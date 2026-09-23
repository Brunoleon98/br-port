extends "res://tools/simular_balanceamento.gd"

# ============================================================
# BR Port VS — a régua do boletim da Dona Cida
#
# Pergunta: o que a Dona Cida AFIRMA no boletim é verdade na semana em que ela
# o diz? Cada tom do boletim faz afirmações sobre o estado — "de novo", "a
# semana passada", "a parcela" — e o `tom_do_boletim()` escolhe o tom só pelo
# resultado e pela média. Nada ligava as duas coisas.
#
# ⚠️ HERDA O SIMULADOR, E NÃO O COPIA. As partidas são as MESMAS que medem o
# balanceamento — as mesmas políticas de jogador, as mesmas sementes —, e uma
# cópia das políticas aqui divergiria delas na primeira afinação. Este arquivo
# só troca o `_rodar()` e escuta o `semana_fechada`, que é o sinal que abre o
# boletim no jogo (`Main._on_semana_fechada`).
#
# ⚠️ O PREDICADO LÊ-SE NO INSTANTE EM QUE A FALA APARECE (`CLAUDE.md`, a regra
# do `turn_advanced`): o estado da parcela é o do momento do `semana_fechada`,
# que no vencimento sai DEPOIS do pagamento — é o que o jogador vê.
#
# ⚠️ E HÁ UM QUINTO PERFIL, o Parado, que nunca aloca ninguém. O boletim da
# primeira semana ruim foi medido em 12/09 precisamente nesse jogador — o
# principiante que ainda não percebeu a alocação —, e os quatro do simulador
# alocam todos. Estado que aperta uma fala é o mais pobre, não o médio.
#
# Uso: $G --headless --path brport_vs --script res://tools/medir_boletim.gd -- [partidas] [semente]
# Espera `BOLETIM OK`; com alguma afirmação falsa sai com código 1.
# ============================================================

const PARADO := {
	"nome": "Parado",
	"descricao": "nunca aloca ninguém nem constrói — o principiante do boletim de 12/09",
	"chance_esquecer_doca": 1.0,
	"estilo_negociacao": "ruim",
	"chance_igualar_rival": 0.40,
	"folga_para_upgrade": 999.0,
	"quita_adiantado": false,
}

var _perfil_atual := ""
var _boletins: Array = []


# O que cada tom AFIRMA, uma linha por afirmação, com o predicado que a torna
# verdade. ⚠️ É ESCRITO À MÃO A PARTIR DO TEXTO, e é essa a fragilidade desta
# régua: quem mudar uma fala em `Narrativa.CIDA_BOLETIM` muda aqui a lista do
# que ela afirma. O que a régua garante é que o estado confirma cada afirmação
# listada — não que a lista esteja completa.
#
# ⚠️ E AFIRMAÇÃO QUE É A PRÓPRIA CONDIÇÃO DO TOM NÃO REPROVA NUNCA. «De novo»
# é exatamente o `anterior < 0` que escolhe o "ruim"; listada sozinha, ela é
# um espelho. Medido: tirar do `tom_do_boletim()` o ramo inteiro da parcela
# PASSAVA nesta régua, porque a semana paga caía em "ruim"/"ruim_virou" e as
# duas cumpriam o que diziam. Quem a apanha é «a façanha é da operação», que
# lê a parcela da semana — um campo que a condição desses tons não lê. E a
# ordem entre a parcela e a primeira semana não se prova aqui: a parcela paga
# na semana 1 não acontece em 1.000 partidas, e quem a monta é o T12.
func _afirmacoes() -> Dictionary:
	return {
		"primeira_ruim": [
			["«no vermelho» — o resultado é negativo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) < 0],
			["«a parcela não espera» — a parcela está por pagar",
				func(b: Dictionary) -> bool: return not bool(b["parcela_paga"])],
			["«a façanha» é da operação — a parcela NÃO saiu nesta semana",
				func(b: Dictionary) -> bool: return int(b["parcela_na_semana"]) == 0],
		],
		"ruim": [
			["«gastar mais do que ganhar» — o resultado é negativo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) < 0],
			["«de novo» — a semana anterior também fechou no vermelho",
				func(b: Dictionary) -> bool: return int(b["anterior"]) < 0],
			["«a façanha» é da operação — a parcela NÃO saiu nesta semana",
				func(b: Dictionary) -> bool: return int(b["parcela_na_semana"]) == 0],
		],
		"ruim_virou": [
			["«gastar mais do que ganhar» — o resultado é negativo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) < 0],
			["«semana passada não foi assim» — a anterior não fechou no vermelho",
				func(b: Dictionary) -> bool:
					return bool(b["tem_historico"]) and int(b["anterior"]) >= 0],
			["«a façanha» é da operação — a parcela NÃO saiu nesta semana",
				func(b: Dictionary) -> bool: return int(b["parcela_na_semana"]) == 0],
		],
		"ruim_ribeiro": [
			["«fechou no vermelho» — o resultado é negativo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) < 0],
			["«quem levou foi o Sr. Ribeiro» — a parcela saiu NESTA semana",
				func(b: Dictionary) -> bool: return int(b["parcela_na_semana"]) > 0],
		],
		"neutro": [
			["«entrou mais do que saiu» — o resultado é positivo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) > 0],
		],
		"otimo": [
			["«foi uma boa semana» — o resultado é positivo",
				func(b: Dictionary) -> bool: return int(b["resultado"]) > 0],
		],
	}


func _rodar() -> void:
	GS = root.get_node("GameState")
	GS.clear_save()
	var args := OS.get_cmdline_user_args()
	var partidas := 200
	var semente := SEMENTE_PADRAO
	if args.size() >= 1 and args[0].is_valid_int():
		partidas = int(args[0])
	if args.size() >= 2 and args[1].is_valid_int():
		semente = int(args[1])

	print("=== BR Port VS — o que a Dona Cida afirma no boletim ===")
	print("%d partidas por perfil · semente %d" % [partidas, semente])
	GS.semana_fechada.connect(_ao_fechar_semana)
	var perfis: Array = PERFIS.duplicate()
	perfis.append(PARADO)
	for perfil in perfis:
		_perfil_atual = String(perfil["nome"])
		_simular_perfil(perfil, partidas, semente)

	var falsas := _imprimir()
	# ⚠️ ZERO BOLETINS É UMA RÉGUA MUDA, NUNCA UM VERDE: o sinal pode ter
	# mudado de nome ou deixado de sair, e aí não haveria afirmação nenhuma a
	# reprovar.
	if _boletins.is_empty():
		print("FALHA: nenhum boletim fechou — a régua não ouviu o `semana_fechada`.")
		quit(1)
		return
	if falsas > 0:
		print("BOLETIM COM FALA FALSA — %d afirmação(ões) desmentida(s) pelo estado." % falsas)
		quit(1)
		return
	print("=== BOLETIM OK — %d boletins, toda afirmação confirmada pelo estado ===" % _boletins.size())
	quit(0)


func _ao_fechar_semana(resumo: Dictionary) -> void:
	var tom: String = Narrativa.tom_do_boletim(resumo)
	_boletins.append({
		"perfil": _perfil_atual,
		"semana": int(resumo["semana"]),
		"tom": tom,
		"resultado": int(resumo["resultado"]),
		"anterior": int(resumo["anterior"]),
		"tem_historico": bool(resumo["tem_historico"]),
		"parcela_paga": bool(GS.parcela_paid),
		"parcela_na_semana": int(resumo["parcela"]),
	})


# Imprime, por tom, quantas vezes saiu e em que semanas, e para cada afirmação
# quantas vezes o estado a DESMENTIU — com a divisão por perfil, que é onde se
# vê QUEM ouve a frase errada. Devolve o total de desmentidos.
func _imprimir() -> int:
	var afirma := _afirmacoes()
	var falsas := 0
	print("")
	# ⚠️ OS TONS SAEM DA TABELA DAS FALAS, e não de uma lista escrita aqui: um
	# tom novo que não tenha afirmações listadas aparece com zero linhas, e
	# um tom que saia no jogo sem estar na tabela reprova abaixo.
	for tom in Narrativa.CIDA_BOLETIM.keys():
		var deste: Array = _boletins.filter(func(b): return b["tom"] == tom)
		var por_semana := {}
		for b in deste:
			por_semana[b["semana"]] = int(por_semana.get(b["semana"], 0)) + 1
		print("── %s: %d boletins · por semana %s" % [tom, deste.size(), str(por_semana)])
		for par in afirma.get(tom, []):
			var erradas: Array = deste.filter(func(b): return not par[1].call(b))
			falsas += erradas.size()
			var por_perfil := {}
			for b in erradas:
				por_perfil[b["perfil"]] = int(por_perfil.get(b["perfil"], 0)) + 1
			print("   %s %s: falsa em %d de %d %s" % [
				"OK " if erradas.is_empty() else "!! ", String(par[0]),
				erradas.size(), deste.size(), str(por_perfil) if not erradas.is_empty() else ""])
	# E todo tom que o jogo escolheu tem de ter afirmações listadas — um tom
	# sem lista passaria por "nada de falso" sem ter sido lido.
	for b in _boletins:
		if not afirma.has(b["tom"]):
			print("   !!  o tom «%s» saiu e não tem afirmações listadas nesta régua" % b["tom"])
			falsas += 1
			break
	print("")
	return falsas
