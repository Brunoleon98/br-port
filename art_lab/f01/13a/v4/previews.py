#!/usr/bin/env python3
"""Pranchas estáticas para avaliação humana; não são captura do Godot."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
REF=ROOT/'reference/Jogo - BR Port'
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BG='#f7f0df';INK='#203544';ACC='#d4722c';LINE='#d6cbbb'
def font(n,bold=False):return ImageFont.truetype(FONT.replace('Sans.ttf','Sans-Bold.ttf') if bold else FONT,n)
def label(d,xy,string,size=20,color=INK,bold=False):d.text(xy,string,font=font(size,bold),fill=color)
def framed(dst,src,box):
    x,y,w,h=box
    d=ImageDraw.Draw(dst);d.rectangle((x-1,y-1,x+w,y+h),outline=LINE,width=2)
    dst.paste(src.resize((w,h),Image.Resampling.LANCZOS),(x,y))

ref=Image.open(REF/'13_arbustos_vegetacao_baixa_mangue_v4.png').convert('RGB')
marked=ref.crop((30,80,340,300))
d=ImageDraw.Draw(marked)
# Região de interesse proposta: moita baixa à frente das copas, ainda parcialmente ocluída.
poly=[(111,140),(129,121),(155,119),(183,132),(209,150),(216,176),(193,198),(157,202),(129,191),(110,166)]
d.line(poly+[poly[0]],fill='#f27427',width=5)
d.ellipse((155,154,166,165),fill='#f27427')
v3=Image.open(REF/'13a_arbusto_baixo_v3.png').convert('RGBA')
v4=Image.open(HERE/'13a_v4_instancia_1.png').convert('RGBA')

# Há diferença de representação: V3 é 4x pixels/desenho; V4 é 4x via viewBox.
# Ambos encolhem 1/6 na tela (desenho 1080 -> mapa 720).
def logical(im):
    bbox=im.getchannel('A').getbbox()
    shape=im.crop(bbox)
    w=max(1,round(shape.width/6));h=max(1,round(shape.height/6))
    tile=Image.new('RGBA',(200,105),'#708e59')
    ground=Image.new('RGBA',(200,105),'#809b64')
    tile.alpha_composite(ground)
    shrunk=shape.resize((w,h),Image.Resampling.LANCZOS)
    tile.alpha_composite(shrunk,(100-w//2,60-h))
    return tile.convert('RGB'),(w,h)

lv3,size3=logical(v3);lv4,size4=logical(v4)
board=Image.new('RGB',(1240,1130),BG);d=ImageDraw.Draw(board)
label(d,(36,25),'BR Port | 13A V4: comparacao visual',30,bold=True)
label(d,(36,68),'Referencia conceitual: a linha laranja marca a moita frontal proposta, com o grupo preservado.',17)
framed(board,ref.crop((30,80,340,300)),(38,118,540,383))
framed(board,marked,(654,118,540,383))
label(d,(38,510),'Grupo completo (recorte original)',18,bold=True)
label(d,(654,510),'Regiao marcada: oculta parcialmente por copas vizinhas',17,bold=True)
label(d,(38,553),'V3 | recorte a 1:1 logico (200 x 105 px)',18,bold=True)
label(d,(654,553),'V4 | recorte a 1:1 logico (200 x 105 px)',18,bold=True)
board.paste(lv3,(38,590));board.paste(lv4,(654,590))
label(d,(38,712),'V3 ampliada 2,7x',18,bold=True)
label(d,(654,712),'V4 ampliada 2,7x',18,bold=True)
framed(board,lv3,(38,750,540,284));framed(board,lv4,(654,750,540,284))
label(d,(38,1051),f'Massa alfa V3: ~{size3[0]} x {size3[1]} px; V4: ~{size4[0]} x {size4[1]} px no mapa.',17)
label(d,(38,1080),'A referencia nao fixa escala. V3/V4: 1080 -> 720; nao sao capturas Godot.',16)
board.save(HERE/'13a_v4_comparacao.jpg',quality=93,subsampling=0)

# Três instâncias existentes, cada uma na mesma janela fixa antes/depois.
old=Image.open(HERE/'mapa_v3.png').convert('RGB')
new=Image.open(HERE/'mapa_v4.png').convert('RGB')
positions=[('Mata / margem alta',(170,44)),('Fundo do lote',(87,84)),('Transicao limpa',(96,161))]
sheet=Image.new('RGB',(1400,1250),BG);d=ImageDraw.Draw(sheet)
label(d,(26,18),'13A | tres posicoes no mapa F1',29,bold=True)
label(d,(26,60),'Em cada linha: V3 e V4 no tamanho logico 1:1; depois ampliacao 2,44x do mesmo recorte.',17)
for i,(title,(cx,cy)) in enumerate(positions):
    top=110+i*370
    label(d,(26,top),title,21,bold=True)
    # 180x100 preservado nos dois estados; centro aproximado marcado com ponto laranja.
    x=max(0,min(720-180,cx-90));y=max(0,min(720-100,cy-50));box=(x,y,x+180,y+100)
    for j,(source,name) in enumerate(((old,'V3'),(new,'V4'))):
        crop=source.crop(box)
        dd=ImageDraw.Draw(crop)
        dd.ellipse((cx-x-2,cy-y-2,cx-x+2,cy-y+2),fill=ACC)
        smallx=30+j*210
        label(d,(smallx,top+39),name+' | 1:1',17,bold=True)
        framed(sheet,crop,(smallx,top+70,180,100))
        bigx=445+j*465
        label(d,(bigx,top+39),name+' | 2,44x',17,bold=True)
        framed(sheet,crop,(bigx,top+70,440,244))
label(d,(26,1222),'Rasterizacao Inkscape; sem HUD, mangues da cena ou captura em aparelho.',15)
sheet.save(HERE/'13a_v4_tres_posicoes.jpg',quality=93,subsampling=0)

full=Image.new('RGB',(1460,770),BG);d=ImageDraw.Draw(full)
label(d,(14,7),'V3 | antes (estatico)',19,bold=True);label(d,(742,7),'V4 | depois (estatico)',19,bold=True)
full.paste(old,(10,35));full.paste(new,(730,35))
full.save(HERE/'13a_v4_mapas_antes_depois.jpg',quality=92)
