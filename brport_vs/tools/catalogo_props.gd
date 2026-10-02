extends RefCounted

# ============================================================
# BR Port VS — o CATÁLOGO dos props de mapa, e o chão debaixo de cada um
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Partilhado pelas três ferramentas que mostram props fora do jogo: a folha de
# contato (`folha_props.gd`), a prancha de um prop (`prancha_prop.gd`) e a
# página de escala (`escala_props.gd`). Vivia dentro da folha até 27/09, e saiu
# daqui no dia em que a prancha precisou de perguntar o mesmo — onde o jogo põe
# o prop e que chão o mapa pinta lá. Copiá-lo seria a regra que vive em dois
# sítios, e essa nunca reprova num defeito injetado.
#
# ⚠️ E SAIU SEM MUDAR UM BYTE DA FOLHA: as três páginas foram fotografadas antes
# e depois da mudança e deram o mesmo `md5`, que é a prova de que o que mudou
# foi o endereço e não a conta.
#
# ⚠️ `load()` DESTE ARQUIVO, NUNCA `preload()`, a partir de um `--script`: ele
# pergunta ao `Main.gd`, ao `Dock.gd` e ao `GameState`, e um script alcançado
# por `preload` é compilado antes de os autoloads existirem (`CLAUDE.md`).
# ============================================================

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

# A arte de interface sai do REGISTO dela, não de um prefixo de nome: os nove
# retratos de fala e os trinta do cartão do trabalhador vêm do `Retratos.gd`,
# que é o único lugar que sabe qual PNG é qual cara. Até 24/09 o do cartão era
# um só e vivia no `Worker.tscn`, e ficava escrito aqui à mão; com os trinta
# (`059`) ele passou a estar no registo, e a lista à mão saiu — os 29 novos
# entrariam nesta folha como props se ela continuasse a ser a fonte.

# ⚠️ OS PROPS QUE NÃO CAEM EM SÍTIO NENHUM DO MAPA, com a razão ao lado. A
# lista é conferida nos DOIS sentidos pela folha (`folha_props.gd`), que é o
# que a impede de envelhecer calada — a versão sem essa conta seria uma folha a
# inventar chão.
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

var _gs: Node
var _mapas := {}


func _init(gs: Node) -> void:
	_gs = gs


## O catálogo, tirado do DISCO e não de uma lista: um prop novo entra aqui
## sozinho, que é o contrário do buraco que esta folha existe para tapar.
func catalogo() -> Array:
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
func mapa(caminho: String) -> Dictionary:
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
func amostrar(caminho: String, ponto: Vector2) -> Color:
	var m := mapa(caminho)
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


func distintas(a: Color, b: Color) -> bool:
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
func da_cena(cena: String, base: Vector2, raiz: String, r: Dictionary) -> void:
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
			da_cena(sub, aqui, "", filhos)
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
func familias(ancoras: Dictionary) -> Dictionary:
	var GS: Node = _gs
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
			# As duas transportadoras de cada serviço (`070`) ocupam o mesmo nó.
			for empresa in mk["CAMINHOES"][motivo]:
				for eixo in ["my", "mx"]:
					camioes.append(empresa[eixo])
					retorno.append(empresa[eixo + "_retorno"])

	# O trabalhador que anda (`075`): os quadros dos dois sexos ocupam o nó
	# dele, a carga o filho `Carga` e a pilha o nó `Pilha` — percorridos nas
	# tabelas do `Dock`, como os cascos.
	var figura: Array = []
	for sexo in dk["QUADROS_TRABALHADOR"]:
		for sentido in dk["QUADROS_TRABALHADOR"][sexo]:
			for t in dk["QUADROS_TRABALHADOR"][sexo][sentido]:
				if not figura.has(t):
					figura.append(t)
	var carga: Array = []
	var pilha: Array = []
	for classe in dk["CARGAS"]:
		for motivo in dk["CARGAS"][classe]:
			var c: Dictionary = dk["CARGAS"][classe][motivo]
			if not carga.has(c["carga"]):
				carga.append(c["carga"])
			if not pilha.has(c["pilha"]):
				pilha.append(c["pilha"])

	# A vaga é a PRIMEIRA — as três caem no mesmo tipo de chão (o berço, que é
	# água costeira), e repetir os nove cascos por doca daria 27 células a
	# dizerem o mesmo. O D21 é quem tranca que os três berços são costeira.
	var vaga := "./MapaWrap/Docas/Doca0"
	return {
		vaga + "/Pier": pier,
		vaga + "/Lanca": dk["ArteLanca"],
		vaga + "/Barco": barcos,
		vaga + "/Trabalhador": figura,
		vaga + "/Trabalhador/Carga": carga,
		vaga + "/Pilha": pilha,
		"./MapaWrap/Cenario/Armazem": [mk["ArmazemRuina"], mk["ArmazemPronto"]],
		"./MapaWrap/Cenario/Escritorio": [mk["EscritorioRuina"], mk["EscritorioPronto"]],
		"./MapaWrap/Cenario/Caminhao0": camioes,
		"./MapaWrap/Cenario/CaminhaoRetorno0": retorno,
	}


## O PAPEL de cada textura dentro da família dela: o EIXO do camião e a
## CLASSE do casco, lidos das tabelas que o jogo lê para os escolher
## (`Main.CAMINHOES`, `Dock.CASCOS`). Quem não tem papel não está aqui.
##
## ⚠️ A família diz quem PODE ocupar o nó; o papel diz quem o ocupa NESTE
## momento sem mentir. O nó do camião anda na rua de `my` e na de `mx`, e uma
## textura de um eixo posta no outro sai atravessada. A prancha escolhia o
## irmão pelo tamanho do desenho e fez exactamente isso (`068`).
func papeis() -> Dictionary:
	var dk: Dictionary = (load("res://scripts/Dock.gd") as Script).get_script_constant_map()
	var mk: Dictionary = (load("res://scripts/Main.gd") as Script).get_script_constant_map()
	var out := {}
	var cascos: Dictionary = dk["CASCOS"]
	for classe in cascos:
		for motivo in cascos[classe]:
			for t in cascos[classe][motivo]:
				out[(t as Texture2D).resource_path.get_file()] = "classe " + String(classe)
	var camioes: Dictionary = mk["CAMINHOES"]
	for motivo in camioes:
		for empresa in camioes[motivo]:
			for eixo in empresa:
				out[(empresa[eixo] as Texture2D).resource_path.get_file()] = \
					"eixo " + String(eixo)
	return out


## Qual dos dois mapas responde por um nó. O equipamento de pátio só EXISTE
## quando o pátio existe (o `Main.gd` esconde-o até lá), então julgá-lo sobre a
## terra batida seria julgá-lo num estado em que ele não aparece. A lista sai
## do jogo, não daqui.
func mapa_do_no(caminho: String, equipamento: Array) -> String:
	for nome in equipamento:
		if caminho.ends_with("/" + String(nome)):
			return MAPA_PATIO
	return MAPA_TERRA


## {png: [Color, ...]} — os chãos distintos de cada prop, na ordem em que a
## cena os apresenta.
func chaos(nomes: Array, r: Dictionary) -> Dictionary:
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
		var cor := amostrar(mapa_do_no(caminho, equipamento), ancoras[caminho])
		if not out.has(png):
			out[png] = []
		for c in out[png]:
			if not distintas(c, cor):
				return
		out[png].append(cor)

	for v in r["vistas"]:
		pousar.call(String(v[0]), String(v[1]))
	var familias := familias(ancoras)
	for caminho in familias:
		for t in familias[caminho]:
			pousar.call((t as Texture2D).resource_path.get_file(), caminho)
	return out


## O chão listrado das células sem âncora — o que nenhuma amostra pode imitar.
func listrado() -> ImageTexture:
	var lado := 8
	var img := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
	for y in range(lado):
		for x in range(lado):
			img.set_pixel(x, y, CHAO_RECURSO if (x + y) % lado < lado / 2 \
				else CHAO_RECURSO.darkened(0.35))
	return ImageTexture.create_from_image(img)
