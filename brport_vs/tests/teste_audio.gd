extends SceneTree

# ============================================================
# BR Port VS — TESTE DE ÁUDIO
#
# Existe por uma razão específica e incômoda: **o contêiner de desenvolvimento
# não tem placa de som.** O Godot cai no driver mudo e nenhuma sessão consegue
# ouvir o que produz (docs/BLOCO6_BRIEFING_AUDIO.md §2).
#
# Em arte havia saída — `capturar_tela.gd` tira a foto e alguém olha. Em áudio
# não há equivalente. O que sobra é separar com rigor as duas colunas:
#
#   VERIFICÁVEL AQUI            SÓ QUEM TEM PLACA DE SOM JULGA
#   o arquivo carrega            se soa bem
#   o bus existe e a rota bate   se está alto demais
#   o sinal certo chama o som    se cansa depois de vinte turnos
#   duração, taxa, canais        se a mixagem equilibra
#   a espera mínima segura       se combina com o jogo
#   não estoura quatro de uma vez
#
# Este arquivo cobre a coluna da esquerda inteira. A da direita não é dele, e
# nenhum commit deve afirmar nada dela.
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tests/teste_audio.gd
# ============================================================

const TAXA_ESPERADA := 32000

var _falhas := 0
var _feito := false

# O identificador global de um autoload NÃO existe num script de `--script`:
# nem `Audio` nem `GameState` compilam aqui. É por isso que a suíte de lógica
# também busca o nó pela raiz. Guardar numa variável evita repetir o get_node
# em seis funções — e o nome curto evita sombrear o autoload de verdade.
var A: Node


func _confere(rotulo: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  %s" % rotulo)
	else:
		print("  FALHA %s%s" % [rotulo, ("  — " + detalhe) if detalhe != "" else ""])
		_falhas += 1


func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true
	_rodar()
	return true


func _rodar() -> void:
	A = root.get_node_or_null("Audio")
	if A == null:
		print("FALHA: o autoload Audio nao esta registrado em project.godot.")
		quit(1)
		return

	print("=== A1: todo som registrado existe e carrega ===")
	_a1_arquivos()
	print("=== A2: os buses estão de pé e roteados ===")
	_a2_buses()
	print("=== A3: prioridade resolve o empilhamento de um frame ===")
	_a3_prioridade()
	print("=== A4: a espera mínima segura a repetição ===")
	_a4_espera()
	print("=== A5: os sinais do jogo pedem o som certo ===")
	_a5_ligacoes()
	print("=== A6: volume vai ao bus e volta ===")
	_a6_volume()

	print("")
	if _falhas == 0:
		print("=== AUDIO OK — o encanamento confere ===")
		print("    (nada aqui diz que os sons são BONS: ninguém os ouviu)")
		quit(0)
	else:
		print("=== %d PROBLEMA(S) DE AUDIO ===" % _falhas)
		quit(1)


func _a1_arquivos() -> void:
	_confere("o registro não está vazio", A.SONS.size() > 0)
	for id in A.SONS:
		var caminho: String = A.PASTA + String(A.SONS[id]["arquivo"]) + ".wav"
		_confere("%s: %s existe" % [id, caminho], ResourceLoader.exists(caminho))
		var s = load(caminho)
		_confere("%s: carrega como AudioStream" % id, s is AudioStream,
			"veio %s" % ("null" if s == null else s.get_class()))
		if s is AudioStreamWAV:
			var w: AudioStreamWAV = s
			_confere("%s: %d Hz, mono, 16 bits" % [id, w.mix_rate],
				w.mix_rate == TAXA_ESPERADA and not w.stereo
				and w.format == AudioStreamWAV.FORMAT_16_BITS,
				"taxa %d, estéreo %s, formato %d" % [w.mix_rate, w.stereo, w.format])
			# Efeito de interface longo demais atrasa a leitura da tela. O
			# apito de navio é a exceção declarada.
			var limite: float = 1.5 if id == "navio" else 1.0
			_confere("%s: dura %.0f ms (teto %.0f)" % [id, s.get_length() * 1000.0,
					limite * 1000.0],
				s.get_length() > 0.0 and s.get_length() <= limite)


func _a2_buses() -> void:
	for bus in ["Master", "Musica", "SFX"]:
		_confere("bus %s existe" % bus, AudioServer.get_bus_index(bus) >= 0)
	var i := AudioServer.get_bus_index("SFX")
	if i >= 0:
		_confere("SFX manda para o Master",
			AudioServer.get_bus_send(i) == &"Master",
			"manda para %s" % AudioServer.get_bus_send(i))
	# As vozes têm de estar no bus de efeito, senão o slider de SFX não as
	# alcança e baixar o volume não baixa nada.
	var no_bus := 0
	for filho in A.get_children():
		if filho is AudioStreamPlayer and (filho as AudioStreamPlayer).bus == "SFX":
			no_bus += 1
	_confere("as %d vozes estão no bus SFX" % A.VOZES, no_bus == A.VOZES,
		"%d de %d" % [no_bus, A.VOZES])


# Avançar o dia emite turn_advanced, boats_spawned, cash_changed e message no
# MESMO frame. Sem prioridade isso seria quatro sons juntos.
func _a3_prioridade() -> void:
	A._nascimento = -999.0        # sai da janela de silêncio inicial
	A._pedido = ""
	A._pedido_prioridade = -1
	A.tocar("click")
	A.tocar("alerta")
	A.tocar("moeda")
	_confere("de click+alerta+moeda no mesmo frame sobra o alerta",
		A._pedido == "alerta", "sobrou %s" % A._pedido)

	A._pedido = ""
	A._pedido_prioridade = -1
	A.tocar("vitoria")
	A.tocar("aviso")
	_confere("nada passa à frente do fim de jogo",
		A._pedido == "vitoria", "sobrou %s" % A._pedido)


func _a4_espera() -> void:
	A._nascimento = -999.0
	A._ultima_vez.clear()
	A._pedido = ""
	A._pedido_prioridade = -1

	A.tocar("aviso")
	A._process(0.016)
	var tocou_uma_vez: bool = A._ultima_vez.has("aviso")
	_confere("o primeiro pedido toca", tocou_uma_vez)

	# O mesmo som logo a seguir tem de ser engolido pela espera mínima.
	var marca: float = float(A._ultima_vez.get("aviso", 0.0))
	A.tocar("aviso")
	A._process(0.016)
	_confere("o mesmo som colado não repete",
		float(A._ultima_vez.get("aviso", 0.0)) == marca,
		"espera de %.2f s não segurou" % float(A.SONS["aviso"]["espera"]))

	# Toda espera tem de ser positiva, senão a regra não existe.
	for id in A.SONS:
		_confere("%s tem espera mínima" % id, float(A.SONS[id]["espera"]) > 0.0)


# Aqui não se testa som: testa-se que o SINAL certo pede o ID certo. É a parte
# do áudio que quebra em silêncio quando alguém renomeia um sinal.
func _a5_ligacoes() -> void:
	var GS = root.get_node("GameState")
	for sinal in ["message", "boats_spawned", "cash_changed", "estrutura_comprada",
			"rival_offer_triggered", "debt_due", "game_over"]:
		var ligado := false
		for c in GS.get_signal_connection_list(sinal):
			if c["callable"].get_object() == A:
				ligado = true
				break
		_confere("Audio escuta %s" % sinal, ligado)

	# `message` já vem classificado — é o achado que cobre 13 pontos da
	# interface com um ouvinte só. Cada classe tem de cair num som distinto.
	var mapa := {"good": "bom", "warn": "aviso", "bad": "ruim", "": "click"}
	for tipo in mapa:
		A._nascimento = -999.0
		A._pedido = ""
		A._pedido_prioridade = -1
		A._ao_mensagem("teste", String(tipo))
		_confere("message(%s) pede %s" % [tipo, mapa[tipo]],
			A._pedido == mapa[tipo], "pediu %s" % A._pedido)

	# Moeda só quando SOBE. Tocar dinheiro ao gastar é o erro clássico.
	A._nascimento = -999.0
	A._caixa_anterior = 1000
	A._pedido = ""
	A._pedido_prioridade = -1
	A._ao_caixa(1200)
	_confere("caixa subindo pede moeda", A._pedido == "moeda")
	A._pedido = ""
	A._pedido_prioridade = -1
	A._ao_caixa(400)
	_confere("caixa caindo NÃO pede moeda", A._pedido == "",
		"pediu %s ao gastar" % A._pedido)


func _a6_volume() -> void:
	var antes: float = A.volume("SFX")
	A.definir_volume("SFX", 0.5)
	_confere("volume 0,5 volta como 0,5", abs(A.volume("SFX") - 0.5) < 0.02,
		"voltou %.3f" % A.volume("SFX"))
	A.definir_volume("SFX", 0.0)
	_confere("volume zero silencia o bus",
		AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))
	_confere("e volume() devolve 0 quando mudo", A.volume("SFX") == 0.0)
	A.definir_volume("SFX", antes)
	_confere("e volta ao que estava", abs(A.volume("SFX") - antes) < 0.02)
