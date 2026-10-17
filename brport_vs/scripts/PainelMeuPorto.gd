extends PainelNarrativo

# Overlay da inicial, antes do Main armar o registro ou recuperar decisões.
# Fechar volta à inicial; só o botão explícito segue para o porto (`125`).
signal entrar_no_porto

const Conteudo := preload("res://scripts/ConteudoMeuPorto.gd")
var tempo: StringName = &""
var resumo: Dictionary = {}
var _entrando := false


func setup(disponivel: Variant = true) -> void:
	montar(560, 780 if bool(disponivel) else 0)
	titulo_encorpado(Icones.BARCO, "Meu porto agora")
	if not bool(disponivel):
		tempo = &"indisponivel"
		paragrafo("Não foi possível retomar esta partida. Volte ao início para escolher um porto disponível.")
		botao_fechar("Voltar ao início").custom_minimum_size.y = 56
		return
	tempo = &"resumo"
	resumo = Conteudo.resumir(get_tree().root.get_node("GameState"))
	var porto := paragrafo(resumo["porto"])
	porto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	porto.theme_type_variation = &"RotuloSecao"
	tarja(resumo["dia"], resumo["semana"])
	var rolo := ScrollContainer.new()
	rolo.name = "Leitura"
	rolo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_vbox.add_child(rolo)
	var corpo := VBoxContainer.new()
	corpo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corpo.add_theme_constant_override("separation", 10)
	rolo.add_child(corpo)
	if resumo["situacao"] != "":
		_linha(corpo, "Situação", resumo["situacao"])
	_linha(corpo, "Caixa atual", resumo["caixa"])
	_linha(corpo, "Obra em andamento", resumo["obra"])
	_linha(corpo, "Serviços contratados", "Nenhum serviço contratado nas docas." if resumo["servicos"].is_empty()
		else "\n\n".join(resumo["servicos"]))
	_linha(corpo, "Cobrança", resumo["cobranca"])
	_linha(corpo, "Meta atual", resumo["meta"])
	var entrar := Button.new()
	entrar.name = "IrAoPorto"
	entrar.text = "Ir ao porto"
	entrar.theme_type_variation = &"BotaoPrimario"
	entrar.custom_minimum_size.y = 56
	entrar.pressed.connect(_entrar)
	_vbox.add_child(entrar)
	botao_fechar("Voltar ao início").custom_minimum_size.y = 56
	entrar.grab_focus()


func _linha(onde: VBoxContainer, titulo_linha: String, texto: String) -> void:
	var titulo := Label.new()
	titulo.text = titulo_linha
	titulo.theme_type_variation = &"RotuloSecao"
	onde.add_child(titulo)
	var linha := Label.new()
	linha.text = texto
	linha.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	onde.add_child(linha)


func _entrar() -> void:
	if _entrando or is_queued_for_deletion():
		return
	_entrando = true
	entrar_no_porto.emit()
	super._fechar()
