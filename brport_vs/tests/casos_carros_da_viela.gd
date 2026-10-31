extends RefCounted

# ============================================================
# D50 — os carros da viela (`docs/decisoes/141`)
#
# Os carros e as motos estacionam na VIELA DE TERRA entre as duas fileiras de
# casas — na rua do porto não cabiam, e o Bruno fê-la rodovia —, e o número
# cresce com a fase e com as obras do porto. O `CarrosDaViela.gd` planta-os
# todos ao montar a cena, escondidos, e mostra os que o estado já trouxe.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 a cópia dos carros e da máscara no `CarrosDaViela.gd` contra a TABELA
#      DE ÂNCORAS, que sai do gerador (o JSON não vai no pacote), e cada
#      carro com o PNG que tem o nome dele;
#   §2 cada carro dentro da viela do degrau dele — entre o fundo dos lotes da
#      frente e a frente dos de trás, as faixas `vila` e `vila_fundo` da
#      tabela —, com folga de meio carro, e dois carros da mesma margem sem
#      se tocarem ao longo dela;
#   §3 cada carro À VISTA, que é o que escolheu os sítios: pelo menos
#      `VISTO_MIN` dos pixels opacos dele acima do topo dos lotes da vila que
#      lhe ficam à frente (refeito dos `pecas_da_vila` da tabela) e dentro da
#      janela do `MapaWrap`; e, onde um lote o tapa (a sombra incluída), a
#      máscara do nó com esse topo, coluna a coluna — a pergunta do D45 sobre
#      o poste atrás da igreja, um carro abaixo. ⚠️ Mede-se no sítio onde o
#      JOGO o desenha (a cópia), e não no da tabela: o §1 já prende uma à
#      outra, e medido na tabela um carro movido só nela reprovava aqui por
#      «fora do pé», sem nunca se perguntar se ele se via;
#   §4 QUEM APARECE, lido na CENA: no dia 1 só os da Fase 1 sem obra; cada
#      reparo da Fase 1 traz os seus; a Fase 2 traz os novos SEM contar os
#      reparos da Fase 1 (que continuam a abrir nela); cada passo traz pelo
#      menos um carro, e no fim todos estão na viela. O esperado sai da
#      TABELA (`fase`, `obras`), e o estado entra pelo sinal que o jogo
#      emite ao comprar — é o `Main` que tem de o ouvir e chamar o refresh.
#
# Bloco num arquivo próprio, pela regra do `AGENTS.md` §2.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261025
## A fração mínima de um carro que se vê. Os sítios foram escolhidos acima
## de 80% (medido a cada 0,1 da viela, com a caixa do carro maior) e estão
## todos acima de 90%; o corte fica abaixo, e a picape posta na margem que a
## fileira da frente tapa (o mutante `carro-atras-das-casas`) dá 0,11.
const VISTO_MIN := 0.75
## A folga ao lote, em unidades: meio carro (a kombi, 0,195) e um nada. O
## gerador pousa-os a 0,375 do lote — o que gera é mais folgado do que o que
## confere.
const FOLGA_AO_LOTE := 0.2
## Meio comprimento, para dois da mesma margem não se tocarem: o carro mais
## comprido (a kombi, 0,5) e a moto (0,28), com a folga a menos.
const MEIO_CARRO := 0.48
const MEIO_MOTO := 0.27
const MASCARA_LADO := 40
const FUNDO_DO_MAPA := 720.0

var falhas := 0
var completo := false

var _gs: Node
var _arvore: SceneTree
var _ancoras: Dictionary
var _ck: Dictionary


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D50: %s" % nome)
	else:
		print("  FALHA D50: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree, ancoras: Dictionary) -> void:
	_gs = gs
	_arvore = arvore
	_ancoras = ancoras
	_ck = (load("res://scripts/CarrosDaViela.gd") as Script).get_script_constant_map()
	# Cada sub-bloco devolve `true` na última linha, e reprova aqui pelo nome se
	# um erro de execução o abortar a meio — senão só ele morria e a bandeira
	# do bloco ficava verde (`testes-e-guardas.md`, «um sub-bloco leva a sua
	# BANDEIRA»).
	conferir("a cópia correu até ao fim", _a_copia() == true)
	conferir("a viela correu até ao fim", _na_viela() == true)
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	conferir("a vista dos carros correu até ao fim", _a_vista(tela) == true)
	conferir("a chegada dos carros correu até ao fim", _quem_aparece(tela) == true)
	_arvore.root.remove_child(tela)
	tela.free()
	_gs.clear_save()
	completo = true


func _tela(mx: float, my: float) -> Vector2:
	var pr: Dictionary = _ancoras["projecao"]
	return Vector2(float(pr["cx"]) + (mx - my) * float(pr["meia_larg"]),
		float(pr["cy"]) + (mx + my) * float(pr["meia_alt"]) - float(pr["alt_cais"]))


# ── §1 ─────────────────────────────────────────────────────────────────────
func _a_copia() -> bool:
	var tabela: Array = _ancoras.get("carros_da_viela", [])
	var copia: Array = _ck["CARROS"]
	conferir("a tabela publica %d carro(s), e a cópia tantos quantos" % tabela.size(),
		not tabela.is_empty() and tabela.size() == copia.size(),
		"tabela %d, cópia %d" % [tabela.size(), copia.size()])
	var arte: Dictionary = _ck["ARTE"]
	for i in range(mini(tabela.size(), copia.size())):
		var t: Dictionary = tabela[i]
		var c: Array = copia[i]
		var v: Vector2 = c[1]
		var igual: bool = String(c[0]) == String(t["prop"]) \
			and absf(v.x - float(t["ponto"][0])) < 0.0005 \
			and absf(v.y - float(t["ponto"][1])) < 0.0005 \
			and int(c[2]) == int(t["fase"]) and int(c[3]) == int(t["obras"])
		conferir("o carro %d da cópia é o da tabela (%s)" % [i, t["prop"]], igual,
			"cópia %s, tabela %s" % [c, t])
		var tex: Texture2D = arte.get(String(t["prop"]))
		conferir("o carro %d tem o PNG com o nome dele" % i,
			tex != null and tex.resource_path.get_file() == String(t["prop"]) + ".png",
			"%s" % [tex.resource_path if tex != null else "nenhum"])
	var masc_t: Array = _ancoras.get("mascara_dos_carros", [])
	var masc_c: Array = _ck["MASCARA"]
	conferir("a máscara dos carros: a tabela tem %d, e a cópia tantas quantas" % masc_t.size(),
		masc_t.size() == masc_c.size(), "tabela %d, cópia %d" % [masc_t.size(), masc_c.size()])
	for k in range(mini(masc_t.size(), masc_c.size())):
		var t: Dictionary = masc_t[k]
		var c: Array = masc_c[k]
		var igual := int(c[0]) == int(t["carro"]) and int(c[1]) == int(t["x0"]) \
			and (c[2] as Array).size() == (t["teto"] as Array).size()
		for j in range(mini((c[2] as Array).size(), (t["teto"] as Array).size())):
			igual = igual and absf(float(c[2][j]) - float(t["teto"][j])) < 0.05
		conferir("a máscara %d da cópia é a da tabela (carro %s)" % [k, t["carro"]], igual)
	return true


# ── §2 ─────────────────────────────────────────────────────────────────────
func _na_viela() -> bool:
	var tabela: Array = _ancoras.get("carros_da_viela", [])
	var faixas: Array = _ancoras["faixas"]
	var dentro := true
	var onde := ""
	for t in tabela:
		var mx := float(t["ponto"][0])
		var my := float(t["ponto"][1])
		var achou := false
		for f in faixas:
			if my < float(f["my"][0]) or my >= float(f["my"][1]):
				continue
			achou = true
			# A viela vai do fundo dos lotes de trás à frente dos da frente.
			var de := float(f["vila_fundo"][1]) + FOLGA_AO_LOTE
			var ate := float(f["vila"][0]) - FOLGA_AO_LOTE
			if mx < de or mx > ate:
				dentro = false
				onde = "%s em mx %.3f, e a viela do degrau dele vai de %.3f a %.3f" \
					% [t["prop"], mx, de, ate]
		if not achou:
			dentro = false
			onde = "%s em my %.2f, fora de todo degrau" % [t["prop"], my]
	conferir("cada carro estaciona na viela de terra do degrau dele, longe dos lotes", dentro,
		onde)
	var separados := true
	onde = ""
	for i in range(tabela.size()):
		for j in range(i + 1, tabela.size()):
			var a: Dictionary = tabela[i]
			var b: Dictionary = tabela[j]
			if absf(float(a["ponto"][0]) - float(b["ponto"][0])) > 0.3:
				continue
			var meio := _meio(a) + _meio(b)
			var d := absf(float(a["ponto"][1]) - float(b["ponto"][1]))
			if d < meio:
				separados = false
				onde = "%s e %s a %.2f, e precisam de %.2f" % [a["prop"], b["prop"], d, meio]
	conferir("dois carros da mesma margem da viela não se tocam", separados, onde)
	return true


func _meio(t: Dictionary) -> float:
	return MEIO_MOTO if String(t["prop"]).begins_with("carro_moto") else MEIO_CARRO


# ── §3 ─────────────────────────────────────────────────────────────────────
func _a_vista(tela: Control) -> bool:
	var cenario := tela.get_node("MapaWrap/Cenario")
	var janela := (tela.get_node("MapaWrap") as Control).size
	var vistos := true
	var mascaras := true
	var tapados := 0
	var onde := ""
	var onde_m := ""
	var copia: Array = _ck["CARROS"]
	for i in range(copia.size()):
		var t: Dictionary = {"prop": copia[i][0]}
		var no := cenario.get_node_or_null("CarroDaViela%d" % i) as TextureRect
		var pe: Vector2 = copia[i][1]
		if no == null or no.texture == null \
				or no.position.distance_to(_tela(pe.x, pe.y) - Vector2(256.0, 256.0)) > 0.05:
			vistos = false
			onde = "CarroDaViela%d falta, ou fora do pé %s" % [i, pe]
			continue
		var x0 := roundi(_tela(pe.x, pe.y).x) - MASCARA_LADO
		var teto := _teto(pe, x0)
		var img := PropIso.imagem(no.texture)
		var esc := PropIso.escala(no.texture)
		var usado := img.get_used_rect()
		var opacos := 0
		var a_vista := 0
		var debaixo := 0
		for py in range(usado.position.y, usado.end.y):
			for px in range(usado.position.x, usado.end.x):
				# A sombra (alfa baixo) conta para a máscara, como no D45, e
				# não para a fração à vista, que é a do carro.
				var alfa := img.get_pixel(px, py).a
				if alfa < 0.1:
					continue
				var m := no.position + Vector2(px, py) * esc
				var c := floori(m.x) - x0
				var tapa := c >= 0 and c < teto.size() and m.y >= float(teto[c])
				if tapa:
					debaixo += 1
				if alfa < 0.5:
					continue
				opacos += 1
				if not tapa and m.y >= 0.0 and m.y < janela.y and m.x >= 0.0 and m.x < janela.x:
					a_vista += 1
		var fracao := float(a_vista) / maxf(1.0, float(opacos))
		if opacos == 0 or fracao < VISTO_MIN:
			vistos = false
			onde = "%s: %.2f dos %d px à vista" % [t["prop"], fracao, opacos]
		if debaixo > 0:
			tapados += debaixo
			var mat := no.material as ShaderMaterial
			var certo := mat != null and absf(float(mat.get_shader_parameter("x0")) - x0) < 0.5
			if certo:
				var dele: PackedFloat32Array = mat.get_shader_parameter("teto")
				var origem: Vector2 = mat.get_shader_parameter("origem")
				certo = dele.size() == teto.size() and origem.distance_to(no.position) < 0.05
				for k in range(mini(dele.size(), teto.size())):
					certo = certo and absf(dele[k] - float(teto[k])) < 0.05
			if not certo:
				mascaras = false
				onde_m = "%s: %d px abaixo do lote à frente, máscara %s" % [t["prop"], debaixo, mat]
	conferir("cada carro está à vista (pelo menos %d%% dos pixels)" % roundi(VISTO_MIN * 100.0),
		vistos, onde)
	conferir("o que um lote da vila tapa de um carro, a máscara esconde", mascaras, onde_m)
	conferir("a vila tapa pixels de algum carro (%d)" % tapados, tapados > 0)
	return true


## O topo dos lotes da vila à frente do pé `pe`, coluna a coluna desde `x0`:
## a conta do `mascara_dos_carros()` do gerador, refeita dos `pecas_da_vila`
## da tabela e da regra do eixo que separa (`lote_a_frente`).
func _teto(pe: Vector2, x0: int) -> Array:
	var teto: Array = []
	for c in range(x0, x0 + 2 * MASCARA_LADO + 1):
		var v := FUNDO_DO_MAPA
		for peca in _ancoras["pecas_da_vila"]:
			var caixa: Array = peca["caixa"]
			var topo: Array = peca["topo"]
			var k := c - int(peca["x0"])
			if k < 0 or k >= topo.size() or pe.x >= float(caixa[1]) or pe.y >= float(caixa[3]):
				continue
			v = minf(v, float(topo[k]))
		teto.append(v)
	return teto


# ── §4 ─────────────────────────────────────────────────────────────────────
func _quem_aparece(tela: Control) -> bool:
	var tabela: Array = _ancoras.get("carros_da_viela", [])
	var cenario := tela.get_node("MapaWrap/Cenario")
	var fases: Array = _gs.FASES
	var da_1: Array = (fases[0]["reparos"] as Dictionary).keys()
	var da_2: Array = []
	for id in (fases[1]["reparos"] as Dictionary).keys():
		if not da_1.has(id):
			da_2.append(id)
	conferir("a Fase 2 acrescenta reparos aos da Fase 1 (%s)" % [da_2], not da_2.is_empty())
	# Os estados, pela ordem em que o jogo os alcança: o dia 1, cada reparo
	# da Fase 1, a passagem à Fase 2 e cada reparo dela.
	var estados: Array = [[1, 0, 0]]
	for k in range(1, da_1.size() + 1):
		estados.append([1, k, 0])
	for k in range(0, da_2.size() + 1):
		estados.append([2, da_1.size(), k])
	var antes := -1
	var cresce := true
	var onde_c := ""
	for e in estados:
		_gs.numero_da_fase = int(e[0])
		_gs.estruturas = da_1.slice(0, int(e[1])) + da_2.slice(0, int(e[2]))
		_gs.estrutura_comprada.emit("pier_2")
		var esperado: Array = []
		for i in range(tabela.size()):
			var t: Dictionary = tabela[i]
			var obras := int(e[1]) if int(t["fase"]) == 1 else int(e[2])
			if int(e[0]) >= int(t["fase"]) and obras >= int(t["obras"]):
				esperado.append(i)
		var visto: Array = []
		for i in range(tabela.size()):
			var no := cenario.get_node_or_null("CarroDaViela%d" % i) as CanvasItem
			if no != null and no.visible:
				visto.append(i)
		conferir("Fase %d, %d reparo(s) da 1 e %d da 2: estacionados os da tabela"
			% [e[0], e[1], e[2]], visto == esperado, "na cena %s, na tabela %s" % [visto, esperado])
		if visto.size() <= antes:
			cresce = false
			onde_c = "Fase %d, %d e %d: %d carros, como no passo anterior" \
				% [e[0], e[1], e[2], visto.size()]
		antes = visto.size()
	conferir("cada passo da fase e das obras traz pelo menos um carro", cresce, onde_c)
	conferir("no fim estão todos na viela (%d de %d)" % [antes, tabela.size()],
		antes == tabela.size())
	return true
