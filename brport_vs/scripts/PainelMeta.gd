extends PainelNarrativo

# A meta não corre contra relógio. As barras contam dias fechados, obras
# concluídas e serviço entregue; um barco apenas atracado não cumpre missão.
func setup(_sem_argumentos: Variant = null) -> void:
	montar(520, 0)
	titulo_encorpado(Icones.VITORIA, "Meta da Fase 2")
	var meta: Dictionary = GameState.progresso_da_meta()
	if meta.is_empty():
		paragrafo("A meta abre na Fase 2.")
		botao_fechar("Fechar")
		return
	tarja("Fase concluída — jogo livre" if meta["concluida"] else "Sem prazo para concluir",
		"O porto segue enquanto houver dinheiro.")
	secao("REPUTAÇÃO COMERCIAL")
	paragrafo("Feche %s seguidos com reputação de pelo menos %d." % [
		Narrativa.concordar(int(meta["dias_alvo"]), "dia", "dias"), int(meta["reputacao_alvo"])])
	_barra("Reputacao", int(meta["dias"]), int(meta["dias_alvo"]))
	secao("INFRAESTRUTURA")
	paragrafo("Píer 3 e guindaste de treliça prontos. A obra só conta depois de concluída.")
	_barra("Infraestrutura", int(meta["infra"]), int(meta["infra_alvo"]))
	secao("MISSÃO DO PORTO")
	paragrafo(Narrativa.missao_da_fase_2())
	_barra("Missao", int(meta["missao"]), 1)
	fio()
	paragrafo(GameState.regra_dos_cargueiros())
	if meta["concluida"]:
		var reler := Button.new()
		reler.text = "Reler a página do diário"
		reler.custom_minimum_size.y = TOQUE_MIN
		reler.pressed.connect(func():
			var diario = load("res://scenes/panels/DiarioFase2.tscn").instantiate()
			diario.theme = theme
			get_parent().add_child(diario)
			diario.setup()
			queue_free())
		_vbox.add_child(reler)
	botao_fechar("Voltar ao porto")


func _barra(nome: String, valor: int, alvo: int) -> void:
	var barra := barra_do_hud(valor, alvo)
	barra.name = nome
	_vbox.add_child(barra)
	paragrafo("%d de %d" % [valor, alvo])
