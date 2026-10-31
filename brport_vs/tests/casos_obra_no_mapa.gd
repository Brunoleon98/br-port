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
#      no que já está pronto) e os dois cones na frente, entre os irmãos do
#      `Cenario` pela profundidade. O D49 mede nos mapas que nada muda fora.
#   §7 o MOBILIÁRIO DA RUA (`140`): a cópia dos postes, das placas e dos
#      cavaletes contra a tabela; cada peça no pedaço de calçada do tipo dela
#      (os postes na da vila — reta, curva de fora, quina de dentro —, a de
#      pedestres na do pátio do cotovelo, o PARE e a de 40 na do porto, fora
#      da boca do acesso), reconstruído da tabela, e com o dia do trecho de
#      rua onde pousa; a planta da fiação por cima da calçada da vila, sem
#      cortar a curva nem o lote da esquina; e, dia a dia, a arte velha ou a
#      nova pelo trecho, a lâmpada de sódio só no poste velho, o cavalete
#      entre os cones e cada fio da fiação pousado num ISOLADOR do poste que
#      se vê — lido no PNG dele, e não na conta que o desenha.
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

	# Cada sub-bloco devolve `true` na última linha, e reprova aqui pelo nome se
	# um erro de execução o abortar a meio — senão só ele morria e a bandeira
	# do bloco ficava verde (`testes-e-guardas.md`, «um sub-bloco leva a sua
	# BANDEIRA»). Os três de baixo já o faziam; os contratos não.
	conferir("o contrato com a tabela correu até ao fim", _contrato_com_a_tabela() == true)
	conferir("o contrato da rua correu até ao fim", _contrato_da_rua() == true)
	conferir("o contrato do mobiliário correu até ao fim", _contrato_do_mobiliario() == true)
	conferir("o quadro por dia correu até ao fim", _um_quadro_por_dia() == true)
	conferir("o píer comprado correu até ao fim", _o_pier_comprado())
	conferir("o armazém correu até ao fim", _o_armazem())
	conferir("o pátio correu até ao fim", _o_patio())
	conferir("os três dias em dois quadros correram até ao fim",
		_tres_dias_em_dois_quadros() == true)
	_gs.clear_save()
	completo = true


# ── §1 ─────────────────────────────────────────────────────────────────────
func _contrato_com_a_tabela() -> bool:
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
	return true


# ── §2 ─────────────────────────────────────────────────────────────────────
func _um_quadro_por_dia() -> bool:
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
	return true


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
	# Os ajudantes que conferem devolvem `true` na última linha, e o pátio só
	# devolve o dele se todos o devolveram.
	var correram: Array = []
	correram.append(_confere_mobiliario(tela, -1, "antes da obra") == true)
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
		correram.append(_confere_asfalto(asfalto, mapa, float(fracoes[d]), dia) == true)
		correram.append(_confere_rua(nova, d, true, dia) == true)
		correram.append(_confere_rua(velha, d, false, dia) == true)
		correram.append(_confere_cones(cenario, d, dia) == true)
		correram.append(_confere_cones(cenario, d, dia, "CavaleteDaRua",
			"cavaletes_da_obra") == true)
		correram.append(_confere_mobiliario(tela, d, dia) == true)
		if not _virar_o_dia():
			_desmontar(tela)
			return false
	conferir("pronto, o mapa é o pavimentado, sem canteiro nem recorte por cima",
		_gs.tem_estrutura("patio") and mapa.texture == _mk["MapaPatio"]
		and not canteiro.visible and not asfalto.visible)
	conferir("pronto, sem rua recortada nem cones",
		not velha.visible and not nova.visible and _cones(cenario).is_empty()
		and _cones(cenario, "CavaleteDaRua").is_empty())
	correram.append(_confere_mobiliario(tela, int(_ancoras["obra_dias"]),
		"com o pátio pronto") == true)
	_desmontar(tela)
	return not correram.has(false)


## O recorte contra os cantos que a TABELA publica, pela projeção dela: do
## avental até `fracao` da largura do pátio. E a UV contra a razão MEDIDA
## entre a textura e o rect do mapa, que é o que põe o pixel certo do mapa
## pronto no sítio certo.
func _confere_asfalto(asfalto: Polygon2D, mapa: TextureRect, fracao: float, dia: String) -> bool:
	if fracao <= 0.0:
		conferir("sem asfalto novo %s (o dia da brita)" % dia, not asfalto.visible)
		return true
	var tabela: Array = _ancoras["patio"]
	var grupos: Array = asfalto.polygons
	conferir("o asfalto novo aparece %s, um quadrilátero por trecho do pátio" % dia,
		asfalto.visible and grupos.size() == tabela.size(),
		"%d grupos, %d trechos" % [grupos.size(), tabela.size()])
	if grupos.size() != tabela.size():
		return true
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
	return true


# ── §6 ─────────────────────────────────────────────────────────────────────
func _contrato_da_rua() -> bool:
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
	return true


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
func _confere_rua(no: Polygon2D, d: int, prontos: bool, dia: String) -> bool:
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
		return true
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
	return true


## Os cones do dia (ou o cavalete entre eles, `140`), nos pontos da tabela, e cada um entre os irmãos de cima e os de baixo na tela — a
## profundidade do `Cenario` é a ordem.
func _confere_cones(cenario: Node, d: int, dia: String, prefixo := "ConeDaRua",
		lista := "cones_da_obra") -> bool:
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
	return true


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
## Quanto se anda da peça para o lado da rua até ao asfalto de que ela é: a
## meia calçada (0,11) e um pouco, para cair dentro do pedaço e não na borda.
const PASSO_PARA_A_RUA := 0.15
## Os tipos que são poste, ligados pela fiação. Escritos aqui, e não lidos do
## `GIRO_DO_POSTE` do jogo: um poste que o jogo tomasse por placa tem de
## reprovar, e não sair da conta dos dois lados.
const TIPOS_DE_POSTE := ["ramal", "poste", "curva_a", "curva_b", "quina"]
## Os postes da linha que chega à subestação, ligados pela ordem da tabela,
## antes dos da rua, e sem luz (quarta passagem).
const TIPOS_DA_LINHA := ["torre", "portico", "saida"]
## Os que levam luminária, e a lâmpada de sódio quando velhos: todos os da
## rua. O da quina de dentro esteve uma passagem sem ela, e voltou a tê-la.
const TIPOS_COM_LUZ := ["ramal", "poste", "curva_a", "curva_b", "quina"]
## O pedaço de calçada (`_meio_da_calcada()`) de cada tipo da rua que não é
## placa da reta do porto. A de pedestres vive na calçada da vila desde a
## quarta passagem, como os postes da reta.
const LUGAR_DO_TIPO := {"ramal": "reta", "poste": "reta", "curva_a": "curva",
	"curva_b": "curva", "quina": "quina", "pedestres": "reta"}
## O que não é da rua e pousa no campo ao norte do pátio: a subestação e a
## linha que lhe chega (`_no_campo()`).
const NO_CAMPO := ["subestacao", "torre", "portico", "saida"]
## As colunas de tela de cada lado do pé que a máscara da vila cobre (o
## `MASCARA_LADO` do gerador), e o fundo do mapa, que é «nada à frente».
const MASCARA_LADO := 40
const FUNDO_DO_MAPA := 720.0
## A distância mínima do pé de um poste da linha, ou da caixa da subestação,
## ao pé de uma planta da restinga: meia copa da aroeira, que é a maior ali.
const FOLGA_DA_PLANTA := 0.3
## Os pontos em que se amostra a planta de cada vão da fiação.
const AMOSTRAS_DO_VAO := 40
## O mais que a planta de um vão se pode afastar do meio da calçada da vila.
## O certo dá 0,113 (a corda de 45° no arco de fora); a rede da terceira
## passagem, 0,349 na curva cortada e 0,891 no lote da esquina. O corte vai
## a meio, uma calçada inteira.
const FIO_FORA_DA_CALCADA := 0.22
## Ao pixel do topo do lote, o vértice pode estar de qualquer dos lados: o
## jogo decide-o pela coluna arredondada e este bloco também, mas o topo
## publicado vai a 0,1 e o antisserrilhado é de um pixel.
const MARGEM_DO_TAPUME := 1.0


func _contrato_do_mobiliario() -> bool:
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
	conferir("um grupo de cavaletes por dia de obra, na tabela e na cópia (%d e %d)"
		% [cav_t.size(), cav_c.size()], cav_t.size() == dias and cav_c.size() == dias)
	for i in range(mini(cav_t.size(), cav_c.size())):
		conferir("os cavaletes do dia %d são os da tabela" % i, _igual(cav_t[i], cav_c[i]))
	var atras_t: Array = _ancoras.get("fiacao_atras_da_vila", [])
	var atras_c: Array = _ok["FIACAO_ATRAS_DA_VILA"]
	var atras_igual := not atras_t.is_empty() and atras_t.size() == atras_c.size()
	for i in range(mini(atras_t.size(), atras_c.size())):
		var t: Dictionary = atras_t[i]
		var c: Array = atras_c[i]
		var tt: Array = t["teto"]
		var ct: Array = c[3]
		atras_igual = atras_igual and int(t["vao"][0]) == int(c[0]) \
			and int(t["vao"][1]) == int(c[1]) and int(t["x0"]) == int(c[2]) \
			and tt.size() == ct.size()
		for k in range(mini(tt.size(), ct.size())):
			atras_igual = atras_igual and absf(float(tt[k]) - float(ct[k])) < 0.05
	conferir("o que a vila tapa da fiação (%d vãos) é o da tabela" % atras_t.size(), atras_igual)
	var masc_t: Array = _ancoras.get("mascara_da_vila", [])
	var masc_c: Array = _ok["MASCARA_DA_VILA"]
	var masc_igual := not masc_t.is_empty() and masc_t.size() == masc_c.size()
	for i in range(mini(masc_t.size(), masc_c.size())):
		var t: Dictionary = masc_t[i]
		var c: Array = masc_c[i]
		var tt: Array = t["teto"]
		var ct: Array = c[2]
		masc_igual = masc_igual and int(t["peca"]) == int(c[0]) and int(t["x0"]) == int(c[1]) \
			and tt.size() == ct.size()
		for k in range(mini(tt.size(), ct.size())):
			masc_igual = masc_igual and absf(float(tt[k]) - float(ct[k])) < 0.05
	conferir("o que a vila tapa das peças (%d) é o da tabela" % masc_t.size(), masc_igual)

	# NA CALÇADA DO LADO DELA. O D2 isenta-os de «fora do asfalto» pelo nome,
	# porque a calçada é rua para ele — é aqui que se pergunta onde eles
	# pousam de verdade. Cada tipo no pedaço de calçada dele, que se
	# reconstrói da tabela (`_meio_da_calcada()`): o poste na reta da vila, os
	# das curvas no arco de fora do cotovelo e o da quina no de dentro, a de
	# pedestres na reta da vila também; o PARE e a de 40 na reta do porto,
	# fora da guia do acesso; e a subestação e a linha no campo do norte.
	var na_calcada := true
	var onde := ""
	var meia := _calcada() / 2.0
	for t in tabela:
		var x := float(t["ponto"][0])
		var y := float(t["ponto"][1])
		var tipo := String(t["tipo"])
		if NO_CAMPO.has(tipo):
			var fora := _no_campo(tipo, Vector2(x, y))
			if fora != "":
				na_calcada = false
				onde = fora
			continue
		if LUGAR_DO_TIPO.has(tipo):
			var dist := float(_meio_da_calcada(Vector2(x, y))[LUGAR_DO_TIPO[tipo]])
			if dist > meia:
				na_calcada = false
				onde = "%s em (%.2f, %.2f) a %.3f do meio da calçada %s" \
					% [tipo, x, y, dist, LUGAR_DO_TIPO[tipo]]
			continue
		var faixa := _faixa_de(y)
		var rua: Array = faixa["rua"]
		var asf: Array = faixa["asfalto"]
		var ok := x > float(asf[1]) and x < float(rua[1])
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
			onde = "%s em (%.2f, %.2f): rua %s, asfalto %s" % [tipo, x, y, rua, asf]
	conferir("cada peça do mobiliário pousa na calçada do lado dela, fora do cotovelo e da guia do acesso",
		na_calcada, onde)

	# E A FIAÇÃO POR CIMA DA CALÇADA DA VILA (quarta passagem): *«fio corta o
	# cotovelo»*, *«fio por cima das casas»*. Com um poste só a meio do arco
	# de fora, a corda dele até ao primeiro da reta de baixo atravessava o
	# lote da esquina — a igreja —, e a da reta de cima cortava o asfalto da
	# curva. A planta de cada vão é a reta entre os pés de dois postes
	# vizinhos (a fila pelo `my`, como a do jogo), e nenhum ponto dela se
	# afasta do meio da calçada mais do que `FIO_FORA_DA_CALCADA`.
	var postes: Array = []
	for t in tabela:
		if TIPOS_DE_POSTE.has(String(t["tipo"])):
			postes.append(Vector2(float(t["ponto"][0]), float(t["ponto"][1])))
	postes.sort_custom(func(a, b): return a.y < b.y)
	var pior := 0.0
	var vao := ""
	for j in range(postes.size() - 1):
		for s in range(AMOSTRAS_DO_VAO + 1):
			var p: Vector2 = (postes[j] as Vector2).lerp(postes[j + 1], float(s) / AMOSTRAS_DO_VAO)
			var perto := INF
			for lugar in ["reta", "curva", "cotovelo", "quina"]:
				perto = minf(perto, float(_meio_da_calcada(p)[lugar]))
			if perto > pior:
				pior = perto
				vao = "%s a %s" % [postes[j], postes[j + 1]]
	conferir("a fiação corre por cima da calçada da vila: o vão mais torto afasta-se %.3f do meio dela"
		% pior, postes.size() > 1 and pior <= FIO_FORA_DA_CALCADA, vao)

	# E NO DIA DO ASFALTO AO LADO DELA: a peça troca no dia em que o pedaço
	# de rua junto dela é recapeado — a reta, ou o cotovelo para as das
	# curvas, a da quina e a de pedestres.
	# ⚠️ A PEÇA POUSA NO MEIO DA CALÇADA, QUE É A FRONTEIRA ENTRE OS PEDAÇOS:
	# cada um vai até lá (`136`). Pela caixa, a placa de pedestres da reta 2
	# cabia também no pedacinho da quina de dentro do cotovelo seguinte, que é
	# de outro dia, e a pergunta não tinha resposta. O ponto que responde é o
	# do asfalto, a `PASSO_PARA_A_RUA` da peça para o lado da rua, pelo
	# polígono exato; e os pedaços onde ele cai são todos do dia da peça — na
	# quina de dentro o cotovelo e a reta de baixo sobrepõem-se, e são do
	# mesmo dia; na junta entre dois dias seriam dois, e reprova.
	var no_dia := true
	for t in tabela:
		var x := float(t["ponto"][0])
		var y := float(t["ponto"][1])
		var tipo := String(t["tipo"])
		var p := Vector2(x, y)
		if int(t["quadro"]) < 0:
			# Da cidade, e não da rua: não troca com a obra, e quem o diz é o
			# `_no_campo()` — a peça da rua com o quadro −1 cai lá e reprova.
			continue
		match tipo:
			"ramal", "poste", "pedestres":
				p.x += PASSO_PARA_A_RUA
			"curva_a", "curva_b":
				p += (_centro_da_curva(p) - p).normalized() * PASSO_PARA_A_RUA
			"quina":
				p += (p - _centro_da_quina(p)).normalized() * PASSO_PARA_A_RUA
			_:
				p.x -= PASSO_PARA_A_RUA
		var achados: Array = []
		for pedaco in _ancoras["obra_da_rua"]:
			var poli := PackedVector2Array()
			for pt in pedaco["pontos"]:
				poli.append(Vector2(float(pt[0]), float(pt[1])))
			if Geometry2D.is_point_in_polygon(p, poli):
				achados.append(int(pedaco["quadro"]))
		var certo := not achados.is_empty()
		for q in achados:
			certo = certo and int(q) == int(t["quadro"])
		if not certo:
			no_dia = false
			onde = "%s em (%.2f, %.2f): quadro %d, o asfalto ao lado é de %s" \
				% [tipo, x, y, int(t["quadro"]), achados]
	conferir("cada peça do mobiliário troca no dia do trecho de rua onde pousa", no_dia, onde)
	return true


## Vazio se a peça `tipo` em `p` pousa no campo ao norte do pátio: entre a
## calçada do porto da reta dela e a areia (`praias`), a norte do primeiro
## pátio, e longe das plantas da restinga (`mata`) — a subestação pela caixa
## inteira (`subestacao`), um poste pelo pé. Senão, o que falhou.
func _no_campo(tipo: String, p: Vector2) -> String:
	var meio := Vector2.ZERO
	if tipo == "subestacao":
		var sub: Dictionary = _ancoras["subestacao"]
		var c := Vector2(float(sub["centro"][0]), float(sub["centro"][1]))
		if c.distance_to(p) > 0.0005:
			return "a subestação em %s, e a caixa dela em %s" % [p, c]
		meio = Vector2(float(sub["tam"][0]), float(sub["tam"][1])) / 2.0
	var norte := float(_ancoras["patio"][0]["my"][0])
	var cantos := [p - meio, Vector2(p.x + meio.x, p.y - meio.y), p + meio,
		Vector2(p.x - meio.x, p.y + meio.y)]
	for k in cantos:
		var q: Vector2 = k
		var faixa := _faixa_de(q.y)
		if faixa.is_empty():
			return "%s em %s: o canto %s fora da rua" % [tipo, p, q]
		var areia := float(faixa["borda"])
		for praia in _ancoras["praias"]:
			if q.y >= float(praia["my"][0]) and q.y < float(praia["my"][1]):
				areia = float(faixa["borda"]) - float(praia["recuo"])
		if q.x <= float(faixa["rua"][1]) or q.x >= areia or q.y >= norte:
			return "%s em %s: o canto %s fora do campo (rua %s, areia %.2f, pátio a %.2f)" \
				% [tipo, p, q, faixa["rua"], areia, norte]
	for planta in _ancoras["mata"]:
		var pe := Vector2(float(planta["mx"]), float(planta["my"]))
		if absf(pe.x - p.x) < meio.x + FOLGA_DA_PLANTA and absf(pe.y - p.y) < meio.y + FOLGA_DA_PLANTA:
			return "%s em %s pisa a %s em %s" % [tipo, p, planta["arvore"], pe]
	return ""


## A largura da calçada, da tabela: do cerco do cotovelo ao asfalto dele.
func _calcada() -> float:
	var cot: Dictionary = _ancoras["cotovelos"][0]
	return float(cot["asfalto_mx"][0]) - float(cot["mx"][0])


## A distância de `p` ao MEIO de cada pedaço de calçada que a fiação e o
## mobiliário usam, reconstruído da tabela (`faixas` e `cotovelos`) e não da
## conta do gerador que os põe: `reta` (a da vila, entre duas curvas),
## `curva` (o arco de fora de cada cotovelo, concêntrico com o do asfalto),
## `cotovelo` (a da vila ao longo dele), `quina` (o arco de dentro, centrado
## do lado do lote, de raio `raio_dentro`) e `patio` (a do outro lado do
## cotovelo, entre a quina de dentro e o arco de fora). Os arcos só valem no
## quadrante deles; fora, a distância é infinita e quem responde é a reta ao
## lado.
func _meio_da_calcada(p: Vector2) -> Dictionary:
	var c := _calcada()
	var out := {"reta": INF, "curva": INF, "cotovelo": INF, "quina": INF, "patio": INF}
	var cots: Array = _ancoras["cotovelos"]
	var faixas: Array = _ancoras["faixas"]
	var topo := -INF
	for k in range(faixas.size()):
		var x := float(faixas[k]["asfalto"][0]) - c / 2.0
		var fim := INF
		if k < cots.size():
			var cot: Dictionary = cots[k]
			var r := float(cot["raio"])
			var rd := float(cot["raio_dentro"])
			var w := float(cot["asfalto_my"][1]) - float(cot["asfalto_my"][0])
			var ya := float(cot["asfalto_my"][0])
			var yb := float(cot["asfalto_my"][1])
			var fora := Vector2(float(cot["asfalto_mx"][0]) + r, yb - r)
			var d := float(cot["asfalto_mx"][1]) - w
			var dentro := Vector2(d - rd, yb + rd)
			fim = fora.y
			if p.x <= fora.x and p.y >= fora.y:
				out["curva"] = minf(out["curva"], absf(p.distance_to(fora) - (r + c / 2.0)))
			if p.x >= dentro.x and p.y <= dentro.y:
				out["quina"] = minf(out["quina"], absf(p.distance_to(dentro) - (rd - c / 2.0)))
			out["cotovelo"] = minf(out["cotovelo"], _ao_segmento(p,
				Vector2(fora.x, yb + c / 2.0), Vector2(dentro.x, yb + c / 2.0)))
			var f := float(cot["asfalto_mx"][0]) + w
			out["patio"] = minf(out["patio"], _ao_segmento(p,
				Vector2(f + rd, ya - c / 2.0), Vector2(float(cot["asfalto_mx"][1]) - r, ya - c / 2.0)))
		out["reta"] = minf(out["reta"], _ao_segmento(p, Vector2(x, maxf(topo, -1e6)),
			Vector2(x, minf(fim, 1e6))))
		if k < cots.size():
			var cot: Dictionary = cots[k]
			topo = float(cot["asfalto_my"][1]) + float(cot["raio_dentro"])
	return out


func _ao_segmento(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))


## O centro do arco de fora do cotovelo onde `p` pousa.
func _centro_da_curva(p: Vector2) -> Vector2:
	var melhor := Vector2.INF
	for cot in _ancoras["cotovelos"]:
		var r := float(cot["raio"])
		var c := Vector2(float(cot["asfalto_mx"][0]) + r, float(cot["asfalto_my"][1]) - r)
		if p.distance_to(c) < p.distance_to(melhor):
			melhor = c
	return melhor


## O centro do arco da quina de dentro do cotovelo onde `p` pousa.
func _centro_da_quina(p: Vector2) -> Vector2:
	var melhor := Vector2.INF
	for cot in _ancoras["cotovelos"]:
		var rd := float(cot["raio_dentro"])
		var w := float(cot["asfalto_my"][1]) - float(cot["asfalto_my"][0])
		var c := Vector2(float(cot["asfalto_mx"][1]) - w - rd, float(cot["asfalto_my"][1]) + rd)
		if p.distance_to(c) < p.distance_to(melhor):
			melhor = c
	return melhor


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
func _confere_mobiliario(tela: Control, d: int, dia: String) -> bool:
	var cenario: Node = tela.get_node("MapaWrap/Cenario")
	var rede := tela.get_node_or_null("MapaWrap/RedeDaRua")
	conferir("a rede da rua desenha-se logo antes do Cenario, debaixo de todo prop %s" % dia,
		rede != null and rede.get_index() == cenario.get_index() - 1)
	if rede == null:
		return true
	var tabela: Array = _ancoras["mobiliario_da_rua"]
	var arte: Dictionary = _ok["ARTE_DO_MOBILIARIO"]
	var certo := true
	var luz_certa := true
	var onde := ""
	var postes := {}
	for i in range(tabela.size()):
		var t: Dictionary = tabela[i]
		var tipo := String(t["tipo"])
		var nova := int(t["quadro"]) <= d or int(t["quadro"]) < 0
		var e_poste := TIPOS_DE_POSTE.has(tipo) or TIPOS_DA_LINHA.has(tipo)
		var nome := "PosteDaRua%d" if e_poste else "PlacaDaRua%d"
		if tipo == "subestacao":
			nome = "SubestacaoDaRede%d"
		var no := cenario.get_node_or_null(nome % i) as TextureRect
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
		if not TIPOS_COM_LUZ.has(tipo):
			luz_certa = luz_certa and luz == null
		elif luz == null or luz.visible == nova or luz.position != no.position:
			luz_certa = false
	conferir("cada peça do mobiliário mostra a arte do trecho dela %s" % dia, certo, onde)
	# ATRÁS DA VILA, ESCONDIDA (quinta passagem): a sombra do poste da curva
	# pintava-se por cima da igreja, que lhe fica à frente. Cada pixel opaco
	# de cada peça (e da lâmpada dela) que cai abaixo do topo do lote à frente
	# do PÉ, refeito aqui dos `pecas_da_vila` da tabela, tem de estar debaixo
	# de uma máscara com esse mesmo topo; e o controle de que há algum.
	var mascara := {"erros": 0, "tapados": 0, "onde": ""}
	for i in range(tabela.size()):
		var t: Dictionary = tabela[i]
		var pe := Vector2(float(t["ponto"][0]), float(t["ponto"][1]))
		var nome := "PosteDaRua%d" if (TIPOS_DE_POSTE.has(String(t["tipo"]))
			or TIPOS_DA_LINHA.has(String(t["tipo"]))) else "PlacaDaRua%d"
		if String(t["tipo"]) == "subestacao":
			nome = "SubestacaoDaRede%d"
		for no in [cenario.get_node_or_null(nome % i), rede.get_node_or_null("PosteLuzDaRua%d" % i)]:
			if no is TextureRect:
				_mascara_da_peca(no as TextureRect, pe, mascara)
	conferir("cada peça do mobiliário some atrás do lote da vila que lhe fica à frente %s" % dia,
		int(mascara["erros"]) == 0, String(mascara["onde"]))
	conferir("a vila tapa pixels de alguma peça (%d) %s" % [mascara["tapados"], dia],
		int(mascara["tapados"]) > 0)
	conferir("a lâmpada de sódio acende só no poste velho, no quadro dele, %s" % dia, luz_certa)

	# Os vãos, pela TABELA: os postes da linha pela ordem dela, da borda do
	# mapa ao de saída da subestação, e depois os da calçada da vila em fila
	# pelo `my` — a rua desce sempre, e os das curvas ficam entre a reta de
	# cima e a de baixo —, cada um ligado ao seguinte.
	var vaos := {}
	var fila: Array = []
	var da_rua: Array = []
	for i in postes.keys():
		if TIPOS_DA_LINHA.has(String(tabela[i]["tipo"])):
			fila.append(i)
		else:
			da_rua.append(i)
	fila.sort()
	da_rua.sort_custom(func(a, b): return float(tabela[a]["ponto"][1]) < float(tabela[b]["ponto"][1]))
	fila += da_rua
	for j in range(fila.size() - 1):
		vaos["%d-%d" % [mini(fila[j], fila[j + 1]), maxi(fila[j], fila[j + 1])]] = true
	var fios: Array = []
	var tapume := {"erros": 0, "tapados": 0, "onde": ""}
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
		if a >= 0 and b >= 0:
			_tapume_do_fio(f as Line2D, tabela[a], tabela[b], tapume)
	conferir("cada fio liga dois postes vizinhos e pousa num isolador de cada %s" % dia,
		nos_isoladores, onde)
	# ATRÁS DA VILA, ESCONDIDO (quarta passagem): a vila é o mapa, e o fio
	# desenhava-se por cima da torre da igreja, que lhe fica à frente. Cada
	# vértice de cada fio, pela cor que o `Line2D` lhe dá, contra o topo do
	# que lhe fica à frente na coluna dele, refeito aqui dos `pecas_da_vila`
	# da tabela — e não da cópia que o jogo lê. Os dois lados: o tapado some,
	# e o que se vê não some; e o controle de que a vila tapa algum.
	conferir("cada fio some atrás do lote da vila que lhe fica à frente, e só aí %s" % dia,
		tapume["erros"] == 0, String(tapume["onde"]))
	conferir("a vila tapa fio em algum vão (%d vértices) %s" % [tapume["tapados"], dia],
		int(tapume["tapados"]) > 0)
	var cada_vao := vistos.size() == vaos.size()
	for v in vistos.values():
		cada_vao = cada_vao and int(v) == FIOS_POR_VAO
	conferir("cada vão leva os seus dois fios %s" % dia, cada_vao, "%s" % [vistos])
	return true


## Os pixels opacos do nó `no` (uma peça do mobiliário, de pé em `pe`) que
## caem abaixo do topo de um lote da vila à frente dele — a conta do
## `mascara_da_vila()` do gerador, refeita dos `pecas_da_vila` — e, se há
## algum, a máscara do nó tem de ter esse topo, coluna a coluna. Soma em
## `conta`.
func _mascara_da_peca(no: TextureRect, pe: Vector2, conta: Dictionary) -> void:
	var x := _tela(pe.x, pe.y).x
	var x0 := roundi(x) - MASCARA_LADO
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
	if teto.min() >= FUNDO_DO_MAPA:
		return
	var img := PropIso.imagem(no.texture)
	var esc := PropIso.escala(no.texture)
	var tapados := 0
	var usado := img.get_used_rect()
	for py in range(usado.position.y, usado.end.y):
		for px in range(usado.position.x, usado.end.x):
			if img.get_pixel(px, py).a < 0.1:
				continue
			var m := no.position + Vector2(px, py) * esc
			var c := floori(m.x) - x0
			if c >= 0 and c < teto.size() and m.y >= float(teto[c]):
				tapados += 1
	if tapados == 0:
		return
	conta["tapados"] = int(conta["tapados"]) + tapados
	var mat := no.material as ShaderMaterial
	var certo := mat != null and absf(float(mat.get_shader_parameter("x0")) - x0) < 0.5
	if certo:
		var dele: PackedFloat32Array = mat.get_shader_parameter("teto")
		var origem: Vector2 = mat.get_shader_parameter("origem")
		certo = dele.size() == teto.size() and origem.distance_to(no.position) < 0.05
		for k in range(mini(dele.size(), teto.size())):
			certo = certo and absf(dele[k] - float(teto[k])) < 0.05
	if not certo:
		conta["erros"] = int(conta["erros"]) + 1
		conta["onde"] = "%s: %d px abaixo do lote à frente, máscara %s" % [no.name, tapados, mat]


## Confere cada vértice do fio `linha`, do poste `ta` ao `tb` (as linhas da
## tabela), contra o que lhe fica à frente: abaixo do topo do lote, a cor
## dele é transparente; acima, é a do fio. Ao pixel do topo, qualquer das
## duas (`MARGEM_DO_TAPUME`). Soma em `conta`.
func _tapume_do_fio(linha: Line2D, ta: Dictionary, tb: Dictionary, conta: Dictionary) -> void:
	var pa := Vector2(float(ta["ponto"][0]), float(ta["ponto"][1]))
	var pb := Vector2(float(tb["ponto"][0]), float(tb["ponto"][1]))
	var pontos := linha.points
	var total := 0.0
	for i in range(1, pontos.size()):
		total += pontos[i - 1].distance_to(pontos[i])
	var andado := 0.0
	for i in pontos.size():
		if i > 0:
			andado += pontos[i - 1].distance_to(pontos[i])
		var c := roundi(pontos[i].x)
		var teto := _teto_da_vila(pa, pb, c)
		var alfa := linha.default_color.a
		if linha.gradient != null:
			alfa = linha.gradient.sample(andado / total).a
		if absf(pontos[i].y - teto) < MARGEM_DO_TAPUME:
			continue
		var tapado := pontos[i].y > teto
		if tapado:
			conta["tapados"] = int(conta["tapados"]) + 1
		if tapado != (alfa < 0.01):
			conta["erros"] = int(conta["erros"]) + 1
			conta["onde"] = "%s: vértice %d em %s, topo da vila %.1f, alfa %.2f" \
				% [linha.name, i, pontos[i], teto, alfa]


## O `y` de cima do que fica à frente da fiação na coluna `c` de tela, entre
## os pés `pa` e `pb`: os lotes da vila (`pecas_da_vila`) à frente do ponto
## da reta dos pés nessa coluna — as pontas, fora dela; o meio, se o vão é
## vertical na tela. «À frente» é a regra do eixo que separa do gerador
## (`lote_a_frente`): o ponto só fica à frente se passar do fim do terreno
## num dos dois eixos.
func _teto_da_vila(pa: Vector2, pb: Vector2, c: int) -> float:
	var xa := _tela(pa.x, pa.y).x
	var xb := _tela(pb.x, pb.y).x
	var f := 0.5
	if absf(xb - xa) >= 1.0:
		f = clampf((float(c) - xa) / (xb - xa), 0.0, 1.0)
	var p := pa.lerp(pb, f)
	var teto := INF
	for peca in _ancoras["pecas_da_vila"]:
		var caixa: Array = peca["caixa"]
		var topo: Array = peca["topo"]
		var k := c - int(peca["x0"])
		if k < 0 or k >= topo.size():
			continue
		if p.x >= float(caixa[1]) or p.y >= float(caixa[3]):
			continue
		teto = minf(teto, float(topo[k]))
	return teto


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
func _tres_dias_em_dois_quadros() -> bool:
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
	return true


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
