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
	_animar_caminhoes()
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


## O n-ésimo motivo que esta classe pode trazer, em roda. Percorre a tabela em
## vez de a listar à mão: motivo novo numa classe entra aqui sozinho, e uma
## classe cujos motivos mudem não deixa este lugar a pedir um casco que não há.
func _motivo_da_classe(classe: String, n: int) -> String:
	var motivos: Array = GameState.CLASSES_DE_NAVIO[classe]["motivos"].keys()
	return String(motivos[n % motivos.size()])


# Os barcos da Zona de Espera são cenário: não têm lógica, mas parados fazem o
# porto parecer uma fotografia. Vivem dentro do Cenario, e não soltos no
# MapaWrap, porque a ordem lá dentro é a profundidade isométrica — metade do
# mapa ordenada e metade não é o mesmo que não estar ordenada. Fases diferentes para não balançarem em bloco,
# que é o que denuncia a animação como truque.
func _animar_ancorados() -> void:
	var fases := [0.0, 0.85]
	var classe_ancorada := _classe_ancorada()
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
		# ⚠️ E O CASCO PEDE UM MOTIVO desde 07/09, porque é o motivo que
		# desenha o convés. O de cada ancorado sai da tabela da classe, pelo
		# ÍNDICE: dois barcos parados lado a lado com o mesmo convés seriam a
		# mesma foto duas vezes, e escolher ao acaso gastaria sorteios do jogo
		# numa decisão que é só de cenário (a regra do `Registro` que nasce
		# desarmado, aplicada à semente).
		barco.texture = DockScript.arte_do_barco(
			classe_ancorada, _motivo_da_classe(classe_ancorada, i))
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

## ONDE A CENA PÕE OS TRÊS CAMIÕES — pontos já dentro do quadro, e é de
## propósito. A primeira passagem começa aqui para que as capturas do CI
## os apanhem na estrada: prop que a captura não vê é prop que ninguém revê. Só
## depois dela é que cada ciclo passa a começar fora do mapa, como foi pedido.
##
## ⚠️ E "dentro do quadro" não chega: tem de ser dentro do quadro E À VISTA.
## O primeiro ponto escolhido foi o alto do degrau 0, que passava no D13 e
## saía na foto com metade do caminhão debaixo da placa do ESCRITÓRIO — as
## placas eram interface, desenhavam-se por cima de tudo, e nenhuma asserção
## sobre o mapa sabia onde elas caíam. (Elas saíram em 05/09; a lição não, e é
## por isso que continua aqui: prop que se põe para ser VISTO confere-se na
## foto.) O D13 tranca que os três estão na rota e inteiros dentro do
## `MapaWrap`, e o D15 que nenhum deles pousa numa das duas pontas de praia.
##
## ⚠️ SÃO TRÊS, E OS TRÊS COMEÇAM EM TRECHOS RETOS. Num cotovelo o caminhão
## anda em `mx` e precisa da outra silhueta: parado ali, ele sairia na captura
## atravessado. A escolha é limitada pelos dois lados — abaixo de `my` 1,2 e
## acima de 22,5 estão as praias, onde o porto acabou e equipamento nenhum
## pousa (D15) —, e os três repartem o que sobra da estrada visível.
const CAMINHAO_ORIGENS: Array[Vector2] = [
	Vector2(0.55, 1.60),
	Vector2(4.55, 9.50),
	Vector2(8.55, 21.00),
]

## A escada da rua, em (mx, my). Primeiro e último ponto estão FORA do quadro —
## 76 unidades ao todo, ~1.700px de tela — e as pontas são as do MUNDO, não
## números escolhidos: o primeiro e o último degrau da costa acabam onde o
## caminhão já está 58px acima do topo e 63px à esquerda da margem.
##
## ⚠️ O `mx` DE CADA TRECHO RETO DEIXOU DE SER O MEIO DA RUA em 07/09, quando
## ela ganhou duas faixas. Andar no meio de uma rua de mão dupla é andar EM CIMA
## DA LINHA, e a linha é justamente o que a faz ler como de mão dupla. Ele é
## agora o meio da faixa DE FORA (`borda - RUA_RECUO + RUA_LARG * 0.75`) — o
## camião segue sempre em `+my`, e quem segue nesse sentido tem a água à
## direita. Sai daí que virar para a doca é virar à DIREITA, e que a entrada de
## cada acesso, que o mapa publica, cai nesta faixa.
##
## O `my` de cada cotovelo é, pela mesma razão, a meia faixa do lado de dentro
## da curva (`my1 - RUA_LARG/4`): a virar em `+mx` a direita é `+my`. Nenhum
## destes números é de gosto, e o D13 confere-os todos contra as âncoras.
##
## ⚠️ ELA CRESCEU EM 05/09, e por duas razões que se somam: a costa ganhou um
## degrau em cada ponta (a rua acompanha-a inteira) e a câmera afastou-se, de
## modo que o pedaço de estrada que cabe no quadro é maior. Os dois pontos das
## pontas eram `-2,0` e `29,5`, escolhidos para caírem fora do quadro ANTIGO —
## e o D13 reprovou-os assim que o quadro cresceu, que é exatamente o que ele
## existe para fazer. Os de agora saem da mesma pergunta, resolvida contra o
## desenho do caminhão e não contra o quadro de 512 dele.
const ROTA_ESTRADA: Array[Vector2] = [
	Vector2(-3.45, -14.00),   # entra por cima do topo do quadro
	Vector2(-3.45, -6.45),
	Vector2(0.55, -6.45),     # cotovelo do degrau 0 para o 1
	Vector2(0.55, 7.55),
	Vector2(4.55, 7.55),      # cotovelo do 1 para o 2
	Vector2(4.55, 15.55),
	Vector2(8.55, 15.55),     # cotovelo do 2 para o 3
	Vector2(8.55, 23.55),
	Vector2(12.55, 23.55),    # cotovelo do 3 para o 4
	Vector2(12.55, 33.55),
	Vector2(16.55, 33.55),    # cotovelo do 4 para o 5
	Vector2(16.55, 42.00),    # sai pela esquerda do quadro
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

## A pausa entre uma travessia e a seguinte, DENTRO do ciclo de cada caminhão.
##
## ⚠️ ELA É A MESMA PARA OS TRÊS, e tem de ser. O período do ciclo é
## `intervalo + travessia`, e só com períodos iguais a distância entre os três
## fica constante para sempre; um intervalo por caminhão fá-los-ia deslizar uns
## para cima dos outros ao fim de algumas voltas. Quem os separa é a ESPERA de
## arranque, que se calcula uma vez e nunca mais.
const CAMINHAO_INTERVALO := 5.0

## OS QUATRO CAMIÕES, UM POR MOTIVO DE ESCALA.
##
## Até 06/09 era um caminhão só, e as duas texturas dele eram o mesmo veículo
## em dois eixos. A estrada mostrava a mesma caçamba laranja fosse o porto a
## receber pescado ou contêiner — e desde `docs/decisoes/008` o jogo SABE a
## diferença. Agora o que passa é o que se está a servir: quem escolhe é
## `_motivo_da_estrada()`, pela doca do mesmo índice.
##
## ⚠️ A CHAVE É O ID DO MOTIVO, e é isso que faz esta tabela ser percorrível.
## O bloco D13 do teste de design varre `GameState.MOTIVOS` e exige casco de
## camião para cada um — um motivo novo sem camião reprova ali, do mesmo modo
## que o D17 exige casco de navio para cada par (classe, motivo). Foi a falta
## dessa pergunta que deixou o `barco_medio` gerado e sem uso durante semanas.
const CAMINHOES := {
	"pescado": {
		"my": preload("res://art/props/caminhao_pescado.png"),
		"mx": preload("res://art/props/caminhao_pescado_mx.png"),
	},
	"armazenagem": {
		"my": preload("res://art/props/caminhao_armazenagem.png"),
		"mx": preload("res://art/props/caminhao_armazenagem_mx.png"),
	},
	"conteiner": {
		"my": preload("res://art/props/caminhao_conteiner.png"),
		"mx": preload("res://art/props/caminhao_conteiner_mx.png"),
	},
	"granel": {
		"my": preload("res://art/props/caminhao_granel.png"),
		"mx": preload("res://art/props/caminhao_granel_mx.png"),
	},
}

## ONDE CADA CAMIÃO SAI DA RUA PARA ENTRAR NO BERÇO.
##
## O `vias()` já desenhava, para cada píer, uma ligação da rua até o avental —
## é ela que explica para que serve a estrada. Até 07/09 nada a percorria: o
## camião levava a carga da doca do mesmo índice e passava reto. O pedido da
## segunda jogada foi dar-lhe o destino: *"ao alocar um navio de um determinado
## serviço, um caminhão relacionado pode aparecer na estrada e ir para a doca
## desse navio. Caso o navio vá embora, esse caminhão vai embora também."*
##
## ⚠️ OS NÚMEROS SÃO REPETIDOS DO GERADOR, E É O D13 QUE OS TRANCA. O mapa
## publica `acessos` na tabela de âncoras — entrada, `mx` e `my` de cada
## acesso —, saídos das mesmas expressões que os desenham; isto aqui é a cópia
## que roda dentro do jogo, que não lê o JSON. Repetição sem asserção é o
## contrato a divergir calado, e é a mesma razão de o `ROTA_ESTRADA` ser
## conferido ponto a ponto.
##
## `entrada` é o ponto DA ROTA onde ele vira (o meio do asfalto do degrau, na
## altura do berço); `paragem` é onde ele encosta, no fundo do acesso.
const ACESSOS_DOCA: Array[Dictionary] = [
	{"entrada": Vector2(0.55, 3.2), "paragem": Vector2(3.45, 3.2)},
	{"entrada": Vector2(4.55, 11.2), "paragem": Vector2(7.45, 11.2)},
	{"entrada": Vector2(8.55, 19.2), "paragem": Vector2(11.45, 19.2)},
]

## O quanto a paragem recua do fim do acesso, para o DESENHO caber lá dentro.
##
## Medido nos quatro PNGs de `mx`: o que mais avança à frente da âncora é o
## porta-contêiner, com 28px = 1,40 unidades; o acesso acaba no avental
## (`borda - APRON`). Recuar 1,25 põe o nariz do maior praticamente na beira do
## avental e mantém a âncora bem dentro do asfalto. É medida, não gosto — e é
## por isso que o D13 confere a paragem contra o acesso publicado.
const BERCO_RECUO := 1.25

# O motivo que cada caminhão leva na volta que está a fazer. Ele é escolhido
# quando o caminhão entra no mapa e NÃO muda a meio da travessia: um camião
# que trocasse de carroçaria a meio da rua é um camião a transformar-se à
# vista. Índice = índice do nó `Caminhao<N>`.
var _carga_na_estrada: Array[String] = []

# O `id` do barco por causa do qual o camião está PARADO no berço, ou -1 se ele
# não está parado. É o `id` e não o índice da doca porque um barco que sai e
# outro que chega na mesma passagem deixam a doca ocupada as duas vezes: sem o
# `id`, o camião ficaria eternamente parado a servir barcos que já foram
# embora. Índice = índice do nó `Caminhao<N>`.
var _visita_na_doca: Array[int] = []

# O canto do quadro de 512 que corresponde ao ponto de partida da cena. Era uma
# variável local do `_animar_caminhoes()` enquanto a volta era um tween em laço;
# com a volta a rearmar-se sozinha, ela tem de sobreviver entre voltas.
var _base_do_caminhao: Array[Vector2] = []


## A silhueta que um trecho pede: a de `mx` se ele anda em `mx`, a de `my` se
## anda em `my`. É PÚBLICA e vive num lugar só porque o D13 lhe pergunta —
## recalcular a mesma escolha do lado do teste seria o teste a concordar
## consigo próprio, e foi assim que a primeira versão dele deixou passar um
## caminhão que usava a mesma silhueta nos oito trechos.
func silhueta_do_trecho(de: Vector2, para: Vector2, motivo: String) -> Texture2D:
	var par: Dictionary = CAMINHOES[motivo]
	return par["mx"] if abs(para.x - de.x) > 0.01 else par["my"]


## O deslocamento de tela entre dois pontos da rota. Só precisa das duas
## constantes da projeção — `CX`, `CY` e a altura do cais cancelam-se na
## diferença.
func tela_da_rota(ponto: Vector2, origem: Vector2) -> Vector2:
	var d := ponto - origem
	return Vector2((d.x - d.y) * MEIA_LARG, (d.x + d.y) * MEIA_ALT)


## `a` vem depois de `b` na rota? Comparar por `my` chega quase sempre — a rota
## nunca recua nele —, e o desempate por `mx` resolve os cotovelos, que andam
## com o `my` parado.
func _adiante(a: Vector2, b: Vector2) -> bool:
	return a.y > b.y or (is_equal_approx(a.y, b.y) and a.x > b.x)


## Os pontos da rota a partir de `desde`, inclusive — os que ainda estão à
## FRENTE de onde se começa.
func _pontos_da_rota(desde: Vector2) -> Array[Vector2]:
	var pontos: Array[Vector2] = [desde]
	for ponto in ROTA_ESTRADA:
		if _adiante(ponto, desde):
			pontos.append(ponto)
	return pontos


## Os pontos da rota de `desde` até `ate`, ambos inclusive. `ate` é sempre um
## ponto de entrada de acesso, que fica num trecho RETO — por isso basta cortar
## a lista pelos dois lados, sem inventar vértice nenhum.
func _pontos_entre(desde: Vector2, ate: Vector2) -> Array[Vector2]:
	var pontos: Array[Vector2] = [desde]
	for ponto in ROTA_ESTRADA:
		if _adiante(ponto, desde) and _adiante(ate, ponto):
			pontos.append(ponto)
	pontos.append(ate)
	return pontos


## O `id` do barco que está a ser servido na doca `i`, ou -1 se não há visita a
## fazer. A pergunta é a do pedido — *"ao ALOCAR um navio"* —, e por isso são as
## DUAS condições: barco no berço E trabalhador nele. Um camião encostado num
## berço sem ninguém a trabalhar diria que o porto está a operar quando não
## está, e é justamente esse o aviso que o jogo dá em letra âmbar por baixo do
## mapa.
func _visita_da_doca(i: int) -> int:
	if i >= GameState.docks.size():
		return -1
	var doca: Dictionary = GameState.docks[i]
	if doca["worker_id"] == null:
		return -1
	var barco = doca["boat"]
	if barco == null:
		return -1
	return int(barco["id"])


## Quantos segundos leva a percorrer o que resta da rota a partir de `desde`.
## Sai da MESMA conta que a animação usa — comprimento a dividir pela
## velocidade —, e é ela que dá a espera de arranque de cada caminhão.
func _tempo_da_rota(desde: Vector2) -> float:
	var pontos := _pontos_da_rota(desde)
	var px := 0.0
	for i in range(pontos.size() - 1):
		px += tela_da_rota(pontos[i + 1], pontos[i]).length()
	return px / CAMINHAO_VELOCIDADE


## O que passa na estrada é O QUE ESTÁ A SER SERVIDO NA DOCA DO MESMO ÍNDICE.
##
## Três docas, três camiões, um para um: a carga que sai do berço sai também
## pela rua, e o jogador que olhe para uma coisa vê a outra. Sem sorteio
## nenhum, e de propósito — o `RandomNumberGenerator` do jogo é o que o
## simulador de balanceamento usa, e um enfeite a gastar sorteios mexeria na
## sequência que as 600 partidas por perfil medem. É a mesma regra do
## `Registro`, que nasce desarmado para não gravar 1.800 arquivos.
##
## Doca vazia ou por construir cai no que o PORTO consegue receber — os motivos
## das classes já destravadas (`docs/decisoes/009`), em roda pelo índice. Assim
## o porto em ruínas manda peixe e carga geral pela estrada, e o porto de nível
## 3 manda contêiner: a estrada conta a mesma história que o cais.
func _motivo_da_estrada(i: int) -> String:
	if i < GameState.docks.size():
		var barco = GameState.docks[i]["boat"]
		if barco != null:
			return String(barco["motivo"])
	var motivos: Array = []
	for classe in GameState.classes_disponiveis():
		for m in GameState.CLASSES_DE_NAVIO[classe]["motivos"]:
			if not motivos.has(m):
				motivos.append(m)
	return String(motivos[i % motivos.size()])


func _animar_caminhoes() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	var n := CAMINHAO_ORIGENS.size()
	_carga_na_estrada.resize(n)
	_visita_na_doca.resize(n)
	_base_do_caminhao.resize(n)
	_visita_na_doca.fill(-1)

	# O CICLO É IGUAL PARA OS TRÊS: pausa + travessia inteira. É esse número
	# que a espera de arranque reparte, e é por ele ser igual que a repartição
	# vale para sempre.
	#
	# ⚠️ ELE DEIXOU DE SER O ÚNICO RITMO em 07/09, e de propósito: um camião que
	# encosta num berço fica lá enquanto o navio estiver a ser servido, e isso
	# não tem duração fixa nenhuma — depende dos turnos de operação e de quando
	# o jogador avança o dia. A repartição continua a valer para as voltas SEM
	# visita, que são as que mantêm a estrada viva; quem visita sai da roda e
	# volta a ela quando parte do berço.
	var ciclo := CAMINHAO_INTERVALO + _tempo_da_rota(ROTA_ESTRADA[0])
	# ⚠️ A ESPERA DE ARRANQUE É DERIVADA, e o número não se escreve à mão.
	# A estrada visível é um terço da rota, então três camiões todos à vista ao
	# mesmo tempo estão, por construção, amontoados num terço do ciclo: sem
	# isto ver-se-iam os três de enfiada e depois quarenta e sete segundos de
	# rua vazia. A espera acerta cada um no seu terço do ciclo, uma vez só.
	var fase_zero := _tempo_da_rota(CAMINHAO_ORIGENS[0]) + CAMINHAO_INTERVALO

	for i in range(n):
		var caminhao := cenario.get_node_or_null("Caminhao%d" % i) as TextureRect
		if caminhao == null:
			continue
		var origem: Vector2 = CAMINHAO_ORIGENS[i]
		# A cena põe o nó no ponto de partida dele; `base` é o canto do quadro
		# de 512 que corresponde a esse ponto, e tudo o resto é medido dali.
		_base_do_caminhao[i] = caminhao.position
		var espera := fase_zero + float(i) * ciclo / float(n) \
			- _tempo_da_rota(origem)
		while espera < CAMINHAO_INTERVALO:
			espera += ciclo

		# ⚠️ A PRIMEIRA PASSAGEM COMEÇA JÁ, e onde a cena o pôs. Ela existe para
		# que os três estejam à vista no primeiro frame — sem isso a estrada
		# abre vazia e fica assim até o primeiro deles entrar pelo topo. A
		# `espera` que reparte o ciclo vem DEPOIS dela, que é onde ela estava
		# quando isto era um tween em laço.
		#
		# Que ela possa desviar-se para o berço não é enfeite: é o que faz a
		# mecânica caber numa captura, porque uma volta inteira leva ~69s e
		# nenhuma fotografia espera tanto. Só dois dos três a alcançam, e é
		# geometria e não escolha — a origem do terceiro fica depois do acesso
		# dele. Ver o tiro `docas` do `capturar_evidencia.sh`.
		_entrar_no_mapa(i, origem, espera + CAMINHAO_INTERVALO)


## Arma UMA volta: a pausa, e depois a travessia que a pausa precede.
##
## ⚠️ ISTO ERA UM TWEEN EM LAÇO ATÉ 07/09, e a visita ao berço é a razão de
## deixar de o ser. Um laço só sabe repetir a mesma coisa: com o desvio, cada
## volta é diferente da anterior — desvia-se ou não conforme a doca do mesmo
## índice —, e a decisão tem de ser tomada NO ARRANQUE de cada uma, com o
## camião fora do mapa. Uma volta que se rearma faz isso; um laço obrigaria a
## reconstruir o tween a meio, que é onde moram os defeitos que ele pediu para
## evitar.
func _lancar_volta(i: int, pausa: float) -> void:
	var caminhao := _no_do_caminhao(i)
	if caminhao == null:
		return
	var tw := caminhao.create_tween()
	tw.tween_interval(maxf(pausa, CAMINHAO_INTERVALO))
	# A DECISÃO É TOMADA NO FIM DA PAUSA, e não ao armar: entre armar e chegar a
	# hora passam segundos em que o jogador pode ter avançado o dia. Decidir no
	# momento em que ele entra no mapa é decidir com o estado que o jogador vê.
	tw.tween_callback(func() -> void:
		_entrar_no_mapa(i, ROTA_ESTRADA[0], CAMINHAO_INTERVALO))


## O camião entra no mapa: escolhe a carga, e vai até o acesso da doca dele.
## `pausa_apos` é o que ele espera antes da volta seguinte — só a primeira
## passagem passa aqui um valor diferente do intervalo comum, e é ela que
## reparte os três pelo ciclo.
func _entrar_no_mapa(i: int, desde: Vector2, pausa_apos: float) -> void:
	var caminhao := _no_do_caminhao(i)
	if caminhao == null:
		return
	# ⚠️ A CARGA ESCOLHE-SE AQUI E NÃO MUDA ATÉ A VOLTA SEGUINTE. Ele está fora
	# do mapa neste instante; um camião que trocasse de carroçaria a meio da rua
	# é um camião a transformar-se à vista.
	_carga_na_estrada[i] = _motivo_da_estrada(i)

	# ⚠️ ELE PASSA SEMPRE PELO PONTO DE ENTRADA DO ACESSO, visite ou não.
	#
	# A primeira versão decidia a visita aqui, à entrada do mapa — e isso punha
	# a decisão a um minuto de distância do jogador: alocar um trabalhador não
	# fazia nada até o camião dar a volta inteira. Decidir NO ACESSO é decidir
	# no instante em que a escolha importa, e é a decisão mais segura de todas:
	# ali ele está parado num vértice conhecido, e o que se faz é começar o
	# percurso seguinte — nunca remendar um a meio, que é onde moram os defeitos
	# que a segunda jogada pediu para evitar.
	var acesso: Dictionary = ACESSOS_DOCA[i] if i < ACESSOS_DOCA.size() else {}
	if not acesso.is_empty() and _adiante(acesso["entrada"], desde):
		_percorrer(caminhao, i, _pontos_entre(desde, acesso["entrada"]),
			func() -> void: _no_acesso(i, pausa_apos))
		return

	_percorrer(caminhao, i, _pontos_da_rota(desde), func() -> void:
		_lancar_volta(i, pausa_apos)
	)


## Chegou à altura do berço: entra, ou segue viagem.
func _no_acesso(i: int, pausa_apos: float) -> void:
	var caminhao := _no_do_caminhao(i)
	if caminhao == null:
		return
	var acesso: Dictionary = ACESSOS_DOCA[i]
	var visita := _visita_da_doca(i)
	if visita < 0:
		_percorrer(caminhao, i, _pontos_da_rota(acesso["entrada"]),
			func() -> void: _lancar_volta(i, pausa_apos))
		return
	_percorrer(caminhao, i, [acesso["entrada"], acesso["paragem"]],
		func() -> void:
			# ENCOSTOU. A partir daqui não há tween nenhum a correr: quem o
			# manda embora é `_docas_mudaram()`, e enquanto o navio estiver no
			# berço ele fica. Era isto o pedido.
			_visita_na_doca[i] = visita
	)


## O camião larga o berço: sai de marcha-atrás pelo acesso e retoma a estrada.
##
## ⚠️ ELE SAI DE RÉ, E ISSO É UMA ESCOLHA COM CUSTO. Só há duas silhuetas por
## carga — uma por eixo —, e as duas foram desenhadas para o sentido POSITIVO,
## que é o único que a rota usava. O acesso percorre-se para dentro em `+mx` e
## para fora em `-mx`: uma das duas pernas ia ser de ré fizesse-se o que se
## fizesse. Um terceiro jogo de PNGs viraria a cabine para `-mx` e mostraria a
## traseira — não é rodar o prop, é reconstruí-lo, porque só as faces `+x` e
## `-y` se veem —, e são mais quatro peças de arte para 74px de movimento lento
## na beira do quadro. Encostar de frente e sair de ré é o que um camião de
## carga faz numa baía; a alternativa era ele entrar de ré, que seria a mesma
## perna invertida e menos legível.
func _sair_do_berco(i: int) -> void:
	var caminhao := _no_do_caminhao(i)
	if caminhao == null:
		return
	var acesso: Dictionary = ACESSOS_DOCA[i]
	var entrada: Vector2 = acesso["entrada"]
	_percorrer(caminhao, i, ([acesso["paragem"], entrada]
		+ _pontos_da_rota(entrada).slice(1)), func() -> void:
			_lancar_volta(i, CAMINHAO_INTERVALO)
	)


## Um barco saiu de um berço onde havia um camião encostado? Então ele vai
## embora também. Chamada pelo `_refresh_docks()`, que é o ponto único por onde
## o estado das docas chega à tela.
##
## ⚠️ ELA COMPARA O `id` DO BARCO, e não "há barco na doca". Um barco que acaba
## e outro que chega no mesmo avanço de dia deixam a doca ocupada as duas vezes,
## e um camião que só perguntasse "ainda há barco?" ficaria parado para sempre a
## servir cargas que já foram embora — e com a carroçaria da primeira.
func _docas_mudaram() -> void:
	for i in range(_visita_na_doca.size()):
		if _visita_na_doca[i] < 0:
			continue
		if _visita_da_doca(i) == _visita_na_doca[i]:
			continue
		_visita_na_doca[i] = -1
		_sair_do_berco(i)


## O nó do camião `i`, ou `null` se a cena ainda não está de pé. Um lugar só
## porque cinco funções o buscavam, e cada cópia é uma chance de uma delas
## esquecer a guarda.
func _no_do_caminhao(i: int) -> TextureRect:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return null
	return cenario.get_node_or_null("Caminhao%d" % i) as TextureRect


## Enfia num tween novo um trecho por par de pontos consecutivos, e chama
## `ao_fim` quando o último acabar. O primeiro ponto é um TELEPORTE: é ele que
## põe o camião no princípio do percurso antes de o percorrer.
func _percorrer(caminhao: TextureRect, indice: int, pontos: Array,
		ao_fim: Callable) -> void:
	var base: Vector2 = _base_do_caminhao[indice]
	var origem_do_no: Vector2 = CAMINHAO_ORIGENS[indice]
	var tw := caminhao.create_tween()
	tw.tween_callback(func() -> void:
		caminhao.position = base + tela_da_rota(pontos[0], origem_do_no)
		# ⚠️ A SILHUETA DE PARTIDA SAI DO PRIMEIRO TRECHO, e não de um `my`
		# cravado. Ela esteve cravada enquanto houve uma origem só, que calhava
		# ser num trecho reto; com três origens um `my` fixo poria um caminhão
		# atravessado no primeiro frame de quem começasse num cotovelo.
		caminhao.texture = silhueta_do_trecho(pontos[0],
			pontos[min(1, pontos.size() - 1)], _carga_na_estrada[indice])
		_ordenar_por_profundidade(caminhao)
	)
	for i in range(pontos.size() - 1):
		var de: Vector2 = pontos[i]
		var para: Vector2 = pontos[i + 1]
		var origem := base + tela_da_rota(de, origem_do_no)
		var destino := base + tela_da_rota(para, origem_do_no)
		# A silhueta certa para o eixo do trecho — é isto que faz a curva ler
		# como curva em vez de o caminhão deslizar de lado.
		tw.tween_callback(func() -> void:
			caminhao.texture = silhueta_do_trecho(de, para,
				_carga_na_estrada[indice])
		)
		tw.tween_method(func(t: float) -> void:
			caminhao.position = origem.lerp(destino, t)
			_ordenar_por_profundidade(caminhao)
		, 0.0, 1.0, origem.distance_to(destino) / CAMINHAO_VELOCIDADE)
	tw.tween_callback(ao_fim)


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
	# E OBRIGA A OLHAR PARA A ESTRADA, pela mesma razão: um camião encostado num
	# berço está lá por causa de um barco, e quando esse barco sai ele vai
	# embora. Este é o ponto único por onde o estado das docas chega à tela, e
	# por isso é aqui — não em cada um dos sinais que mexem numa doca.
	_docas_mudaram()


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
	# `connect` por NOME, e não `menu.ver_balanco.connect(...)`: o
	# `_abrir_painel` devolve um `Control`, e um `Control` não declara este
	# sinal — a forma com ponto não compila. É a mesma razão de o `GS` destipado
	# obrigar a escrever o tipo à mão.
	var menu := _abrir_painel(PauseMenuScene)
	menu.connect("ver_balanco", func() -> void:
		_on_game_over(GameState.won, GameState.end_reason))


func _on_rival_offer_triggered(dock_index: int) -> void:
	_refresh_docks()
	_abrir_painel(CounterOfferScene).setup(dock_index)


func _on_debt_due(amount: int) -> void:
	_abrir_painel(DebtPaymentScene).setup(amount)


func _on_game_over(did_win: bool, reason: String) -> void:
	_abrir_painel(EndGameScene).setup(did_win, reason)
