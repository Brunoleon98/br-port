extends RefCounted

# ============================================================
# BR Port VS — a cor FINAL de um texto da interface, contra o fundo REAL
#
# ISTO É O MOTOR, e tem DOIS consumidores de propósito:
#   `tools/medir_contraste_ui.gd` — imprime a tabela dos dezanove estados;
#   o bloco D33 de `tests/teste_design.gd` — reprova o que estiver abaixo.
#
# ⚠️ E É UM ARQUIVO SÓ PORQUE REGRA DUPLICADA NUNCA REPROVA. Se o percurso e a
# conta vivessem nos dois, um defeito injetado na ferramenta não tocaria no
# teste e vice-versa — a armadilha que o `CLAUDE.md` regista com o
# `trabalho_parado()`/`doca_aceita_trabalhador()`, e que aqui seria pior: a
# ferramenta imprimiria verde de uma medição e o CI de outra.
#
# ⚠️ E NÃO TEM `class_name` NEM FALA DO AUTOLOAD PELO NOME. Um `class_name`
# alcançado a partir de um `--script` compila antes de os autoloads existirem,
# e `GameState.x` lá dentro derruba a suíte inteira com "Identifier not found".
# Quem precisa do estado recebe-o como argumento.
#
# O QUE ELE MEDE não é a cor escrita no tema — é a que chega ao olho, e entre
# uma e outra há quatro camadas, cada uma já paga neste projeto:
#   HERANÇA    `get_theme_color()`, que resolve variação, tema do pai e omissão
#   OVERRIDE   `add_theme_color_override()`
#   MODULAÇÃO  o `modulate` multiplica o texto E o fundo, com cadeias distintas
#   FUNDO REAL o `bg_color` do `StyleBoxFlat` mais perto, composto até o opaco
# ============================================================

# O AA da WCAG. ⚠️ NÃO SE ARREDONDA PARA APROVAR: 2,93:1 reprova o corte de
# texto GRANDE por sete centésimos, e foi defeito verdadeiro em nove painéis.
const AA_PEQUENO := 4.5
const AA_GRANDE := 3.0
const CORTE_GRANDE_PX := 18

# Onde vivem os painéis. O percurso DERIVA daqui e não de uma lista escrita à
# mão: painel novo que ninguém acrescente à lista é o buraco que este bloco
# existe para tapar, e uma lista à mão fecha-o em silêncio.
const PASTA_PAINEIS := "res://scenes/panels"


# ── OS ESTADOS ──────────────────────────────────────────────────────────────
#
# Um painel pode reprovar num estado e passar noutro, então o percurso são
# ESTADOS e não cenas. Os argumentos de `setup()` e o estado do jogo são os
# mesmos que a bateria de capturas usa.
#
# ⚠️ E O ESTADO ESCOLHE-SE PELO QUE APERTA. O painel do Sr. Ribeiro tem duas
# portas — quem pode pagar e quem não pode — e só a segunda tem botão
# desligado; o HUD só mostra o convite a quitar quando o caixa já chega lá.
# Medir só a porta fácil é medir o caso que não reprova.
func percurso() -> Array:
	return [
		{"nome": "Diário", "cena": "res://scenes/panels/PainelDiario.tscn"},
		{"nome": "Nomes", "cena": "res://scenes/panels/TelaNomes.tscn"},
		{"nome": "Construir", "cena": "res://scenes/panels/UpgradePanel.tscn"},
		{"nome": "Calendário", "cena": "res://scenes/panels/PainelCalendario.tscn",
			"setup": []},
		{"nome": "Docas", "cena": "res://scenes/panels/PainelDocas.tscn", "setup": []},
		{"nome": "Reputação", "cena": "res://scenes/panels/PainelReputacao.tscn",
			"setup": []},
		{"nome": "Parcela", "cena": "res://scenes/panels/PainelParcela.tscn",
			"estado": {"turn": 8, "cash": 900000}, "setup": []},
		# ⚠️ COM HISTÓRICO, e não vazio: o painel vazio tem UM parágrafo e a
		# lista cheia tem a área rolável — medir o vazio é medir o que não
		# reprova.
		{"nome": "Mensagens", "cena": "res://scenes/panels/PainelMensagens.tscn",
			"setup": ["#historico"]},
		# ⚠️ E O `setup: []` NÃO É DECORAÇÃO: sem ele o painel nasce vazio e a
		# medição conta zero rótulos, passando por boa — a guarda de atalho que
		# o `capturar_cena.gd` já pagou uma vez.
		{"nome": "Menu-celular", "cena": "res://scenes/panels/PainelMenu.tscn",
			"estado": {"turn": 9}, "setup": []},
		{"nome": "Pausa", "cena": "res://scenes/panels/PauseMenu.tscn"},
		{"nome": "Caixa", "cena": "res://scenes/panels/PainelCaixa.tscn",
			"setup": ["@resumo_do_dia"]},
		{"nome": "Boletim", "cena": "res://scenes/panels/PainelBoletim.tscn",
			"setup": ["@resumo_da_semana:1"]},
		{"nome": "Contra-oferta", "cena": "res://scenes/panels/CounterOfferPanel.tscn",
			"barco": 0, "setup": [0]},
		{"nome": "Ribeiro (pode pagar)",
			"cena": "res://scenes/panels/DebtPaymentPanel.tscn",
			"estado": {"cash": 900000}, "setup": ["@PARCELA_AMOUNT"]},
		{"nome": "Ribeiro (NÃO pode pagar)",
			"cena": "res://scenes/panels/DebtPaymentPanel.tscn",
			"estado": {"cash": 1000}, "setup": ["@PARCELA_AMOUNT"]},
		{"nome": "Fim de jogo (ganhou)", "cena": "res://scenes/EndGame.tscn",
			"setup": [true, "parcela_paga"]},
		{"nome": "Fim de jogo (perdeu)", "cena": "res://scenes/EndGame.tscn",
			"setup": [false, "parcela_nao_paga"]},
		# ⚠️ A HUD ENTRA PORQUE É ONDE OS OVERRIDES VIVEM. Oito dos vinte e um
		# `add_theme_color_override` do projeto são do `Main.gd`, e o âmbar de
		# "toque para quitar agora" media 3,18:1 num rótulo de 13px que nenhuma
		# das três guardas anteriores percorria.
		{"nome": "HUD (falta para a parcela)", "cena": "res://scenes/Main.tscn",
			"estado": {"cash": 100000}, "so_hud": true},
		{"nome": "HUD (já dá para quitar)", "cena": "res://scenes/Main.tscn",
			"estado": {"cash": 900000}, "so_hud": true},
	]


# As cenas de painel que existem em disco. O percurso tem de as cobrir todas.
func paineis_em_disco() -> Array:
	var out: Array = []
	var d := DirAccess.open(PASTA_PAINEIS)
	if d == null:
		return out
	for arq in d.get_files():
		if arq.ends_with(".tscn"):
			out.append("%s/%s" % [PASTA_PAINEIS, arq])
	out.sort()
	return out


# ── MONTAR UM ESTADO ────────────────────────────────────────────────────────
#
# Devolve o nó, ou `null` com o erro descrito em `falhas`. Parte sempre de uma
# PARTIDA NOVA: o autoload tenta `load_game()` antes de `new_game()`, e uma
# cena montada por cima de um autosave herda o porto de outra medição.
var falhas: PackedStringArray = PackedStringArray()


func montar_caso(raiz: Node, GS: Node, caso: Dictionary, tema: Theme) -> Node:
	GS.clear_save()
	seed(20260825)
	GS._rng.seed = 20260825
	GS.new_game()
	# ⚠️ A OFERTA PENDENTE RESOLVE-SE ANTES: com `phase == "rival_offer"` o
	# `comprar_estrutura()` recusa calado, e o estado montado a seguir não é o
	# que se pediu. O `CLAUDE.md` regista isto como "o estado da semente anda
	# com quem a usa".
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	for chave in caso.get("estado", {}):
		GS.set(chave, caso["estado"][chave])
	if caso.has("barco"):
		var d: int = caso["barco"]
		if GS.docks[d].get("boat") == null:
			GS._spawn_boats()
		GS.docks[d]["rival_offer"] = true

	if not ResourceLoader.exists(caso["cena"]):
		falhas.append("cena não encontrada: %s" % caso["cena"])
		return null
	var no: Node = load(caso["cena"]).instantiate()
	# O TEMA À MÃO, como o `_abrir_painel()` do Main faz: um painel solto nasce
	# com o cinzento padrão do Godot, e a medição seria de outra interface.
	if no is Control:
		(no as Control).theme = tema
	raiz.add_child(no)
	if caso.get("so_hud", false):
		# ⚠️ O `Main` ABRE A TELA DOS NOMES no `_ready()`, e ela taparia a HUD
		# que este caso existe para medir. Ela é caso próprio acima.
		_dispensar_paineis(no)
	if caso.has("setup") and no.has_method("setup"):
		var args: Array = []
		for bruto in caso["setup"]:
			if bruto is String and String(bruto).begins_with("#"):
				args.append(_amostra(String(bruto).substr(1)))
			elif bruto is String and String(bruto).begins_with("@"):
				args.append(_do_estado(GS, String(bruto).substr(1)))
			else:
				args.append(bruto)
		no.callv("setup", args)
	return no


func _dispensar_paineis(main: Node) -> void:
	for camada in main.get_children():
		if camada is CanvasLayer:
			for filho in camada.get_children():
				if filho is Control and filho.has_method("montar"):
					camada.remove_child(filho)
					filho.queue_free()


# Conteúdo que não vive no `GameState`: o histórico da faixa de mensagem mora
# na fila do `Main`.
func _amostra(qual: String) -> Variant:
	match qual:
		"historico":
			return [
				{"texto": "Semana nova. Barcos na fila e dinheiro no caixa."},
				{"texto": "O píer 2 ficou pronto."},
				{"texto": "Um barco foi embora sem ser atendido."},
			]
		_:
			falhas.append("amostra desconhecida: %s" % qual)
			return null


# `@nome` lê do `GameState`: constante, método (com `:arg` quando precisa de
# um) ou campo. Nome que não exista ENTRA NAS FALHAS em vez de virar `null`
# calado — a armadilha do `.get(chave, omissão)`.
func _do_estado(GS: Node, chave: String) -> Variant:
	var consts: Dictionary = GS.get_script().get_script_constant_map()
	if consts.has(chave):
		return consts[chave]
	if chave.contains(":"):
		var corte: int = chave.find(":")
		var metodo: String = chave.substr(0, corte)
		var arg: String = chave.substr(corte + 1)
		if not GS.has_method(metodo):
			falhas.append("GameState não tem o método %s" % metodo)
			return null
		return GS.call(metodo, int(arg) if arg.is_valid_int() else arg)
	if GS.has_method(chave):
		return GS.call(chave)
	if chave in GS:
		return GS.get(chave)
	falhas.append("GameState não tem %s" % chave)
	return null


# ── A MEDIÇÃO ───────────────────────────────────────────────────────────────
#
# Todo texto que o jogador LÊ: o `Label`, o rótulo do `Button` e o conteúdo e a
# SUGESTÃO do `LineEdit` — um campo vazio mostra a sugestão, e a tela dos nomes
# abre com as duas à vista. Foi o quinto endereço do neutro de 2,93:1, e nenhum
# dos quatro anteriores o citava.
func medir(raiz: Node) -> Array:
	var out: Array = []
	for no in _controles_com_texto(raiz):
		out.append_array(_medir_um(no, raiz))
	return out


func _controles_com_texto(no: Node) -> Array:
	var out: Array = []
	if no is Label and not (no as Label).text.strip_edges().is_empty():
		out.append(no)
	elif no is Button and not (no as Button).text.strip_edges().is_empty():
		out.append(no)
	elif no is LineEdit:
		out.append(no)
	for filho in no.get_children():
		out.append_array(_controles_com_texto(filho))
	return out


func _medir_um(no: Control, raiz: Node) -> Array:
	var px: int = no.get_theme_font_size("font_size")
	var corte: float = AA_GRANDE if px >= CORTE_GRANDE_PX else AA_PEQUENO
	var fundo := fundo_de(no, raiz)
	var linhas: Array = []

	var pares: Array = []
	if no is Button:
		var b := no as Button
		# ⚠️ TEXTO INATIVO TEM EXCEÇÃO NA WCAG (1.4.3), e ela é do COMPONENTE —
		# não do painel. O rótulo do botão desligado sai isento; a frase que
		# diz POR QUE ele está desligado não sai, e quem confere que ela existe
		# e se lê é o D33, não esta linha.
		var chave := "font_disabled_color" if b.disabled else "font_color"
		pares.append([no.get_theme_color(chave), b.text, b.disabled])
	elif no is LineEdit:
		var e := no as LineEdit
		if not e.text.strip_edges().is_empty():
			pares.append([no.get_theme_color("font_color"), e.text, false])
		if not e.placeholder_text.strip_edges().is_empty():
			pares.append([no.get_theme_color("font_placeholder_color"),
				"(sugestão) " + e.placeholder_text, false])
	else:
		pares.append([no.get_theme_color("font_color"), (no as Label).text, false])

	var mod := mod_efetiva(no, raiz)
	for par in pares:
		var cor: Color = par[0]
		cor = Color(cor.r * mod.r, cor.g * mod.g, cor.b * mod.b, cor.a * mod.a)
		var linha := {
			"px": px, "corte": corte, "inativo": par[2],
			"texto": String(par[1]).replace("\n", " ").substr(0, 46),
			"fonte": origem_da_cor(no), "razao": 0.0, "nota": "",
		}
		if fundo["pendente"]:
			linha["estado"] = "pendente"
			linha["nota"] = fundo["nota"]
			linhas.append(linha)
			continue
		# O texto translúcido compõe-se sobre o fundo ANTES de se medir: 60% de
		# navy sobre branco não é navy, e a razão é a da cor que sai.
		var r_min := 99.0
		var r_max := 0.0
		for f in fundo["cores"]:
			var r := contraste(compor(cor, f), f)
			r_min = minf(r_min, r)
			r_max = maxf(r_max, r)
		linha["razao"] = r_min
		# ⚠️ O INTERVALO SÓ PASSA SE AS DUAS PONTAS PASSAREM. Se elas
		# discordarem, a composição não está resolvida — e isso é PENDÊNCIA,
		# nunca um verde escolhido pela ponta que convém.
		if fundo["cores"].size() > 1 and (r_min < corte) != (r_max < corte):
			linha["estado"] = "pendente"
			linha["nota"] = ("fundo desconhecido por trás de alfa %.2f: de %.2f:1 "
				+ "a %.2f:1 atravessa o corte de %.1f") % [
					fundo["alfa"], r_min, r_max, corte]
		elif par[2]:
			linha["estado"] = "isento"
		elif r_min < corte:
			linha["estado"] = "reprova"
		else:
			linha["estado"] = "passa"
		linhas.append(linha)
	return linhas


# De onde veio a cor: o que separa um defeito de TEMA de um de SCRIPT. O R7
# herda esta coluna.
func origem_da_cor(no: Control) -> String:
	if no.has_theme_color_override("font_color"):
		return "override"
	if no.theme_type_variation != StringName(""):
		return String(no.theme_type_variation)
	return "tema"


# ── O FUNDO REAL ────────────────────────────────────────────────────────────
#
# Devolve as cores candidatas: UMA quando a composição fecha num opaco, DUAS
# (sobre preto e sobre branco) quando o que está por trás é desconhecido — o
# cartão da doca tem alfa 0,96 e pousa sobre o MAPA, que é arte arbitrária.
#
# ⚠️ E "O PAINEL É BRANCO" NÃO É UMA RESPOSTA. A mesma variação mede 5,46:1 no
# cartão, 5,03:1 no balão da fala (#f0f6ff) e 5,27:1 no creme da faixa de
# mensagem. Cor calibrada para um fundo não atravessa para outro — é a regra
# que este projeto tem escrita desde 03/09, e o D32 reconfirmou-a em 20/09.
func fundo_de(no: Control, raiz: Node) -> Dictionary:
	var camadas: Array = []   # da mais perto do texto para a mais longe
	var cur: Node = no
	while cur != null:
		if cur is Control:
			var c := cur as Control
			var sb: StyleBox = null
			if c is Button:
				sb = c.get_theme_stylebox(
					"disabled" if (c as Button).disabled else "normal")
			elif c is LineEdit:
				sb = c.get_theme_stylebox("normal")
			elif c is PanelContainer or c is Panel:
				sb = c.get_theme_stylebox("panel")
			if sb != null:
				if not (sb is StyleBoxFlat):
					return {"pendente": true, "cores": [], "alfa": 0.0,
						"nota": "o fundo é um %s, que não publica bg_color"
							% sb.get_class()}
				var m := mod_efetiva(c, raiz)
				var bg: Color = (sb as StyleBoxFlat).bg_color
				var posta := Color(bg.r * m.r, bg.g * m.g, bg.b * m.b, bg.a * m.a)
				camadas.append(posta)
				if posta.a >= 0.999:
					break
			# O escurecer do `PainelNarrativo` é um IRMÃO desenhado antes, e
			# não um ancestral: quem não está dentro de um cartão cai nele.
			var atras := _colorrect_atras(c, raiz)
			if not atras.is_empty():
				var cor_atras: Color = atras[0]
				camadas.append(cor_atras)
				if cor_atras.a >= 0.999:
					break
		if cur == raiz:
			break
		cur = cur.get_parent()

	if camadas.is_empty():
		return {"pendente": true, "cores": [], "alfa": 0.0,
			"nota": "nenhum fundo entre o texto e a raiz do painel"}

	var ultimo: Color = camadas[camadas.size() - 1]
	if ultimo.a >= 0.999:
		return {"pendente": false, "alfa": 1.0,
			"cores": [_empilhar(camadas, Color(0, 0, 0))], "nota": ""}
	return {"pendente": false, "alfa": ultimo.a, "nota": "",
		"cores": [_empilhar(camadas, Color(0, 0, 0)),
			_empilhar(camadas, Color(1, 1, 1))]}


func _empilhar(camadas: Array, base: Color) -> Color:
	var fora := base
	for i in range(camadas.size() - 1, -1, -1):
		fora = compor(camadas[i], fora)
	return fora


# `a` por cima de `b`, com `b` opaco.
func compor(a: Color, b: Color) -> Color:
	return Color(lerpf(b.r, a.r, a.a), lerpf(b.g, a.g, a.a), lerpf(b.b, a.b, a.a))


# Devolve `[]` ou `[cor]`. NÃO devolve `null` nem uma cor de alfa zero como
# sentinela: um `ColorRect` transparente é um estado legítimo, e sentinela que
# colide com valor real é a mesma armadilha da mensagem nova que casa com uma
# busca na saída de uma ferramenta.
func _colorrect_atras(no: Control, raiz: Node) -> Array:
	var pai := no.get_parent()
	if pai == null:
		return []
	for i in range(no.get_index() - 1, -1, -1):
		var irmao := pai.get_child(i)
		if irmao is ColorRect:
			var m := mod_efetiva(irmao as ColorRect, raiz)
			var c: Color = (irmao as ColorRect).color
			return [Color(c.r * m.r, c.g * m.g, c.b * m.b, c.a * m.a)]
	return []


# ── MODULAÇÃO ───────────────────────────────────────────────────────────────
#
# O `modulate` multiplica o nó E os filhos dele; o `self_modulate` só o nó. O
# fator que chega a um TEXTO é o produto da cadeia inteira até à raiz, e NÃO é
# o mesmo que chega ao FUNDO dele — as duas cadeias começam em nós diferentes.
# Daí aplicar-se às duas pontas em separado. O cartão da doca pulsa por aqui.
func mod_efetiva(no: CanvasItem, raiz: Node) -> Color:
	var fora := no.self_modulate
	var cur: Node = no
	while cur != null:
		if cur is CanvasItem:
			var m: Color = (cur as CanvasItem).modulate
			fora = Color(fora.r * m.r, fora.g * m.g, fora.b * m.b, fora.a * m.a)
		if cur == raiz:
			break
		cur = cur.get_parent()
	return fora


func luminancia(c: Color) -> float:
	var lin: Array = []
	for v in [c.r, c.g, c.b]:
		var f: float = clampf(float(v), 0.0, 1.0)
		lin.append(f / 12.92 if f <= 0.04045 else pow((f + 0.055) / 1.055, 2.4))
	return 0.2126 * float(lin[0]) + 0.7152 * float(lin[1]) + 0.0722 * float(lin[2])


func contraste(a: Color, b: Color) -> float:
	var la := luminancia(a)
	var lb := luminancia(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


# ── O CONTROLE POSITIVO E O NEGATIVO ────────────────────────────────────────
#
# ⚠️ RÉGUA QUE NUNCA REPROVOU NADA NÃO É RÉGUA — e uma que devolve NÚMEROS é
# pior do que um validador mudo, porque o número vira a conclusão. Um
# `contraste()` avariado (canais trocados, gama esquecida, subtração no lugar
# da razão) daria um valor plausível em cada uma das 214 linhas e a auditoria
# inteira leria como boa notícia.
#
# Os dois extremos são conhecidos e não se discutem: preto sobre branco é
# exactamente 21:1, o máximo que a fórmula pode dar, e branco sobre branco é
# exactamente 1:1, o mínimo. Entre eles, o par que este projeto já mediu quatro
# vezes — o neutro do jogo sobre o cartão branco TEM de dar 2,93 e TEM de
# reprovar. Devolve as falhas, uma linha por prova que não bateu.
func calibrar() -> PackedStringArray:
	var mau := PackedStringArray()
	var branco := Color(1, 1, 1)
	var neutro := Color(0.51, 0.6, 0.706)
	for p in [
		["preto sobre branco dá o máximo da fórmula",
			contraste(Color(0, 0, 0), branco), 21.0],
		["branco sobre branco dá o mínimo", contraste(branco, branco), 1.0],
		["o neutro do jogo sobre branco dá os 2,93 medidos quatro vezes",
			contraste(neutro, branco), 2.93],
		["a variação que o substituiu dá os 5,46 do CLAUDE.md",
			contraste(Color(0.35, 0.42, 0.50), branco), 5.46],
	]:
		if absf(float(p[1]) - float(p[2])) >= 0.01:
			mau.append("%s: %.2f, esperado %.2f" % [p[0], p[1], p[2]])
	# ⚠️ E O NEGATIVO NÃO É "UM NÚMERO BAIXO": é a régua a REPROVAR. Sem esta
	# linha, uma régua que devolvesse 2,93 e mesmo assim chamasse o par de bom
	# passaria nas quatro provas acima.
	if contraste(neutro, branco) >= AA_PEQUENO:
		mau.append("a régua NÃO reprova o neutro do jogo sobre branco")
	return mau
