from pathlib import Path
import base64,subprocess
H=Path(__file__).resolve().parent;ROOT=H.parents[3]
base=ROOT/'art_lab/f01/13a/v5/mapa_v5.png'
v1=H.parent/'v1/vegetacao_grupo_f1_v1.png';v2=H/'vegetacao_grupo_f1_v2.png'
ref=ROOT/'reference/Jogo - BR Port/13_arbustos_vegetacao_baixa_mangue_v4.png'
def data(p):return base64.b64encode(p.read_bytes()).decode()
def img(src,x,y,w,h,extra=''):return f'<image xlink:href="data:image/png;base64,{src}" x="{x}" y="{y}" width="{w}" height="{h}" {extra}/>'
def txt(x,y,s,size=17):return f'<text x="{x}" y="{y}" font-family="DejaVu Sans" font-size="{size}" fill="#203c2d">{s}</text>'
def render(s,name):
 f=H/(name+'.svg');f.write_text(s)
 subprocess.run(['inkscape',str(f),'--export-filename='+str(H/(name+'.png'))],check=True,stdout=subprocess.DEVNULL)
 f.unlink()
b=data(base);a=data(v1);c=data(v2);rf=data(ref)
# Same place and use dimensions for both candidates.
for source,name in [(a,'mapa_v1_mesma_escala'),(c,'mapa_v2_mesma_escala')]:
 s='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="720" height="720">'+img(b,0,0,720,720)+img(source,22,15,62,39)+'</svg>'
 render(s,name)
# Context, reference target, transparent standalone sprites, and scene crop at 2.4x.
def box(x,y,w,h):return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="none" stroke="#cdc8ba"/>'
s=['<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1230" height="845" viewBox="0 0 1230 845">','<rect width="1230" height="845" fill="#f2f0e8"/>','<defs><clipPath id="ref"><rect x="290" y="60" width="370" height="245"/></clipPath><pattern id="ck" width="20" height="20" patternUnits="userSpaceOnUse"><rect width="20" height="20" fill="white"/><rect width="10" height="10" fill="#e0e8de"/><rect x="10" y="10" width="10" height="10" fill="#e0e8de"/></pattern>']
for i,x in enumerate((22,428,834)):s.append(f'<clipPath id="z{i}"><rect x="{x}" y="452" width="370" height="370"/></clipPath>')
s.append('</defs>')
s.extend([txt(20,38,'CONCEITO COMPLETO',16),img(rf,20,60,240,360),'<rect x="33" y="82" width="66" height="46" fill="none" stroke="#f3aa4c" stroke-width="3"/>',txt(290,38,'GRUPO DE REFERÊNCIA',16),'<g clip-path="url(#ref)">'+img(rf,212,-82,1382,2073)+'</g>',box(290,60,370,245),txt(695,38,'V1 · 62 × 39 px no jogo',16),'<rect x="695" y="60" width="230" height="146" fill="url(#ck)"/>',img(a,695,60,230,146),txt(966,38,'V2 · 62 × 39 px no jogo',16),'<rect x="966" y="60" width="230" height="146" fill="url(#ck)"/>',img(c,966,60,230,146),txt(290,352,'V2 usa copa #3E8F3A e luz #6FBF4E, como a vegetação do mapa.',16),txt(290,385,'Uma peça única, com duas árvores e arbustos; posição ainda exploratória.',16)])
for i,(name,asset) in enumerate([('MAPA ANTERIOR',None),('V1 NA MESMA ESCALA',a),('V2 NA MESMA ESCALA',c)]):
 x=22+i*406
 s += [txt(x,442,name,16),f'<g clip-path="url(#z{i})">',img(b,x,452,720*2.4,720*2.4)]
 if asset:s.append(img(asset,x+22*2.4,452+15*2.4,62*2.4,39*2.4))
 s+=['</g>',box(x,452,370,370)]
s.append('</svg>')
render('\n'.join(s),'comparacao_v1_v2_no_mapa')
positions=[(22,15),(5,110),(18,145)]
s=['<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1160" height="440" viewBox="0 0 1160 440"><rect width="1160" height="440" fill="#f2f0e8"/><defs>']
for i in range(3):s.append(f'<clipPath id="p{i}"><rect x="{20+i*380}" y="50" width="360" height="360"/></clipPath>')
s.append('</defs>')
for i,(x,y) in enumerate(positions):
 ox=20+i*380
 s += [txt(ox,34,f'Posição {i+1} · ({x}, {y}) · 62 × 39 px',16),f'<g clip-path="url(#p{i})">',img(b,ox,50,1440,1440),img(c,ox+x*2,50+y*2,124,78),'</g>',box(ox,50,360,360)]
s.append('</svg>')
render('\n'.join(s),'tres_posicoes_v2')
