#!/usr/bin/env python3
"""Confere um lote de arte recebido de fora, antes de ele entrar no jogo.

Escrito depois do segundo lote que chegou com o mesmo defeito. O de 28/08 veio
sem canal alfa (`docs/arquivo/BLOCO4_PACOTE_SPRITES.md`); o de 31/08 veio sem alfa E com
metade das peças em outra projeção — o guindaste avulso a 34,6° contra os 26,57°
do mapa, e um prédio da prancha de progressão a 28,2°, dentro do contrato. O
lote não era homogêneo, e ninguém veria isso a olho.

Responde as três perguntas que decidem se um asset entra no jogo ou fica como
referência:

1. Tem canal alfa de verdade, ou o xadrez está pintado nos pixels?
   (A leva de 28/08 veio assim; `tools/preparar_sprites.py` existe por isso.)
2. Em que ângulo a base foi desenhada?
   O contrato do projeto é 2:1 — 26,57°. O gerador de imagem não erra o
   desenho, erra o ÂNGULO, e ângulo errado não se conserta rodando no Godot.
3. Que tamanho e formato tem, contra os 512×512 RGBA dos props em produção.

Não decide nada: mede e classifica. Quem decide se o asset entra é quem olha a
captura. Sem dependência além de Pillow e numpy.

Uso:  python3 tools/conferir_lote_de_arte.py <pasta_do_lote> [--json saida.json]
"""

import argparse
import json
import math
import pathlib
import sys

import numpy as np
from PIL import Image

# O contrato da projeção vive em tools/gerar_mapa_iso.py e tools/gerar_props_iso.py:
# MEIA_LARG=30, MEIA_ALT=15, razão 2:1. A aresta de um quadrado do mundo cai
# então a atan(15/30) = 26,565° da horizontal. Mexer lá obriga a mexer aqui —
# mas o certo é ler de lá, e é o que se faz quando o import for possível.
MEIA_LARG, MEIA_ALT = 30.0, 15.0
CONTRATO_GRAUS = math.degrees(math.atan(MEIA_ALT / MEIA_LARG))   # 26,57°
TOLERANCIA = 3.0                                                 # medido na mão, não é exato


def mascara(caminho):
    """Separa objeto de fundo e diz como o fundo foi feito."""
    im = Image.open(caminho)
    a = np.asarray(im.convert("RGBA")).astype(int)
    if im.mode in ("RGBA", "LA") and a[..., 3].min() < 250:
        return a[..., 3] > 128, "alfa"
    # sem alfa: o fundo é o xadrez cinza (r == g == b), o objeto tem saturação
    saturacao = a[..., :3].max(2) - a[..., :3].min(2)
    return saturacao > 28, "xadrez pintado"


# A classificação é assistida por convenção de nome, não adivinhada. Sem alfa de
# verdade não existe regra geométrica que separe com segurança uma tela cheia de
# um prop recortado — e número errado é pior que número ausente.
PALAVRAS_DE_PRANCHA = ("conceito", "variac", "variaç", "tile", "sheet", "folha",
                       "gameplay", "nivel", "nível", "tela", "prancha")


def classificar(caminho, m):
    """Objeto isolado, folha de vários desenhos, ou prancha/tile.

    Medir ângulo de base numa folha é medir a silhueta do conjunto, que não quer
    dizer nada. A separação por blocos de colunas vazias pega as folhas espaçadas
    (5 a 9 blocos contra 2 de um prop, medido no lote de 31/08), mas NÃO pega a
    prancha densa, em que os desenhos se tocam — nem a fração de área separa as
    duas (a prancha da cidade ocupa 29,6% e o caminhão 21,2%). Por isso a segunda
    regra é o nome do arquivo, que é convenção e não adivinhação. Na dúvida o
    script não mede: número errado é pior que número ausente.
    """
    col = m.any(axis=0)
    vao = max(2, int(m.shape[1] * 0.02))          # vão mínimo para separar peças
    blocos, corrido = 0, 0
    for ocupada in col:
        if ocupada:
            corrido = 0
        else:
            corrido += 1
            if corrido == vao:
                blocos += 1
    if blocos >= 3:
        return "folha"
    # Composição de quadro cheio (tela, tile, prancha densa): sangra pelas
    # quatro bordas. Um objeto recortado sempre tem margem em volta — é o que
    # separa uma tela de gameplay de um prop, sem depender do nome do arquivo.
    if (m[0].any() and m[-1].any() and m[:, 0].any() and m[:, -1].any()
            and m.mean() > 0.85):
        return "tela"
    nome = caminho.name.lower()
    if any(w in nome for w in PALAVRAS_DE_PRANCHA):
        return "prancha"
    return "objeto"


def angulo_da_base(m):
    """Devolve `(esquerda, direita)` — as duas arestas do apoio, em graus.

    Pega a faixa inferior da silhueta e mede as arestas que saem do ponto mais
    baixo (a quina frontal) para a esquerda e para a direita.

    NÃO devolve média, e a razão vale a leitura. A heurística só funciona quando
    a parte de baixo do prop É um quadrilátero apoiado no chão. Num casco de
    barco, numa copa de coqueiro ou numa lança de guindaste não é, e aí ela
    devolve um número com cara de medida que não mede nada — `barco_pequeno` dá
    42,77° e o barco está perfeitamente certo.

    O que separa um caso do outro é as duas arestas CONCORDAREM. `guindaste_base`
    dá 26,57° e 26,57°; o guindaste do lote externo de 31/08 deu 34,86° e 34,43°
    — os dois medíveis, e um deles fora do contrato. O casco de barco dá 4,6° e
    21,2°, e é isso que diz "não me use". Quem decide o veredito é `medir()`.

    Uma última armadilha, medida: a sombra de contato tem azimute próprio (250°)
    e contamina UMA das arestas, puxando-a alguns graus. Subir o limiar de
    opacidade conserta uns props e estraga outros, então não se sobe — a
    discordância que ela causa entra na tolerância de `medir()`.
    """
    ys, _ = np.nonzero(m)
    if ys.size == 0:
        return None
    y1, altura = ys.max(), ys.max() - ys.min()
    faixa = m[y1 - int(altura * 0.16):y1 + 1]
    fy, fx = np.nonzero(faixa)
    desloc = y1 - int(altura * 0.16)
    esq = (fx[np.argmin(fx)], fy[np.argmin(fx)] + desloc)
    dire = (fx[np.argmax(fx)], fy[np.argmax(fx)] + desloc)
    baixo = (fx[np.argmax(fy)], fy[np.argmax(fy)] + desloc)

    def ang(p, q):
        dx, dy = q[0] - p[0], q[1] - p[1]
        return math.degrees(math.atan2(abs(dy), abs(dx))) if dx else 90.0

    return ang(esq, baixo), ang(baixo, dire), float(dire[0] - esq[0])


# Quanto as duas arestas podem discordar e a leitura ainda valer. 4° cobre a
# contaminação da sombra de contato (medida em ~1,5°) e o arredondamento do
# chanfro numa peça pequena, sem deixar passar um casco de barco.
DISCORDANCIA = 4.0

# Apoio estreito demais não mede: dois sapatos de um trabalhador dão 45°/45° —
# as arestas concordam, e mesmo assim o número não quer dizer nada, porque não
# há quadrilátero nenhum ali. Um losango 1x1 do mundo tem 60px de largura, então
# 24px é aproximadamente meia célula: abaixo disso não se opina.
APOIO_MINIMO_PX = 24


def medir(m):
    """`(veredito, esquerda, direita)`.

    veredito: "ok" | "fora" | "indeterminado"
    """
    par = angulo_da_base(m)
    if par is None:
        return "indeterminado", None, None
    e, d, largura = par
    if largura < APOIO_MINIMO_PX:
        return "indeterminado", e, d
    if abs(e - d) > DISCORDANCIA:
        return "indeterminado", e, d
    media = (e + d) / 2
    return ("ok" if abs(media - CONTRATO_GRAUS) <= TOLERANCIA else "fora"), e, d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pasta")
    ap.add_argument("--json")
    args = ap.parse_args()

    raiz = pathlib.Path(args.pasta)
    if not raiz.is_dir():
        sys.exit(f"pasta não encontrada: {raiz}")

    linhas = []
    print(f"{'arquivo':<52} {'tamanho':>11} {'fundo':<15} {'base':>8}")
    print("─" * 92)
    for p in sorted(raiz.rglob("*.png")):
        m, fundo = mascara(p)
        tipo = classificar(p, m)
        veredito, e, d = medir(m) if tipo == "objeto" else ("prancha", None, None)
        a = (e + d) / 2 if veredito in ("ok", "fora") else None
        im = Image.open(p)
        if veredito == "prancha":
            leitura = f"  {tipo}"
        elif veredito == "indeterminado":
            leitura = (f"  arestas {e:5.1f}°/{d:5.1f}° discordam — sem apoio plano"
                       if e is not None else "  vazio")
        else:
            leitura = (f"{a:7.2f}°" +
                       ("  ← fora do contrato" if veredito == "fora" else "  ok"))
        print(f"{p.name:<52} {im.width:>5}x{im.height:<5} {fundo:<15} {leitura}")
        linhas.append({
            "arquivo": str(p.relative_to(raiz)),
            "largura": im.width, "altura": im.height,
            "modo": im.mode, "fundo": fundo,
            "tipo": tipo,
            "veredito": veredito,
            "aresta_esq": round(e, 2) if e is not None else None,
            "aresta_dir": round(d, 2) if d is not None else None,
            "angulo_base": round(a, 2) if a else None,
            "no_contrato": veredito == "ok",
        })

    fora = [x for x in linhas if x["veredito"] == "fora"]
    ok = [x for x in linhas if x["veredito"] == "ok"]
    indet = [x for x in linhas if x["veredito"] == "indeterminado"]
    sem_alfa = [x for x in linhas if x["fundo"] != "alfa"]
    print("─" * 92)
    print(f"{len(linhas)} imagens · {len(sem_alfa)} sem alfa de verdade")
    print(f"ângulo da base contra {CONTRATO_GRAUS:.2f}°: "
          f"{len(ok)} no contrato · {len(fora)} fora · "
          f"{len(indet)} sem apoio plano para medir · "
          f"{len(linhas) - len(ok) - len(fora) - len(indet)} pranchas/folhas")
    if fora:
        print("fora do contrato:")
        for x in fora:
            print(f"  {x['arquivo']}  {x['angulo_base']}°")

    if args.json:
        pathlib.Path(args.json).write_text(
            json.dumps(linhas, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"escrito: {args.json}")


if __name__ == "__main__":
    main()
