from pathlib import Path
import base64,subprocess
H=Path(__file__).resolve().parent;ROOT=H.parents[3]
def b64(p):return base64.b64encode(p.read_bytes()).decode()
def im(data,x,y,w,h,extra=''):return f'<image xlink:href="data:image/png;base64,{data}" x="{x}" y="{y}" width="{w}" height="{h}" {extra}/>'
def tx(x,y,t,sz=16):return f'<text x="{x}" y="{y}" fill="#263d2c" font-family="DejaVu Sans" font-size="{sz}">{t}</text>'
def box(x,y,w,h):return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="none" stroke="#bfc5b8"/>'
def render(parts,name):
 f=H/(name+'.svg');f.write_text('\n'.join(parts))
 subprocess.run(['inkscape',str(f),'--export-filename='+str(H/(name+'.png'))],check=True,stdout=subprocess.DEVNULL)
 f.unlink()
ref=b64(ROOT/'reference/Jogo - BR Port/13_arbustos_vegetacao_baixa_mangue_v4.png')
base=b64(ROOT/'art_lab/f01/13a/v5/mapa_v5.png')
v1=b64(H.parent/'v1/vegetacao_grupo_f1_v1.png')
v3=b64(H/'vegetacao_grupo_f1_v3.png')
start='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1220" height="840" viewBox="0 0 1220 840">'
s=[start,'<rect width="1220" height="840" fill="#f2f0e8"/>','<defs><clipPath id="ref"><rect x="278" y="61" width="398" height="262"/></clipPath><pattern id="ck" width="20" height="20" patternUnits="userSpaceOnUse"><rect width="20" height="20" fill="#fff"/><rect width="10" height="10" fill="#e0e8de"/><rect x="10" y="10" width="10" height="10" fill="#e0e8de"/></pattern>']
for i,x in enumerate((15,421,827)):s.append(f'<clipPath id="z{i}"><rect x="{x}" y="451" width="376" height="376"/></clipPath>')
s.append('</defs>')
s += [tx(15,38,'CONCEITO · grupo marcado'),im(ref,15,60,235,353),'<rect x="28" y="83" width="65" height="44" fill="none" stroke="#f3aa4c" stroke-width="3"/>',tx(278,38,'REFERÊNCIA · grupo completo'),'<g clip-path="url(#ref)">',im(ref,190,-86,1495,2242),'</g>',box(278,61,398,262),tx(699,38,'V1 · 82 × 52 px'),'<rect x="699" y="61" width="235" height="149" fill="url(#ck)"/>',im(v1,699,61,235,149),tx(963,38,'V3 · 82 × 52 px'),'<rect x="963" y="61" width="235" height="149" fill="url(#ck)"/>',im(v3,963,61,235,149),tx(278,362,'Mesma silhueta da V1; verdes ajustados e ramos laterais mais compactos.'),tx(278,392,'Prévia estática no mapa. Posição ainda não integrada.')]
for i,(title,src) in enumerate([('MAPA ATUAL',None),('V1 · MESMA ESCALA',v1),('V3 · MESMA ESCALA',v3)]):
 x=15+i*406
 s += [tx(x,438,title),f'<g clip-path="url(#z{i})">',im(base,x,451,1728,1728)]
 if src:s.append(im(src,x+12*2.4,451+10*2.4,82*2.4,52*2.4))
 s+=['</g>',box(x,451,376,376)]
s.append('</svg>')
render(s,'comparacao_v1_v3_no_mapa')
positions=[(12,10),(5,105),(0,130)]
s=[start.replace('1220" height="840" viewBox="0 0 1220 840','1160" height="440" viewBox="0 0 1160 440'),'<rect width="1160" height="440" fill="#f2f0e8"/><defs>']
for i in range(3):s.append(f'<clipPath id="p{i}"><rect x="{20+i*380}" y="50" width="360" height="360"/></clipPath>')
s.append('</defs>')
for i,(x,y) in enumerate(positions):
 ox=20+i*380
 s += [tx(ox,34,f'Posição {i+1} · ({x}, {y}) · 82 × 52 px'),f'<g clip-path="url(#p{i})">',im(base,ox,50,1440,1440),im(v3,ox+x*2,50+y*2,164,104),'</g>',box(ox,50,360,360)]
s.append('</svg>')
render(s,'tres_posicoes_v3')
