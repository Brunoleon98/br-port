extends SceneTree

# ============================================================
# BR Port VS — folha de contato dos ícones
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Desenha todos os ícones de art/icones/ sobre os TRÊS fundos que existem na
# interface — pílula escura da HUD, cartão branco e botão navy — em dois
# tamanhos: o de uso real (19px) e um ampliado, para conferir o desenho.
#
# O teste que importa é a coluna de 19px. Um ícone que só se lê ampliado não
# serve: na tela ele vive pequeno, sobre fundo escuro. Se sumir aqui, volta
# para a prancheta.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/folha_icones.gd -- [saida.png]
#
# A tela do projeto é retrato com aspecto travado: pedir uma resolução larga
# devolve a folha espremida. Três colunas é o que cabe em 720 de largura, e o
# porquê desse número está na constante.
# ============================================================

const SAIDA_PADRAO := "user://folha_icones.png"
const FRAMES_ATE_ASSENTAR := 8

const PASTA := "res://art/icones"

# ⚠️ TRÊS COLUNAS DESDE 13/09, E O NÚMERO SAIU DE UMA MEDIÇÃO. A duas colunas
# a folha cabia em 20 ícones e rebentava aos 23: 12 linhas pedem 1326 px numa
# tela de 1280, e a conta abaixo mostra que os três ícones do menu-celular não
# caberiam. A célula encolheu de 330 para 222 porque o conteúdo dela mede 189
# px — a amostra de 44 mais as três de 19, com as separações e as margens —,
# de modo que as três colunas cabem nos 688 px úteis com folga.
const COLUNAS := 3
const CELULA := Vector2(222, 100)
const MARGEM := 16
# A separação é UMA constante porque o desenho e a conta do transbordo têm de
# ler o mesmo número: escrita duas vezes, a guarda mediria uma folha que não é
# a que se desenha.
const SEPARACAO := 10

const FUNDO_FOLHA := Color(0.878, 0.914, 0.965)
const FUNDO_PILULA := Color(0.09, 0.16, 0.24)
const FUNDO_CARTAO := Color(1, 1, 1)
const FUNDO_BOTAO := Color(0.11, 0.204, 0.329)

var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _nomes: PackedStringArray = []


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
	print("Folha salva em %s (%dx%d) — %d ícones" % [
		_saida, img.get_width(), img.get_height(), _nomes.size()])
	quit(0)
	return true


func _montar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]

	_nomes = _listar_icones()

	var fundo := ColorRect.new()
	fundo.color = FUNDO_FOLHA
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	root.add_child(fundo)

	var grade := GridContainer.new()
	grade.columns = COLUNAS
	grade.position = Vector2(MARGEM, MARGEM)
	grade.add_theme_constant_override("h_separation", SEPARACAO)
	grade.add_theme_constant_override("v_separation", SEPARACAO)
	fundo.add_child(grade)

	for nome in _nomes:
		grade.add_child(_celula(nome))

	# ⚠️ FOLHA QUE TRANSBORDA CORTA EM SILÊNCIO — e esta é a IRMÃ da folha da
	# frota, que ganhou esta mesma conta em 07/09 sem ninguém vir aqui pô-la.
	# É a regra do `CLAUDE.md` a cobrar a fatura: ao corrigir um, varra os
	# irmãos. Medido em 13/09, antes do conserto: a duas colunas ela cabia em
	# 22 ícones e o 23.º empurrava a última linha 46 px para fora da tela,
	# ficando gerado, registado no `Icones.gd` e por olhar — que é o buraco
	# que uma folha de contato existe para tapar. O `capturar_evidencia.sh`
	# não podia apanhar: ele confere que o PNG tem mais de 20 KB e que a linha
	# "Folha salva em" apareceu, e uma folha cortada cumpre as duas.
	var linhas: int = int(ceil(float(_nomes.size()) / float(COLUNAS)))
	var pede: float = MARGEM + linhas * CELULA.y + maxi(linhas - 1, 0) * SEPARACAO
	var altura: float = float(ProjectSettings.get_setting(
		"display/window/size/viewport_height"))
	if pede > altura:
		print("FALHOU — a folha pede %.0f px de altura e a tela tem %.0f. "
			% [pede, altura]
			+ "Ela cortaria os últimos ícones sem o dizer (%d ícones, %d linhas)."
			% [_nomes.size(), linhas])
		quit(1)
		return


func _listar_icones() -> PackedStringArray:
	var nomes: PackedStringArray = []
	var dir := DirAccess.open(PASTA)
	if dir == null:
		push_error("não abriu %s" % PASTA)
		return nomes
	for arquivo in dir.get_files():
		# Fora do editor os arquivos chegam com o sufixo do import.
		var limpo := arquivo.trim_suffix(".import")
		if limpo.ends_with(".svg") and not nomes.has(limpo):
			nomes.append(limpo)
	nomes.sort()
	return nomes


func _celula(arquivo: String) -> Control:
	var icone: Texture2D = load("%s/%s" % [PASTA, arquivo])

	var caixa := PanelContainer.new()
	caixa.custom_minimum_size = CELULA
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = FUNDO_FOLHA
	estilo.set_corner_radius_all(8)
	estilo.set_content_margin_all(8)
	caixa.add_theme_stylebox_override("panel", estilo)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	caixa.add_child(coluna)

	var titulo := Label.new()
	titulo.text = arquivo.trim_suffix(".svg")
	titulo.add_theme_font_size_override("font_size", 12)
	titulo.add_theme_color_override("font_color", Color(0.11, 0.204, 0.329))
	coluna.add_child(titulo)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	coluna.add_child(linha)

	# 19px é o tamanho de uso. Os três fundos são os que a interface tem.
	linha.add_child(_amostra(icone, 19, FUNDO_PILULA))
	linha.add_child(_amostra(icone, 19, FUNDO_CARTAO))
	linha.add_child(_amostra(icone, 19, FUNDO_BOTAO))
	linha.add_child(_amostra(icone, 44, FUNDO_CARTAO))
	return caixa


func _amostra(icone: Texture2D, tamanho: int, fundo: Color) -> Control:
	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fundo
	estilo.set_corner_radius_all(6)
	estilo.set_content_margin_all(6)
	painel.add_theme_stylebox_override("panel", estilo)

	var img := TextureRect.new()
	img.texture = icone
	img.custom_minimum_size = Vector2(tamanho, tamanho)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	painel.add_child(img)
	return painel
