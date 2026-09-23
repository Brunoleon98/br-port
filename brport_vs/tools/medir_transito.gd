extends SceneTree

# ============================================================
# BR Port — A RÉGUA DO TRÂNSITO: quanto os camiões se tocam
#
# Abre o `Main`, põe as três docas a receber e largar barcos numa agenda
# sorteada (sorteio PRÓPRIO — o do jogo é o que o simulador de balanceamento
# mede) e mede, a cada frame, a folga entre as PEGADAS dos cinco camiões.
#
# A pegada é o retângulo do chassi, centrado no ponto da rota: `CAMINHOES` de
# `blender/brp_porto.py` vezes o `ESCALA_CAMINHAO` (0,72), por 0,62 × 0,72 de
# largura, com o eixo tirado da textura que o nó mostra. É a régua da `052`:
# mediu 27 a 72 sobreposições à vista por meia hora antes da mão direita, e
# zero depois. O D35 do teste de design é a guarda; isto é o instrumento, para
# quando se quiser medir outra agenda sem tocar na suíte.
#
# Uso (sem tela; `--fixed-fps` faz o tempo andar por frames e não pelo relógio):
#   Godot --headless --fixed-fps 30 --path brport_vs \
#     --script res://tools/medir_transito.gd -- <segundos> <modo> [semente] [turno_min turno_max]
#   modo: "visitas" (as docas recebem e largam barcos) | "passagem" (nunca)
# Espera `TRANSITO MEDIDO`.
#
# ⚠️ A SOBREPOSIÇÃO DE DOIS CAMIÕES FORA DO QUADRO NÃO CONTA — são os que
# acabaram a volta, empilhados no fim da rota durante a pausa. O relatório
# mostra a folga mínima de todos os pares, e só os eventos em que pelo menos
# um dos dois está à vista.
# ============================================================

const COMP := {"pescado": 1.10 * 0.72, "granel": 1.48 * 0.72,
	"armazenagem": 1.56 * 0.72, "conteiner": 1.96 * 0.72}
const LARG := 0.62 * 0.72

var _main: Control
var _gs: Node
var _consts: Dictionary
var _tex: Dictionary = {}
var _t := 0.0
var _duracao := 600.0
var _modo := "visitas"
var _rng := RandomNumberGenerator.new()
var _turno_min := 3.0
var _turno_max := 12.0
var _prox_turno := 0.0
var _id := 9000
var _pronto := false
var _min: Dictionary = {}
var _frames_sobre: Dictionary = {}
var _eventos: Array = []
var _ultimo_evento: Dictionary = {}
var _lugares: Dictionary = {}
var _no_berco: Dictionary = {}
var _encostos: Dictionary = {}
var _em_baixo: Dictionary = {}
var _passagens: Dictionary = {}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_duracao = float(args[0])
	if args.size() >= 2:
		_modo = args[1]
	_rng.seed = 424242 if args.size() < 3 else int(args[2])
	if args.size() >= 5:
		_turno_min = float(args[3])
		_turno_max = float(args[4])


# `_process` devolve `false` e quem encerra é só o `quit()`: devolver `true`
# mataria a árvore no fim do primeiro frame (ver o `CLAUDE.md`).
func _process(delta: float) -> bool:
	if not _pronto:
		_gs = root.get_node("GameState")
		_gs.clear_save()
		_gs._rng.seed = 20260903
		_gs.new_game()
		if _gs.phase == "rival_offer":
			_gs.resolve_rival_offer(true)
		while _gs.docks.size() < 3:
			_gs.docks.append({"boat": null, "worker_id": null})
		for d in _gs.docks:
			d["boat"] = null
			d["worker_id"] = null
		_main = load("res://scenes/Main.tscn").instantiate()
		root.add_child(_main)
		_consts = _main.get_script().get_script_constant_map()
		for motivo in (_consts["CAMINHOES"] as Dictionary):
			var par: Dictionary = _consts["CAMINHOES"][motivo]
			for chave in par:
				_tex[par[chave]] = [motivo, String(chave).substr(0, 2)]
		_pronto = true
		return false
	_t += delta
	if _modo == "visitas" and _t >= _prox_turno:
		_turno()
		_prox_turno = _t + _rng.randf_range(_turno_min, _turno_max)
	_medir()
	if _t >= _duracao:
		_relatorio()
		quit(0)
	return false


func _turno() -> void:
	var motivos: Array = _main.call("_motivos_do_porto")
	var mudou := false
	for d in _gs.docks:
		if d["boat"] != null:
			if _rng.randf() < 0.35:
				d["boat"] = null
				d["worker_id"] = null
				mudou = true
				if _rng.randf() < 0.5:
					_id += 1
					d["boat"] = {"id": _id, "motivo": motivos[_rng.randi() % motivos.size()],
						"classe": "pesqueiro"}
					d["worker_id"] = 1
		elif _rng.randf() < 0.5:
			_id += 1
			d["boat"] = {"id": _id, "motivo": motivos[_rng.randi() % motivos.size()],
				"classe": "pesqueiro"}
			d["worker_id"] = 1
			mudou = true
	if mudou:
		_main.call("_docas_mudaram")


func _mundo(no: TextureRect, base: Vector2, origem: Vector2) -> Vector2:
	var s := no.position - base
	var a := s.x / float(_consts["MEIA_LARG"])
	var b := s.y / float(_consts["MEIA_ALT"])
	return origem + Vector2((a + b) / 2.0, (b - a) / 2.0)


func _pegadas() -> Array:
	var out: Array = []
	var cen := _main.get_node("MapaWrap/Cenario")
	var bases: Array = _main.get("_base_do_caminhao")
	var origens: Array = _consts["CAMINHAO_ORIGENS"]
	for i in range(origens.size()):
		var no := cen.get_node("Caminhao%d" % i) as TextureRect
		out.append(_pegada("ida%d" % i, no, _mundo(no, bases[i], origens[i])))
	var bret: Array = _main.get("_base_do_retorno")
	var oret: Array = _consts["CAMINHAO_RETORNO_ORIGENS"]
	for j in range(oret.size()):
		var no := cen.get_node("CaminhaoRetorno%d" % j) as TextureRect
		out.append(_pegada("ret%d" % j, no, _mundo(no, bret[j], oret[j])))
	return out


func _pegada(nome: String, no: TextureRect, c: Vector2) -> Dictionary:
	var info: Array = _tex.get(no.texture, ["conteiner", "my"])
	var comp: float = COMP[info[0]]
	var meio := Vector2(LARG, comp) / 2.0 if info[1] == "my" else Vector2(comp, LARG) / 2.0
	var tela := _main.get_node("MapaWrap") as Control
	var visivel := Rect2(Vector2.ZERO, tela.size).has_point(no.position + Vector2(256, 256))
	return {"nome": nome, "c": c, "meio": meio, "eixo": info[1], "vis": visivel}


func _medir() -> void:
	var p := _pegadas()
	var acessos: Array = _consts["ACESSOS_DOCA"]
	for c in p:
		var nome: String = c["nome"]
		var tipo := nome.substr(0, 3)
		var berco := -1
		for d in range(acessos.size()):
			if (c["c"] as Vector2).distance_to(acessos[d]["paragem"]) < 0.05:
				berco = d
		if berco >= 0 and int(_no_berco.get(nome, -1)) < 0:
			_encostos[tipo] = int(_encostos.get(tipo, 0)) + 1
		_no_berco[nome] = berco
		# A ponta de baixo (`my` 42) é o FIM da ida e o PRINCÍPIO do retorno:
		# contar passagens por ela diz que os camiões andam, e não que acabam.
		var em_baixo := (c["c"] as Vector2).y > 41.9
		if em_baixo and not bool(_em_baixo.get(nome, false)):
			_passagens[tipo] = int(_passagens.get(tipo, 0)) + 1
		_em_baixo[nome] = em_baixo
	for a in range(p.size()):
		for b in range(a + 1, p.size()):
			var A: Dictionary = p[a]
			var B: Dictionary = p[b]
			var d: Vector2 = (A["c"] - B["c"]).abs() - A["meio"] - B["meio"]
			var folga: float = maxf(d.x, d.y)
			var par := "%s-%s" % [A["nome"], B["nome"]]
			if not _min.has(par) or folga < float(_min[par]):
				_min[par] = folga
			if folga >= 0.0:
				continue
			_frames_sobre[par] = int(_frames_sobre.get(par, 0)) + 1
			if _t - float(_ultimo_evento.get(par, -99.0)) > 2.0 and (A["vis"] or B["vis"]):
				var lugar := _lugar(A["c"], B["c"], A["nome"], B["nome"])
				_lugares[lugar] = int(_lugares.get(lugar, 0)) + 1
				_eventos.append("t=%6.1f %s em (%.2f,%.2f)/(%.2f,%.2f) eixos %s/%s fundo %.2f"
					% [_t, par, A["c"].x, A["c"].y, B["c"].x, B["c"].y,
						A["eixo"], B["eixo"], -folga])
			_ultimo_evento[par] = _t


func _lugar(a: Vector2, b: Vector2, na: String, nb: String) -> String:
	var tipo := "ida-ida" if na.begins_with("ida") and nb.begins_with("ida") \
		else ("ret-ret" if na.begins_with("ret") and nb.begins_with("ret") else "ida-ret")
	for ac in (_consts["ACESSOS_DOCA"] as Array):
		var e: Vector2 = ac["entrada"]
		for c in [a, b]:
			if absf(c.y - e.y) < 1.2 and c.x > e.x - 2.2 and c.x < ac["paragem"].x + 0.5:
				return tipo + " no acesso"
	return tipo + " no cotovelo ou na reta"


func _relatorio() -> void:
	print("=== TRÂNSITO: modo %s, %.0f s ===" % [_modo, _duracao])
	var pares := _min.keys()
	pares.sort()
	for par in pares:
		print("  %-10s folga mínima %6.2f  frames sobrepostos %d"
			% [par, float(_min[par]), int(_frames_sobre.get(par, 0))])
	print("  sobreposições À VISTA, por lugar: %s" % str(_lugares))
	print("  encostos por sentido: %s" % str(_encostos))
	print("  passagens pela ponta de baixo: %s" % str(_passagens))
	for e in _eventos.slice(0, 40):
		print("   ", e)
	print("TRANSITO MEDIDO")
