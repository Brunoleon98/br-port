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
# ============================================================

const LARGURA := 460


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, 0, ESCURO_DECISAO)
	titulo_encorpado(Icones.AJUSTES, "Ajustes")

	secao("SOM")
	_vbox.add_child(_slider_de_volume("Música", "Musica"))
	_vbox.add_child(_slider_de_volume("Efeitos", "SFX"))

	fio()
	secao("REGISTRO DA PARTIDA")
	_registro()

	botao_fechar("Voltar")


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
