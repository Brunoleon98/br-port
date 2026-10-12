extends RefCounted

# ============================================================
# BR Port VS — o TUTORIAL CURTO, que o Toninho guia (`docs/decisoes/100`, `101`)
#
# O recorte é o que o Bruno escolheu em 11/10: só o dia 1 de uma partida nova,
# dois verbos — atracar e avançar — e por cima do jogo. O Toninho fala na faixa
# de mensagem, como a Dona Cida, e a conversa do celular guarda a fala com a
# cara que ela pede; quem pulsa é a peça que se toca.
#
#   1. ATRACAR (calmo): há barco ao largo e berço livre. Os cartões «Ao largo»
#      JÁ pulsam sozinhos enquanto houver essa escolha (`BarcoFila._pulsar`,
#      `083`), e isso é até ao primeiro `atracou` — o tutorial não lhes
#      acrescenta pulso nenhum, que seriam dois relógios no mesmo cartão.
#   2. AVANÇAR (irónico): depois do primeiro barco atracado. O «AVANÇAR DIA»
#      pulsa, com o pulso dos cartões, até ao `turn_advanced`. Não se repete.
#   3. Se o dia virar ANTES de atracar, com barco ao largo que se podia
#      chamar, o tutorial acaba, e a fala é a SÉRIA: o que acontece ao barco
#      que espera demais. Sem barco nenhum para chamar, acaba calado.
#
# ⚠️ OVERLAY, NUNCA FASE (`interface.md`): nada disto vive no `GameState`, e o
# simulador fica intocado por construção. E SEM SAVE: o estado deriva-se — dia
# 1 e nenhum barco no píer —, e recarregar no dia 1 repete-o, o que a `100`
# aceitou.
#
# ⚠️ CADA PASSO SOME SE O JOGADOR O FIZER ANTES DE O LER. A fala entra na
# FILA da faixa, e pode esperar a vez atrás de outra (a contra-oferta do dia 1
# deixa um «barco fechado» à frente dela); quem atraca nesses segundos leria
# depois «toque no barco» com o barco já no píer. Feito o passo, a fala que
# ainda espera sai da fila (`FilaDeMensagens.retirar()`); a que está na tela
# fica, porque a fila nunca interrompe a leitura (`034`).
#
# ⚠️ NÃO É UM `class_name`, pela razão da narradora e do trânsito (`095`,
# `096`): lê o `GameState` pelo nome. O `Main` carrega-o por `preload`.
#
# ⚠️ E LIGA-SE AO `GameState` POR MÉTODO, nunca por lambda: um lambda ligado a
# um sinal segura vivo o `RefCounted` onde nasceu, e cada `Main` que as suítes
# soltam deixaria um tutorial a ouvir para sempre (`gdscript.md`, `096`).
# ============================================================

# O pulso é o dos cartões ao largo, lido de lá: a mesma peça a dizer «toque
# aqui» com o mesmo gesto, e uma cópia dos números seria a cor escrita duas
# vezes.
const BarcoFila := preload("res://scripts/BarcoFila.gd")

## O que ele acabou de dizer: o id e o texto, no instante em que a linha entra
## na fila. Quem ouve é a sonda da régua da faixa (`tools/sonda_mensagens.gd`),
## como no `falou` da narradora. O jogo não o liga a nada.
signal falou(id: String, linha: String)

## Em que passo está. Público para LER — o F22 do fumaça pergunta-o direto, e
## um nome errado grita; só este script o escreve.
##   ""          a abertura ainda está na tela, e ninguém chamou `comecar()`
##   "a_espera"  começou, e ainda não há barco que se possa chamar
##   "atracar"   o passo 1 (a fala entra no fim do frame)
##   "avancar"   o barco atracou: o passo 2, e o botão pulsa
##   "aviso"     o dia virou antes de atracar (a fala séria, no fim do frame)
##   "fim"       acabou — ou não era dia de tutorial
var passo := ""

var _fila: FilaDeMensagens
var _avancar: Button
var _pulso: Tween
# O texto que o passo corrente pôs na fila, para o tirar de lá se o jogador
# fizer o passo antes de o ler.
var _dito := ""


func _init(fila: FilaDeMensagens, avancar: Button) -> void:
	_fila = fila
	_avancar = avancar


## Chamado pelo `Main` quando a abertura acaba: o caderno fechado (nomes e
## diário) e o painel que a recuperação de fase abrir já na tela. Uma vez só.
##
## ⚠️ E É O `Main` QUEM SABE QUANDO, e não este objeto. Começar no `_ready()`
## poria o Toninho a falar por baixo da folha de rosto, para a faixa que o
## caderno tapa — a fala saía, e ninguém a lia.
func comecar() -> void:
	if passo != "":
		return
	if not _dia_de_tutorial():
		passo = "fim"
		return
	passo = "a_espera"
	GameState.phase_changed.connect(_ao_mudar_a_fase)
	GameState.atracou.connect(_ao_atracar)
	GameState.turn_advanced.connect(_ao_virar_o_dia)
	_ver_se_ha_barco.call_deferred()


# DIA 1, E NENHUM BARCO NO PÍER. Derivado do estado, e não um campo no save:
# a partida nova é a que está assim, e a que se recarrega assim também.
func _dia_de_tutorial() -> bool:
	if GameState.turn != 1:
		return false
	for doca in GameState.docks:
		if doca["boat"] != null:
			return false
	return true


# O PASSO 1 SÓ SE DIZ COM A ESCOLHA À FRENTE — berço livre e barco pronto ao
# largo (`atracagem_pendente()`) —, e lê-se no fim do frame, onde a linha é
# escrita, e não onde o sinal disparou (`narrativa.md`). Sem isto a fala
# mandaria tocar num barco que não está lá: o da contra-oferta ainda por
# responder, ou a partida que abre com o fundeadouro vazio (0,25³ das
# partidas novas, ~1,6%). Nesta última o dia 1 passa calado, e é aceite: não
# há o que ensinar a tocar.
func _ver_se_ha_barco() -> void:
	if passo != "a_espera":
		return
	if GameState.atracagem_pendente() == Vector2i.ZERO:
		return
	passo = "atracar"
	_dizer("atracar")


# A CONTRA-OFERTA DO DIA 1 FECHA AQUI: ganhe quem ganhar, a fase volta a
# «playing», e só então se sabe se ficou barco para chamar.
func _ao_mudar_a_fase(fase: String) -> void:
	if fase == "playing":
		_ver_se_ha_barco.call_deferred()


# O PRIMEIRO BARCO NO PÍER: o passo 1 está feito — lido ou não —, e o
# seguinte é o avançar. ⚠️ O PULSO LIGA-SE NO FIM DO FRAME, como a fala: uma
# suíte que corre inteira num frame só (o `teste_design`) e atraca barcos num
# `Main` montado não ganha um tween a mais na lista que ela própria vasculha.
func _ao_atracar(_doca: int, _barco: Dictionary, _ao_largo: Array) -> void:
	if passo != "a_espera" and passo != "atracar":
		return
	_feito()
	passo = "avancar"
	_dizer("avancar")
	_pulsar.call_deferred(true)


func _ao_virar_o_dia(_turno: int, _semana: int) -> void:
	match passo:
		"atracar":
			_feito()
			passo = "aviso"
			_dizer("dia_virou")
		"a_espera":
			# ⚠️ O DIA PODE VIRAR ANTES DE O PASSO 1 SER PEDIDO: ele espera o fim
			# do frame, e quem vira o dia no MESMO frame em que o `Main` monta
			# (a bateria de capturas joga assim) apanhava-o aqui e ele calava-se
			# — a fala séria dependia do frame, e não do estado. O que decide é
			# o barco: se o dia virou com um que se podia chamar, é o aviso. ⚠️
			# LIDO NO SINAL, e de propósito: o `turn_advanced` sai antes do
			# sorteio do dia 2, e agora os barcos ao largo são só os que
			# esperaram o dia 1 (`narrativa.md`, a regra do instante do
			# predicado, do lado de cá).
			if GameState.barcos_ao_largo() > 0:
				passo = "aviso"
				_dizer("dia_virou")
			else:
				_acabar()
		"avancar":
			_feito()
			_acabar()
		_:
			# O "aviso" ainda por dizer quando dois dias viram no mesmo frame
			# (a bateria de capturas avança assim): o dia 3 já não é o que ele
			# comentava.
			_acabar()


# A fala de um passo, no fim do frame. Leva o passo em que foi pedida e só sai
# se ele ainda for o mesmo: um passo feito no mesmo frame não deixa fala atrás.
func _dizer(id: String) -> void:
	_dizer_agora.call_deferred(id, passo)


func _dizer_agora(id: String, no_passo: String) -> void:
	if passo != no_passo:
		return
	var linha := Narrativa.toninho(id)
	if linha != "":
		_dito = linha
		falou.emit(id, linha)
		_fila.enfileirar(linha, "", "toninho", GameState.turn, "",
			Narrativa.retrato("toninho", id))
	if no_passo == "aviso":
		_acabar()


# O JOGADOR FEZ O PASSO: a fala dele sai da fila se ainda esperava a vez.
func _feito() -> void:
	if _dito != "":
		_fila.retirar(_dito)
	_dito = ""


func _pulsar(ligado: bool) -> void:
	if _pulso != null and _pulso.is_valid():
		_pulso.kill()
	_pulso = null
	if not is_instance_valid(_avancar):
		return
	if not ligado or passo != "avancar":
		_avancar.modulate = Color.WHITE
		return
	_pulso = _avancar.create_tween().set_loops()
	_pulso.tween_property(_avancar, "modulate", BarcoFila.PULSO_COR,
		BarcoFila.PULSO_SEG).set_trans(Tween.TRANS_SINE)
	_pulso.tween_property(_avancar, "modulate", Color.WHITE,
		BarcoFila.PULSO_SEG).set_trans(Tween.TRANS_SINE)


# Acabou: o botão volta ao repouso e o tutorial deixa de ouvir o jogo — a
# partida continua por semanas, e um ouvinte que já não tem nada a dizer é
# uma chamada a mais em cada virada.
func _acabar() -> void:
	passo = "fim"
	_pulsar(false)
	if GameState.phase_changed.is_connected(_ao_mudar_a_fase):
		GameState.phase_changed.disconnect(_ao_mudar_a_fase)
	if GameState.atracou.is_connected(_ao_atracar):
		GameState.atracou.disconnect(_ao_atracar)
	if GameState.turn_advanced.is_connected(_ao_virar_o_dia):
		GameState.turn_advanced.disconnect(_ao_virar_o_dia)
