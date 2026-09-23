#!/usr/bin/env python3
"""Pranchas estáticas: referência marcada, V4 e V5 na mesma escala."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

HERE=Path(__file__).resolve().parent
V4=HERE.parent/'v4'
REF=HERE.parents[3]/'reference/Jogo - BR Port'
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BG='#f7f0df';INK='#203544';MARK='#ee7327'
def font(n,bold=False):return ImageFont.truetype(FONT.replace('Sans.ttf','Sans-Bold.ttf') if bold else FONT,n)
def label(d,xy,text,size=18,bold=False):d.text(xy,text,font=font(size,bold),fill=INK)
def frame(board,im,x,y,w,h):
    board.paste(im.resize((w,h),Image.Resampling.LANCZOS),(x,y))
    ImageDraw.Draw(board).rectangle((x,y,x+w,y+h),outline='#bcb09e',width=2)
def logical(im):
    bbox=im.getchannel('A').getbbox()
    cut=im.crop(bbox)
    w,h=round(cut.width/6),round(cut.height/6)
    out=Image.new('RGBA',(200,105),'#809b64')
    out.alpha_composite(cut.resize((w,h),Image.Resampling.LANCZOS),(100-w//2,66-h))
    return out.convert('RGB'),(w,h)

ref=Image.open(REF/'13_arbustos_vegetacao_baixa_mangue_v4.png').convert('RGB')
group=ref.crop((30,80,340,300))
marked=group.copy();dr=ImageDraw.Draw(marked)
poly=[(111,140),(129,121),(155,119),(183,132),(209,150),(216,176),(193,198),(157,202),(129,191),(110,166)]
dr.line(poly+[poly[0]],fill=MARK,width=4)
v4=Image.open(V4/'13a_v4_instancia_1.png').convert('RGBA')
v5=Image.open(HERE/'13a_v5_instancia_1.png').convert('RGBA')
l4,s4=logical(v4);l5,s5=logical(v5)

sheet=Image.new('RGB',(1320,1130),BG);d=ImageDraw.Draw(sheet)
label(d,(30,20),'BR Port | 13A: V4 -> V5',31,True)
label(d,(30,65),'A moita frontal do conceito esta marcada; troncos e copas vizinhas permanecem no contexto.',17)
frame(sheet,group,30,110,590,418);frame(sheet,marked,700,110,590,418)
label(d,(30,532),'Grupo completo da referencia',19,True)
label(d,(700,532),'Componente usado como direcao, parcialmente oculto',18,True)
label(d,(30,584),'V4 | 1:1 logico, 200 x 105 px',18,True)
label(d,(700,584),'V5 | 1:1 logico, 200 x 105 px',18,True)
sheet.paste(l4,(30,618));sheet.paste(l5,(700,618))
label(d,(30,739),'V4 ampliada 3x',18,True);label(d,(700,739),'V5 ampliada 3x',18,True)
frame(sheet,l4,30,778,600,315);frame(sheet,l5,700,778,600,315)
label(d,(30,1103),f'Alfa no mapa: V4 ~{s4[0]} x {s4[1]} px; V5 ~{s5[0]} x {s5[1]} px. Previa estatica, sem Godot.',15)
sheet.save(HERE/'13a_v5_comparacao_conceito_v4_v5.jpg',quality=94,subsampling=0)

old=Image.open(V4/'mapa_v4.png').convert('RGB');new=Image.open(HERE/'mapa_v5.png').convert('RGB')
positions=[('Mata / margem alta',(170,44)),('Fundo do lote',(87,84)),('Transicao limpa',(96,161))]
board=Image.new('RGB',(1470,1260),BG);d=ImageDraw.Draw(board)
label(d,(24,18),'13A V4 -> V5 | tres posicoes no mapa F1',29,True)
label(d,(24,60),'Cada janela: V4 e V5 a 1:1 logico; ao lado, ampliacao 2,44x. Ponto laranja = ancora no chao.',17)
for i,(title,(cx,cy)) in enumerate(positions):
    top=110+i*371
    label(d,(24,top),title,21,True)
    x=max(0,min(720-180,cx-90));y=max(0,min(720-100,cy-50));box=(x,y,x+180,y+100)
    for j,(source,name) in enumerate(((old,'V4'),(new,'V5'))):
        crop=source.crop(box);dd=ImageDraw.Draw(crop)
        dd.ellipse((cx-x-2,cy-y-2,cx-x+2,cy-y+2),fill=MARK)
        sx=26+j*210;bx=445+j*500
        label(d,(sx,top+38),name+' | 1:1',17,True)
        label(d,(bx,top+38),name+' | 2,44x',17,True)
        frame(board,crop,sx,top+72,180,100)
        frame(board,crop,bx,top+72,440,244)
label(d,(24,1230),'Render Inkscape do mapa SVG; sem HUD, mangues da cena ou captura em aparelho.',15)
board.save(HERE/'13a_v5_tres_posicoes.jpg',quality=94,subsampling=0)

full=Image.new('RGB',(1460,770),BG);d=ImageDraw.Draw(full)
label(d,(12,7),'V4 | antes',19,True);label(d,(734,7),'V5 | depois',19,True)
full.paste(old,(10,35));full.paste(new,(730,35))
full.save(HERE/'13a_v5_mapas_v4_v5.jpg',quality=92)
