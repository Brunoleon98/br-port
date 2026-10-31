extends PainelNarrativo

# ============================================================
# BR Port VS — AJUSTES: o volume e o registro da partida (`docs/decisoes/066`)
#
# Estes dois viviam no menu de pausa, ao lado de «Continuar» e de «Novo jogo».
# A família do sistema da frente 3 encurtou a pausa para três botões —
# Continuar, Ajustes, Salvar e sair —, e o que não é decisão de agora veio para
# cá. É UMA tela para DUAS portas, a pausa e a tela inicial: o volume é o mesmo
# nas duas, e duas cópias dos sliders seriam duas regras para o mesmo bus.
#
# O que continua valendo, e vinha do cabeçalho do menu de pausa:
#
# OS DOIS SLIDERS SÃO SEPARADOS DE PROPÓSITO. Quem baixa a trilha para ouvir
# outra coisa não quer perder o retorno sonoro dos botões; quem acha o efeito
# cansativo não quer perder a trilha. Um slider só obriga a escolher entre as
# duas, e é por isso que o `default_bus_layout.tres` tem dois buses.
#
# O valor vai direto ao bus e é gravado na hora (`Audio.definir_volume`), sem
# botão de confirmar: mexer no volume e ouvir mudar É a confirmação.
#
# A VIBRAÇÃO MORA AO LADO DO SOM (`149`), como nos Ajustes do próprio
# telefone: é o outro retorno que o jogo dá ao toque. Ligada por omissão, e
# fora do save, na `PreferenciasDeApresentacao`.
# ============================================================

const LARGURA := 460
var _movimento: CheckButton
var _vibracao: CheckButton
var _aviso_preferencia: Label
var _texto_padrao: Button
var _texto_maior: Button


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, 0, ESCURO_DECISAO)
	titulo_encorpado(Icones.AJUSTES, "Ajustes")

	secao("SOM E VIBRAÇÃO")
	_vbox.add_child(_slider_de_volume("Música", "Musica"))
	_vbox.add_child(_slider_de_volume("Efeitos", "SFX"))
	_vibracao = CheckButton.new()
	_vibracao.name = "Vibracao"
	_vibracao.text = "Vibração"
	_vibracao.custom_minimum_size = Vector2(0, TOQUE_MIN)
	_vibracao.button_pressed = PreferenciasDeApresentacao.atual().vibrar
	_vbox.add_child(_vibracao)
	var vibra := paragrafo("Um toque curto ao atracar; mais longo quando uma obra fica pronta e quando a parcela é paga.")
	vibra.theme_type_variation = &"RotuloApoio"
	_vibracao.toggled.connect(_escolher_vibracao)
	PreferenciasDeApresentacao.atual().vibracao_mudou.connect(_mostrar_vibracao)

	fio()
	secao("APRESENTAÇÃO")
	_movimento = CheckButton.new()
	_movimento.name = "ReduzirMovimento"
	_movimento.text = "Reduzir movimento"
	_movimento.custom_minimum_size = Vector2(0, TOQUE_MIN)
	_movimento.button_pressed = PreferenciasDeApresentacao.atual().reduzir_movimento
	_vbox.add_child(_movimento)
	paragrafo("Diminui movimentos de fundo, pulsos e transições. Mantém os avisos e os sinais de operação.")
	_aviso_preferencia = paragrafo("")
	_aviso_preferencia.theme_type_variation = &"RotuloApoio"
	_aviso_preferencia.visible = false
	_movimento.toggled.connect(_escolher_movimento)
	PreferenciasDeApresentacao.atual().mudou.connect(_mostrar_movimento)
	paragrafo("Tamanho do texto")
	var tamanhos := HBoxContainer.new()
	tamanhos.name = "TamanhoDoTexto"
	tamanhos.add_theme_constant_override("separation", 10)
	_vbox.add_child(tamanhos)
	var grupo := ButtonGroup.new()
	for modo in [PreferenciasDeApresentacao.PADRAO, PreferenciasDeApresentacao.MAIOR]:
		var botao := Button.new()
		botao.name = "TextoPadrao" if modo == PreferenciasDeApresentacao.PADRAO else "TextoMaior"
		botao.text = "Padrão" if modo == PreferenciasDeApresentacao.PADRAO else "Maior (+25%)"
		botao.toggle_mode = true
		botao.button_group = grupo
		botao.custom_minimum_size.y = TOQUE_MIN
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao.pressed.connect(_escolher_texto.bind(modo))
		tamanhos.add_child(botao)
		if modo == PreferenciasDeApresentacao.PADRAO:
			_texto_padrao = botao
		else:
			_texto_maior = botao
	_mostrar_texto(PreferenciasDeApresentacao.atual().tamanho_do_texto)
	PreferenciasDeApresentacao.atual().texto_mudou.connect(_mostrar_texto)
	var exemplo := paragrafo("Exemplo: Serviço concluído — R$125.000.")
	exemplo.name = "ExemploDoTexto"

	fio()
	secao("REGISTRO DA PARTIDA")
	_registro()

	botao_fechar("Voltar")


func _escolher_movimento(reduzido: bool) -> void:
	var erro := PreferenciasDeApresentacao.atual().definir_reduzir_movimento(reduzido)
	_aviso_preferencia.text = "Não foi possível lembrar a escolha. Ela vale nesta sessão."
	_aviso_preferencia.visible = erro != OK


func _mostrar_movimento(reduzido: bool) -> void:
	_movimento.set_pressed_no_signal(reduzido)


func _escolher_vibracao(ligada: bool) -> void:
	var erro := PreferenciasDeApresentacao.atual().definir_vibrar(ligada)
	_aviso_preferencia.text = "Não foi possível lembrar a escolha. Ela vale nesta sessão."
	_aviso_preferencia.visible = erro != OK


func _mostrar_vibracao(ligada: bool) -> void:
	_vibracao.set_pressed_no_signal(ligada)


func _escolher_texto(modo: String) -> void:
	var erro := PreferenciasDeApresentacao.atual().definir_tamanho_do_texto(modo)
	_aviso_preferencia.text = "Não foi possível lembrar a escolha. Ela vale nesta sessão."
	_aviso_preferencia.visible = erro != OK


func _mostrar_texto(modo: String) -> void:
	_texto_padrao.set_pressed_no_signal(modo == PreferenciasDeApresentacao.PADRAO)
	_texto_maior.set_pressed_no_signal(modo == PreferenciasDeApresentacao.MAIOR)


# Um rótulo, o slider e a percentagem. A linha tem a altura do alvo de toque,
# e não a do slider: o polegar acerta na linha, não no trilho de 8 px.
func _slider_de_volume(rotulo: String, bus: String) -> Control:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	linha.custom_minimum_size = Vector2(0, TOQUE_MIN)

	var nome := Label.new()
	nome.text = rotulo
	nome.custom_minimum_size = Vector2(76, 0)
	nome.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(nome)

	var slider := HSlider.new()
	slider.name = "Volume_%s" % bus
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = Audio.volume(bus)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.custom_minimum_size = Vector2(0, 28)
	linha.add_child(slider)

	var pct := Label.new()
	pct.custom_minimum_size = Vector2(48, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pct.text = "%d%%" % int(round(slider.value * 100.0))
	linha.add_child(pct)

	slider.value_changed.connect(func(v: float):
		Audio.definir_volume(bus, v)
		pct.text = "%d%%" % int(round(v * 100.0))
	)
	return linha


# ── O REGISTRO DE PARTIDA SAI DAQUI, E É A ÚNICA PORTA QUE TEM ──
#
# `user://` no Android é privado da aplicação: sem cabo e sem `adb` não há
# como lá chegar. Um gravador cujo arquivo não sai do aparelho não gravou
# nada — e o A7 pede justamente que o jogo seja entregue a duas pessoas
# noutro telefone. A área de transferência é o caminho que funciona em
# qualquer aparelho: copiar aqui, colar numa conversa, ler com
# `tools/ler_registros.py`.
#
# Da tela inicial, o que se copia é a ÚLTIMA partida jogada nesta sessão: o
# «Salvar e sair» desarma o gravador mas deixa o caminho (`Registro.desarmar`).
func _registro() -> void:
	var apoio := paragrafo("Copia o que o jogo gravou da partida, para colar numa conversa.")
	apoio.theme_type_variation = &"RotuloApoio"

	var aviso := Label.new()
	aviso.theme_type_variation = &"RotuloApoio"
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Rótulo vazio OCUPA ALTURA. Na captura ficava uma faixa em branco entre
	# os dois botões que se lia como falha de layout, e não como espaço à
	# espera de texto — o mesmo defeito da faixa branca debaixo do botão que
	# já apareceu em três painéis.
	aviso.visible = false

	var botao := Button.new()
	botao.text = "Copiar registro da partida"
	botao.custom_minimum_size = Vector2(0, TOQUE_MIN)
	botao.pressed.connect(func():
		var texto: String = Registro.texto_para_exportar()
		if texto == "":
			# Dizer "copiado" com a área de transferência vazia é pior do que
			# não ter botão: quem cola descobre o silêncio uma hora depois.
			aviso.text = "Nada gravado ainda nesta sessão."
			aviso.visible = true
			return
		DisplayServer.clipboard_set(texto)
		aviso.text = "%s. Cole numa conversa." % Narrativa.concordar(
			Registro.linhas_gravadas(), "linha copiada", "linhas copiadas")
		aviso.visible = true
	)
	_vbox.add_child(botao)
	_vbox.add_child(aviso)
