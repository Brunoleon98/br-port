extends PainelNarrativo

# Consulta opcional: índice → artigo → índice → origem (`114`/`115`).
# O dono trata o Voltar do aparelho pelo mesmo _fechar() que os botões.
# A pausa continua por baixo; a ajuda nunca muda o estado do turno.
const Conteudo := preload("res://scripts/ConteudoComoJogar.gd")
const LARGURA := 560
const ALTURA := 780
const ALTURA_BOTAO := 56

var tempo: StringName = &""
var assunto_atual := ""
var artigos: Array = []
var _rolo: ScrollContainer
var _posicoes := {}
var _ultimo_assunto := ""
var _revisao := 0


func _ready() -> void:
	super._ready()
	montar(LARGURA, ALTURA)
	artigos = Conteudo.artigos(get_tree().root.get_node("GameState"))
	_mostrar("")


func _mostrar(id: String) -> void:
	if _rolo != null:
		_posicoes[assunto_atual] = MemoriaDeLeitura.marcar(_rolo)
	assunto_atual = id
	_revisao += 1
	for filho in _vbox.get_children():
		_vbox.remove_child(filho)
		filho.queue_free()
	var titulo_pagina := "Como jogar"
	var texto := "Escolha um assunto para consultar."
	if id != "":
		for artigo in artigos:
			if artigo["id"] == id:
				titulo_pagina = artigo["titulo"]
				texto = artigo["texto"]
				break
		_ultimo_assunto = id
		if id == "glossario":
			tempo = &"glossario"
		else:
			tempo = &"artigo"
	else:
		tempo = &"indice"
	titulo_encorpado(Icones.DIARIO, titulo_pagina)
	if id == "":
		var apoio := paragrafo(texto)
		apoio.theme_type_variation = &"RotuloApoio"
	_rolo = ScrollContainer.new()
	_rolo.name = "Leitura"
	_rolo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_vbox.add_child(_rolo)
	var foco: Button
	if id == "":
		var lista := VBoxContainer.new()
		lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lista.add_theme_constant_override("separation", 10)
		_rolo.add_child(lista)
		for artigo in artigos:
			var botao := Button.new()
			botao.name = String(artigo["id"])
			botao.text = artigo["titulo"]
			botao.custom_minimum_size.y = ALTURA_BOTAO
			# bind fixa a identidade; o callback não depende da última volta.
			botao.pressed.connect(_mostrar.bind(String(artigo["id"])))
			lista.add_child(botao)
			if foco == null or artigo["id"] == _ultimo_assunto:
				foco = botao
	else:
		var corpo := Label.new()
		corpo.name = "TextoDoArtigo"
		corpo.name = "Corpo"
		corpo.text = texto
		corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_rolo.add_child(corpo)
	var voltar := botao_fechar("Fechar" if id == "" else "Assuntos")
	voltar.name = "Voltar"
	voltar.custom_minimum_size.y = ALTURA_BOTAO
	if foco == null:
		foco = voltar
	_restaurar_leitura(_revisao, foco)


func _restaurar_leitura(revisao: int, foco: Button) -> void:
	# O layout e a barra ainda não conhecem a altura do texto neste frame.
	# Duas esperas, como os outros painéis; a revisão invalida navegação antiga.
	var arvore := get_tree()
	await arvore.process_frame
	# O percurso do contraste remove o painel antes deste frame; consultar
	# get_tree() de novo ali já retornava null. A referência não dispensa a
	# guarda: um nó que saiu da árvore não deve receber foco nem rolagem.
	if not is_inside_tree() or is_queued_for_deletion():
		return
	await arvore.process_frame
	if revisao != _revisao or not is_inside_tree() or is_queued_for_deletion():
		return
	foco.grab_focus()
	MemoriaDeLeitura.restaurar(_rolo, _posicoes.get(assunto_atual, {}))


func _fechar() -> void:
	if assunto_atual != "":
		_mostrar("")
	else:
		super._fechar()
