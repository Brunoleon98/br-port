from pathlib import Path
from PIL import Image,ImageChops
import json,hashlib,subprocess
H=Path(__file__).resolve().parent;ROOT=H.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
a=Image.open(H/'vegetacao_grupo_f1_v1.png').convert('RGBA')
b=Image.open(ROOT/'art_lab/f01/13a/v5/mapa_v5.png').convert('RGBA')
c=Image.open(H/'mapa_estatico_v1.png').convert('RGBA')
m=Image.open(ROOT/'art_lab/f01/13a/v5/mascara_geometria_protegida_v5.png').convert('L')
d=ImageChops.difference(b,c).convert('RGBA')
changed=sum(d.getpixel((x,y))[:3]!=(0,0,0) for y in range(720) for x in range(720))
protected=sum(d.getpixel((x,y))[:3]!=(0,0,0) and m.getpixel((x,y))<128 for y in range(720) for x in range(720))
checks={
 'asset_rgba':a.mode=='RGBA',
 'canvas_600x380':a.size==(600,380),
 'corner_alpha_zero':all(a.getpixel(p)[3]==0 for p in ((0,0),(599,0),(0,379),(599,379))),
 'has_visible_pixels':a.getchannel('A').getbbox() is not None,
 'preview_720x720':b.size==c.size==(720,720),
 'preview_changes_only_unprotected_geometry':changed>0 and protected==0,
}
r={'candidate':'vegetacao_grupo_f1_v1','reference':'13_arbustos_vegetacao_baixa_mangue_v4.png; grupo superior esquerdo completo','scale':{'source_canvas':[600,380],'use_size':[100,63],'static_map_position':[12,10]},'checks':[{'name':k,'status':'PASS' if v else 'FAIL'} for k,v in checks.items()],'changed_pixels':changed,'changed_protected_pixels':protected,'alpha_bbox':a.getchannel('A').getbbox(),'sha256':{p.name:sha(p) for p in (H/'vegetacao_grupo_f1_v1.svg',H/'vegetacao_grupo_f1_v1.png',H/'mapa_estatico_v1.png')},'pending':['avaliação estética de Bruno','captura runtime Godot','teste aparelho alvo','integração no gerador e revisão das posições'], 'ready_for_release':False}
(H/'qa_grupo.json').write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n')
print('PASS',sum(checks.values()),'FAIL',len(checks)-sum(checks.values()),'changed',changed,'protected',protected)
if not all(checks.values()):raise SystemExit(1)
