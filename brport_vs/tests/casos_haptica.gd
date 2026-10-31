extends RefCounted

# ============================================================
# D54 — a háptica: o toque que vibra, e só ele (`docs/decisoes/149`)
#
# Medido antes de escrever uma linha (`144`, e outra vez na `149`): nenhuma
# chamada de vibração no jogo e nenhuma permissão `VIBRATE` no preset. O
# desenho é o da `144`: um ponto único, o `Haptica`, recebe o MOMENTO —
# atracar ~20 ms, obra pronta e parcela paga ~40 ms — e conta o que pediu ao
# aparelho. O contêiner não vibra; a contagem é o que se prova aqui.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 OS TRÊS MOMENTOS, PELA PORTA DO JOGADOR, UM PEDIDO CADA: o cartão ao
#      largo tocado pelo `push_input`; o «Avançar dia» premido na véspera do
#      fim de CADA obra do catálogo; o «Pagar» do Sr. Ribeiro no vencimento e
#      o «Quitar agora» antes dele, escolhidos pelo que dizem. O esperado é o
#      dicionário inteiro: um momento a mais, ou dois pedidos, reprovam;
#   §2 NADA ONDE NÃO HOUVE TOQUE OU CONQUISTA: a virada simples (com barco a
#      pagar), a de uma obra que ainda não acaba, a obra que a bancada
#      conclui, a que o `advance_turn()` direto conclui (o simulador), o
#      atracar e o `pay_debt()` pelo `GameState` direto, o cartão tocado com o
#      berço cheio, o «Não consigo pagar» e a segunda chance aceite (com o
#      «Pagar» desligado, que é a porta que segura a cobrança sem dinheiro);
#   §3 A PREFERÊNCIA DESLIGADA cala os três momentos pela mesma porta, e
#      religada volta a contar — o controlo de que a régua vê um pedido;
#   §4 O MOVIMENTO REDUZIDO NÃO CALA: é outra preferência;
#   §5 OS AJUSTES: a linha «Vibração» mostra a preferência (ligada por
#      omissão), o toque aplica-a já e grava-a fora do save, lida de novo do
#      disco; um valor de outro tipo no arquivo mantém a omissão; e a escrita
#      que falha diz que não lembrou, com a escolha a valer na sessão;
#   §6 A DURAÇÃO: o atracar é o toque curto, e as duas conquistas iguais e
#      mais longas.
#
# ⚠️ FICA DE FORA, e é do telefone: se o aparelho vibra, e se a duração se
# sente. O `F5` do `teste_fumaca` lê a permissão no preset, o `F24` o ponto
# único, e o CI procura a permissão no manifesto do APK.
#
# Bloco num arquivo próprio, pela regra do `AGENTS.md` §2.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261031

var falhas := 0
var completo := false

var _gs: Node
var _arvore: SceneTree
var _pref: Object
var _bancada: Script
var _haptica: Script


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D54: %s" % nome)
	else:
		print("  FALHA D54: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree) -> void:
	_gs = gs
	_arvore = arvore
	_bancada = load("res://tools/estado_da_bancada.gd")
	_haptica = load("res://scripts/Haptica.gd")
	_pref = load("res://scripts/PreferenciasDeApresentacao.gd").atual()
	var vibrar_antes: bool = _pref.vibrar
	var reduzido_antes: bool = _pref.reduzir_movimento
	_pref.vibrar = true
	_pref.reduzir_movimento = false
	conferir("o atracar correu até ao fim", _o_atracar() == true)
	conferir("as obras do catálogo correram até ao fim", _as_obras() == true)
	conferir("as viradas sem conquista correram até ao fim", _sem_conquista() == true)
	conferir("a parcela no vencimento correu até ao fim", _a_parcela_no_vencimento() == true)
	conferir("a parcela antes do prazo correu até ao fim", _a_parcela_antes() == true)
	conferir("a segunda chance correu até ao fim", _a_segunda_chance() == true)
	conferir("a preferência desligada correu até ao fim", _desligada() == true)
	conferir("o movimento reduzido correu até ao fim", _o_reduzido() == true)
	conferir("os Ajustes correram até ao fim", _os_ajustes() == true)
	conferir("a duração correu até ao fim", _a_duracao() == true)
	_pref.vibrar = vibrar_antes
	_pref.reduzir_movimento = reduzido_antes
	_haptica.zerar()
	_gs.clear_save()
	completo = true


# ── a montagem ──────────────────────────────────────────────────────────────

func _partida() -> void:
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	_gs.definir_nomes(_gs.NOME_PORTO_PADRAO, "")
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)
	_haptica.zerar()


func _requisitos(id: String) -> void:
	var r: String = String(_gs.ESTRUTURAS[id]["requer"])
	if r != "":
		_requisitos(r)
		_bancada.instalar(_gs, r)


## Partida com a obra `id` a acabar daqui a `dias` dias, e a cena aberta.
func _abrir_com_obra(id: String, dias: int = 1) -> Control:
	_partida()
	_requisitos(id)
	_gs.cash = 5000000
	_gs.obra_em_andamento = {"id": id, "inicio": _gs.turn - 1, "conclusao": _gs.turn + dias}
	var tela := _abrir_cena()
	_haptica.zerar()
	return tela


func _abrir_cena() -> Control:
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	# Os contentores arrumam-se no frame seguinte, e esta suíte não deixa
	# passar nenhum: sem a ordem dada à mão o toque cai fora do botão (`148`).
	(tela.get_node("AcoesTurno") as Container).notification(Container.NOTIFICATION_SORT_CHILDREN)
	(tela.get_node("Fila") as Container).notification(Container.NOTIFICATION_SORT_CHILDREN)
	return tela


func _fechar(no: Node) -> void:
	if no.get_parent() != null:
		no.get_parent().remove_child(no)
	no.free()


## Premir e soltar no centro de `no` pelo `push_input`, em coordenada da cena
## — o toque do telefone, que o motor entrega como rato.
func _tocar(no: Control) -> void:
	var onde := no.get_global_rect().get_center()
	var mexe := InputEventMouseMotion.new()
	mexe.position = onde
	mexe.global_position = onde
	_arvore.root.push_input(mexe, true)
	for premido in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.position = onde
		ev.global_position = onde
		ev.pressed = premido
		_arvore.root.push_input(ev, true)


func _avancar(tela: Control) -> void:
	_tocar(tela.get_node("AcoesTurno/Avancar") as Control)


## O botão de `painel` cujo texto começa por `texto` — pelo que ele diz, e
## não pelo nome do nó (`138`).
func _botao(painel: Node, texto: String) -> Button:
	if painel is Button and (painel as Button).text.begins_with(texto) \
			and not painel.is_queued_for_deletion():
		return painel
	for filho in painel.get_children():
		var b := _botao(filho, texto)
		if b != null:
			return b
	return null


func _pedidos() -> Dictionary:
	return (_haptica.pedidos as Dictionary).duplicate()


## Até ao vencimento da primeira parcela, pelo `advance_turn()`, com teto.
func _ate_o_vencimento(dinheiro: int) -> bool:
	_partida()
	_gs.turn = _gs.dia_da_parcela(0) - 1
	for _volta in range(4):
		_gs.cash = dinheiro
		_gs.advance_turn()
		if _gs.phase == "rival_offer":
			_gs.resolve_rival_offer(true)
		if _gs.phase == "debt_payment":
			break
	_gs.cash = dinheiro
	_haptica.zerar()
	return _gs.phase == "debt_payment"


func _painel_da_cobranca() -> Control:
	var painel: Control = load("res://scenes/panels/DebtPaymentPanel.tscn").instantiate()
	_arvore.root.add_child(painel)
	painel.setup(_gs.principal_da_parcela())
	return painel


# §1 e §2 ────────────────────────────────────────────────────────────────────

func _o_atracar() -> bool:
	_partida()
	# Dois barcos e um berço: o segundo toque encontra o berço cheio.
	_gs.fila = [_gs._make_boat(), _gs._make_boat()]
	var tela := _abrir_cena()
	tela._concluir_virada()
	_haptica.zerar()
	var cartao := tela.get_node("Fila").get_child(0) as Control
	conferir("§1 o lugar 1 tem barco e o berço 1 está livre",
		cartao.barco() != null and _gs.berco_livre() == 0)
	_tocar(cartao)
	conferir("§1 o cartão ao largo tocado atraca", _gs.docks[0]["boat"] != null and _gs.fila.size() == 1)
	conferir("§1 o cartão tocado pede um atracar, e só ele (%s)" % _pedidos(), _pedidos() == {"atracar": 1})
	_haptica.zerar()
	(tela.get_node("Fila") as Container).notification(Container.NOTIFICATION_SORT_CHILDREN)
	var outro := tela.get_node("Fila").get_child(0) as Control
	conferir("§2 o segundo cartão tem barco e não há berço livre",
		outro.barco() != null and _gs.berco_livre() < 0)
	_tocar(outro)
	conferir("§2 o toque com o berço cheio não atraca", _gs.fila.size() == 1)
	conferir("§2 o toque com o berço cheio não vibra (%s)" % _pedidos(), _pedidos().is_empty())
	_fechar(tela)
	return true


func _as_obras() -> bool:
	var ids: Array = _gs.ESTRUTURAS.keys()
	conferir("§1 o catálogo tem estruturas para percorrer (%d)" % ids.size(), ids.size() >= 2)
	for id in ids:
		conferir("§1 %s correu até ao fim" % id, _uma_obra(String(id)) == true)
	return true


func _uma_obra(id: String) -> bool:
	var tela := _abrir_com_obra(id)
	_avancar(tela)
	conferir("§1 %s: o «Avançar dia» premido conclui a obra" % id,
		_gs.tem_estrutura(id) and _gs.obra_em_andamento.is_empty())
	conferir("§1 %s: e pede uma obra pronta, e só ela (%s)" % [id, _pedidos()],
		_pedidos() == {"obra_pronta": 1})
	_fechar(tela)
	return true


func _sem_conquista() -> bool:
	# A virada simples, com barco a pagar: o «+R$» sobe, e o dedo não sente.
	_partida()
	_gs.fila = [_gs._make_boat()]
	var tela := _abrir_cena()
	conferir("§2 o atracar pelo GameState direto atraca", _gs.atracar(0))
	conferir("§2 o atracar pelo GameState direto não vibra (%s)" % _pedidos(), _pedidos().is_empty())
	var caixa_antes: int = int(_gs.cash)
	var dia_antes: int = int(_gs.turn)
	_avancar(tela)
	conferir("§2 a virada simples virou o dia", int(_gs.turn) == dia_antes + 1)
	conferir("§2 a virada simples não vibra (%s, caixa %d → %d)" % [_pedidos(), caixa_antes, _gs.cash],
		_pedidos().is_empty())
	_fechar(tela)
	# A obra que ainda não acaba nesta virada.
	tela = _abrir_com_obra("armazem", 2)
	_avancar(tela)
	conferir("§2 a obra a meio continua a meio", not _gs.tem_estrutura("armazem"))
	conferir("§2 a virada da obra a meio não vibra (%s)" % _pedidos(), _pedidos().is_empty())
	_fechar(tela)
	# A obra que a bancada conclui, com a cena aberta a ouvir o sinal.
	tela = _abrir_com_obra("armazem", 2)
	_gs.obra_em_andamento = {}
	_bancada.instalar(_gs, "armazem")
	conferir("§2 a obra concluída pela bancada não vibra (%s)" % _pedidos(),
		_gs.tem_estrutura("armazem") and _pedidos().is_empty())
	_fechar(tela)
	# E a que o `advance_turn()` direto conclui — o caminho do simulador.
	tela = _abrir_com_obra("pier_2")
	_gs.advance_turn()
	conferir("§2 a obra concluída pelo advance_turn() direto não vibra (%s)" % _pedidos(),
		_gs.tem_estrutura("pier_2") and _pedidos().is_empty())
	_fechar(tela)
	# O `pay_debt()` direto.
	if _ate_o_vencimento(5000000):
		var quitadas: int = int(_gs.parcelas_quitadas)
		_gs.pay_debt()
		conferir("§2 o pay_debt() direto paga e não vibra (%s)" % _pedidos(),
			int(_gs.parcelas_quitadas) == quitadas + 1 and _pedidos().is_empty())
	else:
		conferir("§2 a montagem chegou ao vencimento", false, _gs.phase)
	return true


func _a_parcela_no_vencimento() -> bool:
	if not _ate_o_vencimento(5000000):
		conferir("§1 a montagem chegou ao vencimento", false, _gs.phase)
		return true
	var painel := _painel_da_cobranca()
	var pagar := _botao(painel, "Pagar ")
	conferir("§1 a cobrança tem o «Pagar» ligado", pagar != null and not pagar.disabled)
	var quitadas: int = int(_gs.parcelas_quitadas)
	pagar.pressed.emit()
	conferir("§1 o «Pagar» quita a parcela", int(_gs.parcelas_quitadas) == quitadas + 1)
	conferir("§1 o «Pagar» pede uma parcela paga, e só ela (%s)" % _pedidos(), _pedidos() == {"parcela_paga": 1})
	_fechar(painel)
	return true


func _a_parcela_antes() -> bool:
	_partida()
	_gs.cash = 5000000
	var painel: Control = load("res://scenes/panels/PainelParcela.tscn").instantiate()
	_arvore.root.add_child(painel)
	painel.setup()
	var quitar := _botao(painel, "Quitar agora")
	conferir("§1 a parcela tem o «Quitar agora»", quitar != null)
	if quitar == null:
		_fechar(painel)
		return true
	quitar.pressed.emit()
	conferir("§1 o «Quitar agora» quita a parcela", bool(_gs.parcela_paid) and int(_gs.parcelas_quitadas) == 1)
	conferir("§1 o «Quitar agora» pede uma parcela paga, e só ela (%s)" % _pedidos(), _pedidos() == {"parcela_paga": 1})
	_fechar(painel)
	return true


func _a_segunda_chance() -> bool:
	if not _ate_o_vencimento(0):
		conferir("§2 a montagem chegou ao vencimento sem dinheiro", false, _gs.phase)
		return true
	var painel := _painel_da_cobranca()
	# Sem dinheiro o «Pagar» nasce desligado, e o toque nele não emite nada:
	# o painel inteiro confia nisso (a resposta «pagou» não confere), e o
	# pedido de vibração também.
	var pagar := _botao(painel, "Pagar ")
	conferir("§2 sem dinheiro, o «Pagar» nasce desligado", pagar != null and pagar.disabled)
	var nao := _botao(painel, "Não consigo pagar")
	conferir("§2 sem dinheiro, a cobrança oferece «Não consigo pagar»", nao != null)
	if nao == null:
		_fechar(painel)
		return true
	nao.pressed.emit()
	conferir("§2 o «Não consigo pagar» não vibra (%s)" % _pedidos(), _pedidos().is_empty())
	var aceitar := _botao(painel, "Aceitar o empréstimo")
	conferir("§2 o Sr. Ribeiro oferece a segunda chance", aceitar != null)
	if aceitar == null:
		_fechar(painel)
		return true
	var quitadas: int = int(_gs.parcelas_quitadas)
	aceitar.pressed.emit()
	conferir("§2 a segunda chance aceite baixa a parcela", int(_gs.parcelas_quitadas) == quitadas + 1)
	conferir("§2 a segunda chance não vibra: quem pagou foi o banco (%s)" % _pedidos(), _pedidos().is_empty())
	_fechar(painel)
	return true


# §3 e §4 ────────────────────────────────────────────────────────────────────

## Os três momentos pela porta do jogador, numa volta só; devolve o que se
## pediu em cada um.
func _os_tres() -> Array:
	var r: Array = []
	_partida()
	_gs.fila = [_gs._make_boat()]
	var tela := _abrir_cena()
	tela._concluir_virada()
	_haptica.zerar()
	_tocar(tela.get_node("Fila").get_child(0) as Control)
	r.append(["atracar", _gs.docks[0]["boat"] != null, _pedidos()])
	_fechar(tela)
	tela = _abrir_com_obra("armazem")
	_avancar(tela)
	r.append(["obra_pronta", _gs.tem_estrutura("armazem"), _pedidos()])
	_fechar(tela)
	if _ate_o_vencimento(5000000):
		var painel := _painel_da_cobranca()
		var quitadas: int = int(_gs.parcelas_quitadas)
		_botao(painel, "Pagar ").pressed.emit()
		r.append(["parcela_paga", int(_gs.parcelas_quitadas) == quitadas + 1, _pedidos()])
		_fechar(painel)
	else:
		r.append(["parcela_paga", false, {}])
	return r


func _desligada() -> bool:
	_pref.vibrar = false
	for volta in _os_tres():
		conferir("§3 desligada, %s aconteceu" % volta[0], volta[1])
		conferir("§3 desligada, %s não vibra (%s)" % [volta[0], volta[2]], (volta[2] as Dictionary).is_empty())
	_pref.vibrar = true
	for volta in _os_tres():
		conferir("§3 religada, %s volta a vibrar (%s)" % [volta[0], volta[2]],
			volta[1] and volta[2] == {volta[0]: 1})
	return true


func _o_reduzido() -> bool:
	_pref.reduzir_movimento = true
	var tela := _abrir_com_obra("armazem")
	_avancar(tela)
	conferir("§4 com o movimento reduzido, a obra pronta vibra na mesma (%s)" % _pedidos(),
		_gs.tem_estrutura("armazem") and _pedidos() == {"obra_pronta": 1})
	_fechar(tela)
	_pref.reduzir_movimento = false
	return true


# §5 ─────────────────────────────────────────────────────────────────────────

func _os_ajustes() -> bool:
	var classe: Script = load("res://scripts/PreferenciasDeApresentacao.gd")
	var caminho: String = _pref.caminho
	var copia := ""
	if FileAccess.file_exists(caminho):
		copia = FileAccess.get_file_as_string(caminho)
	DirAccess.remove_absolute(caminho)
	conferir("§5 sem arquivo, a vibração nasce ligada", classe.new().vibrar == true)
	var cfg := ConfigFile.new()
	cfg.set_value("apresentacao", "vibrar", "false")
	cfg.save(caminho)
	conferir("§5 um valor de outro tipo no arquivo mantém a omissão", classe.new().vibrar == true)
	DirAccess.remove_absolute(caminho)

	var painel: Control = load("res://scenes/panels/PainelAjustes.tscn").instantiate()
	_arvore.root.add_child(painel)
	painel.setup()
	var linha := _botao(painel, "Vibração") as CheckButton
	conferir("§5 os Ajustes têm a linha «Vibração»", linha != null)
	if linha == null:
		_fechar(painel)
		return true
	conferir("§5 e ela mostra a preferência, ligada", linha.button_pressed == true)
	linha.button_pressed = false
	conferir("§5 o toque desliga já", _pref.vibrar == false)
	conferir("§5 e grava fora do save, lido de novo do disco", classe.new().vibrar == false)
	_haptica.zerar()
	_haptica.pedir("atracar")
	conferir("§5 e o ponto único deixa de pedir (%s)" % _pedidos(), _pedidos().is_empty())
	linha.button_pressed = true
	conferir("§5 o toque religa e grava", _pref.vibrar == true and classe.new().vibrar == true)
	_pref.caminho = caminho.get_base_dir()   # um diretório: a escrita falha
	linha.button_pressed = false
	conferir("§5 a escrita que falha diz que não lembrou, e a escolha vale na sessão",
		painel._aviso_preferencia.visible and _pref.vibrar == false)
	_pref.caminho = caminho
	_pref.vibrar = true
	_fechar(painel)
	DirAccess.remove_absolute(caminho)
	if copia != "":
		var f := FileAccess.open(caminho, FileAccess.WRITE)
		f.store_string(copia)
		f.close()
	return true


# §6 ─────────────────────────────────────────────────────────────────────────

func _a_duracao() -> bool:
	var ms: Dictionary = _haptica.DURACAO_MS
	conferir("§6 os três momentos têm duração (%s)" % ms,
		ms.keys().size() == 3 and ms.has("atracar") and ms.has("obra_pronta") and ms.has("parcela_paga"))
	conferir("§6 o atracar é o toque curto, e as conquistas o dobro (%s)" % ms,
		int(ms["atracar"]) >= 10 and int(ms["obra_pronta"]) == int(ms["parcela_paga"])
		and int(ms["obra_pronta"]) >= 2 * int(ms["atracar"]))
	return true
