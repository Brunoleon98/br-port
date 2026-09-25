extends Control

# Contra-oferta do Arlindo — GDD, "Limiar de paciência do cliente":
# 3 presets em botões ("Igualar rival −15%" / "Cortar metade −7%" /
# "Manter preço") + mood face do cliente em 3 estados.
#
# O painel é só a tela: quem sorteia e decide é o GameState. A paciência
# restante também mora lá, para o autosave não devolver tentativas gastas.

var dock_index: int = -1
# O TEMPO DA CENA NA TELA, para quem a fotografa. A cobertura das capturas
# (`tools/conferir_cobertura_paineis.py`) lê daqui o catálogo — cada
# `tempo = &"..."` escrito neste arquivo é um tempo que tem de ter foto — e as
# ferramentas de captura imprimem o valor dele. ⚠️ SEMPRE LITERAL: uma
# atribuição por variável a ferramenta não sabe ler, e reprova em vez de a
# saltar (`docs/decisoes/051`).
var tempo: StringName = &""

var _mood_label: Label
# A fala do Arlindo troca a cada rodada da negociação: abertura, reação ao que
# o jogador ofereceu, e a linha da última tentativa. É guardada porque o painel
# não se reconstrói entre rodadas — só se refresca.
var _fala_arlindo: Label
var _valor_label: Label
var _mood_icone: TextureRect
# A linha inteira do humor do cliente, que sai no segundo tempo — ver
# `_despedida()`.
var _mood_linha: Control
# A cara dele, ao lado da fala. Guardada porque troca três vezes na mesma
# tela: abre a sorrir, aperta na última tentativa, e no fim ganha ou perde.
var _retrato: TextureRect
var _botoes: VBoxContainer
var _btn_igualar: Button
var _btn_metade: Button
var _btn_manter: Button


func setup(index: int) -> void:
	dock_index = index
	tempo = &"rodada"
	_build_ui()
	_refresh()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	# Centralizado e do tamanho do conteúdo — com offsets fixos sobrava um
	# tampão vazio embaixo dos botões.
	var centro := CenterContainer.new()
	centro.anchor_right = 1.0
	centro.anchor_bottom = 1.0
	add_child(centro)

	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(400, 0)
	centro.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	vbox.add_child(PainelNarrativo.cabecalho_encorpado(
		Icones.RIVAL, "Arlindo (Porto Farol) fez uma oferta"))

	# O ARLINDO FALA COM O CLIENTE, NÃO COM O JOGADOR — é isso que faz a tela
	# ser uma negociação assistida em vez de uma discussão, e o arquivo de
	# escrita é explícito nisso. Daí as aspas: o jogador está a ouvir.
	# Mesmo balão das outras telas narrativas. Este painel não herda do
	# `PainelNarrativo` (é anterior a ele e mexer nele sem necessidade é
	# arriscar o que já foi jogado), então usa a variação do tema direto — o
	# estilo continua a vir de um lugar só.
	var balao := PanelContainer.new()
	balao.theme_type_variation = "Fala"
	balao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fala_arlindo = Label.new()
	# `_SMART` pela mesma razão do `fala()` do `PainelNarrativo`: a abertura e
	# a despedida levam o nome do porto, que pode ser uma palavra só de 24
	# letras (`docs/decisoes/051`).
	_fala_arlindo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fala_arlindo.text = GameState.texto(Narrativa.ARLINDO_ABERTURA)
	balao.add_child(_fala_arlindo)
	# A CARA DELE AO LADO DO BALÃO. A linha é montada à mão pela mesma razão
	# que o balão é: este painel não herda do `PainelNarrativo` (é anterior a
	# ele), e refazê-lo agora seria mexer no que já foi jogado. O que vem de um
	# lugar só é o TAMANHO e o arquivo — `Retratos.imagem()` —, que é o que
	# impede este retrato de divergir dos outros dois.
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	_retrato = Retratos.imagem(Narrativa.retrato("arlindo", "abertura"))
	linha.add_child(_retrato)
	linha.add_child(balao)
	vbox.add_child(linha)

	var valor := PanelContainer.new()
	valor.theme_type_variation = "TarjaNarrativa"
	_valor_label = Label.new()
	_valor_label.theme_type_variation = "RotuloTotal"
	_valor_label.text = "Valor original: %s" % GameState.moeda(_valor_barco())
	_valor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	valor.add_child(_valor_label)
	vbox.add_child(valor)

	# A cara do cliente é um ícone que troca no meio da negociação, então a
	# linha é guardada em pedaços: o texto e o ícone mudam juntos em _refresh().
	_mood_linha = Icones.rotulo(Icones.CLIENTE_CALMO, "", Icones.TAM_TEXTO)
	_mood_icone = _mood_linha.get_node("Icone")
	_mood_label = _mood_linha.get_node("Texto")
	vbox.add_child(_mood_linha)

	var btn_row := VBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)
	_botoes = btn_row

	_btn_igualar = Button.new()
	Icones.no_botao(_btn_igualar, Icones.ACORDO)
	_btn_igualar.custom_minimum_size = Vector2(0, 58)
	_btn_igualar.pressed.connect(func(): _negociar("igualar"))
	btn_row.add_child(_btn_igualar)

	_btn_metade = Button.new()
	Icones.no_botao(_btn_metade, Icones.CORTAR)
	_btn_metade.custom_minimum_size = Vector2(0, 58)
	_btn_metade.pressed.connect(func(): _negociar("metade"))
	btn_row.add_child(_btn_metade)

	_btn_manter = Button.new()
	Icones.no_botao(_btn_manter, Icones.FIRMEZA)
	_btn_manter.custom_minimum_size = Vector2(0, 58)
	_btn_manter.pressed.connect(func(): _negociar("manter"))
	btn_row.add_child(_btn_manter)


func _valor_barco() -> int:
	if dock_index < 0 or dock_index >= GameState.docks.size():
		return 0
	var boat = GameState.docks[dock_index]["boat"]
	return int(boat["value"]) if boat != null else 0


func _negociar(acao: String) -> void:
	# A reação sai do que o jogador ESCOLHEU, e por isso é lida antes de o
	# GameState resolver: depois de resolver, a ação já não está em lado nenhum.
	var reacao: String = String(Narrativa.ARLINDO_REACOES.get(acao, ""))
	var resultado := GameState.negotiate_rival(acao)
	if resultado == "insistiu":
		# Cliente ainda na mesa, mas mais impaciente — e igualar ficou mais caro.
		_refresh(reacao, acao)
		return
	if resultado == "invalido":
		queue_free()
		return
	_despedida(resultado)


# O SEGUNDO TEMPO DA NEGOCIAÇÃO, e ele existe porque duas falas dele estavam
# MUDAS desde 01/09: `ARLINDO_VENCEU` e `ARLINDO_PERDEU` estavam escritas e
# nenhuma linha do jogo as disparava — o painel fechava calado, ganhasse quem
# ganhasse. É a mesma forma da cena do Sr. Ribeiro, e pela mesma razão: quem
# perde uma negociação merece ouvir o outro lado dizer alguma coisa, e é dessa
# frase que sai a promessa que a semana seguinte vem cobrar.
#
# NÃO MEXE EM DINHEIRO NENHUM. O `negotiate_rival()` já resolveu tudo antes de
# se chegar aqui; isto é uma tela a mais para LER, não uma decisão a mais — e
# por isso não toca no que o simulador mede, que nunca abre cena.
func _despedida(resultado: String) -> void:
	tempo = &"despedida"
	_valor_label.text = "Negócio fechado no seu porto" if resultado == "fechado" \
		else "Negócio perdido para Porto Farol"
	# "fechado" é o cliente que FICA: quem perdeu foi ele.
	var id := "perdeu" if resultado == "fechado" else "venceu"
	_fala_arlindo.text = GameState.texto(String(Narrativa.ARLINDO_FALAS[id]))
	_retrato.texture = Narrativa.retrato("arlindo", id)
	# ⚠️ O HUMOR DO CLIENTE SAI COM A NEGOCIAÇÃO. A linha dizia "Cliente
	# ouvindo a proposta. (2 tentativas)" por baixo da despedida — com o
	# negócio fechado ou o cliente já no Porto Farol, e nenhuma das duas coisas
	# era verdade. Viveu assim desde que o segundo tempo existe, porque a
	# bateria só fotografava o primeiro (`docs/decisoes/051`).
	_mood_linha.visible = false
	for filho in _botoes.get_children():
		filho.queue_free()
	var sair := Button.new()
	sair.text = "Fechar"
	sair.custom_minimum_size = Vector2(0, PainelNarrativo.TOQUE_MIN)
	sair.pressed.connect(queue_free)
	_botoes.add_child(sair)


func _refresh(reacao: String = "", acao: String = "") -> void:
	var valor := _valor_barco()
	var restantes := GameState.rival_attempts_left
	var ja_insistiu := restantes < GameState.RIVAL_PATIENCE

	var desconto_igualar: float = GameState.RIVAL_DISCOUNT_AFTER_FAIL if ja_insistiu else GameState.RIVAL_DISCOUNT
	_btn_igualar.text = "Igualar rival (−%d%%) — fecha agora\n%s" % [
		int(round(desconto_igualar * 100.0)),
		GameState.moeda(int(round(valor * (1.0 - desconto_igualar))))]

	# A reputação altera a chance REAL em GameState._negociar(). Mostrar a
	# constante de base fazia o botão prometer uma probabilidade diferente da
	# que o sorteio aplicava. A mesma função serve a simulação e este rótulo.
	var chance_metade := GameState._chance_com_reputacao(GameState.RIVAL_HALF_CHANCE)
	var chance_manter := GameState._chance_com_reputacao(GameState.RIVAL_KEEP_CHANCE)
	_btn_metade.text = "Cortar metade (−%d%%) — aposta\n%s · %d%% de chance" % [
		int(round(GameState.RIVAL_HALF_DISCOUNT * 100.0)),
		GameState.moeda(int(round(valor * (1.0 - GameState.RIVAL_HALF_DISCOUNT)))),
		int(round(chance_metade * 100.0))]

	_btn_manter.text = "Manter preço — aposta\n%s · %d%% de chance" % [
		GameState.moeda(valor),
		int(round(chance_manter * 100.0))]

	var desc := "Cliente ouvindo a proposta."
	_mood_icone.texture = Icones.CLIENTE_CALMO
	if restantes <= 1:
		_mood_icone.texture = Icones.CLIENTE_IMPACIENTE
		desc = "Cliente impaciente — se esta não colar, ele vai embora."
	_mood_label.text = "%s (%s)" % [
		desc, Narrativa.concordar(restantes, "tentativa", "tentativas")]

	# Duas falas dele numa rodada só: o que achou da oferta, e a pressão da
	# última tentativa. Juntas porque são o mesmo momento — separá-las em dois
	# balões daria dois cliques a uma coisa que se lê de uma vez.
	if reacao != "":
		var falas := GameState.texto(reacao)
		# ⚠️ A CARA SAI DA ÚLTIMA FALA DO BALÃO, como na cena da parcela. Ele
		# reage à oferta ainda a sorrir; se esta for a derradeira tentativa, a
		# linha da pressão vem a seguir e é ela que fica na tela — o sorriso
		# sai, que é o que muda numa cara que sorri por omissão.
		var id := acao
		if restantes <= 1:
			falas += "\n\n" + GameState.texto(Narrativa.ARLINDO_ULTIMA_TENTATIVA)
			id = "ultima_tentativa"
		_fala_arlindo.text = falas
		if id != "":
			_retrato.texture = Narrativa.retrato("arlindo", id)
