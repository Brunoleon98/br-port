extends SceneTree

# ============================================================
# BR Port VS — folha de contato da FROTA
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Desenha os cascos de navio (um por par classe × motivo) e os camiões (um por
# motivo × eixo da rua), cada um sobre o chão em que vive, com o nome que o
# JOGO lhes dá.
#
# ⚠️ ELA EXISTE POR UMA REGRA DESTE REPOSITÓRIO: prop que a captura não vê é
# prop que ninguém revê. As cinco fotos de JOGO do CI mostram uma partida
# sorteada — medido em 07/09, no dia em que os seis cascos por serviço
# entraram, elas mostravam DOIS deles: as três docas calharam com o mesmo
# motivo e a Zona de Espera com outro. Quatro cascos e sete camiões ficavam
# gerados, validados por duas suítes, e sem ninguém os poder olhar. É a mesma
# forma do buraco do `barco_medio`, e a `folha_icones.gd` já era a resposta
# para os ícones: uma folha que percorre a tabela não depende de sorteio.
#
# ⚠️ E ELA PERCORRE AS TABELAS DO JOGO, nunca uma lista escrita aqui. Os
# cascos saem de `CLASSES_DE_NAVIO[classe]["motivos"]` pelo `arte_do_barco()`
# da doca, e os camiões do `CAMINHOES` do `Main.gd` — as MESMAS fontes que o
# D17 e o D13 percorrem. Uma classe nova, ou um motivo novo numa classe,
# aparece aqui sozinho; uma lista cravada apareceria sem ele, que é
# exactamente o que esta folha existe para impedir.
#
# ⚠️ O PROP É RECORTADO, NÃO ENCOLHIDO. O quadro de um prop tem 512px e o
# desenho ocupa ~100 no meio dele: pôr a textura inteira num TextureRect de
# 200px daria um barco de 40px rodeado de transparência — a armadilha que o
# retrato do trabalhador já pagou ("arte para interface enche o quadro; arte
# para o mapa, não"). Aqui recorta-se pelo `get_used_rect()` e amplia-se com
# filtro NEAREST, como o `recortar_captura.gd` faz.
#
# ⚠️ E O CHÃO NÃO É DECORAÇÃO. Contraste depende do FUNDO, e um casco julgado
# sobre branco não diz nada sobre um casco na água. Os dois tons abaixo foram
# AMOSTRADOS da captura do jogo a correr, não escolhidos.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/folha_frota.gd -- saida.png cascos|camioes
# ============================================================

const SAIDA_PADRAO := "user://folha_frota.png"
const FRAMES_ATE_ASSENTAR := 8

# Amostrados em `inicio.png`/`porto.png` com o jogo a correr: a água funda onde
# o barco atraca e o asfalto da rua por onde o camião passa.
const CHAO_AGUA := Color(0.051, 0.314, 0.439)     # #0d5070
const CHAO_RUA := Color(0.271, 0.306, 0.322)      # #454e52
const FUNDO_FOLHA := Color(0.09, 0.16, 0.24)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)

# ⚠️ E O ZOOM CONTA-SE SOBRE O TAMANHO DO JOGO, não sobre o pixel do arquivo.
# Desde a alavanca B o prop tem 768 px de textura para 512 de coordenada
# (`docs/decisoes/029`): multiplicar o `get_used_rect()` cru por 2 daria TRÊS
# vezes o tamanho do jogo, as células cresceriam 1,5x e a folha reprovaria por
# transbordo — sem que nada no catálogo tivesse mudado. Com o fator da textura
# pelo meio a folha fica do mesmo tamanho e mostra 1,5x mais desenho dentro
# dela, que é o que a alavanca comprou.
#
# O NEAREST fica: a ampliação deixou de ser 2:1 de texel e passou a 4:3, logo
# um em cada três pixels aparece dobrado — artefacto de lupa, e o preço de ver
# o pixel como ele é em vez de o ver borrado. Quem quiser a amostragem do jogo
# olha a `folha_props`, que é a que promete "o tamanho do jogo".
const ZOOM := 2
const MARGEM := 12
const RODAPE := 36                                 # as duas linhas de nome, por baixo

var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _pecas := 0


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_montar()
		return false
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false

	var img: Image = root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	print("Folha salva em %s (%dx%d) — %d peças" % [
		_saida, img.get_width(), img.get_height(), _pecas])
	quit(0)
	return true


func _montar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]
	# ⚠️ A SEÇÃO É OBRIGATÓRIA desde 23/09: `cascos` ou `camioes`. As duas
	# couberam numa tela até os camiões ganharem o sentido do retorno — 16
	# peças, uma linha a mais, e a conta abaixo reprovou por 25 px. Encolher a
	# arte seria tirar à folha a razão de existir (olhar ampliado); a folha dos
	# props já tinha páginas pela mesma razão, e cada página continua a reprovar
	# se transbordar.
	var secao: String = args[1] if args.size() >= 2 else ""
	if secao != "cascos" and secao != "camioes":
		push_error("folha_frota: diga a seção — cascos ou camioes (veio '%s')" % secao)
		quit(1)
		return

	var fundo := ColorRect.new()
	fundo.color = FUNDO_FOLHA
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	root.add_child(fundo)

	var y := float(MARGEM)
	if secao == "cascos":
		y = _secao("CASCOS — o que o navio traz", _cascos(), CHAO_AGUA, y)
	else:
		y = _secao("CAMIÕES — o que sai pela estrada, nos dois sentidos",
			_camioes(), CHAO_RUA, y)

	# ⚠️ FOLHA QUE TRANSBORDA CORTA EM SILÊNCIO, e uma folha cortada é pior do
	# que nenhuma: ela existe para provar que a arte que o sorteio esconde
	# chega a alguém, e um prop que caia abaixo da linha 1280 fica exatamente
	# como estava — gerado, validado e por olhar. Ela cresce sozinha (um porte
	# novo, um motivo novo, uma classe nova), então a conta tem de reprovar em
	# vez de recortar.
	var altura := float(ProjectSettings.get_setting(
		"display/window/size/viewport_height"))
	if y > altura:
		print("FALHOU — a folha pede %.0f px de altura e a tela tem %.0f. "
			% [y, altura]
			+ "Ela cortaria as últimas peças sem o dizer.")
		quit(1)
		return


## Os cascos, percorrendo as classes e os motivos que cada uma pode trazer.
##
## ⚠️ AS DUAS TABELAS LEEM-SE COM `load()`, E NÃO COM `preload()`. É a regra do
## `CLAUDE.md` sobre o autoload, apanhada pela terceira vez e agora deste lado:
## um script alcançado por `preload` a partir de um `--script` é compilado
## ANTES de os autoloads existirem, e o `Dock.gd` fala de `GameState` — o que
## sai é um `GDScript` vazio e um "Nonexistent function 'arte_do_barco'" em
## tempo de execução, sem uma linha a dizer que o script não compilou. Carregar
## dentro do `_process`, quando a árvore já está de pé, resolve-o.
func _cascos() -> Array:
	var GS: Node = root.get_node("GameState")
	var doca: Script = load("res://scripts/Dock.gd")
	var cascos: Dictionary = doca.get_script_constant_map()["CASCOS"]
	var itens: Array = []
	for classe in GS.CLASSES_DE_NAVIO:
		for motivo in GS.CLASSES_DE_NAVIO[classe]["motivos"]:
			# ⚠️ E DESDE 08/09 PERCORRE TAMBÉM O PORTE, que é o eixo novo da
			# frota de pesca. Ele não é o motivo: o pesqueiro continua a levar
			# o mesmo casco nos dois motivos dele, e o que muda entre os três é
			# o VALOR do contrato (`docs/decisoes/014`). Percorrer só o motivo
			# deixaria dois dos três barcos de pesca fora desta folha — o
			# buraco que ela existe para não haver.
			var portes: Array = cascos[classe][motivo]
			for p in range(portes.size()):
				var quantos := " · porte %d/%d" % [p + 1, portes.size()] \
					if portes.size() > 1 else ""
				itens.append([portes[p] as Texture2D,
					String(GS.CLASSES_DE_NAVIO[classe]["nome"]),
					String(GS.MOTIVOS[motivo]["nome"]) + quantos])
	return itens


## Os camiões, percorrendo os motivos do jogo, os dois eixos e os dois sentidos.
func _camioes() -> Array:
	var GS: Node = root.get_node("GameState")
	# ⚠️ `load()` e não `preload()`: um `const X := preload("...gd")` é a CLASSE
	# para o parser, e `get_script_constant_map()` é método do RECURSO — o
	# Godot recusa-se a chamá-lo na classe ("Make an instance instead"). Ler a
	# tabela de lá em vez de a repetir aqui é o que faz esta folha ser a mesma
	# verdade que o jogo desenha.
	var main: Script = load("res://scripts/Main.gd")
	var tabela: Dictionary = main.get_script_constant_map()["CAMINHOES"]
	var itens: Array = []
	for motivo in GS.MOTIVOS:
		if not tabela.has(motivo):
			continue
		# ⚠️ AS CHAVES SAEM DA TABELA, e não de `["my", "mx"]`. Era essa lista
		# escrita à mão, e com a mão dupla (23/09) ela teria deixado os oito
		# camiões do retorno — gerados, validados e no jogo — fora da única
		# folha onde se olha para eles.
		for eixo in (tabela[motivo] as Dictionary).keys():
			itens.append([tabela[motivo][eixo] as Texture2D,
				String(GS.MOTIVOS[motivo]["nome"]), String(eixo).replace("_", " · ")])
	return itens


## Uma seção: o título, e a grade de peças sobre o chão delas. Devolve o `y`
## onde a seguinte começa.
##
## ⚠️ AS COLUNAS SAEM DA MAIOR PEÇA, e não de um número escolhido. Uma carreta
## é mais larga do que um frigorífico e um porta-contêineres do que um
## pesqueiro; fixar quatro colunas cortaria a maior no dia em que ela crescesse
## — que é a mesma armadilha do `DESENHO_CAMINHAO` que o D13 acabou de perder.
func _secao(titulo: String, itens: Array, chao: Color, y0: float) -> float:
	var tela := float(ProjectSettings.get_setting("display/window/size/viewport_width"))

	var rotulo := Label.new()
	rotulo.text = titulo
	rotulo.position = Vector2(MARGEM, y0)
	rotulo.add_theme_color_override("font_color", TINTA)
	rotulo.add_theme_font_size_override("font_size", 17)
	root.add_child(rotulo)
	var y := y0 + 26.0

	var maior := Vector2.ZERO
	var recortes: Array = []
	var tamanhos: Array = []
	for item in itens:
		var img := (item[0] as Texture2D).get_image()
		var r := img.get_used_rect()
		recortes.append(r)
		var tam := Vector2(r.size) * PropIso.escala(item[0] as Texture2D) * float(ZOOM)
		tamanhos.append(tam)
		maior.x = maxf(maior.x, tam.x)
		maior.y = maxf(maior.y, tam.y)

	var celula := Vector2(maior.x + MARGEM, maior.y + RODAPE)
	var colunas: int = maxi(1, int((tela - MARGEM) / celula.x))
	var i := 0
	for item in itens:
		var r: Rect2i = recortes[i]
		var canto := Vector2(MARGEM + (i % colunas) * celula.x,
			y + float(i / colunas) * celula.y)

		# O CHÃO É SÓ POR BAIXO DA PEÇA, e o nome fica fora dele. A primeira
		# versão pintava a célula inteira e a segunda linha do rótulo caía por
		# baixo da borda — o nome do serviço, que é metade do que a folha
		# existe para dizer, saía cortado.
		var piso := ColorRect.new()
		piso.color = chao
		piso.position = canto
		piso.size = Vector2(celula.x - 8, celula.y - RODAPE)
		root.add_child(piso)

		# O recorte pelo `get_used_rect()`, ampliado sem suavizar: a 100px um
		# convés não se julga a olho, e foi ampliando que se viu que o ícone
		# `doca` era um fantasma no painel branco.
		var atlas := AtlasTexture.new()
		atlas.atlas = item[0]
		atlas.region = Rect2(r)
		var arte := TextureRect.new()
		arte.texture = atlas
		arte.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.stretch_mode = TextureRect.STRETCH_SCALE
		arte.size = tamanhos[i]
		arte.position = canto + Vector2(
			(celula.x - 8 - arte.size.x) / 2.0,
			(celula.y - RODAPE - arte.size.y) / 2.0)
		root.add_child(arte)

		var nome := Label.new()
		nome.text = "%s\n%s" % [item[1], item[2]]
		nome.position = canto + Vector2(2, celula.y - RODAPE + 2)
		nome.add_theme_color_override("font_color", TINTA_FRACA)
		nome.add_theme_font_size_override("font_size", 12)
		root.add_child(nome)

		_pecas += 1
		i += 1

	var linhas: int = int(ceil(float(itens.size()) / float(colunas)))
	return y + float(linhas) * celula.y + 14.0
