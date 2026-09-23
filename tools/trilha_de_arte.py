#!/usr/bin/env python3
"""BR Port — a página do gate A5, montada das capturas da trilha de arte.

Roda DEPOIS de `tools/trilha_de_arte.sh`, sobre a mesma pasta. Deriva o que
mudou em cada ponto, converte para WebP sem perdas as imagens que vão ser
publicadas e emite a página que o Bruno percorre.

⚠️ O QUE MUDOU EM CADA PONTO SAI DO HASH DE CADA PNG, nunca de uma lista à mão.
É a mesma pergunta que o workflow da captura faz a cada PR — `cmp` contra a
base —, esticada pela trilha inteira: um ponto "mexeu" numa imagem quando o
conteúdo dela difere do ponto bom anterior. Uma curadoria à mão diria o que
quem a escreveu ACHA que mudou, que é exactamente o que este gate não pode
aceitar.

⚠️ E A CONVERSÃO NÃO TOCA NUM PIXEL: numa página que existe para se julgar
arte, um otimizador com perdas julgaria por quem olha. O WebP sai `lossless`, e
cada arquivo é DESCODIFICADO de volta e comparado com o PNG antes de entrar em
`pub/` — igual byte a byte nos pixels, ou a ferramenta pára.
⚠️ E FOI PRECISO SAIR DO PNG. A primeira página (14/09) publicava PNG
recomprimido, e com 30 pontos já pesava perto de 50 MB; o teto de uma versão
de artifact é 64 MB e 255 arquivos. Medido em 23/09 nas capturas da trilha, o
WebP sem perdas fica em 57% do PNG. O teto continua a ser conferido no fim.

Uso:  python3 tools/trilha_de_arte.py <pasta-de-saida>
Saída: <pasta>/trilha_arte.html + <pasta>/pub/*.webp, prontos para publicar.
Precisa do `pillow` com WebP (`pip install pillow`).
"""
import hashlib
import html
import json
import os
import subprocess
import sys

from PIL import Image

if len(sys.argv) < 2:
    raise SystemExit("uso: python3 tools/trilha_de_arte.py <pasta-de-saida>")
T = os.path.abspath(sys.argv[1])
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# A ordem em que as imagens interessam a olhar: o jogo primeiro, depois os
# painéis, depois as folhas de contato.
# ⚠️ ESTA TABELA DÁ A LEGENDA, NUNCA A LISTA. Até 23/09 a manchete percorria
# estas chaves, e a bateria tinha crescido de 14 fotos para 31: dezassete
# ficavam fora do "02/09 contra hoje" sem uma palavra. Hoje quem diz que fotos
# existem é a pasta do último ponto, e uma foto sem legenda REPROVA.
LEGENDA = {
    "inicio": "turno zero, porto em ruínas",
    "pesca": "frota de pesca no cais",
    "escolhido": "trabalhador escolhido, com barco à espera",
    "meio": "porto a meio da construção",
    "porto": "porto completo, sete estruturas",
    "docas": "camião encostado ao berço",
    "mensagens": "o histórico da faixa de mensagem",
    "pausa": "menu de pausa sobre o mapa",
    "boletim": "Boletim da Dona Cida",
    "construir": "painel Construir, porto a meio",
    "calendario": "painel do calendário",
    "painel_docas": "painel das docas",
    "reputacao": "painel da reputação",
    "caixa": "painel do caixa",
    "diario": "diário do avô",
    "parcela": "a parcela do Sr. Ribeiro",
    "ribeiro": "o Sr. Ribeiro a receber",
    "ribeiro_pagou": "o Sr. Ribeiro, depois de pago",
    "ribeiro_nao_pagou": "o Sr. Ribeiro, sem o dinheiro",
    "fimfase": "a primeira parcela paga, a narração",
    "balanco": "o balanço de uma partida jogada até ao fim",
    "contraoferta": "a negociação do Arlindo",
    "contraoferta_fim": "a despedida do Arlindo",
    "nomes": "a tela dos nomes",
    "menu": "o menu-celular",
    "icones": "folha de contato dos ícones",
    "frota": "folha de contato dos cascos",
    "camioes": "folha de contato dos camiões",
    "props1": "folha de contato dos props, 1 de 3",
    "props2": "folha de contato dos props, 2 de 3",
    "props3": "folha de contato dos props, 3 de 3",
}
# A ordem de leitura é a da própria tabela acima — duas listas seriam duas
# chances de uma envelhecer sem a outra.
ORDEM = list(LEGENDA)

# O teto de UMA versão de artifact: 255 arquivos (a página é um deles) e 64 MB.
# Passar dele não dá erro aqui — dá uma publicação recusada, depois de tudo
# convertido; a conta faz-se antes.
TETO_ARQUIVOS = 255
TETO_BYTES = 64 * 1000 * 1000


def sha(caminho):
    h = hashlib.sha256()
    with open(caminho, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def titulo(h):
    """O rótulo de cada ponto é o título do próprio pull request, tal e qual.
    Escrever um rótulo à mão seria a armadilha do comentário que diz "lido de
    X" e não lê X."""
    for fmt in ("%b", "%s"):
        saida = subprocess.run(["git", "log", "-1", "--format=" + fmt, h],
                               cwd=REPO, capture_output=True, text=True).stdout
        for linha in saida.splitlines():
            if linha.strip():
                return linha.strip()
    return h


def para_webp(origem, destino):
    """Grava `destino` como WebP sem perdas e confere-o: descodifica de volta e
    exige os mesmos pixels do PNG. Devolve o tamanho gravado."""
    with Image.open(origem) as im:
        im.load()
        tmp = destino + ".tmp"
        im.save(tmp, "WEBP", lossless=True, quality=100, method=6)
        with Image.open(tmp) as volta:
            volta.load()
            igual = (volta.size == im.size and
                     volta.convert(im.mode).tobytes() == im.tobytes())
    if not igual:
        os.remove(tmp)
        raise SystemExit("o WebP de %s não devolve os mesmos pixels" % origem)
    os.replace(tmp, destino)
    return os.path.getsize(destino)


pontos = []
with open(os.path.join(T, "pontos.txt"), encoding="utf-8") as f:
    for linha in f:
        h, dt, s = linha.rstrip("\n").split("|", 2)
        pontos.append({"sha": h, "data": dt, "assunto": s})

arquivos = {}
for p in pontos:
    dir_ = os.path.join(T, p["sha"])
    p["falhou"] = not os.path.exists(os.path.join(dir_, ".pronto"))
    p["imagens"] = {}
    if p["falhou"]:
        continue
    for f in sorted(os.listdir(dir_)):
        if f.endswith(".png"):
            caminho = os.path.join(dir_, f)
            hh = sha(caminho)
            p["imagens"][f[:-4]] = hh
            arquivos.setdefault(hh, (caminho, f[:-4]))
    p["titulo"] = titulo(p["sha"])

bons = [p for p in pontos if not p["falhou"]]
if not bons:
    raise SystemExit("nenhum ponto capturado em %s — rode o .sh primeiro" % T)
# ⚠️ SÓ A MANCHETE PUBLICA IMAGENS, e por medição. A primeira página (14/09)
# publicava cada passo — 142 imagens para 30 pontos, perto de 50 MB. Em 23/09 a
# trilha tinha 48 pontos e uma bateria de 31 fotos, e em quase todo ponto mudam
# quase todas: o passo a passo passava das 255 imagens de uma versão e, mesmo
# empacotado, dos 64 MB. Os passos ficam como LISTA do que cada merge mexeu,
# derivada dos hashes; as imagens de um passo tiram-se desta pasta.
usados = set()
for i, p in enumerate(bons):
    ant = bons[i - 1]["imagens"] if i > 0 else {}
    mudou = []
    for nome, hh in p["imagens"].items():
        a = ant.get(nome)
        if a != hh:
            mudou.append({"nome": nome, "antes": a, "depois": hh})
    mudou.sort(key=lambda m: ORDEM.index(m["nome"])
               if m["nome"] in ORDEM else 99)
    p["mudou"] = mudou

primeiro, ultimo = bons[0]["imagens"], bons[-1]["imagens"]
sem_legenda = sorted(n for n in ultimo if n not in LEGENDA)
if sem_legenda:
    raise SystemExit("fotos da bateria de hoje sem legenda em LEGENDA: %s"
                     % ", ".join(sem_legenda))
# ⚠️ O "ANTES" DE CADA FOTO É A PRIMEIRA VEZ QUE A BATERIA A TIROU, e não o
# primeiro ponto da trilha. Contra o primeiro ponto, em 23/09, 26 das 31 fotos
# saíam SOZINHAS — não existiam em 02/09 —, e diante de uma foto sem antes a
# pergunta do gate ("melhorou?") não tem resposta. A folha da frota compara-se
# com a folha da frota no dia em que nasceu.
nascimento = {}
for p in bons:
    for nome, hh in p["imagens"].items():
        nascimento.setdefault(nome, (hh, p["data"]))
trilha = []
iguais = []
for nome in sorted(ultimo, key=ORDEM.index):
    antes, desde = nascimento[nome]
    # A foto que não mudou desde que nasceu ENTRA, sozinha: o gate é olhar a
    # arte, e a folha dos camiões nascida hoje está tão por julgar como o
    # porto que mudou trinta vezes. Escondê-la tirava-a do gate calada.
    if antes == ultimo[nome]:
        iguais.append(nome)
        antes = None
    trilha.append({"nome": nome, "antes": antes, "desde": desde,
                   "depois": ultimo[nome]})
    usados.update(x for x in (antes, ultimo[nome]) if x)

# O teto confere-se ANTES de converter: são minutos de WebP para uma
# publicação que seria recusada.
if len(usados) + 1 > TETO_ARQUIVOS:
    raise SystemExit("%d imagens + a página passam do teto de %d arquivos"
                     % (len(usados), TETO_ARQUIVOS))

pub = os.path.join(T, "pub")
os.makedirs(pub, exist_ok=True)
bytes_png = bytes_pub = 0
for h in sorted(usados):
    caminho, nome = arquivos[h]
    destino = os.path.join(pub, "%s-%s.webp" % (nome, h[:8]))
    bytes_png += os.path.getsize(caminho)
    if os.path.exists(destino):
        bytes_pub += os.path.getsize(destino)
    else:
        bytes_pub += para_webp(caminho, destino)
if bytes_pub > TETO_BYTES:
    raise SystemExit("as imagens pesam %.1f MB, e o teto de uma versão é %.0f"
                     % (bytes_pub / 1e6, TETO_BYTES / 1e6))

d = {"pontos": bons, "trilha": trilha,
     "arquivos": {h: arquivos[h][1] for h in usados}}
arq = d["arquivos"]

def dia(data):
    return data[8:] + "/" + data[5:7]


def src(h):
    return "%s-%s.webp" % (arq[h], h[:8])


def quadro(par, ident):
    nome = par["nome"]
    leg = LEGENDA.get(nome, nome)
    vezes = par.get("vezes", 0)
    leg_cab = leg
    if par["antes"]:
        leg_cab += " · antes: " + dia(par["desde"])
    if vezes:
        leg_cab += " · mudou em %d %s" % (vezes, "ponto" if vezes == 1 else
                                          "pontos")
    novo = par["antes"] is None
    chip = ('<span class="chip">igual desde %s</span>' % dia(par["desde"])
            if novo else "")
    if novo:
        imgs = ('<img class="so" loading="lazy" width="720" height="1280" '
                'src="%s" alt="%s">' % (src(par["depois"]), html.escape(leg)))
        botao = ('<button class="abrir" type="button" '
                 'aria-label="Ver no tamanho original">&#9974;</button>')
    else:
        imgs = ('<img class="depois" loading="lazy" width="720" height="1280" '
                'src="%s" alt="%s, depois"><img class="antes" loading="lazy" '
                'width="720" height="1280" src="%s" alt="%s, antes">'
                % (src(par["depois"]), html.escape(leg),
                   src(par["antes"]), html.escape(leg)))
        botao = ('<button class="piscar" type="button" '
                 'aria-label="Alternar antes e depois">'
                 '<span class="estado">depois</span></button>'
                 '<span class="costura"></span>'
                 '<span class="selo esq">antes</span>'
                 '<span class="selo dir">depois</span>'
                 '<button class="abrir" type="button" '
                 'aria-label="Ver no tamanho original">&#9974;</button>')
    return (
        '<figure class="quadro" data-id="%s" data-novo="%s">'
        '<div class="moldura">%s%s</div>'
        '<figcaption><b>%s</b>%s<span class="leg">%s</span></figcaption>'
        '<div class="veredito" role="group" aria-label="Veredito para %s">'
        '<button class="v v-bom" type="button" data-v="bom">Bom</button>'
        '<button class="v v-nao" type="button" data-v="nao">Não</button>'
        '</div><textarea class="nota" rows="2" placeholder="o que está errado"'
        ' hidden></textarea></figure>'
        % (html.escape(ident), "1" if novo else "0", imgs, botao,
           html.escape(nome), chip, html.escape(leg_cab), html.escape(nome)))


# --- manchete -------------------------------------------------------------
# Quantos pontos mexeram em cada foto depois de ela NASCER: o ponto em que
# aparece pela primeira vez tem `antes` vazio e não conta como mudança.
for m in d["trilha"]:
    m["vezes"] = sum(1 for p in bons[1:]
                     for x in p["mudou"] if x["nome"] == m["nome"] and x["antes"])
manchete = "".join(quadro(m, "trilha-" + m["nome"]) for m in d["trilha"])
n_manchete_par = sum(1 for m in d["trilha"] if m["antes"])
n_nasceram_depois = sum(1 for nome in ultimo
                        if nascimento[nome][1] != bons[0]["data"])

# --- passo a passo --------------------------------------------------------
secoes = []
imagens_dos_passos = set()
for i, p in enumerate(d["pontos"]):
    for m in p["mudou"]:
        imagens_dos_passos.update(x for x in (m["antes"], m["depois"]) if x)
    if p["mudou"]:
        corpo = '<p class="fotos">%s</p>' % "".join(
            '<span class="chip%s" title="%s">%s</span>'
            % ("" if m["antes"] else " chip-novo",
               html.escape(LEGENDA.get(m["nome"], m["nome"])),
               html.escape(m["nome"] + ("" if m["antes"] else " · nova")))
            for m in p["mudou"])
    else:
        corpo = '<p class="nada">Nenhuma das fotos mudou.</p>'
    secoes.append(
        '<li class="ponto"><div class="cab">'
        '<span class="data">%s</span>'
        '<h3>%s</h3><code>%s</code></div>%s</li>'
        % (html.escape(dia(p["data"])),
           html.escape(p.get("titulo", "")), html.escape(p["sha"]), corpo))

dados_js = json.dumps({"total": len(d["trilha"])}, ensure_ascii=False)

PAGINA = """<title>Gate A5 do BR Port</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700&family=Barlow:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap">
<style>
:root{
  color-scheme:dark;
  --fundo:#0a141d; --painel:#142840; --painel2:#1c3454; --linha:#24466e;
  --tinta:#d0dff0; --fraca:#8ea6c4; --ambar:#e09a10; --navy:#1c3454;
  --bom:#4aa06e; --nao:#c8553d; --sombra:0 2px 14px rgba(0,0,0,.45);
  --r:3px;
}
@media (prefers-color-scheme: light){
  :root:not([data-theme="dark"]){
    --fundo:#e9eef4; --painel:#ffffff; --painel2:#f4f7fb; --linha:#cfdcec;
    --tinta:#1c3454; --fraca:#5d7186; --sombra:0 1px 8px rgba(28,52,84,.12);
  }
}
:root[data-theme="light"]{
  --fundo:#e9eef4; --painel:#ffffff; --painel2:#f4f7fb; --linha:#cfdcec;
  --tinta:#1c3454; --fraca:#5d7186; --sombra:0 1px 8px rgba(28,52,84,.12);
}
*{box-sizing:border-box}
body{background:var(--fundo); color:var(--tinta);
  font:400 16px/1.55 Barlow,system-ui,-apple-system,"Segoe UI",sans-serif;}
.env{max-width:1240px; margin:0 auto; padding-inline:20px; padding-block:0 64px;}
h1,h2,h3{text-wrap:balance; margin:0; font-family:"Barlow Condensed",Barlow,
  system-ui,sans-serif; font-weight:700; letter-spacing:.01em;}
code,.mono,.data,.medida{font-family:"JetBrains Mono",ui-monospace,
  "SFMono-Regular",Menlo,monospace; font-variant-numeric:tabular-nums;}

/* ---- cabeçalho ---- */
.topo{border-bottom:1px solid var(--linha); background:var(--fundo);}
.topo .env{padding-block:28px 20px;}
.olho{font-family:"Barlow Condensed",sans-serif; font-weight:600;
  text-transform:uppercase; letter-spacing:.16em; font-size:13px;
  color:var(--ambar); margin:0 0 6px;}
h1{font-size:clamp(30px,6vw,46px); line-height:1.02;}
.sub{color:var(--fraca); max-width:62ch; margin:12px 0 0; font-size:15px;}
.medidas{display:flex; flex-wrap:wrap; gap:10px 26px; margin-top:18px;
  padding-top:16px; border-top:1px solid var(--linha);}
.medidas div{display:flex; flex-direction:column; gap:1px;}
.medidas .n{font-size:22px; font-weight:600;}
.medidas .q{font-family:"Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.11em; font-size:11px; color:var(--fraca);}

.barra{position:sticky; top:env(safe-area-inset-top, 0px); z-index:9; background:var(--fundo);
  border-bottom:1px solid var(--linha);}
.barra .env{display:flex; align-items:center; gap:14px; flex-wrap:wrap;
  padding-block:10px;}
.progresso{flex:1 1 180px; min-width:140px;}
.trilho{height:5px; background:var(--linha); border-radius:99px; overflow:hidden;}
.trilho i{display:block; height:100%; width:0; background:var(--ambar);
  transition:width .25s ease;}
.conta{font-size:12px; color:var(--fraca); margin-top:4px; letter-spacing:.02em;}
.alternar{display:flex; gap:0; border:1px solid var(--linha);
  border-radius:var(--r); overflow:hidden;}
.alternar button{background:transparent; color:var(--fraca); border:0;
  font:600 12px/1 "Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.11em; padding:9px 13px; cursor:pointer;}
.alternar button[aria-pressed="true"]{background:var(--ambar); color:var(--navy);}

/* ---- seções ---- */
h2{font-size:clamp(20px,3.4vw,27px); margin-top:52px;}
.intro{color:var(--fraca); max-width:62ch; margin:8px 0 22px; font-size:15px;}
.tira{display:grid; gap:22px; margin-top:16px;
  grid-template-columns:repeat(auto-fill,minmax(300px,1fr));}
.manchete .tira{grid-template-columns:repeat(auto-fill,minmax(340px,1fr));}

/* ABRIR UM QUADRO mostra-o no tamanho em que foi tirado (720 de largura), e
   não esticado para a largura da coluna: ampliar não devolve o que a grelha
   encolheu. O `depois` passa a definir a caixa e o `antes` sobrepõe-se. */
.quadro.grande{grid-column:1/-1;}
.quadro.grande .moldura{aspect-ratio:auto; max-width:720px; height:auto;}
.quadro.grande .moldura img.depois,
.quadro.grande .moldura img.so{position:static; width:100%; height:auto;
  object-fit:contain;}
.abrir{position:absolute; top:8px; right:8px; z-index:2; width:30px;
  height:30px; border:1px solid var(--linha); border-radius:2px;
  background:var(--painel); color:var(--tinta); cursor:pointer;
  font:600 14px/1 "Barlow Condensed",sans-serif; padding:0;}
.abrir:hover{border-color:var(--ambar); color:var(--ambar);}
.abrir:focus-visible{outline:2px solid var(--ambar); outline-offset:2px;}

.quadro{margin:0; display:flex; flex-direction:column; gap:8px;}
.moldura{position:relative; aspect-ratio:9/16; max-width:100%;
  background:var(--painel); border:1px solid var(--linha);
  border-radius:var(--r); overflow:hidden; box-shadow:var(--sombra);}
.moldura img{position:absolute; inset:0; width:100%; height:100%;
  object-fit:cover; display:block;}
.moldura img.antes{opacity:0;}
.quadro.ver-antes .moldura img.antes{opacity:1;}
.piscar{position:absolute; inset:0; width:100%; height:100%; border:0;
  background:transparent; cursor:pointer; padding:0;}
.piscar .estado{position:absolute; left:8px; bottom:8px;
  font:600 11px/1 "Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.13em; color:var(--navy); background:var(--ambar);
  padding:5px 8px; border-radius:2px;}
.quadro.ver-antes .piscar .estado{background:var(--tinta); color:var(--fundo);}
.piscar:focus-visible{outline:2px solid var(--ambar); outline-offset:2px;}

figcaption{display:flex; align-items:baseline; gap:8px; flex-wrap:wrap;
  font-size:14px;}
figcaption b{font-weight:600;}
.leg{color:var(--fraca); font-size:12.5px;}
.chip{font:600 10px/1 "Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.12em; padding:4px 6px; border-radius:2px;
  border:1px solid var(--linha); color:var(--fraca);}
.chip-novo{border-color:var(--ambar); color:var(--ambar);}

.veredito{display:flex; gap:7px;}
.veredito .v{flex:1; background:transparent; color:var(--fraca);
  border:1px solid var(--linha); border-radius:var(--r); cursor:pointer;
  font:600 12px/1 "Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.11em; padding:9px 6px;}
.veredito .v:hover{border-color:var(--fraca); color:var(--tinta);}
.veredito .v[aria-pressed="true"].v-bom{background:var(--bom);
  border-color:var(--bom); color:#fff;}
.veredito .v[aria-pressed="true"].v-nao{background:var(--nao);
  border-color:var(--nao); color:#fff;}
.veredito .v:focus-visible{outline:2px solid var(--ambar); outline-offset:2px;}
.nota{width:100%; background:var(--painel); color:var(--tinta);
  border:1px solid var(--linha); border-radius:var(--r); padding:7px 9px;
  font:400 13px/1.4 Barlow,sans-serif; resize:vertical;}

/* dividido: as duas imagens inteiras, a de trás recortada ao meio. Com
   `object-fit:cover` e meia moldura cada, as duas metades mostravam pedaços
   DIFERENTES da imagem — o recorte mantém a mesma geometria dos dois lados. */
body.lado .moldura img.antes{opacity:1; clip-path:inset(0 50% 0 0);}
body.lado .costura{opacity:1;}
body.lado .selo{opacity:1;}
body.lado .piscar{display:none;}
.costura,.selo{opacity:0; pointer-events:none;}
.costura{position:absolute; top:0; bottom:0; left:50%; width:1px;
  background:var(--ambar);}
.selo{position:absolute; bottom:8px;
  font:600 10px/1 "Barlow Condensed",sans-serif; text-transform:uppercase;
  letter-spacing:.13em; color:var(--navy); background:var(--ambar);
  padding:4px 6px; border-radius:2px;}
.selo.esq{left:8px;} .selo.dir{right:8px;}

.indice{list-style:none; margin:16px 0 0; padding:4px 14px;
  border:1px solid var(--linha); border-radius:var(--r);
  background:var(--painel);}
.ponto{border-top:1px solid var(--linha); padding-block:12px;}
.ponto:first-child{border-top:0;}
.fotos{display:flex; flex-wrap:wrap; gap:6px; margin:8px 0 0;}
.cab{display:flex; align-items:baseline; gap:12px; flex-wrap:wrap;}
.cab h3{font-size:17px; flex:1 1 300px;}
.data{font-size:12px; color:var(--ambar); letter-spacing:.04em;}
.cab code{font-size:11.5px; color:var(--fraca);}
.nada{color:var(--fraca); font-size:14px; margin:10px 0 0;}

.aviso{margin-top:14px; font-size:13px; color:var(--fraca);
  border-left:2px solid var(--ambar); padding-left:12px;}
@media (prefers-reduced-motion: reduce){ *{transition:none!important;} }
</style>

<div class="topo"><div class="env">
  <p class="olho">Trilha de arte · plano v3</p>
  <h1>Gate A5 do BR Port</h1>
  <p class="sub">Cada foto da bateria de __ATE__ contra a primeira vez que foi
  tirada, com o antes e o depois no mesmo sítio. Toque numa imagem para ela piscar
  entre os dois — é assim que a diferença aparece. Em cada quadro, diga
  <b>Bom</b> ou <b>Não</b>; o veredito fica guardado e volta para a próxima
  sessão como fila de trabalho.</p>
  <div class="medidas">
    <div><span class="n medida">__PONTOS__</span><span class="q">pontos da trilha</span></div>
    <div><span class="n medida">__PARES__</span><span class="q">antes/depois</span></div>
    <div><span class="n medida">__NOVOS__</span><span class="q">nasceram na trilha</span></div>
    <div><span class="n medida">720×1280</span><span class="q">semente e passo fixos</span></div>
  </div>
</div></div>

<div class="barra"><div class="env">
  <div class="progresso"><div class="trilho"><i id="trilho"></i></div>
    <p class="conta" id="conta">a carregar os vereditos…</p></div>
  <div class="alternar" role="group" aria-label="Como comparar">
    <button id="m-piscar" type="button" aria-pressed="true">Piscar</button>
    <button id="m-lado" type="button" aria-pressed="false">Dividido</button>
  </div>
</div></div>

<div class="env">
  <section class="manchete">
    <h2>Cada foto, do primeiro dia a __ATE__</h2>
    <p class="intro">Os __N_HOJE__ quadros da bateria de __ATE__, cada um
    contra a primeira vez que a bateria o tirou — __DE__ para os que já
    existiam no primeiro dia em que a captura passou a ser reprodutível, e o
    dia em que nasceu para os outros. __MANCHETE_NOTA__</p>
    <div class="tira">__MANCHETE__</div>
  </section>

  <section>
    <h2>Passo a passo</h2>
    <p class="intro">Cada ponto é um merge que tocou em arte, na ordem em que
    aconteceram, com as fotos que MUDARAM naquele ponto — derivado do conteúdo
    de cada PNG, não escolhido a olho —, e o título é o do próprio pull
    request. Um <b>Não</b> lá em cima procura-se aqui: os merges que mexeram
    naquela foto são os suspeitos. As imagens de cada passo não vêm nesta
    página: são __N_PASSOS__ distintas, e uma página leva no máximo
    __TETO__ arquivos.</p>
    <ol class="indice">__SECOES__</ol>
  </section>

  <p class="aviso">As imagens são função só do código: a bateria roda com
  semente fixa e passo de tempo fixo, e o mapa foi reimportado em cada ponto
  antes de a foto ser tirada. Duas corridas do mesmo commit dão os mesmos
  bytes — o que muda aqui, mudou mesmo.</p>
</div>

<script>
(function(){
  var dados = __DADOS__;
  var corpo = document.body;
  var trilho = document.getElementById("trilho");
  var conta = document.getElementById("conta");
  var quadros = Array.prototype.slice.call(document.querySelectorAll(".quadro"));
  var vereditos = {};
  var escrever = null;

  // piscar
  document.addEventListener("click", function(e){
    var b = e.target.closest ? e.target.closest(".piscar") : null;
    if(!b) return;
    var q = b.closest(".quadro");
    q.classList.toggle("ver-antes");
    b.querySelector(".estado").textContent =
      q.classList.contains("ver-antes") ? "antes" : "depois";
  });

  // abrir no tamanho original
  document.addEventListener("click", function(e){
    var b = e.target.closest ? e.target.closest(".abrir") : null;
    if(!b) return;
    e.stopPropagation();
    b.closest(".quadro").classList.toggle("grande");
  });

  // modo
  function modo(lado){
    corpo.classList.toggle("lado", lado);
    document.getElementById("m-piscar").setAttribute("aria-pressed", !lado);
    document.getElementById("m-lado").setAttribute("aria-pressed", lado);
  }
  document.getElementById("m-piscar").onclick = function(){ modo(false); };
  document.getElementById("m-lado").onclick = function(){ modo(true); };

  function pintar(){
    var n = 0;
    quadros.forEach(function(q){
      var v = vereditos[q.dataset.id];
      if(v && v.veredito) n++;
      q.querySelectorAll(".v").forEach(function(b){
        b.setAttribute("aria-pressed", !!v && v.veredito === b.dataset.v);
      });
      var nota = q.querySelector(".nota");
      nota.hidden = !(v && v.veredito === "nao");
      if(v && typeof v.nota === "string" && document.activeElement !== nota){
        nota.value = v.nota;
      }
    });
    trilho.style.width = (100 * n / dados.total).toFixed(1) + "%";
    conta.textContent = n + " de " + dados.total + " julgados"
      + (escrever ? "" : " · não estão a ser guardados nesta vista");
  }

  function guardar(id, campos){
    var q = quadros.filter(function(x){ return x.dataset.id === id; })[0];
    var atual = vereditos[id] || {};
    var corpo_ = {
      id: id, nome: q ? q.querySelector("figcaption b").textContent : "",
      veredito: atual.veredito || "", nota: atual.nota || "",
      quando: new Date().toISOString()
    };
    Object.keys(campos).forEach(function(k){ corpo_[k] = campos[k]; });
    vereditos[id] = corpo_;
    pintar();
    if(escrever) escrever(id, corpo_);
  }

  document.addEventListener("click", function(e){
    var b = e.target.closest ? e.target.closest(".v") : null;
    if(!b) return;
    var id = b.closest(".quadro").dataset.id;
    var atual = (vereditos[id] || {}).veredito;
    guardar(id, {veredito: atual === b.dataset.v ? "" : b.dataset.v});
  });
  // A nota guarda-se ENQUANTO se escreve, e não só no `change`: esse só
  // dispara ao sair do campo, e quem escrevesse e fechasse a página logo a
  // seguir perdia a frase sem aviso.
  var esperas = {};
  function guardar_nota(campo){
    var id = campo.closest(".quadro").dataset.id;
    clearTimeout(esperas[id]);
    delete esperas[id];
    guardar(id, {nota: campo.value});
  }
  document.addEventListener("input", function(e){
    if(!e.target.classList || !e.target.classList.contains("nota")) return;
    var campo = e.target, id = campo.closest(".quadro").dataset.id;
    clearTimeout(esperas[id]);
    esperas[id] = setTimeout(function(){ guardar_nota(campo); }, 700);
  });
  document.addEventListener("change", function(e){
    if(!e.target.classList || !e.target.classList.contains("nota")) return;
    guardar_nota(e.target);
  });

  pintar();

  if(window.claude && window.claude.use){
    window.claude.use("db").then(function(db){
      if(!db) return;
      escrever = function(id, corpo_){
        db.doc("veredito/" + id).set(corpo_).catch(function(){});
      };
      db.collection("veredito").onSnapshot(function(s){
        s.docs.forEach(function(doc){
          var v = doc.data(); if(v) vereditos[doc.id] = v;
        });
        pintar();
      }, function(){});
      pintar();
    }).catch(function(){});
  }
})();
</script>
"""

# Os números desta frase saem da trilha: a primeira versão escrevia "Cinco" e
# "de 5 fotos para 14" à mão, e envelheceu no primeiro ponto que acrescentou
# uma foto à bateria.
nota_manchete = ("A bateria cresceu de %d fotos para %d pela trilha fora; a "
                 "data de cada \"antes\" está na legenda."
                 % (len(primeiro), len(ultimo)))
if iguais:
    nota_manchete += (" %d não mudaram desde que nasceram, e aparecem sozinhas:"
                      " estão por julgar como as outras." % len(iguais))

PAGINA = (PAGINA
          .replace("__PONTOS__", str(len(d["pontos"])))
          .replace("__PARES__", str(n_manchete_par))
          .replace("__NOVOS__", str(n_nasceram_depois))
          .replace("__N_PASSOS__", str(len(imagens_dos_passos)))
          .replace("__TETO__", str(TETO_ARQUIVOS))
          .replace("__MANCHETE__", manchete)
          .replace("__MANCHETE_NOTA__", nota_manchete)
          .replace("__N_HOJE__", str(len(ultimo)))
          .replace("__DE__", dia(bons[0]["data"]))
          .replace("__ATE__", dia(bons[-1]["data"]))
          .replace("__SECOES__", "".join(secoes))
          .replace("__DADOS__", dados_js))


destino = os.path.join(T, "trilha_arte.html")
tmp = destino + ".tmp"
with open(tmp, "w", encoding="utf-8", newline="\n") as f:
    f.write(PAGINA)
os.replace(tmp, destino)
print("%d pontos; na manchete %d pares antes/depois (%d fotos nasceram depois "
      "do primeiro ponto, %d iguais desde que nasceram); %d imagens distintas "
      "nos passos, fora da página"
      % (len(bons), n_manchete_par, n_nasceram_depois, len(iguais),
         len(imagens_dos_passos)))
print("%d arquivos em %s: %.1f MB em WebP (%.1f MB em PNG)"
      % (len(usados), pub, bytes_pub / 1e6, bytes_png / 1e6))
print("página em %s" % destino)
