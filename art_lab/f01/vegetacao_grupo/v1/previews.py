from pathlib import Path
import base64,subprocess
H=Path(__file__).resolve().parent
ROOT=H.parents[3]
def data(p):return base64.b64encode(p.read_bytes()).decode('ascii')
def raster(s,name):
 f=H/(name+'.svg');f.write_text(s)
 subprocess.run(['inkscape',str(f),'--export-filename='+str(H/(name+'.png'))],stdout=subprocess.DEVNULL,check=True)
 f.unlink()
ref=data(ROOT/'reference/Jogo - BR Port/13_arbustos_vegetacao_baixa_mangue_v4.png')
asset=data(H/'vegetacao_grupo_f1_v1.png')
mapa=data(H/'mapa_estatico_v1.png')
def img(src,x,y,w,h):return f'<image xlink:href="data:image/png;base64,{src}" x="{x}" y="{y}" width="{w}" height="{h}"/>'
def txt(x,y,t,size=20,color='#283b30'):return f'<text x="{x}" y="{y}" font-family="DejaVu Sans" font-size="{size}" fill="{color}">{t}</text>'
# Context and a marked complete upper-left grouping.
s=['<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1200" height="810" viewBox="0 0 1200 810">','<rect width="1200" height="810" fill="#f5f1e8"/>','<defs><clipPath id="crop"><rect x="373" y="79" width="414" height="305"/></clipPath><pattern id="checker" width="20" height="20" patternUnits="userSpaceOnUse"><rect width="20" height="20" fill="#fbfbfb"/><rect width="10" height="10" fill="#dce3dc"/><rect x="10" y="10" width="10" height="10" fill="#dce3dc"/></pattern></defs>']
s += [txt(24,40,'CONCEITO INTEIRO · alvo marcado',16),img(ref,24,60,320,480),'<rect x="41" y="91" width="87" height="61" fill="none" stroke="#f5a344" stroke-width="4"/>',txt(373,40,'GRUPO COMPLETO · ampliado',16),'<g clip-path="url(#crop)">',img(ref,285,-81,1536,2304),'</g>','<rect x="373" y="79" width="414" height="305" fill="none" stroke="#c9c3af"/>',txt(814,40,'ASSET V1 · PNG alfa',16),'<rect x="814" y="79" width="360" height="228" fill="url(#checker)"/>',img(asset,814,79,360,228),txt(24,583,'NO MAPA · prévia estática, 100 × 63 px, canto da mata',18),img(mapa,24,602,185,185),'<rect x="239" y="602" width="360" height="208" fill="#718f66"/>',img(mapa,239-12*3.4,602-10*3.4,720*3.4,720*3.4),'<rect x="239" y="602" width="360" height="208" fill="none" stroke="#c9c3af"/>',txt(646,638,'Leitura: duas árvores e sub-bosque em uma só peça.',17),txt(646,670,'Posição exploratória; não integrada ao projeto.',17),txt(646,702,'Aprovação visual: pendente.',17)]
# Zoom is physically clipped to target crop.
s.insert(1,'<defs><clipPath id="zoom"><rect x="239" y="602" width="360" height="208"/></clipPath></defs>')
# Existing zoom image needs clipping: add clip-path on the element before it.
s=[v.replace('<image xlink:href="data:image/png;base64,'+mapa+'" x="198.2"','<image clip-path="url(#zoom)" xlink:href="data:image/png;base64,'+mapa+'" x="198.2"') for v in s]
s.append('</svg>')
raster('\n'.join(s),'comparacao_grupo_v1')
# Three alternative candidate placements, each in the same static base map.
base=data(ROOT/'art_lab/f01/13a/v5/mapa_v5.png')
positions=[(12,10,100,63),(5,105,80,50),(42,1,90,57)]
s=['<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1125" height="440" viewBox="0 0 1125 440"><rect width="1125" height="440" fill="#f5f1e8"/><defs>'+''.join(f'<clipPath id="z{i}"><rect x="{18+i*370}" y="50" width="350" height="350"/></clipPath>' for i in range(3))+'</defs>']
for i,(x,y,w,h) in enumerate(positions):
 a=18+i*370
 s += [txt(a,31,f'Posição {i+1} · {w} × {h} px',16),f'<g clip-path="url(#z{i})">'+img(base,a,50,1440,1440)+img(asset,a+x*2,50+y*2,w*2,h*2)+'</g>',f'<rect x="{a}" y="50" width="350" height="350" fill="none" stroke="#c9c3af"/>']
s.append('</svg>')
raster('\n'.join(s),'tres_posicoes_estaticas_v1')
