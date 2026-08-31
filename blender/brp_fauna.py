"""BRP — fauna e vegetação. FASES 6 e parte da 7 do prompt mestre.

**Aviso de escopo.** Fauna está fora do vertical slice (decisão 001). O prompt
pede doze espécies e nove variações de vegetação; aqui estão três peças, e a
escolha é deliberada — cada uma prova um TIPO DE ÂNCORA diferente, que é o que
a FASE 12 precisa validar:

    gaivota         âncora `voo`      — não se cobra apoio no chão
    coqueiro_jovem  âncora `base`     — apoio no chão, com sombra de contato
    arbusto         âncora `base`     — peça baixa, para a regra de apoio
                                        não passar só em peça alta

Produzir as outras nove é repetir o mesmo laço; o que precisava ser provado era
que o contrato aguenta um asset que NÃO toca o chão sem a validação reclamar.

**A gaivota é o asset mais fraco deste lote, e fica registrado.** Três versões:
asas finas (sumiram nesta câmera, que olha de cima), asas grossas com ponta
escura (leram como duas peças soltas), asa clara com bordo de fuga escuro (lê
como um planador cinzento). O arbusto e o coqueiro consertaram-se com material
e silhueta; a ave não.

Não é falta de iteração — é o mesmo teto que o `BLOCO7_PLANO_ARTE_BLENDER.md`
já mediu para o ROSTO do trabalhador: há coisas que primitiva composta não
alcança a 40px. A saída é a mesma que está escrita lá, e não é modelar mais:
é textura pintada num plano, com a silhueta resolvida no desenho em vez de na
geometria. Quem for mexer nisto comece por aí, e não por mais uma caixa.
"""

from brp_studio import caixa, cone, barra, origem, z


def gaivota(M, est):
    """Gaivota em voo. Corpo, cabeça, bico e duas asas em V raso.

    Âncora de VOO: o pacote é explícito — "uma ave voando usa uma origem no
    centro do corpo e não uma origem no chão". Sem essa distinção a validação
    cobraria apoio de uma ave e o pipeline pararia num falso erro.
    """
    # A primeira versão era um borrão branco: corpo branco, asas brancas e
    # finas, tudo do mesmo tom sobre fundo transparente — nada separava a ave
    # dela própria. O que conserta não é detalhe, é CONTRASTE: dorso e pontas
    # escuros, que é aliás como uma gaivota real se lê contra o céu.
    p = []
    p.append(cone("gav_corpo", (0.0, 0.0, z(0.0)), 0.085, 0.030, 0.30, 10,
                  M["cabine"], rot=(0, 90, 0)))
    p.append(caixa("gav_dorso", (-0.02, 0.0, z(1.6)), (0.20, 0.11, 0.035),
                   M["metal"]))
    p.append(cone("gav_cabeca", (0.14, 0.0, z(1.4)), 0.055, 0.045, 0.085, 10,
                  M["cabine"]))
    p.append(cone("gav_bico", (0.20, 0.0, z(1.4)), 0.020, 0.005, 0.07, 8,
                  M["amarelo"], rot=(0, 90, 0)))
    # Asa em DUAS peças por lado, com quebra no cotovelo: é a dobra que faz a
    # silhueta de ave em vez de avião de papel. E mais grossas — a 0,022 elas
    # desapareciam nesta câmera, que olha de cima.
    for i, lado in enumerate((1, -1)):
        # Asa CLARA inteira, com só um fio escuro no bordo de fuga. Na versão
        # anterior a ponta era cinzenta e do tamanho da asa: lia como duas
        # peças soltas em vez de uma asa só. Numa gaivota vista de cima o que
        # há de escuro é uma orla fina, não metade da asa.
        p.append(caixa("gav_asa%d" % i, (0.0, lado * 0.17, z(2.0)),
                       (0.19, 0.34, 0.045), M["cabine"],
                       rot=(lado * 12, 0, lado * -10)))
        p.append(caixa("gav_ponta%d" % i, (-0.09, lado * 0.40, z(3.0)),
                       (0.13, 0.22, 0.040), M["cabine"],
                       rot=(lado * 18, 0, lado * -22)))
        p.append(caixa("gav_fuga%d" % i, (-0.11, lado * 0.26, z(2.4)),
                       (0.035, 0.50, 0.030), M["metal"],
                       rot=(lado * 14, 0, lado * -14)))
    p.append(caixa("gav_cauda", (-0.18, 0.0, z(0.8)), (0.10, 0.14, 0.030),
                   M["metal"]))
    origem("gaivota", tipo="voo")
    est.registrar("gaivota", p, ancora="voo", celulas=(1, 1), habitat="ar",
                  animacoes={"fly": {"frames": 6, "loop": True}},
                  cena_godot="res://scenes/fauna/Gaivota.tscn")


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


CATALOGO = (gaivota, coqueiro_jovem, arbusto)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
