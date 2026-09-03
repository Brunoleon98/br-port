"""BRP — assets do porto. FASE 4 do prompt mestre.

Escolha do que entra, e por quê: o prompt pede navios, edifícios, docas e
guindastes em três estágios, mais "caixas, pallets, contêineres, boias, postes,
cabeços, pneus, cones, barreiras". O jogo JÁ tem navio, píer, guindaste,
armazém, escritório, contêiner, caixote e boia — refazê-los seria trocar arte
que funciona por arte nova sem ganho.

O que falta é a CAUDA: as peças pequenas que ocupam o pátio e que o
`docs/design/BR_Port_Plano_Arte_Blender.md` já tinha medido como o melhor ganho por
custo do projeto ("Etapa 2 — a cauda dos props: barato, muda muito"). O pacote
pede as mesmas peças. Então este catálogo serve as duas listas de uma vez.

Todas as peças usam o kit de `tools/gerar_props_iso.py` e a câmera do contrato.
"""

import math

from brp_studio import (caixa, cone, prisma, barra, corrimao, na_face,
                        janela, poste_de_luz, origem, selecao, z)


# Um losango 1x1 do mundo tem 60px de largura na tela. As medidas abaixo estão
# em unidades de mundo na horizontal e em PIXELS DO MAPA na vertical, que é a
# convenção do §2 do contrato espacial.
def _roda(nome, x, y, raio_px, largura, mat, eixo="y"):
    """Roda deitada: cilindro com o eixo em Y (ou em X, se pedido).

    `cone` nasce em pé, então a rotação de 90° em X é o que a deita. Sem ela a
    roda vira um disco no chão e o veículo parece assente na barriga.

    O `eixo` existe por causa do caminhão da estrada: um veículo deitado em
    `my` tem os eixos a apontar em `x`, e uma roda com o eixo no comprimento
    do próprio veículo lê-se como disco espetado no chassi. `rot=(0,90,0)`
    leva o Z do cilindro para o X do mundo, que é o que faz o eixo virar.
    """
    rot = (90, 0, 0) if eixo == "y" else (0, 90, 0)
    return cone(nome, (x, y, z(raio_px)), z(raio_px), z(raio_px),
                largura, 16, mat, rot=rot)


def _pecas_do_caminhao(M, eixo):
    """As peças do caminhão, deitado no eixo pedido ("my" ou "mx").

    ⚠️ UM CONSTRUTOR, DUAS ORIENTAÇÕES, e é por isso que ele existe. A rua do
    porto é uma ESCADA: corre em `my` dentro de cada degrau e salta 4 unidades
    em `mx` no cotovelo que liga um degrau ao seguinte (ver `vias()` no
    `gerar_mapa_iso.py`). Um caminhão que a percorra de ponta a ponta VIRA 90°
    em cada cotovelo, e para virar precisa das duas silhuetas. Duas cópias
    desta função divergiriam no dia em que uma ganhasse um farol.

    ⚠️ E NÃO SE OBTÊM RODANDO O GRUPO. Só as faces `+x` e `-y` são visíveis
    por esta câmera: rodar 90° manda metade dos detalhes para a face que
    ninguém vê. Cada orientação repõe o para-brisa, a janela e o friso na face
    visível que lhes corresponde — é isso que as duas listas abaixo dizem.
    """
    p = []
    RODA, LARG = 5.0, 0.62
    ao_longo_de_y = eixo == "my"

    # `comp` é o eixo do comprimento e `larg` o da largura — trocam entre as
    # duas orientações, e todo o resto sai daqui.
    def dim(comprimento, largura):
        return (largura, comprimento) if ao_longo_de_y else (comprimento, largura)

    def loc(ao_longo, atravessado, alt):
        return ((atravessado, ao_longo, alt) if ao_longo_de_y
                else (ao_longo, atravessado, alt))

    # A FRENTE aponta para onde ele anda: -y quando corre em `my` (que é o
    # `+my` do mapa), +x quando corre em `mx`.
    face_frente = "-y" if ao_longo_de_y else "+x"
    face_lado = "+x" if ao_longo_de_y else "-y"
    sinal_frente = -1.0 if ao_longo_de_y else 1.0

    p.append(caixa("cam_chassi", loc(0.0, 0.0, z(RODA + 2.0)),
                   dim(1.48, LARG) + (z(4.0),), M["metal"]))

    cab_c = loc(sinal_frente * 0.50, 0.0, z(RODA + 11.5))
    cab_t = dim(0.46, LARG) + (z(15.0),)
    p.append(caixa("cam_cabine", cab_c, cab_t, M["azul"]))
    p += janela("cam_vidro_f", face_frente, cab_c, cab_t, 0.0, 0.030, 0.30,
                0.16, M, peitoril=False)
    p += janela("cam_vidro_l", face_lado, cab_c, cab_t, 0.0, 0.030, 0.26,
                0.15, M, peitoril=False)
    p.append(na_face("cam_grade", face_frente, cab_c, cab_t, 0.0, -0.16,
                     0.34, 0.08, 0.03, M["metal_claro"], 0.01))

    # Caçamba atrás, mais alta que a cabine — é o que dá silhueta de caminhão
    # em vez de furgão. O friso corre no comprimento dela, então vai na face
    # que a mostra de PERFIL, que é a lateral.
    cac_c = loc(-sinal_frente * 0.46, 0.0, z(RODA + 13.0))
    cac_t = dim(0.86, LARG + 0.04) + (z(18.0),)
    p.append(caixa("cam_cacamba", cac_c, cac_t, M["laranja"]))
    p.append(na_face("cam_friso", face_lado, cac_c, cac_t, 0.0, 0.0,
                     0.80, 0.03, 0.02, M["metal_claro"], 0.005))
    p.append(caixa("cam_tampa", loc(-sinal_frente * 0.90, 0.0, z(RODA + 13.0)),
                   dim(0.06, LARG) + (z(17.0),), M["metal"]))

    # Três eixos ao longo do comprimento, dois lados na largura. O eixo da roda
    # aponta na LARGURA — num veículo deitado em `my` isso é `x`.
    eixo_roda = "x" if ao_longo_de_y else "y"
    for i, ao_longo in enumerate((sinal_frente * 0.52, -sinal_frente * 0.30,
                                  -sinal_frente * 0.72)):
        for j, atravessado in enumerate((LARG / 2, -LARG / 2)):
            xy = loc(ao_longo, atravessado, 0.0)
            p.append(_roda("cam_roda_%d%d" % (i, j), xy[0], xy[1], RODA, 0.12,
                           M["metal"], eixo=eixo_roda))
    return p


def caminhao(M, est):
    """Caminhão da estrada, deitado NO EIXO DELA (`my`), cabine para o `+my`.

    O jogo já desenha caminhões estacionados no SVG do mapa; este é o prop,
    para quando um caminhão precisar SE MEXER — que é a regra do projeto: o
    que troca de estado dentro de uma partida não pode estar assado no fundo.
    Hoje ele atravessa o mapa inteiro pela rua; a intenção registada é usá-lo
    para mostrar a chegada de uma entrega a um navio.
    """
    p = _pecas_do_caminhao(M, "my")
    origem("caminhao")
    est.registrar("caminhao", p, celulas=(1, 2),
                  cena_godot="res://scenes/props/Caminhao.tscn")


def caminhao_mx(M, est):
    """O mesmo caminhão virado para `+mx`, para os COTOVELOS da rua.

    A rua salta 4 unidades em `mx` a cada degrau da costa, e nesse trecho o
    caminhão anda atravessado ao anterior. Sem esta segunda silhueta ele faria
    a curva a deslizar de lado — o defeito que o CLAUDE.md avisa não se
    consertar rodando no Godot.
    """
    p = _pecas_do_caminhao(M, "mx")
    origem("caminhao_mx")
    est.registrar("caminhao_mx", p, celulas=(2, 1),
                  cena_godot="res://scenes/props/Caminhao.tscn")


def empilhadeira(M, est):
    """Empilhadeira. Peça pequena e muito legível: o mastro vertical quebra a
    horizontal do pátio, que é onde a composição estava monótona."""
    p = []
    RODA = 3.6
    corpo_c, corpo_t = (-0.10, 0.0, z(RODA + 6.0)), (0.62, 0.46, z(10.0))
    p.append(caixa("emp_corpo", corpo_c, corpo_t, M["amarelo"]))
    p.append(caixa("emp_contrapeso", (-0.42, 0.0, z(RODA + 5.0)),
                   (0.16, 0.44, z(9.0)), M["metal"]))

    # Cabine aberta: quatro montantes e um teto. Fechada, a esta escala, vira
    # um bloco sem leitura.
    for i, (dx, dy) in enumerate(((0.10, 0.20), (0.10, -0.20),
                                  (-0.28, 0.20), (-0.28, -0.20))):
        p.append(barra("emp_montante_%d" % i, (dx, dy, z(RODA + 11.0)),
                       (dx, dy, z(RODA + 20.0)), 0.030, M["metal"]))
    p.append(caixa("emp_teto", (-0.09, 0.0, z(RODA + 20.5)),
                   (0.46, 0.46, z(1.6)), M["metal_claro"]))

    # Mastro e garfos à frente.
    for i, dy in enumerate((0.16, -0.16)):
        p.append(barra("emp_mastro_%d" % i, (0.32, dy, z(RODA)),
                       (0.32, dy, z(RODA + 24.0)), 0.045, M["metal_claro"]))
        p.append(caixa("emp_garfo_%d" % i, (0.50, dy, z(1.2)),
                       (0.34, 0.07, z(1.2)), M["metal_claro"]))
    p.append(barra("emp_travessa", (0.32, 0.19, z(RODA + 3.0)),
                   (0.32, -0.19, z(RODA + 3.0)), 0.035, M["metal_claro"]))

    for i, x in enumerate((0.24, -0.30)):
        for j, y in enumerate((0.23, -0.23)):
            p.append(_roda("emp_roda_%d%d" % (i, j), x, y, RODA, 0.10,
                           M["metal"]))

    origem("empilhadeira")
    est.registrar("empilhadeira", p, celulas=(1, 1),
                  cena_godot="res://scenes/props/Empilhadeira.tscn")


def cabeco(M, est):
    """Cabeço de amarração. Custa nada e é a peça que diz que aquele cais
    recebe navio de verdade — sem ela a beira lê como uma laje qualquer."""
    p = [cone("cab_corpo", (0.0, 0.0, z(4.5)), 0.11, 0.085, z(9.0), 14,
              M["metal"]),
         cone("cab_cabeca", (0.0, 0.0, z(10.0)), 0.14, 0.10, z(3.0), 14,
              M["metal"]),
         cone("cab_base", (0.0, 0.0, z(0.8)), 0.17, 0.16, z(1.6), 14,
              M["metal_claro"])]
    origem("cabeco")
    est.registrar("cabeco", p, celulas=(1, 1))


def poste(M, est):
    """Poste de luz, em DUAS peças: a haste e a luminária.

    O kit devolve as quatro peças juntas, e assim o poste ficaria bom e morto.
    A luminária sai à parte pela mesma razão que a copa do coqueiro e a lança do
    guindaste saem: **o que se mexe não pode estar assado no que não se mexe.**
    Com ela separada, o `light_flicker` que o prompt pede na FASE 7 pisca a
    lâmpada e deixa o poste quieto — se fosse uma peça só, piscaria o ferro.
    """
    pecas = poste_de_luz("poste", (0.0, 0.0, 0.0), z(46.0), M["metal"],
                         M["luz_poste"])
    # `poste_de_luz` devolve pé, haste, braço e luminária, nesta ordem.
    haste, luminaria = pecas[:3], pecas[3:]
    origem("poste")
    est.registrar("poste", haste, celulas=(1, 1))
    origem("poste_luz", tipo="encaixe")
    est.registrar("poste_luz", luminaria, ancora="encaixe", celulas=(1, 1),
                  animacoes={"light_flicker": {"tween": "modulate", "loop": True}})


def pallet(M, est):
    """Pallet vazio, encostado. Peça de dois minutos que diz muito: um pátio
    sem pallets é um pátio onde nunca se descarregou nada."""
    p = []
    for i in range(5):
        p.append(caixa("pal_ripa%d" % i, (-0.28 + i * 0.14, 0.0, z(2.6)),
                       (0.10, 0.62, z(1.4)), M["madeira"]))
    for i, y in enumerate((-0.26, 0.0, 0.26)):
        p.append(caixa("pal_travessa%d" % i, (0.0, y, z(1.0)),
                       (0.68, 0.12, z(2.0)), M["madeira_esc"]))
    origem("pallet")
    est.registrar("pallet", p, celulas=(1, 1))


def pneus(M, est):
    """Pilha de pneus de defensa. Fica no cais, junto da beira, e é o que
    explica por que um casco encosta ali sem se estragar."""
    p = []
    for i, (x, y, h) in enumerate(((0.0, 0.0, 3.0), (0.0, 0.0, 8.0),
                                   (0.26, 0.14, 3.0), (0.26, 0.14, 8.0),
                                   (0.12, -0.2, 3.0))):
        p.append(cone("pne_%d" % i, (x, y, z(h)), 0.20, 0.20, z(5.0), 12,
                      M["metal"]))
        # O furo do meio é o que separa "pneu" de "disco preto" a 40px.
        p.append(cone("pne_furo%d" % i, (x, y, z(h)), 0.085, 0.085, z(5.4), 10,
                      M["parede_suja"]))
    origem("pneus")
    est.registrar("pneus", p, celulas=(1, 1))


def cone_transito(M, est):
    """Cone de sinalização."""
    p = [caixa("con_base", (0.0, 0.0, z(0.9)), (0.30, 0.30, z(1.8)),
               M["laranja"]),
         cone("con_corpo", (0.0, 0.0, z(6.0)), 0.13, 0.03, z(10.0), 10,
              M["laranja"]),
         cone("con_faixa", (0.0, 0.0, z(7.6)), 0.093, 0.075, z(2.0), 10,
              M["cabine"])]
    origem("cone_transito")
    est.registrar("cone_transito", p, celulas=(1, 1))


def barreira(M, est):
    """Barreira de obra, listrada. Serve para fechar um trecho do pátio."""
    p = [caixa("bar_trave", (0.0, 0.0, z(13.0)), (1.10, 0.10, z(4.0)),
               M["cabine"])]
    # As listras são peças, não textura: a esta escala uma faixa pintada some.
    for i in range(4):
        p.append(caixa("bar_faixa%d" % i, (-0.36 + i * 0.24, 0.0, z(13.0)),
                       (0.12, 0.11, z(4.2)), M["laranja"], rot=(0, 0, 0)))
    for x in (-0.46, 0.46):
        p.append(caixa("bar_pe%s" % ("e" if x < 0 else "d"),
                       (x, 0.0, z(6.0)), (0.09, 0.34, z(12.0)), M["cabine"]))
    origem("barreira")
    est.registrar("barreira", p, celulas=(1, 1))


def bote(M, est):
    """Bote salva-vidas no berço, de proa para o mar.

    Casco em prisma, e não em caixa: um bote com a proa quadrada lê como
    caixote pintado de laranja.
    """
    p = []
    contorno = [(-0.52, -0.15), (0.30, -0.19), (0.60, 0.0),
                (0.30, 0.19), (-0.52, 0.15)]
    # `escala_baixo` é um PAR (ex, ey): o casco estreita mais em y que em x,
    # senão o bote afina como uma cunha em vez de ter fundo.
    p.append(prisma("bot_casco", contorno, z(3.0), z(11.0),
                    (0.80, 0.62), M["boia"]))
    p.append(prisma("bot_borda", contorno, z(11.0), z(12.2),
                    (1.0, 1.0), M["cabine"]))
    p.append(caixa("bot_banco", (-0.05, 0.0, z(9.0)), (0.30, 0.26, z(1.6)),
                   M["madeira"]))
    # Berço: sem ele o bote flutua sobre o cais, que é a queixa nº 1 do pacote.
    for i, x in enumerate((-0.34, 0.24)):
        p.append(caixa("bot_berco%d" % i, (x, 0.0, z(1.5)),
                       (0.14, 0.42, z(3.0)), M["madeira_esc"]))
    origem("bote")
    est.registrar("bote", p, celulas=(1, 1))


def guincho(M, est):
    """Guincho de cais: tambor, manivela e cabo enrolado."""
    p = [caixa("gui_base", (0.0, 0.0, z(1.5)), (0.52, 0.42, z(3.0)),
               M["metal"])]
    for i, y in enumerate((-0.17, 0.17)):
        p.append(caixa("gui_flange%d" % i, (0.0, y, z(8.0)),
                       (0.36, 0.06, z(9.0)), M["metal_claro"]))
    p.append(cone("gui_tambor", (0.0, 0.0, z(8.0)), 0.13, 0.13, 0.30, 12,
                  M["corda"], rot=(90, 0, 0)))
    p.append(cone("gui_manivela", (0.0, 0.26, z(8.0)), 0.035, 0.035, 0.16, 8,
                  M["metal_claro"], rot=(90, 0, 0)))
    p.append(caixa("gui_punho", (0.13, 0.34, z(8.0)), (0.05, 0.05, z(3.4)),
                   M["madeira"]))
    origem("guincho")
    est.registrar("guincho", p, celulas=(1, 1))


def pilha_caixotes(M, est):
    """Pilha de caixotes. Três na base, dois em cima, um torto no topo.

    O torto não é enfeite: uma pilha perfeitamente alinhada lê como textura
    repetida, e é justamente a queixa que abre a auditoria do pacote — "objetos
    retangulares que parecem flutuar" porque nada os prende ao lugar.
    """
    p = []
    # TRÊS MADEIRAS ALTERNADAS, e não é enfeite. A primeira versão usava
    # `madeira` nos seis caixotes: renderizou, mediu certo, e ao olhar era uma
    # massa marrom só — faces vizinhas do mesmo tom fundem-se, e a esta escala
    # (a pilha tem ~48px na tela) não há chanfro que as separe. O que separa é
    # o material. Serve de aviso: o teste passou nessa versão.
    TONS = (M["madeira"], M["madeira_esc"], M["madeira_velha"])
    base = ((-0.22, -0.20), (0.22, -0.20), (0.0, 0.22))
    for i, (x, y) in enumerate(base):
        p.append(caixa("pil_a%d" % i, (x, y, z(5.5)), (0.40, 0.40, z(11.0)),
                       TONS[i % 3], rot=(0, 0, 9 * i - 6)))
    for i, (x, y) in enumerate(((-0.10, -0.02), (0.24, 0.06))):
        p.append(caixa("pil_b%d" % i, (x, y, z(16.5)), (0.38, 0.38, z(11.0)),
                       TONS[(i + 2) % 3], rot=(0, 0, -14 + 26 * i)))
    p.append(caixa("pil_topo", (0.02, 0.0, z(27.0)), (0.34, 0.34, z(10.0)),
                   TONS[1], rot=(0, 5, 24)))
    # Cintas no topo de cada caixote da base: é a linha horizontal que corta o
    # marrom e diz onde uma peça acaba e a seguinte começa.
    for i, (x, y) in enumerate(base):
        p.append(caixa("pil_cinta%d" % i, (x, y, z(10.4)),
                       (0.42, 0.42, z(1.1)), M["metal_claro"],
                       rot=(0, 0, 9 * i - 6)))
    origem("pilha_caixotes")
    est.registrar("pilha_caixotes", p, celulas=(1, 1))


def doca_concreto(M, est):
    """Doca de concreto — o estágio INTERMEDIÁRIO da doca de madeira.

    O prompt pede progressão básico/intermediário/avançado e avisa: "não faça
    apenas uma cópia escalada, adicione componentes funcionais visíveis". O que
    muda aqui não é o tamanho: é o material (madeira -> concreto), a defensa de
    pneu, o cabeço e o corrimão. O básico continua sendo `pier_construido.png`,
    que já existe e não se toca.
    """
    p = []
    ALC, LARG = 4.5, 2.4
    ALT = 15.0

    p.append(caixa("doc_laje", (0.0, 0.0, z(ALT - 2.2)),
                   (ALC, LARG, z(4.4)), M["parede_dir"]))
    p.append(caixa("doc_viga", (0.0, 0.0, z(ALT - 5.4)),
                   (ALC - 0.2, LARG - 0.3, z(2.4)), M["parede_suja"]))

    # Pilares de concreto no lugar das estacas de madeira.
    for i, x in enumerate((-1.7, -0.55, 0.6, 1.75)):
        for j, y in enumerate((LARG / 2 - 0.22, -LARG / 2 + 0.22)):
            p.append(caixa("doc_pilar_%d%d" % (i, j), (x, y, z(ALT / 2 - 3.0)),
                           (0.26, 0.26, z(ALT + 10.0)), M["parede_suja"]))

    # Defensas de pneu no flanco onde o barco encosta (-y local = +my do mapa).
    for i, x in enumerate((-1.5, -0.5, 0.5, 1.5)):
        p.append(cone("doc_pneu_%d" % i, (x, -LARG / 2 - 0.02, z(ALT - 6.0)),
                      0.16, 0.16, 0.07, 14, M["metal"], rot=(0, 90, 0)))

    p += corrimao("doc_corrimao", (-ALC / 2 + 0.2, LARG / 2 - 0.08, z(ALT)),
                  (ALC / 2 - 0.2, LARG / 2 - 0.08, z(ALT)), z(16.0),
                  M["metal_claro"], postes=6)
    for i, x in enumerate((-1.4, 1.4)):
        p.append(cone("doc_cabeco_%d" % i, (x, -LARG / 2 + 0.22, z(ALT + 4.5)),
                      0.10, 0.08, z(9.0), 12, M["metal"]))

    origem("doca_concreto")
    selecao("doca_concreto", 0.0, 0.0, ALC, LARG)
    est.registrar("doca_concreto", p, estagio="intermediario",
                  selecionavel=True, celulas=(4, 2),
                  cena_godot="res://scenes/dock/Dock.tscn")


# ── O TRABALHADOR DO CARTÃO ──────────────────────────────────────────────
#
# Pedido do playtest: "o sprite do trabalhador pode ser refeito para ficar mais
# de acordo com o design do jogo". Estava certo, e a distância era grande: o
# `art/sprites/trabalhador.png` é um desenho pintado, com contorno, brilho e
# degradê, e este jogo inteiro é facetado, sem contorno e de faces chapadas.
# Ele não destoava por ser feio — destoava por ser de outra oficina.
#
# ⚠️ NÃO É O `trabalhador` DO PÍER, e os dois têm de continuar a existir. Aquele
# tem 22px na tela e são cinco caixas de propósito: a esta escala mais peça
# vira ruído. Este tem 70px no cartão do rodapé, e a 70px cinco caixas leem-se
# como um boneco de LEGO. Mesmo personagem, dois orçamentos de pixel.
#
# ⚠️ E ELE OLHA PARA A FRENTE, o que nenhum outro prop faz. Todo o resto do
# catálogo vive NO MAPA e por isso obedece ao 3/4 da câmera; este vive num
# CARTÃO de interface, e um retrato de 3/4 num cartão de 108px mostra sobretudo
# o capacete. A volta é rodar o boneco 45° em Z — a câmera não muda, o contrato
# não muda, e a cara passa a apontar para quem olha. As duas faces laterais
# ficam simétricas, que é exactamente a leitura de retrato que se quer.
def _girar_para_a_camera(objs, graus=45.0):
    """Roda o grupo em torno do Z do mundo, posição e orientação juntas.

    Rodar só a `rotation_euler` deixaria as peças no sítio antigo e o boneco
    sairia desmontado — cada caixa girada sobre o próprio centro. A posição
    tem de girar com ela.
    """
    a = math.radians(graus)
    ca, sa = math.cos(a), math.sin(a)
    for o in objs:
        x, y, z_ = o.location
        o.location = (x * ca - y * sa, x * sa + y * ca, z_)
        o.rotation_euler.z += a


def trabalhador_retrato(M, est):
    """De corpo inteiro, de frente, para o cartão do rodapé.

    ⚠️ AS MEDIDAS SÃO TODAS EM PIXELS DE DESENHO, e é a única forma de acertar
    proporção aqui. A primeira tentativa misturou as duas convenções do
    contrato — largura em unidades de mundo, altura em pixels — e saiu um
    PALITO de 429px de altura por 27 de tronco, cortado no topo do quadro.
    Uma unidade de mundo não vale a mesma coisa nos dois eixos: depois da
    rotação de 45°, a largura do boneco anda 42,4px por unidade, a altura
    36,7px, e a PROFUNDIDADE dele sobe 21,2px por unidade (é a faixa da face
    de cima). Três fatores diferentes; escrever em pixels tira-os da frente.

    ⚠️ O ORÇAMENTO REAL É 32x70, que é o tamanho a que o cartão o mostra.
    Foi isso que matou a segunda tentativa, e ela passava em todas as contas:
    as duas faixas refletivas tinham 70px de largura num colete de 68 e
    tapavam o laranja inteiro — o boneco saía com o tronco BRANCO. A esta
    escala cada peça tem de ganhar o seu espaço contra as vizinhas, não
    apenas caber: daí a cabeça grande, o colete mais ESTREITO que o tronco e
    uma faixa só.

    ⚠️ E ELE ENCHE O QUADRO, ao contrário de todos os outros props. Um prop do
    mapa fica pequeno no PNG de 512 e é o Godot que o põe no sítio; este é
    mostrado num `TextureRect` de 70px com `KEEP_ASPECT_CENTERED`, e nesse
    modo o que escala é o QUADRO INTEIRO, transparência incluída. A quarta
    tentativa ficou com 460px de quadro para 251 de boneco e no cartão saiu um
    boneco de 34px dentro de uma moldura de 70 — certo em toda a asserção,
    minúsculo no ecrã. Por isso ele é ESCALADO por `K` e CENTRADO em z: o
    quadro passa a ser quase todo boneco.
    """
    LG = 42.426          # px de tela por unidade, na largura do boneco
    PF = 21.213          # px de tela por unidade, na profundidade dele
    K = 1.85             # enche o quadro (ver o aviso acima)
    # ⚠️ NÃO É METADE DA ALTURA DO BONECO. Quem toca no fundo do quadro não é
    # o pé: é a QUINA DA FRENTE da bota, que numa projeção isométrica desce
    # meia profundidade abaixo dele — 31px aqui. Centrar pela altura deixava a
    # bota 19px cortada, e cortada rente à borda não se vê, porque não há nada
    # por baixo com que a comparar. Este número sai da conta da quina.
    MEIO = 197.0         # quanto o boneco desce, para ficar centrado no quadro

    lg = lambda px: px * K / LG
    pf = lambda px: px * K / PF
    alt = lambda px: z(px * K)                 # uma altura RELATIVA
    nivel = lambda px: z(px * K - MEIO)        # uma altura absoluta, centrada

    def bloco(nome, x_px, y_px, z0, z1, larg_px, fundo_px, mat):
        """Uma peça descrita pelo que se VÊ: onde começa e acaba, e o tamanho."""
        return caixa(nome,
                     (lg(x_px), pf(y_px), nivel((z0 + z1) / 2.0)),
                     (lg(larg_px), pf(fundo_px), alt(z1 - z0)), mat)

    pecas = [
        # Botas mais LARGAS e mais FUNDAS que a perna: é o pé a apontar para a
        # frente, e é o que impede o boneco de se equilibrar em dois palitos.
        bloco("r_bota_e", -16, -6, 0, 16, 30, 34, M["madeira_esc"]),
        bloco("r_bota_d", 16, -6, 0, 16, 30, 34, M["madeira_esc"]),
        bloco("r_perna_e", -16, 0, 16, 78, 26, 22, M["casco"]),
        bloco("r_perna_d", 16, 0, 16, 78, 26, 22, M["casco"]),
        bloco("r_cinto", 0, 0, 74, 84, 80, 32, M["madeira_esc"]),
    ]

    # ⚠️ O TRONCO E O COLETE SÃO PRISMAS, e não caixas, e é a diferença entre
    # um boneco e uma pilha de tijolos. A 32x70 no cartão o que se lê é a
    # SILHUETA, e uma silhueta de caixas é um retângulo — nada nela diz
    # "pessoa". Estreitar a cintura contra o ombro dá o contorno de um corpo
    # com quatro números e sem custo nenhum de render.
    #
    # ⚠️ E O ESTREITAMENTO É SÓ EM `x`. Estreitar também a PROFUNDIDADE
    # recuaria a face da frente meio pixel a meio da altura, e a faixa
    # refletiva — que é uma placa rente a essa face — ficaria DENTRO do
    # colete, invisível e sem erro nenhum a dizê-lo.
    def tronco(nome, z0, z1, larg_px, fundo_px, estreita, mat):
        lx, fy = lg(larg_px) / 2.0, pf(fundo_px) / 2.0
        contorno = [(-lx, -fy), (lx, -fy), (lx, fy), (-lx, fy)]
        return prisma(nome, contorno, nivel(z0), nivel(z1), (estreita, 1.0), mat)

    # Camisa larga, colete mais ESTREITO e mais FUNDO por cima. O colete tem de
    # ficar saliente em `y`, e não rente: duas faces no mesmo plano não dão
    # erro, dão o z-buffer a escolher ao acaso — numa versão anterior o colete
    # e o tronco tinham a mesma frente e o laranja simplesmente não apareceu.
    pecas += [
        tronco("r_tronco", 80, 148, 84, 30, 0.74, M["azul"]),
        # O colete começa 16px ABAIXO do ombro. É esse pedaço de camisa em cima
        # que o faz ler como colete VESTIDO em vez de caixa laranja pousada à
        # frente do boneco — a 32px de largura no cartão uma gola desenhada não
        # cabe, e a que se tentou saía a ler como bolso.
        tronco("r_colete", 82, 132, 62, 38, 0.84, M["colete"]),
        bloco("r_braco_e", -46, 0, 82, 142, 15, 20, M["azul"]),
        bloco("r_braco_d", 46, 0, 82, 142, 15, 20, M["azul"]),
        bloco("r_mao_e", -46, 1, 64, 84, 17, 22, M["pele"]),
        bloco("r_mao_d", 46, 1, 64, 84, 17, 22, M["pele"]),
        bloco("r_pescoco", 0, 0, 144, 154, 22, 16, M["pele"]),
        # Cabeça grande de propósito: a 70px de cartão, uma cabeça de
        # proporção realista tem 10px e não sobra onde pôr cara nenhuma.
        bloco("r_cabeca", 0, 0, 150, 196, 50, 30, M["pele"]),
    ]

    # O capacete é REDONDO, e é o que o identifica de longe. Em caixa ele lia
    # como uma laje amarela pousada na cabeça — a silhueta é metade do trabalho
    # a esta escala. A aba é um disco à parte e fica ACIMA dos olhos: uma aba
    # baixa tapa-os, e um trabalhador sem olhos é um capacete com pernas.
    # ⚠️ `cone` PEDE RAIO, e `lg()` devolve LARGURA. Passar `lg(58)` como raio
    # deu uma aba de 116px de diâmetro numa cabeça de 50 — no cartão o boneco
    # aparecia com um CHAPÉU DE PALHA, e nada no render dizia porquê. Meia
    # largura, portanto, e é a mesma armadilha de todo kit que mistura as duas
    # convenções.
    raio = lambda px: lg(px) / 2.0
    pecas.append(cone("r_aba", (0.0, 0.0, nivel(194)), raio(56), raio(56),
                      alt(4), 12, M["capacete"]))
    pecas.append(cone("r_capacete", (0.0, 0.0, nivel(205)), raio(48), raio(38),
                      alt(20), 12, M["capacete"]))

    # A faixa refletiva do colete, e o rosto. Vão na face `-y` porque é ela que
    # a rotação leva para a frente — e `na_face` só conhece as duas faces que
    # esta câmera vê, o que aqui é ajuda e não limite.
    colete_c = (0.0, 0.0, nivel((82 + 132) / 2.0))
    colete_t = (lg(62), pf(38), alt(50))
    pecas.append(na_face("r_faixa", "-y", colete_c, colete_t,
                         0.0, alt(2), lg(64), alt(9), 0.02, M["refletivo"]))
    cab_c = (0.0, 0.0, nivel((150 + 196) / 2.0))
    cab_t = (lg(50), pf(30), alt(46))
    for lado, u in (("e", -10), ("d", 10)):
        pecas.append(na_face("r_olho_%s" % lado, "-y", cab_c, cab_t,
                             lg(u), alt(3), lg(8), alt(7), 0.02, M["madeira_esc"]))
    pecas.append(na_face("r_boca", "-y", cab_c, cab_t,
                         0.0, alt(-12), lg(16), alt(4), 0.02, M["madeira_esc"]))

    _girar_para_a_camera(pecas)
    origem("trabalhador_retrato", tipo="retrato")
    est.registrar("trabalhador_retrato", pecas, ancora="retrato",
                  cena_godot="res://scenes/worker/Worker.tscn")


CATALOGO = (caminhao, caminhao_mx, empilhadeira, cabeco, poste, pilha_caixotes,
            doca_concreto, pallet, pneus, cone_transito, barreira, bote,
            guincho, trabalhador_retrato)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
