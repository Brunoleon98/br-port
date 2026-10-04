class_name PainelNarrativo
extends Control

# ============================================================
# BR Port VS — o andaime comum das telas narrativas
#
# Cinco das sete telas do A4 têm a mesma forma: escurece o fundo, abre um
# cartão no meio, põe título, texto e um botão. Os painéis que já existiam
# (Upgrade, CounterOffer, DebtPayment, EndGame) repetem esse andaime cada um
# por si — o que era aceitável com quatro e deixa de ser com nove.
#
# Não é refatoração dos antigos: eles ficam como estão, porque mexer neles sem
# necessidade é arriscar o que já foi jogado. Isto é o chão dos novos.
#
# O QUE ELE NÃO FAZ: pintar cor. Toda a aparência vem de `ui/tema_brport.tres`
# — cartão, botão, fonte —, que é o ponto único de estilo do projeto. O único
# valor de cor aqui é a opacidade do escurecimento, que não é cor de marca: é
# quanto do jogo se continua a ver por trás da tela.
# ============================================================

# Quanto o fundo escurece. As telas de leitura escurecem MAIS do que os painéis
# de decisão: numa tela de decisão o jogador quer ver o porto para decidir; num
# diário ou numa despedida, o porto atrás é distração.
const ESCURO_LEITURA := 0.88
const ESCURO_DECISAO := 0.7

# Alvo de toque mínimo (iOS/Android), o mesmo piso que o `teste_design.gd`
# exige do resto da interface.
const TOQUE_MIN := 44

# Emitido quando o painel se fecha. É o que permite encadear a abertura do
# jogo — os nomes, e a seguir o diário — sem cada painel saber quem vem depois.
signal fechou

# Emitido quando um PERSONAGEM diz uma fala na tela — o Sr. Ribeiro na
# cobrança, a Dona Cida no boletim. O `Main` grava-a no histórico da faixa, e
# a conversa do celular mostra-a no balão de quem a disse (`docs/decisoes/067`,
# terceira passagem: «eles também falam no chat»). É SINAL, e não uma chamada
# ao `Main`, pela razão do `fechou`: o painel não sabe quem o abriu.
signal falou(personagem: String, texto: String, retrato: Texture2D)

# O botão VOLTAR do Android pode fechar este painel?
#
# Quase sempre sim: um boletim, uma página do diário, uma lista — dispensar é
# a mesma coisa que tocar no botão. A exceção é a tela em que fechar DECIDE
# alguma coisa, e a tela dos nomes é isso: fechá-la batiza o cais com o padrão
# e a escolha é irrevogável (GDD 7). Um toque acidental no Voltar não pode
# nomear o porto de alguém.
#
# É uma declaração do painel e não uma lista no Main.gd de propósito: uma
# lista lá envelheceria calada no dia em que aparecesse o painel seguinte.
var fecha_com_voltar := true

var _vbox: VBoxContainer

# O retrato do último balão com cara. Guardado para quem precisa de o TROCAR
# no meio da tela — a cena da parcela é em dois tempos, e a cara do Sr.
# Ribeiro depois da decisão não é a mesma de antes dela. Sem isto o painel
# teria de o ir buscar pela árvore (`get_parent().get_child(0)`), que é o tipo
# de caminho cravado que se parte em silêncio no dia em que a linha ganha
# outro filho.
var _retrato_da_fala: TextureRect

# A última fala montada — ver `fala()` e `texto_da_fala()`.
var _fala_montada: Dictionary = {}

# A linha de apoio da última tarja — ver `tarja()`.
var _detalhe_da_tarja: Label


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0


# Monta o andaime e devolve a caixa onde o conteúdo entra.
#
# ALTURA 0 QUER DIZER "AJUSTA AO CONTEÚDO", e é o que quase todos querem. Com
# altura fixa o cartão fica maior do que o texto e sobra uma faixa branca
# debaixo do botão — apareceu em três painéis de uma vez na primeira captura.
# Pior: o mesmo painel muda de tamanho conforme o caso (o boletim ganha a linha
# da parcela na semana 4, o Sr. Ribeiro perde um botão quando há dinheiro), de
# modo que NENHUMA altura fixa serve às duas versões.
#
# Altura fixa continua a existir para quem tem área de rolagem: aí o tamanho é
# uma decisão de leitura, não uma consequência do texto.
#
# A VARIAÇÃO DO CARTÃO é um parâmetro porque o menu-celular não é um cartão
# branco: o corpo dele é o aparelho, e ele tem de sair do TEMA como tudo o
# resto. Com omissão vazia os doze painéis que já existem ficam exatamente
# como estavam — o `theme_type_variation` só se toca quando alguém o pede.
func montar(largura: int, altura: int, escuro: float = ESCURO_LEITURA,
		variacao: String = "") -> VBoxContainer:
	_escurecer(escuro)

	var caixa := PanelContainer.new()
	if variacao != "":
		caixa.theme_type_variation = variacao
	caixa.anchor_left = 0.5
	caixa.anchor_top = 0.5
	caixa.anchor_right = 0.5
	caixa.anchor_bottom = 0.5
	caixa.offset_left = -largura / 2.0
	caixa.offset_right = largura / 2.0
	if altura > 0:
		caixa.offset_top = -altura / 2.0
		caixa.offset_bottom = altura / 2.0
	else:
		# Sem offsets verticais a caixa tem altura zero; `GROW_DIRECTION_BOTH`
		# manda-a crescer para cima e para baixo a partir do centro, à medida
		# do tamanho mínimo que os filhos pedem.
		caixa.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(caixa)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 10)
	caixa.add_child(_vbox)
	return _vbox


func _escurecer(escuro: float) -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, escuro)
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	add_child(fundo)


# Um bloco de texto que quebra sozinho. Praticamente todo o conteúdo narrativo
# é isto, e esquecer o autowrap é o que faz a fala sair numa linha só, cortada
# na borda do cartão.
func paragrafo(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.text = texto
	_vbox.add_child(rotulo)
	return rotulo


# Texto comprido dentro de uma área que rola. A página do diário e a narração
# de fim de fase não cabem nos 1280px de altura do retrato com o resto da
# interface à volta, e um Label que estoure o cartão desenha POR FORA dele.
func paragrafo_rolavel(texto: String, altura: int) -> ScrollContainer:
	var rolo := ScrollContainer.new()
	rolo.custom_minimum_size = Vector2(0, altura)
	rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_vbox.add_child(rolo)

	var rotulo := Label.new()
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.text = texto
	# Sem isto o Label toma a largura que quiser e o rolo cresce na horizontal,
	# que é justamente o que o modo desligado acima não consegue impedir
	# sozinho.
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolo.add_child(rotulo)
	return rolo


## QUANTO PEDE ESTE TEXTO, em pixels, na fonte que o tema vai mesmo usar.
##
## ⚠️ EXISTE PORQUE ALTURA DE ÁREA ROLÁVEL ESCRITA À MÃO ENVELHECE CALADA. O
## `paragrafo_rolavel` recebia um número — 430 no fim de fase —, e área rolável
## não CORTA, esconde: metade da narração, o remate incluído, ficava por baixo
## da dobra com o botão logo abaixo a convidar a sair. O diário levou a mesma
## mordida em 11/09 e foi remedido à mão; o painel irmão não, porque ninguém o
## voltou a fotografar. Medir tira o número da mão de quem escreve o texto.
##
## A largura é a do cartão menos o que o tema gasta de margem — pedida ao
## próprio rótulo depois de ele estar na árvore, e não adivinhada.
func altura_do_texto(texto: String, largura: int) -> int:
	var fonte: Font = get_theme_font("font", "Label")
	var tamanho: int = get_theme_font_size("font_size", "Label")
	if fonte == null or largura <= 0:
		return 0
	var bruto: float = fonte.get_multiline_string_size(
		texto, HORIZONTAL_ALIGNMENT_LEFT, float(largura), tamanho).y
	# ⚠️ E O `line_spacing` DO TEMA ENTRA POR FORA. O `get_multiline_string_size`
	# devolve a soma das linhas e mais nada; o `Label` acrescenta o espaçamento
	# ENTRE elas, que aqui vale 3 px. Sem esta parcela a conta sai ~12% curta e
	# a última dobra do texto fica escondida — que é exatamente o defeito que
	# esta função existe para acabar, a reaparecer dentro dela.
	#
	# Medido no fim de fase: bruto 748 px (34 linhas x 22), o rótulo pede 847,
	# e 847 - 748 = 99 = 33 x 3. Bate ao pixel com o que o `Label` calcula.
	var altura_linha: float = fonte.get_height(tamanho)
	var linhas: int = int(round(bruto / altura_linha)) if altura_linha > 0.0 else 0
	var espaco: int = get_theme_constant("line_spacing", "Label")
	return int(ceil(bruto + maxi(linhas - 1, 0) * espaco))


# Cabeçalho de bloco — RECEITAS, DESPESAS. Cinza e menor que o corpo, porque a
# função dele é agrupar e sair da frente, não competir com os números.
func secao(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.theme_type_variation = "RotuloSecao"
	rotulo.text = texto
	_vbox.add_child(rotulo)
	return rotulo


# A linha que o olho tem de encontrar primeiro. Uma só por tela: duas em
# destaque é nenhuma em destaque.
func total(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.theme_type_variation = "RotuloTotal"
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.text = texto
	_vbox.add_child(rotulo)
	return rotulo


# FALA DE PERSONAGEM, e não mais uma linha de relatório. As telas narrativas
# misturam dois registros — o que o jogo informa e o que alguém diz — e sem
# diferença visual a fala da Dona Cida lia como rodapé de planilha. O balão vem
# do tema, como toda a aparência deste projeto.
#
# `quem` ESCOLHE O BALÃO E A PLACA DA PESSOA (`docs/decisoes/082`): o mesmo
# tom que o celular já dava a cada uma (`067`). Sem pessoa, o balão é o `Fala`
# de sempre e não há placa.
#
# Devolve a fala MONTADA (ver `linha_de_fala()`): quem troca o texto quando a
# cena avança — a cena da parcela, em dois tempos — passa-a a `escrever_fala()`
# em vez de mexer num rótulo, porque o texto pode ocupar mais de um balão.
func fala(texto: String, retrato: Texture2D = null, quem: String = "") -> Dictionary:
	var montada := linha_de_fala(texto, retrato, quem)
	_vbox.add_child(montada["linha"])
	_retrato_da_fala = montada["retrato"]
	_fala_montada = montada
	return montada


# O que a última fala do painel MOSTRA, balão a balão — para quem confere a
# tela e não a fala pedida (`CLAUDE.md`: fala disparada não é fala vista).
func texto_da_fala() -> String:
	return texto_montado(_fala_montada)


# A LINHA DA FALA, estática porque a contra-oferta não herda deste andaime e
# tem de vestir a MESMA linha — como a `tarja_solta()`. Devolve um dicionário:
# a `linha` (o que entra no cartão), o primeiro `balao` e o `rotulo` dele, o
# `retrato` (`null` sem retrato), quem fala e a coluna dos balões `seguidos`.
#
# ⚠️ O RETRATO SENTA NUMA PLACA DA COR DE QUEM FALA (`082`). Solto, o busto de
# 112 x 152 ficava cortado a seco sobre o branco; na placa, o corte do peito é
# a borda de baixo dela, e a cara fica encostada a ele.
#
# ⚠️ E A FALA LONGA PARTE-SE EM BALÕES, UM POR PARÁGRAFO, como no celular. A
# primeira versão esticava a placa até ao fim do balão — e o Sr. Ribeiro, que
# fala dez linhas nos dois tempos, ficava numa coluna cinzenta de 310 px com o
# busto lá em baixo e 150 px de placa vazia por cima da cabeça. Partida no
# `\n\n` que a fala já trazia, o primeiro balão fica ao lado da cara, com o
# bico, e os outros descem colados a ele na mesma coluna, sem bico
# (`BalaoXSeguido`) — a gramática que o celular já usa para duas falas
# seguidas da mesma pessoa. A placa fica com a altura dela, e o que sobra por
# baixo é a margem de quem fala, como no telefone.
#
# ⚠️ OS SEGUIDOS VÃO NA COLUNA DO PRIMEIRO, E NÃO POR BAIXO DA LINHA. A
# segunda versão punha-os por baixo da placa, e o vão entre dois balões saía
# do comprimento do primeiro: 76 px no Arlindo da última tentativa, 6 no Sr.
# Ribeiro da entrada — uma pausa que ninguém desenhou.
static func linha_de_fala(texto: String, retrato: Texture2D = null,
		quem: String = "") -> Dictionary:
	var balao := _balao_de_fala(quem, true)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", SEPARACAO_BALOES)
	coluna.add_child(balao)
	var seguidos := VBoxContainer.new()
	seguidos.add_theme_constant_override("separation", SEPARACAO_BALOES)
	coluna.add_child(seguidos)
	var montada := {"linha": coluna, "balao": balao, "rotulo": balao.get_child(0),
		"retrato": null, "quem": quem, "seguidos": seguidos}
	if retrato == null:
		escrever_fala(montada, texto)
		return montada

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", SEPARACAO_RETRATO)
	var placa := PanelContainer.new()
	_vestir_placa(placa, quem)
	var img := Retratos.imagem(retrato)
	# Encostado ao fundo da placa — o corte do peito é a borda dela.
	img.size_flags_vertical = Control.SIZE_SHRINK_END
	placa.add_child(img)
	# ⚠️ A PLACA RECORTA O RETRATO PELOS CANTOS REDONDOS DELA. Sem isto os
	# ombros, que chegam à borda de baixo, saem em canto vivo por fora da curva.
	placa.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	# A placa não estica: com a altura do busto, a borda de baixo é o corte.
	placa.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	linha.add_child(placa)
	# Sem isto a coluna encolhe ao tamanho do texto e a linha fica com um vão
	# vazio à direita — o retrato empurra, e os balões ocupam o resto. Na
	# vertical cada balão hugs o texto dele, dentro da coluna.
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(coluna)
	# O RABICHO do primeiro balão, no vão entre ele e a placa — ver abaixo.
	balao.draw.connect(func() -> void: _desenhar_rabicho(balao))
	montada["linha"] = linha
	montada["retrato"] = img
	escrever_fala(montada, texto)
	return montada


const SEPARACAO_RETRATO := 10
const SEPARACAO_BALOES := 6

# O RABICHO (segunda passagem, `082`, melhoria por conta própria que o Bruno
# liberou): um triângulo da cor do balão no vão de 10 px até à placa, à altura
# da primeira linha — o balão APONTA para quem fala. Até aqui o «bico» era só
# o canto de cima com raio 4 em vez de 14, a gramática do celular, e num
# cartão de cena isso mal se lia como fala. Desenhado pelo próprio balão, na
# cor que o tema lhe dá: muda com a pessoa sem uma cor escrita aqui.
const RABICHO_COMPRIMENTO := 8.0   # quanto avança para a placa (o vão é 10)
const RABICHO_BASE := 14.0         # a altura da base, encostada ao balão
const RABICHO_TOPO := 10.0         # onde a base começa, desde o topo do balão


static func _desenhar_rabicho(balao: PanelContainer) -> void:
	var estilo := balao.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo == null:
		return
	# A ponta fica no primeiro terço da base: o rabicho inclina para cima, para
	# a cara, que no busto está na metade de cima da placa.
	var pontos := PackedVector2Array([
		Vector2(1.0, RABICHO_TOPO),
		Vector2(-RABICHO_COMPRIMENTO, RABICHO_TOPO + RABICHO_BASE * 0.3),
		Vector2(1.0, RABICHO_TOPO + RABICHO_BASE)])
	balao.draw_colored_polygon(pontos, estilo.bg_color)
	# O polígono não suaviza a diagonal; o contorno na mesma cor suaviza.
	balao.draw_polyline(PackedVector2Array([pontos[0], pontos[1], pontos[2]]),
		estilo.bg_color, 1.0, true)


# Escreve a fala nos balões: o primeiro parágrafo no balão ao lado da cara, e
# cada um dos outros num balão seguido. Os seguidos refazem-se a cada escrita,
# porque a fala do segundo tempo tem outro número de parágrafos.
static func escrever_fala(montada: Dictionary, texto: String) -> void:
	var partes := texto.split("\n\n", false)
	(montada["rotulo"] as Label).text = partes[0] if partes.size() > 0 else ""
	var seguidos: VBoxContainer = montada["seguidos"]
	for velho in seguidos.get_children():
		seguidos.remove_child(velho)
		velho.queue_free()
	for i in range(1, partes.size()):
		var outro := _balao_de_fala(String(montada["quem"]), false)
		(outro.get_child(0) as Label).text = partes[i]
		seguidos.add_child(outro)
	# Sem seguidos a caixa deles esconde-se: visível e vazia, a separação da
	# coluna deixaria 6 px de vão por baixo de toda fala de um parágrafo só.
	seguidos.visible = partes.size() > 1


# O texto que a fala montada mostra, os balões juntos pela mesma quebra que os
# partiu — é o que se compara com a fala pedida.
static func texto_montado(montada: Dictionary) -> String:
	if montada.is_empty():
		return ""
	var partes: Array[String] = [(montada["rotulo"] as Label).text]
	for outro in (montada["seguidos"] as VBoxContainer).get_children():
		partes.append((outro.get_child(0) as Label).text)
	return "\n\n".join(partes)


static func _balao_de_fala(quem: String, com_bico: bool) -> PanelContainer:
	var balao := PanelContainer.new()
	if not _vestir_balao(balao, quem, com_bico):
		balao.theme_type_variation = &"Fala"
	var rotulo := Label.new()
	# A VOZ EM LETRA REGULAR (`082`): o resto do cartão — título, tarja,
	# botões — fica no seminegrito, que é o que o faz ler como informação.
	rotulo.theme_type_variation = &"TextoFala"
	# ⚠️ `_SMART`, PORQUE A FALA LEVA O NOME DE QUEM JOGA. O `AUTOWRAP_WORD` só
	# quebra em fronteira de palavra, e a tela de nomes aceita 24 letras sem
	# espaço: medido em 23/09, "Boa tarde, WWWW…" desenhava a palavra inteira
	# numa linha e passava POR FORA do cartão. O `_SMART` só parte a palavra que
	# não cabe — num texto sem ela as linhas saem as mesmas, ao pixel. O F10 do
	# fumaça tranca (`docs/decisoes/051`).
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	balao.add_child(rotulo)
	return balao


# O balão e a placa de cada pessoa — os do celular (`067`), que aqui servem
# também aos cartões; devolve `false` para quem não tem balão, e cada um dos
# dois sítios decide o que isso quer dizer. ⚠️ LITERAIS, um por ramo, e não
# um dicionário: o `conferir_escopo_ui.py` confere que toda variação usada
# existe no tema, e só a acha escrita depois de um `=`. Num `.get()` o nome
# escaparia à guarda, e um erro de digitação cairia no `PanelContainer` base —
# o cartão branco — sem uma palavra (`docs/decisoes/042`).
static func _vestir_balao(balao: PanelContainer, quem: String, com_bico: bool) -> bool:
	match quem:
		"cida":
			if com_bico:
				balao.theme_type_variation = &"BalaoCida"
			else:
				balao.theme_type_variation = &"BalaoCidaSeguido"
		"ribeiro":
			if com_bico:
				balao.theme_type_variation = &"BalaoRibeiro"
			else:
				balao.theme_type_variation = &"BalaoRibeiroSeguido"
		"arlindo":
			if com_bico:
				balao.theme_type_variation = &"BalaoArlindo"
			else:
				balao.theme_type_variation = &"BalaoArlindoSeguido"
		_:
			return false
	return true


static func _vestir_placa(placa: PanelContainer, quem: String) -> void:
	match quem:
		"cida":
			placa.theme_type_variation = &"PlacaFalaCida"
		"ribeiro":
			placa.theme_type_variation = &"PlacaFalaRibeiro"
		"arlindo":
			placa.theme_type_variation = &"PlacaFalaArlindo"
		_:
			placa.theme_type_variation = &"PlacaRetrato"


# A cara do último balão, para o painel a trocar quando a cena avança.
func retrato_da_fala() -> TextureRect:
	return _retrato_da_fala


# Um fio para separar blocos. Vale mais que um espaço em branco: o espaço diz
# "respira", o fio diz "acabou aqui".
func fio() -> HSeparator:
	var linha := HSeparator.new()
	_vbox.add_child(linha)
	return linha


func titulo(icone: Texture2D, texto: String) -> void:
	_vbox.add_child(Icones.rotulo(icone, texto, Icones.TAM_TITULO, true))


# Cabeçalho da família com personagem. O selo claro é parte do tema: o ícone
# da parcela é navy e desapareceria se fosse pousado direto sobre o navy.
func titulo_encorpado(icone: Texture2D, texto: String) -> void:
	_vbox.add_child(cabecalho_encorpado(icone, texto))


static func cabecalho_encorpado(icone: Texture2D, texto: String) -> PanelContainer:
	var faixa := PanelContainer.new()
	faixa.theme_type_variation = "CabecalhoNarrativo"
	faixa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	faixa.add_child(linha)
	var selo := PanelContainer.new()
	selo.theme_type_variation = "SeloNarrativo"
	selo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	selo.add_child(Icones.imagem(icone, Icones.TAM_TITULO))
	linha.add_child(selo)
	var rotulo := Label.new()
	rotulo.theme_type_variation = "TituloNarrativo"
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotulo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(rotulo)
	return faixa


# A tarja dá um ponto de leitura aos valores que comandam a decisão sem
# transformar o restante da fala ou da contabilidade num segundo destaque.
#
# ⚠️ E O NÚMERO QUE ELA DESTACA LEVA AO LADO AS PARCELAS DE QUE SAI (25/09,
# terceira passagem da frente 3). A cobrança dizia «Faltam R$194.000» na
# tarja, o dinheiro numa linha cinzenta por baixo e a parcela dentro da fala —
# três sítios para uma subtração que o jogador quer poder conferir. O
# `detalhe` é essa linha de apoio: menor, na cor de apoio, DENTRO da tarja,
# e nunca um segundo destaque. Vazio, não ocupa lugar.
func tarja(texto: String, detalhe: String = "", tom: StringName = &"neutro") -> Label:
	var painel := tarja_solta(texto, detalhe, tom)
	_vbox.add_child(painel)
	_detalhe_da_tarja = painel.get_node("Linhas/Detalhe")
	return painel.get_node("Linhas/Principal")


# A linha de apoio da última tarja, para o painel a trocar quando a cena
# avança — o mesmo padrão do `retrato_da_fala()`.
func detalhe_da_tarja() -> Label:
	return _detalhe_da_tarja


# O `detalhe` vazio ESCONDE a linha em vez de a deixar em branco: um rótulo
# vazio visível ainda ocupa a altura de uma linha, e a tarja do boletim sem
# semana anterior sairia com um vão creme por baixo do lucro.
static func escrever_detalhe(rotulo: Label, texto: String) -> void:
	rotulo.text = texto
	rotulo.visible = texto != ""


# Estática porque a contra-oferta não herda deste andaime (é anterior a ele) e
# tem de vestir a MESMA tarja — o estilo continua a sair de um lugar só, como o
# `cabecalho_encorpado()`. Os nós têm nome para quem os troca depois.
static func tarja_solta(texto: String, detalhe: String = "",
		tom: StringName = &"neutro") -> PanelContainer:
	var painel := PanelContainer.new()
	painel.theme_type_variation = "TarjaNarrativa"
	var linhas := VBoxContainer.new()
	linhas.name = "Linhas"
	linhas.add_theme_constant_override("separation", 2)
	painel.add_child(linhas)
	var rotulo := Label.new()
	rotulo.name = "Principal"
	rotulo.theme_type_variation = "RotuloTotal"
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.text = texto
	linhas.add_child(rotulo)
	var apoio := Label.new()
	apoio.name = "Detalhe"
	apoio.theme_type_variation = "RotuloApoio"
	apoio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	escrever_detalhe(apoio, detalhe)
	linhas.add_child(apoio)
	tingir_tarja(rotulo, tom)
	return painel


# O TOM DA TARJA, a partir do rótulo principal dela — `&"bom"`, `&"ruim"` ou
# `&"neutro"` (25/09, quinta passagem). A resposta da cobrança e a despedida do
# Arlindo trocam o texto E o tom da mesma tarja, e é por isso que isto recebe
# o rótulo que os painéis já guardam.
#
# ⚠️ QUEM ESCOLHE O TOM É QUEM ESCREVE A PALAVRA, e ela vem primeiro: o verde
# e o vermelho só repetem o que «Lucro», «Faltam» ou «perdido» já dizem. O F14
# confere que os dois concordam.
#
# ⚠️ E AS VARIAÇÕES SÃO LITERAIS, uma por ramo: o `conferir_escopo_ui.py` só
# confere o nome que vê escrito depois do `=` (`041`).
static func tingir_tarja(principal: Label, tom: StringName) -> void:
	var painel := principal.get_parent().get_parent() as PanelContainer
	match tom:
		&"bom":
			painel.theme_type_variation = &"TarjaNarrativaBoa"
			principal.theme_type_variation = &"RotuloTotalBom"
		&"ruim":
			painel.theme_type_variation = &"TarjaNarrativaRuim"
			principal.theme_type_variation = &"RotuloTotalRuim"
		_:
			painel.theme_type_variation = &"TarjaNarrativa"
			principal.theme_type_variation = &"RotuloTotal"


# ── AS PEÇAS DE NÚMERO DA FAMÍLIA (`063`, `065`) ──
# Viviam dentro do boletim (o bloco de contas) e do balanço (o quadro), e os
# painéis do HUD passaram a precisar das duas (26/09): o dinheiro do dia é a
# pergunta do boletim numa janela mais curta, e os recordes e as docas são
# números da partida como os do balanço. Duas cópias da mesma peça divergem;
# uma no andaime não.

# O TOTAL SOBE PARA A LINHA DO BLOCO, e as parcelas descem de tom (25/09,
# quarta passagem). Era «ENTROU» em cinza pequeno, quatro linhas, um fio e uma
# linha «Total» com o mesmo peso de cada parcela — e outro tanto para o SAIU:
# duas linhas «Total» num cartão só, e o olho a descer a lista inteira para
# achar os dois números que a Dona Cida comenta. É o desenho das finanças do
# *Two Point Hospital* e do fim de dia do *Papers, Please*: de onde entrou e
# para onde saiu, cada bloco encabeçado pelo seu total, com o detalhe por
# baixo (`docs/design/BR_Port_Referencias_Interface_Gestao.md`).
#
# ⚠️ SEM SINAL E SEM COR. A palavra do bloco já diz de que lado está o
# dinheiro — «Saiu −R$49.000» dizia-o duas vezes, que é a dupla negação que o
# `lucro_ou_prejuizo()` já recusa —, e verde contra vermelho não se lê sem
# distinguir as duas cores, nem o tema tem esse par medido sobre o branco.
#
# LINHA COM ZERO NÃO ENTRA: é ruído que o olho descarta a cada abertura.
func bloco_de_contas(nome: String, linhas: Array, soma: int) -> void:
	var cabeca := GridContainer.new()
	cabeca.columns = 2
	cabeca.add_theme_constant_override("h_separation", 16)
	_vbox.add_child(cabeca)
	var titulo_bloco := Label.new()
	titulo_bloco.text = nome
	titulo_bloco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabeca.add_child(titulo_bloco)
	var total_bloco := Label.new()
	total_bloco.text = moeda(soma)
	total_bloco.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cabeca.add_child(total_bloco)

	# As parcelas recuadas e no tom de apoio: detalhe do total de cima.
	var recuo := MarginContainer.new()
	recuo.add_theme_constant_override("margin_left", 14)
	_vbox.add_child(recuo)
	var grade := GridContainer.new()
	grade.columns = 2
	grade.add_theme_constant_override("h_separation", 16)
	grade.add_theme_constant_override("v_separation", 2)
	recuo.add_child(grade)
	for linha in linhas:
		if int(linha[1]) == 0:
			continue
		linha_de_apoio(grade, String(linha[0]), moeda(int(linha[1])))


# O dinheiro pelo `GameState.moeda()`, que é o único sítio que o escreve.
#
# ⚠️ PELA ÁRVORE E NÃO PELO NOME: este arquivo é um `class_name`, e uma
# classe alcançada a partir de um `--script` compila antes de os autoloads
# existirem — `GameState.x` aqui dentro derrubaria a suíte inteira com
# «Identifier not found» (`CLAUDE.md`, Estilo de código).
static func moeda(valor: int) -> String:
	var gs: Node = (Engine.get_main_loop() as SceneTree).root.get_node("GameState")
	return gs.moeda(valor)


# Rótulo à esquerda, valor à direita, os dois no tom de apoio. O valor alinha
# à direita porque é assim que se comparam números empilhados — alinhados à
# esquerda, R$1.200 e R$980 parecem do mesmo tamanho.
static func linha_de_apoio(grade: GridContainer, rotulo: String, valor: String) -> void:
	var esquerda := Label.new()
	esquerda.theme_type_variation = "RotuloApoio"
	esquerda.text = rotulo
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade.add_child(esquerda)

	var direita := Label.new()
	direita.theme_type_variation = "RotuloApoio"
	direita.text = valor
	direita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grade.add_child(direita)


# A grade dos quadros de número, e cada quadro dentro dela. É a caixa do lucro
# das finanças do *Two Point Hospital* (`063`): o número em destaque, cada um
# no seu quadro.
#
# ⚠️ O RÓTULO VAI EM CIMA E NÃO CONCORDA COM O NÚMERO, de propósito: é o nome
# da categoria («Barcos atendidos», com 1 ou com 24), e por isso não precisa
# do `concordar()` que o F9 exige a toda contagem escrita em frase.
#
# O `detalhe` é a linha de apoio POR BAIXO do número — o dia do recorde, o
# tipo do negócio —, e vazio não ocupa lugar.
func grade_de_quadros(colunas: int = 2) -> GridContainer:
	var quadros := GridContainer.new()
	quadros.columns = colunas
	quadros.add_theme_constant_override("h_separation", 8)
	quadros.add_theme_constant_override("v_separation", 8)
	_vbox.add_child(quadros)
	return quadros


static func quadro(grade: GridContainer, nome: String, numero: String,
		detalhe: String = "") -> PanelContainer:
	var bloco := PanelContainer.new()
	bloco.theme_type_variation = "BlocoNumero"
	bloco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	bloco.add_child(coluna)
	var rotulo := Label.new()
	rotulo.theme_type_variation = "RotuloApoio"
	rotulo.text = nome
	coluna.add_child(rotulo)
	var valor := Label.new()
	valor.theme_type_variation = "NumeroGrande"
	valor.text = numero
	coluna.add_child(valor)
	if detalhe != "":
		var apoio := Label.new()
		apoio.theme_type_variation = "RotuloApoio"
		apoio.text = detalhe
		apoio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		coluna.add_child(apoio)
	grade.add_child(bloco)
	return bloco


# A BARRA DO HUD, no estilo base do tema (`063`): o jogador passa a partida a
# olhar para a barra da parcela no rodapé, e cada painel que mostra uma coisa
# a andar para uma meta usa o MESMO desenho — uma barra de outro estilo seria
# outra coisa para aprender. Não recebe toque e não escreve número: o texto ao
# lado é quem diz quanto; ela diz quanto FALTA à vista (26/09, `065`).
static func barra_do_hud(valor: float, maximo: float, minimo: float = 0.0) -> ProgressBar:
	var barra := ProgressBar.new()
	barra.name = "Barra"
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 10)
	barra.min_value = minimo
	barra.max_value = maximo
	barra.value = clampf(valor, minimo, maximo)
	return barra


# A barra DENTRO da última tarja, entre o número e a linha de apoio — o sítio
# que a cobrança do Sr. Ribeiro lhe deu primeiro.
func barra_na_tarja(valor: float, maximo: float) -> ProgressBar:
	var barra := barra_do_hud(valor, maximo)
	var linhas := _detalhe_da_tarja.get_parent()
	linhas.add_child(barra)
	linhas.move_child(barra, _detalhe_da_tarja.get_index())
	return barra


# ── O CADERNO (`docs/decisoes/067`) ──
# O diário e a tela de nomes são o MESMO objeto: a folha de rosto de um
# caderno de capa dura e a primeira página dele. Escolha do Bruno (26/09):
# «caderno, letra à mão» e «folha de rosto do diário», com a página a virar
# para a primeira entrada ao abrir o porto. Os dois painéis montam o caderno
# no MESMO retângulo, e é isso que faz a virada ler como uma página e não como
# duas telas — daí as medidas viverem aqui e não em cada painel.
#
# O papel e a capa são `StyleBoxFlat` do tema, e é contra o creme da página
# que o D33 mede a tinta; a pauta, a margem, a lombada e a fita desenha-as a
# `FolhaDoCaderno.gd`, com as cores do tema.
const FolhaDoCaderno := preload("res://scripts/FolhaDoCaderno.gd")
const PAPEL := preload("res://ui/shaders/papel.gdshader")
const TINTA := preload("res://ui/shaders/tinta.gdshader")
const CADERNO_LARGURA := 640
const CADERNO_ALTURA := 880
# O caderno fica no centro da tela: por cima dele sobra o lugar da legenda da
# tela de nomes, por baixo o do botão. O desvio existe para o caso de a
# legenda precisar de mais vão, e hoje é zero.
const CADERNO_DESCE := 0
const CADERNO_BOTAO_VAO := 22
# O ícone ao lado do título da legenda: da altura das maiúsculas do
# `TituloAbertura` (26 px) e um pouco mais, como o selo dos cartões.
const LEGENDA_ICONE := 30
# As margens do texto dentro da página. Na página pautada o texto começa
# depois da linha vermelha; na folha de rosto não há linha, e a margem é a do
# papel.
const PAGINA_MARGEM_PAUTADA := 58
const PAGINA_MARGEM_LISA := 34
const PAGINA_MARGEM_DIR := 26
const PAGINA_MARGEM_TOPO := 24
const PAGINA_MARGEM_PE := 20

var _caderno_capa: PanelContainer
var _pagina: PanelContainer
var _folha: Control
var _paginas := 0


func montar_caderno(escuro: float = ESCURO_LEITURA) -> PanelContainer:
	_escurecer(escuro)
	var capa := PanelContainer.new()
	capa.name = "Caderno"
	capa.theme_type_variation = &"CadernoCapa"
	capa.anchor_left = 0.5
	capa.anchor_top = 0.5
	capa.anchor_right = 0.5
	capa.anchor_bottom = 0.5
	capa.offset_left = -CADERNO_LARGURA / 2.0
	capa.offset_right = CADERNO_LARGURA / 2.0
	capa.offset_top = -CADERNO_ALTURA / 2.0 + CADERNO_DESCE
	capa.offset_bottom = CADERNO_ALTURA / 2.0 + CADERNO_DESCE
	add_child(capa)
	# A costura, os cantos gastos e as folhas empilhadas: o primeiro filho da
	# capa, por baixo das páginas, que o tapam no meio.
	var desenho := FolhaDoCaderno.CapaDoCaderno.new()
	desenho.name = "Capa"
	capa.add_child(desenho)
	_caderno_capa = capa
	return capa


# Uma página dentro da capa, e a caixa onde o conteúdo dela entra. Chamada
# DUAS vezes empilha duas páginas — a de baixo primeiro —, que é o que a tela
# de nomes faz para a virada ter o que revelar.
#
# ⚠️ A FITA É DO LIVRO, NÃO DA PÁGINA: quem a desenha é a página de BAIXO. Se
# fosse a de cima, a fita virava com a folha.
func pagina_do_caderno(pautada: bool, com_fita: bool,
		orelha: int = FolhaDoCaderno.Orelha.NENHUMA) -> VBoxContainer:
	var papel := PanelContainer.new()
	papel.name = "Pagina"
	papel.theme_type_variation = &"CadernoPagina"
	_caderno_capa.add_child(papel)
	_paginas += 1
	papel.add_child(_fibra_do_papel(papel, _paginas))
	var folha := FolhaDoCaderno.new()
	folha.name = "Folha"
	folha.pautada = pautada
	folha.com_fita = com_fita
	folha.orelha = orelha
	# Cada página com o seu papel: a folha de rosto e a entrada que ela revela
	# não podem ter as manchas no mesmo sítio.
	folha.semente = _paginas
	papel.add_child(folha)

	var margem := MarginContainer.new()
	margem.add_theme_constant_override("margin_left",
		PAGINA_MARGEM_PAUTADA if pautada else PAGINA_MARGEM_LISA)
	margem.add_theme_constant_override("margin_right", PAGINA_MARGEM_DIR)
	margem.add_theme_constant_override("margin_top", PAGINA_MARGEM_TOPO)
	margem.add_theme_constant_override("margin_bottom", PAGINA_MARGEM_PE)
	papel.add_child(margem)
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 12)
	margem.add_child(caixa)

	_pagina = papel
	_folha = folha
	_vbox = caixa
	return caixa


func pagina_atual() -> PanelContainer:
	return _pagina


# A FIBRA DO PAPEL VELHO, num shader por cima do creme (`ui/shaders/papel.gdshader`).
# ⚠️ É UM `ColorRect` TRANSPARENTE, e isso importa para a régua do contraste:
# ela lê um `ColorRect` irmão por trás do texto como um fundo, e um alfa zero
# deixa-a seguir até ao creme da página, que é contra o que a tinta se mede.
# As cores são do tema (`CadernoPagina/colors/grao` e `mancha`).
func _fibra_do_papel(papel: PanelContainer, semente: int) -> ColorRect:
	var fibra := ColorRect.new()
	fibra.name = "Fibra"
	fibra.color = Color(1, 1, 1, 0)
	fibra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = PAPEL
	m.set_shader_parameter("semente", float(semente))
	fibra.material = m
	fibra.resized.connect(func() -> void:
		m.set_shader_parameter("tamanho", fibra.size)
		m.set_shader_parameter("fibra", papel.get_theme_color("grao", &"CadernoPagina"))
		m.set_shader_parameter("mancha", papel.get_theme_color("mancha", &"CadernoPagina")))
	return fibra


# A TINTA DE CANETA nos textos à mão: o tom varia ao longo do traço
# (`ui/shaders/tinta.gdshader`). O shader só multiplica a cor que o tema dá.
static func tinta_de_caneta(no: CanvasItem) -> void:
	var m := ShaderMaterial.new()
	m.shader = TINTA
	no.material = m


# UMA ENTRADA DO DIÁRIO: a data à direita, uma linha em branco, o texto — tudo
# na letra à mão e no ritmo da pauta.
#
# ⚠️ O RITMO É O DA PAUTA, e é o TEMA que o segura. A data e o texto são dois
# rótulos, e só caem em linhas seguidas da pauta se o vão entre eles for o
# `line_spacing` da letra: é a `CadernoLinhas`, cuja separação o tema escreve
# igual ao `line_spacing` da `TextoCaderno`. A linha em branco é a quebra no
# fim da data, e não um espaçador em pixel — um espaçador envelheceria no dia
# em que a letra mudasse de tamanho.
#
# ⚠️ E NADA AQUI LÊ O TEMA NA MONTAGEM: a ferramenta de captura aplica-o
# depois do `_ready()`, e um número lido cedo seria o do tema padrão. A pauta
# lê-o ao desenhar (`FolhaDoCaderno`).
#
# Sem `cabecalho` é a CONTINUAÇÃO de uma entrada (a segunda página do fim de
# fase, `082`): página que continua não volta a datar-se, e a pauta acerta
# pelo próprio texto.
func entrada_do_diario(cabecalho: String, texto: String) -> Label:
	var linhas := VBoxContainer.new()
	linhas.name = "Entrada"
	linhas.theme_type_variation = &"CadernoLinhas"
	_vbox.add_child(linhas)
	var data: Label = null
	if cabecalho != "":
		data = Label.new()
		data.name = "Data"
		data.theme_type_variation = &"TextoCaderno"
		data.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		data.text = cabecalho + "\n"
		linhas.add_child(data)
	var corpo := Label.new()
	corpo.name = "Texto"
	corpo.theme_type_variation = &"TextoCaderno"
	# `_SMART` pela razão da `fala()`: o texto leva o nome do cais, e a tela
	# de nomes aceita 24 letras sem espaço.
	corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	corpo.text = texto
	linhas.add_child(corpo)
	tinta_de_caneta(corpo)
	if data != null:
		tinta_de_caneta(data)
		_folha.pautar_por(data)
	else:
		_folha.pautar_por(corpo, false)
	return corpo


# Texto IMPRESSO na folha — o rótulo de um campo, a nota de pé de página. É a
# letra do jogo, pequena e na cor de tinta de gráfica, para não se confundir
# com o que se escreve à mão por cima dela.
func impresso(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.theme_type_variation = &"ImpressoCaderno"
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.text = texto
	_vbox.add_child(rotulo)
	return rotulo


# Um campo que se preenche À MÃO: a letra do caderno sobre uma linha, sem
# caixa à volta — o que se escreve numa folha de rosto.
#
# ⚠️ A SUGESTÃO É IMPRESSA, e não o `placeholder_text` do campo: o placeholder
# sai na fonte do campo, que é a letra à mão, e «Cais Mirim» e «(pode deixar
# em branco)» liam-se como já escritos, só mais claros (o Bruno apontou-o na
# primeira passagem). Um rótulo na letra impressa, dentro do campo e escondido
# assim que se escreve, lê-se como o exemplo de um formulário.
func campo_a_mao(sugestao: String) -> LineEdit:
	var entrada := LineEdit.new()
	entrada.theme_type_variation = &"CampoCaderno"
	entrada.custom_minimum_size = Vector2(0, TOQUE_MIN + 8)
	# SEM a tinta de caneta: o shader multiplica tudo o que o nó desenha, e no
	# campo isso é também o fundo dele — o papel da etiqueta saía às nuvens.
	_vbox.add_child(entrada)
	var dica := Label.new()
	dica.name = "Sugestao"
	dica.theme_type_variation = &"SugestaoCaderno"
	dica.text = sugestao
	dica.anchor_right = 1.0
	dica.anchor_bottom = 1.0
	dica.offset_left = 6
	dica.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dica.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entrada.add_child(dica)
	entrada.text_changed.connect(func(t: String) -> void: dica.visible = t == "")
	return entrada


# A ETIQUETA ADESIVA da folha de rosto: o rótulo de caderno escolar, creme,
# de filete azul e cantos redondos, colado um pouco torto. Era um quadro de
# filete duplo até à terceira passagem, e o Bruno achou-o «muito formal» —
# formulário de repartição, e não caderno.
#
# ⚠️ O GIRO PEDE UM SUPORTE SIMPLES, como a foto: todo `Container` zera a
# rotação do filho ao arrumá-lo. E a largura é escrita aqui, porque fora do
# contentor a etiqueta já não recebe a da coluna.
const ETIQUETA_LARGURA := 500
const ETIQUETA_GIRO := -1.2

func etiqueta_da_folha() -> VBoxContainer:
	var centro := CenterContainer.new()
	_vbox.add_child(centro)
	var suporte := Control.new()
	suporte.name = "SuporteDaEtiqueta"
	centro.add_child(suporte)
	var etiqueta := PanelContainer.new()
	etiqueta.name = "Etiqueta"
	etiqueta.theme_type_variation = &"CadernoEtiqueta"
	etiqueta.custom_minimum_size = Vector2(ETIQUETA_LARGURA, 0)
	etiqueta.rotation_degrees = ETIQUETA_GIRO
	suporte.add_child(etiqueta)
	etiqueta.resized.connect(func() -> void:
		etiqueta.pivot_offset = etiqueta.size / 2.0
		suporte.custom_minimum_size = etiqueta.size)
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 8)
	etiqueta.add_child(caixa)
	_vbox = caixa
	return caixa


# O RECIBO COLADO NA FOLHA (`082`, terceira passagem): um comprovante de papel
# impresso, colado um pouco torto, com o carimbo por cima. Guarda-se num
# diário o que se quer lembrar, e o fim de fase guarda o da parcela — é o que
# o título diz, agora com o papel na mão. `linhas` são as impressas, de cima
# para baixo; `valor` é o número em destaque; `carimbo`, a palavra carimbada.
#
# ⚠️ O GIRO PEDE UM SUPORTE SIMPLES, como a foto e a etiqueta: todo `Container`
# zera a rotação do filho ao arrumá-lo. E o carimbo é IRMÃO do recibo no
# suporte, e não filho dele: dentro do recibo, que é um contentor, ele seria
# arrumado como mais uma linha.
const RECIBO_GIRO := 1.4
# Mais largo do que as linhas pedem: o carimbo pousa à direita do valor, e
# num recibo da largura do texto ele cairia em cima do número.
const RECIBO_LARGURA := 300
const CARIMBO_GIRO := -11.0

func recibo_colado(linhas: Array, valor: String, carimbo: String) -> PanelContainer:
	var centro := CenterContainer.new()
	_vbox.add_child(centro)
	var suporte := Control.new()
	suporte.name = "SuporteDoRecibo"
	centro.add_child(suporte)
	var recibo := PanelContainer.new()
	recibo.name = "Recibo"
	recibo.theme_type_variation = &"CadernoRecibo"
	recibo.rotation_degrees = RECIBO_GIRO
	recibo.custom_minimum_size = Vector2(RECIBO_LARGURA, 0)
	suporte.add_child(recibo)
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 4)
	recibo.add_child(caixa)
	for texto in linhas:
		var linha := Label.new()
		linha.theme_type_variation = &"ImpressoCaderno"
		linha.text = String(texto)
		caixa.add_child(linha)
	# O PICOTE do talão, tracejado e SUAVIZADO: o `HSeparator` é uma linha de
	# 1 px sem suavização, e no recibo girado saía em escada. A cor é a da
	# letra impressa, lida do tema ao desenhar.
	var picote := Control.new()
	picote.custom_minimum_size = Vector2(0, 8)
	picote.draw.connect(func() -> void:
		var y := picote.size.y / 2.0
		picote.draw_dashed_line(Vector2(0, y), Vector2(picote.size.x, y),
			picote.get_theme_color("font_color", &"ImpressoCaderno"), 1.2, 5.0, true, true))
	caixa.add_child(picote)
	var numero := Label.new()
	numero.name = "Valor"
	numero.theme_type_variation = &"ValorRecibo"
	numero.text = valor
	caixa.add_child(numero)
	var selo := PanelContainer.new()
	selo.name = "Carimbo"
	selo.theme_type_variation = &"CarimboRecibo"
	selo.rotation_degrees = CARIMBO_GIRO
	var palavra := Label.new()
	palavra.theme_type_variation = &"TextoCarimbo"
	palavra.text = carimbo
	selo.add_child(palavra)
	suporte.add_child(selo)
	# O giro é em volta do MEIO de cada peça, e o carimbo pousa sobre o canto
	# de baixo à direita do recibo, ao lado do valor e não em cima dele — só
	# se sabe onde depois de o tema dar as medidas.
	var arrumar := func() -> void:
		recibo.pivot_offset = recibo.size / 2.0
		selo.pivot_offset = selo.size / 2.0
		suporte.custom_minimum_size = recibo.size
		selo.position = Vector2(recibo.size.x - selo.size.x - 14.0,
			recibo.size.y - selo.size.y - 10.0)
	recibo.resized.connect(arrumar)
	selo.resized.connect(arrumar)
	return recibo


# A FOTO COLADA NA FOLHA, com a borda branca de fotografia de papel, as
# cantoneiras e um giro pequeno — foto colada à mão nunca fica a direito.
func foto_colada(textura: Texture2D, largura: int, altura: int,
		giro_graus: float) -> PanelContainer:
	var centro := CenterContainer.new()
	_vbox.add_child(centro)
	# ⚠️ A FOTO VIVE NUM `Control` SIMPLES, e não direto no contentor: todo
	# `Container` zera a rotação e a escala do filho ao arrumá-lo
	# (`fit_child_in_rect`), e a primeira foto saiu a direito com o giro
	# escrito ao lado. O suporte ocupa o lugar dela na coluna; o giro fica.
	var suporte := Control.new()
	suporte.name = "SuporteDaFoto"
	centro.add_child(suporte)
	var moldura := PanelContainer.new()
	moldura.name = "Foto"
	moldura.theme_type_variation = &"CadernoFoto"
	suporte.add_child(moldura)
	var imagem := TextureRect.new()
	imagem.name = "Imagem"
	imagem.texture = textura
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	imagem.custom_minimum_size = Vector2(largura, altura)
	moldura.add_child(imagem)
	moldura.add_child(FolhaDoCaderno.Cantoneiras.new())
	moldura.rotation_degrees = giro_graus
	# O giro é em volta do MEIO da foto, e o suporte pede o tamanho dela — que
	# só se sabe depois de o tema lhe dar as margens.
	moldura.resized.connect(func() -> void:
		moldura.pivot_offset = moldura.size / 2.0
		suporte.custom_minimum_size = moldura.size)
	return moldura


# ── A FOLHA QUE VIRA (`067`; no andaime desde a `082`) ──
# A folha de rosto da tela de nomes curva sobre a primeira entrada do diário,
# e o fim de fase vira a primeira página da entrada dele para a segunda: a
# MESMA folha, num sítio só. Quem chama empilhou as duas páginas (a de baixo
# primeiro, `pagina_do_caderno()`), e recebe o tween para lhe pôr o que vem
# a seguir.
#
# A virada: curta, para não atrasar quem já quer jogar, e longa o bastante
# para o olho a seguir. Com a largura a cair pelo cosseno, o primeiro terço
# anda devagar — a folha a descolar — e por isso ela é um pouco mais longa
# do que a da primeira passagem (0,45 s, a encolher a direito).
const VIRAR_S := 0.55
# Quanto a folha cresce na vertical a meio da virada: é o que ela se aproxima
# do olho ao levantar-se, e a única pista de profundidade que um `Control`
# plano pode dar.
const VIRAR_ERGUE := 0.035
# A FOLHA QUE CURVA (terceira passagem): quanto dura, o raio do cilindro que
# a enrola e a inclinação da dobra — a mão levanta pelo canto de baixo, que o
# eixo inclinado apanha primeiro.
const CURVAR_S := 0.8
const CURVA_RAIO := 44.0
const CURVA_INCLINACAO := 0.18
const FOLHA_VIRANDO := preload("res://ui/shaders/folha_virando.gdshader")

var _virada_folha: PanelContainer
var _virada_desenho: Control
var _virada_baixo: Control
var _virada_legenda: Control
var _curva: ShaderMaterial


# A FOLHA CURVA quando há imagem da tela para a dobrar; sem ela (o
# renderizador das suítes não desenha nada), gira sobre a lombada como na
# segunda passagem da tela de nomes. A legenda, se houver, vai-se com a folha.
func virar_folha(folha: PanelContainer, desenho: Control, de_baixo: Control,
		legenda: Control = null) -> Tween:
	_virada_folha = folha
	_virada_desenho = desenho
	_virada_baixo = de_baixo
	_virada_legenda = legenda
	var t := create_tween()
	var foto := _fotografar_folha()
	if foto != null:
		_montar_curva(foto)
		t.tween_method(_curvar, 0.0, 1.0, CURVAR_S)
	else:
		folha.pivot_offset = Vector2(0, folha.size.y / 2.0)
		t.tween_method(_virar, 0.0, 1.0, VIRAR_S)
	return t


# A folha que vira como está na tela neste instante — na tela de nomes, com
# os nomes escritos.
# ⚠️ A TELA DO APARELHO NÃO É A DE 720: com `canvas_items` o jogo desenha na
# resolução nativa (`CLAUDE.md`, o viewport é um sistema de coordenadas), e o
# recorte passa pela transformação final da janela — escala e faixas.
func _fotografar_folha() -> Texture2D:
	var tela := get_viewport().get_texture()
	if tela == null:
		return null
	var img := tela.get_image()
	if img == null or img.is_empty():
		return null
	var xf: Transform2D = get_viewport().get_final_transform() \
		* _virada_folha.get_global_transform_with_canvas()
	var canto: Vector2 = xf * Vector2.ZERO
	var fim: Vector2 = xf * _virada_folha.size
	var r := Rect2i(Rect2(canto, fim - canto).abs())
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if r.size.x < 8 or r.size.y < 8:
		return null
	return ImageTexture.create_from_image(img.get_region(r))


# A foto da folha entra no lugar dela — a capa é um contentor, e arruma-a no
# mesmo retângulo das páginas — e a folha de verdade esconde-se.
func _montar_curva(foto: Texture2D) -> void:
	var folha := TextureRect.new()
	folha.name = "FolhaVirando"
	folha.texture = foto
	folha.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	folha.stretch_mode = TextureRect.STRETCH_SCALE
	folha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curva = ShaderMaterial.new()
	_curva.shader = FOLHA_VIRANDO
	_curva.set_shader_parameter("tamanho", _virada_folha.size)
	_curva.set_shader_parameter("raio", CURVA_RAIO)
	_curva.set_shader_parameter("inclinacao", CURVA_INCLINACAO)
	_curva.set_shader_parameter("verso", get_theme_color("verso", &"CadernoPagina"))
	_curva.set_shader_parameter("sombra", get_theme_color("sombra_virada", &"CadernoPagina"))
	folha.material = _curva
	_caderno_capa.add_child(folha)
	_virada_folha.visible = false
	_curvar(0.0)


# UM PASSO DA CURVA, de 0 (a folha deitada) a 1 (enrolada para lá da
# lombada). O eixo do cilindro anda da borda direita até passar a esquerda, e
# o shader faz o resto — ver o cabeçalho de `folha_virando.gdshader`.
func _curvar(t: float) -> void:
	var n := Vector2(1.0, CURVA_INCLINACAO).normalized()
	var longe: float = _virada_folha.size.dot(n)
	var suave := t * t * (3.0 - 2.0 * t)
	_curva.set_shader_parameter("dobra", lerpf(longe + 4.0, -CURVA_RAIO - 140.0, suave))
	if _virada_legenda != null:
		_virada_legenda.modulate.a = 1.0 - t


# UM PASSO DA VIRADA SEM IMAGEM, de 0 (a folha deitada) a 1 (a folha de pé,
# de lado, a sumir na lombada) — a da segunda passagem, que fica para quando
# a tela não se pode fotografar. A primeira passagem só encolhia a folha e escurecia-a por
# igual, e lia-se como um cartão a deslizar («a virada é plana»). Agora:
#   · a LARGURA cai pelo cosseno do ângulo, que é a projeção de uma folha a
#     girar — devagar ao descolar, depressa no fim;
#   · a folha ERGUE-SE um pouco na vertical a meio, a aproximar-se do olho;
#   · a borda livre CURVA-SE: sombra por dentro e um fio de luz no gume;
#   · a página de baixo apanha a SOMBRA da folha junto à borda dela.
func _virar(t: float) -> void:
	var angulo := t * PI / 2.0
	_virada_folha.scale = Vector2(maxf(cos(angulo), 0.001), 1.0 + VIRAR_ERGUE * sin(2.0 * angulo))
	_virada_folha.modulate = Color.WHITE.lerp(Color(0.8, 0.78, 0.74), sin(angulo))
	_virada_desenho.dobra = sin(angulo)
	_virada_desenho.queue_redraw()
	_virada_baixo.sombra_x = _virada_folha.size.x * cos(angulo)
	_virada_baixo.sombra = sin(PI * t)
	_virada_baixo.queue_redraw()
	# A legenda é da folha de rosto e vai-se com ela: o diário que abre a
	# seguir não a tem, e ela sumia de um frame para o outro.
	if _virada_legenda != null:
		_virada_legenda.modulate.a = 1.0 - t


# O botão FORA do caderno, por baixo dele — o gesto de fechar o livro ou de o
# abrir, como o «Guardar o telefone» fica fora do celular (`066`). Dentro da
# página seria um botão do jogo desenhado num diário.
#
# `ao_tocar` vazio fecha o painel; o fim de fase passa-lhe a virada da página.
func botao_abaixo_do_caderno(texto: String, ao_tocar: Callable = Callable()) -> Button:
	var botao := Button.new()
	botao.name = "BotaoCaderno"
	botao.text = texto
	botao.anchor_left = 0.5
	botao.anchor_right = 0.5
	botao.anchor_top = 0.5
	botao.anchor_bottom = 0.5
	botao.offset_left = -170
	botao.offset_right = 170
	var pe := CADERNO_ALTURA / 2.0 + CADERNO_DESCE + CADERNO_BOTAO_VAO
	botao.offset_top = pe
	botao.offset_bottom = pe + TOQUE_MIN + 8
	botao.pressed.connect(ao_tocar if ao_tocar.is_valid() else _fechar)
	add_child(botao)
	return botao


# O que se diz ANTES de abrir o caderno: o título e uma frase, claros sobre o
# escuro, no vão por cima dele. É a voz de quem conta a história, e não a de
# quem escreve no diário — por isso fica fora da folha.
#
# Com `icone`, ele vai ao lado do título, como no cabeçalho dos cartões — o
# troféu do fim de fase, que o cartão tinha e o caderno perdeu na primeira
# passagem (`082`).
func legenda_acima_do_caderno(titulo_: String, texto: String,
		icone: Texture2D = null) -> VBoxContainer:
	var coluna := VBoxContainer.new()
	coluna.name = "Legenda"
	coluna.add_theme_constant_override("separation", 8)
	coluna.anchor_left = 0.5
	coluna.anchor_right = 0.5
	coluna.anchor_top = 0.5
	coluna.anchor_bottom = 0.5
	# Um pouco mais larga do que o caderno: a frase do Seu Maneco cabe numa
	# linha a 680 e partia-se a 640, com «coisas.» sozinha na segunda.
	coluna.offset_left = -CADERNO_LARGURA / 2.0 - 20
	coluna.offset_right = CADERNO_LARGURA / 2.0 + 20
	var topo_do_caderno := -CADERNO_ALTURA / 2.0 + CADERNO_DESCE
	coluna.offset_bottom = topo_do_caderno - 18
	coluna.offset_top = coluna.offset_bottom
	coluna.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(coluna)
	var cabeca := Label.new()
	cabeca.theme_type_variation = &"TituloAbertura"
	cabeca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cabeca.text = titulo_
	if icone == null:
		coluna.add_child(cabeca)
	else:
		var linha := HBoxContainer.new()
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		linha.add_theme_constant_override("separation", 10)
		var img := Icones.imagem(icone, LEGENDA_ICONE)
		img.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		linha.add_child(img)
		linha.add_child(cabeca)
		coluna.add_child(linha)
	# Sem frase, só o título: um rótulo vazio ainda ocupava a altura de uma
	# linha, e o título ficava mais longe do caderno do que devia.
	if texto != "":
		var frase := Label.new()
		frase.theme_type_variation = &"TextoAbertura"
		frase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		frase.text = texto
		coluna.add_child(frase)
	return coluna


# O botão que fecha. Devolvê-lo permite ao painel concreto ligar mais alguma
# coisa ao mesmo clique, sem precisar de um segundo botão.
func botao_fechar(texto: String) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, TOQUE_MIN)
	botao.pressed.connect(_fechar)
	_vbox.add_child(botao)
	return botao


func _fechar() -> void:
	fechou.emit()
	queue_free()
