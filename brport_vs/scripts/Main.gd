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

const WorkerScene := preload("res://scenes/worker/Worker.tscn")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")
const TelaNomesScene := preload("res://scenes/panels/TelaNomes.tscn")
const PainelDiarioScene := preload("res://scenes/panels/PainelDiario.tscn")
const PainelBoletimScene := preload("res://scenes/panels/PainelBoletim.tscn")


const COR_BOA := Color(0.102, 0.478, 0.251)
const COR_AVISO := Color(0.851, 0.467, 0.024)
const COR_RUIM := Color(0.761, 0.188, 0.188)
const COR_NEUTRA := Color(0.11, 0.204, 0.329)

@onready var _overlay_layer: CanvasLayer = $Overlay
@onready var _cash_label: Label = $HudBar/CaixaPilula/Linha/Caixa
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


func _ready() -> void:
	_advance_button.pressed.connect(_on_advance_pressed)
	_alocar_button.pressed.connect(_on_alocar_pressed)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	_pause_button.pressed.connect(_on_pause_pressed)

	_connect_game_state()
	_refresh_all()
	_animar_ancorados()
	_animar_coqueiros()
	_animar_boias()
	_animar_luzes()

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
		nomes.fechou.connect(func() -> void: _abrir_painel(PainelDiarioScene))
		return

	# Se o jogo carregou de um save já em rival_offer/debt_payment, reabre o painel certo.
	if GameState.phase == "rival_offer" and GameState.pending_rival_dock >= 0:
		_on_rival_offer_triggered(GameState.pending_rival_dock)
	elif GameState.phase == "debt_payment":
		_on_debt_due(GameState.PARCELA_AMOUNT)
	elif GameState.phase == "game_over":
		_on_game_over(GameState.won, GameState.end_reason)


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
func _animar_coqueiros() -> void:
	var cenario := $MapaWrap.get_node_or_null("Cenario")
	if cenario == null:
		return
	var duracoes := [2.6, 3.1, 2.9]
	var fases := [0.0, 1.1, 0.5]
	var i := 0
	for no in cenario.get_children():
		if not String(no.name).ends_with("Copa"):
			continue
		var amplitude := 0.035 if i % 2 == 0 else -0.035
		var dur: float = duracoes[i % duracoes.size()]
		var tw := no.create_tween().set_loops()
		if fases[i % fases.size()] > 0.0:
			tw.tween_interval(fases[i % fases.size()])
		tw.tween_property(no, "rotation", amplitude, dur).set_trans(Tween.TRANS_SINE)
		tw.tween_property(no, "rotation", -amplitude, dur).set_trans(Tween.TRANS_SINE)
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
	_alocar_button.disabled = not GameState.has_pending_assignment()
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
	else:
		_meta_label.text = "%s — já dá para pagar" % progresso


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
	_refresh_titulo_trabalhadores()


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
	_refresh_titulo_trabalhadores()


# O cartão do trabalhador tem 158px e não comporta a instrução; ela vive aqui,
# onde também pode mudar conforme o estado.
func _refresh_titulo_trabalhadores() -> void:
	if _selecionado >= 0:
		_workers_title.text = "Agora toque numa doca para enviar o #%d" % _selecionado
		_workers_title.add_theme_color_override("font_color", COR_AVISO)
	else:
		_workers_title.text = "Trabalhadores — toque ou arraste para uma doca"
		_workers_title.add_theme_color_override("font_color", Color(0.51, 0.6, 0.706))


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


func _on_pause_pressed() -> void:
	_abrir_painel(PauseMenuScene)


func _on_rival_offer_triggered(dock_index: int) -> void:
	_refresh_docks()
	_abrir_painel(CounterOfferScene).setup(dock_index)


func _on_debt_due(amount: int) -> void:
	_abrir_painel(DebtPaymentScene).setup(amount)


func _on_game_over(did_win: bool, reason: String) -> void:
	_abrir_painel(EndGameScene).setup(did_win, reason)
