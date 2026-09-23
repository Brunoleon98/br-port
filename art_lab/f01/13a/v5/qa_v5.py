#!/usr/bin/env python3
"""Avaliação técnica da V5 sem substituir testes de Godot e julgamento visual."""
from pathlib import Path
import hashlib,importlib.util,json,random,sys
from PIL import Image,ImageChops,ImageDraw

HERE=Path(__file__).resolve().parent;V4=HERE.parent/'v4'
sys.path.insert(0,str(V4/'qa_v3'))
from qa_assets import png_problems,changed_outside

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(path,name):
    s=importlib.util.spec_from_file_location(name,path)
    m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def positions(m,extra=0):
    found=[];original=m.arbusto_baixo_f1
    def capture(x,y,r):
        found.append((round(x,9),y));out=original(x,y,r)
        for _ in range(extra):r.random()
        return out
    m.arbusto_baixo_f1=capture
    try:
        for i in (1,2):
            lo,hi,edge=m.DEGRAUS[i]
            m.vegetacao_do_solo(i,m.FUNDO_TERRA,lo,edge-m.VILA_RECUO_2,hi)
    finally:m.arbusto_baixo_f1=original
    return found
def projection(m,x,y):return m.tela(x,y,m.ALT_CAIS)
def world_box(d,m,a,b,c,e):
    d.polygon([projection(m,x,y) for x,y in ((a,c),(b,c),(b,e),(a,e))],fill=0)
def protected_mask(m):
    table=json.loads((V4/'porto_mapa_ancoras.json').read_text())
    mask=Image.new('L',(720,720),255);d=ImageDraw.Draw(mask)
    for item in table['faixas']:
        for key in ('rua','avental'):world_box(d,m,*item[key],*item['my'])
    for group in ('cotovelos','acessos','lotes_reservados'):
        for item in table[group]:world_box(d,m,*item['mx'],*item['my'])
    for lot in table['lotes']:
        x,y=lot['mx'],lot['my'];world_box(d,m,x-.3,x+lot['dmx']+.3,y-.3,y+lot['dmy']+.3)
    for pier in table['pieres']:
        for key,radius in (('raiz',33),('centro',54),('barco',40)):
            x,y=pier[key];d.ellipse((x-radius,y-radius,x+radius,y+radius),fill=0)
    mask.save(HERE/'mascara_geometria_protegida_v5.png')
    return mask
def main():
    m4=load(V4/'gerar_mapa_iso_13a_v4.py','old');m5=load(HERE/'gerar_mapa_iso_13a_v5.py','new')
    rows=[]
    def add(test,status,detail):rows.append(dict(test=test,status=status,detail=detail))
    for name in ('arbusto_v5.py.txt','gerar_mapa_iso_13a_v5.py','porto_mapa_iso_v5.svg','porto_mapa_iso_patio_v5.svg','13a_v5_instancia_1.png'):
        add('sha_'+name,'PASS',sha(HERE/name))
    errs=png_problems(HERE/'13a_v5_instancia_1.png')
    add('png_alpha_canvas','PASS' if not errs else 'FAIL',errs)
    a,b,c=positions(m4),positions(m5),positions(m5,100)
    add('same_five_anchors_V4_V5','PASS' if a==b else 'FAIL',{'v4':a,'v5':b})
    add('form_cost_does_not_move_anchors','PASS' if b==c else 'FAIL',{'v5':b,'mutated':c})
    x,y=b[0];id='f01_13a_1_0'
    svg=m5.arbusto_baixo_f1(x,y,random.Random(m5._semente_13a(id,'forma')))
    exact=all(svg in (HERE/name).read_text() for name in ('porto_mapa_iso_v5.svg','porto_mapa_iso_patio_v5.svg'))
    add('same_specimen_in_both_maps','PASS' if exact else 'FAIL',exact)
    add('unchanged_gameplay_anchor_table','PASS' if sha(HERE/'porto_mapa_ancoras.json')==sha(V4/'porto_mapa_ancoras.json') else 'FAIL',sha(HERE/'porto_mapa_ancoras.json'))
    mask=protected_mask(m5)
    for mode in ('mapa','mapa_patio'):
        before=Image.open(V4/(mode+'_v4.png')).convert('RGB');after=Image.open(HERE/(mode+'_v5.png')).convert('RGB')
        diff=ImageChops.difference(before,after)
        outside=changed_outside(before,after,mask)
        add(mode+'_dimensions','PASS' if before.size==after.size==(720,720) else 'FAIL',list(after.size))
        add(mode+'_protected_geometry','PASS' if outside==0 else 'FAIL',{'protected_changed_pixels':outside,'changed_pixels':sum(any(p) for p in diff.get_flattened_data()),'bbox':diff.getbbox()})
    for name in ('godot_scene_capture','android_a23','bruno_visual_review','coast_V8'):
        add(name,'PENDING','Sem execução ou aceite para esta candidata.')
    report={'revision':'13A_V5_candidata','base':'13A_V4_laboratorio','tests':rows,'ready_for_release':False}
    (HERE/'qa_v5.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print({status:sum(x['status']==status for x in rows) for status in ('PASS','FAIL','PENDING')})
    if any(x['status']=='FAIL' for x in rows):raise SystemExit(1)
if __name__=='__main__':main()
