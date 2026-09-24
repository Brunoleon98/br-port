extends SceneTree

# ============================================================
# BR Port VS — folha de contato dos PROPS DE MAPA
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Desenha todo prop do catálogo a 1:1, no tamanho em que ele chega ao mapa,
# SOBRE O CHÃO QUE O MAPA PINTA DEBAIXO DELE, com o nome do arquivo por baixo.
# É a segunda metade da medição do gate A5 do plano v3 — "captura antes/depois
# lado a lado, E a folha de contato dos props" —, e a primeira metade (a
# trilha) ficou pronta em 14/09.
#
# ⚠️ ELA EXISTE PELA REGRA QUE JÁ PAGOU QUATRO VEZES: prop que a captura não vê
# é prop que ninguém revê. O `barco_medio` era renderizado, validado e nunca
# posto em doca nenhuma; o `doca_concreto` só é referido por um teste que não
# se exporta; e a pasta `art/brp` inteira — oito assets — é validada a cada
# corrida do CI e não aparece em imagem nenhuma. A `folha_icones` e a
# `folha_frota` já tapavam a sua parte do buraco; isto tapa o resto.
#
# ⚠️ O CHÃO É AMOSTRADO DO MAPA, e essa é a pergunta que a folha passou a
# responder em 16/09. Até aqui ela desenhava tudo sobre um fundo só — o asfalto
# do pátio — e isso estava escrito como limitação assumida: contraste depende do
# FUNDO, e um casco julgado sobre asfalto não diz nada sobre um casco na água.
# A folha respondia "dá para olhar?" e não "separa do fundo?".
#
# ⚠️ E SÃO DUAS FONTES, NUNCA UM ESPELHO. A ÂNCORA de cada prop sai da CENA —
# o `offset` do nó que o desenha, que é onde o jogo o põe — e a COR sai do
# RASTER DO MAPA, que sai do gerador. É a mesma porta por onde o D20 pergunta
# se a pista é pista e o D21 onde o barco fundeia: quem diz o sítio e quem diz
# a cor são arquivos diferentes, escritos por mãos diferentes. Uma tabela de
# posições escrita aqui seria o espelho de que o `CLAUDE.md` avisa.
#
# ⚠️ E A ÂNCORA É RELATIVA AO `MapaWrap`, NÃO À TELA. O `MapaWrap` tem
# `offset_top = 62` e o mapa começa lá; somar esse deslocamento põe toda
# amostra 62 px abaixo do prop — que é a armadilha escrita no `CLAUDE.md`
# ("três recortes já foram ao lugar errado por causa disto"), e ela mordeu
# nesta ferramenta na primeira medição. A conta anda do `MapaWrap` para baixo.
#
# ⚠️ E NÃO SE CONFERE AQUI QUE A CENA CONCORDA COM A TABELA DE ÂNCORAS. Já há
# quem o faça, e uma regra que viva em dois sítios nunca reprova num defeito
# injetado: o bloco **D1** do teste de design exige que Píer, Lança e Barco de
# cada uma das três docas caiam em cima do que o `porto_mapa_ancoras.json`
# publica. Esta folha herda esse acordo em vez de o repetir.
#
# ⚠️ E O QUE NÃO TEM ÂNCORA É DECLARADO COMO TAL, senão a folha mente sobre o
# que mediu. Sobra UM prop — ver `SEM_ANCORA` —, e ele sai sobre um chão de
# recurso LISTRADO, que nenhuma amostra do mapa pode imitar. A conta é dos dois
# lados: prop sem âncora que não esteja declarado REPROVA, e prop declarado que
# afinal tenha âncora REPROVA também, para a lista não envelhecer calada.
#
# ⚠️ E O QUE SE AMOSTRA É O MAPA, que não é sempre o que o prop pisa. Quem
# pousa em cima de OUTRO prop — o trabalhador e as três lanças, no tabuado do
# píer — sai aqui sobre a ÁGUA DO BERÇO, que é o que o mapa pinta por baixo dos
# dois. É limitação assumida e escrita, como o fundo único era até 16/09: o
# convés do píer não está no mapa, está num PNG, e derivá-lo pediria amostrar
# um prop através de outro. Quem quiser essa pergunta tem a captura de jogo, que
# é onde o píer e o trabalhador aparecem um em cima do outro.
#
# ⚠️ E NÃO SE AGRUPA POR `habitat`. Está medido e não dá (`docs/decisoes/026`,
# §A5 do plano): o campo existe nas 44 entradas do manifest, mas só 26 dos 51
# props de mapa lá estão e 20 desses 26 são `terra`. Ele foi desenhado para a
# FAUNA, onde cada bicho tem o seu. Cobertura não é distribuição.
#
# ⚠️ E A ARTE DE INTERFACE FICA DE FORA, por medição e não por gosto. Os nove
# retratos de fala medem 338x450 e o do trabalhador 138x307, contra os 153x140
# do maior prop de mapa: pô-los aqui faria toda célula ter 479px de altura e a
# folha caberia oito peças. E não se julgam aqui de todo — "peça de INTERFACE
# mede-se no tamanho do widget, não no do quadro", e o widget deles é o cartão
# do painel, onde a captura de jogo já os mostra.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/folha_props.gd \
#     -- <saida.png> <pagina> <total_de_paginas>
# ============================================================

const SAIDA_PADRAO := "user://folha_props.png"
const FRAMES_ATE_ASSENTAR := 8
const PASTA := "res://art/props"

const MAPA_TERRA := "res://art/porto_mapa_iso.svg"
const MAPA_PATIO := "res://art/porto_mapa_iso_patio.svg"

# O mapa é desenhado a 1080 e a tabela de âncoras publica TELA. É o mesmo
# acordo que o `_mapa_lido` do teste de design confere; aqui a régua sai da
# imagem contra este número, e uma imagem que não seja um múltiplo coerente
# dele reprova em vez de ler no sítio errado.
const LADO_DO_MAPA := 720.0

# O quadro de todo prop tem 512 e o centro dele é a origem do mundo.
const MEIO_QUADRO := 256.0

# ⚠️ A AMOSTRA É UMA JANELA, NUNCA UM PIXEL, e é a regra que o D20 foi o último
# bloco deste projeto a aprender. Sete por sete px de TELA é a mesma janela que
# ele usa; medido nos 51 props, é onde a amostra deixa de ser um cara-ou-coroa
# entre dois pixels vizinhos sem ainda atravessar para o terreno do lado — a
# 5 px de raio o coqueiro do passeio já lê capim, e o cabeço já lê água.
const RAIO_CHAO := 3

# ⚠️ E O QUE SE TIRA DA JANELA É O PIXEL MEDIANO POR LUMINÂNCIA, não a média.
# Média INVENTA uma cor que não está no mapa, e "cor misturada nunca casa com
# um tom publicado" — o chão desta folha tem de ser um chão que existe. A
# mediana é um pixel de verdade e não se deixa mover por uma pedra, um risco de
# junta ou um tufo de capim dentro da janela.

# ⚠️ E UM PROP PODE PISAR DOIS CHÃOS. A gaivota pousa na água funda e no
# baixio; a maria-farinha, no baixio e na areia SECA; o coqueiro, no passeio e
# no capim. Uma célula por prop com um chão só esconderia metade da resposta, e
# uma célula por AVISTAMENTO faria a folha crescer de 51 para 65 — com 12
# dessas repetições a mostrarem o mesmo tom duas vezes. Então a célula leva uma
# FAIXA por chão distinto, lado a lado, e o prop fica em cima da emenda: a
# metade esquerda dele julga-se contra um, a direita contra o outro.
#
# ⚠️ E O CORTE DO "DISTINTO" VAI AO MEIO DA BANDA MEDIDA, e não onde calha: os
# pares que TÊM de colapsar (dois pixels do mesmo asfalto, duas águas do largo)
# chegam a 11 de diferença máxima de canal, e os que TÊM de separar (passeio
# contra capim, baixio contra areia) começam em 35. O corte fica em 23 — 2,1x
# de folga de um lado e 1,5x do outro. Escolher 40 daria exactamente duas
# páginas cheias, e é por isso mesmo que não se escolhe: seria apertar o teto
# de uma guarda até o resultado ficar bonito.
const CORTE_CHAO := 23

# O chão de recurso: o asfalto do pátio, que é o fundo único que esta folha
# usou até 16/09, LISTRADO com o fundo da folha. Nenhuma amostra do mapa sai
# listrada, então a célula não se confunde com uma célula medida.
const CHAO_RECURSO := Color(0.271, 0.306, 0.322)   # #454e52
const FUNDO_FOLHA := Color(0.09, 0.16, 0.24)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)
const TINTA_RECURSO := Color(0.95, 0.75, 0.30)

# ⚠️ "1:1" É O TAMANHO DO JOGO, E ISSO DEIXOU DE SER O PIXEL DO ARQUIVO. Desde
# a alavanca B um prop tem 768 px de textura para 512 de coordenada
# (`docs/decisoes/029`): desenhar o `get_used_rect()` cru poria esta folha a
# 1,5x do jogo — o píer a 210 px em vez de 140 —, as células cresceriam na
# mesma proporção e a conta das páginas reprovaria, a dizer que é preciso uma
# terceira. Nenhuma das duas coisas é sobre o catálogo. O fator sai de cada
# textura, pelo `PropIso`, e é por isso que já não há um ZOOM constante aqui.
const ZOOM := 1                                    # 1:1 — o tamanho do jogo
const MARGEM := 10
# ⚠️ E CADA PEÇA TEM DE CHEGAR À FOTO, que a folha não perguntava. Em 23/09,
# com os props em atlas (`docs/decisoes/049`), um recorte mal montado desenhou
# TODOS os quadros vazios e a folha imprimiu "Folha salva em" na mesma. Hoje ela
# fotografa duas vezes — com a arte e sem ela — e conta, por peça, os pixels
# que mudam (`PropIso.desenho_na_foto`). O defeito dá ZERO exato; o corte fica
# a meio da banda medida, e quem acrescentar uma peça menor do que metade da
# menor de hoje desce-o de propósito.
# Medido: a menor é o `poste_luz`, com 38 px a 1:1 (folga 2x).
const DESENHO_MIN := 19
const RODAPE := 32                                 # as duas linhas de nome
const CABECALHO := 46                              # o título e a legenda
const FONTE_NOME := 11
const FONTE_CHAO := 10

# A arte de interface sai do REGISTO dela, não de um prefixo de nome: os nove
# retratos de fala e os trinta do cartão do trabalhador vêm do `Retratos.gd`,
# que é o único lugar que sabe qual PNG é qual cara. Até 24/09 o do cartão era
# um só e vivia no `Worker.tscn`, e ficava escrito aqui à mão; com os trinta
# (`059`) ele passou a estar no registo, e a lista à mão saiu — os 29 novos
# entrariam nesta folha como props se ela continuasse a ser a fonte.

# ⚠️ OS PROPS QUE NÃO CAEM EM SÍTIO NENHUM DO MAPA, com a razão ao lado. A
# lista é conferida nos DOIS sentidos lá em baixo, que é o que a impede de
# envelhecer calada — a versão sem essa conta seria uma folha a inventar chão.
#
# O briefing desta sessão previa cinco famílias aqui (as alternativas em ruína,
# os nove cascos, o píer vazio) porque contava com a TABELA DE ÂNCORAS, onde
# eles de facto não estão. Medido, a cena responde por todos: a ruína e o
# prédio pronto partilham o nó que o `Main.gd` troca, e os cascos, as lanças e
# os píeres partilham as vagas da doca. Sobra o órfão.
const SEM_ANCORA := {
	# O `tools/arte_orfa.py` acha-o desde 14/09: nada no jogo o desenha, e o
	# destino dele é decisão do Bruno (entra no mapa ou sai do catálogo). Até
	# lá ele aparece aqui, porque uma folha que o escondesse seria a folha a
	# repetir o buraco que existe para tapar.
	"doca_concreto.png": "órfão — nada no jogo o desenha",
}

var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _pagina := 1
var _total := 1
var _pecas := 0
var _mapas := {}
var _foto: Image = null
var _artes: Array = []


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		if not _montar():
			return true
		return false
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false

	# A foto que se grava é a primeira; a segunda, sem a arte, só serve para
	# provar que cada peça chegou à primeira (`PropIso.desenho_na_foto`).
	if _foto == null:
		_foto = root.get_texture().get_image()
		for par in _artes:
			(par[0] as CanvasItem).hide()
		_frames = 0
		return false
	var ausentes := _pecas_ausentes(_foto, root.get_texture().get_image())
	var img := _foto
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	if ausentes > 0:
		print("FALHOU: %d peça(s) sem desenho na foto — ver acima" % ausentes)
		quit(1)
		return true
	print("Folha salva em %s (%dx%d) — %d peças (página %d de %d)" % [
		_saida, img.get_width(), img.get_height(), _pecas, _pagina, _total])
	quit(0)
	return true


## Conta as peças que NÃO chegaram à foto, e diz a menor que chegou. É a mesma
## função da `folha_frota`: cada folha responde pelas SUAS peças.
func _pecas_ausentes(com: Image, sem: Image) -> int:
	var ausentes := 0
	var menor := -1
	var menor_nome := ""
	for par in _artes:
		var arte := par[0] as TextureRect
		var n := PropIso.desenho_na_foto(com, sem, Rect2(arte.position, arte.size))
		if n < DESENHO_MIN:
			print("FALHOU  %s não chegou à foto: %d px mudam ao escondê-la"
				% [par[1], n])
			ausentes += 1
		if menor < 0 or n < menor:
			menor = n
			menor_nome = par[1]
	print("Menor peça na foto: %d px (%s)" % [menor, menor_nome])
	return ausentes


## O catálogo, tirado do DISCO e não de uma lista: um prop novo entra aqui
## sozinho, que é o contrário do buraco que esta folha existe para tapar.
func _catalogo() -> Array:
	var fora := {}
	# ⚠️ `load()` e não `preload()`: um script alcançado por `preload` a partir
	# de um `--script` é compilado antes de a árvore estar de pé. É a regra do
	# `CLAUDE.md`, e a `folha_frota` já a carrega escrita ao lado.
	var retratos: Script = load("res://scripts/Retratos.gd")
	for chave in retratos.get_script_constant_map():
		var v = retratos.get_script_constant_map()[chave]
		if v is Texture2D:
			fora[(v as Texture2D).resource_path.get_file()] = true
	for caminho in retratos.get_script_constant_map()["TRABALHADORES"]:
		fora[String(caminho).get_file()] = true

	var nomes: Array[String] = []
	var d := DirAccess.open(PASTA)
	if d == null:
		return nomes
	for f in d.get_files():
		if f.ends_with(".png") and not fora.has(f):
			nomes.append(f)
	nomes.sort()
	return nomes


# ── O MAPA, e a régua dele ────────────────────────────────────────────────
#
# ⚠️ LÊ O `load()` DA TEXTURA, e não o arquivo. É a mesma escolha do
# `_mapa_lido` do teste de design: o projeto é importado antes da bateria,
# então esta é a MESMA textura que o jogo recebe. Quem regera arte corre o
# `--import` antes de fotografar, que é a regra do `CLAUDE.md`.
func _mapa(caminho: String) -> Dictionary:
	if _mapas.has(caminho):
		return _mapas[caminho]
	var tex := load(caminho) as Texture2D
	var img := tex.get_image() if tex != null else null
	if img == null:
		_mapas[caminho] = {}
		return _mapas[caminho]
	var fx := float(img.get_width()) / LADO_DO_MAPA
	var fy := float(img.get_height()) / LADO_DO_MAPA
	# O fator não se escreve numa constante: sai da imagem contra os 720 que a
	# tabela publica. Uma imagem de outra proporção, mais pequena ou esticada
	# num eixo só, tem de reprovar em vez de ler no sítio errado.
	if not is_equal_approx(fx, fy) or fx < 1.0 \
			or not is_equal_approx(fx, round(fx * 2.0) / 2.0):
		_mapas[caminho] = {}
		return _mapas[caminho]
	_mapas[caminho] = {"img": img, "escala": fx}
	return _mapas[caminho]


## O pixel MEDIANO por luminância de uma janela de `RAIO_CHAO` px de TELA.
func _amostrar(caminho: String, ponto: Vector2) -> Color:
	var m := _mapa(caminho)
	if m.is_empty():
		return Color.MAGENTA
	var img: Image = m["img"]
	var e: float = m["escala"]
	var centro := Vector2i(int(floor(ponto.x * e)), int(floor(ponto.y * e)))
	var r := int(round(float(RAIO_CHAO) * e))
	var janela: Array = []
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var q := centro + Vector2i(dx, dy)
			if q.x < 0 or q.y < 0 or q.x >= img.get_width() or q.y >= img.get_height():
				continue
			var cor := img.get_pixelv(q)
			janela.append([cor.get_luminance(), cor])
	if janela.is_empty():
		return Color.MAGENTA
	janela.sort_custom(func(a, b): return a[0] < b[0])
	return janela[janela.size() / 2][1]


func _distintas(a: Color, b: Color) -> bool:
	var d := maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), absf(a.b - b.b))
	return d * 255.0 > float(CORTE_CHAO)


# ── A CENA, e onde ela põe cada prop ──────────────────────────────────────
#
# Lê o `SceneState` em vez de instanciar a cena, e isso é cuidado medido: um
# `Main.tscn` instanciado corre o `_ready()` dele, que arma o `Registro` e
# carrega o autosave que estiver em `user://` — a armadilha que o
# `capturar_cena.gd` pagou em 12/09. O estado guardado responde à pergunta
# desta folha (onde está o nó) sem pôr nada de pé.
##
## Devolve {"ancoras": {caminho_do_no: Vector2}, "vistas": [[png, caminho], ...]}
## com as coordenadas já relativas ao `MapaWrap`.
func _da_cena(cena: String, base: Vector2, raiz: String, r: Dictionary) -> void:
	var ps := load(cena) as PackedScene
	if ps == null:
		return
	var st := ps.get_state()
	var desloc := {}
	for i in range(st.get_node_count()):
		var caminho := String(st.get_node_path(i))
		var d := Vector2.ZERO
		var tex := ""
		var inst: PackedScene = st.get_node_instance(i)
		for j in range(st.get_node_property_count(i)):
			var nome := String(st.get_node_property_name(i, j))
			var v = st.get_node_property_value(i, j)
			if nome == "offset_left":
				d.x = float(v)
			elif nome == "offset_top":
				d.y = float(v)
			elif nome == "position":
				d = v
			elif nome == "texture" and v is Texture2D:
				tex = (v as Texture2D).resource_path
		var pai := caminho.get_base_dir()
		var acc: Vector2 = d
		if caminho == raiz:
			acc = Vector2.ZERO          # a raiz é a origem, e o +62 dela fica de fora
		elif desloc.has(pai):
			acc = (desloc[pai] as Vector2) + d
		desloc[caminho] = acc
		if raiz != "" and not caminho.begins_with(raiz + "/"):
			continue

		var aqui := base + acc
		if inst != null:
			var sub := inst.resource_path
			# A doca é um `Control` com props dentro: cada slot dela leva o
			# quadro de 512 como qualquer outro. A fauna é um `Node2D` com um
			# `Sprite2D` CENTRADO no nó, então a âncora é a própria posição.
			var filhos := {"ancoras": {}, "vistas": []}
			_da_cena(sub, aqui, "", filhos)
			for k in filhos["ancoras"]:
				r["ancoras"][caminho + "/" + String(k).substr(2)] = \
					aqui if not sub.ends_with("Dock.tscn") else filhos["ancoras"][k]
			for v in filhos["vistas"]:
				var p2: String = caminho + "/" + String(v[1]).substr(2)
				r["vistas"].append([v[0], p2])
			if not sub.ends_with("Dock.tscn"):
				r["ancoras"][caminho] = aqui
		else:
			r["ancoras"][caminho] = aqui + Vector2(MEIO_QUADRO, MEIO_QUADRO)
			if tex.begins_with(PASTA + "/"):
				r["vistas"].append([tex.get_file(), caminho])


# ── AS FAMÍLIAS: quem mais pode encher um slot que a cena deixa em branco ──
#
# Um nó da cena mostra UMA textura, e o jogo troca-a: o mesmo `Barco` recebe
# nove cascos, o mesmo `Pier` quatro estados, o mesmo `Armazem` a ruína e o
# prédio pronto. A âncora é do SLOT; quem a partilha sai das TABELAS DO JOGO,
# percorridas como a `folha_frota` as percorre — nunca de uma lista escrita
# aqui, que apareceria sem o casco novo no dia em que ele entrasse.
#
# O que fica escrito é só o NOME DO NÓ de cada família, que é uma afirmação
# sobre a cena e não um número: se o nó não existir, isto reprova; e onde a
# cena já põe uma textura naquele slot, ela tem de pertencer à família.
func _familias(ancoras: Dictionary) -> Dictionary:
	var GS: Node = root.get_node("GameState")
	var doca: Script = load("res://scripts/Dock.gd")
	var main: Script = load("res://scripts/Main.gd")
	var dk: Dictionary = doca.get_script_constant_map()
	var mk: Dictionary = main.get_script_constant_map()

	var pier: Array = [dk["ArtePierVazio"]]
	for t in dk["ArtePier"]:
		pier.append(t)

	# Os cascos percorrem classe × motivo × porte, como na folha da frota: o
	# pesqueiro leva o mesmo casco nos dois motivos dele e três portes dentro
	# de cada um, e percorrer só o motivo deixaria dois deles de fora.
	var cascos: Dictionary = dk["CASCOS"]
	var barcos: Array = []
	for classe in GS.CLASSES_DE_NAVIO:
		for motivo in GS.CLASSES_DE_NAVIO[classe]["motivos"]:
			for t in cascos[classe][motivo]:
				barcos.append(t)

	# A ida e o retorno são nós DIFERENTES da cena, e cada um mostra as suas
	# silhuetas: o chão de cada célula sai do sítio onde o nó pousa.
	var camioes: Array = []
	var retorno: Array = []
	for motivo in GS.MOTIVOS:
		if mk["CAMINHOES"].has(motivo):
			for eixo in ["my", "mx"]:
				camioes.append(mk["CAMINHOES"][motivo][eixo])
				retorno.append(mk["CAMINHOES"][motivo][eixo + "_retorno"])

	# A vaga é a PRIMEIRA — as três caem no mesmo tipo de chão (o berço, que é
	# água costeira), e repetir os nove cascos por doca daria 27 células a
	# dizerem o mesmo. O D21 é quem tranca que os três berços são costeira.
	var vaga := "./MapaWrap/Docas/Doca0"
	return {
		vaga + "/Pier": pier,
		vaga + "/Lanca": dk["ArteLanca"],
		vaga + "/Barco": barcos,
		"./MapaWrap/Cenario/Armazem": [mk["ArmazemRuina"], mk["ArmazemPronto"]],
		"./MapaWrap/Cenario/Escritorio": [mk["EscritorioRuina"], mk["EscritorioPronto"]],
		"./MapaWrap/Cenario/Caminhao0": camioes,
		"./MapaWrap/Cenario/CaminhaoRetorno0": retorno,
	}


## Qual dos dois mapas responde por um nó. O equipamento de pátio só EXISTE
## quando o pátio existe (o `Main.gd` esconde-o até lá), então julgá-lo sobre a
## terra batida seria julgá-lo num estado em que ele não aparece. A lista sai
## do jogo, não daqui.
func _mapa_do_no(caminho: String, equipamento: Array) -> String:
	for nome in equipamento:
		if caminho.ends_with("/" + String(nome)):
			return MAPA_PATIO
	return MAPA_TERRA


## {png: [Color, ...]} — os chãos distintos de cada prop, na ordem em que a
## cena os apresenta.
func _chaos(nomes: Array, r: Dictionary) -> Dictionary:
	var main: Script = load("res://scripts/Main.gd")
	var equipamento: Array = main.get_script_constant_map()["EQUIPAMENTO_DE_PATIO"]
	var ancoras: Dictionary = r["ancoras"]
	var conhecidos := {}
	for n in nomes:
		conhecidos[n] = true

	var out := {}
	var pousar := func(png: String, caminho: String) -> void:
		if not conhecidos.has(png) or not ancoras.has(caminho):
			return
		var cor := _amostrar(_mapa_do_no(caminho, equipamento), ancoras[caminho])
		if not out.has(png):
			out[png] = []
		for c in out[png]:
			if not _distintas(c, cor):
				return
		out[png].append(cor)

	for v in r["vistas"]:
		pousar.call(String(v[0]), String(v[1]))
	var familias := _familias(ancoras)
	for caminho in familias:
		for t in familias[caminho]:
			pousar.call((t as Texture2D).resource_path.get_file(), caminho)
	return out


## O chão listrado das células sem âncora — o que nenhuma amostra pode imitar.
func _listrado() -> ImageTexture:
	var lado := 8
	var img := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
	for y in range(lado):
		for x in range(lado):
			img.set_pixel(x, y, CHAO_RECURSO if (x + y) % lado < lado / 2 \
				else CHAO_RECURSO.darkened(0.35))
	return ImageTexture.create_from_image(img)


func _montar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]
	if args.size() >= 3:
		_pagina = int(args[1])
		_total = int(args[2])

	var nomes := _catalogo()
	if nomes.is_empty():
		print("FALHOU — não há prop nenhum em %s" % PASTA)
		quit(1)
		return false

	for caminho in [MAPA_TERRA, MAPA_PATIO]:
		if _mapa(caminho).is_empty():
			print("FALHOU — %s não rasteriza num múltiplo coerente dos %d px "
				% [caminho.get_file(), int(LADO_DO_MAPA)]
				+ "que a tabela de âncoras publica. Rode o --import.")
			quit(1)
			return false

	var r := {"ancoras": {}, "vistas": []}
	_da_cena("res://scenes/Main.tscn", Vector2.ZERO, "./MapaWrap", r)

	# ⚠️ TODA FAMÍLIA APONTA PARA UM NÓ QUE EXISTE, E O QUE A CENA PÕE LÁ
	# PERTENCE À FAMÍLIA. Sem a primeira metade, um nó renomeado faria 23 props
	# caírem calados no chão de recurso — a folha a dizer "sem âncora" sobre
	# props que têm uma. Sem a segunda, uma família podia estar presa ao slot
	# errado e ninguém saberia.
	var familias := _familias(r["ancoras"])
	var na_cena := {}
	for v in r["vistas"]:
		na_cena[String(v[1])] = String(v[0])
	for caminho in familias:
		if not r["ancoras"].has(caminho):
			print("FALHOU — a família de '%s' aponta para um nó que a cena não tem."
				% caminho)
			quit(1)
			return false
		if not na_cena.has(caminho):
			continue
		var posta: String = na_cena[caminho]
		var tem := false
		for t in familias[caminho]:
			if (t as Texture2D).resource_path.get_file() == posta:
				tem = true
		if not tem:
			print("FALHOU — a cena põe '%s' em '%s' e a família desse nó não o "
				% [posta, caminho] + "conhece. Ou o nó mudou de dono, ou a "
				+ "tabela do jogo deixou de o listar.")
			quit(1)
			return false

	var chaos := _chaos(nomes, r)

	# ⚠️ A CONTA DOS SEM-ÂNCORA É DOS DOIS LADOS. Um prop novo que não caia em
	# sítio nenhum do mapa tem de aparecer aqui em vez de ganhar um chão
	# inventado; e um prop declarado que já tenha âncora tem de sair da lista,
	# senão ela envelhece calada — que é o defeito que este projeto apanha uma
	# vez por semana.
	var orfaos: Array = []
	for n in nomes:
		if not chaos.has(n) or (chaos[n] as Array).is_empty():
			orfaos.append(n)
	for n in orfaos:
		if not SEM_ANCORA.has(n):
			print("FALHOU — '%s' não cai em sítio nenhum do mapa e não está " % n
				+ "declarado em SEM_ANCORA. Ou o prop entra na cena, ou entra "
				+ "naquela lista com a razão ao lado — um chão inventado "
				+ "faria esta folha mentir sobre o que mediu.")
			quit(1)
			return false
	for n in SEM_ANCORA:
		if not orfaos.has(n):
			print("FALHOU — '%s' está declarado em SEM_ANCORA e a cena já lhe " % n
				+ "dá âncora. Tire-o da lista: ela existe para ser exceção.")
			quit(1)
			return false

	# A CÉLULA SAI DO MAIOR PROP DO CATÁLOGO INTEIRO, e não do maior desta
	# página: duas páginas com células de tamanhos diferentes não se comparam,
	# e comparar tamanhos é metade do que esta folha entrega — a 1:1, ver que
	# um cone tem 30px ao lado de um píer de 140 é informação.
	var texturas := {}
	var recortes := {}
	var tamanhos := {}
	var maior := Vector2.ZERO
	for n in nomes:
		var tex: Texture2D = load("%s/%s" % [PASTA, n])
		texturas[n] = tex
		var rc := PropIso.imagem(tex).get_used_rect()
		recortes[n] = rc
		# O recorte é em pixel da textura (é ele que o `AtlasTexture` corta); o
		# TAMANHO em que ele se desenha é em coordenada, que é o do jogo.
		var tam := Vector2(rc.size) * PropIso.escala(tex) * float(ZOOM)
		tamanhos[n] = tam
		maior.x = maxf(maior.x, tam.x)
		maior.y = maxf(maior.y, tam.y)

	# ⚠️ E O RÓTULO TAMBÉM NÃO PODE SER CORTADO. `Label` que não cabe corta sem
	# dar erro (é o D18 do teste de design, noutra roupa), e um prop sem nome
	# legível nesta folha é um prop que ninguém sabe ir procurar. Mede-se o
	# PIOR do catálogo, não o que calha — e desde 16/09 são DUAS linhas: a
	# segunda diz de que cor é o chão, e ela cresce quando um prop pisa dois.
	# O pior caso sai do que a folha ESCREVE, nunca de um texto suposto.
	#
	# ⚠️ E ESTÁ MEDIDO O QUE CADA LINHA DEFENDE, que não é o mesmo. Quem estava
	# apertado era a PRIMEIRA: `caminhao_armazenagem_mx` pedia 155 px num
	# orçamento de 159, e o `_retorno_mx` (200 px) reprovou — é por isso que a
	# célula passou a sair também do rótulo (ver abaixo). A segunda tem folga — dois chãos pedem 83 px e três pedem 126,
	# e ela só transborda ao QUARTO (170 px, medido com a mesma chamada que a
	# guarda faz). Nenhum prop do catálogo de hoje pisa quatro chãos, então um
	# defeito que baixe o `CORTE_CHAO` a zero não chega a esta guarda — está
	# medido, e escreve-se em vez de se apertar o teto até ele apanhar o
	# defeito seguinte. Desde que a célula cresce com o rótulo, uma fonte maior
	# já não reprova AQUI: medido, a 16 px a célula alarga para duas colunas e
	# quem reprova é a conta das páginas (59 props pedem 5, pediram-se 3).
	var fonte := ThemeDB.fallback_font
	var pior := 0.0
	var pior_texto := ""
	for n in nomes:
		for par in [[n.get_basename(), FONTE_NOME], [_linha_do_chao(n, chaos), FONTE_CHAO]]:
			var w := fonte.get_string_size(String(par[0]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, int(par[1])).x
			if w > pior:
				pior = w
				pior_texto = String(par[0])
	# ⚠️ E A CÉLULA SAI TAMBÉM DO RÓTULO, desde 23/09. Até ali ela saía só do
	# maior DESENHO e o rótulo era conferido depois contra ela — com 4 px de
	# folga, avisava o comentário acima. Os camiões do retorno trouxeram
	# `caminhao_armazenagem_retorno_mx`, que pede 200 px numa célula de 159, e
	# a guarda reprovou como devia. O remédio não é encurtar o nome do arquivo,
	# que é o que o rótulo existe para mostrar: é a célula caber o que ela
	# carrega, desenho E nome. A guarda que sobra é a da PÁGINA.
	var larg_pagina := float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	if pior + 4.0 + 2.0 * MARGEM > larg_pagina:
		print("FALHOU — o rótulo '%s' pede %.0f px e a página dá %.0f."
			% [pior_texto, pior, larg_pagina - 2.0 * MARGEM - 4.0])
		quit(1)
		return false

	var larg := float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var alt := float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var celula := Vector2(maxf(maior.x, pior + 4.0) + MARGEM, maior.y + RODAPE)
	var colunas: int = maxi(1, int((larg - MARGEM) / celula.x))
	var linhas: int = maxi(1, int((alt - CABECALHO - MARGEM) / celula.y))
	var por_pagina := colunas * linhas

	# ⚠️ FOLHA QUE TRANSBORDA CORTA EM SILÊNCIO, e é a regra que a `folha_frota`
	# já carrega — aqui com uma cara a mais, porque esta folha tem PÁGINAS. Um
	# prop novo que empurre o catálogo para uma página a mais não pode sair
	# recortado nem sair sem foto: quem chama diz quantas páginas espera, e a
	# conta reprova se o catálogo já não couber nelas. Acrescentar a chamada da
	# página nova no `capturar_evidencia.sh` faz parte de acrescentar o prop.
	var precisa: int = int(ceil(float(nomes.size()) / float(por_pagina)))
	if precisa != _total:
		print("FALHOU — o catálogo tem %d props e cabem %d por página (%d x %d), "
			% [nomes.size(), por_pagina, colunas, linhas]
			+ "logo precisa de %d páginas e pediram-se %d. " % [precisa, _total]
			+ "Acrescente ou tire uma chamada no capturar_evidencia.sh.")
		quit(1)
		return false
	if _pagina < 1 or _pagina > _total:
		print("FALHOU — pediu-se a página %d de %d." % [_pagina, _total])
		quit(1)
		return false


	var fundo := ColorRect.new()
	fundo.color = FUNDO_FOLHA
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	root.add_child(fundo)

	var titulo := Label.new()
	titulo.text = "PROPS DE MAPA a 1:1 — página %d de %d, %d de %d no catálogo" \
		% [_pagina, _total, mini(por_pagina, nomes.size() - (_pagina - 1) * por_pagina),
		   nomes.size()]
	titulo.position = Vector2(MARGEM, 4)
	titulo.add_theme_color_override("font_color", TINTA)
	titulo.add_theme_font_size_override("font_size", 15)
	root.add_child(titulo)

	var legenda := Label.new()
	legenda.text = "o chão é a cor que o mapa pinta debaixo da âncora do prop · " \
		+ "duas faixas = dois chãos · listrado = sem âncora, chão de recurso"
	legenda.position = Vector2(MARGEM, 25)
	legenda.add_theme_color_override("font_color", TINTA_FRACA)
	legenda.add_theme_font_size_override("font_size", 11)
	root.add_child(legenda)

	var listrado := _listrado()
	var inicio := (_pagina - 1) * por_pagina
	var fim: int = mini(inicio + por_pagina, nomes.size())
	for i in range(inicio, fim):
		var n: String = nomes[i]
		var k := i - inicio
		var rc: Rect2i = recortes[n]
		var canto := Vector2(MARGEM + (k % colunas) * celula.x,
			CABECALHO + float(k / colunas) * celula.y)
		var piso_tam := Vector2(celula.x - 6, celula.y - RODAPE)
		var tons: Array = chaos.get(n, [])

		if tons.is_empty():
			var listras := TextureRect.new()
			listras.texture = listrado
			listras.stretch_mode = TextureRect.STRETCH_TILE
			listras.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			listras.position = canto
			listras.size = piso_tam
			root.add_child(listras)
		else:
			# UMA FAIXA POR CHÃO, lado a lado, com o prop em cima da emenda.
			for t in range(tons.size()):
				var faixa := ColorRect.new()
				faixa.color = tons[t]
				faixa.position = canto + Vector2(
					piso_tam.x * float(t) / float(tons.size()), 0.0)
				faixa.size = Vector2(piso_tam.x / float(tons.size()), piso_tam.y)
				root.add_child(faixa)

		var arte := TextureRect.new()
		arte.texture = PropIso.recorte(texturas[n])
		# ⚠️ O FILTRO ERA `NEAREST`, E ISSO SÓ ERA VERDADE A 1:1 DE PIXEL. Com a
		# textura a 768 dentro de uma célula de coordenada, `NEAREST` deitaria
		# fora um pixel em cada três e a folha mostraria uma aliasagem que o
		# jogo não tem — o jogo desenha com o filtro padrão do projeto. A folha
		# promete "o tamanho do jogo"; então mostra também a amostragem dele.
		arte.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.stretch_mode = TextureRect.STRETCH_SCALE
		arte.size = tamanhos[n]
		arte.position = canto + Vector2(
			(piso_tam.x - arte.size.x) / 2.0,
			(piso_tam.y - arte.size.y) / 2.0)
		root.add_child(arte)
		_artes.append([arte, n])

		var rotulo := Label.new()
		rotulo.text = n.get_basename()
		rotulo.position = canto + Vector2(2, celula.y - RODAPE)
		rotulo.add_theme_color_override("font_color", TINTA_FRACA)
		rotulo.add_theme_font_size_override("font_size", FONTE_NOME)
		root.add_child(rotulo)

		var chao := Label.new()
		chao.text = _linha_do_chao(n, chaos)
		chao.position = canto + Vector2(2, celula.y - RODAPE + 15)
		chao.add_theme_color_override("font_color",
			TINTA_RECURSO if tons.is_empty() else TINTA_FRACA)
		chao.add_theme_font_size_override("font_size", FONTE_CHAO)
		root.add_child(chao)
		_pecas += 1

	return true


## A segunda linha do rótulo: de que cor é o chão, ou que ele é de recurso.
func _linha_do_chao(png: String, chaos: Dictionary) -> String:
	var tons: Array = chaos.get(png, [])
	if tons.is_empty():
		return "sem âncora · recurso"
	var partes: Array = []
	for c in tons:
		partes.append("#" + (c as Color).to_html(false))
	return " ".join(partes)
