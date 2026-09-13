extends PainelNarrativo

# ============================================================
# BR Port VS — o MENU, que é um celular
#
# Item 17 do segundo playtest, na letra do Bruno: *"Crie no HUD inferior uma
# botão de menu, onde nesse menu estarão os atalhos do mapa da cidade e loja,
# por exemplo. Inclusive esse menu pode ser um celular e os aplicativos seriam
# essas outras partes do jogo."*
#
# ESTA TELA É A CASCA, e só ela. O mapa da cidade, as lojas e as missões são
# os itens 18 a 21, que o próprio plano classifica como "um segundo jogo" e
# que assentam numa pergunta ainda sem resposta — a economia das fases
# seguintes, na `BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. Construí-los aqui seria
# escolher essa economia de passagem.
#
# ⚠️ E ELA É UM OVERLAY, NUNCA UMA FASE DO `GameState`. Uma fase a mais fez 24
# de 30 partidas não terminarem, com o CI verde — o `advance_turn()` retorna
# calado fora de "playing" e o laço do simulador só sabe resolver duas fases.
# Como overlay, o balanceamento medido fica intocado POR CONSTRUÇÃO e não por
# cuidado de quem escreveu isto.
#
# ── POR QUE CELULAR, E NÃO MAIS UM CARTÃO BRANCO ──
#
# A metáfora era sugestão e não ordem, e a conta que a aprovou é esta: a
# moldura do aparelho SUBSTITUI a margem do cartão em vez de se somar a ela.
# Medido — o cartão padrão tem 12 px de margem de cada lado e 2 de borda, o
# que num painel de 400 deixa 372 de conteúdo; o corpo do celular gasta 10 de
# margem e 2 de borda, e a tela mais 12, o que deixa 352. **São 20 px de 372,
# 5,4%**, e em troca o menu ganha um registo visual próprio — que é
# exactamente a divisão que os itens 18 a 21 fazem: o porto de um lado, a
# cidade do outro.
#
# ── O QUE ENTRA AQUI, E O QUE NÃO ENTRA ──
#
# Só o que NÃO TEM PORTA. As quatro pílulas do HUD já abrem caixa, calendário,
# reputação e docas; o cartão da parcela abre a parcela; o botão Construir
# abre as estruturas. Repetir qualquer uma delas aqui seria o defeito que este
# projeto já registou a propósito do chip do dia — "abrir dois painéis para a
# mesma pergunta é pedir ao jogador para comparar um com o outro".
#
# O que sobrou dessa peneira foi UMA coisa: o **diário do avô**, que abre uma
# vez na abertura do jogo, encadeado à tela de nomes, e nunca mais. É texto
# escrito, com a origem do caixa inicial lá dentro (`docs/decisoes/018`), que
# o jogador não podia reler.
#
# ── E O MENU DE PAUSA NÃO É ABSORVIDO ──
#
# Ele carrega volume, "Copiar registro da partida" e "Novo jogo (apaga
# progresso)" — coisas de SISTEMA, que existem fora da ficção. Este celular é
# um objeto DO MUNDO: o telefone de quem toma conta do porto. Misturar os dois
# poria um botão destrutivo ao lado de uma loja, e o botão Pausar já está no
# canto onde a convenção do gênero o põe.
# ============================================================

## Pedido para abrir um app. É SINAL e não uma chamada ao `Main`, pela mesma
## razão do `ver_balanco` do menu de pausa: este painel vive no
## `_overlay_layer` e não conhece quem o abriu — alcançar o pai pelo caminho
## seria um `get_parent().get_parent()` que quebra calado no dia em que a
## árvore mudar.
##
## ⚠️ E ELE LEVA A CENA, NÃO O ID. Com um id, o Main precisaria da sua própria
## tabela de "qual id abre o quê" — e duas listas que nada obriga a concordar
## são a fonte dupla que já custou caro neste projeto. A tabela abaixo é a
## única que sabe o que cada app abre.
signal abrir_app(cena: String)

const LARGURA := 400

# ⚠️ A ALTURA É FIXA, E É A ÚNICA COISA QUE FAZ ISTO LER COMO UM TELEFONE.
#
# O andaime deste projeto manda `montar(largura, 0)` — ajustar ao conteúdo —
# porque altura fixa já deixou faixa branca debaixo do botão em três painéis.
# Aqui é ao contrário, e mede-se: com altura ao conteúdo o aparelho saía
# 400 x 390, quase quadrado, e na primeira captura lia-se como mais um cartão
# de cantos redondos. Um telefone é ALTO — a proporção é o que o olho
# reconhece antes do ícone —, e 400 x 680 dá 1:1,7.
#
# E o vazio que sobra na tela não é a tal faixa branca: aquela era cartão sem
# conteúdo, esta é a tela de um telefone com lugar para mais apps, que é
# exatamente o que os itens 18 a 21 vão pôr lá. Cabe nos 1280 do retrato com
# 300 px de folga.
const ALTURA := 680

# O tile de um app. 72 está acima do alvo de toque mínimo (44) com folga, e é
# o tamanho em que o ícone de 40 px ainda respira dentro do quadrado.
const TILE := 72
const ICONE_APP := 40
const COLUNAS := 3
const SEPARACAO := 14

# ⚠️ A TABELA DOS APPS, E O CADEADO É UM SÓ DE PROPÓSITO.
#
# Desenhar quatro ícones para quatro coisas que ainda não existem seria
# escolher a gramática visual delas antes de as construir — e a gramática de
# uma loja depende do que se compra nela, que é a pergunta que os itens 19 e
# 20 ainda não responderam. Um app que ainda não está instalado mostra um
# quadrado genérico; quem o distingue é o NOME por baixo, que está sempre lá.
# Quando uma porta abrir, ela traz o ícone dela, e a folha de contato já tem
# lugar para mais dez.
#
# `cena` vazia quer dizer porta fechada — e é o campo que decide, não uma
# segunda lista de ids que pudesse discordar desta.
const APPS := [
	{"id": "diario", "nome": "Diário", "icone": Icones.DIARIO, "cena": "res://scenes/panels/PainelDiario.tscn"},
	{"id": "cidade", "nome": "Cidade", "icone": Icones.BLOQUEADO, "cena": ""},
	{"id": "lojas", "nome": "Lojas", "icone": Icones.BLOQUEADO, "cena": ""},
	{"id": "missoes", "nome": "Missões", "icone": Icones.BLOQUEADO, "cena": ""},
	{"id": "analise", "nome": "Análise", "icone": Icones.BLOQUEADO, "cena": ""},
]

# ⚠️ A LINHA QUE FAZ DE UMA PORTA FECHADA UMA PORTA, e não um botão morto.
#
# Ela é UMA para todos os apagados em vez de uma por tile, e isso é escolha de
# espaço medida: a coluna tem 108 px e "Abre na Fase 2" pede duas linhas de
# texto dentro dela, o que triplicaria a altura da grelha para repetir quatro
# vezes a mesma frase. Aqui embaixo ela é dita uma vez, no sítio onde o olho
# vai depois de percorrer os quadrados.
const RODAPE_FECHADOS := "Os quadrados apagados abrem na Fase 2, quando a cidade abrir."


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO, "Celular")

	# SEM `titulo()`, e não por esquecimento: o título do andaime é um `Label`
	# com a cor padrão do tema, que é navy porque todos os outros painéis são
	# cartões brancos. Sobre a tela do celular ele seria navy sobre navy. Quem
	# faz o papel de título aqui é a barra de status, que além de nomear a tela
	# diz uma coisa verdadeira.
	var tela := PanelContainer.new()
	tela.theme_type_variation = "CelularTela"
	# A TELA ESTICA E O CONTEÚDO DELA NÃO. Sem o `EXPAND_FILL` a tela encolhe
	# ao tamanho dos apps e o resto do aparelho fica com a cor do CORPO, o que
	# desenha uma moldura preta larguíssima em vez de um telefone; sem o
	# `ALIGNMENT_BEGIN` na coluna, os cinco apps flutuam no meio do visor em
	# vez de começarem no topo, que é onde um telefone os põe.
	tela.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbox.add_child(tela)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 14)
	coluna.alignment = BoxContainer.ALIGNMENT_BEGIN
	tela.add_child(coluna)

	coluna.add_child(_barra_de_status())

	var grade := GridContainer.new()
	grade.columns = COLUNAS
	grade.add_theme_constant_override("h_separation", SEPARACAO)
	grade.add_theme_constant_override("v_separation", SEPARACAO)
	coluna.add_child(grade)
	for app in APPS:
		grade.add_child(_app(app))

	# O VÃO QUE EMPURRA A NOTA PARA O FUNDO DO VISOR. Com ela colada aos apps,
	# os 300 px de tela que sobram ficavam todos num bloco por baixo e a
	# composição lia como página por acabar; com as duas pontas ancoradas —
	# apps em cima, nota em baixo — o vazio fica no MEIO, que é como um
	# telefone com poucos apps se parece de verdade.
	var vao := Control.new()
	vao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(vao)

	var rodape := Label.new()
	rodape.theme_type_variation = "TextoCelularFraco"
	rodape.autowrap_mode = TextServer.AUTOWRAP_WORD
	rodape.text = RODAPE_FECHADOS
	coluna.add_child(rodape)

	botao_fechar("Guardar o telefone")


# A barra de status do aparelho, e ela mostra o que um relógio mostraria: onde
# se está. O número sai do `GameState` e não é escrito aqui — é a mesma regra
# do `_refresh_hud`, que também escreve "Dia N/M" a partir das constantes.
func _barra_de_status() -> Control:
	var linha := HBoxContainer.new()

	var esquerda := Label.new()
	esquerda.theme_type_variation = "TextoCelularFraco"
	var dia: int = mini(GameState.turn, GameState.TURNS_TOTAL)
	esquerda.text = "Dia %d/%d" % [dia, GameState.TURNS_TOTAL]
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(esquerda)

	var direita := Label.new()
	direita.theme_type_variation = "TextoCelularFraco"
	direita.text = "Semana %d" % GameState.week_of(maxi(dia, 1))
	direita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	linha.add_child(direita)
	return linha


# Um app: o quadrado por cima, o nome por baixo.
#
# O quadrado ABERTO é um `Button` e o FECHADO é um `PanelContainer`, e a
# diferença não é decorativa. Um botão que não responde ao toque ensina o
# jogador a não tocar no menu — e este menu vai encher-se de portas nos itens
# seguintes. Um quadrado que nunca foi botão não promete nada, e o rodapé diz
# o que falta para ele acender.
func _app(app: Dictionary) -> Control:
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 6)
	caixa.alignment = BoxContainer.ALIGNMENT_BEGIN

	var aberto: bool = String(app["cena"]) != ""
	var icone: Texture2D = app["icone"]

	if aberto:
		var botao := Button.new()
		botao.name = "Tile_%s" % String(app["id"])
		botao.theme_type_variation = "AppAberto"
		botao.custom_minimum_size = Vector2(TILE, TILE)
		botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		botao.tooltip_text = String(app["nome"])
		Icones.no_botao(botao, icone, ICONE_APP)
		var cena: String = String(app["cena"])
		botao.pressed.connect(func() -> void:
			abrir_app.emit(cena)
			queue_free())
		caixa.add_child(botao)
	else:
		var quadro := PanelContainer.new()
		quadro.name = "Tile_%s" % String(app["id"])
		quadro.theme_type_variation = "AppFechado"
		quadro.custom_minimum_size = Vector2(TILE, TILE)
		quadro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var img := Icones.imagem(icone, ICONE_APP)
		img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		quadro.add_child(img)
		caixa.add_child(quadro)

	var nome := Label.new()
	nome.name = "Nome_%s" % String(app["id"])
	nome.theme_type_variation = "TextoCelular" if aberto else "TextoCelularFraco"
	nome.text = String(app["nome"])
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(nome)
	return caixa
