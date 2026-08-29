"""BR Port — demonstração: o MESMO guindaste em dois pipelines.

NÃO entra no jogo e nada em `brport_vs/` depende disto. Existe para responder
com uma imagem, e não com uma opinião, à pergunta "dá para chegar ao nível
daquela arte de referência usando o Blender?".

Renderiza o guindaste duas vezes, na MESMA câmera e na escala de produção:

  atual  — as 5 caixas que o jogo tem hoje, sol duro, material chapado
  rico   — treliça vazada, chanfro, luz de três pontos, desgaste procedural

O veredito e o que se aprendeu estão em docs/BLOCO5_PROMPTS_BLENDER_RICO.md.
A imagem resultante está em docs/img/guindaste_atual_vs_rico.png.

Uso:
    python3 -m venv ~/bpy-venv && ~/bpy-venv/bin/pip install "bpy==4.5.13"
    ~/bpy-venv/bin/python tools/demo_guindaste_rico.py <pasta_de_saida>
"""
import math, sys
import bpy

MEIA_LARG, MEIA_ALT = 30.0, 15.0
ROT_X, ROT_Z = 60.0, 45.0
RESOLUCAO = 512
ESCALA_ORTO = RESOLUCAO / (MEIA_LARG / math.cos(math.radians(45.0)))
ALTURA_PX = (RESOLUCAO / ESCALA_ORTO) * math.cos(math.radians(90.0 - ROT_X))


def _lin(v):
    c = v / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def rgb(hexa):
    h = hexa.lstrip("#")
    return tuple(_lin(int(h[i:i + 2], 16)) for i in (0, 2, 4)) + (1.0,)


def mat_liso(nome, hexa):
    """Como hoje: cor chapada, sem brilho, sem variacao."""
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = rgb(hexa)
    b.inputs["Roughness"].default_value = 1.0
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def mat_gasto(nome, hexa, hexa_gasto, escala=14.0, aspereza=0.62):
    """Mesma cor, mas com desgaste procedural e um pouco de brilho.

    O ruido nao e enfeite: e o que faz duas caixas da mesma cor pararem de
    ler como a mesma caixa. Sem isso um guindaste inteiro laranja e uma
    silhueta laranja, nao um objeto de metal.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    ruido = nt.nodes.new("ShaderNodeTexNoise")
    ruido.inputs["Scale"].default_value = escala
    ruido.inputs["Detail"].default_value = 6.0
    ruido.inputs["Roughness"].default_value = 0.7
    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = 0.42
    rampa.color_ramp.elements[0].color = rgb(hexa)
    rampa.color_ramp.elements[1].position = 0.62
    rampa.color_ramp.elements[1].color = rgb(hexa_gasto)
    nt.links.new(ruido.outputs["Fac"], rampa.inputs["Fac"])
    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = aspereza
    b.inputs["Specular IOR Level"].default_value = 0.35
    b.inputs["Metallic"].default_value = 0.25
    return m


def caixa(nome, centro, meia, mat, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=centro)
    o = bpy.context.active_object
    o.name = nome
    o.scale = meia
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def chanfrar(objs, largura=0.022, segmentos=2):
    """Chanfro em tudo. E a diferenca entre 'caixa' e 'peca fabricada':
    aresta viva nao pega luz, aresta chanfrada pega uma linha de luz e o
    volume aparece sozinho."""
    for o in objs:
        m = o.modifiers.new("chanfro", "BEVEL")
        m.width = largura
        m.segments = segmentos
        m.limit_method = "ANGLE"
        m.angle_limit = math.radians(40)


# ------------------------------------------------------------------ cenas
def camera_e_render(alvo_z=2.2):
    cena = bpy.context.scene
    cena.render.resolution_x = cena.render.resolution_y = RESOLUCAO
    cena.render.film_transparent = True
    bpy.ops.object.camera_add()
    cam = bpy.context.active_object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ESCALA_ORTO
    cam.rotation_euler = (math.radians(ROT_X), 0.0, math.radians(ROT_Z))
    rx, rz = math.radians(ROT_X), math.radians(ROT_Z)
    dx, dy, dz = 0.0, math.sin(rx), -math.cos(rx)
    d = (dx * math.cos(rz) - dy * math.sin(rz),
         dx * math.sin(rz) + dy * math.cos(rz), dz)
    alvo = (0.0, 0.0, alvo_z)
    cam.location = tuple(alvo[i] - d[i] * 30.0 for i in range(3))
    cena.camera = cam
    return cena


def luz_atual(cena):
    """Um sol duro e um mundo cinza — o que o gerador faz hoje."""
    bpy.ops.object.light_add(type="SUN", location=(6, -8, 12))
    sol = bpy.context.active_object
    sol.data.energy = 3.2
    sol.data.angle = 0.0
    sol.rotation_euler = (math.radians(48), 0, math.radians(28))
    cena.world = bpy.data.worlds.new("mundo")
    cena.world.use_nodes = True
    f = cena.world.node_tree.nodes["Background"]
    f.inputs[0].default_value = (0.55, 0.6, 0.68, 1)
    f.inputs[1].default_value = 0.55


def luz_tres_pontos(cena):
    """Chave quente + preenchimento frio + contraluz.

    O sol unico da hoje tres tons por volume e para ai. O preenchimento frio
    tira a sombra de preto morto, e o contraluz poe um fio de luz na quina de
    cima — e esse fio que separa o objeto do fundo sem precisar de contorno.
    """
    bpy.ops.object.light_add(type="SUN", location=(6, -8, 12))
    chave = bpy.context.active_object
    chave.data.energy = 3.4
    chave.data.angle = math.radians(1.6)      # beirada macia, mas nao borrada
    chave.data.color = (1.0, 0.93, 0.82)
    # Elevacao ALTA de proposito. Com os 48 graus do mapa a sombra sai comprida
    # e o sprite fica com um rabo escuro atravessado no piso. Sombra de sprite
    # tem de ser CURTA: serve para grudar a peca no chao, nao para contar a
    # hora do dia.
    chave.rotation_euler = (math.radians(68), 0, math.radians(28))

    bpy.ops.object.light_add(type="AREA", location=(-7, 5, 5))
    ench = bpy.context.active_object
    ench.data.energy = 260.0
    ench.data.size = 12.0
    ench.data.color = (0.62, 0.75, 1.0)
    ench.rotation_euler = (math.radians(58), 0, math.radians(-135))

    bpy.ops.object.light_add(type="AREA", location=(4, 7, 6))
    contra = bpy.context.active_object
    contra.data.energy = 420.0
    contra.data.size = 6.0
    contra.data.color = (1.0, 0.97, 0.88)
    contra.rotation_euler = (math.radians(120), 0, math.radians(35))

    cena.world = bpy.data.worlds.new("mundo")
    cena.world.use_nodes = True
    f = cena.world.node_tree.nodes["Background"]
    f.inputs[0].default_value = (0.60, 0.68, 0.80, 1)
    f.inputs[1].default_value = 0.42


def chao_sombra(cena):
    """Plano que so recebe sombra (alpha em volta). O prop deixa de parecer
    adesivo colado no mapa — hoje nenhum deles projeta nada."""
    bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, 0))
    p = bpy.context.active_object
    p.name = "chao_sombra"
    p.is_shadow_catcher = True
    return p


# --------------------------------------------------------------- guindaste
def guindaste_atual(M):
    """As 5 caixas de hoje."""
    return [
        caixa("base", (0.0, 0.0, 0.18), (0.6, 0.6, 0.36), M["metal"]),
        caixa("mastro", (0.0, 0.0, 1.5), (0.24, 0.24, 2.6), M["metal_claro"]),
        caixa("lanca", (-0.9, 0.0, 2.7), (2.0, 0.18, 0.18), M["metal_claro"]),
        caixa("cabo", (-1.75, 0.0, 2.25), (0.05, 0.05, 0.8), M["metal"]),
        caixa("gancho", (-1.75, 0.0, 1.78), (0.2, 0.2, 0.24), M["amarelo"]),
    ]


def _trelica(nome, p0, p1, lado, mat, montantes=5, esp=0.045):
    """Uma trelica: 4 banzos + diagonais em zigue-zague entre eles.

    E a peca que mais separa a referencia do que temos: guindaste de verdade
    e VAZADO, e o vazado deixa o fundo aparecer no meio da estrutura. Uma
    caixa macica nunca vai ler como guindaste, por melhor que esteja a luz.
    """
    ax, ay, az = p0
    bx, by, bz = p1
    comp = math.dist(p0, p1)
    meio = ((ax + bx) / 2, (ay + by) / 2, (az + bz) / 2)
    # angulo no plano XZ (as trelicas aqui sao verticais ou horizontais)
    ang_y = math.degrees(math.atan2(bx - ax, bz - az))
    pecas = []
    for i, (ox, oy) in enumerate([(-lado, -lado), (-lado, lado),
                                  (lado, -lado), (lado, lado)]):
        pecas.append(caixa(f"{nome}_banzo{i}",
                           (meio[0] + ox * math.cos(math.radians(ang_y)),
                            meio[1] + oy, meio[2] + ox * math.sin(math.radians(ang_y))),
                           (esp, esp, comp / 2), mat, rot=(0, ang_y, 0)))
    passo = comp / montantes
    for i in range(montantes):
        t = (i + 0.5) / montantes
        c = (ax + (bx - ax) * t, ay + (by - ay) * t, az + (bz - az) * t)
        for sinal, oy in ((1, -lado), (-1, lado)):
            pecas.append(caixa(f"{nome}_diag{i}_{oy:.2f}", (c[0], c[1] + oy, c[2]),
                               (esp * 0.8, esp * 0.8, passo * 0.72), mat,
                               rot=(0, ang_y + sinal * 34, 0)))
        pecas.append(caixa(f"{nome}_trav{i}", (c[0], c[1], c[2]),
                           (esp * 0.8, lado, esp * 0.8), mat, rot=(0, ang_y, 0)))
    return pecas


def guindaste_rico(M):
    """Mesmo guindaste, mesma silhueta geral — mas fabricado."""
    pecas = []
    # base com chapa e parafusos
    pecas.append(caixa("base", (0.0, 0.0, 0.16), (0.62, 0.62, 0.16), M["metal"]))
    pecas.append(caixa("base_chapa", (0.0, 0.0, 0.34), (0.50, 0.50, 0.06), M["laranja"]))
    for sx in (-0.42, 0.42):
        for sy in (-0.42, 0.42):
            pecas.append(caixa(f"pe_{sx}_{sy}", (sx, sy, 0.40), (0.07, 0.07, 0.07), M["metal"]))
    # torre vazada
    pecas += _trelica("torre", (0.0, 0.0, 0.42), (0.0, 0.0, 3.05), 0.20, M["laranja"], 6)
    # cabine do operador, encostada na torre
    # A cabine ficava grande, branca e no meio da torre: lia como um bloco
    # solto pousado no guindaste. Menor, na cor da estrutura e com o vidro
    # ocupando quase toda a face, vira cabine.
    pecas.append(caixa("cabine", (0.30, -0.02, 2.42), (0.15, 0.17, 0.17), M["laranja"]))
    pecas.append(caixa("cabine_vidro", (0.33, -0.02, 2.46), (0.13, 0.15, 0.12), M["vidro"]))
    # lanca vazada + contrapeso do outro lado (o que equilibra a silhueta)
    pecas += _trelica("lanca", (-0.15, 0.0, 3.12), (-2.30, 0.0, 3.12), 0.135, M["laranja"], 7)
    pecas += _trelica("contra", (0.15, 0.0, 3.12), (0.95, 0.0, 3.12), 0.115, M["laranja"], 3)
    pecas.append(caixa("contrapeso", (1.02, 0.0, 3.06), (0.16, 0.22, 0.22), M["metal"]))
    # tirantes da ponta ate o topo do mastro
    pecas.append(caixa("tirante_a", (-1.15, 0.0, 3.48), (1.20, 0.02, 0.02), M["metal"], rot=(0, -16, 0)))
    pecas.append(caixa("mastrinho", (0.0, 0.0, 3.45), (0.05, 0.05, 0.35), M["metal"]))
    # carro, cabo e moitao
    pecas.append(caixa("carro", (-1.70, 0.0, 3.00), (0.14, 0.15, 0.09), M["metal"]))
    pecas.append(caixa("cabo", (-1.70, 0.0, 2.40), (0.022, 0.022, 0.55), M["metal"]))
    pecas.append(caixa("moitao", (-1.70, 0.0, 1.80), (0.11, 0.13, 0.13), M["amarelo"]))
    pecas.append(caixa("gancho", (-1.70, 0.0, 1.62), (0.05, 0.05, 0.09), M["metal"]))
    return pecas


def render(caminho, modo):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    cena = camera_e_render()
    cena.render.engine = "CYCLES"
    cena.cycles.device = "CPU"

    if modo == "atual":
        cena.cycles.samples = 24
        M = {k: mat_liso(k, v) for k, v in
             {"metal": "#4a535a", "metal_claro": "#6d7880",
              "amarelo": "#e09a10"}.items()}
        luz_atual(cena)
        pecas = guindaste_atual(M)
    else:
        cena.cycles.samples = 128
        M = {
            "metal": mat_gasto("metal", "#4a535a", "#39424a", 20.0, 0.55),
            "laranja": mat_gasto("laranja", "#d4601f", "#a8481a", 16.0, 0.60),
            "amarelo": mat_gasto("amarelo", "#e09a10", "#b87c0c", 22.0, 0.55),
            "cabine": mat_gasto("cabine", "#eef2f5", "#c9d2d8", 24.0, 0.50),
            "vidro": mat_liso("vidro", "#5f93ad"),
        }
        luz_tres_pontos(cena)
        # NAO se chama chao_sombra() aqui — ver a nota na propria funcao.
        pecas = guindaste_rico(M)
        chanfrar(pecas)

    cena.render.filepath = caminho
    bpy.ops.render.render(write_still=True)
    print("gravado:", caminho, "| pecas:", len(pecas))


if __name__ == "__main__":
    destino = sys.argv[-1]
    render(f"{destino}/guindaste_atual.png", "atual")
    render(f"{destino}/guindaste_rico.png", "rico")
