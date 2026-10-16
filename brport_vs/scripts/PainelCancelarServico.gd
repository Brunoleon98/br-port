extends PainelNarrativo

var doca := -1
var barco_id := -1
var orcamento: Dictionary = {}
var _confirmar: Button
var _aviso: Label
var _respondido := false


func setup(indice: int, id: int) -> void:
	doca = indice
	barco_id = id
	orcamento = GameState.custos_do_cancelamento(doca, barco_id)
	add_to_group("confirmacao_cancelamento")
	montar(520, 0, ESCURO_DECISAO)
	titulo_encorpado(Icones.BARCO, "Cancelar serviço da Doca %d?" % (doca + 1))
	if orcamento.is_empty():
		paragrafo("Este serviço não está mais disponível para cancelamento.")
		botao_fechar("Voltar ao porto")
		return
	paragrafo("%s · %s · %d de %s." % [
		GameState.CLASSES_DE_NAVIO[orcamento["classe"]]["nome"],
		GameState.MOTIVOS[orcamento["motivo"]]["nome"],
		int(orcamento["operados"]), Narrativa.concordar(int(orcamento["total"]), "dia operado", "dias operados")])
	paragrafo("Você não receberá os %s previstos para este serviço, incluindo adicionais. Não há pagamento parcial." % GameState.moeda(int(orcamento["receita_abandonada"])))
	# O formatador do Godot não aceita %g: emitia erro de motor e texto vazio,
	# sem SCRIPT ERROR. String.num preserva a porcentagem lida da constante.
	paragrafo("Multa: %s (%s%% do acordo de %s, sem adicionais)." % [
		GameState.moeda(int(orcamento["multa"])), numero_da_confirmacao(GameState.CANCELAMENTO_MULTA * 100),
		GameState.moeda(int(orcamento["valor_acordado"]))])
	paragrafo("Reputação: %s → %s." % [numero_da_confirmacao(float(orcamento["rep_antes"])),
		numero_da_confirmacao(float(orcamento["rep_depois"]))])
	paragrafo("Caixa atual: %s. Após a multa: %s." % [
		GameState.moeda(int(orcamento["caixa_antes"])), GameState.moeda(int(orcamento["caixa_depois"]))])
	paragrafo("O barco vai embora definitivamente. A doca e o trabalhador ficam livres agora, sem passar o dia.")
	if int(orcamento["caixa_depois"]) < 0:
		paragrafo("O saldo ficará negativo. Recupere o caixa até o fecho do dia para não perder o porto.")
	_aviso = paragrafo("")
	_aviso.visible = false
	var continuar := botao_fechar("Continuar serviço")
	continuar.name = "ContinuarServico"
	continuar.theme_type_variation = &"BotaoPrimario"
	_confirmar = Button.new()
	_confirmar.name = "CancelarServico"
	_confirmar.text = "Cancelar serviço"
	_confirmar.theme_type_variation = &"BotaoPerigo"
	_confirmar.custom_minimum_size.y = TOQUE_MIN
	_confirmar.pressed.connect(confirmar)
	_vbox.add_child(_confirmar)
	continuar.grab_focus()


func confirmar() -> void:
	if _respondido or is_queued_for_deletion() or not is_inside_tree():
		return
	_respondido = true
	_confirmar.disabled = true
	if GameState.cancelar_servico(doca, barco_id, orcamento):
		_fechar()
	else:
		_aviso.text = "O serviço ou seus custos mudaram. Feche e abra novamente para conferir."
		_aviso.visible = true


static func numero_da_confirmacao(valor: float) -> String:
	return String.num(valor, 2).trim_suffix(".0").replace(".", ",")
