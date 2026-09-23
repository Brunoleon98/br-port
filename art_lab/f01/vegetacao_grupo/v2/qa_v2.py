from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json
H=Path(__file__).resolve().parent;ROOT=H.parents[3]
a=Image.open(H/'vegetacao_grupo_f1_v2.png').convert('RGBA')
base=Image.open(ROOT/'art_lab/f01/13a/v5/mapa_v5.png').convert('RGBA')
prev=Image.open(H/'mapa_estatico_v2.png').convert('RGBA')
mask=Image.open(ROOT/'art_lab/f01/13a/v5/mascara_geometria_protegida_v5.png').convert('L')
diff=ImageChops.difference(base,prev).convert('RGB')
pix=diff.load();protected=mask.load();n=0;blocked=0
for y in range(720):
 for x in range(720):
  if pix[x,y]!=(0,0,0):
   n+=1
   if protected[x,y]<128:blocked+=1
checks={'PNG RGBA 600x380':a.size==(600,380),'cantos transparentes':all(a.getpixel(c)[3]==0 for c in [(0,0),(599,0),(0,379),(599,379)]),'desenho visível':a.getchannel('A').getbbox() is not None,'prévia 720x720':base.size==prev.size==(720,720),'geometria protegida intacta':n>0 and blocked==0,'três posições fora da máscara':all(all(mask.getpixel((px,py))>=128 for py in range(y,y+39) for px in range(x,x+62)) for x,y in [(22,15),(5,110),(18,145)]),'cores da copa e luz do mapa presentes':all(color in (H/'vegetacao_grupo_f1_v2.svg').read_text().lower() for color in ('#3e8f3a','#6fbf4e'))}
r={'candidate':'vegetacao_grupo_f1_v2','compare':'V1 e V2 no mesmo tamanho lógico 62x39','checks':[{'name':k,'status':'PASS' if v else 'FAIL'} for k,v in checks.items()],'changed_pixels':n,'protected_changed_pixels':blocked,'alpha_bbox':a.getchannel('A').getbbox(),'sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (H/'vegetacao_grupo_f1_v2.svg',H/'vegetacao_grupo_f1_v2.png',H/'mapa_estatico_v2.png')},'pending':['avaliação estética de Bruno','captura Godot','teste em aparelho alvo','integração no gerador e verificação de sobreposição com objetos não incluídos na máscara'],'ready_for_release':False}
(H/'qa_v2.json').write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n')
print(sum(checks.values()),'PASS;',len(checks)-sum(checks.values()),'FAIL;',n,'alterados;',blocked,'protegidos')
if not all(checks.values()):raise SystemExit(1)
