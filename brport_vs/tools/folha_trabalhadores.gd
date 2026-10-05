extends SceneTree

# ============================================================
# BR Port VS — folha de contato dos TRABALHADORES
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Os trinta rostos (`docs/decisoes/059`), cada um num cartão de VERDADE — o
# `DocaCartao.tscn`, com o tema e o `refresh()` do jogo —, sobre o fundo da
# barra onde eles vivem. Até à `083` era o cartão do trabalhador, na fileira
# que a fila no fundeadouro substituiu; desde então a cara de cada um mora no
# cabeçalho da doca do píer dele.
#
# ⚠️ ELA EXISTE PELA REGRA DA ARTE QUE VARIA COM O SORTEIO (`CLAUDE.md`, Arte):
# o porto tem no máximo três trabalhadores e o rosto de cada um sai ao nascer,
# logo as fotos de jogo da bateria mostram três dos trinta, e sempre os
# mesmos três (a semente é fixa). Os outros vinte e sete ficavam gerados,
# validados e por olhar — o buraco do `barco_medio`. Esta folha percorre a
# tabela e não depende de sorteio.
#
# ⚠️ E PERCORRE O REGISTO DO JOGO, nunca uma lista escrita aqui: o rosto k é o
# `Retratos.TRABALHADORES[k]`, e o cartão recebe-o pela porta do jogo — um
# trabalhador no `GameState` com `rosto = k` e o `setup()` —, não por uma
# textura posta à mão. Um cartão que mostrasse o arquivo errado passaria numa
# folha que pusesse a textura ela própria.
#
# ⚠️ E CADA RETRATO TEM DE CHEGAR À FOTO, pela mesma régua da `folha_frota`:
# duas fotos, com e sem o retrato, e os pixels que mudam por cartão
# (`PropIso.desenho_na_foto`). Um cartão que mostrasse o arquivo errado também
# reprova: o `resource_path` da textura tem de ser o do registo.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/folha_trabalhadores.gd -- saida.png
# ============================================================

const SAIDA_PADRAO := "user://folha_trabalhadores.png"
const RETRATO := "Coluna/Cabecalho/Placa/Retrato"
const FRAMES_ATE_ASSENTAR := 8
# O fundo da barra inferior, onde os cartões vivem (`CLAUDE.md`, Arte: cartão
# escuro sobre fundo escuro ganha corpo por borda, e é isso que se tem de ver).
const FUNDO_FOLHA := Color(0.051, 0.102, 0.149)     # #0d1a26
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)
# CINCO e não seis desde 04/10 (`081`): o cartão passou a duas colunas, com o
# retrato ao lado do número, e o mínimo dele subiu de 108 para ~130 px.
# TRÊS desde a `083`: o cartão da doca tem 224 px de mínimo, e três cabem nos
# 720 da tela com os vãos.
const COLUNAS := 3
const MARGEM := 10
const VAO := 6
# 32 e não 46, e a legenda a 14 e não 16, desde a placa do retrato a 52 px
# (`083`, terceira passagem): o cartão da doca cresceu 8 px, e dez linhas
# pediam 1.306 px na tela de 1.280 — a conta de baixo reprovou, como devia.
# A folha encolheu as folgas dela, e não o cartão: o cartão é o do jogo.
const CABECALHO := 32
# Numa linha só, «h · jovem · parda», e não uma por linha: com três colunas são
# dez linhas de cartões, e as legendas de três linhas não cabiam na tela.
const LEGENDA := 14
# Medido: o menor retrato muda 950 px na placa de 52 do cabeçalho da doca (um
# homem jovem de pele branca, o de menos contraste com a placa). O defeito (o retrato escondido também na primeira foto) dá ZERO
# exato; o corte fica a meio da banda. Era 1.203, a meio dos 2.407 do cartão
# de 70 do trabalhador, que saiu com a fila (`083`): a primeira corrida com o
# cartão novo reprovou os trinta, que é o que um número em pixel escrito à mão
# faz quando o que ele descreve muda de tamanho. E mudou mais duas vezes na
# mesma conversa — a placa passou de 30 a 44 e a 52 px a pedido do Bruno, e o
# mínimo de 239 a 635 e a 950: quem mexe na placa remede aqui.
const DESENHO_MIN := 475

var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _foto: Image = null
var _cartoes: Array = []
var _falhas := 0


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		if not _montar():
			quit(1)
			return false
		return false
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false
	if _foto == null:
		_conferir_texturas()
		# ⚠️ A FOTO É O ÚLTIMO FRAME DESENHADO, não o estado de agora: o que se
		# muda nesta volta só chega ao frame seguinte. O primeiro mutante desta
		# guarda escondia os retratos AQUI, antes desta linha, e a folha passou
		# com 2.407 px — o defeito nunca chegou à foto. Escondidos ao montar,
		# deram zero exato e os trinta reprovaram.
		_foto = root.get_texture().get_image()
		for par in _cartoes:
			((par[0] as Node).get_node(RETRATO) as CanvasItem).self_modulate.a = 0.0
		_frames = 0
		return false
	var ausentes := _retratos_ausentes(_foto, root.get_texture().get_image())
	var erro := _foto.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	if ausentes + _falhas > 0:
		print("FALHOU: %d retrato(s) fora da foto ou trocados — ver acima"
			% (ausentes + _falhas))
		quit(1)
		return true
	print("Folha salva em %s (%dx%d) — %d trabalhadores" % [
		_saida, _foto.get_width(), _foto.get_height(), _cartoes.size()])
	quit(0)
	return true


func _retratos_ausentes(com: Image, sem: Image) -> int:
	var ausentes := 0
	var menor := -1
	var menor_nome := ""
	for par in _cartoes:
		var arte := (par[0] as Node).get_node(RETRATO) as TextureRect
		var n := PropIso.desenho_na_foto(com, sem, arte.get_global_rect())
		if n < DESENHO_MIN:
			print("FALHOU  %s não chegou à foto: %d px mudam ao escondê-lo"
				% [par[1], n])
			ausentes += 1
		if menor < 0 or n < menor:
			menor = n
			menor_nome = par[1]
	print("Menor retrato na foto: %d px (%s)" % [menor, menor_nome])
	return ausentes


## O cartão tem de estar a mostrar o arquivo do REGISTO, e não o padrão da
## cena: é a pergunta que a foto sozinha não faz — 29 dos 30 diferem do
## padrão, mas um cartão pregado nele passaria por «tem desenho».
func _conferir_texturas() -> void:
	for k in range(_cartoes.size()):
		var arte := (_cartoes[k][0] as Node).get_node(RETRATO) as TextureRect
		var tem: String = arte.texture.resource_path if arte.texture != null else "(nada)"
		if tem != _cartoes[k][2]:
			print("FALHOU  o cartão do rosto %d mostra %s, e o registo diz %s"
				% [k, tem, _cartoes[k][2]])
			_falhas += 1


func _montar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]
	# ⚠️ `load()` E NÃO `preload()`: o `DocaCartao.gd` e o `Retratos.gd` falam do
	# autoload, e um script alcançado por `preload` a partir de um `--script` é
	# compilado antes de ele existir (a regra do `CLAUDE.md`).
	var retratos: Script = load("res://scripts/Retratos.gd")
	var caminhos: Array = retratos.get_script_constant_map()["TRABALHADORES"]
	var cena := load("res://scenes/dock/DocaCartao.tscn") as PackedScene
	var GS: Node = root.get_node("GameState")
	if cena == null or GS == null:
		print("FALHOU — o DocaCartao.tscn ou o GameState não carregou")
		return false

	# O PORTO DA FOLHA: uma doca por rosto, cada uma a operar um barco com o
	# trabalhador do píer dela — o retrato a cheio, que é como o jogador o vê
	# a trabalhar (sem barco ele sai esbatido, à espera). O rosto entra à mão
	# porque é isso que a folha percorre; o resto do dicionário sai dos
	# construtores do jogo, que dizem a forma de um trabalhador e de um barco.
	GS.phase = "playing"
	GS.docks = []
	GS.workers = []
	for k in range(caminhos.size()):
		var w: Dictionary = GS.novo_trabalhador()
		w["rosto"] = k
		GS.workers.append(w)
		GS.docks.append({"boat": GS._make_boat(), "worker_id": int(w["id"])})

	var raiz := Control.new()
	raiz.anchor_right = 1.0
	raiz.anchor_bottom = 1.0
	# ⚠️ Sem o tema o cartão nasce com o cinzento padrão do Godot: é a
	# fotografia mentirosa da regra 6 do `CLAUDE.md`.
	raiz.theme = load("res://ui/tema_brport.tres")
	root.add_child(raiz)
	var fundo := ColorRect.new()
	fundo.color = FUNDO_FOLHA
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	raiz.add_child(fundo)
	var titulo := Label.new()
	titulo.text = "TRABALHADORES — os %d rostos do cartão, pelo registo do jogo" % caminhos.size()
	titulo.position = Vector2(MARGEM, MARGEM)
	titulo.add_theme_color_override("font_color", TINTA)
	raiz.add_child(titulo)

	# ⚠️ A CÉLULA É A DO MAIOR CARTÃO, e não a do primeiro. Até 04/10 a folha
	# media o «#1» e punha os outros na mesma grelha; com o número ao lado do
	# retrato (`081`), «#10» a «#30» são mais largos e sobrepunham-se ao
	# vizinho, sem erro nenhum. Mede-se todos, e todos ficam com a mesma caixa.
	var larg := 0.0
	var alt := 0.0
	var montados: Array = []
	for k in range(caminhos.size()):
		var cartao: PanelContainer = cena.instantiate()
		raiz.add_child(cartao)
		cartao.setup(k)
		montados.append(cartao)
		larg = maxf(larg, cartao.get_combined_minimum_size().x)
		alt = maxf(alt, cartao.get_combined_minimum_size().y)
	for k in range(caminhos.size()):
		var cartao: PanelContainer = montados[k]
		cartao.size = Vector2(larg, alt)
		var col := k % COLUNAS
		var lin := k / COLUNAS
		cartao.position = Vector2(MARGEM + col * (larg + VAO),
			CABECALHO + lin * (alt + LEGENDA + VAO))
		var nome := String(caminhos[k]).get_file().get_basename().trim_prefix("trabalhador_")
		var legenda := Label.new()
		legenda.text = nome.replace("_", " · ") if nome != "retrato" else "padrão"
		legenda.add_theme_font_size_override("font_size", 10)
		legenda.add_theme_color_override("font_color", TINTA_FRACA)
		legenda.position = cartao.position + Vector2(2, alt)
		raiz.add_child(legenda)
		_cartoes.append([cartao, nome, String(caminhos[k])])

	# ⚠️ FOLHA QUE TRANSBORDA CORTA EM SILÊNCIO: a conta reprova em vez de
	# recortar (a regra da `folha_frota`).
	var linhas := int(ceil(caminhos.size() / float(COLUNAS)))
	var pede := CABECALHO + linhas * (alt + LEGENDA + VAO)
	var tela := float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var largura := MARGEM + COLUNAS * (larg + VAO)
	if pede > tela or largura > float(ProjectSettings.get_setting(
			"display/window/size/viewport_width")):
		print("FALHOU — a folha pede %.0f x %.0f px e a tela não chega." % [largura, pede])
		return false
	return true
