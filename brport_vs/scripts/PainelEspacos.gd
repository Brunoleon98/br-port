extends PainelNarrativo

# ============================================================
# BR Port VS — os TRÊS ESPAÇOS de save, da tela inicial (`docs/decisoes/066`)
#
# Um painel, dois modos e três tempos:
#
#  - «carregar»: os três espaços; os ocupados têm «Carregar», os livres dizem
#    que estão livres e não são botão (um botão que não leva a lado nenhum
#    ensina a não tocar — a regra dos apps fechados do celular);
#  - «nova»: os mesmos três; o livre tem «Começar aqui», o ocupado
#    «Substituir», que NÃO apaga nada — leva ao terceiro tempo;
#  - «confirmar»: o porto que se vai apagar, com o dia e o dinheiro dele numa
#    tarja do tom ruim, e as duas saídas. Apagar uma partida é a única
#    decisão sem volta desta família, e ela pede o segundo toque.
#
# O que cada espaço mostra sai de `GameState.resumo_do_espaco()`, que lê o
# ARQUIVO sem tocar no estado vivo — o painel pode mostrar os três sem
# carregar nenhum.
# ============================================================

## O jogador escolheu o espaço `espaco`, no `modo` em que o painel abriu. Quem
## carrega, apaga e troca de cena é a tela inicial — o painel só pergunta.
signal escolhido(espaco: int, modo: String)

# O tempo em que o painel está, para a bateria de captura provar que o
# fotografou (`docs/decisoes/051`). ⚠️ Todo `tempo = &"..."` escrito neste
# arquivo é um tempo que tem de ter foto — e as ferramentas leem-no daqui.
var tempo: StringName = &""

const LARGURA := 560

var _modo := "carregar"


func setup(modo: Variant = "carregar") -> void:
	_modo = "nova" if String(modo) == "nova" else "carregar"
	montar(LARGURA, 0, ESCURO_DECISAO)
	_lista()


func _esvaziar() -> void:
	for filho in _vbox.get_children():
		_vbox.remove_child(filho)
		filho.queue_free()


func _lista() -> void:
	_esvaziar()
	if _modo == "nova":
		tempo = &"nova"
		titulo_encorpado(Icones.RECOMECAR, "Nova partida")
		_apoio("Escolha onde guardar o porto novo.")
	else:
		tempo = &"carregar"
		# O BARCO e não a DOCA: o ícone da doca é traço CLARO, feito para a
		# barra escura do HUD, e no selo claro do cabeçalho saía um quadrado
		# vazio — o fantasma que o ícone `doca` já foi uma vez no painel branco.
		# O barco é o que o painel das Docas põe no mesmo selo.
		titulo_encorpado(Icones.BARCO, "Carregar partida")
		_apoio("Escolha o porto.")
	for n in range(1, GameState.ESPACOS + 1):
		_vbox.add_child(_cartao_do_espaco(n))
	botao_fechar("Voltar")


func _apoio(texto: String) -> Label:
	var rotulo := paragrafo(texto)
	rotulo.theme_type_variation = &"RotuloApoio"
	return rotulo


# Um espaço, no quadro das duas famílias (`BlocoNumero`): o número do espaço
# em cima, o nome do cais como a linha que o olho procura, o dia e o dinheiro
# por baixo, e o botão do modo.
func _cartao_do_espaco(n: int) -> Control:
	var r: Dictionary = GameState.resumo_do_espaco(n)
	var bloco := PanelContainer.new()
	bloco.name = "Espaco%d" % n
	bloco.theme_type_variation = &"BlocoNumero"
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 2)
	bloco.add_child(coluna)

	var cabeca := Label.new()
	cabeca.theme_type_variation = &"RotuloApoio"
	cabeca.text = "Espaço %d" % n
	if not r.is_empty() and String(r["fase"]) == "game_over":
		cabeca.text += " · partida encerrada, %s" % (
			"parcela paga" if bool(r["venceu"]) else "parcela não paga")
	coluna.add_child(cabeca)

	var nome := Label.new()
	nome.theme_type_variation = &"RotuloTotal"
	nome.text = "Livre" if r.is_empty() else String(r["porto"])
	nome.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	coluna.add_child(nome)

	var detalhe := Label.new()
	detalhe.theme_type_variation = &"RotuloApoio"
	detalhe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detalhe.text = "Nenhum porto guardado aqui." if r.is_empty() else GameState.linha_do_espaco(r)
	coluna.add_child(detalhe)

	var acao := ""
	if _modo == "nova":
		acao = "Começar aqui" if r.is_empty() else "Substituir"
	elif not r.is_empty():
		acao = "Carregar"
	if acao != "":
		var botao := Button.new()
		botao.name = "Acao"
		botao.text = acao
		botao.custom_minimum_size = Vector2(0, TOQUE_MIN)
		botao.pressed.connect(func() -> void:
			if _modo == "nova" and not r.is_empty():
				_confirmar(n, r)
			else:
				_escolher(n))
		coluna.add_child(botao)
	return bloco


# O terceiro tempo: o porto que se apaga, antes de se apagar.
func _confirmar(n: int, r: Dictionary) -> void:
	_esvaziar()
	tempo = &"confirmar"
	titulo_encorpado(Icones.RECOMECAR, "Nova partida")
	tarja("Apagar o %s?" % String(r["porto"]),
		"%s. O espaço %d recebe um porto novo, e este não volta." % [
			_com_maiuscula(GameState.linha_do_espaco(r)), n],
		&"ruim")
	var apagar := Button.new()
	apagar.name = "Apagar"
	apagar.text = "Apagar e começar"
	apagar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	apagar.pressed.connect(func() -> void: _escolher(n))
	_vbox.add_child(apagar)
	var voltar := Button.new()
	voltar.name = "VoltarLista"
	voltar.text = "Voltar aos espaços"
	voltar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	voltar.pressed.connect(_lista)
	_vbox.add_child(voltar)


static func _com_maiuscula(texto: String) -> String:
	return texto.left(1).to_upper() + texto.substr(1)


func _escolher(n: int) -> void:
	escolhido.emit(n, _modo)
	_fechar()
