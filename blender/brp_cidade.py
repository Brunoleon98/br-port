"""BRP — cidade de Porto Mirim. FASE 5 do prompt mestre.

**Aviso de escopo.** A decisão 001 mantém a cidade FORA do vertical slice: ela
está na lista `VS — OUT` do GDD 7, e a vila que o jogo mostra hoje é assada no
SVG do mapa de propósito — ela troca entre FASES, não entre turnos, e o que não
troca dentro de uma partida não precisa ser prop.

Estas duas construções existem para a cena de teste de encaixe, e para provar
duas coisas que o prompt cobra e que nenhum prop atual do jogo prova:

  1. um prédio SELECIONÁVEL, com `COL_select` dimensionado pela base e não pela
     silhueta — o `mercado`;
  2. um prédio NÃO selecionável ao lado dele, para o teste conseguir mostrar
     que tocar num não seleciona o outro — a `casa_costeira`.

Nenhuma das duas entra em `Main.tscn`.
"""

from brp_studio import (caixa, janela, porta, na_face, moldura, cone,
                        telhado_duas_aguas, origem, selecao, z)


def casa_costeira(M, est):
    """Casa térrea de telha de barro — o nível 1 da vila, em prop.

    Mesma implantação que `lotes_da_vila()` desenha no SVG (1,35 x 1,1), para
    que trocar uma pela outra não mexa no enquadramento.
    """
    p = []
    LARG, FUNDO, ALT = 1.35, 1.10, 26.0
    c, t = (0.0, 0.0, z(ALT / 2)), (LARG, FUNDO, z(ALT))
    p.append(caixa("casa_corpo", c, t, M["parede"]))
    p += telhado_duas_aguas("casa_telhado", (0.0, 0.0, z(ALT)),
                            (LARG + 0.12, FUNDO + 0.12, 0), z(13.0),
                            M["telhado"], M["telha_cume"], fiadas=4)
    # Só as faces +x e -y aparecem. Duas janelas e uma porta chegam.
    p += janela("casa_jan_a", "+x", c, t, -0.28, 0.02, 0.34, 0.30, M)
    p += porta("casa_porta", "+x", c, t, 0.30, 0.30, 0.52, M)
    p += janela("casa_jan_b", "-y", c, t, 0.10, 0.02, 0.32, 0.30, M)
    # Soleira: sem ela a porta encosta no chão e a casa parece afundada.
    p.append(caixa("casa_soleira", (LARG / 2 + 0.06, 0.30, z(1.2)),
                   (0.22, 0.42, z(2.4)), M["parede_dir"]))
    origem("casa_costeira")
    est.registrar("casa_costeira", p, celulas=(2, 2), selecionavel=False)


def mercado(M, est):
    """Mercado — construção SELECIONÁVEL, com toldo e balcão.

    O toldo é o que separa comércio de casa a 60px de distância: é a única
    peça que sai da caixa e projeta uma listra de cor no passeio.
    """
    p = []
    LARG, FUNDO, ALT = 1.7, 1.25, 34.0
    c, t = (0.0, 0.0, z(ALT / 2)), (LARG, FUNDO, z(ALT))
    p.append(caixa("merc_corpo", c, t, M["parede_dir"]))
    p.append(caixa("merc_platibanda", (0.0, 0.0, z(ALT + 3.0)),
                   (LARG + 0.10, FUNDO + 0.10, z(6.0)), M["parede"]))
    p.append(caixa("merc_laje", (0.0, 0.0, z(ALT + 0.6)),
                   (LARG, FUNDO, z(1.2)), M["parede_suja"]))

    # Vitrine na face +x, larga e baixa.
    p += moldura("merc_vitrine", "+x", c, t, -0.14, -0.06, 0.62, 0.34, 0.05,
                 M["parede"], 0.01)
    p.append(na_face("merc_vidro", "+x", c, t, -0.14, -0.06, 0.58, 0.30,
                     0.03, M["vidro"], -0.02))
    p += porta("merc_porta", "+x", c, t, 0.40, 0.28, 0.50, M)

    # Toldo listrado: três faixas alternadas, inclinadas para fora.
    for i in range(3):
        p.append(caixa("merc_toldo%d" % i,
                       (LARG / 2 + 0.16, -0.34 + i * 0.34, z(ALT * 0.72)),
                       (0.36, 0.32, z(1.4)),
                       M["laranja"] if i % 2 == 0 else M["cabine"],
                       rot=(0, -16, 0)))
    p.append(caixa("merc_balcao", (LARG / 2 + 0.20, -0.02, z(6.0)),
                   (0.30, 0.80, z(12.0)), M["madeira"]))
    for i, y in enumerate((-0.30, 0.26)):
        p.append(cone("merc_caixa%d" % i, (LARG / 2 + 0.20, y, z(14.0)),
                      0.10, 0.10, z(4.0), 10, M["folha"]))

    origem("mercado")
    # Base, não silhueta: o toldo avança 0,34 e a colisão NÃO o acompanha,
    # senão tocar no passeio à frente da loja passa a selecioná-la.
    selecao("mercado", 0.0, 0.0, LARG, FUNDO)
    est.registrar("mercado", p, celulas=(2, 2), selecionavel=True,
                  cena_godot="res://scenes/city/Mercado.tscn")


CATALOGO = (casa_costeira, mercado)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
