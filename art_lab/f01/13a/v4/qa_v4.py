#!/usr/bin/env python3
"""Guardas da V4: geometria publicada, RNG real e evidência com hash."""
import hashlib
import importlib.util
import json
import random
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "qa_v3"))
from qa_assets import png_problems, changed_outside  # guardas do pacote V3


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def module():
    spec = importlib.util.spec_from_file_location("brp_v4", ROOT / "gerar_mapa_iso_13a_v4.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def world_rect(draw, m, a, b, c, d, fill=0, expand=0):
    pts = []
    for x, y in ((a, c), (b, c), (b, d), (a, d)):
        px, py = m.tela(x, y, m.ALT_CAIS)
        pts.append((px, py))
    draw.polygon(pts, fill=fill)
    if expand:
        from PIL import ImageFilter
        # expansão feita sobre a máscara inteira após desenhar os retângulos


def geometry_mask(m):
    """Branco permite alteração; preto protege geometria do jogo, sem ler o diff."""
    table = json.loads((ROOT / "porto_mapa_ancoras.json").read_text())
    mask = Image.new("L", (720, 720), 255)
    d = ImageDraw.Draw(mask)
    for row in table["faixas"]:
        world_rect(d, m, *row["rua"], *row["my"])
        world_rect(d, m, *row["avental"], *row["my"])
    for row in table["cotovelos"]:
        world_rect(d, m, *row["mx"], *row["my"])
    for row in table["acessos"]:
        world_rect(d, m, *row["mx"], *row["my"])
    for row in table["lotes_reservados"]:
        world_rect(d, m, *row["mx"], *row["my"])
    for lot in table["lotes"]:
        x,y=lot["mx"],lot["my"]
        world_rect(d,m,x-.3,x+lot["dmx"]+.3,y-.3,y+lot["dmy"]+.3)
    for pier in table["pieres"]:
        for key,radius in (("raiz",33),("centro",54),("barco",40)):
            x,y=pier[key]
            d.ellipse((x-radius,y-radius,x+radius,y+radius),fill=0)
    mask.save(ROOT / "mascara_geometria_protegida.png")
    return mask


def positions(m, extra=0):
    rows=[]
    original=m.arbusto_baixo_f1
    def captured(mx,my,r):
        rows.append([round(mx,9),my])
        svg=original(mx,my,r)
        for _ in range(extra):r.random()
        return svg
    m.arbusto_baixo_f1=captured
    try:
        for zone in (1,2):
            lo,hi,edge=m.DEGRAUS[zone]
            m.vegetacao_do_solo(zone,m.FUNDO_TERRA,lo,edge-m.VILA_RECUO_2,hi)
    finally:
        m.arbusto_baixo_f1=original
    return rows


def main():
    m=module()
    rows=[]
    def add(name,status,detail):rows.append(dict(test=name,status=status,detail=detail))
    for file in ("gerar_mapa_iso_13a_v4.py","porto_mapa_iso_v4.svg","porto_mapa_iso_patio_v4.svg","13a_v4_instancia_1.png"):
        add("hash_"+file,"PASS",sha(ROOT/file))
    problems=png_problems(ROOT/"13a_v4_instancia_1.png")
    add("png_alpha_canvas","PASS" if not problems else "FAIL",problems)
    old=positions(m);mutated=positions(m,extra=100)
    add("anchors_stable_on_shape_cost","PASS" if old==mutated else "FAIL",{"normal":old,"mutated":mutated})
    aid="f01_13a_1_0";x,y=old[0]
    specimen=m.arbusto_baixo_f1(x,y,random.Random(m._semente_13a(aid,"forma")))
    match=all(specimen in (ROOT/f).read_text() for f in ("porto_mapa_iso_v4.svg","porto_mapa_iso_patio_v4.svg"))
    add("specimen_exact_svg_in_both_maps","PASS" if match else "FAIL",match)
    add("deterministic_specimen","PASS" if specimen==m.arbusto_baixo_f1(x,y,random.Random(m._semente_13a(aid,"forma"))) else "FAIL",True)
    mask=geometry_mask(m)
    for newpath,label in ((ROOT/"mapa_v4.png","terra"),
                          (ROOT/"mapa_patio_v4.png","patio")):
        # A base é o raster auditado para terra; para pátio renderiza-se também
        # o SVG intacto, pois o script V3 é fonte e não se usa mapa reconstruído.
        before=ROOT/('mapa_v3.png' if label=='terra' else 'mapa_patio_v3.png')
        a=Image.open(before).convert("RGB");b=Image.open(newpath).convert("RGB")
        diff=ImageChops.difference(a,b)
        outside=changed_outside(a,b,mask)
        add(label+"_map_dimensions","PASS" if a.size==b.size==(720,720) else "FAIL",[list(a.size),list(b.size)])
        add(label+"_protected_geometry","PASS" if outside==0 else "FAIL",{"protected_changed_pixels":outside,"changed_pixels":sum(any(p) for p in diff.get_flattened_data()),"bbox":diff.getbbox()})
    for gate in ("godot_capture","android_a23","bruno_visual_review","coast_v8"):
        add(gate,"PENDING","Sem execução/aprovação da candidata V4 para este gate.")
    result={"asset_id":"f01_arbusto_13a","revision":"V4_candidata","base_commit":"cc36166a262a751494ca3ccd25f1359f77b18fc1","source_v3_sha256":"e4c3d35e86f9f37e444a7f08ae51e7e64ebe09385a19bd9f9d126949df66e499","tests":rows,"ready_for_release":False}
    (ROOT/"qa_v4.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n")
    print({s:sum(r["status"]==s for r in rows) for s in ("PASS","FAIL","PENDING")})
    if any(r["status"]=="FAIL" for r in rows):raise SystemExit(1)


if __name__=="__main__":main()
