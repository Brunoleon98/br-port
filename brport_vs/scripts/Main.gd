extends Control

const CancelarServicoScene := preload("res://scenes/panels/PainelCancelarServico.tscn")

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
# O TRÁFEGO DOS CAMIÕES, num script seu desde o M8 (`docs/decisoes/095`): a
# rua, as duas mãos, a cedência e a visita ao berço. `preload` e não
# `class_name`, pela razão do `Dock.gd`: ele lê o `GameState` pelo nome.
const TrafegoDeCamioes := preload("res://scripts/TrafegoDeCamioes.gd")
# A VOZ DA DONA CIDA NA FAIXA, num script seu desde o segundo corte do M8
# (`docs/decisoes/096`): o que a põe a falar, a variante de cada momento e as
# memórias que a impedem de se repetir. `preload` pela mesma razão.
const NarradoraDaCida := preload("res://scripts/NarradoraDaCida.gd")
# A OBRA NO MAPA (`docs/decisoes/121`): o armazém e o pátio a avançar dia a
# dia, do dia em que se paga ao dia em que ficam prontos. `preload` pela razão
# do tráfego: ele lê o `GameState` pelo nome.
const ObraNoMapa := preload("res://scripts/ObraNoMapa.gd")
# A MATA DO MORRO (`docs/decisoes/127`): as árvores do Blender atrás da vila,
# intercaladas no `Cenario` pela profundidade e a balançar como os coqueiros.
const MataNoMapa := preload("res://scripts/MataNoMapa.gd")
# A FILA DAS TELAS QUE ABREM SOZINHAS, num script seu desde o terceiro corte
# do M8 (`docs/decisoes/097`). `preload` pela mesma razão.
const VezDasTelas := preload("res://scripts/VezDasTelas.gd")
# O TUTORIAL CURTO, que o Toninho guia no dia 1 (`docs/decisoes/100`, `101`).
# `preload` pela mesma razão: lê o `GameState` pelo nome.
const TutorialDoToninho := preload("res://scripts/TutorialDoToninho.gd")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")
const TelaNomesScene := preload("res://scenes/panels/TelaNomes.tscn")
const PainelDiarioScene := preload("res://scenes/panels/PainelDiario.tscn")
const PainelBoletimScene := preload("res://scenes/panels/PainelBoletim.tscn")
const PainelCaixaScene := preload("res://scenes/panels/PainelCaixa.tscn")
const PainelMensagensScene := preload("res://scenes/panels/PainelMensagens.tscn")
const PainelReputacaoScene := preload("res://scenes/panels/PainelReputacao.tscn")
const PainelDocasScene := preload("res://scenes/panels/PainelDocas.tscn")
const PainelCalendarioScene := preload("res://scenes/panels/PainelCalendario.tscn")
const PainelMenuScene := preload("res://scenes/panels/PainelMenu.tscn")
const PainelMetaScene := preload("res://scenes/panels/PainelMeta.tscn")
const DiarioFase2Scene := preload("res://scenes/panels/DiarioFase2.tscn")
const PainelParcelaScene := preload("res://scenes/panels/PainelParcela.tscn")
const PainelAjustesScene := preload("res://scenes/panels/PainelAjustes.tscn")
const DiagnosticoScene := preload("res://scenes/panels/PainelDiagnostico.tscn")
const ComoJogarScene := preload("res://scenes/panels/PainelComoJogar.tscn")
# A tela inicial é uma CENA e não um painel: sair para ela troca a árvore
# inteira, e é por isso que ela não está com os painéis acima (`066`).
const CENA_INICIAL := "res://scenes/TelaInicial.tscn"


# As quatro cores da faixa de mensagem VIVEM NO TEMA desde 22/09, em
# `TextoFaixa`, `TextoFaixaBom`, `TextoFaixaAviso` e `TextoFaixaRuim`. O que
# este script escolhe é a VARIAÇÃO, nunca a cor — ver `_pintar()`.

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
# A FILA DA FAIXA. Objeto do Main e não autoload, de propósito: um autoload
# carregaria também nas seis suítes e nas 600 partidas por perfil do
# simulador, que é o que o `Registro.gd` já ensinou a não fazer.
var _fila := FilaDeMensagens.new()
# QUEM FALA PARA ELA, além do sistema: a Dona Cida, com a fila que é desta
# tela. É PÚBLICA pela razão do `trafego`: a régua da faixa ouve-lhe o
# `falou`, e o F8 do `teste_fumaca` chama-lhe a semana nova — lida direto,
# um nome errado grita. Liga-se aos sinais no `_connect_game_state()`.
var narradora: NarradoraDaCida = NarradoraDaCida.new(_fila)

# A VEZ DAS TELAS QUE ABREM SOZINHAS — o Sr. Ribeiro, o boletim e o fim de
# fase —, num script seu desde o terceiro corte do M8 (`VezDasTelas.gd`,
# `docs/decisoes/097`). É PÚBLICA pela razão do `trafego`: o T16 do
# `run_tests` fecha quem tem a vez, e lido direto um nome errado grita.
@onready var vez: VezDasTelas = VezDasTelas.new(self)

# O TUTORIAL DO DIA 1, com a fila da faixa (onde o Toninho fala) e o botão que
# ele faz pulsar. É PÚBLICO pela razão do `trafego`: o F22 do `teste_fumaca`
# lê-lhe o passo, e a sonda da régua da faixa ouve-lhe o `falou` — lido
# direto, um nome errado grita. Começa em `_depois_da_abertura()`.
@onready var tutorial: TutorialDoToninho = TutorialDoToninho.new(_fila,
	$AcoesTurno/Avancar)

@onready var _message_cartao: PanelContainer = $MensagemCartao
@onready var _message_label: Label = $MensagemCartao/Linha/Mensagem
@onready var _pendentes_label: Label = $MensagemCartao/Linha/Pendentes
@onready var _advance_button: Button = $AcoesTurno/Avancar
@onready var _upgrade_button: Button = $LinhaConstruir/Upgrade
@onready var _menu_button: Button = $LinhaConstruir/Menu
# Uma doca tem DUAS metades na tela: a vaga no mapa (píer, barco, guindaste,
# trabalhador) e o cartão na barra de baixo (texto e alvo de toque). O Main é
# quem sabe que as duas são a mesma doca de índice `i` — nenhuma das duas
# conhece a outra.
@onready var _docks_container: Control = $MapaWrap/Docas
@onready var _dock_cards: HBoxContainer = $BarraDocas
# A camada do «+R$» que sobe do barco servido, por cima das três docas
# (`078`, e o comentário do nó no `Main.tscn`).
@onready var _ganhos: Control = $MapaWrap/Ganhos
# OS CAMIÕES DA RUA. Um objeto do Main, como a fila da faixa, a quem se dá o
# `Cenario` onde eles vivem e as vagas a quem avisam que encostaram. É
# PÚBLICO porque as suítes e as ferramentas lhe perguntam pelo trânsito: lido
# direto, um nome errado grita, onde um `get` por string ficaria calado.
@onready var trafego: TrafegoDeCamioes = TrafegoDeCamioes.new(
	$MapaWrap.get_node_or_null("Cenario"), _docks_container)

# A linha «Ao largo» (`083`): os três lugares da fila no fundeadouro e o
# rótulo que diz se há escolha a fazer. Substituiu a fileira dos
# trabalhadores, a seleção por toque e o «Alocar todos» — desde a fila o
# trabalhador vai junto com o barco, e não havia escolha nenhuma em alocá-lo.
@onready var _fila_lugares: HBoxContainer = $Fila
@onready var _fila_titulo: Label = $FilaTitulo
@onready var _mapa: TextureRect = $MapaWrap/Mapa
# A OBRA NO MAPA. Um objeto do Main, como o tráfego, a quem se dão o mapa, o
# recorte do asfalto e o canteiro do pátio; quem o chama é o
# `_refresh_estruturas()`. O D45 não lhe pergunta nada: lê os nós da cena.
@onready var obra: ObraNoMapa = ObraNoMapa.new(_mapa,
	$MapaWrap/AsfaltoDaObra as Polygon2D,
	$MapaWrap/Cenario/CanteiroDoPatio as TextureRect)
# A MATA DO MORRO. Planta-se ao montar a cena, antes de o trânsito começar a
# reordenar os camiões entre os irmãos — que passam a contar com ela.
@onready var mata: MataNoMapa = MataNoMapa.new($MapaWrap/Cenario as Control)
var movimento_de_fundo: MovimentoDeFundo

# As estruturas trocam de TEXTURA, não de nó: assim o prop ocupa exatamente o
# mesmo quadro nos dois estados e o prédio não salta ao ser consertado — a
# mesma razão que fez o píer partilhar a geometria entre vazio e construído.
## O que só faz sentido num pátio já reconstruído. Ver `_refresh_estruturas`.
const EQUIPAMENTO_DE_PATIO := ["Empilhadeira", "PilhaCaixotes", "Pallet",
	"Guincho", "ConeTransito", "Barreira"]
## Os dois do equipamento que são SINALIZAÇÃO DE OBRA — a barreira listrada e
## o cone —, e por isso aparecem também enquanto o pátio está a ser feito
## (`121`). O resto (empilhadeira, pallets, guincho) é de pátio a trabalhar.
const SINALIZACAO_DE_OBRA := ["ConeTransito", "Barreira"]

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
	movimento_de_fundo = MovimentoDeFundo.new()
	add_child(movimento_de_fundo)
	PreferenciasDeApresentacao.atual().mudou.connect(_aplicar_movimento)
	# O gravador de partida (item B7) só grava depois disto, e ESTA é a única
	# linha do projeto que o arma. É de propósito que seja o jogo a armá-lo e
	# não ele a armar-se sozinho: o autoload está de pé também durante as 600
	# partidas × 3 perfis do simulador e durante as quatro suítes, que não
	# abrem cena nenhuma — se gravasse por omissão, medir o balanceamento
	# escreveria 1.800 arquivos e o custo de os escrever entraria na medida.
	Registro.armar()
	GameState.gerenciamento_solicitado.connect(_gerenciar_servico)

	_advance_button.pressed.connect(_on_advance_pressed)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)
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
	mata.animar()
	# A frente visual mantém a implantação da mata. O RB6 usa apenas sua API
	# pública de nós/rajadas, sem alterar árvores, arte ou enquadramento.
	for i in mata.nos().size():
		movimento_de_fundo.guardar(mata.rajadas()[i], mata.nos()[i], {"rotation": 0.0})
	_animar_boias()
	_animar_luzes()
	trafego.animar_caminhoes()
	trafego.animar_retorno()
	_animar_espuma()

	# Turno 1 abria com a faixa de mensagem VAZIA — um cartão creme com nada
	# dentro, que na tela lê como falha e não como "ainda não aconteceu nada".
	# A mensagem inicial não pode vir do GameState: `new_game()` roda no
	# autoload, antes de esta cena existir para escutar o sinal.
	_fila.apresentou.connect(_pintar)
	# ⚠️ O TOQUE É NO CARTÃO INTEIRO, e não num botão ao lado: ele mede
	# 692x52 px, muito acima do alvo mínimo de 44 do projeto, e é a peça que a
	# pessoa está a olhar quando lhe falta o que passou. Um ícone de 19 px
	# obrigaria a mirar o que ela nem sabe que existe.
	_message_cartao.gui_input.connect(_on_faixa_input)
	if _message_label.text == "":
		_on_message(Narrativa.abertura_do_porto(), "", "porto")

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
			diario.fechou.connect(_depois_da_abertura)
		)
		return

	_depois_da_abertura()


# O FIM DA ABERTURA, pelos dois caminhos: a partida nova depois do diário, e
# a que se carrega logo no `_ready()`. Primeiro o painel que a fase pedir, e
# só depois o tutorial — que espera esse painel resolver-se antes de falar
# (`TutorialDoToninho.gd`). Começá-lo antes do caderno poria o Toninho a falar
# para uma faixa tapada pela folha de rosto.
func _depois_da_abertura() -> void:
	_recuperar_fase()
	tutorial.comecar()


# Se o jogo abre com uma fase que BLOQUEIA o turno, o painel que a resolve tem
# de estar na tela — venha ela de um save carregado ou do sorteio do
# `new_game()`. Vive numa função própria porque é chamada dos dois fins da
# abertura — o `_ready()` sem caderno e o diário fechado —, hoje pelo
# `_depois_da_abertura()`, que a seguir dá a vez ao tutorial.
func _recuperar_fase() -> void:
	if GameState.phase == GameState.ESTADO_OFERTA and GameState.pending_rival >= 0:
		_on_rival_offer_triggered(GameState.pending_rival)
	elif GameState.phase == GameState.ESTADO_COBRANCA:
		_on_debt_due(GameState.principal_da_parcela())
	elif GameState.phase == GameState.ESTADO_FIM:
		_on_game_over(GameState.won, GameState.end_reason)


# OS BARCOS DA ZONA DE ESPERA SÃO A FILA (`083`): os dois primeiros barcos ao
# largo, com o casco de cada um — o mesmo `arte_do_barco()` que os desenha na
# doca e no cartão «Ao largo». Até lá eram cenário: a classe mais alta que o
# porto recebia, num motivo e num valor escolhidos por índice para os dois
# não saírem com o mesmo casco. Desde que o barco espera ao largo, o que lá
# está é o que o jogador pode chamar, e um lugar vazio na fila é água vazia.
#
# São TRÊS, um por lugar da fila: a primeira passagem tinha só os dois da
# composição de `017`, e o terceiro barco ao largo existia no HUD e não no
# mapa — pedido do Bruno. A posição foi a dele numa prancha de duas: acima e
# à direita dos outros, no largo ainda livre, e não a da recomendação (abaixo,
# junto ao segundo). A ORDEM da fila não se lê pela posição no mapa — quem a
# diz é o cartão «Ao largo»; aqui só conta quantos estão à espera e de que
# porte. E o nó vive no `Cenario` entre a Empilhadeira e o Cabeço porque é aí
# que a profundidade dele cai (o D3).
const ANCORADOS := ["BarcoEspera1", "BarcoEspera2", "BarcoEspera3"]


func _pintar_ancorados() -> void:
	var i := 0
	for nome in ANCORADOS:
		var barco := $MapaWrap/Cenario.get_node_or_null(nome) as TextureRect
		if barco == null:
			continue
		if i < GameState.fila.size():
			var b: Dictionary = GameState.fila[i]
			barco.texture = DockScript.arte_do_barco(
				String(b["classe"]), String(b["motivo"]), int(b["value"]))
			barco.visible = true
		else:
			barco.visible = false
		i += 1


# Parados, fazem o porto parecer uma fotografia. Vivem dentro do Cenario, e
# não soltos no MapaWrap, porque a ordem lá dentro é a profundidade
# isométrica. Fases diferentes para não balançarem em bloco, que é o que
# denuncia a animação como truque.
func _animar_ancorados() -> void:
	var fases := [0.0, 0.85, 0.4]
	var i := 0
	for nome in ANCORADOS:
		var barco := $MapaWrap/Cenario.get_node_or_null(nome) as TextureRect
		if barco == null:
			continue
		var base := barco.position
		var tw := barco.create_tween().set_loops()
		movimento_de_fundo.guardar(tw, barco, {"position": base})
		if fases[i] > 0.0:
			tw.tween_interval(fases[i])
		tw.tween_property(barco, "position:y", base.y - 4.0, 2.1) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(barco, "position:y", base.y, 2.1) \
			.set_trans(Tween.TRANS_SINE)
		i += 1
	_pintar_ancorados()


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
		movimento_de_fundo.guardar(tw, no, {"rotation": 0.0})
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
		movimento_de_fundo.guardar(tw, tr, {"position": base})
		if fases[i % fases.size()] > 0.0:
			tw.tween_interval(fases[i % fases.size()])
		var dur: float = duracoes[i % duracoes.size()]
		tw.tween_property(tr, "position:y", base.y - 3.0, dur) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(tr, "position:y", base.y, dur) \
			.set_trans(Tween.TRANS_SINE)
		i += 1


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
const ESPUMA_AVANCO := Vector2(TrafegoDeCamioes.MEIA_LARG,
	TrafegoDeCamioes.MEIA_ALT) * 0.1333


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
		movimento_de_fundo.guardar(tw, camada, {"position": camada.position,
			"modulate:a": camada.modulate.a})
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
		movimento_de_fundo.guardar(tw, tr, {"modulate:a": 1.0})
		tw.tween_property(tr, "modulate:a", 0.82, 1.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(tr, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_interval(2.2)


func _connect_game_state() -> void:
	GameState.cash_changed.connect(func(_v): _refresh_hud())
	GameState.reputation_changed.connect(func(_v): _refresh_hud())
	GameState.phase_changed.connect(func(_p): _refresh_hud())
	# «Há escolha?» depende da FASE: com a oferta do Arlindo aberta não se
	# atraca, e o título, os cartões ao largo e o berço livre têm de o saber
	# quando ela fecha — ganhe quem ganhar, e a fila pode nem ter mudado.
	GameState.phase_changed.connect(func(_p): _repintar_fila())
	GameState.turn_advanced.connect(func(_t, _w): _refresh_all())
	GameState.boats_spawned.connect(func(): _refresh_docks())
	GameState.roster_changed.connect(_refresh_all)
	# A OBRA COMEÇA NO DIA DA COMPRA (`121`), e o mapa tem de a mostrar nesse
	# mesmo dia: até aqui nada redesenhava o porto ao comprar, porque a obra
	# só mudava alguma coisa na virada, quando ficava pronta.
	GameState.estrutura_comprada.connect(func(_id): _refresh_all())
	GameState.fila_mudou.connect(_refresh_fila)
	GameState.fila_mudou.connect(_pintar_ancorados)
	GameState.message.connect(_on_message)
	GameState.rival_offer_triggered.connect(_on_rival_offer_triggered)
	GameState.debt_due.connect(_on_debt_due)
	GameState.game_over.connect(_on_game_over)
	GameState.fase_concluida.connect(_on_fase_concluida)
	GameState.meta_atualizada.connect(_refresh_meta)
	GameState.semana_fechada.connect(_on_semana_fechada)

	# AS FALAS DA DONA CIDA penduram-se nos sinais acima, e ligam-se AQUI, por
	# último, como quando as sete linhas viviam neste sítio: quem ouve um sinal
	# é chamado pela ordem da ligação, e a extração não mudou essa ordem
	# (`NarradoraDaCida.gd`, `096`).
	narradora.conectar()


func _refresh_all() -> void:
	_refresh_estruturas()
	_refresh_hud()
	_refresh_docks()
	_refresh_fila()


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
	var patio_em_obra := int(GameState.quadro_da_obra("patio", 1)) >= 0
	for nome in EQUIPAMENTO_DE_PATIO:
		var eq := cenario.get_node_or_null(nome) as CanvasItem
		if eq != null:
			eq.visible = tem_patio or (patio_em_obra and nome in SINALIZACAO_DE_OBRA)
	obra.refresh()
	# O armazém em obra mostra o quadro do dia (`121`); fora dela, a ruína ou
	# o pronto, como sempre.
	var armazem := cenario.get_node_or_null("Armazem") as TextureRect
	if armazem != null:
		var em_obra := obra.textura_do_armazem()
		if GameState.tem_estrutura("armazem"):
			armazem.texture = ArmazemPronto
		elif em_obra != null:
			armazem.texture = em_obra
		else:
			armazem.texture = ArmazemRuina
	var escritorio := cenario.get_node_or_null("Escritorio") as TextureRect
	if escritorio != null:
		escritorio.texture = EscritorioPronto if GameState.tem_estrutura("escritorio") \
			else EscritorioRuina


func _refresh_hud() -> void:
	_mostrar_caixa(int(GameState.cash))
	# Na fase sem prazo o dia não tem «de quantos» (`104`).
	if GameState.fase_tem_prazo():
		var shown_day: int = min(GameState.turn, GameState.ultimo_dia_da_fase())
		_day_label.text = "Dia %d/%d" % [shown_day, GameState.ultimo_dia_da_fase()]
	else:
		_day_label.text = "Dia %d" % GameState.turn
	_rep_label.text = "%d %s" % [int(GameState.reputation), GameState.reputation_label()]
	_docks_label.text = "%d/%d" % [GameState.docks.size(), GameState.bercos_no_mapa()]
	# O botão não some quando tudo está construído: vira o registo de que o
	# porto está completo, que é uma informação, não um beco sem saída.
	var faltam := 0
	var liberadas := 0
	for id in GameState.ESTRUTURAS:
		if not GameState.tem_estrutura(String(id)):
			faltam += 1
			if GameState.desbloqueio_da_estrutura(String(id)) == "" \
					and GameState.obra_termina_na_fase(String(id)):
				liberadas += 1
	_upgrade_button.disabled = GameState.phase != GameState.ESTADO_JOGANDO or faltam == 0
	if faltam == 0:
		_upgrade_button.text = "Porto completo"
		Icones.no_botao(_upgrade_button, Icones.FEITO, 26)
	elif not GameState.obra_em_andamento.is_empty():
		_upgrade_button.text = "Construir  ·  obra em andamento"
		Icones.no_botao(_upgrade_button, Icones.AMPLIAR_PIER, 26)
	else:
		# O catálogo tem arte futura; só os reparos liberados contam como
		# disponíveis. Sem reparo aberto, o painel ainda explica as etapas.
		# ⚠️ «Disponível» é o que o CALENDÁRIO deixa comprar hoje: aberto e
		# ainda a terminar nesta fase (O7, `090`). O dinheiro não conta — quem
		# não pode pagar lê «Faltam R$…» no cartão, e o rodapé que desce a
		# zero por falta de caixa esconderia que há reparo à espera dele.
		_upgrade_button.text = "Construir  ·  %s" % Narrativa.concordar(liberadas,
			"disponível", "disponíveis") if liberadas > 0 else "Construir  ·  ver estruturas"
		Icones.no_botao(_upgrade_button, Icones.AMPLIAR_PIER, 26)
	_advance_button.disabled = GameState.phase != GameState.ESTADO_JOGANDO
	_refresh_meta()


# O playtest perdeu uma partida por R$1 sem nunca ver o quanto faltava. Esta é
# a informação que estava faltando na tela: quanto já tem, quanto falta e
# quantos dias restam até o Sr. Ribeiro bater na porta.
func _refresh_meta() -> void:
	# Sem cobrança, o cartão abre as três barras (`106`). O resumo dá o mesmo
	# peso a cada requisito; o painel mostra o que falta em cada um.
	if not GameState.tem_cobranca():
		_meta_icone.texture = Icones.FEITO
		var meta: Dictionary = GameState.progresso_da_meta()
		_meta_titulo.text = "Fase 2 concluída — jogo livre" if GameState.meta_concluida else "Meta da Fase 2 — toque para ver"
		_meta_bar.value = 100.0 * (float(meta["dias"]) / meta["dias_alvo"] + float(meta["infra"]) / meta["infra_alvo"] + meta["missao"]) / 3.0
		_meta_label.text = "Sem prazo: o porto segue enquanto houver dinheiro" if GameState.meta_concluida else "Reputação · infraestrutura · primeiro cargueiro"
		_meta_label.theme_type_variation = &"TextoPilulaBom"
		return
	var alvo := GameState.principal_da_parcela()
	if GameState.parcela_paid:
		# Pago: o banco dá lugar ao visto verde, que é o estado, não o credor.
		_meta_icone.texture = Icones.FEITO
		_meta_titulo.text = "Parcela %d de %d — Sr. Ribeiro" % [GameState.parcela_indice + 1, GameState.parcelas_na_fase()]
		_meta_bar.value = 100.0
		_meta_label.text = "Paga — %d de %s" % [GameState.parcelas_quitadas,
			Narrativa.concordar(GameState.parcelas_na_fase(), "quitada", "quitadas")]
		_meta_label.theme_type_variation = &"TextoPilulaBom"
		return

	# O banco em traço CLARO: o cartão passou a escuro em 04/10, e o `PARCELA`
	# dos painéis é navy cheio (`081`).
	_meta_icone.texture = Icones.PARCELA_BARRA
	var dias_restantes: int = max(GameState.vencimento_da_parcela() - GameState.turn + 1, 0)
	_meta_titulo.text = "Parcela %d de %d — %s" % [GameState.parcela_indice + 1,
		GameState.parcelas_na_fase(), Narrativa.concordar(dias_restantes, "dia restante", "dias restantes")]
	# O dinheiro do cartão é o MOSTRADO, e não o do `GameState`: na virada ele
	# conta junto com a pílula, e os dois números nunca discordam na tela
	# (`078`). Fora da virada os dois são o mesmo.
	_meta_bar.value = clamp(100.0 * float(_caixa_mostrado) / float(alvo), 0.0, 100.0)
	# ⚠️ O CONVITE ABRE ONDE A PORTA ABRE, e a porta cobra o valor de HOJE.
	# Até 04/10 ele comparava com a parcela CHEIA e escrevia «R$1.045.000 de
	# R$530.000» com a barra cheia, o que se lia como 197%; e entre o valor de
	# hoje e o cheio a porta já estava aberta e o cartão dizia «faltam». Hoje
	# a linha com sobra diz o MESMO número que a tarja do painel, que é o que
	# o botão de lá tira (o F15 confere os três) (`081`).
	var hoje: int = GameState.valor_da_parcela_hoje()
	if _caixa_mostrado < hoje:
		var falta: int = alvo - _caixa_mostrado
		_meta_label.text = "%s de %s — faltam %s" % [
			GameState.moeda(_caixa_mostrado), GameState.moeda(alvo), GameState.moeda(falta)]
		_meta_label.theme_type_variation = &"TextoBarra"
	else:
		# CARTÃO TOCÁVEL QUE NÃO SE ANUNCIA É CARTÃO QUE NINGUÉM TOCA. O convite
		# só aparece quando há o que fazer com ele — antes disso, tocar abriria
		# um painel que só sabe dizer quanto falta, e a linha aqui já diz isso.
		_meta_label.text = "Dá para quitar hoje por %s — toque para ver" % GameState.moeda(hoje)
		# ⚠️ O ÂMBAR CLARO, e não o `RotuloAlerta` que vestiu até 04/10. Aquele
		# é o âmbar escurecido para o cartão BRANCO (5,06:1 lá); o cartão
		# passou a escuro, onde ele mediria 2,93:1, e o claro da reputação na
		# pílula mede 8,37:1 no mesmo azul (`035`, `081`).
		_meta_label.theme_type_variation = &"TextoPilulaDestaque"


# As vagas já existem na cena, uma por píer desenhado no mapa. Aqui só se diz
# a cada uma qual índice ela representa — quem não tem doca correspondente se
# desenha como vaga por construir.
func _refresh_docks() -> void:
	var vagas := _docks_container.get_children()
	for i in range(vagas.size()):
		vagas[i].setup(i)
	var cartoes := _dock_cards.get_children()
	for i in range(cartoes.size()):
		cartoes[i].setup(i)
	# MEXER NAS DOCAS OBRIGA A REPINTAR A FILA, porque «há escolha?» é uma
	# pergunta sobre os berços livres e não sobre o barco: o cartão ao largo
	# acende quando um berço se solta, sem a fila ter mudado (`083`).
	_repintar_fila()
	# E OBRIGA A OLHAR PARA A ESTRADA, pela mesma razão: um camião encostado num
	# berço está lá por causa de um barco, e quando esse barco sai ele vai
	# embora. Este é o ponto único por onde o estado das docas chega à tela, e
	# por isso é aqui — não em cada um dos sinais que mexem numa doca.
	trafego.docas_mudaram()


func _clear(container: Node) -> void:
	# queue_free() sozinho é adiado até o fim do frame — sem o remove_child o
	# container fica com os nós velhos e os novos ao mesmo tempo por um frame.
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


# Os três lugares são da CENA (um por lugar do fundeadouro), e aqui só se diz a
# cada um qual índice mostra — como as docas. A fila anda: o lugar 0 mostra
# sempre quem chegou primeiro.
func _refresh_fila() -> void:
	var lugares := _fila_lugares.get_children()
	for i in range(lugares.size()):
		lugares[i].setup(i)
	_repintar_fila()


func _repintar_fila() -> void:
	for no in _fila_lugares.get_children():
		no.refresh()
	# O berço livre também fala da fila («livre — chame um barco» ou
	# «ninguém ao largo»), e um barco que chega não mexe em doca nenhuma.
	for cartao in _dock_cards.get_children():
		cartao.refresh()
	_refresh_titulo_fila()


# A linha acima da fila é a única de texto entre as docas e os barcos, e é a
# sucessora do «trabalhadores parados — docas esperando» do primeiro playtest:
# se algum lugar tem de dizer que há escolha por fazer, é este. Os estados:
# doca livre com barco pronto (a escolha, em âmbar, a dizer QUAL doca), barcos
# sem doca livre (a espera), o fundeadouro vazio, e a doca livre com o único
# barco nas mãos do Arlindo.
#
# ⚠️ O «os berços estão ocupados» da primeira versão era o ramo de tudo o
# resto, e mentia na oferta do rival: o berço estava livre e o barco ao largo
# não se podia chamar. Cada ramo diz agora o que o pôs lá.
func _refresh_titulo_fila() -> void:
	var pendente := GameState.atracagem_pendente()
	if pendente != Vector2i.ZERO:
		_fila_titulo.text = "%s — escolha quem atraca" % _docas_livres()
		_fila_titulo.theme_type_variation = &"TextoBarraAlerta"
	elif GameState.fila.is_empty():
		_fila_titulo.text = "Ao largo — ninguém fundeado hoje"
		_fila_titulo.theme_type_variation = &"TextoBarra"
	elif GameState.bercos_livres() == 0:
		_fila_titulo.text = "Ao largo — à espera de doca livre"
		_fila_titulo.theme_type_variation = &"TextoBarra"
	elif GameState.phase == GameState.ESTADO_OFERTA:
		_fila_titulo.text = "Ao largo — o Arlindo disputa um cliente"
		_fila_titulo.theme_type_variation = &"TextoBarra"
	else:
		_fila_titulo.text = "Ao largo"
		_fila_titulo.theme_type_variation = &"TextoBarra"


# «Doca 2 livre», «Docas 1 e 3 livres», «Docas 1, 2 e 3 livres»: o número de
# cada doca, que é o que está escrito no cartão por cima. Dizer QUAL poupa ao
# olho a procura do cartão aceso.
func _docas_livres() -> String:
	var numeros: Array[String] = []
	for i in range(GameState.docks.size()):
		if GameState.docks[i]["boat"] == null:
			numeros.append(str(i + 1))
	if numeros.size() == 1:
		return "Doca %s livre" % numeros[0]
	var ultimo: String = numeros.pop_back()
	return "Docas %s e %s livres" % [", ".join(numeros), ultimo]


# ⚠️ ISTO JÁ NÃO ESCREVE NA TELA — ENFILEIRA. Era o funil único das duas
# fontes e continua a sê-lo; o que mudou é que a faixa deixou de ser o que a
# última escrita deixou lá. Medido antes de mexer, 15 partidas: das 861
# escritas o jogador via 597, e 264 eram apagadas no mesmo frame em que
# nasciam (`tools/medir_fila_mensagens.gd`, `docs/decisoes/034`).
func _on_message(text: String, kind: String, assunto: String = "") -> void:
	_fila.enfileirar(text, kind, "sistema", GameState.turn, assunto)


# Quem escreve na tela, e só ele. Chamado pela fila quando chega a vez.
#
# A VARIAÇÃO por `kind`, e o tema é que sabe a cor — como o
# `_refresh_titulo_trabalhadores()` ao lado e o `DocaCartao.refresh()`.
#
# ⚠️ QUATRO LITERAIS, E NÃO UM DICIONÁRIO, e isso é decisão medida. A versão
# arrumada era um `const VARIACAO_DA_FAIXA := {...}` com um `.get(kind, ...)`;
# só que o `conferir_escopo_ui.py` procura `theme_type_variation = "<nome>"`,
# e num dicionário o nome não está depois do `=`. As quatro variações ficariam
# INVISÍVEIS ao portão que existe para as conferir, e um erro de digitação
# cairia no `Label` base sem uma palavra — que é a armadilha escrita no
# cabeçalho do próprio portão. A forma do código escolhe-se pelo que a régua
# ALCANÇA, que é a mesma regra por que a `041` escolheu a leva (`042`).
#
# ⚠️ E O `kind` DESCONHECIDO CAI NO NEUTRO DE PROPÓSITO — é o que a fila
# entrega para a voz da Dona Cida, que enfileira com `""`.
func _pintar(text: String, kind: String) -> void:
	_message_label.text = text
	match kind:
		"good":
			_message_label.theme_type_variation = &"TextoFaixaBom"
		"warn":
			_message_label.theme_type_variation = &"TextoFaixaAviso"
		"bad":
			_message_label.theme_type_variation = &"TextoFaixaRuim"
		_:
			_message_label.theme_type_variation = &"TextoFaixa"
	_pintar_pendentes()


# O CONTADOR EXISTE PARA O HISTÓRICO SER DESCOBERTO. Sem ele a fila drena
# calada e a pessoa não tem como saber que houve mais — o texto ficaria
# recuperável e ninguém iria buscá-lo, que é o `barco_medio` com a roupa de
# uma tela.
func _pintar_pendentes() -> void:
	var n := _fila.pendentes()
	_pendentes_label.text = "+%d" % n if n > 0 else ""


func _process(delta: float) -> void:
	if _fila.avancar(delta):
		return
	_pintar_pendentes()


func _on_faixa_input(evento: InputEvent) -> void:
	# A MESMA PERGUNTA DO `BarcoFila.gd`: toque que SOLTA, botão esquerdo. Reagir
	# ao premir dispara durante um arrasto que passe por cima da faixa.
	if evento is InputEventMouseButton:
		var b := evento as InputEventMouseButton
		if b.button_index == MOUSE_BUTTON_LEFT and not b.pressed:
			_abrir_painel(PainelMensagensScene).setup(_fila.historico)


func _on_semana_fechada(resumo: Dictionary) -> void:
	# O boletim é a única tela que abre sozinha durante o jogo. Abre no fecho
	# da semana, que já é um momento de pausa — o turno acabou de virar e não
	# há decisão pendente. Abrir a meio de um turno seria interromper.
	#
	# ⚠️ E NA SEMANA 4 ELE ESPERA A VEZ. O fecho dela vem de dentro do «Pagar»
	# (ou do «Não consigo pagar»), com o Sr. Ribeiro ainda na tela — ver
	# `VezDasTelas.gd`.
	vez.na_vez(func() -> Control:
		var painel := _abrir_painel(PainelBoletimScene)
		painel.setup(resumo)
		return painel)


# ── A VIRADA DO DIA NA TELA (`078`) ──
# O `GameState` vira o dia de uma vez, e continua a virar: a transição é a
# TELA a alcançar o estado novo, e nada do que ela faz volta ao jogo — o
# balanceamento e o simulador ficam intocados por construção. Escolha do
# Bruno, entre quatro: o barco servido parte (`Dock.gd`, `_mostrar_barco`),
# o dinheiro conta, e o que cada doca rendeu sobe do barco como «+R$».
#
# ⚠️ SÓ O BOTÃO ARMA A CONTAGEM. Toda outra mudança de dinheiro — comprar,
# pagar a parcela, uma suíte que escreve `GS.cash` e chama `_refresh_hud()` —
# continua a saltar para o valor certo, e é por isso que nenhuma asserção que
# lê o HUD logo a seguir a uma ação mudou. A troca de barco não depende do
# botão: ela é do MUNDO, e anima venha a virada de onde vier.
## A contagem dura o mesmo que o «+R$» no ar: o número chega ao valor novo
## quando o último ganho se desfaz. Eram 0,6 s, e o Bruno achou-a rápida.
const CONTAGEM_SEG := 1.2
const GANHO_SEG := 1.2
## O «+R$» nasce no MEIO do casco e sobe pouco, escolha do Bruno: o barco sai
## por baixo dele e o valor fica onde o barco estava, sobre a água do berço. Na
## primeira versão ele nascia 34 px acima e subia 40, e passava por cima da
## superestrutura do navio, do cais e da base da grua. O centro do quadro do
## barco cai no FUNDO do casco, e por isso o meio dele está acima do centro.
const GANHO_SUBIDA_PX := 20.0
const GANHO_ACIMA_PX := 12.0
var _virada_armada := false
var _caixa_mostrado := 0
var _tw_caixa: Tween


func _on_advance_pressed() -> void:
	if get_tree().has_group("confirmacao_cancelamento"):
		return
	# UM TOQUE A MEIO DA VIRADA ACABA-A JÁ, e vira o dia seguinte — quem joga
	# depressa não fica mais lento (escolha do Bruno, `078`).
	_concluir_virada()
	# QUEM VAI PAGAR, lido ANTES: depois da virada o barco servido já saiu, e
	# com ele a receita. O valor é o do `receita_da_doca()`, o mesmo
	# `_lancar_receita()` que põe o dinheiro no caixa, bónus incluído. E quem
	# pagou lê-se no RESULTADO — o barco que tinha trabalhador e já não está
	# lá —, em vez de repetir aqui a regra do `progress` contra o `op_turns`.
	var a_pagar: Dictionary = {}
	for i in range(GameState.docks.size()):
		var doca: Dictionary = GameState.docks[i]
		if doca["boat"] != null and doca["worker_id"] != null:
			a_pagar[i] = {"id": int(doca["boat"]["id"]),
				"valor": GameState.receita_da_doca(i)}
	_virada_armada = true
	GameState.advance_turn()
	_virada_armada = false
	for i in a_pagar:
		var barco = GameState.docks[i]["boat"]
		if barco == null or int(barco["id"]) != int(a_pagar[i]["id"]):
			_subir_ganho(int(i), int(a_pagar[i]["valor"]))


## Leva a virada em curso ao fim: o dinheiro no valor certo, cada barco no
## berço (ou a doca vazia) e nenhum «+R$» no ar. É o que o toque seguinte faz
## antes de virar outro dia, e o que a bateria de capturas faz antes de
## fotografar (`capturar_tela.gd`).
func _concluir_virada() -> void:
	if _tw_caixa != null and _tw_caixa.is_valid():
		_tw_caixa.kill()
		_pintar_caixa(int(GameState.cash))
	for vaga in _docks_container.get_children():
		vaga.concluir_troca()
	for rotulo in _ganhos.get_children():
		rotulo.visible = false
		rotulo.queue_free()


## A virada ainda está a acontecer na tela.
func virada_em_curso() -> bool:
	if _tw_caixa != null and _tw_caixa.is_valid() and _tw_caixa.is_running():
		return true
	for vaga in _docks_container.get_children():
		if vaga.em_troca():
			return true
	for rotulo in _ganhos.get_children():
		if not rotulo.is_queued_for_deletion():
			return true
	return false


func _mostrar_caixa(alvo: int) -> void:
	if _tw_caixa != null and _tw_caixa.is_valid():
		_tw_caixa.kill()
	if PreferenciasDeApresentacao.atual().reduzir_movimento or not _virada_armada or alvo == _caixa_mostrado:
		_pintar_caixa(alvo)
		return
	_tw_caixa = create_tween()
	_tw_caixa.tween_method(_pintar_caixa_f, float(_caixa_mostrado), float(alvo),
		CONTAGEM_SEG).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _pintar_caixa_f(valor: float) -> void:
	_pintar_caixa(int(round(valor)))


func _pintar_caixa(valor: int) -> void:
	_caixa_mostrado = valor
	_cash_label.text = GameState.moeda(valor)
	_refresh_meta()


## O «+R$» que sobe do barco servido da doca `doca` e se desfaz.
func _subir_ganho(doca: int, valor: int) -> void:
	var vagas := _docks_container.get_children()
	if doca >= vagas.size() or valor <= 0:
		return
	var rotulo := Label.new()
	rotulo.theme_type_variation = &"GanhoNoMapa"
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rotulo.text = "+" + GameState.moeda(valor)
	_ganhos.add_child(rotulo)
	rotulo.reset_size()
	# Pela transformada GLOBAL dos dois lados, e não somando `offset` de pai em
	# pai: é o `MapaWrap` (62 px) que esse caminho esquece (`CLAUDE.md`).
	var centro: Vector2 = _ganhos.get_global_transform().affine_inverse() \
		* vagas[doca].centro_do_barco()
	rotulo.position = centro - Vector2(rotulo.size.x * 0.5,
		rotulo.size.y * 0.5 + GANHO_ACIMA_PX)
	var tw := rotulo.create_tween().set_parallel(true)
	movimento_de_fundo.guardar(tw, rotulo, {"position": rotulo.position, "modulate:a": 1.0})
	tw.tween_property(rotulo, "position:y", rotulo.position.y - GANHO_SUBIDA_PX,
		GANHO_SEG).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(rotulo, "modulate:a", 0.0, GANHO_SEG * 0.4) \
		.set_delay(GANHO_SEG * 0.6)
	# A leitura do resultado tem o mesmo tempo, mesmo com o movimento pausado.
	# O descarte fica fora do tween decorativo para nunca esperar um ciclo parado.
	rotulo.create_tween().tween_interval(GANHO_SEG).finished.connect(rotulo.queue_free)


func _aplicar_movimento(reduzido: bool) -> void:
	if reduzido and _tw_caixa != null and _tw_caixa.is_valid():
		_tw_caixa.kill()
		_pintar_caixa(int(GameState.cash))


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
	# A consulta tem navegação própria também na pausa do fim da partida.
	# Não libera o Voltar de decisões obrigatórias que estejam por baixo.
	if is_instance_valid(_overlay_layer) and _overlay_layer.get_child_count() > 0:
		var consulta := _overlay_layer.get_child(_overlay_layer.get_child_count() - 1)
		if consulta.scene_file_path == ComoJogarScene.resource_path:
			if not consulta.is_queued_for_deletion():
				consulta.call("_fechar")
			return
	if GameState.phase != GameState.ESTADO_JOGANDO:
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
	# O QUE UM PERSONAGEM DIZ NUM PAINEL fica no histórico, e a conversa do
	# celular mostra-o no balão dele (`docs/decisoes/067`). Liga-se ANTES de o
	# chamador fazer `setup()`, que é onde a primeira fala sai.
	if painel.has_signal("falou"):
		painel.connect("falou", _ao_falar)
	return painel


# Grava sem mostrar: a fala já está na tela do painel, e passá-la também pela
# faixa seria dizê-la duas vezes.
func _ao_falar(personagem: String, texto: String, retrato: Texture2D) -> void:
	_fila.registrar(texto, personagem, GameState.turn, retrato)


func _on_upgrade_pressed() -> void:
	_abrir_painel(UpgradePanelScene)


func _gerenciar_servico(doca: int, id: int) -> void:
	if _overlay_layer.get_child_count() > 0:
		return
	if GameState.custos_do_cancelamento(doca, id).is_empty():
		return
	_abrir_painel(CancelarServicoScene).setup(doca, id)


# AS QUATRO PÍLULAS DO HUD SÃO TOCÁVEIS — item do primeiro playtest (02/09):
# "tocar num item do HUD abre detalhe". As quatro reagem à mesma pergunta —
# toque que SOLTA, botão esquerdo, a mesma razão do `BarcoFila.gd` (reagir no
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
#
# Na Fase 2 o mesmo toque abre a meta (`106`), sem tentar ler uma parcela.
func _on_meta_cartao_input(event: InputEvent) -> void:
	if _e_toque_de_soltar(event) and (GameState.tem_cobranca() or GameState.numero_da_fase == 2):
		if GameState.numero_da_fase == 2:
			_abrir_painel(PainelMetaScene).setup()
		else:
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
	menu.connect("pedir_ajustes", _abrir_ajustes)
	menu.connect("sair_para_inicio", _sair_para_inicio)
	menu.connect("pedir_como_jogar", _abrir_como_jogar)
	menu.connect("pedir_diagnostico", _abrir_diagnostico)


func _abrir_diagnostico() -> void:
	for filho in _overlay_layer.get_children():
		if filho.scene_file_path == DiagnosticoScene.resource_path and not filho.is_queued_for_deletion():
			return
	_abrir_painel(DiagnosticoScene)


func _abrir_ajustes() -> void:
	for filho in _overlay_layer.get_children():
		if filho.scene_file_path == PainelAjustesScene.resource_path and not filho.is_queued_for_deletion():
			return
	_abrir_painel(PainelAjustesScene).call("setup")


func _abrir_como_jogar() -> void:
	# A pausa fica na árvore. Pedidos repetidos não empilham consultas.
	for filho in _overlay_layer.get_children():
		if filho.scene_file_path == ComoJogarScene.resource_path and not filho.is_queued_for_deletion():
			return
	_abrir_painel(ComoJogarScene)


# «SALVAR E SAIR» — da pausa para a tela inicial (`066`).
#
# Grava mais uma vez por garantia (o jogo já grava a cada lance), DESARMA o
# gravador de partida — que é este script quem arma, e que continuaria a
# escrever no arquivo desta partida o que a tela inicial fizesse ao estado — e
# troca a cena. Os painéis abertos saem com ela: vivem no `_overlay_layer`,
# que é filho desta cena.
func _sair_para_inicio() -> void:
	GameState.save_game()
	Registro.desarmar()
	get_tree().change_scene_to_file(CENA_INICIAL)


# O MENU-CELULAR, e a porta de cada app dele.
#
# `connect` por NOME pela mesma razão do `ver_balanco` do menu de pausa: o
# `_abrir_painel` devolve um `Control`, e um `Control` não declara este sinal
# — a forma com ponto não compila.
#
# ⚠️ E O SINAL TRAZ A CENA, NÃO UM ID. Um id obrigaria o Main a ter a sua
# própria tabela de "qual id abre o quê" — duas listas que nada obriga a
# concordar, que é a fonte dupla que este projeto já pagou no `barco_medio` e
# no `.get(chave, omissão)`. Assim quem sabe o que cada app abre é a tabela do
# menu, num lugar só, e um app fechado não chega aqui: o tile dele nem é botão.
func _on_menu_pressed() -> void:
	var menu := _abrir_painel(PainelMenuScene)
	menu.connect("abrir_app", _on_menu_app_pedido)
	menu.call("setup")


func _on_menu_app_pedido(cena: String) -> void:
	var painel := _abrir_painel(load(cena) as PackedScene)
	# O APP DE MENSAGENS mostra o histórico da faixa, e o histórico mora aqui,
	# na fila — é a mesma chamada do toque na faixa (`_on_faixa_input`).
	if cena == PainelMensagensScene.resource_path:
		painel.call("setup", _fila.historico)


func _on_rival_offer_triggered(indice_fila: int) -> void:
	_refresh_fila()
	var abrir := func() -> Control:
		var painel := _abrir_painel(CounterOfferScene)
		painel.setup(indice_fila)
		return painel
	# Pagar também sorteia a chegada do próximo dia. A captura do balanço da
	# `087` encontrou o Arlindo por cima da resposta do Ribeiro na parcela 2.
	# Só nesse caminho ele espera resposta e boletim; a oferta habitual mantém
	# a prioridade que já tinha sobre os outros painéis.
	if is_instance_valid(vez.painel_da_vez) and vez.painel_da_vez.scene_file_path in [DebtPaymentScene.resource_path, DiarioFase2Scene.resource_path]:
		vez.na_vez(abrir)
	else:
		abrir.call()


func _on_debt_due(amount: int) -> void:
	vez.na_vez(func() -> Control:
		var painel := _abrir_painel(DebtPaymentScene)
		painel.setup(amount)
		return painel)


func _on_game_over(did_win: bool, reason: String) -> void:
	vez.na_vez(func() -> Control:
		var painel := _abrir_painel(EndGameScene)
		painel.setup(did_win, reason)
		return painel)


# A PASSAGEM (`104`): a página do diário que fechava a Fase 1 abre por cima do
# jogo, e a partida já está na Fase 2 por baixo dela. A reputação lê-se AQUI,
# no instante do sinal — que sai antes de a fase mudar —, e não quando o
# painel abrir: ele espera a vez atrás da resposta do Sr. Ribeiro e do
# boletim, e a essa hora a barra já recomeçou na escala da Fase 2.
func _on_fase_concluida(_numero: int, motivo: String) -> void:
	if _numero == 2:
		vez.na_vez(func() -> Control:
			var diario := _abrir_painel(DiarioFase2Scene)
			diario.setup()
			return diario)
		return
	var reputacao: float = GameState.reputation
	vez.na_vez(func() -> Control:
		var painel := _abrir_painel(EndGameScene)
		painel.setup(true, motivo, reputacao)
		return painel)
