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

var _falhas := 0
var _conferidos := 0


func _process(_delta: float) -> bool:
	var manifesto := _ler(MANIFEST)
	if manifesto.is_empty():
		_erro("manifest ilegível: %s" % MANIFEST)
		_fim()
		return true

	_contrato_bate_com_o_mapa(manifesto)
	_assets(manifesto)
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
		for pasta in ["props", "brp", "sprites", "tiles"]:
			var tentativa := "res://art/%s/%s" % [pasta, arquivo]
			if ResourceLoader.exists(tentativa):
				achado = tentativa
				break
		if achado == "":
			_erro("%s: no manifest e não no disco" % arquivo)
			continue

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
		var img := tex.get_image()
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
		print("=== ASSET OK — %d assets conferidos ===" % _conferidos)
		quit(0)
	else:
		print("=== %d PROBLEMA(S) DE ASSET ===" % _falhas)
		quit(1)
