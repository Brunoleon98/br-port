"""BRP — o estúdio compartilhado. FASE 2 do prompt mestre do pacote de arte.

O prompt pede quatro `.blend` de estúdio com "câmera, escala e iluminação
compartilhadas". Metade disso já existia: `tools/gerar_props_iso.py` monta a
câmera no contrato, o rig de três pontos, a paleta, o kit de detalhe e a sombra
de contato, e ainda confere a própria projeção no fim.

Então este módulo NÃO refaz nada disso — ele importa de lá. A auditoria do
pacote nomeia como risco nº 1 o Claude criar uma arquitetura idealizada ao lado
do protótipo real, e como risco nº 2 duplicar a animação que já existe. Uma
segunda câmera "quase igual" seria as duas coisas ao mesmo tempo, e a
divergência só apareceria quando um prop novo caísse 40px fora do chão.

O que este módulo acrescenta é o que o pacote traz de novo e o projeto não
tinha: `ORIGIN_anchor` explícito, convenção de nome, coleção `EXPORT`, manifest
de exportação e gravação do `.blend`.

Uso a partir de um catálogo:

    from brp_studio import Estudio
    est = Estudio("porto")
    est.montar(catalogo)          # catalogo(M, est) -> {nome: [objetos]}
    est.exportar("brport_vs/art/props")
"""

from __future__ import annotations

import json
import math
import os
import pathlib
import sys

# O gerador vive em tools/, na raiz do repositório. Ele é a fonte da projeção e
# do kit — importar é o que impede este arquivo de virar uma segunda verdade.
_RAIZ = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_RAIZ / "tools"))

import bpy                                        # noqa: E402
import gerar_props_iso as base                    # noqa: E402

# Reexportados para os catálogos não precisarem saber de onde vieram.
MEIA_LARG, MEIA_ALT = base.MEIA_LARG, base.MEIA_ALT
ROT_X, ROT_Z = base.ROT_X, base.ROT_Z
RESOLUCAO = base.RESOLUCAO
z, pos = base.z, base.pos
caixa, cone, prisma, barra, trelica = (
    base.caixa, base.cone, base.prisma, base.barra, base.trelica)
na_face, moldura, janela, porta = (
    base.na_face, base.moldura, base.janela, base.porta)
telhado_duas_aguas, corrimao, escotilhas, poste_de_luz = (
    base.telhado_duas_aguas, base.corrimao, base.escotilhas, base.poste_de_luz)
material, material_gasto, paleta_completa = (
    base.material, base.material_gasto, base.paleta_completa)
para_pixel = base.para_pixel


# ────────────────────────────────────────────────────────────── ancoragem
def origem(nome: str, mx: float = 0.0, my: float = 0.0,
           altura_px: float = 0.0, tipo: str = "base"):
    """Cria o `ORIGIN_anchor` de um asset, no ponto de CONTATO.

    O pacote exige que todo asset declare onde encosta, e a razão é a queixa
    que abre a auditoria: "objetos retangulares de carga que parecem flutuar
    porque não têm um ponto de contato com a rua ou com a doca".

    O `tipo` não é decoração — ele diz o que a validação deve cobrar:

        base       encosta no chão. A âncora tem de ficar no fundo da malha.
        waterline  flutua. A âncora fica na linha de água, não na quilha, e a
                   malha PODE descer abaixo dela.
        voo        ave no ar. Não se cobra apoio nenhum.
        encaixe    peça que monta noutra (copa de coqueiro, lança de guindaste):
                   a âncora é o ponto de encaixe na peça-mãe.
        retrato    NÃO pousa em lado nenhum: vive num cartão de interface. Não
                   se cobra apoio, e sobretudo não se compõe a sombra de
                   contacto — num cartão não há chão para ela cair, e o que
                   sai é um risco diagonal atrás do boneco.
    """
    if tipo not in ("base", "waterline", "voo", "encaixe", "retrato"):
        raise ValueError("tipo de âncora desconhecido: %s" % tipo)
    e = bpy.data.objects.new("ORIGIN_%s" % nome, None)
    e.empty_display_type = "PLAIN_AXES"
    e.empty_display_size = 0.35
    e.location = pos(mx, my, altura_px)
    e["brp_ancora"] = tipo
    bpy.context.scene.collection.objects.link(e)
    return e


def selecao(nome: str, mx: float, my: float, largura: float, fundo: float,
            altura_px: float = 0.0):
    """Cria o `COL_select` — o volume de toque, separado da malha visual.

    Dimensionado pela BASE e não pela silhueta, de propósito. Uma colisão do
    tamanho da silhueta de um guindaste cobre metade do cais e rouba o toque do
    prédio ao lado; a regra sai da própria lista de revisão visual do pacote,
    que manda procurar "colisões maiores que o prédio".
    """
    e = bpy.data.objects.new("COL_select_%s" % nome, None)
    e.empty_display_type = "CUBE"
    e.empty_display_size = 0.5
    e.location = pos(mx, my, altura_px)
    e.scale = (largura, fundo, 0.2)
    e["brp_selecao"] = True
    bpy.context.scene.collection.objects.link(e)
    return e


def brp_nome(categoria: str, nome: str, variante: str = "base") -> str:
    """`BRP_<categoria>_<nome>_<variante>`, como o prompt manda."""
    return "BRP_%s_%s_%s" % (categoria, nome, variante)


# ────────────────────────────────────────────────────────────── o estúdio
class Estudio:
    """Uma cena de estúdio, com o catálogo montado dentro dela.

    Um estúdio = um `.blend` = uma categoria do prompt (terreno, porto, cidade,
    fauna). Todos partilham `preparar_cena()`, portanto partilham câmera,
    `ortho_scale`, rig de luz e resolução — que é a exigência que o guia do
    pacote faz e não consegue garantir sozinho, porque ele fixa o Z da câmera e
    esquece o X.
    """

    def __init__(self, categoria: str):
        self.categoria = categoria
        self.cena = base.preparar_cena()
        self.M = paleta_completa()
        self.grupos: dict[str, list] = {}
        self.fichas: dict[str, dict] = {}
        self.exportacao = bpy.data.collections.new("EXPORT")
        self.cena.collection.children.link(self.exportacao)

    # -- montagem ---------------------------------------------------------
    def registrar(self, nome: str, objetos: list, *, estagio: str = "base",
                  ancora: str = "base", selecionavel: bool = False,
                  celulas: tuple = (1, 1), animacoes: dict | None = None,
                  habitat: str = "terra", cena_godot: str = "") -> None:
        """Põe um asset no catálogo, com a ficha que vai para o manifest."""
        self.grupos[nome] = objetos
        self.fichas[nome] = {
            "id": brp_nome(self.categoria, nome, estagio),
            "category": self.categoria,
            "stage": estagio,
            "file": "%s.png" % nome,
            "format": "png-rgba",
            "frame_size": [RESOLUCAO, RESOLUCAO],
            "columns": 1, "rows": 1, "fps": 0,
            "animations": animacoes or {},
            "origin": ancora,
            "base_cells": list(celulas),
            "selectable": selecionavel,
            "habitat": habitat,
            "godot_scene": cena_godot,
        }
        for o in objetos:
            if o.name not in self.exportacao.objects:
                self.exportacao.objects.link(o)

    def montar(self, catalogo) -> None:
        """`catalogo(M, est)` devolve `{nome: [objetos]}` e chama `registrar`."""
        catalogo(self.M, self)
        # Chanfro por último, como no gerador: as funções de peça continuam
        # falando de caixas, e quem as reaproveitar não herda o modificador.
        base.chanfrar({o for g in self.grupos.values() for o in g
                       if o.type == "MESH"})

    # -- saída ------------------------------------------------------------
    def salvar_blend(self, caminho: str) -> None:
        os.makedirs(os.path.dirname(caminho), exist_ok=True)
        bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(caminho))

    def exportar(self, saida: str, apenas: list | None = None) -> dict:
        """Renderiza cada grupo isolado, com alfa de verdade.

        `film_transparent` já vem ligado de `preparar_cena()`. Isto importa: os
        dois lotes de arte que chegaram de fora vieram com o xadrez de
        transparência PINTADO nos pixels, e é o defeito que
        `tools/preparar_sprites.py` existe para consertar. Aqui não há o que
        consertar, porque o alfa nasce certo.
        """
        os.makedirs(saida, exist_ok=True)
        alvos = apenas or list(self.grupos)
        desconhecidos = [a for a in alvos if a not in self.grupos]
        if desconhecidos:
            raise SystemExit("asset desconhecido: %s\ndisponíveis: %s"
                             % (", ".join(desconhecidos),
                                ", ".join(sorted(self.grupos))))

        todos = {o for g in self.grupos.values() for o in g}
        feitos = {}
        for nome in alvos:
            for o in todos:
                o.hide_render = True
            for o in self.grupos[nome]:
                o.hide_render = False
            alvo = os.path.join(saida, "%s.png" % nome)
            self.cena.render.filepath = alvo
            bpy.ops.render.render(write_still=True)

            ficha = dict(self.fichas[nome])
            if ficha["origin"] == "base":
                temp = os.path.join(saida, "_sombra_tmp.png")
                base.render_sombra(self.cena, self.grupos[nome], temp)
                base.compor_sombra(alvo, temp)
                os.remove(temp)
                ficha["sombra_de_contato"] = True
                print("  %s  (+ sombra)" % nome)
            else:
                ficha["sombra_de_contato"] = False
                print("  %s" % nome)
            feitos[nome] = ficha
        return feitos


# ────────────────────────────────────────────────────────────── manifest
def escrever_manifest(caminho: str, entradas: dict) -> None:
    """Junta ao manifest em vez de sobrescrever.

    Cada estúdio roda sozinho — são quatro processos, um por categoria, porque
    `preparar_cena()` limpa a cena inteira. Se cada um sobrescrevesse o
    manifest, o último a rodar apagaria os três anteriores.
    """
    antigo = {}
    p = pathlib.Path(caminho)
    if p.exists():
        antigo = {e["file"]: e for e in json.loads(p.read_text("utf-8"))["assets"]}
    for ficha in entradas.values():
        antigo[ficha["file"]] = ficha
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(
        {"contrato": {
            "meia_larg": MEIA_LARG, "meia_alt": MEIA_ALT,
            "rot_x": ROT_X, "rot_z": ROT_Z,
            "angulo_aresta": round(math.degrees(math.atan(MEIA_ALT / MEIA_LARG)), 3),
            "quadro": [RESOLUCAO, RESOLUCAO],
            "altura_px_por_unidade": round(base.ALTURA_PX, 2),
            "doc": "docs/BRP_SPATIAL_CONTRACT.md"},
         "assets": sorted(antigo.values(), key=lambda e: e["file"])},
        ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("manifest: %s (%d assets)" % (caminho, len(antigo)))
