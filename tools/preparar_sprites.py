#!/usr/bin/env python3
"""
BR Port — preparação de sprites gerados por IA para uso no Godot.

POR QUE ISSO EXISTE
-------------------
Gerador de imagem não entrega transparência de verdade. Pedir "fundo
transparente" faz o modelo DESENHAR um quadriculado cinza-e-branco — pixels
opacos que só imitam o xadrez do Photoshop. O PNG sai como `RGB`, sem alpha, e
no Godot cada sprite aparece dentro de um retângulo quadriculado.

Este script recebe os PNGs crus e devolve PNGs com alpha de verdade,
recortados e no tamanho de uso.

DOIS MODOS, DETECTADOS SOZINHO
------------------------------
* **Fundo sólido** (recomendado — ver docs/BLOCO4_GUIA_GERACAO_ASSETS.md):
  peça ao gerador um fundo chapado de magenta `#FF00FF`. É o caminho limpo,
  porque magenta não aparece em nada portuário e o recorte fica exato.

* **Quadriculado pintado** (o que veio na primeira leva): tratado por
  componentes conexos a partir da borda, o que preserva os brancos legítimos
  de dentro do sprite — a cabine do cargueiro, as faixas do colete. Buracos
  fechados (cordame, treliça) são pegos por serem bitonais.

USO
---
    python3 tools/preparar_sprites.py ORIGEM DESTINO [--lado N]

ORIGEM   pasta com os PNGs crus
DESTINO  onde gravar os prontos (normalmente brport_vs/art/sprites)
--lado   maior dimensão de saída para arquivos não listados em ALVOS
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

# --- fundo quadriculado ---
SATURACAO_MAX = 14      # quanto o pixel pode fugir do cinza e ainda ser fundo
BRILHO_MIN = 214        # quão claro precisa ser
# --- fundo sólido ---
TOL_CHROMA = 60         # distância de cor aceita como "é o fundo"
UNIFORMIDADE_MIN = 0.90 # fração da borda que precisa bater para ser sólido
# --- comum ---
EROSAO = 2              # pixels comidos na fronteira, mata o halo/franja
LADO_PADRAO = 512

# Maior dimensão de saída, por arquivo conhecido. ~2x o tamanho de exibição,
# para a arte não borrar em tela densa.
ALVOS = {
    "trabalhador.png": 256,
    "cargueiro.png": 512,
    "barco_pesca.png": 448,
    "guindaste.png": 320,
    "caminhao.png": 320,
}

# Compatibilidade com os nomes crus da primeira leva.
RENOMEAR = {
    "BR_Port_sprite_trabalhador.png": "trabalhador.png",
    "BR_Port_sprite_cargueiro.png": "cargueiro.png",
    "BR_Port_sprite_barco_pesca.png": "barco_pesca.png",
    "BR_Port_sprite_guindaste.png": "guindaste.png",
    "BR_Port_sprite_caminhao.png": "caminhao.png",
}


def _anel_da_borda(rgb: np.ndarray, espessura: int = 4) -> np.ndarray:
    return np.concatenate([
        rgb[:espessura].reshape(-1, 3), rgb[-espessura:].reshape(-1, 3),
        rgb[:, :espessura].reshape(-1, 3), rgb[:, -espessura:].reshape(-1, 3),
    ])


def _modo_do_fundo(rgb: np.ndarray):
    """
    Decide qual dos dois fundos é este, olhando o anel da borda.

    A ordem importa: o quadriculado é testado PRIMEIRO. Os dois cinzas dele
    (~253 e ~238) ficam a ~13 de distância da própria mediana, ou seja, dentro
    de qualquer tolerância de cor razoável — testar "é uniforme?" antes
    classificaria quadriculado como fundo sólido, e aí a limpeza dos buracos
    fechados (cordame, treliça) nunca rodaria.
    """
    anel = _anel_da_borda(rgb)

    saturacao = anel.max(axis=1) - anel.min(axis=1)
    cinza_e_claro = (saturacao <= SATURACAO_MAX) & (anel.min(axis=1) >= BRILHO_MIN)
    if cinza_e_claro.mean() >= 0.90:
        cinza = anel.mean(axis=1)
        hist = np.bincount(np.rint(cinza).astype(int).clip(0, 255), minlength=256)
        tons = tuple(int(t) for t in np.argsort(hist)[-2:])
        if abs(tons[0] - tons[1]) >= 6 and _e_quadriculado(cinza, tons):
            return "quadriculado", None

    cor = np.median(anel, axis=0)
    perto = np.linalg.norm(anel - cor, axis=1) <= TOL_CHROMA
    if perto.mean() >= UNIFORMIDADE_MIN:
        return "sólido", cor

    return "quadriculado", None


def _e_quadriculado(cinza_do_grupo: np.ndarray, tons: tuple) -> bool:
    """
    Separa quadriculado de fundo de arte branca legítima.

    O quadriculado é bitonal: alterna dois cinzas fixos e nada mais. Área
    branca de verdade tem sombreado, então espalha valores. Exigir os DOIS
    tons presentes é o que distingue um do outro.
    """
    perto_a = np.abs(cinza_do_grupo - tons[0]) <= 5
    perto_b = np.abs(cinza_do_grupo - tons[1]) <= 5
    if (perto_a | perto_b).mean() < 0.85:
        return False
    return min(perto_a.mean(), perto_b.mean()) >= 0.12


def _so_o_que_encosta_na_borda(candidato: np.ndarray):
    grupos, _ = ndimage.label(candidato)
    da_borda = set(grupos[0, :]) | set(grupos[-1, :]) | set(grupos[:, 0]) | set(grupos[:, -1])
    da_borda.discard(0)
    return np.isin(grupos, list(da_borda)), grupos, da_borda


def remover_fundo(img: Image.Image):
    """Devolve (imagem RGBA, nome do modo usado)."""
    rgb = np.asarray(img.convert("RGB")).astype(np.int16)
    modo, cor_solida = _modo_do_fundo(rgb)

    if modo == "sólido":
        candidato = np.linalg.norm(rgb - cor_solida, axis=2) <= TOL_CHROMA
        fundo, _, _ = _so_o_que_encosta_na_borda(candidato)
    else:
        saturacao = rgb.max(axis=2) - rgb.min(axis=2)
        candidato = (saturacao <= SATURACAO_MAX) & (rgb.min(axis=2) >= BRILHO_MIN)
        fundo, grupos, da_borda = _so_o_que_encosta_na_borda(candidato)
        modo = "quadriculado"

        # Cordame e treliça cercam quadriculado que não encosta na borda.
        cinza = rgb.mean(axis=2)
        if fundo.any():
            hist = np.bincount(np.rint(cinza[fundo]).astype(int).clip(0, 255), minlength=256)
            tons = tuple(int(t) for t in np.argsort(hist)[-2:])
            tamanhos = np.bincount(grupos.ravel())
            for rotulo, caixa in enumerate(ndimage.find_objects(grupos), start=1):
                if caixa is None or rotulo in da_borda or tamanhos[rotulo] < 40:
                    continue
                dentro = grupos[caixa] == rotulo
                if _e_quadriculado(cinza[caixa][dentro], tons):
                    fundo[caixa] |= dentro

    if EROSAO > 0:
        fundo = ndimage.binary_dilation(fundo, iterations=EROSAO)

    dados = np.asarray(img.convert("RGBA")).copy()
    dados[..., 3] = np.where(fundo, 0, 255)
    return Image.fromarray(dados, "RGBA"), modo


def recortar_e_redimensionar(img: Image.Image, maior_lado: int) -> Image.Image:
    caixa = img.getbbox()
    if caixa:
        img = img.crop(caixa)
    escala = maior_lado / max(img.size)
    novo = (max(1, round(img.width * escala)), max(1, round(img.height * escala)))
    return img.resize(novo, Image.LANCZOS)


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    lado_padrao = LADO_PADRAO
    for a in sys.argv[1:]:
        if a.startswith("--lado"):
            lado_padrao = int(a.split("=", 1)[1] if "=" in a else a[6:])

    if len(args) != 2:
        print(__doc__)
        return 2

    origem, destino = Path(args[0]), Path(args[1])
    entradas = sorted(origem.glob("*.png"))
    if not entradas:
        print("Nenhum PNG em %s" % origem)
        return 1
    destino.mkdir(parents=True, exist_ok=True)

    for caminho_entrada in entradas:
        nome_saida = RENOMEAR.get(caminho_entrada.name, caminho_entrada.name)
        maior_lado = ALVOS.get(nome_saida, lado_padrao)

        img = Image.open(caminho_entrada)
        antes = img.size
        sem_fundo, modo = remover_fundo(img)
        pronto = recortar_e_redimensionar(sem_fundo, maior_lado)

        caminho = destino / nome_saida
        pronto.save(caminho, optimize=True)

        opacos = int((np.asarray(pronto)[..., 3] > 0).sum())
        print(
            "%-18s %sx%s -> %sx%s  fundo %-12s %3d%% opaco  %4d KB"
            % (
                nome_saida, antes[0], antes[1], pronto.width, pronto.height,
                modo, round(100 * opacos / (pronto.width * pronto.height)),
                caminho.stat().st_size // 1024,
            )
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
