"""BRP — terreno e água. FASE 3 do prompt mestre.

**Aviso de escopo, e é importante.** O chão do BR Port não é feito de tiles: é
um SVG inteiro, gerado por `tools/gerar_mapa_iso.py`, com a costa em degraus, o
enrocamento, a malha viária e os números de doca em estêncil. Ele funciona, o
`teste_design.gd` verifica-o, e o guia de mapa da Parte 04 do pacote pede
exatamente as peças que esse SVG já desenha — porque foi escrito contra um
estado do projeto anterior a elas.

Então estes tiles NÃO substituem o mapa. Eles existem para a cena de teste de
encaixe (FASE 11) ter chão próprio, sem depender do mapa do jogo, que é o que
permite pôr um asset em três posições diferentes e ver se a origem aguenta —
o critério de aprovação que o prompt define.

Cada tile é uma laje de 2x2 células, plana, sem sombra de contato: chão não
projeta sombra em si mesmo, e a sombra de contato aqui só criaria uma emenda
escura em cada junta.
"""

from brp_studio import caixa, cone, origem, z

LADO = 2.0          # 2x2 células = 120x60 px na tela
ESP = 1.2           # espessura em pixels do mapa: quase nada, só para a laje
                    # não ser um plano de espessura zero (que o Cycles às vezes
                    # renderiza com o avesso virado para a câmera)


def _laje(nome, mat, altura_px=0.0):
    return caixa(nome, (0.0, 0.0, z(altura_px - ESP / 2)),
                 (LADO, LADO, z(ESP)), mat)


def terreno_areia(M, est):
    p = [_laje("areia_laje", M["corda"])]
    # Seixos esparsos. Sem eles a areia é um losango chapado e o olho não
    # encontra escala nenhuma nela.
    for i, (x, y, r) in enumerate(((-0.6, 0.3, 0.05), (0.35, -0.5, 0.04),
                                   (0.1, 0.55, 0.035), (-0.25, -0.7, 0.045),
                                   (0.7, 0.15, 0.03))):
        p.append(cone("areia_seixo%d" % i, (x, y, z(0.4)), r, r * 0.7,
                      z(1.6), 8, M["madeira_velha"]))
    origem("terreno_areia", tipo="encaixe")
    est.registrar("terreno_areia", p, ancora="encaixe", celulas=(2, 2))


def terreno_rua(M, est):
    p = [_laje("rua_laje", M["parede_suja"])]
    # Faixa tracejada no eixo, na diagonal do mundo — a rua do mapa corre
    # paralela ao cais, que em coordenadas de mundo é o eixo my.
    for i in range(4):
        p.append(caixa("rua_faixa%d" % i, (0.0, -0.75 + i * 0.5, z(0.3)),
                       (0.06, 0.26, z(1.0)), M["cabine"]))
    p.append(caixa("rua_meiofio_a", (LADO / 2 - 0.05, 0.0, z(1.6)),
                   (0.10, LADO, z(3.2)), M["parede_dir"]))
    p.append(caixa("rua_meiofio_b", (-LADO / 2 + 0.05, 0.0, z(1.6)),
                   (0.10, LADO, z(3.2)), M["parede_dir"]))
    origem("terreno_rua", tipo="encaixe")
    est.registrar("terreno_rua", p, ancora="encaixe", celulas=(2, 2))


def terreno_agua(M, est):
    """Água. Duas lajes quase à mesma altura, a de cima menor e mais clara.

    É o truque mais barato que dá profundidade sem shader: a borda da laje de
    cima lê como a crista de uma onda larga. O guia de terrenos do pacote pede
    "profundidade visual, ondas direcionais e espuma só em costa, rocha e
    doca" — a espuma fica no tile de costa, que é onde ela existe de verdade.
    """
    p = [_laje("agua_funda", M["casco"]),
         caixa("agua_rasa", (0.1, -0.1, z(0.3)), (LADO * 0.8, LADO * 0.8,
                                                  z(1.0)), M["azul"])]
    origem("terreno_agua", tipo="encaixe")
    est.registrar("terreno_agua", p, ancora="encaixe", celulas=(2, 2),
                  habitat="agua")


def terreno_costa(M, est):
    """Transição areia -> água, com espuma na linha de encontro."""
    p = [_laje("costa_agua", M["azul"])]
    p.append(caixa("costa_areia", (0.0, LADO / 4, z(0.2)),
                   (LADO, LADO / 2, z(1.4)), M["corda"]))
    # Espuma: uma fita clara e estreita exatamente na junta.
    p.append(caixa("costa_espuma", (0.0, 0.0, z(0.9)),
                   (LADO, 0.13, z(1.0)), M["cabine"]))
    for i, x in enumerate((-0.62, -0.1, 0.44)):
        p.append(cone("costa_pedra%d" % i, (x, 0.06, z(1.2)), 0.09, 0.06,
                      z(4.0), 8, M["madeira_velha"]))
    origem("terreno_costa", tipo="encaixe")
    est.registrar("terreno_costa", p, ancora="encaixe", celulas=(2, 2))


CATALOGO = (terreno_areia, terreno_rua, terreno_agua, terreno_costa)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
