extends PainelNarrativo

# ============================================================
# BR Port VS — o menu de PAUSA, curto (`docs/decisoes/066`)
#
# Três botões: Continuar, Ajustes e Salvar e sair — o padrão que a pesquisa
# da família do sistema achou nos jogos de gestão (pista pela busca; as páginas
# não se leem nestas sessões, `063`). Até 26/09 a pausa carregava volume,
# registro e «Novo jogo (apaga progresso)» num cartão de 280 px, com o botão
# destrutivo a um dedo do «Continuar».
#
#  - o VOLUME e o REGISTRO foram para a tela Ajustes, que a tela inicial
#    também abre: uma tela, duas portas;
#  - o «NOVO JOGO» deixou de existir aqui. A partida nova nasce na tela
#    inicial, num dos três espaços de save, e só apaga um porto depois de
#    perguntar qual;
#  - o «SALVAR E SAIR» leva à tela inicial. «Salvar» é verdade sem ser trabalho:
#    o jogo já grava a cada lance, e o botão só grava mais uma vez por
#    garantia antes de sair.
#
# ⚠️ NÃO HÁ «SAIR DO JOGO». No Android a regra do sistema é não ter botão de
# fechar a aplicação — o Voltar na tela inicial fecha-a —, e no desktop a
# janela tem o dela.
#
# É um OVERLAY, como todo painel: fechar a pausa não mexe em fase nenhuma do
# `GameState`, e o balanceamento medido fica intocado por construção.
# ============================================================

## Pedido para reabrir o balanço da partida. É SINAL e não uma chamada direta
## ao `Main`: este menu vive no `_overlay_layer` e não conhece quem o abriu —
## alcançar o pai pelo caminho seria um `get_parent().get_parent()` que quebra
## calado no dia em que a árvore mudar.
signal ver_balanco
## Pedido para abrir a tela Ajustes, pela mesma razão: quem abre painéis — e
## lhes dá o tema — é o `Main`.
signal pedir_ajustes
## Pedido para voltar à tela inicial. Quem troca de cena é o `Main`, que é
## também quem armou o gravador da partida e o tem de desarmar.
signal sair_para_inicio

const LARGURA := 460
const ALTURA_BOTAO := 56


func _ready() -> void:
	super._ready()
	montar(LARGURA, 0, ESCURO_DECISAO)
	titulo_encorpado(Icones.PAUSAR, "Pausado")

	# ONDE SE ESTÁ, numa linha: o cais, o dia e o espaço. Com três partidas no
	# aparelho, «Salvar e sair» pede que se saiba QUAL se está a deixar.
	var onde := paragrafo("%s · dia %d de %d · espaço %d de %d" % [
		GameState.texto("{portName}"),
		mini(GameState.turn, GameState.TURNS_TOTAL), GameState.TURNS_TOTAL,
		GameState.espaco, GameState.ESPACOS])
	onde.theme_type_variation = &"RotuloApoio"

	var continuar := botao_fechar("Continuar")
	continuar.theme_type_variation = &"BotaoPrimario"
	continuar.custom_minimum_size = Vector2(0, ALTURA_BOTAO)

	_botao("Ajustes", func() -> void:
		pedir_ajustes.emit())

	# ⚠️ A PORTA DE VOLTA AO BALANÇO, e ela existe por causa do botão de fechar
	# que o `EndGame.gd` ganhou em 07/09. Fechar o balanço para chegar AQUI
	# (que é o que a segunda jogada pediu) não pode custar o balanço para
	# sempre — seria trocar um beco sem saída por outro. Só aparece com a
	# partida terminada: no meio de um jogo não há balanço nenhum a ver.
	if GameState.phase == "game_over":
		_botao("Ver o balanço da partida", func() -> void:
			ver_balanco.emit()
			queue_free())

	_botao("Salvar e sair", func() -> void:
		sair_para_inicio.emit())


func _botao(texto: String, ao_tocar: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, ALTURA_BOTAO)
	botao.pressed.connect(ao_tocar)
	_vbox.add_child(botao)
	return botao
