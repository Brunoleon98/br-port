extends Node

# ============================================================
# BR Port VS — Audio (autoload singleton)
#
# O ponto único que toca som. Mesmo espírito do `Icones.gd`: antes dele, cada
# rótulo carregava o emoji embutido e trocar um ícone era caçar string por
# string. Um `AudioStreamPlayer` espalhado por cena teria o mesmo destino —
# ninguém sabe o que está tocando nem consegue baixar o volume de tudo.
#
# O QUE ESTE ARQUIVO RESOLVE E NÃO É ÓBVIO
#
# 1. **Empilhamento.** Avançar o dia emite `turn_advanced`, `boats_spawned`,
#    `cash_changed` e `message` NO MESMO FRAME. Sem regra, isso é quatro sons
#    ao mesmo tempo — que não soa a quatro coisas, soa a estouro. Aqui os
#    pedidos de um frame entram numa fila e só o de maior PRIORIDADE toca.
#
# 2. **Repetição.** O mesmo som disparado vinte vezes seguidas vira tique. Cada
#    som tem uma espera mínima própria, e o clique ainda leva variação de
#    altura de ±5% (pedida no guia de áudio) para não soar sempre idêntico.
#
# 3. **Botão.** São 18 pontos de `pressed` no jogo, e o painel de construção
#    ainda cria botões por código. Ligar um a um seria esquecer algum. Este nó
#    escuta `node_added` da árvore e liga o clique sozinho em todo BaseButton
#    que nascer, venha de cena ou de script.
#
# 4. **Volume.** Vive em `user://audio.cfg`, e NÃO no save do jogo: apagar a
#    partida não pode devolver o volume ao máximo no meio da noite.
#
# ⚠️ NINGUÉM QUE ESCREVEU ISTO OUVIU ESTES SONS. O contêiner de
# desenvolvimento não tem placa de som (ver docs/BLOCO6_BRIEFING_AUDIO.md §2).
# O que se afirma aqui é o que `tests/teste_audio.gd` mede: o arquivo carrega,
# o bus existe, o sinal certo chama o método certo, a espera mínima segura a
# repetição. Se soa bem, quem julga é quem tem placa de som.
# ============================================================

const PASTA := "res://audio/sfx/"

# id -> {arquivo, prioridade, espera}
#
# PRIORIDADE decide quem sobrevive quando dois pedidos caem no mesmo frame.
# A escala é de intenção, não de volume: o fim de jogo cala tudo; um aviso vale
# mais que uma moeda; o clique é o que mais cede, porque é o que mais toca.
#
# ESPERA é o tempo mínimo entre duas repetições DO MESMO som, em segundos.
const SONS := {
	"click":   {"arquivo": "sfx_ui_click",    "prioridade": 10, "espera": 0.04},
	"bom":     {"arquivo": "sfx_ui_success",  "prioridade": 40, "espera": 0.12},
	"aviso":   {"arquivo": "sfx_ui_warn",     "prioridade": 50, "espera": 0.12},
	"ruim":    {"arquivo": "sfx_ui_error",    "prioridade": 60, "espera": 0.15},
	"moeda":   {"arquivo": "sfx_moeda",       "prioridade": 30, "espera": 0.25},
	"alerta":  {"arquivo": "sfx_alerta",      "prioridade": 80, "espera": 0.30},
	"navio":   {"arquivo": "sfx_navio_chega", "prioridade": 35, "espera": 0.60},
	"obra":    {"arquivo": "sfx_construir",   "prioridade": 70, "espera": 0.20},
	"vitoria": {"arquivo": "sfx_vitoria",     "prioridade": 99, "espera": 1.00},
	"derrota": {"arquivo": "sfx_derrota",     "prioridade": 99, "espera": 1.00},
}

# Quantos podem soar ao mesmo tempo. Com um pedido por frame, três chegam de
# sobra — o quarto só faria falta se um som durasse mais que três frames de
# distância, e o mais longo aqui tem 1,1 s contra a espera de 0,6 s do navio.
const VOZES := 3

# Silêncio na abertura. `GameState._ready()` já sorteia a mão inicial de barcos
# e pode abrir oferta do rival antes de a tela existir; sem esta janela o jogo
# começava com um alerta tocando sozinho.
const SILENCIO_INICIAL := 0.5

const CONFIG := "user://audio.cfg"

var _streams := {}
var _vozes: Array[AudioStreamPlayer] = []
var _ultima_vez := {}
var _pedido := ""
var _pedido_prioridade := -1
var _nascimento := 0.0
var _botoes_ligados := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # som continua com o jogo pausado
	_nascimento = _agora()

	for id in SONS:
		var caminho: String = PASTA + String(SONS[id]["arquivo"]) + ".wav"
		var s = load(caminho)
		if s == null:
			push_error("Audio: nao consegui carregar %s" % caminho)
			continue
		_streams[id] = s

	for i in range(VOZES):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_vozes.append(p)

	_carregar_config()
	_ligar_game_state()
	get_tree().node_added.connect(_ao_nascer_no)
	# Os botões que já estão na árvore quando este nó entra não passam por
	# `node_added` — o autoload nasce antes da cena principal, mas o inverso
	# vale para quem instancia a cena na mão (a suíte de testes faz isso).
	_varrer_botoes(get_tree().root)


func _agora() -> float:
	return Time.get_ticks_msec() / 1000.0


# ── a API ──
# Pedir NÃO é tocar. O pedido entra numa disputa que se resolve no fim do
# frame, e é isso que impede quatro sinais simultâneos de virarem quatro sons.
func tocar(id: String) -> void:
	if not SONS.has(id):
		push_error("Audio: som desconhecido %s" % id)
		return
	if _agora() - _nascimento < SILENCIO_INICIAL:
		return
	var prioridade: int = int(SONS[id]["prioridade"])
	if prioridade > _pedido_prioridade:
		_pedido = id
		_pedido_prioridade = prioridade


func _process(_delta: float) -> void:
	if _pedido == "":
		return
	var id := _pedido
	_pedido = ""
	_pedido_prioridade = -1

	var agora := _agora()
	if agora - float(_ultima_vez.get(id, -999.0)) < float(SONS[id]["espera"]):
		return
	if not _streams.has(id):
		return

	var voz := _voz_livre()
	voz.stream = _streams[id]
	# ±5% de altura no clique: é o que o guia pede para o som mais repetido do
	# jogo não virar tique. Nos outros a altura fica fixa — variar um apito de
	# navio faz o mesmo navio parecer outro.
	voz.pitch_scale = randf_range(0.95, 1.05) if id == "click" else 1.0
	voz.play()
	_ultima_vez[id] = agora


func _voz_livre() -> AudioStreamPlayer:
	for v in _vozes:
		if not v.playing:
			return v
	return _vozes[0]        # todas ocupadas: a mais antiga cede


# ── volume ──
# Guardado em decibéis no bus e em 0..1 na configuração, porque slider é
# linear e ouvido não é. `linear_to_db(0)` é -inf, daí o caso à parte.
func volume(bus: String) -> float:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		return 1.0
	if AudioServer.is_bus_mute(i):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(i))


func definir_volume(bus: String, valor: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i < 0:
		return
	valor = clampf(valor, 0.0, 1.0)
	AudioServer.set_bus_mute(i, valor <= 0.001)
	if valor > 0.001:
		AudioServer.set_bus_volume_db(i, linear_to_db(valor))
	_gravar_config()


func _carregar_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG) != OK:
		return
	for bus in ["Musica", "SFX"]:
		definir_volume(bus, float(cfg.get_value("volume", bus, 1.0)))


func _gravar_config() -> void:
	var cfg := ConfigFile.new()
	for bus in ["Musica", "SFX"]:
		cfg.set_value("volume", bus, volume(bus))
	cfg.save(CONFIG)


# ── as ligações ──
# Um ouvinte de `message` cobre 13 pontos da interface. Foi o achado do
# levantamento de áudio: o sinal já vem classificado em good/warn/bad, então
# não é preciso espalhar `tocar()` por sete scripts para dar retorno sonoro a
# quase tudo o que o jogo diz.
func _ligar_game_state() -> void:
	GameState.message.connect(_ao_mensagem)
	GameState.boats_spawned.connect(func(): tocar("navio"))
	GameState.cash_changed.connect(_ao_caixa)
	GameState.estrutura_comprada.connect(func(_id): tocar("obra"))
	GameState.rival_offer_triggered.connect(func(_d): tocar("alerta"))
	GameState.debt_due.connect(func(_v): tocar("alerta"))
	GameState.game_over.connect(func(ganhou, _r): tocar("vitoria" if ganhou else "derrota"))


func _ao_mensagem(_texto: String, tipo: String) -> void:
	match tipo:
		"good": tocar("bom")
		"warn": tocar("aviso")
		"bad":  tocar("ruim")
		_:      tocar("click")


var _caixa_anterior: int = -1


# Moeda SÓ QUANDO SOBE. Tocar dinheiro ao gastar é o erro clássico: o jogador
# ouve recompensa no momento em que perdeu caixa e o som passa a mentir.
func _ao_caixa(novo: int) -> void:
	var antes := _caixa_anterior
	_caixa_anterior = novo
	if antes >= 0 and novo > antes:
		tocar("moeda")


# ── clique em botão, sem tocar em botão nenhum ──
func _ao_nascer_no(no: Node) -> void:
	if no is BaseButton:
		_ligar_botao(no)


func _varrer_botoes(raiz: Node) -> void:
	if raiz is BaseButton:
		_ligar_botao(raiz)
	for filho in raiz.get_children():
		_varrer_botoes(filho)


func _ligar_botao(b: BaseButton) -> void:
	var id := b.get_instance_id()
	if _botoes_ligados.has(id):
		return
	_botoes_ligados[id] = true
	b.pressed.connect(func(): tocar("click"))
	# O dicionário cresceria para sempre numa partida longa — o painel de
	# construção recria os seus botões a cada compra.
	b.tree_exiting.connect(func(): _botoes_ligados.erase(id))
