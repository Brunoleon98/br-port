extends PainelNarrativo

# As lojas e o arquivo da história usam o andaime do jogo. Sem arte nova no
# mapa: este é o primeiro acesso à cidade pelo celular (`146`). A compra é
# confirmada aqui e validada outra vez pelo GameState, no instante do débito.
var _loja := ""
var _capitulo := ""
var _linha := 0
var _falas: Array = []
var _visita := false
enum Origem { BOLETIM, LOJA, HISTORIAS }
var _origem_conversa := Origem.BOLETIM


func _ready() -> void:
	super()
	mostrar_lojas()


func setup(capitulo: String = "") -> void:
	if capitulo != "":
		abrir_capitulo(capitulo)


func _limpar(titulo_da_tela: String) -> void:
	for filho in get_children():
		remove_child(filho)
		filho.queue_free()
	montar(500, 0)
	titulo_encorpado(Icones.APP_LOJAS, titulo_da_tela)
	_capitulo = ""


func _acao(texto: String, agir: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size.y = TOQUE_MIN
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.pressed.connect(agir)
	_vbox.add_child(b)
	return b


func mostrar_lojas() -> void:
	_limpar("Lojas de Porto Mirim")
	paragrafo("Dinheiro disponível: %s" % GameState.moeda(GameState.cash))
	secao("MERCADO DA PRAÇA")
	paragrafo("Mantimentos, café e os encontros que não cabem na rotina do cais.")
	_acao("Visitar o mercado", mostrar_loja.bind("mercado"))
	secao("DELIVERY DO MANÉ")
	paragrafo("A comida vem da cidade. As histórias vêm junto.")
	_acao("Ver o delivery", mostrar_loja.bind("delivery"))
	fio()
	_acao("História do porto", mostrar_historias)
	botao_fechar("Voltar ao porto")


func mostrar_loja(id: String) -> void:
	_loja = id
	_limpar("Mercado da Praça" if id == "mercado" else "Delivery do Mané")
	paragrafo("Dinheiro disponível: %s" % GameState.moeda(GameState.cash))
	_acao("Conversar com Seu Biu" if id == "mercado" else "Conversar com Mané", conversar)
	for produto in VidaDoPorto.PRODUTOS:
		var item: Dictionary = VidaDoPorto.PRODUTOS[produto]
		if item["loja"] != id:
			continue
		secao(String(item["nome"]).to_upper())
		paragrafo(String(item["efeito"]))
		if GameState.vida_do_porto["compras"].has(produto):
			paragrafo("Já comprado. A conversa está na História do porto.")
			_acao("Ler a conversa", abrir_capitulo.bind(produto, Origem.LOJA))
		else:
			var motivo: String = GameState.impedimento_compra_loja(produto)
			paragrafo("Preço: %s" % GameState.moeda(int(item["preco"])))
			if motivo == "":
				_acao("Comprar %s" % item["nome"], confirmar_compra.bind(produto))
			else:
				paragrafo(motivo)
	_acao("Voltar às lojas", mostrar_lojas)
	botao_fechar("Voltar ao porto")


func confirmar_compra(id: String) -> void:
	var item: Dictionary = VidaDoPorto.PRODUTOS[id]
	_limpar("Confirmar compra")
	secao(String(item["nome"]))
	paragrafo(String(item["efeito"]))
	paragrafo("Sai agora: %s\nSeu dinheiro depois: %s" % [
		GameState.moeda(int(item["preco"])), GameState.moeda(GameState.cash - int(item["preco"]))])
	_acao("Confirmar compra por %s" % GameState.moeda(int(item["preco"])), comprar.bind(id))
	_acao("Voltar sem comprar", mostrar_loja.bind(_loja))
	botao_fechar("Voltar ao porto")


func comprar(id: String) -> void:
	if GameState.comprar_na_loja(id):
		abrir_capitulo(id, Origem.LOJA)
	else:
		mostrar_loja(_loja)


func conversar() -> void:
	_visita = true
	_origem_conversa = Origem.LOJA
	_linha = 0
	_falas = Narrativa.falas_da_visita(_loja, GameState.vida_do_porto["cenas_lidas"])
	_mostrar_fala()


func mostrar_historias() -> void:
	_limpar("História do porto")
	var disponiveis: Array = GameState.capitulos_do_porto()
	if disponiveis.is_empty():
		paragrafo("A primeira história chega depois da primeira semana. As visitas às lojas já estão abertas.")
	for id in disponiveis:
		var lida: bool = GameState.vida_do_porto["cenas_lidas"].has(id)
		_acao(("Reler: " if lida else "Nova: ") + String(VidaDoPorto.CAPITULOS[id]), abrir_capitulo.bind(id, Origem.HISTORIAS))
	_acao("Voltar às lojas", mostrar_lojas)
	botao_fechar("Voltar ao porto")


func abrir_capitulo(id: String, origem: Origem = Origem.BOLETIM) -> void:
	if not GameState.capitulos_do_porto().has(id):
		return
	_visita = false
	# A origem pertence à conversa aberta, não ao save. O boletim continua
	# por baixo; loja e arquivo precisam reconstruir a tela de onde se veio.
	_origem_conversa = origem
	_linha = 0
	_falas = Narrativa.falas_da_historia(id)
	_capitulo = id
	_mostrar_fala()


func _mostrar_fala() -> void:
	# _limpar reinicia a seleção dos outros estados; esta conversa mantém o id
	# até a ÚLTIMA fala. Sair antes dela deixa a cena disponível para depois.
	var id := _capitulo
	_limpar("Uma conversa na cidade" if _visita else String(VidaDoPorto.CAPITULOS[id]))
	_capitulo = id
	var linha: Array = _falas[_linha]
	secao(String(linha[1]))
	var quem := String(linha[0])
	var retrato := Narrativa.retrato_da_historia(quem)
	var texto: String = GameState.texto(String(linha[2]))
	fala(texto, retrato, quem)
	# As visitas são locais ao estabelecimento; o grupo do celular só conhece
	# os retratos do porto. As cenas do arco, com essas vozes, ficam no grupo.
	if not _visita:
		falou.emit(quem, texto, retrato)
	if _linha + 1 < _falas.size():
		_acao("Continuar a conversa", _proxima_fala)
	else:
		_acao("Concluir conversa", _concluir_conversa)
	_acao(_texto_de_retorno(), _voltar_da_conversa)


func _proxima_fala() -> void:
	_linha += 1
	_mostrar_fala()


func _concluir_conversa() -> void:
	if not _visita:
		GameState.concluir_capitulo(_capitulo)
	_voltar_da_conversa()


func _texto_de_retorno() -> String:
	match _origem_conversa:
		Origem.LOJA:
			return "Voltar ao mercado" if _loja == "mercado" else "Voltar ao delivery"
		Origem.HISTORIAS:
			return "Voltar às histórias"
	return "Voltar ao boletim"


func _voltar_da_conversa() -> void:
	match _origem_conversa:
		Origem.LOJA:
			mostrar_loja(_loja)
		Origem.HISTORIAS:
			mostrar_historias()
		Origem.BOLETIM:
			_fechar()
