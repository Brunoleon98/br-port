extends Control

# Painel de construção do porto.
#
# Antes era um upgrade só ("ampliar o píer") e cabia num botão. Agora o porto
# ABRE PARADO e o jogador levanta-o peça por peça, então o painel lista tudo:
# o que já está de pé, o que dá para comprar agora, e — o que mais importa —
# POR QUE não dá, quando não dá. Um botão apagado sem explicação faz o jogador
# achar que o jogo travou.

const COR_FEITO := Color(0.102, 0.478, 0.251)

# ⚠️ ESTE PAINEL É BRANCO, E A COR NEUTRA DO JOGO É PARA FUNDO ESCURO. O
# cinzento-azulado (0,51/0,6/0,706) que marca texto neutro sobre a barra escura
# mede **2,93:1** aqui — reprova até o corte de texto GRANDE da WCAG (3,0), e
# estas linhas são de 13 e 14px, que pedem 4,5:1. O mesmo erro já tinha sido
# apanhado no calendário em 03/09 e ficou registado no `CLAUDE.md`; o painel
# Construir carregava-o desde então, na descrição de cada estrutura.
#
# 0,35/0,42/0,50 mede **5,46:1** sobre branco e passa o AA para texto pequeno.
const COR_SECUNDARIA := Color(0.35, 0.42, 0.50)

# Comprar emite `cash_changed` E `roster_changed`, e o botão que disparou a
# compra está dentro do que vai ser destruído. Remontar na hora significaria
# libertar um nó no meio da emissão do sinal dele próprio, duas vezes.
# Marcar e remontar no fim do frame resolve as duas coisas de uma vez.
var _rebuild_pedido := false


func _ready() -> void:
	_build_ui()
	GameState.cash_changed.connect(func(_v): _pedir_rebuild())
	GameState.roster_changed.connect(_pedir_rebuild)


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

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -320
	box.offset_top = -280
	box.offset_right = 320
	box.offset_bottom = 280
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	box.add_child(vbox)

	vbox.add_child(Icones.rotulo(Icones.AMPLIAR_PIER, "Construir no porto"))

	var caixa := Label.new()
	caixa.text = "Caixa: %s" % GameState.moeda(int(GameState.cash))
	caixa.add_theme_font_size_override("font_size", 14)
	vbox.add_child(caixa)

	# O NÍVEL DO PORTO, e o que ele recebe. Sem esta linha a trava de 06/09
	# seria estado invisível: o jogador veria o navio grande deixar de aparecer
	# e não teria como saber que é o porto dele que não o aguenta. É a mesma
	# razão de o motivo estar escrito no cartão da doca — mecânica que não se
	# lê em algum lado é mecânica que não existe.
	#
	# ⚠️ ELA PERCORRE `CLASSES_DE_NAVIO` e não uma lista escrita à mão: uma
	# classe nova tem de aparecer aqui sozinha, senão volta o defeito do
	# `barco_medio` — gerado, validado, e sem chegar à tela.
	var nivel := int(GameState.nivel_do_porto())
	var recebe := PackedStringArray()
	var falta := PackedStringArray()
	for id in GameState.CLASSES_DE_NAVIO:
		var dados: Dictionary = GameState.CLASSES_DE_NAVIO[id]
		if int(dados["nivel"]) <= nivel:
			recebe.append(String(dados["nome"]))
		else:
			falta.append(String(dados["nome"]))
	var porto := Label.new()
	porto.text = "Porto nível %d — recebe %s" % [nivel, ", ".join(recebe).to_lower()]
	if falta.size() > 0:
		porto.text += "\nAinda não aguenta: %s" % ", ".join(falta).to_lower()
	porto.add_theme_font_size_override("font_size", 13)
	porto.add_theme_color_override("font_color", COR_SECUNDARIA)
	vbox.add_child(porto)

	# Ordenar pela chave `ordem` e não pela do dicionário: a ordem de um
	# Dictionary em GDScript é a de inserção, e depender disso é frágil.
	var ids := GameState.ESTRUTURAS.keys()
	ids.sort_custom(func(a, b):
		return int(GameState.ESTRUTURAS[a]["ordem"]) < int(GameState.ESTRUTURAS[b]["ordem"]))

	for id in ids:
		vbox.add_child(_linha_estrutura(String(id)))

	var btn_fechar := Button.new()
	btn_fechar.text = "Fechar"
	btn_fechar.pressed.connect(func(): queue_free())
	vbox.add_child(btn_fechar)


func _linha_estrutura(id: String) -> Control:
	var def: Dictionary = GameState.ESTRUTURAS[id]
	var feito: bool = GameState.tem_estrutura(id)
	var impedimento: String = GameState.impedimento_estrutura(id)

	var cartao := PanelContainer.new()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	cartao.add_child(col)

	var titulo := Label.new()
	titulo.text = "%s  ·  %s" % [def["nome"], GameState.moeda(int(def["custo"]))]
	titulo.add_theme_font_size_override("font_size", 15)
	if feito:
		titulo.add_theme_color_override("font_color", COR_FEITO)
	col.add_child(titulo)

	var efeito := Label.new()
	efeito.text = String(def["desc"])
	efeito.autowrap_mode = TextServer.AUTOWRAP_WORD
	efeito.add_theme_font_size_override("font_size", 12)
	efeito.add_theme_color_override("font_color", COR_SECUNDARIA)
	col.add_child(efeito)

	if feito:
		var pronto := Icones.rotulo(Icones.FEITO, "Construída", Icones.TAM_TEXTO)
		pronto.get_node("Texto").add_theme_font_size_override("font_size", 12)
		pronto.get_node("Texto").add_theme_color_override("font_color", COR_FEITO)
		col.add_child(pronto)
		return cartao

	var btn := Button.new()
	btn.text = "Construir por %s" % GameState.moeda(int(def["custo"])) if impedimento == "" else impedimento
	btn.disabled = impedimento != ""
	btn.add_theme_font_size_override("font_size", 13)
	if impedimento == "":
		btn.pressed.connect(func(): GameState.comprar_estrutura(id))
	col.add_child(btn)
	return cartao
