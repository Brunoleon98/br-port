"""As folhas de contato das variações: a tabela inteira, sem sorteio.

Arte que varia com o estado do jogo não aparece nas fotos da partida (o
`CLAUDE.md`, Arte): prova-se numa folha que percorre a tabela. Duas escalas:

- `folha_cartao.png` — ao TAMANHO DO CARTÃO: o `Retrato` do `Worker.tscn` tem
  70 de altura em `KEEP_ASPECT_CENTERED`, sobre o fundo do `TrabLivre`; a 70
  (a tela de 720) e a 105 (um telefone de 1080);
- `folha_ampliada.png` — a cabeça e os ombros de cada um, a 2x do cartão de
  1080 e sem suavizar, para ler o que a folha pequena não mostra.

    python3 art_lab/retratos/trabalhador_variacoes/v3/montar_folhas.py [png|previa]
"""

import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

AQUI = pathlib.Path(__file__).resolve().parent
CORES = ("branca", "parda", "preta", "amarela", "indigena")
LINHAS = [(s, i) for s in ("homem", "mulher") for i in ("jovem", "adulto", "veterano")]
FUNDO = (237, 251, 242)          # o `bg_color` do `trab_livre`, no tema
PAPEL = (250, 250, 250)


def _fonte(tam):
    for f in ("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",):
        try:
            return ImageFont.truetype(f, tam)
        except OSError:
            pass
    return ImageFont.load_default()


def _grade(pasta, lado, recorte=None, ampliar=1, margem=6):
    fonte = _fonte(13)
    rot_l, rot_t = 120, 24
    cel = lado * ampliar
    w = rot_l + len(CORES) * (cel + margem) + margem
    h = rot_t + len(LINHAS) * (cel + margem) + margem
    folha = Image.new("RGB", (w, h), PAPEL)
    d = ImageDraw.Draw(folha)
    for c, cor in enumerate(CORES):
        d.text((rot_l + margem + c * (cel + margem), 5), cor, fill=(40, 40, 40), font=fonte)
    for li, (sexo, idade) in enumerate(LINHAS):
        y = rot_t + margem + li * (cel + margem)
        d.text((6, y + cel // 2 - 8), "%s %s" % (sexo, idade), fill=(40, 40, 40), font=fonte)
        for c, cor in enumerate(CORES):
            png = pasta / ("trabalhador_%s_%s_%s.png" % (sexo, idade, cor))
            im = Image.open(png).convert("RGBA")
            if recorte:
                q = im.size[0] / 768.0
                im = im.crop(tuple(int(v * q) for v in recorte))
            im = im.resize((lado, lado), Image.LANCZOS)
            if ampliar > 1:
                im = im.resize((cel, cel), Image.NEAREST)
            base = Image.new("RGBA", (cel, cel), FUNDO + (255,))
            base.alpha_composite(im)
            folha.paste(base.convert("RGB"), (rot_l + margem + c * (cel + margem), y))
    return folha


def main():
    pasta = AQUI / (sys.argv[1] if len(sys.argv) > 1 else "png")
    a = _grade(pasta, 70)
    b = _grade(pasta, 105)
    folha = Image.new("RGB", (a.width + b.width + 20, max(a.height, b.height)), PAPEL)
    folha.paste(a, (0, 0))
    folha.paste(b, (a.width + 20, 0))
    folha.save(AQUI / "folha_cartao.png")
    # A cabeça e os ombros, sem o fundo vazio. ⚠️ A JANELA SAI DOS 30, e não do
    # padrão: escrita à mão (150–618, a cabeça de hoje) ela cortava 14 px do
    # cabelo crespo, que vai até aos 632, e a folha fazia parecer cortado um
    # retrato que no cartão sai inteiro (a pergunta do Bruno na v3).
    _grade(pasta, 105, recorte=_janela(pasta), ampliar=2).save(AQUI / "folha_ampliada.png")
    print("folhas em", AQUI)


def _janela(pasta, alto=468, folga=8):
    """O quadrado centrado no busto que cabe o mais largo dos 30 na altura da
    cabeça (os `alto` px de cima do quadro de 768)."""
    meia = alto / 2.0
    for png in pasta.glob("trabalhador_*.png"):
        im = Image.open(png).convert("RGBA")
        q = im.size[0] / 768.0
        caixa = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).crop(
            (0, 0, im.size[0], int(alto * q))).getbbox()
        if caixa:
            meia = max(meia, 384.0 - caixa[0] / q + folga, caixa[2] / q - 384.0 + folga)
    return (384.0 - meia, 0.0, 384.0 + meia, 2.0 * meia)


if __name__ == "__main__":
    main()
