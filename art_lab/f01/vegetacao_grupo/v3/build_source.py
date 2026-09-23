from pathlib import Path
import random, math, subprocess, base64
from xml.sax.saxutils import escape
from PIL import Image

OUT=Path(__file__).parent
parts=[]
def add(s): parts.append(s)
def path(d,fill,stroke='none',sw=1,extra=''):
 add(f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round" {extra}/>')
def poly(points,fill,opacity=1):
 add(f'<polygon points="{points}" fill="{fill}" opacity="{opacity}"/>')
def ell(x,y,rx,ry,fill,op=1):
 add(f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" opacity="{op}"/>')

# The source viewBox spans the whole grouping in the approved concept, not one shrub crop.
add('<svg xmlns="http://www.w3.org/2000/svg" width="600" height="380" viewBox="0 0 300 190">')
# Short broken contact shadows, following each root rather than a painted platform.
for x,y,rx,ry in [(45,151,29,5),(105,151,31,5),(177,151,37,5),(246,144,31,5),(137,145,20,4)]:
 ell(x,y,rx,ry,'#4a4930',.11)
for x,y,r in [(27,150,8),(62,156,13),(98,156,10),(165,160,15),(215,151,11),(272,145,10)]:ell(x,y,r,3,'#57543c',.09)

# Trunk silhouettes are visible through canopy openings, with tapering forks.
def trunk(x,y,s=1,mirror=1):
 add(f'<g transform="translate({x} {y}) scale({s*mirror} {s})">')
 path('M-5 0 Q-3 -18 -2 -39 L-12 -62 L-9 -65 L2 -49 L5 -75 L9 -73 L6 -48 L19 -62 L22 -58 L8 -36 L7 0Z','#65503a')
 path('M-2 -3 L0 -44 L4 -46 L3 -5Z','#806343')
 path('M4 -31 L19 -61 L21 -59 L8 -31Z','#92714c')
 add('</g>')
trunk(121,142,1.1)
trunk(209,137,.89,-1)
# Pale branch and root flashes present in reference.
path('M114 142 L109 147 M127 142 L131 146 M205 136 L199 141','none','#5a4834',2)

# Canopies: overlapping irregular leaf masses. No continuous extruded skirt.
def canopy(cx,cy,rx,ry,seed,tones):
 rng=random.Random(seed)
 n=15
 angles=[2*math.pi*i/n for i in range(n)]
 ring=[]
 for a in angles:
  k=rng.uniform(.82,1.12)
  ring.append((cx+math.cos(a)*rx*k,cy+math.sin(a)*ry*k))
 def pts(v):return ' '.join(f'{x:.1f},{y:.1f}' for x,y in v)
 poly(pts(ring),tones[1])
 # A handful of broad plane changes; each facet belongs to one mass.
 for i in range(0,n,2):
  a=ring[i];b=ring[(i+2)%n]
  mx=cx+rng.uniform(-.26,.26)*rx; my=cy+rng.uniform(-.26,.26)*ry
  color=tones[0] if i in (2,4,6,8,10) else tones[2]
  poly(pts([a,ring[(i+1)%n],b,(mx,my)]),color,.83)
 # Directional crown lights smaller than the masses.
 x=cx-rx*.35;y=cy-ry*.42
 poly(pts([(x-rx*.35,y+ry*.19),(x+rx*.01,y-ry*.2),(x+rx*.42,y-ry*.08),(x+rx*.16,y+ry*.22)]),tones[3],.7)

# Back left tree: multi-lobed silhouette, distinct open branching.
canopy(88,65,29,24,21,('#377c35','#285f30','#24502c','#55a243'))
canopy(116,46,31,26,31,('#3d8a38','#2d7232','#245a2f','#64ab45'))
canopy(139,75,18,15,16,('#317532','#285f2f','#1f542d','#529747'))
canopy(110,85,18,13,28,('#348038','#285f31','#26572f','#55a444'))
# Back right tree is lower and broader, like concept's second crown.
canopy(181,78,22,18,12,('#39883a','#2a6b32','#215530','#59a543'))
canopy(214,72,31,24,25,('#3c8738','#286d31','#245b2d','#58a342'))
canopy(233,94,19,15,36,('#337a37','#286631','#24582d','#4b943b'))

# Individual leaves on low, sprawling branches. Elliptical blades end in points.
def leaf(x,y,angle,length,width,color):
 a=math.radians(angle); ux,uy=math.cos(a),math.sin(a); vx,vy=-uy,ux
 base=(x,y);tip=(x+ux*length,y+uy*length)
 p1=(x+ux*length*.42+vx*width,y+uy*length*.42+vy*width)
 p2=(x+ux*length*.42-vx*width,y+uy*length*.42-vy*width)
 d=f'M{base[0]:.1f} {base[1]:.1f} Q{p1[0]:.1f} {p1[1]:.1f} {tip[0]:.1f} {tip[1]:.1f} Q{p2[0]:.1f} {p2[1]:.1f} {base[0]:.1f} {base[1]:.1f}Z'
 path(d,color)
def rosette(x,y,scale,seed,ochre=False):
 rng=random.Random(seed)
 colors=('#658e34','#849e37','#adac41','#c2ae4f') if ochre else ('#2c6832','#36783a','#398341','#4b963f','#5ca548')
 for i in range(10):
  ang=2*math.pi*i/10+rng.uniform(-.22,.22)
  xx=x+math.cos(ang)*scale*.45;yy=y+math.sin(ang)*scale*.24
  leaf(xx,yy,math.degrees(ang)-8,scale*rng.uniform(.78,1.22),scale*.24,rng.choice(colors))
 ell(x,y,scale*.22,scale*.16,colors[0])

# Low branching foliage stays connected to the shrub masses at use size.
for x,y,sc,seed in [(29,126,9,1),(59,128,9,3),(257,129,9,4),(275,128,6,5)]:
 path(f'M{x-5} {y+9} L{x+8} {y-3}','none','#614e36',2)
 rosette(x,y,sc,seed)

# Foreground shrubs are rounded, separate clusters with staggered depth.
for args in [
 (36,121,18,15,41,('#3e8335','#347332','#265f30','#61a044')),
 (62,136,24,16,43,('#438c3a','#377a35','#2d692f','#63a743')),
 (88,118,22,20,44,('#478f3b','#347c34','#28602e','#6eae4c')),
 (151,127,16,14,46,('#448d39','#347735','#2b652f','#68a846')),
 (174,139,20,17,47,('#41873b','#327634','#295d2e','#5fa247')),
 (206,123,15,13,48,('#387f38','#2e7032','#265e2d','#549940')),
 (238,131,15,13,49,('#438e3b','#347934','#2a652e','#62a946'))]:canopy(*args)
# Rose-like leaf tips soften the bush contours without turning into noise.
for x,y,s,k in [(39,131,7,60),(80,142,8,61),(155,135,8,62),(186,148,9,63),(230,139,6,64)]:rosette(x,y,s,k)
# Small ochre middle accent from the original grouping.
rosette(130,131,8,75,True)
# Low broad-leaf sprigs beyond the main shadows.
for x,y,s,k in [(18,139,5,71),(247,143,7,73),(265,136,6,72)]:rosette(x,y,s,k)
add('</svg>')
svg='\n'.join(parts)
import re
def tune(m):
 h=m.group(0);r,g,b=(int(h[i:i+2],16) for i in (1,3,5))
 if g>r*1.12 and g>b*1.28 and g>=75:
  r=min(112,round(.90*r+17));g=min(191,round(.86*g+33));b=min(86,round(.90*b+6))
  return f'#{r:02x}{g:02x}{b:02x}'
 return '#425f3c' if h.lower() in ('#4a4930','#57543c') else h
svg=re.sub(r'#[0-9a-fA-F]{6}',tune,svg)
(OUT/'vegetacao_grupo_f1_v3.svg').write_text(svg,encoding='utf8')
subprocess.run(['inkscape',str(OUT/'vegetacao_grupo_f1_v3.svg'),'--export-filename='+str(OUT/'vegetacao_grupo_f1_v3.png')],check=True,stdout=subprocess.DEVNULL)
