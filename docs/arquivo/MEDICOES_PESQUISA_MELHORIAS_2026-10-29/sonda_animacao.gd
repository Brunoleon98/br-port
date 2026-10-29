extends SceneTree
# Sonda de pesquisa (29/10): o que MEXE no jogo, lido nos nós ao longo dos
# frames. Monta o Main como o capturar_tela.gd (semente, nomes, `completo`),
# espera assentar e amostra cada CanvasItem visível a cada PASSO frames;
# depois atraca o que houver ao largo e toca duas vezes no «Avançar dia».
# Vive no arquivo (`143`), fora do `brport_vs/`, e não é ferramenta do CI.
# ⚠️ Sem `atracar` o barco atracado não aparece no que mexe: a primeira
# corrida quase o deu por parado (`gerais.md`, «percurso responde pelo que
# se vê»).
# Uso: $G --headless --fixed-fps 60 --path brport_vs --script <caminho
#      absoluto disto> -- [completo] [atracar]

const ASSENTAR := 30
const PASSO := 6
const PARADO := 1200      # 20 s a 60 fps
const VIRADA := 300       # duas viradas de 2,5 s

var GS: Node
var _main: Node
var _f := 0
var _amostras := {}       # caminho -> Array de estados
var _virada := {}         # caminho -> Array de estados
var _fase := 0
var _f0 := 0


func _estado(ci: CanvasItem) -> Array:
	var t := ci.get_global_transform()
	var tex := ""
	if ci is TextureRect and (ci as TextureRect).texture != null:
		tex = str((ci as TextureRect).texture.get_rid())
	elif ci is Sprite2D and (ci as Sprite2D).texture != null:
		tex = str((ci as Sprite2D).texture.get_rid())
	var txt := ""
	if ci is Label:
		txt = (ci as Label).text
	return [t.origin.x, t.origin.y, t.get_rotation(), t.get_scale().x, t.get_scale().y,
		ci.modulate.a, ci.self_modulate.a, ci.modulate.r, ci.is_visible_in_tree(), tex, txt]


func _amostrar(destino: Dictionary) -> void:
	var pilha: Array = [_main]
	while not pilha.is_empty():
		var n: Node = pilha.pop_back()
		for c in n.get_children():
			pilha.append(c)
		if n is CanvasItem:
			var ci := n as CanvasItem
			var k := str(_main.get_path_to(ci))
			if not destino.has(k):
				destino[k] = []
			destino[k].append(_estado(ci))


func _process(_d: float) -> bool:
	if _f == 0:
		GS = root.get_node("GameState")
		for n in range(2, GS.ESPACOS + 1):
			GS.apagar_espaco(n)
		GS._rng.seed = 12345
		GS.comecar_no_espaco(1)
		GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		if OS.get_cmdline_user_args().has("completo"):
			var total: int = 0
			for e in GS.ESTRUTURAS:
				total += int(GS.ESTRUTURAS[e]["custo"])
			GS.cash += total
			for e in GS.ESTRUTURAS:
				load("res://tools/estado_da_bancada.gd").instalar(GS, e)
		if OS.get_cmdline_user_args().has("atracar"):
			for _i in range(GS.docks.size()):
				if GS.atracagem_pendente() == Vector2i.ZERO:
					break
				GS.atracar(0)
		_main = load("res://scenes/Main.tscn").instantiate()
		root.add_child(_main)
	_f += 1
	if _fase == 0 and _f > ASSENTAR and (_f - ASSENTAR) % PASSO == 0:
		_amostrar(_amostras)
		if _f - ASSENTAR >= PARADO:
			_fase = 1
			_f0 = _f
			# atraca o que estiver ao largo, para a virada ter barco a servir
			for _i in range(GS.docks.size()):
				if GS.atracagem_pendente() == Vector2i.ZERO:
					break
				GS.atracar(0)
			print("antes: turno %d, caixa %d" % [GS.turn, GS.cash])
			_main.call("_on_advance_pressed")
	elif _fase == 1 and (_f - _f0) % 3 == 0:
		_amostrar(_virada)
		if _f - _f0 == VIRADA / 2:
			print("meio: turno %d, caixa %d" % [GS.turn, GS.cash])
			_main.call("_on_advance_pressed")
		if _f - _f0 >= VIRADA:
			print("depois: turno %d, caixa %d" % [GS.turn, GS.cash])
			_relatar()
			quit(0)
	return false


func _mudou(lista: Array) -> Dictionary:
	var r := {}
	if lista.size() < 2:
		return r
	var a: Array = lista[0]
	var nomes := ["pos", "pos", "rot", "escala", "escala", "alfa", "alfa_proprio", "cor", "visivel", "textura", "texto"]
	for s in lista:
		var vis: bool = s[8] or a[8]
		if not vis:
			continue
		for i in range(a.size()):
			var x = a[i]
			var y = s[i]
			if typeof(x) == TYPE_FLOAT:
				if absf(float(x) - float(y)) > 0.05 if i < 2 else absf(float(x) - float(y)) > 0.003:
					r[nomes[i]] = true
			elif x != y:
				r[nomes[i]] = true
	return r


func _grupo(k: String) -> String:
	var folha := k.get_file()
	var re := RegEx.new()
	re.compile("[0-9@]+")
	return k.get_base_dir().get_file() + "/" + re.sub(folha, "#", true)


func _relatar() -> void:
	for titulo in ["PARADO (20 s)", "VIRADA (dois toques, 5 s)"]:
		var fonte: Dictionary = _amostras if titulo.begins_with("PARADO") else _virada
		var vis := 0
		var mexe := 0
		var grupos := {}
		for k in fonte:
			var lista: Array = fonte[k]
			var algum_vis := false
			for s in lista:
				if s[8]:
					algum_vis = true
					break
			if not algum_vis:
				continue
			vis += 1
			var m := _mudou(lista)
			if m.is_empty():
				continue
			mexe += 1
			var g := _grupo(k)
			if not grupos.has(g):
				grupos[g] = {"n": 0, "como": {}}
			grupos[g]["n"] += 1
			for c in m:
				grupos[g]["como"][c] = true
		print("== %s: %d nós visíveis, %d mexem" % [titulo, vis, mexe])
		var chaves := grupos.keys()
		chaves.sort()
		for g in chaves:
			print("   %-48s %3d  %s" % [g, grupos[g]["n"], ",".join(grupos[g]["como"].keys())])
	print("SONDA FEITA")
