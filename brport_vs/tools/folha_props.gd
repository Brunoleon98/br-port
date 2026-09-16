extends SceneTree

# ============================================================
# BR Port VS — folha de contato dos PROPS DE MAPA
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Desenha todo prop do catálogo a 1:1, no tamanho em que ele chega ao mapa, com
# o nome do arquivo por baixo. É a segunda metade da medição do gate A5 do
# plano v3 — "captura antes/depois lado a lado, E a folha de contato dos
# props" —, e a primeira metade (a trilha) ficou pronta em 14/09.
#
# ⚠️ ELA EXISTE PELA REGRA QUE JÁ PAGOU QUATRO VEZES: prop que a captura não vê
# é prop que ninguém revê. O `barco_medio` era renderizado, validado e nunca
# posto em doca nenhuma; o `doca_concreto` só é referido por um teste que não
# se exporta; e a pasta `art/brp` inteira — oito assets — é validada a cada
# corrida do CI e não aparece em imagem nenhuma. A `folha_icones` e a
# `folha_frota` já tapavam a sua parte do buraco; isto tapa o resto.
#
# ⚠️ O FUNDO É UM SÓ, E ISSO É UMA LIMITAÇÃO ASSUMIDA. Contraste depende do
# FUNDO — um casco julgado sobre asfalto não diz nada sobre um casco na água —,
# e o fundo certo de cada prop mede-se AMOSTRANDO o mapa debaixo da âncora
# dele, que é o que o D20 e o D21 já fazem para outra pergunta. Isso é sessão
# própria; até lá, esta folha responde "dá para olhar?" e não "separa do
# fundo?". Quem quiser a segunda pergunta hoje tem a captura de jogo.
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

# Amostrado da captura do jogo, como os da `folha_frota`: o asfalto do pátio,
# que é o chão de mais props do que qualquer outro.
const CHAO := Color(0.271, 0.306, 0.322)          # #454e52
const FUNDO_FOLHA := Color(0.09, 0.16, 0.24)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)

const ZOOM := 1                                    # 1:1 — o tamanho do jogo
const MARGEM := 10
const RODAPE := 18                                 # a linha do nome, por baixo
const CABECALHO := 30
const FONTE_NOME := 11

# A arte de interface sai do REGISTO dela, não de um prefixo de nome: os nove
# retratos de fala vêm do `Retratos.gd`, que é o único lugar que sabe qual PNG
# é qual cara. Sobra um que aquele registo não conhece — o retrato do cartão do
# trabalhador, que vive no `Worker.tscn` —, e ele fica escrito aqui com a razão
# ao lado em vez de esta ferramenta ficar esperta a adivinhar quem é interface.
const INTERFACE_AVULSA := ["trabalhador_retrato.png"]

var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _pagina := 1
var _total := 1
var _pecas := 0


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		if not _montar():
			return true
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
	print("Folha salva em %s (%dx%d) — %d peças (página %d de %d)" % [
		_saida, img.get_width(), img.get_height(), _pecas, _pagina, _total])
	quit(0)
	return true


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
	for f in INTERFACE_AVULSA:
		fora[f] = true

	var nomes: Array[String] = []
	var d := DirAccess.open(PASTA)
	if d == null:
		return nomes
	for f in d.get_files():
		if f.ends_with(".png") and not fora.has(f):
			nomes.append(f)
	nomes.sort()
	return nomes


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

	# A CÉLULA SAI DO MAIOR PROP DO CATÁLOGO INTEIRO, e não do maior desta
	# página: duas páginas com células de tamanhos diferentes não se comparam,
	# e comparar tamanhos é metade do que esta folha entrega — a 1:1, ver que
	# um cone tem 30px ao lado de um píer de 140 é informação.
	var texturas := {}
	var recortes := {}
	var maior := Vector2i.ZERO
	for n in nomes:
		var tex: Texture2D = load("%s/%s" % [PASTA, n])
		texturas[n] = tex
		var r := tex.get_image().get_used_rect()
		recortes[n] = r
		maior.x = maxi(maior.x, r.size.x)
		maior.y = maxi(maior.y, r.size.y)

	var larg := float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var alt := float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var celula := Vector2(maior.x * ZOOM + MARGEM, maior.y * ZOOM + RODAPE)
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

	# ⚠️ E O NOME TAMBÉM NÃO PODE SER CORTADO. `Label` que não cabe corta sem
	# dar erro (é o D18 do teste de design, noutra roupa), e um prop sem nome
	# legível nesta folha é um prop que ninguém sabe ir procurar. Mede-se o
	# PIOR nome do catálogo, não o que calha.
	var fonte := ThemeDB.fallback_font
	var pior := 0.0
	var pior_nome := ""
	for n in nomes:
		var w := fonte.get_string_size(n.get_basename(),
			HORIZONTAL_ALIGNMENT_LEFT, -1, FONTE_NOME).x
		if w > pior:
			pior = w
			pior_nome = n
	if pior > celula.x - 4.0:
		print("FALHOU — o nome '%s' pede %.0f px e a célula dá %.0f."
			% [pior_nome.get_basename(), pior, celula.x - 4.0])
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
	titulo.position = Vector2(MARGEM, 6)
	titulo.add_theme_color_override("font_color", TINTA)
	titulo.add_theme_font_size_override("font_size", 15)
	root.add_child(titulo)

	var inicio := (_pagina - 1) * por_pagina
	var fim: int = mini(inicio + por_pagina, nomes.size())
	for i in range(inicio, fim):
		var n: String = nomes[i]
		var k := i - inicio
		var r: Rect2i = recortes[n]
		var canto := Vector2(MARGEM + (k % colunas) * celula.x,
			CABECALHO + float(k / colunas) * celula.y)

		var piso := ColorRect.new()
		piso.color = CHAO
		piso.position = canto
		piso.size = Vector2(celula.x - 6, celula.y - RODAPE)
		root.add_child(piso)

		var atlas := AtlasTexture.new()
		atlas.atlas = texturas[n]
		atlas.region = Rect2(r)
		var arte := TextureRect.new()
		arte.texture = atlas
		arte.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.stretch_mode = TextureRect.STRETCH_SCALE
		arte.size = Vector2(r.size) * ZOOM
		arte.position = canto + Vector2(
			(celula.x - 6 - arte.size.x) / 2.0,
			(celula.y - RODAPE - arte.size.y) / 2.0)
		root.add_child(arte)

		var rotulo := Label.new()
		rotulo.text = n.get_basename()
		rotulo.position = canto + Vector2(2, celula.y - RODAPE + 1)
		rotulo.add_theme_color_override("font_color", TINTA_FRACA)
		rotulo.add_theme_font_size_override("font_size", FONTE_NOME)
		root.add_child(rotulo)
		_pecas += 1

	return true
