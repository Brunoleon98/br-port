class_name Icones
extends RefCounted

# ============================================================
# BR Port VS — registro dos ícones da interface
#
# Um único lugar onde a UI diz qual arquivo é qual ícone. Antes disto cada
# rótulo carregava um emoji embutido no texto, e trocar um ícone era caçar
# string por string em sete scripts e numa cena.
#
# Os ícones são vetor CHAPADO, não isométrico. Ícone de HUD é interface: tem
# de se ler a 19px sobre a barra escura, e o bloco de estilo isométrico
# devolve borrão nesse tamanho. Isto vale mesmo depois de o mapa migrar para
# isométrico — a decisão de arte é sobre o cenário, não sobre a UI.
#
# COR E FUNDO. Cada ícone foi colorido para o fundo onde ele realmente cai,
# porque a paleta não tem uma cor que sirva aos dois:
#   - pílula da HUD e chip da doca são ESCURAS (navy ~#17293d)
#   - cartões e painéis são BRANCOS
#   - botões são navy cheio, e o botão desabilitado é azul-claro
# Quem for reaproveitar um ícone noutro fundo confira antes: `doca` é traço
# creme (só sobrevive em fundo escuro) e `parcela` é navy cheio (só sobrevive
# em fundo claro). O resto foi feito em âmbar, vermelho ou com disco de
# fundo próprio, e aguenta os dois.
# ============================================================

const CAIXA := preload("res://art/icones/caixa.svg")
const DIA := preload("res://art/icones/dia.svg")
const REPUTACAO := preload("res://art/icones/reputacao.svg")
const DOCA := preload("res://art/icones/doca.svg")
const TRABALHADOR := preload("res://art/icones/trabalhador.svg")
const BARCO := preload("res://art/icones/barco.svg")
const PARCELA := preload("res://art/icones/parcela.svg")
const AMPLIAR_PIER := preload("res://art/icones/ampliar_pier.svg")

const PAUSAR := preload("res://art/icones/pausar.svg")
const AVANCAR := preload("res://art/icones/avancar.svg")
const FEITO := preload("res://art/icones/feito.svg")
const MENU := preload("res://art/icones/menu.svg")
# A engrenagem da tela Ajustes (`066`), no desenho do `pausar`: disco navy e
# figura clara, porque as duas moram no mesmo sítio — o selo do cabeçalho.
const AJUSTES := preload("res://art/icones/ajustes.svg")

# O DIÁRIO e o CADEADO são do menu, e o cadeado é UM para todas as portas
# fechadas de propósito. Quando uma delas abrir, ela ganha o ícone dela — o
# genérico é o que um celular mostra por um app que ainda não está instalado,
# e desenhar quatro ícones para quatro coisas que ainda não existem seria
# escolher a gramática delas antes de as construir.
const DIARIO := preload("res://art/icones/diario.svg")
const BLOQUEADO := preload("res://art/icones/bloqueado.svg")

# ⚠️ E DESDE 26/09 CADA APP TEM A SUA COR E O SEU DESENHO, e o cadeado ficou
# só como selo em cima dos fechados — escolha do Bruno na família do sistema,
# que reabre a regra acima de propósito (`docs/decisoes/066`). São quadrados
# de cor cheia com o desenho branco, como os ícones de um telefone, e são
# desenhados a 144 px: no celular ocupam o tile inteiro (72 de coordenada,
# 108 num telefone de 1080), e os ícones de 48 ficariam borrados.
const APP_DIARIO := preload("res://art/icones/app_diario.svg")
const APP_CIDADE := preload("res://art/icones/app_cidade.svg")
const APP_LOJAS := preload("res://art/icones/app_lojas.svg")
const APP_MISSOES := preload("res://art/icones/app_missoes.svg")
const APP_ANALISE := preload("res://art/icones/app_analise.svg")
# A conversa do porto (`067`): o mesmo painel que o toque na faixa abre.
const APP_MENSAGENS := preload("res://art/icones/app_mensagens.svg")
# A barra de status do celular. Desenho, e não medida: o Godot 4 não lê a
# bateria nem o sinal do aparelho (sondado em 26/09 — nem o `OS` nem o
# `DisplayServer` têm `get_power_*`). A hora, essa, é a do aparelho.
const CELULAR_SINAL := preload("res://art/icones/celular_sinal.svg")
const CELULAR_BATERIA := preload("res://art/icones/celular_bateria.svg")

const RIVAL := preload("res://art/icones/rival.svg")
const ACORDO := preload("res://art/icones/acordo.svg")
const CORTAR := preload("res://art/icones/cortar.svg")
const FIRMEZA := preload("res://art/icones/firmeza.svg")
const CLIENTE_CALMO := preload("res://art/icones/cliente_calmo.svg")
const CLIENTE_IMPACIENTE := preload("res://art/icones/cliente_impaciente.svg")

const VITORIA := preload("res://art/icones/vitoria.svg")
const DERROTA := preload("res://art/icones/derrota.svg")
const RECOMECAR := preload("res://art/icones/recomecar.svg")

# Tamanhos de uso. O SVG é rasterizado a 48px e mostrado menor: reduzir uma
# imagem grande fica nítido, ampliar uma pequena não.
const TAM_TEXTO := 19
const TAM_TITULO := 22
const TAM_CHIP := 17


# Um TextureRect pronto para sentar ao lado de um Label, já no tamanho certo.
static func imagem(icone: Texture2D, tamanho: int = TAM_TEXTO) -> TextureRect:
	var img := TextureRect.new()
	img.name = "Icone"
	img.texture = icone
	img.custom_minimum_size = Vector2(tamanho, tamanho)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Sem isto o ícone come o clique do painel que está atrás dele.
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	img.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return img


# Linha "ícone + texto" para os painéis, que são construídos por código.
# Devolve a linha; o ícone e o texto ficam acessíveis por `get_node("Icone")` e
# `get_node("Texto")` para quem precisar trocá-los depois — é o caso da cara do
# cliente, que muda de calmo para impaciente no meio da negociação.
static func rotulo(icone: Texture2D, texto: String, tamanho: int = TAM_TITULO,
		centralizado: bool = false) -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 7)
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if centralizado:
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_child(imagem(icone, tamanho))

	var label := Label.new()
	label.name = "Texto"
	label.text = texto
	if centralizado:
		# Um label que preenche a linha ignora o alignment do container: para
		# centralizar o par ícone+texto ele precisa encolher até o próprio texto.
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label)
	return linha


# Põe um ícone num Button. O texto do SVG é rasterizado a 48px e o botão o
# mostraria nesse tamanho, estourando a altura da linha — `icon_max_width` é o
# que segura isso.
static func no_botao(botao: Button, icone: Texture2D, tamanho: int = TAM_TITULO) -> void:
	botao.icon = icone
	botao.add_theme_constant_override("icon_max_width", tamanho)
