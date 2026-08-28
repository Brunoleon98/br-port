#!/usr/bin/env python3
"""
BR Port — preparação de sprites gerados por IA para uso no Godot.

POR QUE ISSO EXISTE
-------------------
Os PNGs entregues pelo gerador de imagens vêm com um problema silencioso: eles
*parecem* ter fundo transparente, mas não têm. O quadriculado cinza-e-branco
que aparece no visualizador está PINTADO na imagem como pixels opacos — o
cabeçalho do PNG diz `RGB`, sem canal alpha.

Se esses arquivos forem jogados direto no Godot, cada sprite aparece dentro de
um retângulo quadriculado. O guia de sprites manda "verificar se o alpha foi
importado corretamente" — não há alpha para importar.

Este script conserta isso:

1. Detecta o fundo quadriculado (pixels claros e dessaturados) que está
   CONECTADO à borda da imagem. Usar componentes conexos a partir da borda é o
   que impede de comer os brancos legítimos de dentro do sprite — a
   superestrutura branca do cargueiro, as faixas refletivas do colete.
2. Come 2px extras na fronteira para remover o halo de antialiasing, que
   sairia como uma franja cinza em volta do sprite.
3. Recorta a moldura vazia e redimensiona para o tamanho de uso no jogo.

USO
---
    python3 tools/preparar_sprites.py ORIGEM DESTINO

ORIGEM  pasta com os PNGs originais (nomes BR_Port_sprite_*.png)
DESTINO pasta onde gravar os PNGs prontos (normalmente brport_vs/art/sprites)
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

# Quanto o pixel pode fugir do cinza puro e ainda contar como fundo.
SATURACAO_MAX = 14
# Quão claro o pixel precisa ser para contar como fundo.
BRILHO_MIN = 214
# Pixels comidos na fronteira, para matar o halo de antialiasing.
EROSAO = 2

# Nome de saída e maior dimensão desejada, em pixels.
# São ~2x o tamanho de exibição, para a arte continuar nítida em telas densas.
ALVOS = {
    "BR_Port_sprite_trabalhador.png": ("trabalhador.png", 256),
    "BR_Port_sprite_cargueiro.png": ("cargueiro.png", 512),
    "BR_Port_sprite_barco_pesca.png": ("barco_pesca.png", 448),
    "BR_Port_sprite_guindaste.png": ("guindaste.png", 320),
    "BR_Port_sprite_caminhao.png": ("caminhao.png", 320),
}


def _e_quadriculado(cinza_do_grupo: np.ndarray, tons: tuple[int, int]) -> bool:
    """
    Decide se um trecho fechado é quadriculado de fundo ou arte legítima.

    O quadriculado é bitonal: alterna dois cinzas fixos e nada mais. Uma área
    branca de verdade — a cabine do cargueiro, as faixas do colete — tem
    sombreado, então espalha valores em vez de se concentrar nos dois tons.
    Exigir os DOIS tons presentes é o que separa um do outro.
    """
    perto_a = np.abs(cinza_do_grupo - tons[0]) <= 5
    perto_b = np.abs(cinza_do_grupo - tons[1]) <= 5
    if (perto_a | perto_b).mean() < 0.85:
        return False
    return min(perto_a.mean(), perto_b.mean()) >= 0.12


def remover_fundo(img: Image.Image) -> Image.Image:
    """Troca o quadriculado pintado por transparência de verdade."""
    rgb = np.asarray(img.convert("RGB")).astype(np.int16)

    saturacao = rgb.max(axis=2) - rgb.min(axis=2)
    brilho = rgb.min(axis=2)
    parece_fundo = (saturacao <= SATURACAO_MAX) & (brilho >= BRILHO_MIN)

    # Só é fundo o que estiver ligado à borda. Um branco cercado por arte —
    # a cabine do navio, o capacete — fica de fora por construção.
    grupos, _ = ndimage.label(parece_fundo)
    da_borda = set(grupos[0, :]) | set(grupos[-1, :]) | set(grupos[:, 0]) | set(grupos[:, -1])
    da_borda.discard(0)

    fundo = np.isin(grupos, list(da_borda))

    # O cordame do barco de pesca e a treliça do guindaste cercam pedaços de
    # quadriculado que não encostam na borda. Sem este passo eles sobram como
    # manchas cinza no meio do sprite.
    cinza = rgb.mean(axis=2)
    if fundo.any():
        hist = np.bincount(np.rint(cinza[fundo]).astype(int).clip(0, 255), minlength=256)
        tons = tuple(int(t) for t in np.argsort(hist)[-2:])

        tamanhos = np.bincount(grupos.ravel())
        caixas = ndimage.find_objects(grupos)
        for rotulo, caixa in enumerate(caixas, start=1):
            if caixa is None or rotulo in da_borda or tamanhos[rotulo] < 40:
                continue
            dentro = grupos[caixa] == rotulo
            if _e_quadriculado(cinza[caixa][dentro], tons):
                fundo[caixa] |= dentro

    if EROSAO > 0:
        fundo = ndimage.binary_dilation(fundo, iterations=EROSAO)

    saida = img.convert("RGBA")
    dados = np.asarray(saida).copy()
    dados[..., 3] = np.where(fundo, 0, 255)
    return Image.fromarray(dados, "RGBA")


def recortar_e_redimensionar(img: Image.Image, maior_lado: int) -> Image.Image:
    caixa = img.getbbox()
    if caixa:
        img = img.crop(caixa)

    escala = maior_lado / max(img.size)
    novo = (max(1, round(img.width * escala)), max(1, round(img.height * escala)))
    return img.resize(novo, Image.LANCZOS)


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2

    origem, destino = Path(sys.argv[1]), Path(sys.argv[2])
    destino.mkdir(parents=True, exist_ok=True)

    faltando = [n for n in ALVOS if not (origem / n).exists()]
    if faltando:
        print("Não encontrei em %s: %s" % (origem, ", ".join(faltando)))
        return 1

    for nome, (nome_saida, maior_lado) in ALVOS.items():
        img = Image.open(origem / nome)
        antes = img.size

        pronto = recortar_e_redimensionar(remover_fundo(img), maior_lado)
        caminho = destino / nome_saida
        pronto.save(caminho, optimize=True)

        opacos = int((np.asarray(pronto)[..., 3] > 0).sum())
        area = pronto.width * pronto.height
        print(
            "%-16s %sx%s -> %sx%s  %3d%% opaco  %4d KB"
            % (
                nome_saida,
                antes[0], antes[1],
                pronto.width, pronto.height,
                round(100 * opacos / area),
                caminho.stat().st_size // 1024,
            )
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
