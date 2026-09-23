extends SceneTree
## BRP — validação do lado do Godot. FASE 12 do prompt mestre.
##
##   Godot --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
##
## O validador do Blender (`blender/validate_brp_assets.py`) confere o que só
## existe com a cena montada: âncora, apoio, coleção, volume de seleção. Este
## confere o que sobreviveu ao render e chegou ao jogo: o arquivo existe, tem o
## quadro que o manifest promete, tem alfa de verdade, e — o mais importante —
## **a projeção que gerou os PNGs é a mesma que o mapa desenha**.
##
## Essa última é a que paga o preço do arquivo. A projeção é um contrato entre
## `gerar_mapa_iso.py`, `gerar_props_iso.py` e as cenas; agora há um quarto
## participante, o pipeline BRP, e um contrato com quatro lados quebra sem
## avisar. Aqui ele avisa.
##
## Espera-se `ASSET OK` e código de saída 0.

const MANIFEST := "res://data/assets/BRP_EXPORT_MANIFEST.json"
const ANCORAS := "res://art/porto_mapa_ancoras.json"
const PASTA_PROPS := "res://art/props"

## A fração do quadro que o desenho ocupa, abaixo da qual o prop TEM de estar
## em atlas (`docs/decisoes/049`). Medido nos 69 em 23/09: os 60 de mapa vão de
## 0,04% (o poste) a 16,3% (o `trabalhador_retrato`); os nove retratos de fala,
## de 55,5% a 62,3%. O corte é o meio geométrico da banda — folga de 1,8x para
## cada lado. Não decide o que fica FORA: isso é a outra pergunta, derivada.
const CORTE_ATLAS := 0.30

## O limiar do `fix_alpha_border` do importador, medido: abaixo dele o Godot
## reescreve o RGB da borda quase transparente em QUALQUER textura, com atlas ou
## sem. Em 23/09 os 69 props diferiam do arquivo SÓ aí (alfa máximo 16), e zero
## pixels acima. Comparar o RGB desses pixels reprovaria todos os props certos.
const ALFA_REESCRITO := 20

var _falhas := 0
var _conferidos := 0
var _em_atlas := 0


func _process(_delta: float) -> bool:
	var manifesto := _ler(MANIFEST)
	if manifesto.is_empty():
		_erro("manifest ilegível: %s" % MANIFEST)
		_fim()
		return true

	_contrato_bate_com_o_mapa(manifesto)
	_assets(manifesto)
	_props_no_atlas()
	_fim()
	return true


func _ler(caminho: String) -> Dictionary:
	var f := FileAccess.open(caminho, FileAccess.READ)
	if f == null:
		return {}
	var lido: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return lido if typeof(lido) == TYPE_DICTIONARY else {}


## A projeção do manifest contra a que o mapa publica em porto_mapa_ancoras.json.
func _contrato_bate_com_o_mapa(manifesto: Dictionary) -> void:
	if not manifesto.has("contrato"):
		_erro("manifest sem bloco `contrato`")
		return
	var c: Dictionary = manifesto["contrato"]
	var ancoras := _ler(ANCORAS)
	if ancoras.is_empty() or not ancoras.has("projecao"):
		_erro("âncoras do mapa ilegíveis: %s" % ANCORAS)
		return
	var pr: Dictionary = ancoras["projecao"]

	_confere("meia_larg do pipeline == a do mapa",
		float(c["meia_larg"]) == float(pr["meia_larg"]),
		"pipeline %s, mapa %s" % [c["meia_larg"], pr["meia_larg"]])
	_confere("meia_alt do pipeline == a do mapa",
		float(c["meia_alt"]) == float(pr["meia_alt"]),
		"pipeline %s, mapa %s" % [c["meia_alt"], pr["meia_alt"]])

	# O ângulo da aresta é consequência dos dois acima; conferir os três
	# separadamente pega uma incoerência DENTRO do próprio manifest — alguém
	# que edite o JSON à mão em vez de regerar.
	var esperado := rad_to_deg(atan(float(c["meia_alt"]) / float(c["meia_larg"])))
	_confere("ângulo da aresta coerente com meia_larg/meia_alt",
		abs(float(c["angulo_aresta"]) - esperado) < 0.01,
		"manifest diz %.3f, a conta dá %.3f" % [c["angulo_aresta"], esperado])

	# A câmera do Blender é o que fixa o ângulo. 60° é o valor que produz a
	# razão 2:1; o guia do pacote de arte fixava só o Z e deixava este em
	# aberto, e foi por isso que metade do lote veio a 34,6°.
	_confere("rot_x da câmera é 60 (o número que o guia do pacote não fixava)",
		abs(float(c["rot_x"]) - 60.0) < 0.001,
		"manifest diz %s" % c["rot_x"])


func _assets(manifesto: Dictionary) -> void:
	if not manifesto.has("assets"):
		_erro("manifest sem lista `assets`")
		return

	for entrada in manifesto["assets"]:
		var ficha: Dictionary = entrada
		var arquivo: String = ficha["file"]
		var achado := ""
		var onde: Array[String] = []
		for pasta in ["props", "brp", "sprites", "tiles"]:
			var tentativa := "res://art/%s/%s" % [pasta, arquivo]
			if ResourceLoader.exists(tentativa):
				onde.append(pasta)
				if achado == "":
					achado = tentativa
		if achado == "":
			_erro("%s: no manifest e não no disco" % arquivo)
			continue

		# ⚠️ O MESMO NOME EM DUAS PASTAS, E A BUSCA ACIMA FICA COM A PRIMEIRA.
		# O `art/brp/README.md` avisa disto por escrito desde que existe:
		# `gerar_brp.py todos <dir>` despeja os 24 assets no MESMO diretório, e
		# nove deles vivem noutro — apontá-lo a `art/props` deixa lá cópias que
		# ninguém pediu. A busca acha a de `props`, passa, e ficam dois arquivos
		# a divergir a partir do dia seguinte.
		#
		# Até 16/09 isto era só um aviso num README, e um aviso num README não
		# é uma guarda: caí nele nesta mesma sessão, ao regerar o catálogo para
		# a alavanca B. Custa cinco linhas e fecha a porta.
		_confere("%s existe numa pasta só" % arquivo, onde.size() == 1,
			"está em art/%s — a busca fica com a primeira e a outra envelhece "
				% "/, art/".join(onde) + "em silêncio")

		_conferidos += 1
		var tex: Texture2D = load(achado)
		var quadro: Array = ficha["frame_size"]
		_confere("%s tem o quadro do manifest" % arquivo,
			tex.get_width() == int(quadro[0]) and tex.get_height() == int(quadro[1]),
			"disco %dx%d, manifest %sx%s" % [tex.get_width(), tex.get_height(),
				quadro[0], quadro[1]])

		# Alfa de verdade. Os dois lotes de arte que chegaram de fora vieram
		# com o xadrez PINTADO nos pixels; um PNG assim carrega, desenha e só
		# denuncia quando aparece um retângulo cinzento por cima do mapa.
		var img := PropIso.imagem(tex)
		_confere("%s tem canal alfa" % arquivo,
			img.detect_alpha() != Image.ALPHA_NONE,
			"o PNG é opaco de ponta a ponta")

		# Um prop com o quadro inteiro opaco não tem recorte nenhum: ou é um
		# tile de fundo (e aí não devia estar em art/props/) ou o alfa se
		# perdeu na exportação.
		if ficha["category"] != "terreno":
			_confere("%s não ocupa o quadro inteiro" % arquivo,
				not _quadro_cheio(img),
				"todos os cantos opacos — parece fundo, não prop")

		if bool(ficha["selectable"]):
			_confere("%s selecionável declara cena" % arquivo,
				String(ficha["godot_scene"]) != "",
				"`godot_scene` vazio: nada sabe o que abrir ao tocar")


## ⚠️ O QUADRO DE UM PROP DE MAPA NÃO VIVE NA VRAM (`docs/decisoes/049`).
##
## 89,6% do quadro de 768 é moldura vazia (`029`). O importador `texture_atlas`
## apara-a e devolve um `AtlasTexture` com a MARGEM a repor o quadro: o jogo vê
## os mesmos 768 e desenha no mesmo sítio, e a VRAM de textura em jogo caiu de
## 235,68 para 64,04 MB. Isto percorre a PASTA e não o manifest — o manifest
## tem 44 entradas e os props são 69 —, e faz três perguntas a cada um:
##
## 1. atlas que custa MAIS do que o quadro reprova. O empacotador arredonda a
##    largura a potência de dois, e um retrato de 510 px sai num atlas de 1024:
##    26% pior do que não o cortar. É por isto, e não por uma lista, que os
##    retratos de fala ficam de fora;
## 2. prop de moldura quase vazia FORA do atlas reprova — é o prop novo que
##    entrou pelo importador por omissão e trouxe o quadro inteiro;
## 3. o quadro reconstruído pelo `PropIso` é o desenho do ARQUIVO: alfa em
##    todo pixel e cor onde o alfa passa do `ALFA_REESCRITO`. É o que prova que
##    a margem repõe o desenho no sítio — uma margem errada move o prop inteiro
##    sem erro nenhum, e o `crop_to_region` encolhe o quadro.
func _props_no_atlas() -> void:
	for nome in DirAccess.get_files_at(PASTA_PROPS):
		if not nome.ends_with(".png"):
			continue
		var caminho := "%s/%s" % [PASTA_PROPS, nome]
		var tex: Texture2D = load(caminho)
		var quadro := PropIso.imagem(tex)
		var area := float(quadro.get_width() * quadro.get_height())
		var fracao := float(quadro.get_used_rect().get_area()) / area
		if not (tex is AtlasTexture):
			_confere("%s fica fora do atlas com o quadro cheio" % nome,
				fracao >= CORTE_ATLAS,
				"o desenho ocupa %.1f%% do quadro e o resto é moldura na VRAM — "
					% (100.0 * fracao)
					+ "importe-o como `texture_atlas` (`docs/decisoes/049`)")
			continue
		_em_atlas += 1
		var atlas := (tex as AtlasTexture).atlas
		_confere("%s: o atlas custa menos do que o quadro" % nome,
			float(atlas.get_width() * atlas.get_height()) < area,
			"atlas %dx%d contra quadro %dx%d — cortar sai mais caro"
				% [atlas.get_width(), atlas.get_height(), quadro.get_width(),
					quadro.get_height()])
		var arquivo := Image.load_from_file(ProjectSettings.globalize_path(caminho))
		_confere("%s: o quadro reconstruído é o desenho do arquivo" % nome,
			_mesmo_desenho(quadro, arquivo) == "", _mesmo_desenho(quadro, arquivo))


## "" se os dois desenham o mesmo; senão, a primeira diferença.
func _mesmo_desenho(a: Image, b: Image) -> String:
	if b == null:
		return "o arquivo não abre"
	if a.get_size() != b.get_size():
		return "quadro %s contra o arquivo %s" % [a.get_size(), b.get_size()]
	a = a.duplicate() as Image
	b = b.duplicate() as Image
	a.convert(Image.FORMAT_RGBA8)
	b.convert(Image.FORMAT_RGBA8)
	var r := b.get_used_rect()
	if a.get_used_rect() != r:
		return "desenho em %s, e o arquivo em %s" % [a.get_used_rect(), r]
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var p := a.get_pixel(x, y)
			var q := b.get_pixel(x, y)
			if p.a8 != q.a8 or (q.a8 >= ALFA_REESCRITO and
					(p.r8 != q.r8 or p.g8 != q.g8 or p.b8 != q.b8)):
				return "pixel (%d, %d): %s contra %s no arquivo" % [x, y, p, q]
	return ""


func _quadro_cheio(img: Image) -> bool:
	var l := img.get_width() - 1
	var a := img.get_height() - 1
	for p in [Vector2i(0, 0), Vector2i(l, 0), Vector2i(0, a), Vector2i(l, a)]:
		if img.get_pixelv(p).a < 0.5:
			return false
	return true


func _confere(rotulo: String, ok: bool, detalhe: String) -> void:
	if ok:
		print("  PASS  %s" % rotulo)
	else:
		_erro("%s — %s" % [rotulo, detalhe])


func _erro(msg: String) -> void:
	_falhas += 1
	print("  FALHOU  %s" % msg)


func _fim() -> void:
	print("")
	if _falhas == 0:
		print("=== ASSET OK — %d assets conferidos, %d props em atlas ==="
			% [_conferidos, _em_atlas])
		quit(0)
	else:
		print("=== %d PROBLEMA(S) DE ASSET ===" % _falhas)
		quit(1)
