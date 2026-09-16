"""BRP — fauna e vegetação. FASES 6 e parte da 7 do prompt mestre.

O segundo playtest reabriu uma parte limitada da fauna que a decisão 001 tinha
deixado fora do vertical slice. O catálogo jogável cobre agora o ar, a praia,
o baixio e três nichos terrestres visíveis, todos plausíveis no litoral
brasileiro:

    gaivota (gaivotão)          âncora `voo`       — ar
    maria_farinha               âncora `base`      — areia seca
    tartaruga_verde             âncora `waterline` — baixio
    cachorro_caramelo           âncora `base`      — vila
    quero_quero                  âncora `base`      — campo aberto
    capivara                     âncora `base`      — mata + gramado + água

Coqueiro jovem e arbusto continuam aqui como provas de vegetação/ancoragem; a
mudança não puxa as outras espécies previstas no pacote grande.

**A gaivota anterior ocupava só cerca de 20 px do quadro e lia como planador.**
A quarta versão troca caixas por prismas de silhueta: asa dobrada, cauda
bifurcada e ponta escura fazem o desenho antes de qualquer detalhe. Ela também
ganha escala de jogo — o quadro continua o mesmo, mas a ave deixa de ser um
punhado de pixels no meio dele. É a aplicação prática do diagnóstico antigo:
resolver a ave no desenho visto de cima, e não empilhar mais primitivas.
"""

from brp_studio import caixa, cone, prisma, barra, origem, selecao, z


# Medido no render de 13/09 contra duas réguas do próprio jogo: o trabalhador
# ocupa 15 px de largura e o bote de pesca, 44. A fauna miúda continua na régua
# de 11–15 px; a capivara pode passar da pessoa em comprimento, mas fica muito
# abaixo do bote. Escala-se o GRUPO inteiro a partir da origem, nunca as
# literais internas — é a regra de todo prop deste estúdio.
ESCALA_DE_JOGO = {
    # O alfa antisserrilhado acrescenta um pixel à caixa; estes fatores são
    # os que o render mediu nos alvos 15 / 14 / 12, não uma regra de três
    # suposta a partir da caixa antiga.
    "gaivota": 0.290,
    "tartaruga_verde": 0.278,
    "maria_farinha": 0.252,
    "cachorro_caramelo": 0.350,
    "quero_quero": 0.445,
    "capivara": 0.350,
}


def _escalar_grupo(objetos, fator: float):
    """Reduz malha e posição em torno da origem, uma vez por objeto."""
    for objeto in set(objetos):
        objeto.location *= fator
        objeto.scale *= fator
    return objetos


def gaivota(M, est):
    """Gaivotão em voo, resolvido como silhueta vista de cima.

    Âncora de VOO: o pacote é explícito — "uma ave voando usa uma origem no
    centro do corpo e não uma origem no chão". Sem essa distinção a validação
    cobraria apoio de uma ave e o pipeline pararia num falso erro.
    """
    p = []
    corpo = [(0.82, 0.0), (0.46, 0.18), (-0.24, 0.15),
             (-0.58, 0.34), (-0.48, 0.03), (-0.62, -0.34),
             (-0.24, -0.15), (0.46, -0.18)]
    p.append(prisma("gav_corpo", corpo, z(0.0), z(3.0), (0.92, 0.92),
                    M["cabine"]))
    # Asa em joelho: a ponta vem para trás do corpo e quebra o triângulo de
    # avião de papel. Cada lado é um prisma único, uma forma lida de relance.
    for i, lado in enumerate((1, -1)):
        asa = [(0.30, lado * 0.10), (0.06, lado * 0.24),
               (-0.24, lado * 1.12), (-0.02, lado * 1.02),
               (0.42, lado * 0.34)]
        ponta = [(-0.24, lado * 1.12), (-0.02, lado * 1.02),
                 (0.13, lado * 0.72), (-0.11, lado * 0.79)]
        p.append(prisma("gav_asa%d" % i, asa, z(1.0), z(4.0),
                        (0.96, 0.96), M["cabine"]))
        p.append(prisma("gav_ponta%d" % i, ponta, z(4.1), z(5.0),
                        (0.98, 0.98), M["metal"]))
    p.append(prisma("gav_dorso", [(0.53, 0.0), (0.08, 0.09),
                                   (-0.30, 0.0), (0.08, -0.09)],
                    z(3.1), z(5.0), (0.95, 0.95), M["metal_claro"]))
    p.append(prisma("gav_bico", [(0.98, 0.0), (0.76, 0.075),
                                  (0.76, -0.075)],
                    z(0.7), z(2.2), (0.92, 0.92), M["amarelo"]))
    origem("gaivota", tipo="voo")
    volume = selecao("gaivota", 0.0, 0.0, 1.0, 1.0)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["gaivota"])
    est.registrar("gaivota", p, ancora="voo", selecionavel=True,
                  celulas=(1, 1), habitat="ar",
                  animacoes={"voo": {"frames": 6, "loop": True},
                             "toque": {"frames": 4, "loop": False}},
                  cena_godot="res://scenes/fauna/Gaivota.tscn")


def maria_farinha(M, est):
    """Maria-farinha: caranguejo claro, largo e rente à areia."""
    p = []
    corpo = cone("mf_corpo", (0.0, 0.0, z(2.0)), 0.40, 0.32,
                 z(4.0), 10, M["corda"])
    corpo.scale.y = 0.72
    p.append(corpo)
    # Quatro pernas por lado em leque. O vazio entre elas é mais importante
    # que a espessura: sem recorte o animal vira apenas uma pedra bege.
    for lado in (1, -1):
        for i, x in enumerate((-0.25, -0.08, 0.10, 0.25)):
            y0 = lado * (0.20 + i * 0.02)
            y1 = lado * (0.52 + i * 0.055)
            p.append(barra("mf_perna_%d_%d" % (lado, i),
                           (x, y0, z(1.6)), (x - 0.10, y1, z(0.8)),
                           0.035, M["laranja"]))
        # Pinça aberta, duas peças que deixam uma fenda legível.
        p.append(barra("mf_pinca_a%d" % lado, (0.24, lado * 0.25, z(2.2)),
                       (0.52, lado * 0.53, z(2.2)), 0.055, M["laranja"]))
        p.append(barra("mf_pinca_b%d" % lado, (0.52, lado * 0.53, z(2.2)),
                       (0.70, lado * 0.42, z(2.2)), 0.045, M["laranja"]))
    origem("maria_farinha")
    volume = selecao("maria_farinha", 0.0, 0.0, 1.0, 1.0)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["maria_farinha"])
    est.registrar("maria_farinha", p, selecionavel=True, celulas=(1, 1),
                  habitat="areia",
                  animacoes={"andar_lado": {"frames": 6, "loop": True},
                             "toca": {"frames": 5, "loop": False}},
                  cena_godot="res://scenes/fauna/MariaFarinha.tscn")


def tartaruga_verde(M, est):
    """Tartaruga-verde juvenil vista de cima, na linha de água."""
    p = []
    casco = cone("tv_casco", (0.0, 0.0, z(3.0)), 0.52, 0.40,
                 z(6.0), 12, M["casco_pesca"])
    casco.scale.y = 0.68
    p.append(casco)
    topo = cone("tv_placa", (-0.04, 0.0, z(6.4)), 0.35, 0.28,
                z(1.3), 10, M["folha_clara"])
    topo.scale.y = 0.66
    p.append(topo)
    cabeca = cone("tv_cabeca", (0.58, 0.0, z(2.6)), 0.18, 0.14,
                  z(3.8), 10, M["folha"])
    cabeca.scale.y = 0.78
    p.append(cabeca)
    for i, lado in enumerate((1, -1)):
        frente = [(0.34, lado * 0.18), (0.13, lado * 0.34),
                  (0.42, lado * 0.72), (0.64, lado * 0.60)]
        tras = [(-0.32, lado * 0.16), (-0.48, lado * 0.25),
                (-0.64, lado * 0.48), (-0.35, lado * 0.42)]
        p.append(prisma("tv_nadadeira_f%d" % i, frente, z(1.0), z(3.4),
                        (0.94, 0.94), M["folha"]))
        p.append(prisma("tv_nadadeira_t%d" % i, tras, z(0.8), z(2.8),
                        (0.94, 0.94), M["folha"]))
    origem("tartaruga_verde", tipo="waterline")
    volume = selecao("tartaruga_verde", 0.0, 0.0, 1.0, 1.0)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["tartaruga_verde"])
    est.registrar("tartaruga_verde", p, ancora="waterline", selecionavel=True,
                  celulas=(1, 1), habitat="agua_rasa",
                  animacoes={"nado": {"frames": 6, "loop": True},
                             "mergulho": {"frames": 5, "loop": False}},
                  cena_godot="res://scenes/fauna/TartarugaVerde.tscn")


def cachorro_caramelo(M, est):
    """Cão semidomiciliado da vila: corpo baixo, orelhas e focinho escuros."""
    p = []
    corpo = cone("cc_corpo", (-0.06, 0.0, z(2.7)), 0.46, 0.34,
                 z(5.2), 10, M["laranja"])
    corpo.scale.x = 1.28
    corpo.scale.y = 0.58
    p.append(corpo)
    peito = cone("cc_peito", (0.32, 0.0, z(2.9)), 0.29, 0.24,
                 z(5.6), 9, M["corda"])
    peito.scale.y = 0.62
    p.append(peito)
    cabeca = cone("cc_cabeca", (0.56, 0.0, z(5.1)), 0.24, 0.18,
                  z(4.0), 9, M["laranja"])
    cabeca.scale.y = 0.72
    p.append(cabeca)
    p.append(cone("cc_focinho", (0.78, 0.0, z(4.6)), 0.12, 0.085,
                  z(2.3), 8, M["madeira_esc"]))
    for i, lado in enumerate((1, -1)):
        orelha = [(0.49, lado * 0.11), (0.38, lado * 0.20),
                  (0.59, lado * 0.18)]
        p.append(prisma("cc_orelha%d" % i, orelha, z(6.6), z(8.2),
                        (0.96, 0.96), M["madeira_esc"]))
        for j, x in enumerate((-0.34, 0.31)):
            p.append(barra("cc_pata_%d_%d" % (i, j),
                           (x, lado * 0.16, z(2.2)),
                           (x + 0.04, lado * 0.20, z(0.3)),
                           0.050, M["laranja_esc"]))
    p.append(barra("cc_cauda", (-0.48, 0.0, z(4.3)),
                   (-0.78, -0.10, z(6.0)), 0.055, M["laranja"]))
    origem("cachorro_caramelo")
    volume = selecao("cachorro_caramelo", 0.0, 0.0, 1.2, 0.7)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["cachorro_caramelo"])
    est.registrar("cachorro_caramelo", p, selecionavel=True, celulas=(1, 1),
                  habitat="vila",
                  animacoes={"trote": {"frames": 6, "loop": True},
                             "farejo": {"frames": 4, "loop": False}},
                  cena_godot="res://scenes/fauna/CachorroCaramelo.tscn")


def quero_quero(M, est):
    """Quero-quero de campo: pernas amarelas, peito preto e asa branca."""
    p = []
    corpo = cone("qq_corpo", (-0.05, 0.0, z(3.7)), 0.34, 0.25,
                 z(4.4), 10, M["corda"])
    corpo.scale.x = 1.12
    corpo.scale.y = 0.58
    p.append(corpo)
    p.append(prisma("qq_asa", [(0.22, 0.0), (-0.08, 0.22),
                                (-0.34, 0.0), (-0.08, -0.22)],
                    z(5.3), z(6.7), (0.96, 0.96), M["cabine"]))
    # Mancha escura grande no topo, não um detalhe: a 13 px ela separa a ave
    # branca das pedras claras do campo. Pintar só bico e olho sumiria no
    # antisserrilhado e devolveria exatamente a leitura de "seixo".
    p.append(prisma("qq_peito", [(0.34, 0.0), (0.16, 0.14),
                                  (0.00, 0.0), (0.16, -0.14)],
                    z(6.75), z(7.55), (0.97, 0.97), M["casco"]))
    p.append(cone("qq_cabeca", (0.36, 0.0, z(6.5)), 0.17, 0.13,
                  z(3.0), 9, M["casco"]))
    p.append(prisma("qq_bico", [(0.67, 0.0), (0.43, 0.055),
                                  (0.43, -0.055)],
                    z(6.5), z(7.3), (0.96, 0.96), M["amarelo"]))
    for i, lado in enumerate((1, -1)):
        p.append(barra("qq_perna%d" % i, (-0.02, lado * 0.09, z(3.1)),
                       (0.02, lado * 0.12, z(0.2)), 0.030, M["amarelo"]))
    # Pequeno penacho para a silhueta não se confundir com a gaivota no chão.
    p.append(barra("qq_penacho", (0.29, 0.0, z(8.6)),
                   (0.19, 0.0, z(10.1)), 0.025, M["metal"]))
    origem("quero_quero")
    volume = selecao("quero_quero", 0.0, 0.0, 0.9, 0.7)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["quero_quero"])
    est.registrar("quero_quero", p, selecionavel=True, celulas=(1, 1),
                  habitat="campo_aberto",
                  animacoes={"andar_bicar": {"frames": 6, "loop": True},
                             "voo_curto": {"frames": 4, "loop": False}},
                  cena_godot="res://scenes/fauna/QueroQuero.tscn")


def capivara(M, est):
    """Capivara junto à restinga: corpo pesado, focinho quadrado e pés escuros."""
    p = []
    corpo = cone("cap_corpo", (-0.08, 0.0, z(4.0)), 0.58, 0.46,
                 z(7.5), 12, M["madeira"])
    corpo.scale.x = 1.34
    corpo.scale.y = 0.62
    p.append(corpo)
    cabeca = cone("cap_cabeca", (0.63, 0.0, z(5.0)), 0.34, 0.27,
                  z(6.6), 10, M["madeira"])
    cabeca.scale.y = 0.70
    p.append(cabeca)
    focinho = caixa("cap_focinho", (0.88, 0.0, z(4.2)),
                    (0.25, 0.28, z(3.0)), M["madeira_esc"])
    p.append(focinho)
    for i, lado in enumerate((1, -1)):
        p.append(cone("cap_orelha%d" % i, (0.55, lado * 0.16, z(8.6)),
                      0.075, 0.055, z(1.5), 8, M["madeira_esc"]))
        for j, x in enumerate((-0.38, 0.36)):
            p.append(barra("cap_pata_%d_%d" % (i, j),
                           (x, lado * 0.20, z(3.1)),
                           (x + 0.02, lado * 0.21, z(0.3)),
                           0.065, M["madeira_esc"]))
    origem("capivara")
    volume = selecao("capivara", 0.0, 0.0, 1.5, 0.8)
    _escalar_grupo(p + [volume], ESCALA_DE_JOGO["capivara"])
    est.registrar("capivara", p, selecionavel=True, celulas=(1, 1),
                  habitat="borda_de_mata",
                  animacoes={"andar_pastar": {"frames": 6, "loop": True},
                             "refugio": {"frames": 5, "loop": False}},
                  cena_godot="res://scenes/fauna/Capivara.tscn")


def coqueiro_jovem(M, est):
    """Coqueiro jovem — o estágio BÁSICO do coqueiro que já existe.

    O jogo tem `coqueiro_tronco` e `coqueiro_copa` em peças separadas, porque a
    copa oscila com um Tween e o tronco não. Este mantém a mesma divisão de
    responsabilidade num prop só, por ser baixo demais para a oscilação ler:
    um coqueiro de 1,2m não balança na tela, e animá-lo seria custo sem efeito.
    """
    p = []
    ALT = 30.0
    p.append(cone("coqj_tronco", (0.0, 0.0, z(ALT / 2)), 0.075, 0.055,
                  z(ALT), 10, M["tronco"], rot=(0, 4, 0)))
    # FOLHA EM DUAS PEÇAS, com a ponta caída. Retângulo único saindo do topo
    # dava uma estrela-do-mar: numa palmeira o que se reconhece não é o
    # comprimento da folha, é a CURVA dela. Duas peças com ângulos diferentes
    # chegam perto, e a segunda ainda estreita.
    for i in range(5):
        ang = i * 72 + 12
        cor = M["folha"] if i % 2 == 0 else M["folha_clara"]
        p.append(caixa("coqj_folha%d" % i, (0.0, 0.0, z(ALT + 1.5)),
                       (0.34, 0.115, 0.022), cor, rot=(0, -16, ang)))
        # A ponta arranca onde a primeira acaba, e cai bem mais.
        import math as _m
        r = 0.30
        p.append(caixa("coqj_ponta%d" % i,
                       (r * _m.cos(_m.radians(ang)), r * _m.sin(_m.radians(ang)),
                        z(ALT - 0.5)),
                       (0.30, 0.085, 0.020), cor, rot=(0, 34, ang)))
    p.append(cone("coqj_coco", (0.03, 0.02, z(ALT - 2.5)), 0.05, 0.045,
                  z(3.0), 8, M["madeira_esc"]))
    origem("coqueiro_jovem")
    est.registrar("coqueiro_jovem", p, estagio="basico", celulas=(1, 1),
                  animacoes={"wind_idle": {"frames": 6, "loop": True}})


def arbusto(M, est):
    """Arbusto de restinga. Peça baixa e larga, para a regra de apoio da FASE
    12 não passar só em coisa alta — um prop rasteiro é onde o erro de origem
    aparece menos e incomoda mais."""
    # A primeira versão passava `r1 < r2` e saía um BALDE: o cone alargava para
    # cima e terminava numa tampa plana. Moita é o contrário — larga em baixo,
    # fechando em cima — e são vários volumes pequenos deslocados, não um só
    # grande, senão a silhueta não tem recorte nenhum.
    p = []
    MOITAS = ((0.00, 0.00, 0.23, 12.0), (-0.17, 0.11, 0.17, 9.0),
              (0.16, -0.12, 0.16, 8.5), (0.07, 0.17, 0.13, 7.0),
              (-0.12, -0.15, 0.12, 6.0))
    for i, (x, y, r, h) in enumerate(MOITAS):
        p.append(cone("arb_moita%d" % i, (x, y, z(h / 2)), r, r * 0.42,
                      z(h), 9, M["folha"] if i % 2 == 0 else M["folha_clara"]))
    for i, (x, y) in enumerate(((0.05, 0.0), (-0.12, 0.08))):
        p.append(barra("arb_galho%d" % i, (x, y, z(0.5)), (x, y, z(6.0)),
                       0.018, M["tronco"]))
    origem("arbusto")
    est.registrar("arbusto", p, celulas=(1, 1),
                  animacoes={"wind_idle": {"frames": 6, "loop": True}})


CATALOGO = (gaivota, maria_farinha, tartaruga_verde,
            cachorro_caramelo, quero_quero, capivara,
            coqueiro_jovem, arbusto)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
