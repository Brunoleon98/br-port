extends PainelNarrativo

# A inicial guarda só as decisões de entrar no porto; as consultas continuam
# nas mesmas cenas da pausa, reunidas aqui sem ler ou escrever uma partida.
signal pedir_ajustes
signal pedir_como_jogar
signal pedir_diagnostico


func _ready() -> void:
	super._ready()
	montar(460, 0, ESCURO_DECISAO)
	titulo_encorpado(Icones.AJUSTES, "Configurações")
	_opcao("Ajustes", func(): pedir_ajustes.emit())
	_opcao("Como jogar", func(): pedir_como_jogar.emit())
	_opcao("Versão e diagnóstico", func(): pedir_diagnostico.emit())
	botao_fechar("Voltar")


func _opcao(texto: String, acao: Callable) -> void:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, 56)
	botao.pressed.connect(acao)
	_vbox.add_child(botao)
