"""BRP — assets do porto. FASE 4 do prompt mestre.

Escolha do que entra, e por quê: o prompt pede navios, edifícios, docas e
guindastes em três estágios, mais "caixas, pallets, contêineres, boias, postes,
cabeços, pneus, cones, barreiras". O jogo JÁ tem navio, píer, guindaste,
armazém, escritório, contêiner, caixote e boia — refazê-los seria trocar arte
que funciona por arte nova sem ganho.

O que falta é a CAUDA: as peças pequenas que ocupam o pátio e que o
`docs/BLOCO7_PLANO_ARTE_BLENDER.md` já tinha medido como o melhor ganho por
custo do projeto ("Etapa 2 — a cauda dos props: barato, muda muito"). O pacote
pede as mesmas peças. Então este catálogo serve as duas listas de uma vez.

Todas as peças usam o kit de `tools/gerar_props_iso.py` e a câmera do contrato.
"""

from brp_studio import (caixa, cone, barra, corrimao, na_face, janela,
                        poste_de_luz, origem, selecao, z)


# Um losango 1x1 do mundo tem 60px de largura na tela. As medidas abaixo estão
# em unidades de mundo na horizontal e em PIXELS DO MAPA na vertical, que é a
# convenção do §2 do contrato espacial.
def _roda(nome, x, y, raio_px, largura, mat):
    """Roda deitada: cilindro com o eixo em Y.

    `cone` nasce em pé, então a rotação de 90° em X é o que a deita. Sem ela a
    roda vira um disco no chão e o veículo parece assente na barriga.
    """
    return cone(nome, (x, y, z(raio_px)), z(raio_px), z(raio_px),
                largura, 16, mat, rot=(90, 0, 0))


def caminhao(M, est):
    """Caminhão de pátio. O jogo já desenha caminhões estacionados no SVG do
    mapa; este é o prop, para quando um caminhão precisar SE MEXER — carga
    chegando, fila no portão — que é a regra do projeto: o que troca de estado
    dentro de uma partida não pode estar assado no fundo."""
    p = []
    RODA, LARG = 5.0, 0.62

    # Chassi. Fica acima do raio da roda, senão o eixo aparece flutuando.
    p.append(caixa("cam_chassi", (0.0, 0.0, z(RODA + 2.0)),
                   (1.48, LARG, z(4.0)), M["metal"]))

    # Cabine à frente (+mx é o lado do mar; o caminhão aponta para lá).
    cab_c, cab_t = (0.50, 0.0, z(RODA + 11.5)), (0.46, LARG, z(15.0))
    p.append(caixa("cam_cabine", cab_c, cab_t, M["azul"]))
    # Só as faces +x e -y são visíveis: envidraçar as outras é render que
    # ninguém vê.
    p += janela("cam_vidro_f", "+x", cab_c, cab_t, 0.0, 0.030, 0.30, 0.16, M,
                peitoril=False)
    p += janela("cam_vidro_l", "-y", cab_c, cab_t, 0.0, 0.030, 0.26, 0.15, M,
                peitoril=False)
    p.append(na_face("cam_grade", "+x", cab_c, cab_t, 0.0, -0.16,
                     0.34, 0.08, 0.03, M["metal_claro"], 0.01))

    # Caçamba atrás, mais alta que a cabine — é o que dá silhueta de caminhão
    # em vez de furgão.
    cac_c, cac_t = (-0.46, 0.0, z(RODA + 13.0)), (0.86, LARG + 0.04, z(18.0))
    p.append(caixa("cam_cacamba", cac_c, cac_t, M["laranja"]))
    p.append(na_face("cam_friso", "-y", cac_c, cac_t, 0.0, 0.0,
                     0.80, 0.03, 0.02, M["metal_claro"], 0.005))
    p.append(caixa("cam_tampa", (-0.90, 0.0, z(RODA + 13.0)),
                   (0.06, LARG, z(17.0)), M["metal"]))

    for i, x in enumerate((0.52, -0.30, -0.72)):
        for j, y in enumerate((LARG / 2, -LARG / 2)):
            p.append(_roda("cam_roda_%d%d" % (i, j), x, y, RODA, 0.12,
                           M["metal"]))

    origem("caminhao")
    est.registrar("caminhao", p, celulas=(2, 1),
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
    """Poste de luz. O kit já tinha `poste_de_luz` e ninguém o usava — está
    anotado como prop gerado e sem uso desde o Bloco 5."""
    p = poste_de_luz("poste", (0.0, 0.0, 0.0), z(46.0), M["metal"],
                     M["luz_poste"])
    origem("poste")
    est.registrar("poste", p, celulas=(1, 1))


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


CATALOGO = (caminhao, empilhadeira, cabeco, poste, pilha_caixotes,
            doca_concreto)


def montar(M, est):
    for f in CATALOGO:
        f(M, est)
