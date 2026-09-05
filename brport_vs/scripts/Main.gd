extends Control

# ============================================================
# BR Port VS — Main
#
# A tela mora em Main.tscn e o estilo em ui/tema_brport.tres. Este script
# só escuta os signals do GameState e alimenta os nós — não constrói e não
# pinta nada.
#
# Desde o Bloco 4 as docas não são mais uma fileira de cartões: são três
# VAGAS FIXAS no mapa do porto, já posicionadas em Main.tscn sobre os
# píeres. Quantas estão construídas vem de GameState.docks, então "Reconstruir
# o píer" acende a terceira vaga em vez de só somar um cartão.
#
# Cada doca tem duas metades na tela — a vaga no mapa e o cartão na barra
# abaixo dele — e é este script que as mantém apontando para o mesmo índice.
# ============================================================

# O script da doca, para chamar o `arte_do_barco()` dele sem duplicar a tabela
# de cascos. Um segundo dicionário de cascos seria a fonte dupla que este
# projeto já pagou noutros sítios.
const DockScript := preload("res://scripts/Dock.gd")
const WorkerScene := preload("res://scenes/worker/Worker.tscn")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")
const TelaNomesScene := preload("res://scenes/panels/TelaNomes.tscn")
const PainelDiarioScene := preload("res://scenes/panels/PainelDiario.tscn")
const PainelBoletimScene := preload("res://scenes/panels/PainelBoletim.tscn")
const PainelCaixaScene := preload("res://scenes/panels/PainelCaixa.tscn")
const PainelReputacaoScene := preload("res://scenes/panels/PainelReputacao.tscn")
const PainelDocasScene := preload("res://scenes/panels/PainelDocas.tscn")
const PainelCalendarioScene := preload("res://scenes/panels/PainelCalendario.tscn")
const PainelParcelaScene := preload("res://scenes/panels/PainelParcela.tscn")


const COR_BOA := Color(0.102, 0.478, 0.251)
const COR_AVISO := Color(0.851, 0.467, 0.024)
const COR_RUIM := Color(0.761, 0.188, 0.188)
const COR_NEUTRA := Color(0.11, 0.204, 0.329)

@onready var _overlay_layer: CanvasLayer = $Overlay
@onready var _cash_label: Label = $HudBar/CaixaPilula/Linha/Caixa
@onready var _caixa_pilula: PanelContainer = $HudBar/CaixaPilula
@onready var _dia_pilula: PanelContainer = $HudBar/DiaPilula
@onready var _rep_pilula: PanelContainer = $HudBar/RepPilula
@onready var _docas_pilula: PanelContainer = $HudBar/DocasPilula
@onready var _day_label: Label = $HudBar/DiaPilula/Linha/Dia
@onready var _rep_label: Label = $HudBar/RepPilula/Linha/RepTexto
@onready var _docks_label: Label = $HudBar/DocasPilula/Linha/DocasTexto
@onready var _pause_button: Button = $HudBar/Pausar
@onready var _message_label: Label = $MensagemCartao/Mensagem
@onready var _advance_button: Button = $AcoesTurno/Avancar
@onready var _alocar_button: Button = $AcoesTurno/Alocar
@onready var _upgrade_button: Button = $Upgrade
# Uma doca tem DUAS metades na tela: a vaga no mapa (píer, barco, guindaste,
# trabalhador) e o cartão na barra de baixo (texto e alvo de toque). O Main é
# quem sabe que as duas são a mesma doca de índice `i` — nenhuma das duas
# conhece a outra.
@onready var _docks_container: Control = $MapaWrap/Docas
@onready var _dock_cards: HBoxContainer = $BarraDocas

# Trabalhador escolhido por toque, à espera de uma doca. -1 = nenhum.
# Vive aqui e não no GameState porque é estado de interface: quem joga com
# arrasto nunca o usa, e o jogo salvo não deve carregar isto.
var _selecionado: int = -1
@onready var _workers_container: HBoxContainer = $Trabalhadores
@onready var _workers_title: Label = $TrabalhadoresTitulo
@onready var _mapa: TextureRect = $MapaWrap/Mapa

# As estruturas trocam de TEXTURA, não de nó: assim o prop ocupa exatamente o
# mesmo quadro nos dois estados e o prédio não salta ao ser consertado — a
# mesma razão que fez o píer partilhar a geometria entre vazio e construído.
## O que só faz sentido num pátio já reconstruído. Ver `_refresh_estruturas`.
const EQUIPAMENTO_DE_PATIO := ["Empilhadeira", "PilhaCaixotes", "Pallet",
	"Guincho", "ConeTransito", "Barreira"]

const MapaTerra := preload("res://art/porto_mapa_iso.svg")
const MapaPatio := preload("res://art/porto_mapa_iso_patio.svg")
const ArmazemRuina := preload("res://art/props/galpao_velho.png")
const ArmazemPronto := preload("res://art/props/galpao.png")
const EscritorioRuina := preload("res://art/props/escritorio_ruina.png")
const EscritorioPronto := preload("res://art/props/escritorio.png")
@onready var _meta_bar: ProgressBar = $MetaCartao/MetaColuna/MetaBarra
@onready var _meta_label: Label = $MetaCartao/MetaColuna/MetaTexto
@onready var _meta_titulo: Label = $MetaCartao/MetaColuna/MetaTituloLinha/MetaTitulo
@onready var _meta_icone: TextureRect = $MetaCartao/MetaColuna/MetaTituloLinha/Icone
@onready var _meta_cartao: PanelContainer = $MetaCartao


func _ready() -> void:
	# O gravador de partida (item B7) só grava depois disto, e ESTA é a única
	# linha do projeto que o arma. É de propósito que seja o jogo a armá-lo e
	# não ele a armar-se sozinho: o autoload está de pé também durante as 600
	# partidas × 3 perfis do simulador e durante as quatro suítes, que não
	# abrem cena nenhuma — se gravasse por omissão, medir o balanceamento
	# escreveria 1.800 arquivos e o custo de os escrever entraria na medida.
	Registro.armar()

	_advance_button.pressed.connect(_on_advance_pressed)
	_alocar_button.pressed.connect(_on_alocar_pressed)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	_pause_button.pressed.connect(_on_pause_pressed)
	_caixa_pilula.gui_input.connect(_on_caixa_pilula_input)
	_dia_pilula.gui_input.connect(_on_dia_pilula_input)
	_rep_pilula.gui_input.connect(_on_rep_pilula_input)
	_docas_pilula.gui_input.connect(_on_docas_pilula_input)
	_meta_cartao.gui_input.connect(_on_meta_cartao_input)

	_connect_game_state()
	_refresh_all()
	_animar_ancorados()
	_animar_coqueiros()
	_animar_boias()
	_animar_luzes()
	_animar_caminhao()
	_animar_espuma()

	# Turno 1 abria com a faixa de mensagem VAZIA — um cartão creme com nada
	# dentro, que na tela lê como falha e não como "ainda não aconteceu nada".
	# A mensagem inicial não pode vir do GameState: `new_game()` roda no
	# autoload, antes de esta cena existir para escutar o sinal.
	if _message_label.text == "":
		_on_message("O porto é seu. Um píer de pé e o resto por levantar.", "")

	# A ABERTURA VEM ANTES DE TUDO. Partida nova pergunta os dois nomes, e a
	# escolha é irrevogável (GDD 7). É overlay e não fase do jogo de propósito:
	# uma fase nova faria o simulador de balanceamento girar até o limite de
	# segurança sem que nada reprovasse — ver o cabeçalho de TelaNomes.gd.
	if GameState.precisa_dos_nomes():
		# A abertura é uma CORRENTE, não duas chamadas: o diário só pode abrir
		# depois de os nomes estarem gravados, porque a primeira página usa o
		# nome do cais. Encadear pelo sinal `fechou` mantém cada painel sem
		# saber quem vem a seguir — quem sabe a ordem é este lugar, e só ele.
		var nomes: PainelNarrativo = _abrir_painel(TelaNomesScene)
		nomes.fechou.connect(func() -> void:
			var diario: PainelNarrativo = _abrir_painel(PainelDiarioScene)
			# ⚠️ E A RECUPERAÇÃO DE FASE VEM DEPOIS DO DIÁRIO, não é dispensada
			# por ele. Antes, este ramo acabava num `return` e o bloco de
			# recuperação lá em baixo nunca corria numa PARTIDA NOVA — que é
			# justamente quando ele mais faz falta:
			#
			#   1. `GameState._ready()` chama `new_game()`, que chama
			#      `_spawn_boats()`, que tem 30% de abrir contra-oferta;
			#   2. o `rival_offer_triggered` é emitido no autoload, ANTES de
			#      esta cena existir para o escutar — ninguém o ouve;
			#   3. `_ready()` via `precisa_dos_nomes()` e saía;
			#   4. o jogador batizava o cais, lia o diário, voltava ao mapa —
			#      e a fase continuava `rival_offer` sem painel nenhum aberto.
			#
			# `advance_turn()` retorna CALADO fora de "playing", então o botão
			# "Avançar dia" não fazia nada e a partida ficava presa no dia 1
			# com um barco no píer. Sem erro, sem aviso. Trinta por cento das
			# instalações novas, e foi o que o primeiro playtest no telefone
			# encontrou (Análise 1, 02/09).
			diario.fechou.connect(_recuperar_fase)
		)
		return

	_recuperar_fase()


# Se o jogo abre com uma fase que BLOQUEIA o turno, o painel que a resolve tem
# de estar na tela — venha ela de um save carregado ou do sorteio do
# `new_game()`. Vive numa função própria porque é chamada de dois sítios: aqui,
# quando não há abertura, e no fim da corrente da abertura.
func _recuperar_fase() -> void:
	if GameState.phase == "rival_offer" and GameState.pending_rival_dock >= 0:
		_on_rival_offer_triggered(GameState.pending_rival_dock)
	elif GameState.phase == "debt_payment":
		_on_debt_due(GameState.PARCELA_AMOUNT)
	elif GameState.phase == "game_over":
		_on_game_over(GameState.won, GameState.end_reason)


# A classe mais alta que o porto de hoje consegue receber — é a que fica
# ancorada à espera de vaga. Percorre a tabela em vez de a listar à mão, pela
# mesma razão que o painel Construir o faz: classe nova tem de aparecer sozinha.
func _classe_ancorada() -> String:
	var melhor := "pesqueiro"
	var nivel := -1
	for id in GameState.classes_disponiveis():
		var n: int = int(GameState.CLASSES_DE_NAVIO[id]["nivel"])
		if n > nivel:
			nivel = n
			melhor = String(id)
	return melhor


# Os barcos da Zona de Espera são cenário: não têm lógica, mas parados fazem o
# porto parecer uma fotografia. Vivem dentro do Cenario, e não soltos no
# MapaWrap, porque a ordem lá dentro é a profundidade isométrica — metade do
# mapa ordenada e metade não é o mesmo que não estar ordenada. Fases diferentes para não balançarem em bloco,
# que é o que denuncia a animação como truque.
func _animar_ancorados() -> void:
	var fases := [0.0, 0.85]
	var i := 0
	for nome in ["BarcoEspera1", "BarcoEspera2"]:
		var barco := $MapaWrap/Cenario.get_node_or_null(nome) as TextureRect
		if barco == null:
			continue
		# ⚠️ O CASCO ANCORADO SEGUE A TRAVA DO PORTO. A cena traz um cargueiro
		# assado, e desde a trava de 06/09 isso passou a contradizer a
		# mecânica: o porto em ruínas não recebe cargueiro, e a Zona de Espera
		# mostrava dois ancorados desde o primeiro dia. É a mesma regra que já
		# vale para o píer e para o galpão — o que troca de estado numa partida
		# não pode estar assado no fundo.
		barco.texture = DockScript.arte_do_barco(_classe_ancorada())
		var base := barco.position
		var tw := barco.create_tween().set_loops()
		if fases[i] > 0.0:
			tw.tween_interval(fases[i])
		tw.tween_property(barco, "position:y", base.y - 4.0, 2.1) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(barco, "position:y", base.y, 2.1) \
			.set_trans(Tween.TRANS_SINE)
		i += 1


# A copa gira no TOPO DO TRONCO, não no centro do quadro: o pivot_offset da
# cena está em (256, 178), que é onde as duas peças se encontram. Girar pelo
# centro faria a copa descrever um arco e descolar do tronco.
#
# Cada uma com sua duração e sua fase — coqueiros em sincronia denunciam que é
# a mesma animação repetida.
# ⚠️ RAJADA, E NÃO PÊNDULO — pedido do primeiro playtest ("pode deixar
# animações mais fluidas"). A versão anterior era +A → −A → +A com a mesma
# duração nos dois sentidos: um metrônomo, e é isso que o olho lia. Vento não
# tem período fixo.
#
# O ciclo aqui é o de uma rajada de verdade: a copa é EMPURRADA depressa
# (EASE_OUT, que gasta a velocidade no fim do movimento, como quem bate numa
# parede de ar), volta devagar passando do ponto para o outro lado, oscila uma
# vez menor — a copa a assentar — e PARA. A pausa é o que faz a rajada
# seguinte parecer uma rajada nova em vez da mesma volta do relógio.
func _animar_coqueiros() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	# Cada coqueiro com o seu tempo E a sua força: três iguais em sincronia
	# denunciam que é a mesma animação repetida (era já a razão das fases).
	var duracoes := [2.6, 3.1, 2.9]
	var fases := [0.0, 1.1, 0.5]
	var pausas := [1.3, 0.7, 1.9]
	var i := 0
	for no in cenario.get_children():
		if not String(no.name).ends_with("Copa"):
			continue
		var amplitude := 0.038 if i % 2 == 0 else -0.038
		var dur: float = duracoes[i % duracoes.size()]
		var tw := no.create_tween().set_loops()
		if fases[i % fases.size()] > 0.0:
			tw.tween_interval(fases[i % fases.size()])
		# A rajada bate: rápida a ir, com a velocidade a morrer no fim.
		tw.tween_property(no, "rotation", amplitude, dur * 0.35) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# E solta devagar, passando do ponto para o outro lado.
		tw.tween_property(no, "rotation", -amplitude * 0.55, dur * 0.8) \
			.set_trans(Tween.TRANS_SINE)
		# A copa assenta — uma oscilação pequena, não uma segunda rajada.
		tw.tween_property(no, "rotation", amplitude * 0.22, dur * 0.5) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(no, "rotation", 0.0, dur * 0.45) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_interval(pausas[i % pausas.size()])
		i += 1


# ── FASE 7 do prompt do pacote de arte, no idioma do projeto ──
#
# O prompt pede ciclos de 6 ou 8 frames em folha de sprites. Aqui não se faz
# assim, e a auditoria do próprio pacote diz por quê: "reutilizar e ampliar os
# padrões de tween existentes antes de criar uma segunda arquitetura
# concorrente". Uma folha de frames para uma boia que sobe e desce 3px seria
# oito PNGs de 512 para fazer o que uma linha de Tween faz — e ainda obrigaria
# a manter célula, origem e margem iguais em todos eles, que é justamente a
# lista de coisas que o prompt avisa que costuma sair errada.
#
# `wind_idle` já existia, em `_animar_coqueiros`. Faltavam estas duas.


## `bob` — a boia sobe e desce, e a marca da Zona de Espera fica quieta.
##
## A marca é uma estaca cravada no fundo: se ela balançasse com a boia, o mar
## inteiro pareceria subir. Por isso o filtro é pela TEXTURA e não pelo nome do
## nó — `Ancoragem0` é o marcador e `Ancoragem1/2` são boias, e um dia alguém
## vai acrescentar `Ancoragem3` sem olhar qual é qual.
func _animar_boias() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	var duracoes := [1.7, 2.05]
	var fases := [0.0, 0.6]
	var i := 0
	for no in cenario.get_children():
		var tr := no as TextureRect
		if tr == null or tr.texture == null:
			continue
		if not String(tr.texture.resource_path).ends_with("boia.png"):
			continue
		var base := tr.position
		var tw := tr.create_tween().set_loops()
		if fases[i % fases.size()] > 0.0:
			tw.tween_interval(fases[i % fases.size()])
		var dur: float = duracoes[i % duracoes.size()]
		tw.tween_property(tr, "position:y", base.y - 3.0, dur) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(tr, "position:y", base.y, dur) \
			.set_trans(Tween.TRANS_SINE)
		i += 1


## O CAMINHÃO ENTRA NO PÁTIO — pedido do primeiro playtest ("até fazer o
## caminhão andar pela estrada").
##
## ⚠️ ELE NÃO ANDA AO LONGO DA ESTRADA, e é medido: a cabine do prop aponta
## para **+mx** (está escrito no `blender/brp_porto.py` — "+mx é o lado do mar;
## o caminhão aponta para lá"), e a estrada corre no eixo **my**. Um caminhão
## a percorrer a estrada com este sprite seria um caminhão a deslizar DE LADO,
## que é justamente o defeito que o CLAUDE.md avisa não se consertar rodando
## no Godot — ângulo errado se conserta no gerador, não aqui. Andar pela
## estrada precisa do prop rerenderizado virado para o eixo dela (Blender).
##
## O que ele faz é a única marcha honesta com o desenho que existe: avança na
## direção em que aponta, entrando da rua para o pátio — que é exactamente o
## caso que o docstring do próprio prop antecipa ("carga chegando, fila no
## portão").
##
## O LIMITE DA MARCHA SAI DO CONTRATO DE PROFUNDIDADE, não de um número
## escrito aqui. Ordem de irmão É profundidade neste plano, e `mx+my` cresce
## com o Y de tela — então o caminhão pode avançar até o Y do irmão seguinte,
## e nem um pixel além. Um número cravado envelheceria calado no dia em que
## alguém movesse o coqueiro ao lado; assim, a animação respeita o D3 por
## construção.
## O CAMINHÃO ATRAVESSA O MAPA INTEIRO — pedido do playtest, terceira volta:
## "ele deveria vir de fora do mapa, e depois sair do mapa".
##
## As duas primeiras tentativas erraram por escrito aqui, e as duas por
## acreditar numa coisa que não se tinha medido: que a rua fosse feita de
## trechos soltos. NÃO É. O `vias()` do `gerar_mapa_iso.py` desenha um
## COTOVELO em cada degrau, com a mesma largura da rua, ligando um trecho ao
## seguinte — a estrada é uma escada CONTÍNUA, do topo do quadro até fora dele
## pela esquerda. Dava para atravessá-la desde sempre.
##
## A rota tem 42 unidades (~1.400px) e sai da geometria do mapa, não do gosto:
## dentro de cada degrau a rua corre em `my` no eixo `borda - RUA_RECUO +
## RUA_LARG/2`, e o cotovelo corre em `mx` a meia largura do fim do degrau.
## O bloco D13 do teste de design confere ponto a ponto contra as faixas que o
## gerador publica — se a estrada mudar, ele reprova antes de alguém olhar.
##
## ⚠️ E A CADA COTOVELO ELE VIRA, o que exige DUAS silhuetas. Só as faces `+x`
## e `-y` são visíveis por esta câmera, então um caminhão virado não se obtém
## rodando o sprite: `caminhao.png` corre em `my` e `caminhao_mx.png` em `mx`,
## os dois saídos do mesmo construtor em `blender/brp_porto.py`. Trocar a
## textura na curva é o que faz a volta ler como volta.
##
## A INTENÇÃO REGISTADA, para quem vier depois: isto é a base para mostrar a
## chegada de uma entrega a um navio, quando existir o serviço de compra.
# ⚠️ ESTA É A ESCALA DE TELA, e desde 05/09 ela já não é a que o gerador do
# mapa usa para desenhar: ele desenha a 30 num quadro maior e o `viewBox` do
# SVG encolhe o quadro (ver o bloco do enquadramento em `gerar_mapa_iso.py`).
# Aqui manda o PNG, porque é em pixel de PNG que o caminhão anda. O D13
# confere estes dois contra as âncoras, que publicam a efetiva.
const MEIA_LARG := 20.0
const MEIA_ALT := 10.0

## Onde a CENA põe o caminhão: um ponto já dentro do quadro, e é de propósito.
## A primeira passagem começa aqui para que as cinco capturas do CI o apanhem
## na estrada — prop que a captura não vê é prop que ninguém revê. Só depois
## dela é que o ciclo passa a começar fora do mapa, como foi pedido.
##
## ⚠️ E "dentro do quadro" não chega: tem de ser dentro do quadro E À VISTA.
## O primeiro ponto escolhido foi o alto do degrau 0, que passava no D13 e
## saía na foto com metade do caminhão debaixo da placa do ESCRITÓRIO — as
## placas eram interface, desenhavam-se por cima de tudo, e nenhuma asserção
## sobre o mapa sabia onde elas caíam. (Elas saíram em 05/09; a lição não, e é
## por isso que continua aqui: prop que se põe para ser VISTO confere-se na
## foto.) Este ponto é o meio do degrau 1, o trecho mais desimpedido da
## estrada; o D13 tranca que ele está na rota e inteiro dentro do `MapaWrap`.
const CAMINHAO_ORIGEM := Vector2(3.75, 9.5)

## A escada da rua, em (mx, my). Primeiro e último ponto estão FORA do quadro —
## 76 unidades ao todo, ~1.700px de tela — e as pontas são as do MUNDO, não
## números escolhidos: o primeiro e o último degrau da costa acabam onde o
## caminhão já está 58px acima do topo e 63px à esquerda da margem.
##
## O `mx` de cada trecho reto é o MEIO do asfalto daquele degrau
## (`borda - RUA_RECUO + RUA_LARG/2`), e o `my` de cada cotovelo é o meio da
## faixa que o `vias()` desenha para virar (`my1 - RUA_LARG/2`). Nenhum destes
## números é de gosto, e o D13 confere-os todos contra as âncoras.
##
## ⚠️ ELA CRESCEU EM 05/09, e por duas razões que se somam: a costa ganhou um
## degrau em cada ponta (a rua acompanha-a inteira) e a câmera afastou-se, de
## modo que o pedaço de estrada que cabe no quadro é maior. Os dois pontos das
## pontas eram `-2,0` e `29,5`, escolhidos para caírem fora do quadro ANTIGO —
## e o D13 reprovou-os assim que o quadro cresceu, que é exatamente o que ele
## existe para fazer. Os de agora saem da mesma pergunta, resolvida contra o
## desenho do caminhão e não contra o quadro de 512 dele.
const ROTA_ESTRADA: Array[Vector2] = [
	Vector2(-4.25, -14.0),   # entra por cima do topo do quadro
	Vector2(-4.25, -6.55),
	Vector2(-0.25, -6.55),   # cotovelo do degrau 0 para o 1
	Vector2(-0.25, 7.45),
	Vector2(3.75, 7.45),     # cotovelo do 1 para o 2
	Vector2(3.75, 15.45),
	Vector2(7.75, 15.45),    # cotovelo do 2 para o 3
	Vector2(7.75, 23.45),
	Vector2(11.75, 23.45),   # cotovelo do 3 para o 4
	Vector2(11.75, 33.45),
	Vector2(15.75, 33.45),   # cotovelo do 4 para o 5
	Vector2(15.75, 42.0),    # sai pela esquerda do quadro
]

## Velocidade constante em pixels por segundo. É ela que dá a duração de cada
## trecho, e não um número por trecho: com durações iguais o caminhão
## disparava nos cotovelos curtos e arrastava-se nos degraus longos.
##
## 25,3px/s dá ~69s de travessia e ~2,5s para ele andar o próprio comprimento
## (63px de silhueta) — devagar de propósito: isto é fundo de cena, não é o
## que se olha. Depressa, um prop que atravessa o quadro inteiro puxa o olho
## para longe das docas.
##
## ⚠️ ELE ENCOLHEU COM A CÂMERA em 05/09, e tinha de encolher: velocidade em
## PIXEL, com o mundo a ser desenhado 1,5x menor, é o caminhão a andar 1,5x
## mais depressa NO MUNDO por uma mudança que foi só de enquadramento. Os 38
## davam 26s de travessia onde antes davam 38. A travessia passou de 38s para
## 69s na mesma mudança, e isso é o mundo a ser maior: o que se manteve — que é
## o que a linha acima escolhe — é o caminhão a andar o próprio comprimento em
## 2,5s, que é a régua com que o olho lê velocidade.
const CAMINHAO_VELOCIDADE := 38.0 * 2.0 / 3.0

const CaminhaoMy := preload("res://art/props/caminhao.png")
const CaminhaoMx := preload("res://art/props/caminhao_mx.png")


## A silhueta que um trecho pede: a de `mx` se ele anda em `mx`, a de `my` se
## anda em `my`. É PÚBLICA e vive num lugar só porque o D13 lhe pergunta —
## recalcular a mesma escolha do lado do teste seria o teste a concordar
## consigo próprio, e foi assim que a primeira versão dele deixou passar um
## caminhão que usava a mesma silhueta nos oito trechos.
func silhueta_do_trecho(de: Vector2, para: Vector2) -> Texture2D:
	return CaminhaoMx if abs(para.x - de.x) > 0.01 else CaminhaoMy


## O deslocamento de tela de um ponto da rota, medido a partir de onde a cena
## põe o caminhão. Só precisa das duas constantes da projeção — `CX`, `CY` e a
## altura do cais cancelam-se na diferença.
func tela_da_rota(ponto: Vector2) -> Vector2:
	var d := ponto - CAMINHAO_ORIGEM
	return Vector2((d.x - d.y) * MEIA_LARG, (d.x + d.y) * MEIA_ALT)


func _animar_caminhao() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	var caminhao := cenario.get_node_or_null("Caminhao") as TextureRect
	if caminhao == null:
		return
	var base := caminhao.position - tela_da_rota(CAMINHAO_ORIGEM)

	# Primeira passagem: começa onde a cena o pôs (dentro do quadro) e sai.
	var primeira := caminhao.create_tween()
	_trechos_da_rota(primeira, caminhao, base, CAMINHAO_ORIGEM)
	primeira.tween_callback(func() -> void:
		# E daqui em diante o ciclo completo, de fora do mapa a fora do mapa.
		var ciclo := caminhao.create_tween().set_loops()
		ciclo.tween_interval(5.0)
		_trechos_da_rota(ciclo, caminhao, base, ROTA_ESTRADA[0])
	)


## Enfia na `tw` um trecho por par de pontos da rota, a partir de `desde`.
func _trechos_da_rota(tw: Tween, caminhao: TextureRect, base: Vector2,
		desde: Vector2) -> void:
	var pontos: Array[Vector2] = [desde]
	for ponto in ROTA_ESTRADA:
		# Só os pontos que ainda estão À FRENTE de onde se começa. Comparar por
		# `my` chega: a rota nunca recua nele.
		if ponto.y > desde.y or (is_equal_approx(ponto.y, desde.y) and ponto.x > desde.x):
			pontos.append(ponto)

	# O primeiro salto é um TELEPORTE, não um trecho: é ele que põe o caminhão
	# no princípio da rota antes de a percorrer.
	tw.tween_callback(func() -> void:
		caminhao.position = base + tela_da_rota(pontos[0])
		caminhao.texture = CaminhaoMy
		_ordenar_por_profundidade(caminhao)
	)
	for i in range(pontos.size() - 1):
		var de: Vector2 = pontos[i]
		var para: Vector2 = pontos[i + 1]
		var origem := base + tela_da_rota(de)
		var destino := base + tela_da_rota(para)
		# A silhueta certa para o eixo do trecho — é isto que faz a curva ler
		# como curva em vez de o caminhão deslizar de lado.
		var textura := silhueta_do_trecho(de, para)
		tw.tween_callback(func() -> void: caminhao.texture = textura)
		tw.tween_method(func(t: float) -> void:
			caminhao.position = origem.lerp(destino, t)
			_ordenar_por_profundidade(caminhao)
		, 0.0, 1.0, origem.distance_to(destino) / CAMINHAO_VELOCIDADE)


## Põe `no` no índice que a profundidade dele pede, entre os irmãos.
##
## Profundidade é `mx+my`, e ela cresce com o Y de tela — então contar quantos
## irmãos estão ACIMA na tela dá o índice, sem precisar da projeção aqui. É a
## mesma leitura que o bloco D3 do teste de design faz para reprovar ordem
## errada; aqui ela mantém a ordem certa enquanto o prop se mexe.
func _ordenar_por_profundidade(no: Control) -> void:
	var pai := no.get_parent()
	var indice := 0
	for outro in pai.get_children():
		if outro == no:
			continue
		if outro is Control and (outro as Control).position.y < no.position.y:
			indice += 1
	if pai.get_child(indice) != no:
		pai.move_child(no, indice)


## A ARREBENTAÇÃO — a terceira das três animações que o playtest pediu
## ("animações mais fluidas, e novas animações, para o coqueiro, ondas e até
## fazer o caminhão andar"). As outras duas eram tween e saíram no mesmo dia;
## esta não era, e a razão está medida: até 03/09 a espuma estava ASSADA no SVG
## do mapa, que é UMA textura. Não havia nó de onda para animar, e animar o
## mapa faria a costa deslizar. Hoje o `gerar_mapa_iso.py` escreve a espuma em
## dois arquivos próprios, e são eles que se lavam.
##
## ⚠️ A LAVAGEM É EM CONTRAFASE, e é isso que a faz parecer mar. Uma camada só
## a pulsar põe a costa INTEIRA a clarear e a escurecer ao mesmo tempo — que é
## o irmão do defeito que o gerador já documenta (traço de espessura constante
## lê como pintura de solo, não como espuma). Com duas sementes diferentes em
## oposição, o que se vê é espuma a nascer num sítio enquanto se desfaz noutro.
##
## ⚠️ E O TEMPO É ASSIMÉTRICO, como na rajada do coqueiro. Onda ENTRA depressa
## e RECUA devagar; com a mesma duração nos dois sentidos volta a ser pêndulo,
## e pêndulo é o que o olho identifica como animação de programador.
const ESPUMA_ENTRA := 1.6
const ESPUMA_RECUA := 3.4

## Quanto a espuma avança sobre a terra no auge da lavagem. O sentido é o da
## NORMAL DA COSTA: `+mx` move (+MEIA_LARG, +MEIA_ALT) por unidade na tela, e
## 0,133 unidades disso é o suficiente para se ler sem descolar a espuma da
## beira que ela desenha. Era `Vector2(4, 2)` cravado, que valia essas 0,133
## unidades à escala antiga e valeria 0,2 à nova — a espuma a subir metade de
## um passo a mais na areia por uma mudança de câmera.
const ESPUMA_AVANCO := Vector2(MEIA_LARG, MEIA_ALT) * 0.1333


func _animar_espuma() -> void:
	for i in 2:
		var camada := $MapaWrap.get_node_or_null("Espuma%d" % i) as TextureRect
		if camada == null:
			continue
		var base := camada.position
		# A segunda começa já lavada, para as duas nunca estarem no mesmo
		# ponto do ciclo. Sem isto elas subiriam e desceriam juntas e a
		# contrafase não existiria — duas camadas a fazer o trabalho de uma.
		var alta := i == 1
		camada.modulate.a = 1.0 if alta else 0.45
		camada.position = base + (ESPUMA_AVANCO if alta else Vector2.ZERO)
		var tw := camada.create_tween().set_loops().set_parallel(false)
		for passo in 2:
			var sobe := (passo == 0) != alta
			var dur := ESPUMA_ENTRA if sobe else ESPUMA_RECUA
			var trans := Tween.TRANS_CUBIC if sobe else Tween.TRANS_SINE
			tw.set_parallel(true)
			tw.tween_property(camada, "modulate:a", 1.0 if sobe else 0.45, dur) \
				.set_trans(trans).set_ease(Tween.EASE_OUT)
			tw.tween_property(camada, "position",
				base + (ESPUMA_AVANCO if sobe else Vector2.ZERO), dur) \
				.set_trans(trans).set_ease(Tween.EASE_OUT)
			tw.set_parallel(false)


## `light_flicker` — a luminária do poste, e só ela.
##
## É esta a razão de `poste` e `poste_luz` serem dois PNGs: uma lâmpada que
## pisca arrastando o ferro do poste atrás dela não lê como lâmpada, lê como
## falha de render. Mesma divisão da copa do coqueiro e da lança do guindaste.
##
## A oscilação é pequena de propósito: 1.0 -> 0.82, e lenta. Uma lâmpada de
## sódio velha BATE, não pisca. Amplitude maior aqui viraria pisca-pisca, e a
## luminária tem 26px na tela — o que a esta escala se lê é a variação, não o
## desenho dela.
func _animar_luzes() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	for no in cenario.get_children():
		if not String(no.name).begins_with("PosteLuz"):
			continue
		var tr := no as TextureRect
		if tr == null:
			continue
		var tw := tr.create_tween().set_loops()
		tw.tween_property(tr, "modulate:a", 0.82, 1.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(tr, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_interval(2.2)


func _connect_game_state() -> void:
	GameState.cash_changed.connect(func(_v): _refresh_hud())
	GameState.reputation_changed.connect(func(_v): _refresh_hud())
	GameState.phase_changed.connect(func(_p): _refresh_hud())
	GameState.turn_advanced.connect(func(_t, _w): _refresh_all())
	GameState.boats_spawned.connect(func(): _refresh_docks())
	GameState.roster_changed.connect(_refresh_all)
	GameState.message.connect(_on_message)
	GameState.rival_offer_triggered.connect(_on_rival_offer_triggered)
	GameState.debt_due.connect(_on_debt_due)
	GameState.game_over.connect(_on_game_over)
	GameState.semana_fechada.connect(_on_semana_fechada)

	# AS FALAS DA DONA CIDA penduram-se em sinais que já existiam. Nenhuma
	# delas abre painel: são a faixa de mensagem que o jogo já tem, com voz.
	# Uma tela por evento seria um clique a cada coisa que acontece — e o
	# plano é explícito em que tela nova não pode mudar o ritmo do turno.
	GameState.estrutura_comprada.connect(func(_id): _cida("upgrade_pronto"))
	GameState.rival_offer_triggered.connect(func(_d): _cida("arlindo_indireto"))
	GameState.reputation_changed.connect(_cida_reputacao)
	GameState.cash_changed.connect(_cida_caixa)
	GameState.turn_advanced.connect(_cida_semana)


func _refresh_all() -> void:
	_refresh_estruturas()
	_refresh_hud()
	_refresh_docks()
	_refresh_workers()


# O mapa e os prédios contam o que o jogador construiu. É o retorno visível do
# dinheiro gasto — sem isto, comprar uma estrutura é só um número que baixa.
func _refresh_estruturas() -> void:
	_mapa.texture = MapaPatio if GameState.tem_estrutura("patio") else MapaTerra
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return

	# O equipamento de pátio só aparece quando o pátio existe.
	#
	# Sem isto, uma empilhadeira, um pallet e um guincho ficam em cima da terra
	# batida de um porto que o jogador ainda não reconstruiu — e, pior, roubam
	# metade do efeito da compra: o pátio é a estrutura cuja mudança visual é
	# justamente terra virar asfalto COM movimento em cima. Comprar tem de
	# mudar mais do que o chão.
	#
	# O caminhão, o poste e a beira do cais ficam de fora desta lista de
	# propósito: rua, iluminação pública e cais não são do pátio, e o porto
	# opera uma doca desde o primeiro dia.
	var tem_patio := GameState.tem_estrutura("patio")
	for nome in EQUIPAMENTO_DE_PATIO:
		var eq := cenario.get_node_or_null(nome) as CanvasItem
		if eq != null:
			eq.visible = tem_patio
	var armazem := cenario.get_node_or_null("Armazem") as TextureRect
	if armazem != null:
		armazem.texture = ArmazemPronto if GameState.tem_estrutura("armazem") else ArmazemRuina
	var escritorio := cenario.get_node_or_null("Escritorio") as TextureRect
	if escritorio != null:
		escritorio.texture = EscritorioPronto if GameState.tem_estrutura("escritorio") \
			else EscritorioRuina


func _refresh_hud() -> void:
	_cash_label.text = GameState.moeda(int(GameState.cash))
	var shown_day: int = min(GameState.turn, GameState.TURNS_TOTAL)
	_day_label.text = "Dia %d/%d" % [shown_day, GameState.TURNS_TOTAL]
	_rep_label.text = "%d %s" % [int(GameState.reputation), GameState.reputation_label()]
	_docks_label.text = "%d/%d" % [GameState.docks.size(), GameState.BERCOS_NO_MAPA]
	# O botão não some quando tudo está construído: vira o registo de que o
	# porto está completo, que é uma informação, não um beco sem saída.
	var faltam := 0
	for id in GameState.ESTRUTURAS:
		if not GameState.tem_estrutura(String(id)):
			faltam += 1
	_upgrade_button.disabled = GameState.phase != "playing" or faltam == 0
	if faltam == 0:
		_upgrade_button.text = "Porto completo"
		Icones.no_botao(_upgrade_button, Icones.FEITO, 26)
	else:
		var plural := "disponível" if faltam == 1 else "disponíveis"
		_upgrade_button.text = "Construir  ·  %d %s" % [faltam, plural]
		Icones.no_botao(_upgrade_button, Icones.AMPLIAR_PIER, 26)
	_advance_button.disabled = GameState.phase != "playing"
	_refresh_meta()


# O playtest perdeu uma partida por R$1 sem nunca ver o quanto faltava. Esta é
# a informação que estava faltando na tela: quanto já tem, quanto falta e
# quantos dias restam até o Sr. Ribeiro bater na porta.
func _refresh_meta() -> void:
	var alvo := GameState.PARCELA_AMOUNT
	if GameState.parcela_paid:
		# Pago: o banco dá lugar ao visto verde, que é o estado, não o credor.
		_meta_icone.texture = Icones.FEITO
		_meta_titulo.text = "Parcela do Sr. Ribeiro"
		_meta_bar.value = 100.0
		_meta_label.text = "Paga — porto salvo"
		return

	_meta_icone.texture = Icones.PARCELA
	var dias_restantes: int = max(GameState.PARCELA_DUE_TURN - GameState.turn + 1, 0)
	_meta_titulo.text = "Parcela do Sr. Ribeiro — %d dia(s) restante(s)" % dias_restantes
	_meta_bar.value = clamp(100.0 * float(GameState.cash) / float(alvo), 0.0, 100.0)
	var falta: int = alvo - int(GameState.cash)
	var progresso := "%s de %s" % [GameState.moeda(int(GameState.cash)), GameState.moeda(alvo)]
	if falta > 0:
		_meta_label.text = "%s — faltam %s" % [progresso, GameState.moeda(falta)]
		_meta_label.remove_theme_color_override("font_color")
	else:
		# CARTÃO TOCÁVEL QUE NÃO SE ANUNCIA É CARTÃO QUE NINGUÉM TOCA. O convite
		# só aparece quando há o que fazer com ele — antes disso, tocar abriria
		# um painel que só sabe dizer quanto falta, e a linha aqui já diz isso.
		_meta_label.text = "%s — toque para quitar agora" % progresso
		_meta_label.add_theme_color_override("font_color", COR_AVISO)


# As vagas já existem na cena, uma por píer desenhado no mapa. Aqui só se diz
# a cada uma qual índice ela representa — quem não tem doca correspondente se
# desenha como vaga por construir.
func _refresh_docks() -> void:
	var vagas := _docks_container.get_children()
	for i in range(vagas.size()):
		vagas[i].trabalhador_selecionado = _selecionado
		vagas[i].setup(i)
	var cartoes := _dock_cards.get_children()
	for i in range(cartoes.size()):
		cartoes[i].trabalhador_selecionado = _selecionado
		cartoes[i].setup(i)
	# MEXER NAS DOCAS OBRIGA A REPINTAR OS TRABALHADORES, porque "parado" é uma
	# pergunta sobre as docas e não sobre o operário (ver `TrabParado` no tema).
	# Sem isto o cartão só mudava quando o roster mudava — e barco novo a chegar
	# não mexe no roster, que é exatamente o momento em que o aviso faz falta.
	_repintar_trabalhadores()


# Repinta o que depende de "há trabalho parado?", sem reconstruir cartão nenhum:
# os cartões existentes, a linha de título e o botão de alocar em lote. É a
# versão barata do `_refresh_workers()`, e o botão vive aqui — e não no
# `_refresh_hud()`, onde vivia — para que os três sinais do mesmo estado sejam
# atualizados pela mesma chamada e não possam discordar.
func _repintar_trabalhadores() -> void:
	for no in _workers_container.get_children():
		no.refresh()
	_alocar_button.disabled = not GameState.has_pending_assignment()
	_refresh_titulo_trabalhadores()


func _clear(container: Node) -> void:
	# queue_free() sozinho é adiado até o fim do frame — sem o remove_child o
	# container fica com os nós velhos e os novos ao mesmo tempo por um frame.
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _refresh_workers() -> void:
	# Um trabalhador que deixou de estar livre não pode continuar selecionado —
	# senão o próximo toque numa doca tentaria alocar quem já está ocupado.
	if _selecionado >= 0 and not _pode_ser_selecionado(_selecionado):
		_selecionado = -1

	_clear(_workers_container)
	for w in GameState.workers:
		var worker_node = WorkerScene.instantiate()
		_workers_container.add_child(worker_node)
		worker_node.setup(int(w["id"]))
		worker_node.selecionado.connect(_on_worker_selecionado)
		worker_node.marcar_selecionado(int(w["id"]) == _selecionado)
	_repintar_trabalhadores()


func _pode_ser_selecionado(worker_id: int) -> bool:
	if GameState.phase != "playing":
		return false
	if GameState.worker_dock_index(worker_id) >= 0:
		return false
	for w in GameState.workers:
		if int(w["id"]) == worker_id:
			return int(w["busy_turns"]) == 0
	return false


# Tocar no mesmo trabalhador de novo desmarca — sem isso não haveria como
# desistir da seleção a não ser alocando.
func _on_worker_selecionado(worker_id: int) -> void:
	_selecionado = -1 if _selecionado == worker_id else worker_id
	for no in _workers_container.get_children():
		no.marcar_selecionado(no.worker_id == _selecionado)
	# As duas metades da doca precisam saber quem está escolhido: o cartão para
	# aceitar o toque, a vaga no mapa para acender o realce sobre o píer.
	_refresh_docks()


# O cartão do trabalhador tem 158px e não comporta a instrução; ela vive aqui,
# onde também pode mudar conforme o estado.
#
# São TRÊS estados e não dois. O do meio nasceu do primeiro playtest: o dia
# avançou com dois operários livres e duas docas sem trabalhador, e esta linha
# dizia a instrução genérica de sempre, em cinzento-azulado. Ela é a única
# linha de texto que fica logo acima dos cartões — se algum lugar tem de
# contar quanto trabalho está parado, é este.
#
# O âmbar aqui MEDE (5,53:1 sobre a barra escura, passa o AA); no cartão do
# trabalhador não mediria, e por isso lá o sinal é o fundo. Ver o comentário
# do `trab_parado` no tema.
func _refresh_titulo_trabalhadores() -> void:
	var parado := GameState.trabalho_parado()
	if _selecionado >= 0:
		_workers_title.text = "Agora toque numa doca para enviar o #%d" % _selecionado
		_workers_title.add_theme_color_override("font_color", COR_AVISO)
	elif parado != Vector2i.ZERO:
		_workers_title.text = "%s parado%s — %s esperando" % [
			_plural(parado.x, "trabalhador", "trabalhadores"),
			"" if parado.x == 1 else "s",
			_plural(parado.y, "doca", "docas")]
		_workers_title.add_theme_color_override("font_color", COR_AVISO)
	else:
		_workers_title.text = "Trabalhadores — toque ou arraste para uma doca"
		_workers_title.add_theme_color_override("font_color", Color(0.51, 0.6, 0.706))


# "1 doca" / "2 docas". Existe porque o número vem de uma contagem e escrever
# "1 docas" numa faixa de alerta desfaz o alerta.
func _plural(n: int, singular: String, plural: String) -> String:
	return "%d %s" % [n, singular if n == 1 else plural]


func _on_alocar_pressed() -> void:
	_selecionado = -1
	GameState.assign_all_free_workers()


func _on_message(text: String, kind: String) -> void:
	_message_label.text = text
	match kind:
		"good":
			_message_label.add_theme_color_override("font_color", COR_BOA)
		"warn":
			_message_label.add_theme_color_override("font_color", COR_AVISO)
		"bad":
			_message_label.add_theme_color_override("font_color", COR_RUIM)
		_:
			_message_label.add_theme_color_override("font_color", COR_NEUTRA)


# Uma linha da Dona Cida na faixa de mensagem. Ela NÃO tapa a mensagem do
# sistema: quem chama isto chama-o depois do evento, e a mensagem do GameState
# (que diz o que aconteceu em números) já passou. A fala dela é a leitura
# humana por cima, não a substituição.
func _cida(id: String) -> void:
	var linha := Narrativa.cida(id)
	if linha != "":
		_on_message(linha, "")


# A REPUTAÇÃO SÓ FALA QUANDO CRUZA UMA FAIXA, não a cada ponto. Ela mexe-se em
# quase todo turno (±0,8 por barco), e uma fala por movimento seria a Dona Cida
# a comentar ruído. A faixa qualitativa já existe em `reputation_label()` e é a
# unidade em que o jogador pensa — "respeitado" virou "admirado" é notícia,
# 71,2 virar 72,0 não é.
var _faixa_reputacao := ""
var _reputacao_vista := 0.0


func _cida_reputacao(valor: float) -> void:
	var faixa: String = GameState.reputation_label()
	# A primeira chamada só regista onde a barra estava: sem um valor anterior
	# não há direção nenhuma para anunciar.
	if _faixa_reputacao == "":
		_faixa_reputacao = faixa
		_reputacao_vista = valor
		return
	if faixa != _faixa_reputacao:
		# A DIREÇÃO SAI DO VALOR GUARDADO, não da barra corrente. A primeira
		# versão comparava a reputação com ela própria, o que dá sempre falso —
		# a Dona Cida teria dito "caiu" mesmo quando subia, e nada reprovaria.
		_cida("reputacao_subiu" if valor > _reputacao_vista else "reputacao_caiu")
		_faixa_reputacao = faixa
	_reputacao_vista = valor


# O aviso de caixa curto dispara UMA VEZ por travessia, não a cada centavo
# abaixo da linha. Sem a memória do estado anterior ele repetir-se-ia em todo
# turno enquanto o jogador estivesse apertado — que é justamente quando ele
# menos precisa de ser lembrado.
var _caixa_estava_curto := false


func _cida_caixa(valor: int) -> void:
	var curto: bool = valor < GameState.PARCELA_AMOUNT / 2
	if curto and not _caixa_estava_curto:
		_cida("caixa_baixo")
	_caixa_estava_curto = curto


var _semana_vista := 0


func _cida_semana(_turno: int, semana: int) -> void:
	if semana == _semana_vista:
		return
	# A semana 1 não é "semana nova": é a primeira, e o jogador acabou de ler o
	# diário. A fala é sobre voltar ao trabalho, não sobre começar.
	if _semana_vista > 0:
		_cida("semana_nova")
	_semana_vista = semana


func _on_semana_fechada(resumo: Dictionary) -> void:
	# O boletim é a única tela que abre sozinha durante o jogo. Abre no fecho
	# da semana, que já é um momento de pausa — o turno acabou de virar e não
	# há decisão pendente. Abrir a meio de um turno seria interromper.
	_abrir_painel(PainelBoletimScene).setup(resumo)


func _on_advance_pressed() -> void:
	GameState.advance_turn()


# O BOTÃO VOLTAR DO ANDROID. Só existe no telefone, e é por isso que ninguém
# tinha reparado: por omissão o Godot FECHA A APLICAÇÃO nele, de modo que um
# toque em Voltar com o boletim aberto matava o jogo em vez de fechar o painel.
# O `quit_on_go_back=false` no project.godot desliga o padrão; quem decide o
# que ele faz é isto.
#
# A REGRA É A FASE DO GAMESTATE, e não uma lista de painéis. Fora de
# `"playing"` o jogo está à espera de uma resposta — a oferta do Arlindo, a
# parcela do Sr. Ribeiro, o fim de jogo —, e fechar esse painel deixaria a
# fase de pé sem nada na tela para a resolver: um travamento silencioso, que é
# exatamente o defeito que a decisão de as telas serem overlay existe para
# evitar. Em `"playing"` todo painel é dispensável, com uma exceção que o
# próprio painel declara (`fecha_com_voltar`).
func _notification(qual: int) -> void:
	if qual != NOTIFICATION_WM_GO_BACK_REQUEST:
		return
	if GameState.phase != "playing":
		return

	var filhos := _overlay_layer.get_children()
	if filhos.is_empty():
		# Nada aberto: Voltar abre a pausa. É onde estão sair e recomeçar, que
		# é o que a pessoa queria ao carregar em Voltar — só que sem levar a
		# aplicação abaixo pelo caminho.
		_on_pause_pressed()
		return

	# O de cima é o último filho: é o que está desenhado por cima, e é o único
	# que o toque alcança.
	var topo: Node = filhos[-1]
	if topo is PainelNarrativo and not (topo as PainelNarrativo).fecha_com_voltar:
		return
	# Pelo `_fechar()` do próprio painel quando ele tem um, e não por
	# `queue_free()`: é o `_fechar()` que grava o que houver para gravar e que
	# emite `fechou`, do qual depende a corrente de abertura do jogo.
	if topo.has_method("_fechar"):
		topo.call("_fechar")
	else:
		topo.queue_free()


# Os painéis pendurados no CanvasLayer NÃO herdam o tema: tema só se propaga
# por uma árvore de Control, e CanvasLayer não é Control. Sem repassar na mão,
# todo painel sai com o visual padrão do Godot em cima do jogo temático.
func _abrir_painel(cena: PackedScene) -> Control:
	var painel: Control = cena.instantiate()
	painel.theme = theme
	_overlay_layer.add_child(painel)
	return painel


func _on_upgrade_pressed() -> void:
	_abrir_painel(UpgradePanelScene)


# AS QUATRO PÍLULAS DO HUD SÃO TOCÁVEIS — item do primeiro playtest (02/09):
# "tocar num item do HUD abre detalhe". As quatro reagem à mesma pergunta —
# toque que SOLTA, botão esquerdo, a mesma razão do `Worker.gd` (reagir no
# release deixa o clique livre para quem quisesse arrastar) — e só o painel
# que abrem muda. Extrair a pergunta evita QUATRO cópias da mesma regra: é
# exatamente o tipo de duplicação que já escondeu um defeito neste projeto
# (ver `trabalho_parado()` no CLAUDE.md, a guarda de fase repetida).
func _e_toque_de_soltar(event: InputEvent) -> bool:
	return event is InputEventMouseButton and not event.pressed \
		and event.button_index == MOUSE_BUTTON_LEFT


func _on_caixa_pilula_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event):
		_abrir_painel(PainelCaixaScene).setup(GameState.resumo_do_dia())
		accept_event()


# O chip "Dia" abre o CALENDÁRIO, não um resumo do próprio chip — os dois
# itens do playtest ("tocar no dia" e "calendário com eventos sinalizados")
# são a mesma pergunta, e abrir dois painéis para ela seria pedir ao jogador
# para comparar um com o outro.
func _on_dia_pilula_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event):
		_abrir_painel(PainelCalendarioScene).setup()
		accept_event()


func _on_rep_pilula_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event):
		_abrir_painel(PainelReputacaoScene).setup()
		accept_event()


func _on_docas_pilula_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event):
		_abrir_painel(PainelDocasScene).setup()
		accept_event()


# O CARTÃO DA PARCELA TAMBÉM É TOCÁVEL, e é por ali que se paga adiantado —
# item do playtest que a triagem tinha perdido. O botão não vive no cartão
# porque o rodapé não tem os 44px de toque para lhe dar; ver o cabeçalho de
# `PainelParcela.gd`.
func _on_meta_cartao_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event):
		_abrir_painel(PainelParcelaScene).setup()
		accept_event()


func _on_pause_pressed() -> void:
	_abrir_painel(PauseMenuScene)


func _on_rival_offer_triggered(dock_index: int) -> void:
	_refresh_docks()
	_abrir_painel(CounterOfferScene).setup(dock_index)


func _on_debt_due(amount: int) -> void:
	_abrir_painel(DebtPaymentScene).setup(amount)


func _on_game_over(did_win: bool, reason: String) -> void:
	_abrir_painel(EndGameScene).setup(did_win, reason)
