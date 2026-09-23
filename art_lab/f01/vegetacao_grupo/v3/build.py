"""Retune V1 vector artwork to the F1 map palette; preserve silhouette."""
from pathlib import Path
import re,subprocess,base64
H=Path(__file__).parent;ROOT=H.parents[3]
subprocess.run(['python',str(H/'build_source.py')],check=True)
base=ROOT/'art_lab/f01/13a/v5/mapa_v5.png'
def preview(src,x,y,w,h,name):
 b1=base64.b64encode(base.read_bytes()).decode();b2=base64.b64encode(src.read_bytes()).decode()
 doc=f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="720" height="720"><image xlink:href="data:image/png;base64,{b1}" width="720" height="720"/><image xlink:href="data:image/png;base64,{b2}" x="{x}" y="{y}" width="{w}" height="{h}"/></svg>'
 p=H/(name+'.svg');p.write_text(doc)
 subprocess.run(['inkscape',str(p),'--export-filename='+str(H/(name+'.png'))],check=True,stdout=subprocess.DEVNULL)
 p.unlink()
preview(H.parent/'v1/vegetacao_grupo_f1_v1.png',12,10,82,52,'mapa_v1_82px')
preview(H/'vegetacao_grupo_f1_v3.png',12,10,82,52,'mapa_v3_82px')
