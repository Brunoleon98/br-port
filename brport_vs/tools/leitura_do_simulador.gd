extends RefCounted

# ============================================================
# BR Port VS — A LEITURA DO SIMULADOR, separada de quem a imprime
#
# Isto era um bloco dentro de `simular_balanceamento.gd` e saiu de lá por uma
# razão só: **não havia como prová-lo.** O simulador é um `SceneTree` que roda
# 4 perfis × 600 partidas antes de chegar à conclusão, e uma suíte não instancia
# isso para conferir uma frase. Aqui é aritmética sobre um Array de Dictionary,
# sem GameState e sem árvore — o bloco T7 do `run_tests.gd` alimenta-o com
# fixtures e lê as linhas que saem.
#
# ⚠️ E NADA AQUI PODE FALAR DO AUTOLOAD. Este arquivo é carregado a partir de um
# `--script`, e a regra do CLAUDE.md morde de três maneiras nesse caminho; a
# proteção é ele não ter nada que precise da árvore de pé.
#
# O que os dois defeitos que isto conserta tinham em comum: ambos liam o
# resultado pela POSIÇÃO na lista.
#
# 1. **A identidade vinha do índice.** `resultados[size - 1]` era o Descuidado
#    quando os perfis eram três; com o Antecipado no fim (12/09) passou a ser
#    ele, e a Leitura ficou a chamar "jogar mal" ao clone do Mediano que quita
#    adiantado. Medido em 600 partidas com a semente do CI: a tabela dizia
#    Descuidado 37,3% e a Leitura publicava 80%, com o vão a sair 20 pontos em
#    vez de 62,7. Não era erro de enfeite — invertia a conclusão, e dizia que a
#    decisão do jogador pesava pouco por cima de uma tabela que media o
#    contrário.
#
# 2. **O denominador vinha de um perfil só.** O `n` era montado dos contadores
#    do Ótimo e servia as DUAS taxas. Hoje isso não se vê, porque todos os
#    perfis correm as mesmas `partidas` — é um defeito latente à espera da
#    primeira rodada com amostras diferentes, e é da família do `.get(chave, 0)`
#    que já fez o relatório afirmar que o jogador construía de graça.
#
# A identidade é o NOME, e não uma chave nova: é a mesma que o despejo JSON já
# usa (`perfis[nome]`) e a que o `projetar_parcelas.py` já consulta
# (`medicao["perfis"]["Mediano"]`). Um contrato que já existe em dois lugares
# não precisa de um terceiro.
# ============================================================

# Quem representa cada papel na conclusão. "Descuidado" NÃO quer dizer "a menor
# taxa desta rodada": o Antecipado pode ficar abaixo dele numa semente qualquer
# sem deixar de ser outro comportamento, e um `argmin` leria isso como jogar
# mal. O papel é declarado, não inferido.
const PERFIL_BOM := "Ótimo"
const PERFIL_RUIM := "Descuidado"


# Quantas partidas daquele perfil chegaram a um desfecho. Os três contadores
# PARTICIONAM as partidas — o `if/elif/else` do `_simular_perfil` cai num e num
# só —, e é por isso que esta soma é o denominador honesto: ele sai do próprio
# registro, e não do total pedido na linha de comando nem do vizinho.
static func amostra(r: Dictionary) -> int:
	return int(r.get("vitorias", 0)) + int(r.get("quebrou_antes", 0)) \
		+ int(r.get("chegou_sem_dinheiro", 0))


# Devolve o registro do perfil com aquele nome, ou o motivo de não o devolver.
# Ausente e DUPLICADO são recusas separadas de propósito: uma lista com dois
# "Descuidado" tem uma identidade que não identifica, e escolher o primeiro
# seria voltar a decidir por posição com outra roupa.
static func achar(resultados: Array, nome: String) -> Dictionary:
	var achados := []
	var nomes := []
	for r in resultados:
		var n := String(r.get("perfil", {}).get("nome", ""))
		nomes.append(n)
		if n == nome:
			achados.append(r)
	if achados.size() == 1:
		return {"ok": true, "perfil": achados[0]}
	if achados.is_empty():
		return {"ok": false, "erro":
			"não achei o perfil \"%s\" entre os simulados (%s)" % [nome, ", ".join(nomes)]}
	return {"ok": false, "erro":
		"o perfil \"%s\" aparece %d vezes — a identidade tem de ser única" % [nome, achados.size()]}


# -> {"ok": bool, "linhas": Array[String]}
#
# Devolve LINHAS em vez de imprimir para que a prova possa ler o texto final, e
# não o número anterior à formatação: foi a formatação que já engoliu um número
# neste projeto (o `0.` do JUROS_POR_TURNO), e uma asserção sobre o objeto de
# dentro não teria visto nada.
#
# O `ok` falso é o que faz o simulador encerrar com código 1. Sob `set -euo
# pipefail`, que é como os dois workflows o chamam, isso reprova o passo sem
# precisar de sentinela nova na saída — e a linha "=== Leitura ===" continua a
# sair, porque a corrida CHEGOU aqui: é isso que o CI pergunta com ela.
static func ler(resultados: Array) -> Dictionary:
	var linhas := ["=== Leitura ==="]

	var bom := achar(resultados, PERFIL_BOM)
	var ruim := achar(resultados, PERFIL_RUIM)
	for e in [bom, ruim]:
		if not bool(e["ok"]):
			linhas.append("· NÃO CONSEGUI LER: %s." % e["erro"])
	if not bool(bom["ok"]) or not bool(ruim["ok"]):
		linhas.append("  A conclusão precisa dos dois papéis para existir, e não sai daqui sem eles.")
		return {"ok": false, "linhas": linhas}

	var r_bom: Dictionary = bom["perfil"]
	var r_ruim: Dictionary = ruim["perfil"]
	var n_bom := amostra(r_bom)
	var n_ruim := amostra(r_ruim)
	# Amostra vazia não vira 0% — vira recusa. Uma taxa com denominador zero é o
	# pior valor de omissão que há, porque se lê como medida.
	for par in [[PERFIL_BOM, n_bom], [PERFIL_RUIM, n_ruim]]:
		if int(par[1]) <= 0:
			linhas.append("· NÃO CONSEGUI LER: o perfil \"%s\" não tem partida nenhuma com desfecho." % par[0])
	if n_bom <= 0 or n_ruim <= 0:
		linhas.append("  Sem amostra não há taxa, e sem taxa não há conclusão.")
		return {"ok": false, "linhas": linhas}

	# Cada taxa com o denominador do SEU perfil.
	var taxa_bom := 100.0 * float(r_bom["vitorias"]) / float(n_bom)
	var taxa_ruim := 100.0 * float(r_ruim["vitorias"]) / float(n_ruim)

	if taxa_bom < 60.0:
		linhas.append("· Jogo perfeito (%s) ganha só %.1f%% de %d partidas — está DIFÍCIL demais no teto:"
			% [PERFIL_BOM, taxa_bom, n_bom])
		linhas.append("  nem jogando certo dá para confiar na vitória, e isso lê como injustiça.")
	elif taxa_bom > 90.0:
		linhas.append("· Jogo perfeito (%s) ganha %.1f%% de %d partidas — o teto está garantido, o que é bom."
			% [PERFIL_BOM, taxa_bom, n_bom])
	else:
		linhas.append("· Jogo perfeito (%s) ganha %.1f%% de %d partidas — teto ainda com sorte demais no meio."
			% [PERFIL_BOM, taxa_bom, n_bom])

	# ⚠️ AQUI HAVIA UM VEREDITO, E ELE SAIU POR NÃO TER DECISÃO POR TRÁS. A
	# frase era "o ERRO NÃO CUSTA, é este o sintoma de 'fácil demais'" acima de
	# 50%, e "errar custa caro" abaixo de 15% — limiares da fantasia de
	# sobrevivência que a `docs/decisoes/005` substituiu em 02/09. Aquela
	# decisão diz o contrário com todas as letras: num jogo tranquilo "a decisão
	# errada custa TEMPO e OPORTUNIDADE, não a partida". Nenhum limiar novo foi
	# escrito para o lugar do velho, e inventar um aqui seria pôr política de
	# balanceamento dentro de um relatório. O que fica é o que se mediu.
	linhas.append("· Jogar mal (%s) ganha %.1f%% de %d partidas." % [PERFIL_RUIM, taxa_ruim, n_ruim])

	# PONTOS PERCENTUAIS, e dito. A diferença RELATIVA entre 100% e 30% também
	# dá 70, o que torna as duas contas indistinguíveis justamente no caso mais
	# comum deste projeto (o Ótimo satura no teto) — daí a palavra estar escrita
	# na linha, e a fixture da prova ter um Ótimo abaixo de 100.
	var vao := taxa_bom - taxa_ruim
	linhas.append("· Vão entre jogar bem e jogar mal: %.1f pontos percentuais (%.1f%% − %.1f%%)."
		% [vao, taxa_bom, taxa_ruim])
	linhas.append("  A taxa de vitória deixou de ser o que discrimina os perfis com a trava do")
	linhas.append("  nível (docs/decisoes/009): quem mede isso é a margem em REGIME, acima.")
	linhas.append("")
	linhas.append("Para testar uma mudança: edite uma constante `# TUNING:` em")
	linhas.append("autoload/GameState.gd e rode de novo com a MESMA semente.")
	return {"ok": true, "linhas": linhas}
