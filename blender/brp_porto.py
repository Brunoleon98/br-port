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

from mathutils import Euler, Matrix, Vector

from brp_studio import (caixa, cone, prisma, barra, corrimao, na_face,
                        janela, moldura, poste_de_luz, origem, selecao, z)


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


# ── OS QUATRO CAMIÕES, UM POR MOTIVO DE ESCALA ──────────────────────────
#
# Até 06/09 havia UM caminhão, em duas silhuetas — e as duas eram o mesmo
# veículo, porque a rua vira 90° e só as faces `+x` e `-y` são visíveis. A
# estrada do porto mostrava sempre a mesma caçamba laranja, fosse o porto a
# receber pescado ou contêiner.
#
# Desde os motivos da escala (`docs/decisoes/008`) o jogo SABE o que cada barco
# traz. O que sai do porto pela estrada passou a poder dizê-lo: quem escolhe é
# o `Main.gd`, pela carga da doca do mesmo índice, e a chave é o id do motivo —
# por isso estes nomes são `pescado`, `armazenagem`, `conteiner` e `granel` e
# não "frigorífico", "baú", "carreta" e "basculante". Nome de prop que não é a
# chave da tabela do jogo é uma tradução a mais para envelhecer.
#
# ⚠️ O QUE SEPARA QUATRO CAMIÕES A 60px É A SILHUETA, NÃO A COR. Quatro
# carroçarias do mesmo tamanho pintadas de quatro cores seriam quatro etiquetas
# — a mesma armadilha do armazém em ruína, que era o galpão com o telhado
# repintado. Por isso cada um tem comprimento, altura e número de eixos
# próprios: a carreta é longa e baixa, o baú é curto e alto, o frigorífico é o
# mais curto de todos, e o basculante leva o monte de granel acima da borda.
CAMINHOES = {
    # A carreta: o chassi mais longo do jogo e o contêiner do PÁTIO em cima
    # dele. O contêiner é o mesmo vocabulário — corpo laranja, vinco de valor,
    # cantoneira escura — de propósito: é a mesma caixa que o pátio empilha, e
    # vê-la a sair pela estrada é o que liga as duas pontas.
    "conteiner":   dict(chassi=1.96, cabine=0.44, cor_cab="cabine",
                        eixos=(0.78, -0.18, -0.54, -0.86)),
    "granel":      dict(chassi=1.48, cabine=0.46, cor_cab="amarelo",
                        eixos=(0.52, -0.30, -0.72)),
    "armazenagem": dict(chassi=1.56, cabine=0.44, cor_cab="azul",
                        eixos=(0.58, -0.28, -0.70)),
    # O mais curto: um frigorífico de peixe é um caminhão de bairro, não uma
    # carreta de porto.
    "pescado":     dict(chassi=1.10, cabine=0.42, cor_cab="cabine",
                        eixos=(0.34, -0.36)),
}


def _pecas_do_caminhao(M, eixo, servico):
    """As peças de um caminhão, no eixo pedido ("my" ou "mx") e do serviço dado.

    ⚠️ UM CONSTRUTOR, DUAS ORIENTAÇÕES, e é por isso que ele existe. A rua do
    porto é uma ESCADA: corre em `my` dentro de cada degrau e salta 4 unidades
    em `mx` no cotovelo que liga um degrau ao seguinte (ver `vias()` no
    `gerar_mapa_iso.py`). Um caminhão que a percorra de ponta a ponta VIRA 90°
    em cada cotovelo, e para virar precisa das duas silhuetas. Duas cópias
    desta função divergiriam no dia em que uma ganhasse um farol — e com
    quatro serviços seriam OITO cópias a divergir.

    ⚠️ E NÃO SE OBTÊM RODANDO O GRUPO. Só as faces `+x` e `-y` são visíveis
    por esta câmera: rodar 90° manda metade dos detalhes para a face que
    ninguém vê. Cada orientação repõe o para-brisa, a janela e o friso na face
    visível que lhes corresponde — é isso que as duas listas abaixo dizem.

    ⚠️ E A TRASEIRA NUNCA É VISÍVEL, nas duas. Para o caminhão de `my` a
    traseira é `+y`; para o de `mx` é `-x`; nenhuma das duas está de frente
    para esta câmera. Por isso o portão de enrolar do baú NÃO foi desenhado
    atrás, que era onde ele estaria num caminhão de verdade: a assinatura de
    cada carroçaria tem de caber nas duas faces que se veem, ou é render que
    ninguém vê.
    """
    d = CAMINHOES[servico]
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
    sf = -1.0 if ao_longo_de_y else 1.0          # sinal da frente

    chassi, cab_comp = d["chassi"], d["cabine"]
    p.append(caixa("cam_chassi", loc(0.0, 0.0, z(RODA + 2.0)),
                   dim(chassi, LARG) + (z(4.0),), M["metal"]))

    # A cabine encosta na frente do chassi — a posição SAI do comprimento, e
    # não de um número por serviço: quatro chassis diferentes com a cabine
    # escrita à mão dariam quatro chances de uma ficar a pairar no ar.
    cab_c = loc(sf * (chassi / 2.0 - cab_comp / 2.0), 0.0, z(RODA + 11.5))
    cab_t = dim(cab_comp, LARG) + (z(15.0),)
    p.append(caixa("cam_cabine", cab_c, cab_t, M[d["cor_cab"]]))
    p += janela("cam_vidro_f", face_frente, cab_c, cab_t, 0.0, 0.030, 0.30,
                0.16, M, peitoril=False)
    p += janela("cam_vidro_l", face_lado, cab_c, cab_t, 0.0, 0.030, 0.26,
                0.15, M, peitoril=False)
    p.append(na_face("cam_grade", face_frente, cab_c, cab_t, 0.0, -0.16,
                     0.34, 0.08, 0.03, M["metal_claro"], 0.01))

    # A carroçaria enche o que sobra do chassi, encostada à traseira. Os 0,06
    # de folga para a cabine são o que impede as duas de partilharem uma face
    # — duas faces no mesmo plano dão o losango preto que este projeto já
    # registou três vezes.
    corpo_comp = chassi - cab_comp - 0.06
    corpo_x = -sf * (chassi / 2.0 - corpo_comp / 2.0)
    def corpo_c(alt_px):
        return loc(corpo_x, 0.0, z(RODA + alt_px))

    if servico == "granel":
        # BASCULANTE, e o granel À VISTA acima da borda. Uma caçamba vazia é
        # uma caixa; o que diz "granel" é o monte, e ele tem de passar da
        # borda, senão fica dentro e a câmera não o vê.
        cac_t = dim(corpo_comp, LARG + 0.04) + (z(16.0),)
        p.append(caixa("cam_cacamba", corpo_c(12.0), cac_t, M["metal"]))
        p.append(na_face("cam_friso", face_lado, corpo_c(12.0), cac_t, 0.0, 0.0,
                         corpo_comp * 0.92, 0.03, 0.02, M["metal_claro"], 0.005))
        # Duas camadas: a carga rente à borda e a crista mais estreita por
        # cima. Uma camada só saía como um tampo plano — a caçamba fechada.
        p.append(caixa("cam_carga", corpo_c(20.0),
                       dim(corpo_comp - 0.06, LARG - 0.04) + (z(4.0),),
                       M["madeira_velha"]))
        p.append(caixa("cam_crista", corpo_c(23.0),
                       dim(corpo_comp - 0.34, LARG - 0.20) + (z(3.0),),
                       M["madeira_velha"]))

    elif servico == "armazenagem":
        # BAÚ. A assinatura dele é a ALTURA e o avanço sobre a cabine — é o que
        # se lê de longe. O friso laranja separa-o do frigorífico branco-e-azul
        # sem repetir a silhueta dele.
        # ⚠️ O BAÚ NÃO AVANÇA SOBRE A CABINE. A primeira versão dava-lhe
        # 0,16 de comprimento a mais e um deslocamento de 0,08 para a frente —
        # o "nariz" do furgão, que é um traço real —, e o que saiu foi a caixa
        # a ATRAVESSAR a cabine por 0,10: a teal do serviço quase desaparecia
        # atrás do branco. Quem separa este dos outros três é a ALTURA (24px
        # contra os 16 do basculante), e ela não precisa de ajuda.
        bau_t = dim(corpo_comp + 0.02, LARG + 0.04) + (z(24.0),)
        bau_c = loc(corpo_x, 0.0, z(RODA + 16.0))
        p.append(caixa("cam_bau", bau_c, bau_t, M["cabine"]))
        p.append(na_face("cam_friso", face_lado, bau_c, bau_t, 0.0, -0.06,
                         corpo_comp * 0.94, 0.09, 0.02, M["laranja"], 0.005))
        # Duas nervuras verticais: um baú é chapa em painéis, e a esta escala
        # dois vincos chegam para o dizer. Mais seria a lixa do `DESGASTE`.
        for i, u in enumerate((-0.18, 0.18)):
            p.append(na_face("cam_nerv%d" % i, face_lado, bau_c, bau_t, u, 0.06,
                             0.04, 0.22, 0.02, M["parede_dir"], 0.004))

    elif servico == "pescado":
        # FRIGORÍFICO. Curto, azul, e com a unidade de frio a espreitar por
        # cima da cabine — é essa saliência no topo da frente que diz "peixe" a
        # 40px, e não a cor sozinha.
        bau_t = dim(corpo_comp + 0.10, LARG) + (z(19.0),)
        bau_c = loc(corpo_x + sf * 0.05, 0.0, z(RODA + 13.5))
        p.append(caixa("cam_bau", bau_c, bau_t, M["azul"]))
        p.append(na_face("cam_faixa", face_lado, bau_c, bau_t, 0.0, 0.04,
                         corpo_comp * 0.92, 0.07, 0.02, M["refletivo"], 0.005))
        # A unidade de frio: pequena de propósito. A 0,16 x 0,50 ela saía como
        # um TAMPO escuro sobre metade do baú, e o que se lia era um caminhão
        # de teto preto. O que diz "frigorífico" é a saliência, não a área.
        p.append(caixa("cam_frio",
                       loc(corpo_x + sf * (corpo_comp / 2.0 - 0.02), 0.0,
                           z(RODA + 23.0)),
                       dim(0.11, LARG - 0.24) + (z(5.0),), M["metal_claro"]))

    else:                                       # conteiner
        # CARRETA. Prancha rasa e o contêiner do pátio em cima — e o contêiner
        # é a peça, não a caixa laranja: sem cantoneira e sem vinco ele lê como
        # um baú cor de tijolo.
        p.append(caixa("cam_prancha", corpo_c(6.0),
                       dim(corpo_comp, LARG + 0.02) + (z(3.0),), M["metal"]))
        cont_comp = corpo_comp - 0.16
        cont_t = dim(cont_comp, LARG - 0.02) + (z(15.0),)
        cont_c = corpo_c(15.0)
        p.append(caixa("cam_cont", cont_c, cont_t, M["laranja"]))
        for i in range(4):
            u = (i - 1.5) * (cont_comp / 4.4)
            p.append(na_face("cam_vinco%d" % i, face_lado, cont_c, cont_t, u,
                             0.0, cont_comp / 6.4, z(15.0) * 0.72, 0.05,
                             M["laranja_esc"], -0.030))
        # Cantoneiras: o canto escuro é a assinatura do contêiner, e é ela que
        # o separa do baú do caminhão de armazenagem.
        #
        # ⚠️ E AQUI ELAS SÃO MONTANTES INTEIROS, não os quatro quadrados que o
        # contêiner do pátio usa. A razão é a escala: aquele tem 23px de face
        # comprida e este 29px de comprimento sobre 10 de altura — um quadrado
        # de 0,09 dá 2px, que a esta altura some entre o vinco e a beira. Duas
        # verticais de ponta a ponta mais a longarina de baixo desenham a mesma
        # coisa (o esqueleto escuro do contêiner) com traços que se veem.
        for i, su in enumerate((-1, 1)):
            p.append(na_face("cam_canto%d" % i, face_lado, cont_c, cont_t,
                             su * (cont_comp / 2 - 0.045), 0.0,
                             0.09, z(15.0) * 0.96, 0.05, M["metal"], -0.026))
        p.append(na_face("cam_longarina", face_lado, cont_c, cont_t, 0.0,
                         -z(15.0) / 2 + 0.03, cont_comp * 0.98, 0.06, 0.05,
                         M["metal"], -0.026))

    # Os eixos vêm da tabela: a carreta tem quatro, o frigorífico dois. O eixo
    # da roda aponta na LARGURA — num veículo deitado em `my` isso é `x`.
    eixo_roda = "x" if ao_longo_de_y else "y"
    for i, ao_longo in enumerate(d["eixos"]):
        for j, atravessado in enumerate((LARG / 2, -LARG / 2)):
            xy = loc(sf * ao_longo, atravessado, 0.0)
            p.append(_roda("cam_roda_%d%d" % (i, j), xy[0], xy[1], RODA, 0.12,
                           M["metal"], eixo=eixo_roda))
    return p


# ⚠️ O CAMIÃO ERA DO TAMANHO DO ESCRITÓRIO, e está medido (playtest 2, 06/09).
# A carreta tinha 1,96 unidades de comprimento; o escritório tem 1,99 × 1,70 e
# a casa da vila 1,35 de profundidade — um camião tão comprido quanto o prédio
# inteiro, e mais comprido do que uma casa é larga. Na rua, os 0,62 de largura
# ocupavam 56% dos 1,10 do asfalto.
#
# ⚠️ E A MEDIDA TINHA DUAS SAÍDAS. Ela também diz que os PRÉDIOS estão
# pequenos — um escritório de porto do tamanho de um camião é o mesmo defeito
# visto do outro lado. Encolher o camião é a metade contida: não toca em
# pegada, em vão da vila nem no enquadramento, e ainda liberta largura de rua
# para a via de mão dupla. Foi a escolha do Bruno, com o número na mão.
#
# 0,72 põe a carreta em 1,41 (contra 1,99 do escritório e 1,35 da casa) e a
# largura em 0,45 numa rua de 1,10 — 41% dela, que deixa passar dois.
#
# ⚠️ E ESCALA-SE NO GRUPO, nunca reescrevendo as literais. São trinta números
# por camião — chassi, cabine, vidro, friso, monte de granel, cantoneira,
# eixo — e trinta chances de um ficar por escalar. É a regra que o galpão
# pagou quando encolheu. Cada objeto UMA vez: aqui não há partilha (o
# construtor cria peças novas a cada chamada), e o `set()` fica na mesma,
# porque é ele que deixa acrescentar um camião sem saber o que ele reaproveita.
ESCALA_CAMINHAO = 0.72


def _encolher(objetos, k):
    """Escala uniforme em torno da origem do mundo.

    `location` e `scale` pelo mesmo fator mantêm a base assente no chão, porque
    a base está em z≈0. Escalar só o `scale` deixaria as peças nos lugares
    antigos e o camião desmontava-se.
    """
    for o in set(objetos):
        o.location = tuple(c * k for c in o.location)
        o.scale = tuple(c * k for c in o.scale)


def _registrar_caminhoes(M, est):
    """Os oito props: quatro serviços × duas orientações.

    O jogo já sabe que um caminhão que anda em `mx` precisa de outra silhueta;
    o que passou a saber é QUAL das quatro. A tabela do `Main.gd` indexa por
    `<motivo>` e `<motivo>_mx`, e é por isso que os nomes se escrevem assim.
    """
    for servico in CAMINHOES:
        for eixo, sufixo, celulas in (("my", "", (1, 2)), ("mx", "_mx", (2, 1))):
            nome = "caminhao_%s%s" % (servico, sufixo)
            pecas = _pecas_do_caminhao(M, eixo, servico)
            _encolher(pecas, ESCALA_CAMINHAO)
            origem(nome)
            est.registrar(nome, pecas, celulas=celulas)


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
    mapa fica pequeno no PNG e é o Godot que o põe no sítio; este é
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


# ── OS TRÊS ROSTOS QUE FALAM ────────────────────────────────────────────────
#
# Pedido do Bruno na primeira leitura em voz alta (13/09): *"seria legal
# aparecer o sprite dos personagens, poderia ser o sprite com a reação do
# personagem mais a mensagem"*. Até aqui o jogo tinha sete telas narrativas e
# nenhuma CARA — a Dona Cida, o Arlindo e o Sr. Ribeiro eram texto num balão,
# e quem falava só se sabia pelo título do painel.
#
# ⚠️ SÃO BUSTOS, E O `trabalhador_retrato` É DE CORPO INTEIRO. Não é gosto: os
# dois cartões pedem coisas diferentes, que é a mesma razão de existirem dois
# bonecos de trabalhador. Aquele identifica uma UNIDADE, e o que o identifica é
# o capacete e o colete — silhueta, que sobrevive a qualquer tamanho. Estes
# carregam uma EXPRESSÃO, e expressão vive em meia dúzia de pixels de cara: de
# corpo inteiro a 96px a cabeça tem 13px e o olho tem 2, e a essa escala as
# nove imagens deste bloco seriam a mesma imagem. Cortado no peito, a cabeça
# fica com 44px e o olho com 5 — que é onde a diferença entre uma boca reta e
# uma boca descontente passa a existir.
#
# ⚠️ E O GDD DESCREVE COMO CADA UM FALA, NUNCA COMO CADA UM É. As fichas
# (`gdd/sistemas/npcs.md`) e o guia de voz dão tom, maneirismo e papel; não há
# uma linha sobre aparência de nenhum dos três. Logo a cara é DECISÃO desta
# passagem, e está escrita de maneira a poder ser mudada barato: o que
# distingue cada personagem são três ou quatro peças nomeadas e uma cor de
# pele que sai da paleta — trocar qualquer delas é uma linha e um render de
# três segundos. Ver `docs/decisoes/020`.
#
# O QUE SEPARA OS TRÊS A 96px É A CABEÇA, e por isso cada um tem uma silhueta
# de topo diferente: o coque e os óculos da Dona Cida, o boné de aba do
# Arlindo, a careca grisalha e a gravata do Sr. Ribeiro. Três chapéus seriam
# três etiquetas — é a armadilha dos quatro camiões pintados de quatro cores,
# escrita lá em cima.

# As medidas voltam a estar em PIXELS DE DESENHO, pela razão que o
# `trabalhador_retrato` explica: depois da rotação de 45° a largura, a altura e
# a profundidade andam em três fatores diferentes, e escrever tudo em pixels
# tira-os da frente.
_LG, _PF = 42.426, 21.213

# ⚠️ ESTES DOIS NÚMEROS SÃO MEDIDOS NO PNG, NÃO ESCOLHIDOS. `K` enche o quadro
# (a mesma armadilha do retrato do trabalhador: um `TextureRect` em
# `KEEP_ASPECT_CENTERED` escala o quadro INTEIRO, transparência incluída, e um
# busto pequeno no quadro sai minúsculo no cartão) e `MEIO` centra-o. O valor
# saiu de renderizar e medir a caixa opaca do PNG.
#
# ⚠️ E A ALAVANCA B NÃO OS TOCA, apesar de o comentário acima falar de pixel.
# Os dois entram na conta ANTES do `z()`, logo estão em pixels de DESENHO e
# viram unidades de mundo: o que eles decidem é a fração do quadro que o busto
# ocupa, e essa é a mesma a 512 e a 768 porque o `ortho_scale` não se mexeu
# (`docs/decisoes/029`). Medido: o busto ocupava 338 x 479 de 512 e passou a
# ocupar 507 x 690 de 768 — as mesmas proporções.
#
# ⚠️ E A LINHA QUE DIZIA "ver o bloco `_f6_retratos` do teste de fumaça, que
# tranca as duas coisas" NÃO ERA VERDADE: o bloco chama-se `_f7_retratos` e faz
# quatro perguntas de TABELA (toda fala tem cara, toda cara tem arquivo, toda
# cara é usada, toda fala chega ao jogo) — nenhuma delas mede a caixa opaca.
# Ninguém tranca estes dois números; quem os julga é a folha de contato.
_K = 1.68
_MEIO = 285.0

_lg = lambda px: px * _K / _LG                    # noqa: E731 — largura
_pf = lambda px: px * _K / _PF                    # noqa: E731 — profundidade
_alt = lambda px: z(px * _K)                      # noqa: E731 — altura relativa
_niv = lambda px: z(px * _K - _MEIO)              # noqa: E731 — altura absoluta

# O busto, em pixels de desenho. A cabeça vale 192 dos ~316 de altura — 61%,
# contra os 23% de um corpo inteiro, e é a proporção que faz isto ser um
# retrato em vez de um boneco pequeno.
#
# ⚠️ E O OMBRO TEM DE SER MUITO MAIS LARGO DO QUE A CABEÇA. A segunda versão
# deu-lhe 178 contra os 150 da cabeça — dezoito por cento —, e o que saiu foi
# uma cabeça pousada num caixote, sem pescoço à vista e sem nada que se lesse
# como ombro. Num busto de verdade o ombro vale duas cabeças e meia; aqui vale
# duas, e é o que faz a silhueta ter um V em cima em vez de dois retângulos
# empilhados.
#
# ⚠️ E A PROFUNDIDADE É MAGRA DE PROPÓSITO. Nesta câmera o fundo de uma caixa
# projeta-se para CIMA — a quina de trás sobe meia profundidade acima do topo.
# A primeira versão tinha a cabeça com 96 de fundo e o cabelo com 104, e o que
# saiu foi um capacete de cabelo a comer o quadro todo com a cara lá em baixo:
# 84px de rosto num PNG de 406, que a 96px no cartão dão 16. Cortar o fundo
# não achata nada nesta projeção — tira TELHADO, que é o que estava a roubar
# o espaço da cara.
# ⚠️ O OMBRO COMEÇA EM 20 E NÃO EM ZERO, e é o CORTE do busto. Baixá-lo até
# ao fundo dava um terço da imagem de peito liso — a versão anterior tinha o
# peito a valer mais pixels do que a cara, que é o contrário do que um retrato
# é para. Cortar mais alto não muda proporção nenhuma da pessoa: muda o
# enquadramento, que é o que se faz numa fotografia.
_OMBRO_Z = (2.0, 80.0)
_OMBRO_LARG, _OMBRO_FUNDO = 300.0, 78.0
_PESCOCO_Z = (70.0, 126.0)
_CABECA_Z = (126.0, 300.0)
_CABECA_LARG, _CABECA_FUNDO = 148.0, 74.0


# Onde o maxilar acaba e o crânio começa. A cabeça é DUAS peças por causa
# disto: uma cabeça de uma peça só é um tijolo, e foi a primeira queixa do
# Bruno sobre estes retratos — *"faltam detalhes e está muito quadrado"*.
_CABECA_MAXILAR = 202.0


def _contorno_oitavado(larg, fundo, corte):
    """Um retângulo com as quatro quinas cortadas.

    ⚠️ É O QUE TIRA O TIJOLO, e é a única forma de curva que este kit tem.
    Chanfro de modificador (`chanfrar`, 0,020) arredonda 1,7px numa peça de
    207 — serve para a aresta apanhar luz e não muda silhueta nenhuma. O que
    muda silhueta é cortar a quina na GEOMETRIA, e a esta escala 20px de corte
    numa cabeça de 140 leem-se como maçã do rosto.
    """
    lx, fy = _lg(larg) / 2.0, _pf(fundo) / 2.0
    cx, cy = _lg(corte), _pf(corte)
    return [(-lx + cx, -fy), (lx - cx, -fy), (lx, -fy + cy), (lx, fy - cy),
            (lx - cx, fy), (-lx + cx, fy), (-lx, fy - cy), (-lx, -fy + cy)]


def _cabeca_plano():
    """Centro e tamanho da cabeça, como `na_face` os quer.

    ⚠️ CONTINUA A SER A CAIXA e não o octógono, de propósito: a face `-y` da
    peça oitavada está exatamente onde estaria a da caixa — o corte come as
    QUINAS, não o meio. O que a cara tem de respeitar é a largura da parte
    plana (±(larg/2 − corte)), e é por isso que os olhos vivem em ±32 e não
    em ±34: a 34 com 30 de largura a placa passava por cima do bisel e saía
    uma orelha de tinta escura.
    """
    centro = (0.0, 0.0, _niv((_CABECA_Z[0] + _CABECA_Z[1]) / 2.0))
    tam = (_lg(_CABECA_LARG), _pf(_CABECA_FUNDO),
           _alt(_CABECA_Z[1] - _CABECA_Z[0]))
    return centro, tam


def _placa(nome, u, v, larg, alt_px, mat, inclina=0.0, fora=0.0):
    """Uma placa na face `-y` da cabeça — o único sítio onde a cara cabe.

    `inclina` gira a placa DENTRO da face, em torno do eixo Y do mundo, que é
    a normal desta face antes de o busto rodar para a câmera. Tem de ser aqui
    e não depois: `_girar_para_a_camera` soma 45° ao Z, e o Godot compõe a
    Euler XYZ como Rz·Ry·Rx — a inclinação da sobrancelha acontece primeiro, o
    giro para a câmera a seguir, que é a ordem certa. Ao contrário, a
    sobrancelha sairia torta no eixo errado e ninguém saberia porquê.
    """
    centro, tam = _cabeca_plano()
    o = na_face(nome, "-y", centro, tam, _lg(u), _alt(v),
                _lg(larg), _alt(alt_px), 0.02, mat, fora)
    if inclina:
        o.rotation_euler.y = math.radians(inclina)
    return o


# AS TRÊS ALAVANCAS DA EXPRESSÃO, e não um desenho por emoção. A esta escala o
# que existe é BOCA, SOBRANCELHA e OLHO: nariz não cabe (o trabalhador também
# não tem) e ruga é ruído. Nove expressões saem de combinar três alavancas, o
# que também é o que impede a décima de ser um desenho à parte.
# A altura a que a cabeça gira. É o meio do pescoço e não a base do crânio:
# sobre a base, um roll de 6° abre uma fresta de pele entre a cabeça e o
# pescoço; sobre o meio do pescoço o movimento reparte-se e a fresta fecha.
_PIVO_CABECA = 104.0


def _pousar_cabeca(pecas, pose):
    """Roda a cabeça inteira sobre o pescoço: roll, pitch e yaw, em graus.

    ⚠️ A ORDEM IMPORTA, e é aqui que se paga se ela estiver trocada. Isto corre
    ANTES do `_girar_para_a_camera`, que soma 45° ao Z de cada peça — e somar
    45 ao Z é, na ordem Euler XYZ do Godot e do Blender, exatamente
    pré-multiplicar por Rz(45°), porque o Z é o fator de FORA. Logo a pose
    acontece no espaço do busto, de frente, e a câmera vem depois; ao
    contrário, a cabeça inclinar-se-ia num eixo diagonal que não é nenhum dos
    três que se pediram.

    A rotação é sobre um PIVÔ, e não sobre a origem de cada peça: rodar cada
    caixa sobre o próprio centro desmontaria a cabeça, que é a mesma armadilha
    que o `_girar_para_a_camera` documenta ao lado.
    """
    roll, pitch, yaw = pose
    if roll == 0.0 and pitch == 0.0 and yaw == 0.0:
        return
    pivo = Vector((0.0, 0.0, _niv(_PIVO_CABECA)))
    giro = Euler((math.radians(pitch), math.radians(roll),
                  math.radians(yaw)), "XYZ").to_matrix().to_4x4()
    mover = Matrix.Translation(pivo) @ giro @ Matrix.Translation(-pivo)
    for o in pecas:
        o.matrix_world = mover @ o.matrix_world


# AS CINCO ALAVANCAS DA EXPRESSÃO, e não um desenho por emoção. Três são da
# CARA — boca, sobrancelha e olho —, e duas são do que a cara não consegue
# fazer sozinha a este tamanho:
#
# ⚠️ A POSE É A ALAVANCA MAIS FORTE DAS CINCO, e foi a última a entrar. Com as
# nove imagens na mesma pose, o que muda entre elas são seis pixels de boca e
# quatro de sobrancelha; inclinar a cabeça muda a SILHUETA inteira, que é o que
# se lê primeiro e o que sobrevive a qualquer tamanho. Uma cabeça de lado lê
# como interesse antes de o olho chegar à boca, e uma de queixo em baixo lê
# como peso. É a mesma lição da silhueta dos props, aplicada a uma pessoa.
#
# ⚠️ E O OLHAR NÃO É A CARA: é PARA ONDE ela olha. A pupila é uma placa dentro
# da esclera, e movê-la três pixels muda quem está a ser olhado — o Arlindo
# contrariado desvia os olhos, a Dona Cida preocupada baixa-os. Custa um
# deslocamento e vale uma expressão inteira.
#
# `pose` é (roll, pitch, yaw) em graus: inclinar a cabeça para o ombro, baixar
# ou levantar o queixo, virar para o lado. Ângulos pequenos — acima de uns 10°
# o pescoço abre uma fresta, porque a cabeça roda sobre um pivô e não sobre uma
# rótula.
_CARAS = {
    # Dona Cida — pragmática, brava, leal. O tom dela no boletim tem quatro
    # entradas e três caras: o "primeira semana no vermelho" e o "de novo"
    # pedem a mesma preocupação.
    ("cida", "seria"): dict(
        boca="reta", cenho="neutra", olho="aberto", olhar="frente",
        pose=(0.0, 0.0, 0.0)),
    ("cida", "preocupada"): dict(
        boca="descontente", cenho="franzida", olho="aberto", olhar="baixo",
        pose=(-3.0, 5.0, -4.0)),
    ("cida", "contente"): dict(
        boca="sorriso", cenho="erguida", olho="aberto", olhar="frente",
        pose=(6.0, -3.0, 0.0)),
    # Arlindo — "sempre sorrindo quando ataca", diz o guia de voz. Por isso o
    # sorriso é o estado NORMAL dele e não a recompensa: o que muda quando a
    # negociação aperta é o sorriso SAIR.
    ("arlindo", "sorriso"): dict(
        boca="sorriso", cenho="erguida", olho="aberto", olhar="frente",
        pose=(4.0, -2.0, 6.0)),
    # Queixo em baixo e olhos por baixo da aba: é assim que se olha alguém
    # quando a conversa deixou de ser simpática.
    ("arlindo", "pressao"): dict(
        boca="reta", cenho="franzida", olho="cerrado", olhar="frente",
        pose=(0.0, 6.0, 0.0)),
    ("arlindo", "contrariado"): dict(
        boca="descontente", cenho="torta", olho="aberto", olhar="lado",
        pose=(-2.0, 1.0, -9.0)),
    # Sr. Ribeiro — "quando bravo fica MAIS educado, não menos". A cara grave
    # dele não é uma cara zangada: é a cordial com a boca em baixo e os olhos
    # cerrados, que é o que a educação faz com a contrariedade.
    ("ribeiro", "cordial"): dict(
        boca="sorriso_curto", cenho="neutra", olho="aberto", olhar="frente",
        pose=(3.0, -2.0, 3.0)),
    ("ribeiro", "formal"): dict(
        boca="reta", cenho="neutra", olho="aberto", olhar="frente",
        pose=(0.0, 0.0, 0.0)),
    ("ribeiro", "grave"): dict(
        boca="descontente", cenho="franzida", olho="cerrado", olhar="frente",
        pose=(0.0, 5.0, 0.0)),
}

# Quais expressões cada personagem tem. É esta tabela que o gerador percorre —
# e é dela que o `Retratos.gd` do jogo tem de ser o espelho, o que o bloco F6
# do teste de fumaça confere contra o DISCO e não contra ela.
RETRATOS = {
    "cida": ("seria", "preocupada", "contente"),
    "arlindo": ("sorriso", "pressao", "contrariado"),
    "ribeiro": ("cordial", "formal", "grave"),
}


def _olhos(M, cara, escuro):
    """Dois olhos com BRANCO, e não duas manchas escuras.

    Cerrado não é fechado: é a mesma placa com metade da altura e descida
    para o meio do olho. Fechar de todo daria duas linhas, que a 5px lê como
    personagem a dormir.

    ⚠️ E O BRANCO É O DETALHE QUE MAIS RENDE A ESTA ESCALA. Um olho de uma
    placa só é um ponto; com a esclera por baixo e a pupila por cima ele passa
    a ter três pixels de informação — e é a mesma receita do vinco do
    corrugado: quem desenha detalhe neste tamanho é a fronteira de VALOR entre
    duas placas, nunca o relevo, que o antisserrilhado come.
    """
    aberto = cara["olho"] == "aberto"
    alto = 24.0 if aberto else 12.0
    v = 24.0 if aberto else 18.0
    # PARA ONDE ELE OLHA. A pupila anda dentro da esclera: três pixels de
    # desvio mudam quem está a ser olhado, e é o mais barato que há para
    # comprar expressão. Os limites saem do tamanho da esclera (36 x 24) menos
    # o da pupila (15 x alto-7): mais do que isto e a pupila sai do olho.
    desvio = {"frente": (0.0, 0.0), "lado": (8.0, 0.0),
              "baixo": (0.0, -5.0), "cima": (0.0, 4.0)}[cara["olhar"]]
    pecas = []
    for lado, u in (("e", -32.0), ("d", 32.0)):
        pecas.append(_placa("olho_branco_%s" % lado, u, v, 36.0, alto,
                            M["cabine"]))
        # A pupila é mais SALIENTE que a esclera (o `na_face` põe a placa a
        # `esp/2` da face, e esta leva mais um passo): duas placas no mesmo
        # plano dariam o z-buffer a escolher ao acaso, que é o losango preto
        # que este arquivo já registou duas vezes.
        pecas.append(na_face("olho_pupila_%s" % lado, "-y", *_cabeca_plano(),
                             _lg(u + desvio[0]), _alt(v - 1.0 + desvio[1]),
                             _lg(15.0), _alt(alto - 7.0), 0.02, escuro, 0.012))
    return pecas


def _nariz(M, sombra):
    """Duas placas de sombra — a lateral e a base.

    Nariz de GEOMETRIA não existe a esta escala: uma peça saliente mostra as
    faces laterais dela, que aqui têm menos de um pixel, e o resto apanha
    exatamente a mesma luz da cara. Quem desenha nariz num rosto de 44px é a
    SOMBRA que ele faz, que é uma placa um tom abaixo da pele — e é por isso
    que a paleta ganhou um degrau a mais em cada tom de pele.
    """
    return [_placa("nariz_lado", 8.0, -4.0, 16.0, 32.0, sombra),
            _placa("nariz_base", 1.0, -21.0, 28.0, 9.0, sombra)]


def _sobrancelhas(M, cara, escuro):
    """Duas barras acima dos olhos, e a inclinação é a emoção inteira.

    ⚠️ O SINAL INVERTE-SE ENTRE OS DOIS LADOS. Franzido é a ponta de DENTRO
    para baixo nos dois — e "para baixo" é uma rotação num sentido do lado
    esquerdo e no outro do direito. Escrever um ângulo só para os dois dá uma
    sobrancelha franzida e outra erguida, que é a cara `torta` do Arlindo por
    acidente em vez de por decisão.
    """
    estilo = cara["cenho"]
    barras = []
    for lado, u, sinal in (("e", -32.0, 1.0), ("d", 32.0, -1.0)):
        # ⚠️ A ALTURA DELAS É LIMITADA PELA FRANJA, e não pela cara. A 56 a
        # sobrancelha caía debaixo do cabelo da Dona Cida — o cabelo é uma peça
        # 4 unidades mais FUNDA do que a cabeça, portanto passa à frente das
        # placas dela —, e ela ficava com uma expressão a menos sem nada a
        # dizê-lo: a cara mudava só na boca. Aqui em baixo elas cabem entre o
        # olho e a linha do cabelo nos três.
        v, ang = 50.0, 0.0
        if estilo == "franzida":
            ang = 14.0 * sinal
        elif estilo == "erguida":
            v, ang = 56.0, -7.0 * sinal
        elif estilo == "torta":
            # Uma erguida e uma franzida: o cético, e o que sobra a quem
            # perdeu e ainda não admitiu.
            v, ang = (56.0, -10.0) if lado == "e" else (48.0, -14.0)
        barras.append(_placa("sobrancelha_%s" % lado, u, v, 40.0, 12.0,
                             escuro, inclina=ang))
    return barras


def _boca(M, cara, escuro):
    """A boca é uma barra e dois cantos — nunca uma curva.

    Curva não existe neste kit e não faria falta: a 96px o que se lê é para
    onde apontam as PONTAS. Subi-las 6px de desenho (menos de um pixel de
    tela) não chegaria; a diferença que se vê é o canto ficar fora da barra,
    acima ou abaixo dela, que é como o pixel art desenha sorriso desde sempre.
    """
    estilo = cara["boca"]
    if estilo == "reta":
        return [_placa("boca", 0.0, -44.0, 56.0, 12.0, escuro)]
    if estilo == "sorriso":
        pecas = [_placa("boca", 0.0, -50.0, 56.0, 12.0, escuro)]
        pecas += [_placa("boca_canto_%s" % l, u, -38.0, 14.0, 12.0, escuro)
                  for l, u in (("e", -35.0), ("d", 35.0))]
        # OS DENTES, que são o que separa um sorriso de uma boca virada para
        # cima. Uma placa clara de três pixels por cima da barra escura: a
        # mesma receita do branco do olho, e vale o mesmo — a fronteira de
        # valor é que desenha, não o relevo.
        pecas.append(_placa("dentes", 0.0, -44.0, 30.0, 5.0, M["cabine"]))
        return pecas
    if estilo == "sorriso_curto":
        pecas = [_placa("boca", 0.0, -47.0, 38.0, 12.0, escuro)]
        pecas += [_placa("boca_canto_%s" % l, u, -38.0, 12.0, 12.0, escuro)
                  for l, u in (("e", -25.0), ("d", 25.0))]
        return pecas
    pecas = [_placa("boca", 0.0, -40.0, 48.0, 12.0, escuro)]
    pecas += [_placa("boca_canto_%s" % l, u, -51.0, 13.0, 12.0, escuro)
              for l, u in (("e", -30.0), ("d", 30.0))]
    return pecas


def _corpo(M, pele, roupa, sombra):
    """Ombros, pescoço e cabeça — a parte que os três partilham.

    ⚠️ TUDO AQUI É PRISMA OITAVADO E NADA É CAIXA, e a razão está na primeira
    queixa que estes retratos levaram: *"faltam detalhes e está muito
    quadrado"*. A versão anterior era uma cabeça-caixa em cima de um tronco-
    caixa, e a esta escala a silhueta é metade do trabalho — quatro quinas
    vivas dizem "tijolo" antes de qualquer detalhe de cara ser visto.
    Cortá-las custa quatro vértices por peça e nenhum render a mais.
    #
    ⚠️ E O ESTREITAMENTO É SÓ EM `x`, em toda peça deste bloco. Encolher
    também a PROFUNDIDADE recuaria a face da frente, e todas as placas da cara
    e do peito vivem nela: a gravata do Sr. Ribeiro ficaria DENTRO do terno e o
    queixo à frente da boca. É a mesma armadilha que o colete do trabalhador
    registou, e aqui ela apanharia doze peças de uma vez.
    """
    # DUAS LISTAS, e é o que permite a cabeça ter POSE. O que está acima do
    # pescoço roda com ela — cabelo, boné, cara, orelhas —, e o tronco fica
    # quieto; devolver uma lista só obrigaria quem chama a adivinhar onde
    # acaba um e começa o outro, pela ordem, que é o tipo de contrato que se
    # parte em silêncio no dia em que alguém acrescenta uma peça no meio.
    tronco = [prisma("ombros", _contorno_oitavado(_OMBRO_LARG, _OMBRO_FUNDO, 38.0),
                     _niv(_OMBRO_Z[0]), _niv(_OMBRO_Z[1]), (0.86, 1.0), roupa)]
    pecas = tronco

    # O TRAPÉZIO — o degrau entre o ombro e o pescoço. É ele que faz o ombro
    # CAIR para fora em vez de ser uma prateleira: sem ele o topo do tronco é
    # uma linha reta de 300px de ponta a ponta, que é a leitura de caixote.
    pecas.append(prisma("trapezio", _contorno_oitavado(150.0, 68.0, 20.0),
                        _niv(_OMBRO_Z[1] - 6.0), _niv(_OMBRO_Z[1] + 18.0),
                        (1.12, 1.0), roupa))

    pecas.append(prisma("pescoco", _contorno_oitavado(46.0, 42.0, 8.0),
                        _niv(_PESCOCO_Z[0]), _niv(_PESCOCO_Z[1]),
                        (1.0, 1.0), pele))
    # A SOMBRA DO QUEIXO no pescoço. Duas peças de pele encostadas com o mesmo
    # tom fundem-se — é a regra do caixote de `madeira` no tabuado de
    # `madeira`, dentro de um prop em vez de contra o cenário —, e sem ela o
    # pescoço e o maxilar são uma coluna só.
    pecas.append(prisma("pescoco_sombra", _contorno_oitavado(46.0, 42.0, 8.0),
                        _niv(_PESCOCO_Z[1] - 14.0), _niv(_PESCOCO_Z[1]),
                        (1.0, 1.0), sombra))

    # A CABEÇA SÃO DUAS PEÇAS: maxilar que estreita para o queixo, crânio que
    # estreita para o alto. Uma peça só dá o tijolo; duas dão maçã do rosto e
    # queixo com quatro números e sem custo de render.
    pecas = []
    pecas.append(prisma("maxilar",
                        _contorno_oitavado(_CABECA_LARG, _CABECA_FUNDO, 20.0),
                        _niv(_CABECA_Z[0]), _niv(_CABECA_MAXILAR),
                        (0.86, 1.0), pele))
    pecas.append(prisma("cranio",
                        _contorno_oitavado(_CABECA_LARG - 10.0, _CABECA_FUNDO, 18.0),
                        _niv(_CABECA_MAXILAR), _niv(_CABECA_Z[1]),
                        (_CABECA_LARG / (_CABECA_LARG - 10.0), 1.0), pele))

    # AS ORELHAS, que valem dois pixels cada e mudam a silhueta: sem elas o
    # lado da cabeça é uma vertical perfeita de 174px, e vertical perfeita é a
    # assinatura de caixa.
    #
    # ⚠️ ELAS TÊM DE FICAR FORA DO CABELO, com folga. Encostadas ao cabelo dos
    # lados (que os três têm, a ±58) saíam duas faces laterais coplanares e o
    # z-buffer escolhia ao acaso: no primeiro render havia um RETÂNGULO PRETO
    # em cada têmpora. É o losango preto deste arquivo, à escala de uma orelha
    # — e a folga de 4px de pele entre as duas peças é o que o resolve.
    for lado, u in (("e", -1.0), ("d", 1.0)):
        pecas.append(prisma("orelha_%s" % lado, _contorno_oitavado(16.0, 30.0, 5.0),
                            _niv(228.0), _niv(266.0), (1.0, 1.0), pele))
        pecas[-1].location.x += u * _lg(_CABECA_LARG / 2.0 + 2.0)
    return tronco, pecas


def _gola(nome, mat):
    """O que fecha o pescoço: uma CAIXA em volta dele, nunca uma placa no peito.

    ⚠️ E ESTA É A ARMADILHA DA PROFUNDIDADE OUTRA VEZ, do outro lado. A
    primeira versão era uma placa na face da frente do tronco, à altura do
    pescoço — e saiu um retângulo a FLUTUAR dez pixels abaixo dele, com um
    buraco de blusa pelo meio. A conta explica: a placa vive em `y = -fundo/2`
    e o pescoço em `y = 0`, e nesta câmera cada unidade de profundidade vale
    meia unidade de altura na tela. Duas peças à mesma altura no mundo NÃO
    estão à mesma altura na imagem se estiverem a fundos diferentes. Uma caixa
    à volta do pescoço partilha o fundo dele e encosta.
    """
    #
    # ⚠️ E ELA TEM DE SER MAIS FUNDA DO QUE O TRAPÉZIO, senão desaparece. O
    # degrau do ombro tem 68 de fundo e a gola tinha 50: a face da frente do
    # trapézio fica NOVE pixels à frente da dela, e o colarinho branco das três
    # personagens simplesmente não estava no render — não havia erro nenhum a
    # dizê-lo, só um pescoço sem gola. Numa peça que envolve outra, o fundo é
    # que decide quem se vê.
    # ⚠️ E ELA TEM DE CHEGAR AO QUEIXO. Encurtada de 20 para 14 ela descolou:
    # ficou uma barra clara a flutuar no peito, com a pele do pescoço a
    # aparecer por cima. Uma gola que não toca o pescoço não é uma gola.
    return prisma(nome, _contorno_oitavado(86.0, 76.0, 12.0),
                  _niv(_OMBRO_Z[1] - 2.0), _niv(_OMBRO_Z[1] + 20.0),
                  (1.0, 1.0), mat)


# A espessura de uma placa de peito, e o degrau entre duas que se cruzam.
#
# ⚠️ DUAS PLACAS DE PEITO NO MESMO `fora` SÃO COPLANARES, e isto custou um
# defeito que viveu escondido pela resolução. A gravata do Sr. Ribeiro e a
# camisa por baixo dela estavam ambas em `fora = 0`: as duas caixas ocupam a
# MESMA lasca de espaço à frente do peito, o Cycles resolve o empate por
# amostra e o resultado depende de onde cai o centro de cada pixel. A 512 os
# 64 samples misturavam as duas num vermelho plausível; a 768 (`docs/decisoes/
# 029`) o empate passou a desenhar-se — a gravata saiu partida ao meio, escura
# em cima, rosa lavado em baixo, com uma costura horizontal a direito.
#
# É a regra que o `CLAUDE.md` já carrega para os props do mapa — *"peça que
# pousa noutra afunda uma fração ou sobe uma fração; nunca encosta"* —, e o
# que ela acrescenta é que **subir a resolução não cria este defeito: revela-o**.
# Quem reprovou não foi suíte nenhuma: foi o `comparar_props.py` a dizer que
# quatro retratos MUDARAM entre 512 e 768 quando os outros 57 não mudaram.
_PLACA_ESP = 0.02


def _no_peito(nome, u, v, larg, alt_px, mat, camada=0):
    """Uma placa na frente do peito — a camisa e a gravata.

    `camada` empilha em profundidade: 0 é rente ao peito, 1 fica uma espessura
    à frente, e assim por diante. Duas peças que se CRUZAM levam camadas
    diferentes; duas que não se tocam podem partilhar a mesma.
    """
    centro = (0.0, 0.0, _niv((_OMBRO_Z[0] + _OMBRO_Z[1]) / 2.0))
    tam = (_lg(_OMBRO_LARG), _pf(_OMBRO_FUNDO),
           _alt(_OMBRO_Z[1] - _OMBRO_Z[0]))
    return na_face(nome, "-y", centro, tam, _lg(u), _alt(v),
                   _lg(larg), _alt(alt_px), _PLACA_ESP, mat,
                   _PLACA_ESP * camada)


def _cida(M, cara):
    """Cabelo preso, coque e óculos — e é o coque que a distingue de longe.

    O coque fica ATRÁS E ACIMA de propósito. Atrás sozinho não existiria: a
    câmera vê as faces `+x` e `-y`, e o que está em `+y` puro fica escondido
    pela própria cabeça. Acima da linha do cabelo ele passa a ser SILHUETA, que
    é o que sobrevive a 96px.
    """
    escuro = M["vao"]
    tronco, pecas = _corpo(M, M["pele_escura"], M["casco_pesca"],
                           M["pele_sombra"])

    # O CABELO SÃO TRÊS CAMADAS e não um capacete. A versão de uma peça só era
    # uma laje castanha pousada na cabeça: aqui a franja desce sobre a testa,
    # a copa fecha o alto e as bandas descem pelos lados até ao maxilar. É a
    # mesma ideia do `com_saia()` do mapa — massa em cima, aba a descer — e é
    # o que faz cabelo ler como cabelo em vez de chapéu.
    # A COPA É UMA CÚPULA e não uma laje: doze lados a fechar para cima. Uma
    # caixa em cima de uma cabeça oitavada devolvia o tijolo pelo telhado.
    pecas.append(cone("cabelo_copa", (0.0, 0.0, _niv(306.0)),
                      _lg(152.0) / 2.0, _lg(120.0) / 2.0, _alt(26.0), 12,
                      M["madeira_esc"]))
    pecas.append(prisma("cabelo_franja", _contorno_oitavado(150.0, 78.0, 21.0),
                        _niv(286.0), _niv(306.0), (1.0, 1.0), M["madeira"]))
    for lado, u in (("e", -1.0), ("d", 1.0)):
        pecas.append(prisma("cabelo_%s" % lado,
                            _contorno_oitavado(18.0, 76.0, 6.0),
                            _niv(210.0), _niv(296.0), (0.8, 1.0),
                            M["madeira_esc"]))
        pecas[-1].location.x += u * _lg(58.0)
    # ⚠️ O COQUE É UM CILINDRO, e a primeira versão era uma caixa alta: saía
    # uma CHAMINÉ em cima da cabeça. Redondo e baixo lê como cabelo preso;
    # quadrado e alto lê como qualquer outra coisa.
    pecas.append(cone("coque", (0.0, _pf(42.0), _niv(318.0)),
                      _lg(72.0) / 2.0, _lg(62.0) / 2.0, _alt(26.0), 12,
                      M["madeira_esc"]))
    pecas.append(cone("coque_liga", (0.0, _pf(40.0), _niv(304.0)),
                      _lg(50.0) / 2.0, _lg(50.0) / 2.0, _alt(9.0), 12,
                      M["colete"]))

    pecas += _olhos(M, cara, escuro)
    # OS ÓCULOS SÃO MOLDURA E NÃO PLACA, e a diferença é a mesma que o kit já
    # aprendeu na janela: placa cheia fica NA FRENTE do olho e tapa exatamente
    # o que devia emoldurar — a personagem sairia de venda.
    centro, tam = _cabeca_plano()
    for lado, u in (("e", -32.0), ("d", 32.0)):
        pecas += moldura("oculos_%s" % lado, "-y", centro, tam,
                         _lg(u), _alt(24.0), _lg(34.0), _alt(28.0), 0.02,
                         M["metal"], 0.02, _lg(6.0))
    pecas.append(_placa("oculos_ponte", 0.0, 24.0, 14.0, 6.0, M["metal"]))
    pecas += _sobrancelhas(M, cara, escuro)
    pecas += _nariz(M, M["pele_sombra"])
    pecas += _boca(M, cara, escuro)

    # A gola da blusa é clara, e é a única peça clara do busto dela: sem ela o
    # peito é uma chapa verde de um terço da imagem — a mesma queixa do
    # armazém antes da plataforma de carga, à escala de um cartão.
    tronco.append(_gola("gola", M["cabine"]))
    # ⚠️ O BRINCO SAIU QUANDO O LÁPIS ENTROU, e é a regra do acento único: os
    # dois eram dourados, e com dois pontos da mesma cor de acento nenhum deles
    # aponta para coisa nenhuma. Entre um brinco e a ferramenta da profissão
    # dela, fica a ferramenta — é a mesma escolha que pôs o boné no Arlindo e
    # a gravata no Sr. Ribeiro.
    # O LÁPIS ATRÁS DA ORELHA. É contabilista, e é a peça que diz a profissão
    # dela sem uma palavra — o equivalente ao boné do Arlindo e à gravata do
    # Sr. Ribeiro, que ambos tinham e ela não.
    # ⚠️ ELE FICA ACIMA DA ORELHA E NÃO AO LADO DELA. A primeira versão estava
    # exatamente no `x` da orelha (±76) e desapareceu dentro dela — duas peças
    # à mesma distância do eixo, uma dentro da outra, e nada a dizê-lo.
    # ⚠️ ELE FICA FORA DO CABELO, e isso custou duas tentativas: a ±76 estava
    # dentro da orelha e a ±68 dentro da cúpula do cabelo (que tem raio 76).
    # Peça pequena encostada a peça grande do mesmo prop desaparece sem erro
    # nenhum — a régua aqui é o RAIO da peça vizinha, não o tamanho da cabeça.
    lapis = caixa("lapis", (_lg(84.0), _pf(4.0), _niv(272.0)),
                  (_lg(9.0), _pf(9.0), _alt(50.0)), M["capacete"])
    lapis.rotation_euler.y = math.radians(-14.0)
    pecas.append(lapis)
    ponta = caixa("lapis_ponta", (_lg(90.0), _pf(4.0), _niv(246.0)),
                  (_lg(9.0), _pf(9.0), _alt(11.0)), M["madeira_esc"])
    ponta.rotation_euler.y = math.radians(-14.0)
    pecas.append(ponta)
    return tronco, pecas


def _arlindo(M, cara):
    """Boné de capitão, aba sobre os olhos e bigode.

    ⚠️ O BONÉ É NAVY E NÃO BRANCO, e isso foi medido antes de desenhado. O
    boné de capitão de verdade é branco, e `cabine` (#eef2f5) mede **0,016** de
    Weber contra o balão de fala (245,4 de luminância): sobre o cartão claro
    deste jogo um boné branco não é um boné, é um buraco com um contorno. É a
    regra do contraste contra o FUNDO, e aqui o fundo é papel.
    """
    escuro = M["vao"]
    tronco, pecas = _corpo(M, M["pele"], M["vidro"], M["pele_escura"])

    # A COPA DO BONÉ É UM CILINDRO DE DOZE LADOS, não uma caixa: boné é a peça
    # redonda por excelência, e uma caixa em cima da cabeça lê como embalagem.
    pecas.append(cone("bone_copa", (0.0, _pf(6.0), _niv(308.0)),
                      _lg(150.0) / 2.0, _lg(138.0) / 2.0, _alt(30.0), 12,
                      M["casco"]))
    # ⚠️ A ABA TAPAVA AS SOBRANCELHAS, e duas das três caras dele são feitas
    # de sobrancelha. Ela avançava 50 de fundo, e nesta câmera avançar 50 é
    # descer 25 na imagem: a aba caía exactamente na linha das barras. Menos
    # avanço e mais altura resolve sem lhe tirar a sombra sobre os olhos, que
    # é o que faz um boné ler como boné.
    pecas.append(prisma("bone_aba", _contorno_oitavado(154.0, 34.0, 12.0),
                        _niv(304.0), _niv(314.0), (1.0, 1.0), M["metal"]))
    pecas[-1].location.y -= _pf(36.0)
    pecas.append(cone("bone_faixa", (0.0, _pf(6.0), _niv(296.0)),
                      _lg(152.0) / 2.0, _lg(152.0) / 2.0, _alt(12.0), 12,
                      M["capacete"]))
    # O EMBLEMA VAI NA FRENTE DA FAIXA e não pousado na aba: pousado, ele lê
    # como uma peça solta em cima do boné — o que diz CAPITÃO é a marca no
    # centro da testa, não um cubo dourado no ar.
    pecas.append(caixa("emblema", (0.0, -_pf(40.0), _niv(302.0)),
                       (_lg(26.0), _pf(6.0), _alt(18.0)), M["casco"]))

    for lado, u in (("e", -1.0), ("d", 1.0)):
        pecas.append(prisma("costeleta_%s" % lado,
                            _contorno_oitavado(16.0, 76.0, 5.0),
                            _niv(212.0), _niv(292.0), (0.9, 1.0),
                            M["madeira_esc"]))
        pecas[-1].location.x += u * _lg(58.0)

    pecas += _olhos(M, cara, escuro) + _sobrancelhas(M, cara, escuro)
    pecas += _nariz(M, M["pele_escura"])
    # A BARBA POR FAZER, e ela é RECUADA. Uma placa de sombra no maxilar, atrás
    # das da boca: à mesma saliência que elas o z-buffer escolheria ao acaso
    # justamente onde a boca cai, e a barba comeria o bigode.
    pecas.append(_placa("barba", 0.0, -44.0, 84.0, 42.0, M["pele_escura"],
                        0.0, -0.006))
    # O BIGODE É DUAS PEÇAS, com o meio mais alto: um retângulo de ponta a
    # ponta lê como boca fechada e apaga a boca de verdade que vem por baixo.
    # ⚠️ O BIGODE É CLARO, e não da cor da boca. Em `madeira_esc` ele e a boca
    # eram a mesma mancha escura no cartão — duas peças vizinhas do mesmo tom
    # fundem-se, que é a regra do caixote no tabuado, aqui a dois pixels de
    # distância. Um passo mais claro separa-os e o bigode passa a ser peça.
    pecas.append(_placa("bigode", 0.0, -20.0, 26.0, 12.0, M["madeira"]))
    for lado, u in (("e", -22.0), ("d", 22.0)):
        pecas.append(_placa("bigode_%s" % lado, u, -24.0, 20.0, 10.0,
                            M["madeira"]))
    pecas += _boca(M, cara, escuro)

    # Gola aberta, que é o que o guia de voz descreve em roupa: familiaridade
    # como ferramenta. Fechada com gravata seria o Sr. Ribeiro.
    tronco.append(_gola("gola", M["pele"]))
    # A GOLA ABERTA SÃO DUAS PONTAS INCLINADAS, e não dois retângulos: chatos
    # e a direito eles leem como dois BOLSOS colados no peito, que foi o que
    # a primeira versão deu.
    for lado, u, ang in (("e", -30.0, -28.0), ("d", 30.0, 28.0)):
        ponta = _no_peito("colarinho_%s" % lado, u, 12.0, 26.0, 58.0,
                          M["casco"])
        ponta.rotation_euler.y = math.radians(ang)
        tronco.append(ponta)
    return tronco, pecas


def _ribeiro(M, cara):
    """Terno, gravata e a cabeça grisalha — o banco com um rosto simpático."""
    escuro = M["vao"]
    tronco, pecas = _corpo(M, M["pele_clara"], M["casco"], M["pele"])

    # A COROA DE CABELO, e não uma cabeleira. Ele é o mais velho dos três e a
    # careca é metade da silhueta que o distingue: cabelo só dos lados e uma
    # faixa a fechar por cima da nuca, ambas oitavadas para acompanharem o
    # crânio em vez de o encaixotarem.
    for lado, u in (("e", -1.0), ("d", 1.0)):
        pecas.append(prisma("cabelo_%s" % lado,
                            _contorno_oitavado(18.0, 78.0, 6.0),
                            _niv(214.0), _niv(294.0), (0.85, 1.0),
                            M["cabelo_grisalho"]))
        pecas[-1].location.x += u * _lg(58.0)
    # ⚠️ E O TOPO DELE NÃO PODE COINCIDIR COM O TOPO DA CABEÇA. Acabava nos
    # mesmos 300, e duas faces de cima coplanares deram um RETÂNGULO PRETO em
    # cada têmpora — o losango preto deste arquivo, pela terceira vez neste
    # prop. Acaba seis pixels abaixo, e a coroa passa a ler-se como cabelo a
    # rarear em vez de um risco de tinta.
    pecas.append(prisma("cabelo_nuca", _contorno_oitavado(132.0, 20.0, 6.0),
                        _niv(268.0), _niv(304.0), (1.0, 1.0),
                        M["cabelo_grisalho"]))
    pecas[-1].location.y += _pf(32.0)

    pecas += _olhos(M, cara, escuro) + _sobrancelhas(M, cara, escuro)
    pecas += _nariz(M, M["pele"])
    pecas += _boca(M, cara, escuro)
    # A IDADE DELE, em três placas de sombra: os pés-de-galinha e uma ruga na
    # testa. É o mais velho dos três e o único careca; sem isto a careca fazia
    # todo o trabalho sozinha, e careca não é idade — é penteado.
    for lado, u in (("e", -46.0), ("d", 46.0)):
        pecas.append(_placa("pe_de_galinha_%s" % lado, u, 20.0, 14.0, 5.0,
                            M["pele"], 0.0, -0.006))
    pecas.append(_placa("ruga_testa", 0.0, 66.0, 54.0, 5.0, M["pele"],
                        0.0, -0.006))

    # Camisa, gravata e LAPELAS. As lapelas são o que separa um terno de uma
    # camisola de gola alta a esta escala: duas placas inclinadas a abrir um V
    # a partir do colarinho, num navy um passo mais escuro — porque duas peças
    # do mesmo tom encostadas fundem-se, e o peito voltaria a ser uma chapa.
    # ⚠️ AS TRÊS CRUZAM-SE, LOGO SÃO TRÊS CAMADAS. A gravata corre por cima da
    # camisa de v=-21 a v=25 e o nó por cima da gravata de v=17 a v=31: no
    # mesmo `fora` isso são três caixas a disputar a mesma lasca de espaço.
    # Ver o bloco do `_no_peito`.
    tronco.append(_no_peito("camisa", 0.0, 8.0, 56.0, 40.0, M["cabine"]))
    tronco.append(_no_peito("gravata", 0.0, 2.0, 20.0, 46.0, M["faixa"], 1))
    tronco.append(_no_peito("gravata_no", 0.0, 24.0, 24.0, 14.0, M["faixa"], 2))
    for lado, u, ang in (("e", -46.0, -22.0), ("d", 46.0, 22.0)):
        lapela = _no_peito("lapela_%s" % lado, u, 6.0, 34.0, 62.0,
                           M["terno_lapela"])
        lapela.rotation_euler.y = math.radians(ang)
        tronco.append(lapela)
    # O LENÇO DE BOLSO. Três pixels de branco no navy, e é o que faz o terno
    # ler como terno de banco em vez de casaco: peça da FUNÇÃO, como a
    # plataforma de carga do armazém.
    # O lenço cai DENTRO da lapela esquerda (u -72..-52 contra -63..-29), então
    # leva camada própria pela mesma conta da gravata.
    tronco.append(_no_peito("lenco", -62.0, -12.0, 20.0, 10.0, M["cabine"], 1))
    tronco.append(_gola("colarinho", M["cabine"]))
    return tronco, pecas


_PERSONAGENS = {"cida": _cida, "arlindo": _arlindo, "ribeiro": _ribeiro}


def retratos_de_fala(M, est):
    """Os nove bustos — três personagens, três expressões cada.

    Cada um é construído inteiro e no MESMO sítio do mundo: o `exportar()` do
    estúdio esconde tudo e mostra um grupo de cada vez, então nove bustos
    empilhados na origem renderizam-se sem se verem uns aos outros. Partilhar
    o corpo entre as três expressões e trocar só a cara seria mais barato de
    render e impossível de exportar — a unidade de exportação é o GRUPO.
    """
    for personagem, expressoes in RETRATOS.items():
        for expressao in expressoes:
            nome = "retrato_%s_%s" % (personagem, expressao)
            cara = _CARAS[(personagem, expressao)]
            tronco, cabeca = _PERSONAGENS[personagem](M, cara)
            _pousar_cabeca(cabeca, cara["pose"])
            pecas = tronco + cabeca
            for peca in pecas:
                peca.name = "%s_%s" % (nome, peca.name)
            _girar_para_a_camera(pecas)
            origem(nome, tipo="retrato")
            est.registrar(nome, pecas, ancora="retrato")


CATALOGO = (_registrar_caminhoes, empilhadeira, cabeco, poste, pilha_caixotes,
            doca_concreto, pallet, pneus, cone_transito, barreira, bote,
            guincho, trabalhador_retrato, retratos_de_fala)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
