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
    "conteiner":   dict(chassi=1.96, cabine=0.44,
                        eixos=(0.78, -0.18, -0.54, -0.86)),
    "granel":      dict(chassi=1.48, cabine=0.46,
                        eixos=(0.52, -0.30, -0.72)),
    "armazenagem": dict(chassi=1.56, cabine=0.44,
                        eixos=(0.58, -0.28, -0.70)),
    # O mais curto: um frigorífico de peixe é um caminhão de bairro, não uma
    # carreta de porto.
    "pescado":     dict(chassi=1.10, cabine=0.42,
                        eixos=(0.34, -0.36)),
}


# ── AS DUAS TRANSPORTADORAS DE CADA SERVIÇO (27/09, `docs/decisoes/069`) ──
#
# A nota do Bruno: «novas variações devem ser criadas como se tivessem mais de
# uma empresa prestando o mesmo serviço». O escopo dele: DUAS por serviço, e
# três marcas a separá-las — a cor da cabine, a faixa na carroçaria e o modelo
# da cabine. O SERVIÇO continua a ler-se pela carroçaria (o bloco acima); a
# EMPRESA lê-se pelo que está à frente dela.
#
# ⚠️ A EMPRESA 0 É O CAMIÃO DE SEMPRE, cor a cor. É o controle: renderizada, dá
# Δ zero contra o PNG que o jogo já tem.
#
# ⚠️ O BICUDO SÓ NOS TRÊS MÉDIOS, e é o real: o bicudo das estradas
# brasileiras é o caminhão médio — o baú, o basculante e o frigorífico de
# motor à frente —, e a carreta de contêiner é puxada por cavalo cara-chata.
# E há uma razão de medida: o porta-contêiner é o MAIOR camião, e é nele que
# estão medidos o recuo da paragem e a janela da curva (`Main.gd`). O capô
# acrescenta-se À FRENTE do camião de sempre, que não encolhe, e nenhum dos
# três médios com capô passa do comprimento dele (1,40 / 1,78 / 1,86 < 1,96).
#
# ⚠️ E A COR DA CABINE ESCOLHE-SE CONTRA O ASFALTO (#49535b), que é o chão onde
# ela anda: o navy e o verde do kit fundem-se nele pelo valor. As da empresa 1
# são claras ou saturadas, como as da 0.
#
# ⚠️ E CADA EMPRESA 1 TEM A SUA COR. A primeira candidata pôs três cabines
# vermelhas e lia como UMA transportadora a fazer tudo; e o vermelho, contra o
# asfalto, separava-se só pelo matiz (0,06 de Weber no granel). Escolha do
# Bruno: uma cor por serviço, que se veja também pelo valor.
EMPRESAS = {
    "conteiner": (
        dict(modelo="chata", cab="cabine", faixa=None),
        dict(modelo="chata", cab="cab_verde", faixa=None)),
    "granel": (
        dict(modelo="chata", cab="amarelo", faixa="metal_claro"),
        dict(modelo="bicudo", cab="cabine", faixa="cab_coral")),
    "armazenagem": (
        dict(modelo="chata", cab="azul", faixa="laranja"),
        dict(modelo="bicudo", cab="amarelo", faixa="casco")),
    "pescado": (
        dict(modelo="chata", cab="cabine", faixa="refletivo"),
        dict(modelo="bicudo", cab="cab_coral", faixa="amarelo")),
}

# ⚠️ OS 16 PNGs DE CAMIÃO QUE O JOGO TEM SÃO DE ANTES DISTO (27/09). A empresa
# 1 e os detalhes de baixo são a CANDIDATA que está com o Bruno, e ainda não
# foram gerados para `art/props`: regerar hoje um camião pelo `gerar_brp.py`
# troca-o pela candidata sem ninguém ter decidido. Os 32 entram juntos, numa
# passagem própria — a tabela do `Main.gd`, o sorteio, o D35 com o chassi do
# bicudo e a folha (`docs/decisoes/069`, «O que fica para a passagem
# seguinte»).

# O capô do bicudo, antes do `ESCALA_CAMINHAO`: 0,29 de mundo no jogo, ~1,5 m.
# A primeira candidata tinha 0,30 (~1,1 m), e o Bruno pediu-o «mais
# comprido»: o nariz é a parte que diz bicudo. O teto é o do porta-contêiner —
# o baú bicudo fica com 1,56 + 0,40 = 1,96, exatamente o comprimento dele.
CAPO = 0.40


def _vidro(nome, face, centro, tam, u, v, larg, alt, M):
    """O vidro de camião: uma chapa escura só, rente à face.

    A `janela()` do kit é a de CASA — vidro claro recuado, moldura, travessa ao
    meio —, e numa cabine de 15 px lia como janela de casa (o Bruno, 27/09).
    """
    return na_face(nome, face, centro, tam, u, v, larg, alt, 0.03,
                   M["vidro_cab"], 0.004)


def _pecas_do_caminhao(M, eixo, servico, retorno=False, empresa=0):
    """As peças de um caminhão, no eixo pedido ("my" ou "mx") e do serviço dado.

    `retorno` vira a FRENTE para o outro lado: o caminhão que sobe a rua em
    `-my` e atravessa os cotovelos em `-mx`, na faixa de dentro (ver
    `ROTA_RETORNO` no `Main.gd`). Ver o bloco da traseira, no fim.

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
    marca = EMPRESAS[servico][empresa]
    p = []
    RODA, LARG = 5.0, 0.62
    ao_longo_de_y = eixo == "my"

    # `comp` é o eixo do comprimento e `larg` o da largura — trocam entre as
    # duas orientações, e todo o resto sai daqui.
    def dim(comprimento, largura):
        return (largura, comprimento) if ao_longo_de_y else (comprimento, largura)

    # ⚠️ O CAMIÃO DE SEMPRE RECUA MEIO CAPÔ (`recuo`, abaixo), e o capô ocupa o
    # que ele deixou à frente: o chassi cresce centrado na âncora e a traseira
    # fica rente a ele. Só o chassi e o capô se escrevem em `absoluto`; tudo o
    # resto — cabine, carroçaria, rodas, traseira — é o camião de sempre, e
    # anda junto sem saber que há capô.
    def loc(ao_longo, atravessado, alt, absoluto=False):
        if not absoluto:
            ao_longo += recuo
        return ((atravessado, ao_longo, alt) if ao_longo_de_y
                else (ao_longo, atravessado, alt))

    # A FRENTE aponta para onde ele anda: -y quando corre em `my` (que é o
    # `+my` do mapa), +x quando corre em `mx`. Na VOLTA os dois trocam, e a
    # face da frente passa a ser uma das que esta câmera não vê.
    face_lado = "+x" if ao_longo_de_y else "-y"
    sf = -1.0 if ao_longo_de_y else 1.0          # sinal da frente
    if retorno:
        sf = -sf
    # A face visível que o caminhão MOSTRA de ponta: a frente na ida, a
    # traseira no retorno. Só uma das duas pontas está de frente para a câmera.
    face_ponta = "-y" if ao_longo_de_y else "+x"
    face_frente = None if retorno else face_ponta

    bicudo = marca["modelo"] == "bicudo"
    capo = CAPO if bicudo else 0.0
    recuo = -sf * capo / 2.0
    cor_cab = M[marca["cab"]]

    chassi, cab_comp = d["chassi"], d["cabine"]
    chassi_c = loc(0.0, 0.0, z(RODA + 2.0), absoluto=True)
    chassi_t = dim(chassi + capo, LARG) + (z(4.0),)
    p.append(caixa("cam_chassi", chassi_c, chassi_t, M["metal"]))

    # O CONTORNO DE CHÃO de uma peça, em qualquer eixo e sentido, para os
    # prismas — o teto em bisel, o capô e o defletor. `absoluto` como no `loc`.
    def _chao(a, w, absoluto=False):
        return tuple(loc(sf * a, w, 0.0, absoluto)[:2])

    # O mesmo sentido de volta nos dois eixos e nos dois sentidos: o `sf` e a
    # troca de eixo espelham o contorno, e o prisma fecharia as faces viradas
    # para dentro. O kit usa o anti-horário (medido no corpo da gaivota).
    def _prisma(nome, cima, baixo, z0, z1, mat):
        area = sum(baixo[i][0] * baixo[i - 1][1] - baixo[i - 1][0] * baixo[i][1]
                   for i in range(len(baixo)))
        if area > 0:
            baixo, cima = baixo[::-1], cima[::-1]
        return prisma(nome, cima, z0, z1, None, mat, contorno_baixo=baixo)

    # A CABINE encosta na frente do chassi — a posição SAI do comprimento, e
    # não de um número por serviço: quatro chassis diferentes com a cabine
    # escrita à mão dariam quatro chances de uma ficar a pairar no ar.
    #
    # ⚠️ E É UMA CAIXA COM O TETO EM BISEL, não um cubo (27/09, `069`). O cubo de
    # quinas vivas era o que mais a fazia ler como caixa; a caixa vai até
    # `CAB_QUINA` e, por cima, um prisma cujo topo recua 0,08 à frente e 0,03
    # dos lados. O prisma afunda 0,3 px na caixa e a base dele encolhe 0,004:
    # com o mesmo contorno e a mesma altura, a face de baixo dele (virada para
    # baixo, escura) e a de cima da caixa ficavam coplanares — o losango preto.
    CAB_BASE, CAB_QUINA, CAB_TOPO = 4.0, 16.5, 19.0     # px acima da RODA
    cab_c = loc(sf * (chassi / 2.0 - cab_comp / 2.0), 0.0,
                z(RODA + (CAB_BASE + CAB_QUINA) / 2.0))
    cab_t = dim(cab_comp, LARG) + (z(CAB_QUINA - CAB_BASE),)
    p.append(caixa("cam_cabine", cab_c, cab_t, cor_cab))
    tras_cab, frente_cab = chassi / 2.0 - cab_comp, chassi / 2.0
    w0, w1 = LARG / 2.0 - 0.004, LARG / 2.0 - 0.03
    p.append(_prisma("cam_teto",
                     [_chao(tras_cab + 0.02, -w1), _chao(frente_cab - 0.08, -w1),
                      _chao(frente_cab - 0.08, w1), _chao(tras_cab + 0.02, w1)],
                     [_chao(tras_cab + 0.004, -w0), _chao(frente_cab - 0.004, -w0),
                      _chao(frente_cab - 0.004, w0), _chao(tras_cab + 0.004, w0)],
                     z(RODA + CAB_QUINA - 0.3), z(RODA + CAB_TOPO), cor_cab))
    # Os vidros de cabine vivem na caixa, e as alturas deles contam-se do
    # centro DELA — que desceu 1,25 px quando o teto passou a prisma. No bicudo
    # o para-brisa sobe e encurta, para a metade de baixo não ficar atrás do
    # capô. E a grade vai para a ponta do capô, que é onde o motor está.
    if face_frente is not None:
        p.append(_vidro("cam_vidro_f", face_frente, cab_c, cab_t, 0.0,
                        0.095 if bicudo else 0.074, 0.50, 0.13 if bicudo else 0.17,
                        M))
        if not bicudo:
            p.append(na_face("cam_grade", face_frente, cab_c, cab_t, 0.0, -0.126,
                             0.34, 0.08, 0.03, M["metal_claro"], 0.01))
    if bicudo:
        # O CAPÔ vai da frente da cabine à ponta do chassi, afundado 0,02 nela e
        # 0,3 px no chassi — encostado, seriam duas faces coplanares. Mais
        # estreito do que a cabine e baixo: é o DEGRAU entre ele e o para-brisa
        # que diz «bicudo» a 60 px, e ele pede a cor da cabine para ler como a
        # mesma peça de chapa.
        # ⚠️ E ARREDONDADO À FRENTE, como o do 1113: uma caixa até 9,5 px e por
        # cima um prisma que recua 0,08 no bico e 0,03 dos lados — não recua
        # atrás, onde encosta na cabine.
        a0, a1 = chassi / 2.0 - capo / 2.0 - 0.02, chassi / 2.0 + capo / 2.0
        capo_c = loc(sf * (a0 + a1) / 2.0, 0.0, z(RODA + 6.6), absoluto=True)
        capo_t = dim(a1 - a0, LARG - 0.10) + (z(5.8),)
        p.append(caixa("cam_capo", capo_c, capo_t, cor_cab))
        h0, h1 = (LARG - 0.10) / 2.0 - 0.004, (LARG - 0.10) / 2.0 - 0.03
        p.append(_prisma("cam_capo_bico",
                         [_chao(a0, -h1, True), _chao(a1 - 0.08, -h1, True),
                          _chao(a1 - 0.08, h1, True), _chao(a0, h1, True)],
                         [_chao(a0 + 0.004, -h0, True), _chao(a1 - 0.004, -h0, True),
                          _chao(a1 - 0.004, h0, True), _chao(a0 + 0.004, h0, True)],
                         z(RODA + 9.2), z(RODA + 11.0), cor_cab))
        if face_frente is not None:
            p.append(na_face("cam_grade", face_frente, capo_c, capo_t, 0.0, 0.0,
                             0.30, 0.12, 0.03, M["metal_claro"], 0.01))

    # ── OS DETALHES DE CAMIÃO DE VERDADE (27/09, `069`) ─────────────────────
    #
    # O Bruno pediu-os em duas voltas — «mais realista», e depois «outros
    # detalhes para deixar os modelos mais bonitos» — e marcou todos os grupos:
    # retrovisores e para-sol, para-choque e faróis, tanque e para-lamas,
    # defletor; e o escape, a carreta articulada, os cubos das rodas, a borda e
    # os reforços da caçamba, a porta e o degrau, as lanternas do teto. A 60 px
    # de textura cada um é um ou dois pixels — o que os paga é a SILHUETA (o
    # retrovisor, o para-sol e o escape mudam o contorno) e o VALOR (o
    # para-choque e os cubos claros contra o escuro).
    #
    # ⚠️ Cada peça afunda uma fração na vizinha e nenhuma lhe iguala uma face:
    # é a regra das duas faces coplanares, que aqui teria vinte sítios para
    # morder. E nenhuma passa da ponta do chassi em mais de 0,01.
    lado = 1.0 if ao_longo_de_y else -1.0         # o lado que a câmera vê
    ponta = (chassi + capo) / 2.0                  # absoluta
    # O vão entre a cabine e a carga: na carreta é o do cavalo mecânico, que
    # mostra o chassi e a quinta roda (o Bruno: «carreta articulada»); nos
    # outros é a folga que impede a carroçaria de encostar na cabine.
    vao = 0.24 if servico == "conteiner" else 0.06
    # Os retrovisores: dos dois lados, rente à frente da cabine e a meia altura
    # da janela. O de trás também desenha — é contorno.
    for i, su in enumerate((1.0, -1.0)):
        p.append(caixa("cam_retrovisor%d" % i,
                       loc(sf * (frente_cab - 0.05), su * (LARG / 2.0 + 0.02),
                           z(RODA + 14.0)),
                       dim(0.04, 0.05) + (z(5.0),), M["metal"]))
    # O para-sol: a pala escura por cima do para-brisa, a sair da caixa logo
    # abaixo do bisel — mais acima ficaria a pairar à frente do teto recuado.
    p.append(caixa("cam_parasol", loc(sf * (frente_cab + 0.025), 0.0,
                                      z(RODA + 16.8)),
                   dim(0.07, LARG - 0.04) + (z(1.4),), M["metal"]))
    # O para-choque: claro, porque escuro sumia no asfalto; na ponta de tudo.
    p.append(caixa("cam_parachoque_f", loc(sf * (ponta - 0.015), 0.0,
                                          z(RODA + 3.0), absoluto=True),
                   dim(0.05, LARG + 0.02) + (z(2.6),), M["metal_claro"]))
    if face_frente is not None:
        # Os faróis, na face da frente de quem a tem: a cabine na cara-chata, o
        # capô no bicudo — a flanquear a grade, que ocupa o meio.
        if bicudo:
            f_c, f_t, fu, fv = capo_c, capo_t, 0.21, 0.02
        else:
            f_c, f_t, fu, fv = cab_c, cab_t, 0.23, -0.126
        for i, su in enumerate((-1.0, 1.0)):
            p.append(na_face("cam_farol%d" % i, face_frente, f_c, f_t, su * fu,
                             fv, 0.07, 0.05, 0.02, M["luz_poste"], 0.012))
    # O tanque de combustível, no lado que se vê, logo atrás da cabine — e na
    # carreta, atrás do vão, que é onde fica no cavalo.
    p.append(caixa("cam_tanque",
                   loc(sf * (tras_cab - 0.14), lado * (LARG / 2.0 - 0.03),
                       z(RODA + 2.0)),
                   dim(0.22, 0.10) + (z(5.0),), M["metal_claro"]))
    # O escape: o cano vertical atrás da cabine, no lado que se vê, a passar
    # acima do teto. Claro, porque atrás dele há chapa escura e baú branco.
    p.append(cone("cam_escape",
                  loc(sf * (tras_cab - 0.03), lado * (LARG / 2.0 - 0.06),
                      z(RODA + 13.5)),
                  0.03, 0.03, z(19.0), 8, M["metal_claro"]))
    if servico == "conteiner":
        # A quinta roda, no chassi à vista do vão: o disco escuro onde o
        # semirreboque engata.
        p.append(caixa("cam_quinta_roda",
                       loc(sf * (tras_cab - vao / 2.0 - 0.02), 0.0, z(RODA + 4.5)),
                       dim(0.14, LARG - 0.20) + (z(1.0),), M["metal"]))
    # Os para-lamas, pretos, por cima da roda da frente. No bicudo cobrem-na
    # por fora do capô (mais largos do que ele, mais estreitos do que a
    # cabine); na cara-chata são a faixa escura na lateral da cabine, que é
    # onde a roda está.
    # ⚠️ A SEGUNDA CANDIDATA TINHA LAMEIROS, E NENHUMA CÂMERA OS VIA. Um
    # lameiro é uma chapa ATRAVESSADA ao sentido da marcha: de lado, que é
    # como esta câmera vê o camião que desce, só mostra a aresta. O Bruno
    # marcou-os «invisíveis», e a chapa foi para onde a face se vê.
    if bicudo:
        p.append(caixa("cam_paralama",
                       loc(sf * (d["eixos"][0] + capo * 0.8), 0.0, z(RODA + 4.5)),
                       dim(0.30, LARG - 0.02) + (z(2.6),), M["metal"]))
    else:
        p.append(caixa("cam_paralama",
                       loc(sf * d["eixos"][0], lado * (LARG / 2.0 + 0.005),
                           z(RODA + 5.0)),
                       dim(0.30, 0.02) + (z(3.0),), M["metal"]))
    # A PORTA: a janela lateral avança para a frente da cabine, que é onde está
    # a da porta, e o risco da porta fica logo atrás dela; por baixo, o degrau
    # de alumínio. O `u` de uma face lateral corre AO LONGO do camião
    # (`_plano_da_face`), logo `sf * (A - centro)` põe uma peça no ponto A.
    centro_cab = chassi / 2.0 - cab_comp / 2.0
    p.append(_vidro("cam_vidro_l", face_lado, cab_c, cab_t, sf * 0.05, 0.074,
                    0.24, 0.15, M))
    p.append(na_face("cam_porta_risco", face_lado, cab_c, cab_t,
                     sf * (frente_cab - 0.05 - 0.24 - 0.03 - centro_cab), 0.0,
                     0.02, cab_t[2] * 0.80, 0.02, M["metal"], 0.006))
    p.append(na_face("cam_degrau", face_lado, cab_c, cab_t, sf * 0.05,
                     -cab_t[2] / 2.0 + 0.025, 0.14, 0.035, 0.03,
                     M["metal_claro"], 0.006))
    # O DEFLETOR, na carreta e no baú, que são as cargas mais altas do que a
    # cabine: uma RAMPA, do bico do teto até à altura da carga. A segunda
    # candidata tinha-o em dois degraus, e lia como um degrau no teto (o
    # Bruno). É um prisma com a base do tamanho do teto e o topo estreito
    # atrás — a face da frente sai inclinada sem ângulo nenhum escrito à mão.
    # Mais estreito do que o topo do bisel (0,26 contra 0,28 de meia largura),
    # para as faces dos dois não coincidirem.
    topo_teto = CAB_TOPO
    if servico in ("conteiner", "armazenagem"):
        topo = 26.0 if servico == "conteiner" else 30.0
        tras, frente = tras_cab + 0.03, frente_cab - 0.09
        wb, wt = LARG / 2.0 - 0.05, LARG / 2.0 - 0.07
        p.append(_prisma("cam_defletor",
                         [_chao(tras, -wt), _chao(tras + 0.08, -wt),
                          _chao(tras + 0.08, wt), _chao(tras, wt)],
                         [_chao(tras, -wb), _chao(frente, -wb),
                          _chao(frente, wb), _chao(tras, wb)],
                         z(RODA + CAB_TOPO - 0.2), z(RODA + topo), cor_cab))
    # As LANTERNAS DO TETO, as três luzes de cima da cara-chata: no bico do teto,
    # ou no topo do defletor quando há um, que é onde a carreta as leva.
    if not bicudo:
        if servico in ("conteiner", "armazenagem"):
            l_a, l_z = tras + 0.04, topo + 0.2
        else:
            l_a, l_z = frente_cab - 0.12, topo_teto + 0.2
        for i, w in enumerate((-0.12, 0.0, 0.12)):
            p.append(caixa("cam_lanterna_teto%d" % i,
                           loc(sf * l_a, w, z(RODA + l_z)),
                           dim(0.04, 0.05) + (z(0.8),), M["amarelo"]))

    # A carroçaria enche o que sobra do chassi, encostada à traseira. O `vao`
    # para a cabine (0,06; 0,24 na carreta) é o que impede as duas de partilharem uma face
    # — duas faces no mesmo plano dão o losango preto que este projeto já
    # registou três vezes.
    corpo_comp = chassi - cab_comp - vao
    corpo_x = -sf * (chassi / 2.0 - corpo_comp / 2.0)
    def corpo_c(alt_px):
        return loc(corpo_x, 0.0, z(RODA + alt_px))

    if servico == "granel":
        # BASCULANTE, e o granel À VISTA acima da borda. Uma caçamba vazia é
        # uma caixa; o que diz "granel" é o monte, e ele tem de passar da
        # borda, senão fica dentro e a câmera não o vê.
        cac_t = dim(corpo_comp, LARG + 0.04) + (z(16.0),)
        p.append(caixa("cam_cacamba", corpo_c(12.0), cac_t, M["metal"]))
        tras_c, tras_t = corpo_c(12.0), cac_t
        # A FAIXA DA EMPRESA, e não um friso: com 0,03 de altura ela lia como
        # um risco na chapa (o Bruno, na primeira candidata). Com 0,07 é tinta.
        p.append(na_face("cam_friso", face_lado, corpo_c(12.0), cac_t, 0.0, 0.0,
                         corpo_comp * 0.92, 0.07, 0.02, M[marca["faixa"]], 0.005))
        # A BORDA e os REFORÇOS: a chapa lisa lia como uma caixa escura. A borda
        # é mais larga do que a caçamba e passa-lhe 0,2 px do topo; os três
        # reforços saem mais do que a faixa, que atravessam, para as duas não
        # ficarem no mesmo plano.
        p.append(caixa("cam_borda", corpo_c(19.6),
                       dim(corpo_comp + 0.02, LARG + 0.06) + (z(1.2),),
                       M["metal_claro"]))
        for i, k in enumerate((-0.30, 0.0, 0.30)):
            p.append(na_face("cam_reforco%d" % i, face_lado, corpo_c(12.0), cac_t,
                             k * corpo_comp, 0.0, 0.03, z(16.0) * 0.86, 0.02,
                             M["metal_claro"], 0.012))
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
        tras_c, tras_t = bau_c, bau_t
        p.append(na_face("cam_friso", face_lado, bau_c, bau_t, 0.0, -0.06,
                         corpo_comp * 0.94, 0.09, 0.02, M[marca["faixa"]], 0.005))
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
        tras_c, tras_t = bau_c, bau_t
        p.append(na_face("cam_faixa", face_lado, bau_c, bau_t, 0.0, 0.04,
                         corpo_comp * 0.92, 0.07, 0.02, M[marca["faixa"]], 0.005))
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
        prancha_t = dim(corpo_comp, LARG + 0.02) + (z(3.0),)
        p.append(caixa("cam_prancha", corpo_c(6.0), prancha_t, M["metal"]))
        # Na carreta articulada o semirreboque começa depois do vão, e o
        # contêiner enche-o quase todo: 1,24 contra os 1,30 de antes do vão.
        cont_comp = corpo_comp - 0.04
        cont_t = dim(cont_comp, LARG - 0.02) + (z(15.0),)
        cont_c = corpo_c(15.0)
        p.append(caixa("cam_cont", cont_c, cont_t, M["laranja"]))
        tras_c, tras_t = cont_c, cont_t
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
    # No bicudo o eixo da frente vai para debaixo do capô, que é onde o motor
    # o põe; os de trás não se mexem.
    for i, ao_longo in enumerate(d["eixos"]):
        if bicudo and i == 0:
            ao_longo += capo * 0.8
        for j, atravessado in enumerate((LARG / 2, -LARG / 2)):
            xy = loc(sf * ao_longo, atravessado, 0.0)
            p.append(_roda("cam_roda_%d%d" % (i, j), xy[0], xy[1], RODA, 0.12,
                           M["metal"], eixo=eixo_roda))
            # O CUBO: um disco claro no centro, mais largo do que o pneu para
            # sair dele dos dois lados. Sem ele a roda era uma mancha escura.
            p.append(cone("cam_cubo_%d%d" % (i, j), (xy[0], xy[1], z(RODA)),
                          z(2.0), z(2.0), 0.14, 12, M["metal_claro"],
                          rot=(90, 0, 0) if eixo_roda == "y" else (0, 90, 0)))

    # ⚠️ NO RETORNO, A TRASEIRA É A PONTA QUE SE VÊ — e ela nunca tinha sido
    # desenhada, porque na ida ficava na face escondida (ver o cabeçalho). Sem
    # nada nela, o caminhão que sobe a rua mostraria de ponta uma caixa lisa,
    # e o que diz "ele vai no outro sentido" é justamente a traseira: lanternas,
    # para-choque e a porta. O para-brisa da frente fica na face que ninguém
    # vê, e por isso não é desenhado.
    if retorno:
        fp = face_ponta
        # O para-choque corre no chassi, que é a peça mais baixa e a mais
        # recuada de todas.
        p.append(na_face("cam_parachoque", fp, chassi_c, chassi_t, 0.0, 0.0,
                         LARG * 0.94, chassi_t[2] * 0.9, 0.03,
                         M["metal_claro"], 0.004))
        # ⚠️ AS LANTERNAS DO CONTÊINER VÃO NA PRANCHA, e não no contêiner:
        # vermelho sobre laranja não se separa (a regra da cor contra o FUNDO),
        # e sobre a chapa escura da prancha sim.
        if servico == "conteiner":
            luz_c, luz_t = corpo_c(6.0), prancha_t
        else:
            luz_c, luz_t = tras_c, tras_t
        for i, su in enumerate((-1, 1)):
            p.append(na_face("cam_lanterna%d" % i, fp, luz_c, luz_t,
                             su * (LARG / 2 - 0.09), -luz_t[2] / 2 + z(1.6),
                             0.13, z(2.6), 0.02, M["faixa"], 0.006))
        if servico == "granel":
            # A tampa basculante: a dobradiça em cima é o que a separa de uma
            # parede de caçamba.
            p.append(na_face("cam_tampa", fp, tras_c, tras_t, 0.0,
                             tras_t[2] / 2 - z(1.5), LARG * 0.9, z(1.5), 0.02,
                             M["metal_claro"], 0.004))
        else:
            # Porta de duas folhas: a junta ao meio. No contêiner vão também
            # as duas barras de fecho, que são a assinatura da porta dele.
            p.append(na_face("cam_porta", fp, tras_c, tras_t, 0.0, 0.0,
                             0.035, tras_t[2] * 0.86, 0.02, M["metal"], 0.004))
            if servico == "conteiner":
                for i, su in enumerate((-1, 1)):
                    p.append(na_face("cam_fecho%d" % i, fp, tras_c, tras_t,
                                     su * 0.11, 0.0, 0.03, tras_t[2] * 0.8,
                                     0.02, M["laranja_esc"], 0.004))
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
    """Os dezesseis props: quatro serviços × duas orientações × dois sentidos.

    O jogo já sabe que um caminhão que anda em `mx` precisa de outra silhueta;
    o que passou a saber é QUAL das quatro. A tabela do `Main.gd` indexa por
    `<motivo>` e `<motivo>_mx`, e é por isso que os nomes se escrevem assim.
    """
    # ⚠️ E OS OITO DO RETORNO (`_retorno`, `_retorno_mx`): o mesmo construtor, com a
    # frente virada. Um camião que suba a rua não se obtém espelhando o que
    # desce — só as faces `+x` e `-y` se veem, e espelhar mandaria o lado para
    # a face escondida —, por isso é reconstruído, como o de `mx` já era.
    for servico in CAMINHOES:
        for eixo, sufixo, celulas, retorno in (
                ("my", "", (1, 2), False), ("mx", "_mx", (2, 1), False),
                ("my", "_retorno", (1, 2), True), ("mx", "_retorno_mx", (2, 1), True)):
            nome = "caminhao_%s%s" % (servico, sufixo)
            pecas = _pecas_do_caminhao(M, eixo, servico, retorno)
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
# de acordo com o design do jogo" — e ele saiu deste estúdio, de corpo inteiro
# em caixas, em 01/09. Em 24/09 passou ao kit afinado dos retratos, em BUSTO e
# em Standard, por escolha do Bruno e ao fim de seis voltas
# (`art_lab/retratos/trabalhador/`, decisão `058`): o construtor é o
# `trabalhador()` de `brp_retratos.py`, e as armadilhas de cada peça estão lá.
#
# ⚠️ NÃO É O `trabalhador` DO PÍER, e os dois continuam a existir. Aquele tem
# 22px na tela e são cinco caixas de propósito: a esta escala mais peça vira
# ruído. Este vive num cartão de 70px, e é um retrato como os três que falam.
#
# O corpo inteiro deixou quatro lições que continuam a valer para qualquer
# boneco deste estúdio (plano de arte §7): medidas em pixels de desenho e
# nunca misturadas com unidades de mundo; cada peça ganha o seu espaço contra
# as vizinhas, não só cabe; duas faces no mesmo plano não dão erro, dão o
# z-buffer ao acaso; e `cone()` pede RAIO, não largura.
#
# A cara, uma só: o cartão mostra o mesmo retrato em todos os estados (livre,
# parado, escolhido). O meio sorriso curto é a cortesia de quem está pronto a
# trabalhar, e a cabeça inclina 4° — a pose vale mais do que a cara a este
# tamanho.
TRABALHADOR_CARA = dict(boca="sorriso_curto", cenho="neutra", olho="aberto",
                        olhar="frente", pose=(4.0, -2.0, 0.0))

# ⚠️ A CABEÇA A 56% DO QUADRO, e não aos 60% dos três que falam: ele
# identifica-se pelo COLETE, e a 60% a faixa de baixo saía cortada (v4).
TRABALHADOR_CABECA = 0.56


# ── AS VARIAÇÕES DO TRABALHADOR (`059`) ─────────────────────────────────────
#
# 2 sexos × 3 idades × as 5 cores do IBGE: o escopo é do Bruno (`058`), e as 30
# foram aceites na v3 (`art_lab/retratos/trabalhador_variacoes/`). O construtor
# é o mesmo `trabalhador()`, com um `perfil`; as marcas de cada eixo estão lá.
#
# OS PELOS NO ROSTO, em alguns homens: nunca no jovem, que é o de cara lisa, e
# nunca no padrão. Três tipos em sete homens (a v1 tinha dois em cinco, e o
# Bruno pediu «mais variações de barba»).
PELOS_DO_TRABALHADOR = {
    ("adulto", "branca"): "barba", ("adulto", "preta"): "cavanhaque",
    ("adulto", "indigena"): "bigode",
    ("veterano", "branca"): "cavanhaque", ("veterano", "parda"): "bigode",
    ("veterano", "preta"): "barba", ("veterano", "amarela"): "cavanhaque",
}
# O PENTEADO DELA: cinco, cada um três vezes, nenhum repetido na mesma idade.
CABELOS_DA_TRABALHADORA = {
    ("jovem", "branca"): "rabo", ("jovem", "parda"): "crespo", ("jovem", "preta"): "tranca",
    ("jovem", "amarela"): "solto", ("jovem", "indigena"): "curto",
    ("adulto", "branca"): "solto", ("adulto", "parda"): "rabo", ("adulto", "preta"): "crespo",
    ("adulto", "amarela"): "curto", ("adulto", "indigena"): "tranca",
    ("veterano", "branca"): "curto", ("veterano", "parda"): "tranca",
    ("veterano", "preta"): "crespo", ("veterano", "amarela"): "rabo",
    ("veterano", "indigena"): "solto",
}


def _perfis_do_trabalhador():
    """Os 30, pela ordem que o jogo guarda: `(nome do asset, perfil)`.

    ⚠️ O ÍNDICE É O `rosto` DE CADA TRABALHADOR NO SAVE, e o
    `Retratos.TRABALHADORES` do jogo é o espelho desta lista (o fumaça confere
    os nomes contra o disco). O 0 é o padrão — o homem adulto pardo, que é o
    `trabalhador_retrato` de sempre, e sai sem perfil. Acrescentar vai no FIM:
    trocar a ordem troca a cara de quem já está num save.
    """
    lista = [("trabalhador_retrato", None)]
    for sexo in ("homem", "mulher"):
        for idade in ("jovem", "adulto", "veterano"):
            for cor in ("branca", "parda", "preta", "amarela", "indigena"):
                if (sexo, idade, cor) == ("homem", "adulto", "parda"):
                    continue
                homem = sexo == "homem"
                lista.append(("trabalhador_%s_%s_%s" % (sexo, idade, cor), dict(
                    sexo=sexo, idade=idade, cor=cor,
                    pelos=PELOS_DO_TRABALHADOR.get((idade, cor)) if homem else None,
                    cabelo=None if homem else CABELOS_DA_TRABALHADORA[(idade, cor)])))
    return lista


TRABALHADOR_PERFIS = _perfis_do_trabalhador()


def trabalhador_retrato(M, est):
    """O busto do trabalhador do rodapé — os 30 perfis, o padrão primeiro."""
    for nome, perfil in TRABALHADOR_PERFIS:
        _um_trabalhador(M, est, nome, perfil)


def _um_trabalhador(M, est, nome, perfil):
    """Um busto do trabalhador, pelo kit afinado de `brp_retratos.py`.

    O import é aqui dentro pela mesma razão do `retratos_de_fala`: aquele
    módulo importa as medidas deste, e no topo seria um ciclo.
    """
    import brp_retratos
    tronco, cabeca = brp_retratos.trabalhador(M, TRABALHADOR_CARA, perfil)
    pecas = tronco + cabeca
    medir = [o for o in cabeca if o.name.startswith(("cabeca", "cabelo", "capacete"))]
    for peca in pecas:
        peca.name = "%s_%s" % (nome, peca.name)
    brp_retratos.enquadrar(est.cena, nome, pecas, medir, cabeca=TRABALHADOR_CABECA)
    brp_retratos.pousar_cabeca(cabeca, TRABALHADOR_CARA["pose"],
                               brp_retratos.TRABALHADOR.pivo)
    origem(nome, tipo="retrato")
    est.registrar(nome, pecas, ancora="retrato",
                  cena_godot="res://scenes/worker/Worker.tscn",
                  cor=brp_retratos.COR_RETRATO)


# ── OS TRÊS ROSTOS QUE FALAM ────────────────────────────────────────────────
#
# Pedido do Bruno na primeira leitura em voz alta (13/09): *"seria legal
# aparecer o sprite dos personagens, poderia ser o sprite com a reação do
# personagem mais a mensagem"*. Até aqui o jogo tinha sete telas narrativas e
# nenhuma CARA — a Dona Cida, o Arlindo e o Sr. Ribeiro eram texto num balão,
# e quem falava só se sabia pelo título do painel.
#
# ⚠️ SÃO BUSTOS, e o `trabalhador_retrato` foi de corpo inteiro até 24/09. Não
# era gosto: os dois cartões pedem coisas diferentes. Aquele identifica uma
# UNIDADE, e o que o identifica é o capacete e o colete — silhueta, que
# sobrevive a qualquer tamanho; passou a busto por escolha do Bruno, e o busto
# dele é mais ABERTO (a cabeça a 56% do quadro) para o colete caber. Estes
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

# ⚠️ ESTES DOIS NÚMEROS ENQUADRAVAM O KIT DE CAIXAS, e hoje já não enquadram
# nada. Foram medidos no PNG: `K` enchia o quadro (a armadilha do retrato do
# trabalhador — um `TextureRect` em `KEEP_ASPECT_CENTERED` escala o quadro
# INTEIRO, e um busto pequeno sai minúsculo no cartão) e `MEIO` centrava-o. No
# kit afinado quem enquadra é o `enquadrar()` de `brp_retratos.py`, MEDINDO a
# cabeça (`055`), e estes dois ficaram só como a conversão de pixel de desenho
# em mundo que as peças usam. Não se mexem por isso: o enquadramento anula a
# escala, mas o que o kit escreve em unidades de MUNDO — o `fora` das placas,
# o `esp`, o chanfro do estúdio — não se escalaria com eles.
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
    # ⚠️ A CONTENTE DE BOCA ABERTA E SOBRANCELHA ERGUIDA LIA COMO ESPANTO: o
    # Bruno pediu «sorriso mais claro» (24/09) e escolheu, entre três
    # candidatas fotografadas no boletim ótimo, a boca fechada em U com a
    # pálpebra de baixo a subir — o sorriso que chega aos olhos
    # (`art_lab/retratos/cida_contente/v1/`).
    ("cida", "contente"): dict(
        boca="sorriso_fechado", cenho="suave", olho="sorrindo", olhar="frente",
        pose=(6.0, -3.0, 0.0)),
    # Arlindo — "sempre sorrindo quando ataca", diz o guia de voz. Aceito pelo
    # Bruno na foto do jogo em 24/09 (`art_lab/retratos/arlindo/v6/`), depois
    # de as três caras terem lido mal duas voltas: cada uma sai agora da FALA
    # que acompanha, e as rugas de cada expressão vivem no `arlindo()`.
    # - sorriso («Entendo, querido. Mas eu consigo cobrir isso»): o charme — o
    #   sorriso fechado largo, a sobrancelha erguida e os olhos a sorrir;
    # - pressão («Minha oferta não expira. A paciência do senhor, sim.»): ele
    #   sorri quando ataca — o MEIO sorriso frio, os olhos cerrados e o
    #   franzido carregado, com a cabeça baixa;
    # - contrariado («Dessa vez não. Mas tem mais semanas pela frente»): o
    #   último a admitir — o queixo levantado, a cara a fugir e a sobrancelha
    #   torta.
    ("arlindo", "sorriso"): dict(
        boca="sorriso_fechado", cenho="erguida", olho="sorrindo", olhar="frente",
        pose=(6.0, -3.0, 7.0)),
    ("arlindo", "pressao"): dict(
        boca="sorriso_lado", cenho="carregada", olho="cerrado", olhar="frente",
        pose=(2.0, 6.0, 4.0)),
    ("arlindo", "contrariado"): dict(
        boca="descontente", cenho="torta", olho="aberto", olhar="lado",
        pose=(-6.0, -3.0, -14.0)),
    # Sr. Ribeiro — "quando bravo fica MAIS educado, não menos". Aceito pelo
    # Bruno na foto do jogo em 24/09 (`art_lab/retratos/ribeiro/v4/`), com a
    # pose a separar as três — a alavanca mais forte, e na v1 as três liam
    # como a mesma cara:
    # - cordial: o sorriso fechado, os olhos a sorrir, a sobrancelha suave e
    #   a cabeça de lado — a simpatia que torna a dívida difícil de ignorar;
    # - formal: a boca reta e o queixo um pouco levantado — a postura do banco;
    # - grave: TRISTE, e não zangado (o Bruno, na v2) — as pontas de dentro das
    #   sobrancelhas erguidas, o olhar baixo e a cabeça inclinada.
    ("ribeiro", "cordial"): dict(
        boca="sorriso_fechado", cenho="suave", olho="sorrindo", olhar="frente",
        pose=(6.0, -3.0, 5.0)),
    ("ribeiro", "formal"): dict(
        boca="reta", cenho="neutra", olho="aberto", olhar="frente",
        pose=(0.0, -3.0, 0.0)),
    ("ribeiro", "grave"): dict(
        boca="descontente", cenho="triste", olho="aberto", olhar="baixo",
        pose=(-4.0, 7.0, -3.0)),
}

# Quais expressões cada personagem tem. É esta tabela que o gerador percorre —
# e é dela que o `Retratos.gd` do jogo tem de ser o espelho, o que o bloco F6
# do teste de fumaça confere contra o DISCO e não contra ela.
RETRATOS = {
    "cida": ("seria", "preocupada", "contente"),
    "arlindo": ("sorriso", "pressao", "contrariado"),
    "ribeiro": ("cordial", "formal", "grave"),
}


def retratos_de_fala(M, est):
    """Os nove bustos — três personagens, três expressões cada.

    Cada um é construído inteiro e no MESMO sítio do mundo: o `exportar()` do
    estúdio esconde tudo e mostra um grupo de cada vez, então nove bustos
    empilhados na origem renderizam-se sem se verem uns aos outros. Partilhar
    o corpo entre as três expressões e trocar só a cara seria mais barato de
    render e impossível de exportar — a unidade de exportação é o GRUPO.

    OS TRÊS SAEM DO KIT AFINADO de `brp_retratos.py` (`docs/decisoes/055` e
    `056`): cada um com a sua cabeça (`Rosto`), o enquadramento MEDIDO pela
    cabeça dele e a cor Standard. O kit de caixas que os fez de 13/09 a 24/09
    (`_corpo()`, uma cabeça e um ombro para os três) saiu com o último deles.
    O import é aqui dentro porque aquele módulo importa as medidas deste
    (`_lg`, `_niv`...), e no topo seria um ciclo.
    """
    import brp_retratos
    for personagem, expressoes in RETRATOS.items():
        rosto, construtor = brp_retratos.KIT[personagem]
        for expressao in expressoes:
            nome = "retrato_%s_%s" % (personagem, expressao)
            cara = _CARAS[(personagem, expressao)]
            tronco, cabeca = construtor(M, cara)
            pecas = tronco + cabeca
            medir = [o for o in cabeca
                     if o.name.startswith(("cabeca", "cabelo", "coque", "bone"))]
            for peca in pecas:
                peca.name = "%s_%s" % (nome, peca.name)
            brp_retratos.enquadrar(est.cena, nome, pecas, medir)
            brp_retratos.pousar_cabeca(cabeca, cara["pose"], rosto.pivo)
            origem(nome, tipo="retrato")
            est.registrar(nome, pecas, ancora="retrato", cor=brp_retratos.COR_RETRATO)


CATALOGO = (_registrar_caminhoes, empilhadeira, cabeco, poste, pilha_caixotes,
            doca_concreto, pallet, pneus, cone_transito, barreira, bote,
            guincho, trabalhador_retrato, retratos_de_fala)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
