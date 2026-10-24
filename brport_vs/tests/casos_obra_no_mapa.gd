extends RefCounted

# ============================================================
# D45 — a obra no mapa (`docs/decisoes/121`)
#
# Do dia em que se paga ao dia em que fica pronta, cada obra mostra no mapa o
# quadro do dia: o píer na vaga dele, o armazém no nó dele e o pátio no
# canteiro e no asfalto recortado. Este bloco joga as três obras e lê a CENA
# a cada dia — a textura de cada nó, o recorte do asfalto e o cartão da doca
# —, e não a lista que o jogo diz que mostra.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 a cópia do pátio e da projeção no `ObraNoMapa.gd` contra a TABELA DE
#      ÂNCORAS, que sai do gerador: o JSON não vai no pacote, e a cópia é a
#      constante escrita à mão que envelhece calada;
#   §2 um quadro por dia de obra, e o asfalto a crescer, contra o
#      `dias_da_obra()` da fase — a escolha do Bruno foi «avança por dia»;
#   §3 o píer comprado de VERDADE (`comprar_estrutura()`): o quadro 0 tem de
#      estar no mapa NO DIA DA COMPRA, antes de virar o dia — até à `121`
#      nada redesenhava o porto ao comprar —, e o cartão diz «píer em obra»
#      com o prazo do `GameState`;
#   §4 o armazém e o pátio, um dia de cada vez pela virada do jogo, até
#      ficarem prontos; o asfalto conferido contra os cantos que a TABELA
#      publica, e não contra o `poligonos_do_asfalto()` que o desenha;
#   §5 a obra de três dias num nó de dois quadros (o píer 3 da Fase 2): o
#      último quadro calha no último dia, e nenhum índice passa do fim;
#   §6 a RUA que a obra do pátio recapeia (`136`): a cópia dos pedaços e dos
#      cones contra a tabela, um trecho por dia e o último no fim — o
#      «por partes» que o Bruno pediu —, e a cada dia os dois recortes da
#      rua (o mapa de terra no que falta, por cima do pátio, e o pavimentado
#      no que já está pronto) e os três cones na frente, entre os irmãos do
#      `Cenario` pela profundidade. O D49 mede nos mapas que nada muda fora.
#   §7 o MOBILIÁRIO DA RUA (`140`): a cópia dos postes, das placas e dos
#      cavaletes contra a tabela; cada peça na calçada do lado dela (o poste
#      na da vila, a placa na do porto), fora do cotovelo e da boca do acesso,
#      e com o dia do trecho de rua onde pousa; e, dia a dia, a arte velha ou
#      a nova pelo trecho, a lâmpada de sódio só no poste velho, os dois
#      cavaletes entre os cones e cada fio da fiação pousado num ISOLADOR do
#      poste que se vê — lido no PNG dele, e não na conta que o desenha.
#
# Bloco num arquivo próprio pela regra do `AGENTS.md` §2: dois agentes a
# acrescentar blocos deixam de editar o mesmo `teste_design.gd`. Síncrono,
# como a suíte que o chama: um `await` lá nunca volta.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261016

var falhas := 0
var completo := false

var _gs: Node
var _arvore: SceneTree
var _ancoras: Dictionary
var _obra_script: Script
var _ok: Dictionary
var _dk: Dictionary
var _mk: Dictionary


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D45: %s" % nome)
	else:
		print("  FALHA D45: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree, ancoras: Dictionary) -> void:
	_gs = gs
	_arvore = arvore
	_ancoras = ancoras
	_obra_script = load("res://scripts/ObraNoMapa.gd")
	_ok = _obra_script.get_script_constant_map()
	_dk = (load("res://scripts/Dock.gd") as Script).get_script_constant_map()
	_mk = (load("res://scripts/Main.gd") as Script).get_script_constant_map()

	_contrato_com_a_tabela()
	_contrato_da_rua()
	_contrato_do_mobiliario()
	_um_quadro_por_dia()
	conferir("o píer comprado correu até ao fim", _o_pier_comprado())
	conferir("o armazém correu até ao fim", _o_armazem())
	conferir("o pátio correu até ao fim", _o_patio())
	_tres_dias_em_dois_quadros()
	_gs.clear_save()
	completo = true


# ── §1 ─────────────────────────────────────────────────────────────────────
func _contrato_com_a_tabela() -> void:
	var tabela: Array = _ancoras.get("patio", [])
	var copia: Array = _ok["PATIO"]
	conferir("o pátio da tabela tem %d trecho(s), e a cópia tantos quantos" % tabela.size(),
		not tabela.is_empty() and tabela.size() == copia.size(),
		"tabela %d, cópia %d" % [tabela.size(), copia.size()])
	for i in range(mini(tabela.size(), copia.size())):
		var t: Dictionary = tabela[i]
		var c: Array = copia[i]
		var esperado := [float(t["my"][0]), float(t["my"][1]),
			float(t["mx"][0]), float(t["mx"][1])]
		var igual := true
		for j in range(4):
			igual = igual and absf(float(c[j]) - esperado[j]) < 0.0005
		conferir("o trecho %d do pátio é o da tabela" % i, igual,
			"cópia %s, tabela %s" % [c, esperado])
	var pr: Dictionary = _ancoras["projecao"]
	for par in [["CX", "cx"], ["CY", "cy"], ["ALT_CAIS", "alt_cais"],
			["MEIA_LARG", "meia_larg"], ["MEIA_ALT", "meia_alt"]]:
		conferir("a projeção do recorte: %s é o `%s` da tabela" % par,
			absf(float(_ok[par[0]]) - float(pr[par[1]])) < 0.0005,
			"%s contra %s" % [_ok[par[0]], pr[par[1]]])


# ── §2 ─────────────────────────────────────────────────────────────────────
func _um_quadro_por_dia() -> void:
	_novo_jogo()
	for par in [["pier_2", (_dk["ArtePierObra"] as Array).size()],
			["armazem", (_ok["ARMAZEM"] as Array).size()],
			["patio", (_ok["CANTEIRO"] as Array).size()]]:
		var dias := int(_gs.dias_da_obra(String(par[0])))
		conferir("%s: um quadro por dia de obra (%d quadros, %d dias)"
			% [par[0], par[1], dias], dias > 0 and int(par[1]) == dias)
	var fracoes: Array = _ok["ASFALTO_POR_QUADRO"]
	conferir("uma fração de asfalto por quadro do canteiro",
		fracoes.size() == (_ok["CANTEIRO"] as Array).size())
	var cresce := fracoes.size() > 1 and float(fracoes[0]) == 0.0
	for i in range(1, fracoes.size()):
		cresce = cresce and float(fracoes[i]) > float(fracoes[i - 1]) \
			and float(fracoes[i]) < 1.0
	conferir("o asfalto começa em zero e cresce sem chegar ao pátio inteiro %s" % [fracoes],
		cresce)


# ── §3 ─────────────────────────────────────────────────────────────────────
func _o_pier_comprado() -> bool:
	_novo_jogo()
	var tela: Control = _montar()
	var pier: TextureRect = tela.get_node("MapaWrap/Docas/Doca1/Pier")
	var progresso: Label = tela.get_node("BarraDocas/Cartao1/Coluna/ProgressoLinha/Progresso")
	var prazo: Label = tela.get_node("BarraDocas/Cartao1/Coluna/TrabalhadorLinha/Trabalhador")
	var quadros: Array = _dk["ArtePierObra"]
	conferir("antes da compra a vaga 2 mostra as estacas velhas",
		pier.texture == _dk["ArtePierVazio"])
	var custo := int(_gs.ESTRUTURAS["pier_2"]["custo"])
	_gs.cash = maxi(int(_gs.cash), custo * 2)
	var comprou: bool = _gs.comprar_estrutura("pier_2")
	conferir("o píer 2 compra-se no dia %d" % int(_gs.turn), comprou,
		String(_gs.impedimento_estrutura("pier_2")))
	if not comprou:
		_desmontar(tela)
		return false
	var conclusao := int(_gs.obra_em_andamento["conclusao"])
	var dias := int(_gs.dias_da_obra("pier_2"))
	for d in range(dias):
		var quando := "no dia da compra" if d == 0 else "no dia %d da obra" % (d + 1)
		conferir("o píer mostra o quadro %d %s" % [d, quando], pier.texture == quadros[d],
			"textura %s" % (pier.texture.resource_path if pier.texture else "nenhuma"))
		conferir("o cartão diz «píer em obra» %s" % quando, progresso.text == "píer em obra",
			"«%s»" % progresso.text)
		conferir("o cartão diz o prazo do jogo %s («%s»)" % [quando, prazo.text],
			prazo.text == _gs.prazo_curto_da_obra(conclusao)
			and prazo.text.contains(str(conclusao)))
		if not _virar_o_dia():
			_desmontar(tela)
			return false
	conferir("pronto, o píer é o do nível 1 e não um quadro de obra",
		_gs.tem_estrutura("pier_2") and pier.texture == (_dk["ArtePier"] as Array)[0]
		and not quadros.has(pier.texture))
	conferir("pronto, o cartão deixa de dizer «píer em obra»",
		progresso.text != "píer em obra", "«%s»" % progresso.text)
	_desmontar(tela)
	return true


# ── §4 ─────────────────────────────────────────────────────────────────────
## O armazém, pela obra posta no estado e pelo sinal da compra — o caminho da
## compra de verdade é o do §3, e o calendário de abertura dele (semana 2) é
## o T17 que tranca. Aqui a pergunta é o que a CENA mostra em cada dia.
func _o_armazem() -> bool:
	_novo_jogo()
	var tela: Control = _montar()
	var armazem: TextureRect = tela.get_node("MapaWrap/Cenario/Armazem")
	var quadros: Array = _ok["ARMAZEM"]
	conferir("antes da obra o armazém é a ruína", armazem.texture == _mk["ArmazemRuina"])
	_comecar_obra("armazem")
	for d in range(int(_gs.dias_da_obra("armazem"))):
		conferir("o armazém mostra o quadro %d no dia %d da obra" % [d, d + 1],
			armazem.texture == quadros[d],
			"textura %s" % (armazem.texture.resource_path if armazem.texture else "nenhuma"))
		if not _virar_o_dia():
			_desmontar(tela)
			return false
	conferir("pronto, o armazém é o galpão pronto",
		_gs.tem_estrutura("armazem") and armazem.texture == _mk["ArmazemPronto"])
	_desmontar(tela)
	return true


func _o_patio() -> bool:
	_novo_jogo()
	var tela: Control = _montar()
	var canteiro: TextureRect = tela.get_node("MapaWrap/Cenario/CanteiroDoPatio")
	var asfalto: Polygon2D = tela.get_node("MapaWrap/AsfaltoDaObra")
	var mapa: TextureRect = tela.get_node("MapaWrap/Mapa")
	var cenario: Node = tela.get_node("MapaWrap/Cenario")
	var quadros: Array = _ok["CANTEIRO"]
	var fracoes: Array = _ok["ASFALTO_POR_QUADRO"]
	var velha: Polygon2D = tela.get_node("MapaWrap/RuaPorRecapear")
	var nova: Polygon2D = tela.get_node("MapaWrap/RuaRecapeada")
	conferir("antes da obra não há canteiro nem asfalto novo",
		not canteiro.visible and not asfalto.visible)
	# §6 — a ordem dos três recortes é a pergunta: a rua por recapear tem de
	# TAPAR o asfalto do pátio, que atravessa três cotovelos.
	conferir("a rua por recapear vem depois do asfalto do pátio, e a recapeada depois dela",
		asfalto.get_index() < velha.get_index() and velha.get_index() < nova.get_index())
	conferir("a rua por recapear recorta o mapa de terra, e a recapeada o pavimentado",
		velha.texture == _mk["MapaTerra"] and nova.texture == _mk["MapaPatio"])
	conferir("antes da obra não há rua recortada nem cones",
		not velha.visible and not nova.visible and _cones(cenario).is_empty())
	_confere_mobiliario(tela, -1, "antes da obra")
	_comecar_obra("patio")
	for d in range(int(_gs.dias_da_obra("patio"))):
		var dia := "no dia %d da obra" % (d + 1)
		conferir("o canteiro mostra o quadro %d %s" % [d, dia],
			canteiro.visible and canteiro.texture == quadros[d])
		conferir("a barreira e o cone sinalizam a obra, e a empilhadeira não está %s" % dia,
			(cenario.get_node("Barreira") as CanvasItem).visible
			and (cenario.get_node("ConeTransito") as CanvasItem).visible
			and not (cenario.get_node("Empilhadeira") as CanvasItem).visible)
		conferir("o chão de baixo continua a terra %s" % dia, mapa.texture == _mk["MapaTerra"])
		_confere_asfalto(asfalto, mapa, float(fracoes[d]), dia)
		_confere_rua(nova, d, true, dia)
		_confere_rua(velha, d, false, dia)
		_confere_cones(cenario, d, dia)
		_confere_cones(cenario, d, dia, "CavaleteDaRua", "cavaletes_da_obra")
		_confere_mobiliario(tela, d, dia)
		if not _virar_o_dia():
			_desmontar(tela)
			return false
	conferir("pronto, o mapa é o pavimentado, sem canteiro nem recorte por cima",
		_gs.tem_estrutura("patio") and mapa.texture == _mk["MapaPatio"]
		and not canteiro.visible and not asfalto.visible)
	conferir("pronto, sem rua recortada nem cones",
		not velha.visible and not nova.visible and _cones(cenario).is_empty()
		and _cones(cenario, "CavaleteDaRua").is_empty())
	_confere_mobiliario(tela, int(_ancoras["obra_dias"]), "com o pátio pronto")
	_desmontar(tela)
	return true


## O recorte contra os cantos que a TABELA publica, pela projeção dela: do
## avental até `fracao` da largura do pátio. E a UV contra a razão MEDIDA
## entre a textura e o rect do mapa, que é o que põe o pixel certo do mapa
## pronto no sítio certo.
func _confere_asfalto(asfalto: Polygon2D, mapa: TextureRect, fracao: float, dia: String) -> void:
	if fracao <= 0.0:
		conferir("sem asfalto novo %s (o dia da brita)" % dia, not asfalto.visible)
		return
	var tabela: Array = _ancoras["patio"]
	var grupos: Array = asfalto.polygons
	conferir("o asfalto novo aparece %s, um quadrilátero por trecho do pátio" % dia,
		asfalto.visible and grupos.size() == tabela.size(),
		"%d grupos, %d trechos" % [grupos.size(), tabela.size()])
	if grupos.size() != tabela.size():
		return
	var pontos := asfalto.polygon
	var certo := true
	var detalhe := ""
	for i in range(tabela.size()):
		var t: Dictionary = tabela[i]
		var rua := float(t["mx"][0])
		var avental := float(t["mx"][1])
		var frente := avental - fracao * (avental - rua)
		var cantos := [_tela(frente, float(t["my"][0])), _tela(avental, float(t["my"][0])),
			_tela(avental, float(t["my"][1])), _tela(frente, float(t["my"][1]))]
		var ids: PackedInt32Array = grupos[i]
		if ids.size() != 4:
			certo = false
			detalhe = "o trecho %d tem %d vértices" % [i, ids.size()]
			continue
		for k in range(4):
			if pontos[ids[k]].distance_to(cantos[k]) > 0.05:
				certo = false
				detalhe = "trecho %d, canto %d: %s contra %s" % [i, k, pontos[ids[k]], cantos[k]]
	conferir("o asfalto vai do avental a %d%% do pátio %s, nos cantos da tabela"
		% [roundi(fracao * 100.0), dia], certo, detalhe)
	var razao := float(asfalto.texture.get_width()) / mapa.size.x
	var uv_certa := asfalto.uv.size() == pontos.size() and razao > 1.0
	for k in range(mini(asfalto.uv.size(), pontos.size())):
		uv_certa = uv_certa and asfalto.uv[k].distance_to(pontos[k] * razao) < 0.01
	conferir("a UV do recorte é o vértice × %.3f, a razão textura/rect %s" % [razao, dia],
		uv_certa)


# ── §6 ─────────────────────────────────────────────────────────────────────
func _contrato_da_rua() -> void:
	var dias := (_ok["CANTEIRO"] as Array).size()
	conferir("a tabela conta os mesmos dias de obra que o canteiro (%d)" % dias,
		int(_ancoras.get("obra_dias", -1)) == dias)
	var tabela: Array = _ancoras.get("obra_da_rua", [])
	var copia: Array = _ok["RUA"]
	conferir("a obra da rua da tabela tem %d pedaço(s), e a cópia tantos quantos" % tabela.size(),
		not tabela.is_empty() and tabela.size() == copia.size(),
		"tabela %d, cópia %d" % [tabela.size(), copia.size()])
	var por_dia := {}
	for i in range(mini(tabela.size(), copia.size())):
		var t: Dictionary = tabela[i]
		por_dia[int(t["quadro"])] = true
		conferir("o pedaço %d da obra da rua é o da tabela" % i,
			_igual(t, copia[i]), "cópia %s" % [copia[i]])
	# Um trecho em cada dia e o último no fim: sem isto, um pedaço no dia 0
	# a mais recapeava a rua inteira de uma vez, e tudo o resto passava.
	var cada_dia := true
	for q in range(dias + 1):
		cada_dia = cada_dia and por_dia.has(q)
	conferir("a rua recapeia por partes: um trecho em cada dia e o último no fim (%s)"
		% [por_dia.keys()], cada_dia and por_dia.size() == dias + 1)
	var cones_t: Array = _ancoras.get("cones_da_obra", [])
	var cones_c: Array = _ok["CONES"]
	conferir("um grupo de cones por dia de obra, na tabela e na cópia (%d e %d)"
		% [cones_t.size(), cones_c.size()], cones_t.size() == dias and cones_c.size() == dias)
	for i in range(mini(cones_t.size(), cones_c.size())):
		conferir("os cones do dia %d são os da tabela" % i, _igual(cones_t[i], cones_c[i]))


## Um pedaço (ou um grupo de cones) da cópia contra o da tabela: o dia e cada
## ponto, à mesma tolerância do pátio.
func _igual(t: Dictionary, c: Array) -> bool:
	var pts: Array = t["pontos"]
	var vs: Array = c[1]
	if int(t["quadro"]) != int(c[0]) or pts.size() != vs.size():
		return false
	for k in range(vs.size()):
		var v: Vector2 = vs[k]
		if absf(v.x - float(pts[k][0])) >= 0.0005 or absf(v.y - float(pts[k][1])) >= 0.0005:
			return false
	return true


## Um recorte da rua no dia `d`: os pedaços prontos (`prontos`) ou os que
## faltam, contra a TABELA, pela projeção dela.
func _confere_rua(no: Polygon2D, d: int, prontos: bool, dia: String) -> void:
	var esperado: Array = []
	for t in _ancoras["obra_da_rua"]:
		if (int(t["quadro"]) <= d) == prontos:
			esperado.append(t["pontos"])
	var nome := "a rua recapeada" if prontos else "a rua por recapear"
	var grupos: Array = no.polygons
	conferir("%s mostra %d pedaço(s) %s" % [nome, esperado.size(), dia],
		no.visible == not esperado.is_empty() and grupos.size() == esperado.size(),
		"%d grupos, visível %s" % [grupos.size(), no.visible])
	if grupos.size() != esperado.size():
		return
	var certo := true
	for i in range(esperado.size()):
		var ids: PackedInt32Array = grupos[i]
		var pts: Array = esperado[i]
		if ids.size() != pts.size():
			certo = false
			continue
		for k in range(pts.size()):
			if no.polygon[ids[k]].distance_to(_tela(float(pts[k][0]), float(pts[k][1]))) > 0.05:
				certo = false
	conferir("%s cai nos pedaços da tabela %s" % [nome, dia], certo)


## Os três cones do dia (ou os dois cavaletes entre eles, `140`), nos pontos
## da tabela, e cada um entre os irmãos de cima e os de baixo na tela — a
## profundidade do `Cenario` é a ordem.
func _confere_cones(cenario: Node, d: int, dia: String, prefixo := "ConeDaRua",
		lista := "cones_da_obra") -> void:
	var cones := _cones(cenario, prefixo)
	var esperado: Array = []
	for t in _ancoras[lista]:
		if int(t["quadro"]) == d:
			esperado = t["pontos"]
	var quem := "cones" if prefixo == "ConeDaRua" else "cavaletes"
	conferir("%d %s na frente da obra %s" % [esperado.size(), quem, dia],
		not esperado.is_empty() and cones.size() == esperado.size(), "há %d" % cones.size())
	var no_sitio := cones.size() == esperado.size()
	var na_ordem := true
	var onde := ""
	for c in cones:
		var pe := (c as Control).position + Vector2(PropIso.MEIO, PropIso.MEIO)
		var achou := false
		for v in esperado:
			achou = achou or pe.distance_to(_tela(float(v[0]), float(v[1]))) < 0.05
		no_sitio = no_sitio and achou
		var i := (c as Node).get_index()
		var y := (c as Control).position.y
		for j in range(cenario.get_child_count()):
			var outro := cenario.get_child(j) as Control
			if outro == null or outro == c:
				continue
			if (j < i and outro.position.y > y + 0.5) or (j > i and outro.position.y < y - 0.5):
				na_ordem = false
				onde = "%s (y %.1f, índice %d) e %s (y %.1f, índice %d)" \
					% [c.name, y, i, outro.name, outro.position.y, j]
	conferir("os %s ficam nos pontos da tabela %s" % [quem, dia], no_sitio)
	conferir("cada um dos %s fica entre os irmãos pela profundidade %s" % [quem, dia],
		na_ordem, onde)


func _cones(cenario: Node, prefixo := "ConeDaRua") -> Array:
	var out: Array = []
	for no in cenario.get_children():
		if String(no.name).begins_with(prefixo):
			out.append(no)
	return out


# ── §7 ─────────────────────────────────────────────────────────────────────
## A guia rebaixada de cada lado da boca do acesso (`ABA` do gerador). A
## placa fica fora dela por mais folga ainda (`FOLGA_DA_PLACA`); a guarda
## pede só a guia, que é o que tem de ficar livre — quem gera é mais folgado
## do que quem confere (`mapa.md`, os limiares iguais).
const GUIA_DO_ACESSO := 0.22
## O raio, em pixels do PNG, em que o fio tem de achar o isolador. Medido no
## poste velho da segunda passagem (`140`): as três pontas certas acertam já a
## 1 px; sem o tombo de 6°, duas das três só tocam um isolador a 3 px — e a
## terceira cai em cheio no isolador VIZINHO, porque o tombo anda a ponta
## quase a distância entre os dois da direita. O corte vai a meio, e é a
## contagem dos três fios que apanha o poste direito no lugar do torto.
const RAIO_DO_ISOLADOR := 2
## O isolador é a peça mais clara do poste, e é por aí que se acha: os
## pixels opacos acima disto, na luminância de 0 a 1. Medido nos mesmos PNG:
## o isolador dá 0,72 a 0,74, e a peça clara seguinte, o concreto novo, 0,60
## no p90 — o corte vai a meio.
const LUZ_DO_ISOLADOR := 0.66
## Os fios de cada vão (`140`, terceira passagem: eram três e liam pesados).
const FIOS_POR_VAO := 2


func _contrato_do_mobiliario() -> void:
	var tabela: Array = _ancoras.get("mobiliario_da_rua", [])
	var copia: Array = _ok["MOBILIARIO"]
	conferir("o mobiliário da tabela tem %d peça(s), e a cópia tantas quantas" % tabela.size(),
		not tabela.is_empty() and tabela.size() == copia.size(),
		"tabela %d, cópia %d" % [tabela.size(), copia.size()])
	for i in range(mini(tabela.size(), copia.size())):
		var t: Dictionary = tabela[i]
		var c: Array = copia[i]
		var v: Vector2 = c[1]
		conferir("a peça %d do mobiliário (%s) é a da tabela" % [i, t["tipo"]],
			String(c[0]) == String(t["tipo"]) and int(c[2]) == int(t["quadro"])
			and absf(v.x - float(t["ponto"][0])) < 0.0005
			and absf(v.y - float(t["ponto"][1])) < 0.0005,
			"cópia %s, tabela %s" % [c, t])
	var cav_t: Array = _ancoras.get("cavaletes_da_obra", [])
	var cav_c: Array = _ok["CAVALETES"]
	var dias := int(_ancoras.get("obra_dias", -1))
	conferir("um par de cavaletes por dia de obra, na tabela e na cópia (%d e %d)"
		% [cav_t.size(), cav_c.size()], cav_t.size() == dias and cav_c.size() == dias)
	for i in range(mini(cav_t.size(), cav_c.size())):
		conferir("os cavaletes do dia %d são os da tabela" % i, _igual(cav_t[i], cav_c[i]))

	# NA CALÇADA DO LADO DELA. A tabela publica a rua (asfalto e calçadas) e o
	# asfalto de cada faixa; o poste vive entre a borda da rua e o asfalto do
	# lado da vila, e a placa do outro lado. O D2 isenta-os de «fora do
	# asfalto» pelo nome, porque a calçada é rua para ele — é aqui que se
	# pergunta onde eles pousam de verdade.
	var na_calcada := true
	var onde := ""
	for t in tabela:
		var x := float(t["ponto"][0])
		var y := float(t["ponto"][1])
		if String(t["tipo"]) == "quina":
			# O poste da quina vive no arco da calçada de fora do cotovelo:
			# concêntrico com o do asfalto, entre o raio dele e o raio mais a
			# calçada, e no quadrante da quina (`mx` baixo, `my` alto).
			var na_quina := false
			for cot in _ancoras["cotovelos"]:
				var r := float(cot["raio"])
				var largura := float(cot["asfalto_mx"][0]) - float(cot["mx"][0])
				var centro := Vector2(float(cot["asfalto_mx"][0]) + r,
					float(cot["asfalto_my"][1]) - r)
				var dist := Vector2(x, y).distance_to(centro)
				if dist > r and dist < r + largura and x < centro.x and y > centro.y:
					na_quina = true
			if not na_quina:
				na_calcada = false
				onde = "quina em (%.2f, %.2f) fora do arco da calçada de fora de um cotovelo" % [x, y]
			continue
		var faixa := _faixa_de(y)
		var rua: Array = faixa["rua"]
		var asf: Array = faixa["asfalto"]
		var ok: bool
		if String(t["tipo"]) == "poste":
			ok = x > float(rua[0]) and x < float(asf[0])
		else:
			ok = x > float(asf[1]) and x < float(rua[1])
		for cot in _ancoras["cotovelos"]:
			if x > float(cot["mx"][0]) and x < float(cot["mx"][1]) \
					and y > float(cot["my"][0]) and y < float(cot["my"][1]):
				ok = false
		for a in _ancoras["acessos"]:
			if x > float(asf[1]) and y > float(a["my"][0]) - GUIA_DO_ACESSO \
					and y < float(a["my"][1]) + GUIA_DO_ACESSO:
				ok = false
		if not ok:
			na_calcada = false
			onde = "%s em (%.2f, %.2f): rua %s, asfalto %s" % [t["tipo"], x, y, rua, asf]
	conferir("cada peça do mobiliário pousa na calçada do lado dela, fora do cotovelo e da guia do acesso",
		na_calcada, onde)

	# E NO DIA DO TRECHO ONDE POUSA: o poste troca no dia em que o asfalto do
	# pedaço de rua debaixo dele troca — a reta, ou o cotovelo para o poste da
	# quina. Cada pedaço da obra da rua vai até ao meio das duas calçadas, e a
	# peça pousa nessa borda: conta o pedaço cuja caixa a contém, com 0,01 de
	# folga, e todos os que a contêm têm de concordar.
	var no_dia := true
	for t in tabela:
		var x := float(t["ponto"][0])
		var y := float(t["ponto"][1])
		var achou := -1
		for pedaco in _ancoras["obra_da_rua"]:
			var xs: Array = []
			var ys: Array = []
			for pt in pedaco["pontos"]:
				xs.append(float(pt[0]))
				ys.append(float(pt[1]))
			if x >= float(xs.min()) - 0.01 and x <= float(xs.max()) + 0.01 \
					and y >= float(ys.min()) - 0.01 and y <= float(ys.max()) + 0.01:
				if achou >= 0 and achou != int(pedaco["quadro"]):
					achou = -2
					break
				achou = int(pedaco["quadro"])
		if achou != int(t["quadro"]):
			no_dia = false
			onde = "%s em (%.2f, %.2f): quadro %d, a reta dele é do %d" \
				% [t["tipo"], x, y, int(t["quadro"]), achou]
	conferir("cada peça do mobiliário troca no dia da reta de rua onde pousa", no_dia, onde)


func _faixa_de(my: float) -> Dictionary:
	for f in _ancoras["faixas"]:
		if my >= float(f["my"][0]) and my < float(f["my"][1]):
			return f
	return {}


## O mobiliário no dia `d` da obra do pátio — −1 antes dela, `obra_dias`
## com o pátio pronto: cada peça com a arte velha ou a nova pelo dia do
## trecho DELA, no ponto da tabela; e a rede da rua antes do `Cenario`: a
## lâmpada de sódio só no poste velho, no quadro dele, e cada fio a ligar
## dois postes vizinhos com cada ponta pousada num isolador do poste que se
## VÊ.
func _confere_mobiliario(tela: Control, d: int, dia: String) -> void:
	var cenario: Node = tela.get_node("MapaWrap/Cenario")
	var rede := tela.get_node_or_null("MapaWrap/RedeDaRua")
	conferir("a rede da rua desenha-se logo antes do Cenario, debaixo de todo prop %s" % dia,
		rede != null and rede.get_index() == cenario.get_index() - 1)
	if rede == null:
		return
	var tabela: Array = _ancoras["mobiliario_da_rua"]
	var arte: Dictionary = _ok["ARTE_DO_MOBILIARIO"]
	var certo := true
	var luz_certa := true
	var onde := ""
	var postes := {}
	for i in range(tabela.size()):
		var t: Dictionary = tabela[i]
		var tipo := String(t["tipo"])
		var nova := int(t["quadro"]) <= d
		var e_poste := tipo == "poste" or tipo == "quina"
		var no := cenario.get_node_or_null(
			("PosteDaRua%d" if e_poste else "PlacaDaRua%d") % i) as TextureRect
		var pe := _tela(float(t["ponto"][0]), float(t["ponto"][1]))
		if no == null or no.texture != arte[tipo][1 if nova else 0] \
				or (no.position + Vector2(PropIso.MEIO, PropIso.MEIO)).distance_to(pe) > 0.05:
			certo = false
			onde = "peça %d (%s, quadro %d)" % [i, tipo, int(t["quadro"])]
			continue
		if not e_poste:
			continue
		postes[i] = no
		var luz := rede.get_node_or_null("PosteLuzDaRua%d" % i) as TextureRect
		if luz == null or luz.visible == nova or luz.position != no.position:
			luz_certa = false
	conferir("cada peça do mobiliário mostra a arte do trecho dela %s" % dia, certo, onde)
	conferir("a lâmpada de sódio acende só no poste velho, no quadro dele, %s" % dia, luz_certa)

	# Os vãos, pela TABELA: os postes da calçada da vila em fila pelo `my` —
	# a rua desce sempre, e o da quina fica entre a reta de cima e a de baixo
	# —, cada um ligado ao seguinte.
	var vaos := {}
	var fila: Array = postes.keys()
	fila.sort_custom(func(a, b): return float(tabela[a]["ponto"][1]) < float(tabela[b]["ponto"][1]))
	for j in range(fila.size() - 1):
		vaos["%d-%d" % [mini(fila[j], fila[j + 1]), maxi(fila[j], fila[j + 1])]] = true
	var fios: Array = []
	for f in rede.get_children():
		if f is Line2D:
			fios.append(f)
	# Dois fios por vão, escolha do Bruno na terceira passagem (eram três).
	conferir("dois fios em cada vão de poste a poste, a virar nas quinas (%d vãos) %s"
		% [vaos.size(), dia], not vaos.is_empty() and fios.size() == vaos.size() * FIOS_POR_VAO,
		"há %d fios" % fios.size())
	var nos_isoladores := true
	var vistos := {}
	for f in fios:
		var pontos: PackedVector2Array = (f as Line2D).points
		if pontos.size() < 2:
			nos_isoladores = false
			continue
		var a := _poste_do_isolador(pontos[0], postes)
		var b := _poste_do_isolador(pontos[pontos.size() - 1], postes)
		var chave := "%d-%d" % [mini(a, b), maxi(a, b)]
		if a < 0 or b < 0 or not vaos.has(chave):
			nos_isoladores = false
			onde = "%s: pontas em %s e %s, postes %d e %d" \
				% [f.name, pontos[0], pontos[pontos.size() - 1], a, b]
		vistos[chave] = int(vistos.get(chave, 0)) + 1
	conferir("cada fio liga dois postes vizinhos e pousa num isolador de cada %s" % dia,
		nos_isoladores, onde)
	var cada_vao := vistos.size() == vaos.size()
	for v in vistos.values():
		cada_vao = cada_vao and int(v) == FIOS_POR_VAO
	conferir("cada vão leva os seus dois fios %s" % dia, cada_vao, "%s" % [vistos])


## O poste de cujo ISOLADOR sai o ponto `p` (espaço do mapa), ou −1: o pixel
## do PNG do poste, na textura que ele mostra, à volta do ponto tem de ter
## a peça clara do isolador. Lê o desenho, e não a conta do `ObraNoMapa`.
func _poste_do_isolador(p: Vector2, postes: Dictionary) -> int:
	for i in postes.keys():
		var no: TextureRect = postes[i]
		var img := PropIso.imagem(no.texture)
		var k := PropIso.escala(no.texture)
		var px := (p - no.position) / k
		for dy in range(-RAIO_DO_ISOLADOR, RAIO_DO_ISOLADOR + 1):
			for dx in range(-RAIO_DO_ISOLADOR, RAIO_DO_ISOLADOR + 1):
				var x := roundi(px.x) + dx
				var y := roundi(px.y) + dy
				if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
					continue
				var c := img.get_pixel(x, y)
				if c.a > 0.5 and c.get_luminance() > LUZ_DO_ISOLADOR:
					return int(i)
	return -1


# ── §5 ─────────────────────────────────────────────────────────────────────
func _tres_dias_em_dois_quadros() -> void:
	_novo_jogo()
	var t := int(_gs.turn)
	_gs.obra_em_andamento = {"id": "pier_3", "inicio": t, "conclusao": t + 3}
	var vistos: Array = []
	for d in range(3):
		_gs.turn = t + d
		vistos.append(int(_gs.quadro_da_obra("pier_3", 2)))
	conferir("três dias em dois quadros dão 0, 0, 1 — o último no último dia %s" % [vistos],
		vistos == [0, 0, 1])
	conferir("outra obra não dá quadro ao píer 3", int(_gs.quadro_da_obra("armazem", 2)) == -1)
	_gs.turn = t
	_gs.obra_em_andamento = {}


# ── utilitários ────────────────────────────────────────────────────────────
func _novo_jogo() -> void:
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	_gs.definir_nomes(_gs.NOME_PORTO_PADRAO, "")
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)


func _montar() -> Control:
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	return tela


func _desmontar(tela: Control) -> void:
	_arvore.root.remove_child(tela)
	tela.free()


## A obra posta no estado como o `comprar_estrutura()` a põe, e anunciada pelo
## MESMO sinal — é por ele que o `Main` redesenha no dia da compra.
func _comecar_obra(id: String) -> void:
	var t := int(_gs.turn)
	_gs.obra_em_andamento = {"id": id, "inicio": t, "conclusao": t + int(_gs.dias_da_obra(id))}
	_gs.estrutura_comprada.emit(id)


## A virada do jogo, e só ela: se uma oferta do Arlindo fechar o dia, resolve-a
## e confere que o dia andou — o `advance_turn()` volta calado fora de jogo.
func _virar_o_dia() -> bool:
	var antes := int(_gs.turn)
	_gs.advance_turn()
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)
	var andou := int(_gs.turn) == antes + 1
	if not andou:
		conferir("o dia %d virou" % antes, false, "fase «%s»" % _gs.phase)
	return andou


func _tela(mx: float, my: float) -> Vector2:
	var pr: Dictionary = _ancoras["projecao"]
	return Vector2(float(pr["cx"]) + (mx - my) * float(pr["meia_larg"]),
		float(pr["cy"]) + (mx + my) * float(pr["meia_alt"]) - float(pr["alt_cais"]))
