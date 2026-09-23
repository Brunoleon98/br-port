"""BR Port F1 group: shared map palette and forms, independent source asset."""
from pathlib import Path
import math,random,subprocess,base64
H=Path(__file__).parent
out=[]
def add(x):out.append(x)
def polygon(points,fill,opacity=1):
 q=' '.join(f'{x:.1f},{y:.1f}' for x,y in points)
 add(f'<polygon points="{q}" fill="{fill}" opacity="{opacity}"/>')
def ellipse(x,y,rx,ry,fill,opacity=1):add(f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" opacity="{opacity}"/>')
def canopy(x,y,rx,ry,seed,primary='#3e8f3a',light='#6fbf4e'):
 r=random.Random(seed);n=7; a0=r.uniform(-.14,.12)
 pts=[]
 for i in range(n):
  a=a0+2*math.pi*i/n
  k=r.uniform(.90,1.06)
  pts.append((x+math.cos(a)*rx*k,y+math.sin(a)*ry*k))
 polygon(pts,'#326f31')
 # One dark edge and two broad lit planes, no full-depth extruded skirt.
 polygon([pts[4],pts[5],pts[6],(x+rx*.17,y+ry*.13)],'#2f7131')
 polygon([pts[2],pts[3],(x-rx*.18,y-ry*.1),pts[1]],primary)
 polygon([pts[0],pts[1],pts[2],(x-rx*.18,y-ry*.1),(x+rx*.18,y-ry*.31)],'#4f9d41')
 polygon([(x-rx*.50,y-ry*.53),(x-rx*.15,y-ry*.78),(x+rx*.06,y-ry*.50)],light,.82)

def tree(x,y,scale,seed):
 r=random.Random(seed)
 ellipse(x+7*scale,y+3*scale,22*scale,5*scale,'#425f3c',.22)
 # Trunk and two forks echo existing map trees, but are thinner than V1.
 polygon([(x-3*scale,y),(x+3*scale,y),(x+2*scale,y-34*scale),(x-2*scale,y-32*scale)],'#5a4632')
 polygon([(x-1*scale,y-21*scale),(x-14*scale,y-37*scale),(x-11*scale,y-38*scale),(x+2*scale,y-27*scale)],'#5a4632')
 polygon([(x+1*scale,y-20*scale),(x+14*scale,y-37*scale),(x+16*scale,y-36*scale),(x+3*scale,y-18*scale)],'#71583b')
 canopy(x-14*scale,y-45*scale,23*scale,16*scale,seed+1)
 canopy(x+12*scale,y-49*scale,24*scale,18*scale,seed+2)
 canopy(x-2*scale,y-62*scale,24*scale,19*scale,seed+3)

def bush(x,y,s,seed,ochre=False):
 colors=('#758b3b','#8d9a42') if ochre else ('#39883a','#69b64a')
 ellipse(x+3*s,y+3*s,13*s,3*s,'#425f3c',.15)
 canopy(x-6*s,y-8*s,17*s,10*s,seed,colors[0],colors[1])
 canopy(x+7*s,y-10*s,14*s,11*s,seed+1,colors[0],colors[1])

add('<svg xmlns="http://www.w3.org/2000/svg" width="600" height="380" viewBox="0 0 300 190">')
# Composition retains the whole upper-left grouping: two rear trees, front undergrowth and tiny ochre accent.
tree(105,143,1.09,101)
tree(213,139,.94,204)
bush(45,141,.88,303)
bush(83,152,1.25,315)
bush(134,150,1.10,337)
bush(178,153,1.22,349)
bush(243,149,1.23,361)
bush(273,137,.58,380)
bush(144,139,.47,411,True)
add('</svg>')
svg='\n'.join(out)
(H/'vegetacao_grupo_f1_v2.svg').write_text(svg)
subprocess.run(['inkscape',str(H/'vegetacao_grupo_f1_v2.svg'),'--export-filename='+str(H/'vegetacao_grupo_f1_v2.png')],check=True,stdout=subprocess.DEVNULL)
# Static preview. The original map remains untouched.
ROOT=H.parents[3]
base=ROOT/'art_lab/f01/13a/v5/mapa_v5.png'
def preview(x,y,w,h,name):
 b1=base64.b64encode(base.read_bytes()).decode()
 b2=base64.b64encode((H/'vegetacao_grupo_f1_v2.png').read_bytes()).decode()
 doc=f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="720" height="720"><image xlink:href="data:image/png;base64,{b1}" width="720" height="720"/><image xlink:href="data:image/png;base64,{b2}" x="{x}" y="{y}" width="{w}" height="{h}"/></svg>'
 p=H/(name+'.svg');p.write_text(doc)
 subprocess.run(['inkscape',str(p),'--export-filename='+str(H/(name+'.png'))],check=True,stdout=subprocess.DEVNULL)
 p.unlink()
preview(22,15,62,39,'mapa_estatico_v2')
