extends Control

# Painel de construção do porto.
#
# Antes era um upgrade só ("ampliar o píer") e cabia num botão. Agora o porto
# ABRE PARADO e o jogador levanta-o peça por peça, então o painel lista tudo:
# o que já está de pé, o que dá para comprar agora, e — o que mais importa —
# POR QUE não dá, quando não dá. Um botão apagado sem explicação faz o jogador
# achar que o jogo travou.

# ⚠️ O VERDE DA ESTRUTURA DE PÉ SAIU DAQUI em 22/09, para o tema
# (`docs/decisoes/044`): é a variação `TextoEstruturaFeita`, escrita LITERAL
# nos dois sítios. Nunca num dicionário nem por `StringName(var)` — o
# `conferir_escopo_ui.py` procura o nome depois do `=`, e o que ele não vê é
# um erro de digitação a cair no `Label` base sem uma palavra.

# ⚠️ ESTE PAINEL É BRANCO, E A COR NEUTRA DO JOGO É PARA FUNDO ESCURO. O
# cinzento-azulado (0,51/0,6/0,706) que marca texto neutro sobre a barra escura
# mede **2,93:1** aqui — reprova até o corte de texto GRANDE da WCAG (3,0), e
# estas linhas são de 13 e 14px, que pedem 4,5:1. O mesmo erro já tinha sido
# apanhado no calendário em 03/09 e ficou registado no `CLAUDE.md`; o painel
# Construir carregava-o desde então, na descrição de cada estrutura.
#
# A cor certa (0,35/0,42/0,50, 5,46:1 sobre branco) vive no tema desde 21/09,
# na variação `RotuloApoio` — era uma `const COR_SECUNDARIA` aqui, que é o que
# o R7 veio acabar: cor de interface escrita à mão é cor que diverge calada.

# Comprar emite `cash_changed` E `roster_changed`, e o botão que disparou a
# compra está dentro do que vai ser destruído. Remontar na hora significaria
# libertar um nó no meio da emissão do sinal dele próprio, duas vezes.
# Marcar e remontar no fim do frame resolve as duas coisas de uma vez.
var _rebuild_pedido := false


func _ready() -> void:
	_build_ui()
	GameState.cash_changed.connect(func(_v): _pedir_rebuild())
	GameState.roster_changed.connect(_pedir_rebuild)
	GameState.turn_advanced.connect(func(_dia, _semana): _pedir_rebuild())


func _pedir_rebuild() -> void:
	if _rebuild_pedido:
		return
	_rebuild_pedido = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_pedido = false
	for filho in get_children():
		remove_child(filho)
		filho.queue_free()
	_build_ui()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	# A ALTURA SAI DO CONTEÚDO, como no `montar(largura, 0)` do andaime: a
	# caixa cresce para cima e para baixo a partir do centro. Até 04/10 ela
	# declarava 560 e o conteúdo pedia ~870 — cada linha levava um botão de
	# largura inteira —, e a declaração não dizia nada (`081`).
	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -320
	box.offset_right = 320
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	box.add_child(vbox)

	# O VOCABULÁRIO DAS FAMÍLIAS DE 25/09 (`062`–`065`): cabeçalho com selo e
	# tarja. O Construir abre-se pelo HUD como o Dinheiro, as Docas e a
	# Reputação, e era o único que tinha ficado de fora (`081`).
	vbox.add_child(PainelNarrativo.cabecalho_encorpado(Icones.AMPLIAR_PIER, "Construir no porto"))

	# O NÍVEL DO PORTO, e o que ele recebe. Sem esta linha a trava de 06/09
	# seria estado invisível: o jogador veria o navio grande deixar de aparecer
	# e não teria como saber que é o porto dele que não o aguenta. É a mesma
	# razão de o motivo estar escrito no cartão da doca — mecânica que não se
	# lê em algum lado é mecânica que não existe.
	#
	# ⚠️ ELA PERCORRE `CLASSES_DE_NAVIO` e não uma lista escrita à mão: uma
	# classe nova tem de aparecer aqui sozinha, senão volta o defeito do
	# `barco_medio` — gerado, validado, e sem chegar à tela.
	#
	# Desde 04/10 ela é a linha de apoio da tarja, e o dinheiro é a tarja: é
	# o número que decide o que se compra, e os botões abaixo cobram dele.
	var nivel := int(GameState.nivel_do_porto())
	var recebe := PackedStringArray()
	var falta := PackedStringArray()
	for id in GameState.CLASSES_DE_NAVIO:
		var dados: Dictionary = GameState.CLASSES_DE_NAVIO[id]
		if int(dados["nivel"]) <= nivel:
			recebe.append(String(dados["nome"]))
		else:
			falta.append(String(dados["nome"]))
	var porto := "Porto nível %d — recebe %s" % [nivel, ", ".join(recebe).to_lower()]
	if int(GameState.nivel_guindaste()) == 1:
		porto += "\nGuindaste de madeira · novos guindastes na Fase 2"
	if falta.size() > 0:
		porto += "\nAinda não aguenta: %s" % ", ".join(falta).to_lower()
	vbox.add_child(PainelNarrativo.tarja_solta(
		"Dinheiro: %s" % GameState.moeda(int(GameState.cash)), porto))

	# Ordenar pela chave `ordem` e não pela do dicionário: a ordem de um
	# Dictionary em GDScript é a de inserção, e depender disso é frágil.
	#
	# ⚠️ E O QUE JÁ ESTÁ DE PÉ VAI PARA O FIM (`081`). Até 04/10 os dois
	# píeres, comprados primeiro, ficavam no topo e empurravam para baixo o que
	# ainda se pode comprar — que é a razão de abrir o painel.
	var ids := GameState.ESTRUTURAS.keys()
	ids.sort_custom(func(a, b):
		var feita_a := GameState.tem_estrutura(String(a))
		var feita_b := GameState.tem_estrutura(String(b))
		if feita_a != feita_b:
			return feita_b
		return int(GameState.ESTRUTURAS[a]["ordem"]) < int(GameState.ESTRUTURAS[b]["ordem"]))

	for id in ids:
		vbox.add_child(_linha_estrutura(String(id)))

	var btn_fechar := Button.new()
	btn_fechar.text = "Fechar"
	btn_fechar.custom_minimum_size = Vector2(0, 44)
	btn_fechar.pressed.connect(func(): queue_free())
	vbox.add_child(btn_fechar)


# UMA LINHA POR ESTRUTURA: o nome e o efeito à esquerda, e à direita o que se
# pode fazer com ela — o botão, o preço de quem ainda não pode, ou o
# «Construída» (`081`). Até 04/10 o preço saía DUAS vezes (no título e no
# botão «Construir por R$…»), e cada botão ocupava a largura inteira: quatro
# barras navy iguais, uma por cima da outra, e o cartão a 870 px.
func _linha_estrutura(id: String) -> Control:
	var def: Dictionary = GameState.ESTRUTURAS[id]
	var feito: bool = GameState.tem_estrutura(id)
	var impedimento: String = GameState.impedimento_estrutura(id)

	var cartao := PanelContainer.new()
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 12)
	cartao.add_child(linha)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(col)

	var titulo := Label.new()
	titulo.text = String(def["nome"])
	titulo.add_theme_font_size_override("font_size", 15)
	if feito:
		titulo.theme_type_variation = &"TextoEstruturaFeita"
	col.add_child(titulo)

	var efeito := Label.new()
	efeito.text = String(def["desc"])
	if not feito and GameState.dias_da_obra(id) > 0:
		efeito.text += " · %s de obra" % Narrativa.concordar(
			GameState.dias_da_obra(id), "dia", "dias")
	efeito.autowrap_mode = TextServer.AUTOWRAP_WORD
	efeito.add_theme_font_size_override("font_size", 12)
	efeito.theme_type_variation = "RotuloApoio"
	col.add_child(efeito)

	if feito:
		var pronto := Icones.rotulo(Icones.FEITO, "Construída", Icones.TAM_TEXTO)
		var texto_pronto := pronto.get_node("Texto") as Label
		texto_pronto.add_theme_font_size_override("font_size", 12)
		texto_pronto.theme_type_variation = &"TextoEstruturaFeita"
		# ⚠️ SEM QUEBRA E SEM EXPANDIR: o `Icones.rotulo` dá ao texto as duas
		# coisas, que servem a uma linha que ocupa a largura toda. Ao lado da
		# coluna do nome, que expande, a quebra deixa-lhe largura quase zero, e
		# «Construída», uma palavra só, saía por cima da borda do cartão. O D19
		# mede isto.
		texto_pronto.autowrap_mode = TextServer.AUTOWRAP_OFF
		texto_pronto.size_flags_horizontal = Control.SIZE_SHRINK_END
		pronto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		linha.add_child(pronto)
		return cartao

	# ⚠️ COM A OBRA A ANDAR, O AVISO É INFORMAÇÃO E VAI NO TOM DE APOIO; o
	# âmbar fica para ANTES de comprar, que é onde ele muda uma decisão (`090`).
	# O dia sai do `prazo_da_obra()`, e não do `conclusao` cru: a obra que só
	# acaba no fecho do último dia dizia aqui «pronto no dia 85».
	if GameState.obra_em_andamento.get("id", "") == id:
		var andamento := Label.new()
		andamento.text = "Em obra · %s · %s" % [
			Narrativa.concordar(GameState.dias_restantes_da_obra(), "dia restante", "dias restantes"),
			GameState.prazo_da_obra(int(GameState.obra_em_andamento["conclusao"]))]
		andamento.autowrap_mode = TextServer.AUTOWRAP_WORD
		andamento.add_theme_font_size_override("font_size", 13)
		andamento.theme_type_variation = "RotuloApoio"
		col.add_child(andamento)
		var pago := Label.new()
		pago.text = "Pago"
		pago.theme_type_variation = "RotuloApoio"
		pago.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		linha.add_child(pago)
		return cartao

	# ⚠️ O MOTIVO DO BLOQUEIO NÃO PODE VIVER DENTRO DO BOTÃO DESLIGADO, e viveu
	# até 20/09. A WCAG isenta o texto de um componente INATIVO (1.4.3), e o
	# `font_disabled_color` sobre o `botao_off` mede 2,16:1 — legítimo para o
	# rótulo de um botão que não se pode premir, e desastroso quando a única
	# frase que explica POR QUE ele não se pode premir é esse mesmo rótulo. A
	# isenção engolia a explicação: medido nos três cartões bloqueados do porto
	# inicial, a frase estava na tela, lavada, e nada a media porque a régua a
	# dava por isenta com razão.
	#
	# Conserta-se TIRANDO: um botão que não se pode premir é um convite falso,
	# e o que a estrutura bloqueada tem a dizer é uma frase, não uma ação.
	#
	# ⚠️ E O PREÇO FICA À DIREITA, onde estaria o botão (`081`). Saiu do
	# título; sem ele aqui, quem ainda não pode comprar não saberia quanto custa
	# — e «Faltam R$…» é a diferença, não o preço.
	if impedimento != "":
		var trava := Label.new()
		trava.text = impedimento
		trava.autowrap_mode = TextServer.AUTOWRAP_WORD
		trava.add_theme_font_size_override("font_size", 13)
		trava.theme_type_variation = "RotuloApoio"
		col.add_child(trava)
		var preco := Label.new()
		preco.text = GameState.moeda(int(def["custo"]))
		preco.add_theme_font_size_override("font_size", 14)
		preco.theme_type_variation = "RotuloApoio"
		preco.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		linha.add_child(preco)
		return cartao

	# A OBRA QUE SÓ FICA PRONTA NO FECHO DO ÚLTIMO DIA compra-se, e avisa
	# (D8, `090`): o jogador paga o preço inteiro por uma estrutura que esta
	# fase não deixa usar, e é aqui, com o botão ao lado, que ele o decide. Em
	# `RotuloAlerta`, o âmbar escurecido do tema, que mede 5,06:1 no cartão
	# branco — o caso «Construir (obra sem uso na fase)» da régua do contraste
	# mede-o, porque o percurso abre no dia 1 e nunca chegaria aqui.
	var conclusao: int = GameState.turn + GameState.dias_da_obra(id)
	if GameState.obra_sem_uso_na_fase(conclusao):
		var aviso := Label.new()
		aviso.name = "AvisoObraSemUso"
		aviso.text = "Fica %s." % GameState.prazo_da_obra(conclusao)
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD
		aviso.add_theme_font_size_override("font_size", 13)
		aviso.theme_type_variation = "RotuloAlerta"
		col.add_child(aviso)

	var btn := Button.new()
	btn.text = "Construir · %s" % GameState.moeda(int(def["custo"]))
	btn.add_theme_font_size_override("font_size", 13)
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func(): GameState.comprar_estrutura(id))
	linha.add_child(btn)
	return cartao
