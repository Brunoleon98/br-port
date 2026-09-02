extends Node

# ============================================================
# BR Port VS — Registro (autoload singleton)
#
# A metade de MÁQUINA do playtest (item B7 do plano; a metade humana é o A7).
# Escreve uma linha JSON por acontecimento numa partida, para que cinco
# partidas jogadas por pessoas diferentes produzam uma leitura que nenhuma
# delas mostrava sozinha. Quem faz a leitura é `tools/ler_registros.py`.
#
# Mesmo espírito do `Audio.gd`: um ponto só, que escuta os sinais do
# `GameState` em vez de espalhar `store_line()` por sete scripts. O jogo NÃO
# sabe que está a ser gravado, e é isso que impede o gravador de mudar o jogo.
#
# ─────────────────────────────────────────────────────────────
# AS QUATRO COISAS QUE ESTE ARQUIVO RESOLVE E NÃO SÃO ÓBVIAS
# ─────────────────────────────────────────────────────────────
#
# 1. **DESARMADO POR OMISSÃO — e é a regra que mais importa aqui.**
#    Um autoload carrega TAMBÉM em `--script`: é por isso que a suíte pega o
#    `GameState` por `root.get_node()` em vez de o construir. Logo, este nó
#    está de pé durante as 600 partidas × 3 perfis do
#    `simular_balanceamento.gd` e durante as quatro suítes. Se gravasse por
#    omissão, uma medição de balanceamento escreveria 1.800 arquivos e o
#    disco do CI seria o menor dos problemas — o custo por turno entraria na
#    conta do que se está a medir.
#    Por isso: só grava depois de `armar()`, e quem arma é o JOGO
#    (`Main.gd._ready()`). Ferramenta nenhuma arma.
#    É a mesma família de armadilha da regra "tela nova é overlay, nunca fase
#    do GameState": algo que funciona no jogo e envenena calado quem mede.
#
# 2. **`FileAccess.WRITE` TRUNCA.** Não existe modo "append" no Godot 4: abrir
#    para escrever apaga o que lá estava. Acrescentar é abrir em `READ_WRITE`
#    (que exige o arquivo existir) e `seek_end()`, com `WRITE` só na primeira
#    vez. Escrito à mão isto dá um arquivo de uma linha só — a última.
#
# 3. **NUM TELEFONE, FECHAR É O QUE GRAVA.** O Android mata a aplicação sem
#    aviso quando precisa da memória, e o que estiver em buffer morre com ela.
#    Uma partida de 32 turnos que se perde inteira porque alguém atendeu uma
#    chamada é exatamente o dado que este item existe para não perder. Por
#    isso o arquivo abre e FECHA a cada linha: ~40 aberturas por partida, que
#    ao lado de um turno de jogo não é nada, e cada linha fica no disco.
#
# 4. **O ARQUIVO PRECISA DE SAIR DO TELEFONE.** `user://` no Android é
#    privado da aplicação: sem cabo e sem `adb` não há como lá chegar. Um
#    gravador cujo resultado não sai do aparelho não gravou nada. Daí o
#    `texto_para_exportar()`, que o menu de pausa põe na área de transferência
#    — o caminho que funciona em qualquer telefone, sem cabo: copiar e colar
#    numa conversa.
#
# ─────────────────────────────────────────────────────────────
# O QUE NÃO SE GRAVA, DE PROPÓSITO
# ─────────────────────────────────────────────────────────────
# O **nome do jogador** não entra no arquivo. O A7 pede que o jogo seja
# entregue "a duas pessoas sem explicar nada", e esse arquivo vai ser colado
# numa conversa. O que se grava é a FORMA da escolha e não a pessoa: se o
# campo ficou vazio (que é sinal de playtest de verdade — a narrativa tem
# variante sem vocativo justamente para isso) e quantos caracteres tinha.
# O nome do PORTO entra: esse é escolha de jogo, não identidade de ninguém.
# ============================================================

# Sobe sempre que a FORMA de um evento mudar. O leitor usa isto para saber o
# que consegue ler.
#
# Ao contrário do `SAVE_VERSION`, registro velho NÃO se descarta: um save
# errado estraga a partida em curso, um registro velho continua a ser um dado
# que alguém produziu jogando. O leitor lê o que reconhece e DIZ o que deixou
# de fora.
const VERSAO := 1

const PASTA := "user://registros"

# Teto de linhas por arquivo. Uma partida honesta faz ~40; isto é para o caso
# de algo entrar em laço com o gravador armado. Passado o teto grava-se uma
# linha a dizer que se parou — um arquivo que emudece sem explicação leria
# como partida abandonada, que é uma conclusão errada sobre um jogador real.
const TETO_LINHAS := 5000

# Quantas partidas se guardam no aparelho. O A7 pede cinco; vinte dá folga
# para jogar várias vezes antes de exportar, sem encher o telefone de quem
# emprestou o aparelho para testar.
const TETO_ARQUIVOS := 20

var _armado := false
var _caminho := ""
var _linhas := 0
var _calou := false

# Relógio de deliberação. `Time.get_ticks_msec()` é monotónico — não anda para
# trás quando o relógio do sistema é acertado, que é o que estragaria uma
# medida de tempo feita com a hora do dia.
var _ms_do_turno := 0
var _ms_da_oferta := 0

# O que aconteceu DENTRO do turno em curso, para sair numa linha só quando o
# turno virar. Um evento por linha daria um arquivo cinco vezes maior a dizer
# o mesmo, e o que interessa ao leitor é o turno como unidade.
#
# ⚠️ SERVIDO E PERDIDO SAEM DA DIFERENÇA DE `metrics`, NÃO DE UM CONTADOR AQUI.
# A primeira versão tinha `_servidos_no_turno` a ser zerado a cada turno e
# nunca incrementado — não existe sinal para "barco atendido", e o
# `advance_turn()` resolve o barco por dentro. O campo saía SEMPRE zero, e o
# relatório dizia "0 barcos servidos · 0 perdidos" num porto que atendeu 81.
# Zero é o pior valor de omissão que há: lê-se como medida.
var _mensagens_ruins := 0
var _servidos_antes := 0
var _perdidos_antes := 0

var _GS: Node


func _ready() -> void:
	# O identificador global `GameState` não resolve dentro de tudo o que é
	# alcançado a partir de um `--script` (ver a regra no CLAUDE.md). Pegar
	# pela árvore funciona nos dois casos, e este nó tem de existir nos dois
	# — desarmado, mas de pé.
	_GS = get_node_or_null("/root/GameState")
	if _GS == null:
		return
	_GS.turn_advanced.connect(_ao_turno)
	_GS.semana_fechada.connect(_ao_fim_de_semana)
	_GS.estrutura_comprada.connect(_ao_comprar)
	_GS.rival_offer_triggered.connect(_ao_abrir_oferta)
	_GS.negociacao_resolvida.connect(_ao_negociar)
	_GS.debt_due.connect(_ao_vencer_parcela)
	_GS.game_over.connect(_ao_fim)
	_GS.message.connect(_ao_mensagem)


# ── ARMAR ──
#
# Chamado pelo jogo, e só pelo jogo. Ver a nota 1 do cabeçalho.
#
# ⚠️ CADA CHAMADA ABRE UM ARQUIVO NOVO, e é de propósito. A primeira versão
# saía cedo quando já estava armado, e isso escondia um defeito calado: quem
# carrega em "Novo jogo (apaga progresso)" faz `reload_current_scene()`, o
# `Main._ready()` corre outra vez e a partida NOVA continuava a escrever no
# arquivo da anterior — sem linha de abertura entre as duas. O leitor parte as
# partidas justamente pela abertura, então as duas viravam UMA, com o dobro
# dos turnos e uma curva de caixa que nenhum jogador jogou. Um defeito que não
# dá erro nenhum e só aparece no relatório, como número plausível.
func armar() -> void:
	_armado = true
	DirAccess.make_dir_recursive_absolute(PASTA)
	_podar()
	# O nome sai da hora local, e não de um contador, porque dois aparelhos
	# diferentes têm de gerar arquivos que não colidem quando os registros dos
	# dois chegam à mesma pasta para serem lidos juntos — que é precisamente o
	# que o A7 vai fazer.
	#
	# ⚠️ MAS A HORA SÓ TEM RESOLUÇÃO DE UM SEGUNDO, e duas partidas começadas
	# dentro do mesmo segundo davam o MESMO nome: a segunda continuava a
	# escrever no arquivo da primeira. Não dá erro — dá um arquivo com duas
	# partidas dentro e um `linhas_gravadas()` que conta as duas, e o botão de
	# copiar exportaria as duas como se fossem uma sessão. Quem carrega duas
	# vezes seguidas em "Novo jogo" chega lá em dois toques. O sufixo resolve,
	# e o laço é a garantia de que resolve mesmo quando o relógio não anda.
	var base := "%s/partida_%s" % [PASTA, Time.get_datetime_string_from_system(false, false)
		.replace(":", "").replace("-", "").replace("T", "_")]
	_caminho = base + ".jsonl"
	var n := 2
	while FileAccess.file_exists(_caminho):
		_caminho = "%s_%d.jsonl" % [base, n]
		n += 1
	_linhas = 0
	_calou = false
	_ms_do_turno = Time.get_ticks_msec()
	_zerar_turno()
	_gravar({
		"e": "abriu",
		"versao": VERSAO,
		"jogo": ProjectSettings.get_setting("application/config/version", "?"),
		"plataforma": OS.get_name(),
		"quando": Time.get_datetime_string_from_system(true),
		# Abrir a aplicação com um save por acabar arma o gravador a meio de
		# uma partida. Sem esta marca, o arquivo anterior — que não tem linha
		# de fim, porque a partida não acabou — leria como ABANDONADA, que é a
		# conclusão mais dura que um playtest dá e seria falsa.
		"retomada": _GS.turn > 1,
		"t_inicial": _GS.turn,
		# O que o jogo assume sobre a partida. Sem isto, um registro de hoje
		# lido daqui a três reescalas mede-se contra os números errados — o
		# mesmo defeito que a tabela dos números existe para resolver.
		"turnos_totais": _GS.TURNS_TOTAL,
		"parcela": _GS.PARCELA_AMOUNT,
		"caixa_inicial": _GS.START_CASH,
	})


func armado() -> bool:
	return _armado


# ── ESCRITA ──
#
# Uma linha, aberta e fechada. Ver as notas 2 e 3 do cabeçalho: o `WRITE` só
# na primeira vez existe porque `READ_WRITE` exige o arquivo já existir, e o
# `close()` a cada linha existe porque o Android não avisa antes de matar.
func _gravar(evento: Dictionary) -> void:
	if not _armado or _calou:
		return
	if _linhas >= TETO_LINHAS:
		_calou = true
		evento = {"e": "calou", "motivo": "teto de %d linhas" % TETO_LINHAS}
	var existe := FileAccess.file_exists(_caminho)
	var f := FileAccess.open(_caminho, FileAccess.READ_WRITE if existe else FileAccess.WRITE)
	if f == null:
		# Disco cheio ou permissão negada. Não derruba o jogo por causa do
		# gravador: quem está a jogar não é quem quer o dado.
		_armado = false
		return
	if existe:
		f.seek_end()
	f.store_line(JSON.stringify(evento))
	f.close()
	_linhas += 1


# Guarda no máximo `TETO_ARQUIVOS`, apagando os mais antigos. Ordem
# alfabética serve porque o nome começa pela data em formato que ordena.
func _podar() -> void:
	var nomes := _arquivos()
	if nomes.size() < TETO_ARQUIVOS:
		return
	nomes.sort()
	for i in range(nomes.size() - TETO_ARQUIVOS + 1):
		DirAccess.remove_absolute("%s/%s" % [PASTA, nomes[i]])


func _arquivos() -> Array:
	var d := DirAccess.open(PASTA)
	if d == null:
		return []
	var fora: Array = []
	for n in d.get_files():
		if n.ends_with(".jsonl"):
			fora.append(n)
	return fora


# ── OS EVENTOS ──

func _zerar_turno() -> void:
	_mensagens_ruins = 0
	# `new_game()` zera o `metrics`. Se isso acontecer com o gravador armado —
	# o que no jogo não acontece, porque quem arma é o `Main._ready()` e ele
	# corre DEPOIS —, a diferença fica negativa e o relatório imprime "-3
	# barcos perdidos", que não quer dizer nada e lê-se como medida. O `maxi`
	# em `_ao_turno` corta o negativo; esta linha volta a ancorar no valor
	# novo, para o turno seguinte já contar certo.
	_servidos_antes = int(_GS.metrics.get("boats_served", 0))
	_perdidos_antes = int(_GS.metrics.get("boats_lost", 0))


# O turno é a unidade do registro. Sai DEPOIS de o GameState ter resolvido
# tudo, então os números aqui são os de fim de turno — que é o que o jogador
# viu ao carregar no botão.
func _ao_turno(novo_turno: int, semana: int) -> void:
	var agora := Time.get_ticks_msec()
	var ocupadas := 0
	var com_barco := 0
	for d in _GS.docks:
		if d["boat"] != null:
			com_barco += 1
			if d["worker_id"] != null:
				ocupadas += 1
	_gravar({
		"e": "turno",
		"t": novo_turno,
		"s": semana,
		# Quanto tempo o jogador ficou NESTE turno antes de o avançar. É a
		# pergunta que o A7 faz por escrito ("quanto tempo demorou a
		# escolher") e a única que uma gravação de tela responderia de outro
		# modo — e ver gravação é caro e não se soma.
		"ms": maxi(0, agora - _ms_do_turno),
		"caixa": _GS.cash,
		"rep": snappedf(_GS.reputation, 0.1),
		"docas": _GS.docks.size(),
		"trab": _GS.workers.size(),
		# Barco parado sem trabalhador ao virar o turno é o erro que o
		# simulador MODELA com `chance_esquecer_doca` e nunca mediu.
		"barcos": com_barco,
		"alocados": ocupadas,
		# `metrics` é acumulado desde o início da partida e o `advance_turn()`
		# já o atualizou quando este sinal chega — a diferença é o turno.
		"servidos": maxi(0, int(_GS.metrics.get("boats_served", 0)) - _servidos_antes),
		"perdidos": maxi(0, int(_GS.metrics.get("boats_lost", 0)) - _perdidos_antes),
		"avisos_ruins": _mensagens_ruins,
	})
	_ms_do_turno = agora
	_zerar_turno()


func _ao_fim_de_semana(resumo: Dictionary) -> void:
	var linha := {"e": "semana"}
	# O resumo já vem fechado do GameState e é a MESMA conta que o Boletim
	# mostra ao jogador. Copiá-lo inteiro em vez de escolher campos evita a
	# segunda versão da conta que este projeto já pagou uma vez.
	for k in resumo.keys():
		linha[k] = resumo[k]
	_gravar(linha)


func _ao_comprar(id: String) -> void:
	_gravar({
		"e": "obra",
		"id": id,
		"t": _GS.turn,
		"caixa": _GS.cash,
		# Comprar com folga ou raspando é a diferença entre um jogador que
		# planeou e um que arriscou, e não se vê no saldo depois.
		#
		# ⚠️ A chave é `custo`. A primeira versão dizia `preco` e o
		# `.get("preco", 0)` devolvia ZERO — sem erro, sem aviso, com o
		# relatório a dizer que o jogador construiu de graça. Num dicionário
		# de configuração, o valor de omissão do `get()` transforma um erro de
		# digitação em número plausível; por isso aqui o acesso é DIRETO, e um
		# `id` que não exista rebenta em vez de mentir.
		"custo": int(_GS.ESTRUTURAS[id]["custo"]) if _GS.ESTRUTURAS.has(id) else -1,
	})


func _ao_abrir_oferta(dock_index: int) -> void:
	_ms_da_oferta = Time.get_ticks_msec()
	_gravar({"e": "arlindo", "t": _GS.turn, "doca": dock_index})


# O que o jogador ESCOLHEU na contra-oferta, e quanto tempo levou a escolher.
# O simulador tem três perfis que ADIVINHAM isto ("otimo" tenta o meio-termo,
# "medio" iguala de cara na maioria das vezes); aqui mede-se.
func _ao_negociar(acao: String, resultado: String, tentativa: int) -> void:
	_gravar({
		"e": "negociou",
		"t": _GS.turn,
		"acao": acao,
		"resultado": resultado,
		"tentativa": tentativa,
		"ms": maxi(0, Time.get_ticks_msec() - _ms_da_oferta),
		"rep": snappedf(_GS.reputation, 0.1),
	})
	_ms_da_oferta = Time.get_ticks_msec()


func _ao_vencer_parcela(valor: int) -> void:
	_gravar({"e": "parcela", "t": _GS.turn, "valor": valor, "caixa": _GS.cash})


func _ao_fim(ganhou: bool, motivo: String) -> void:
	_gravar({
		"e": "fim",
		"ganhou": ganhou,
		"motivo": motivo,
		"t": _GS.turn,
		"caixa": _GS.cash,
		"rep": snappedf(_GS.reputation, 0.1),
		"metrics": _GS.metrics,
		"estruturas": _GS.estruturas,
		"porto": _GS.nome_porto,
		# Ver "O QUE NÃO SE GRAVA" no cabeçalho: a forma da escolha, não a
		# pessoa que a fez.
		"jogador_anonimo": _GS.nome_jogador == "",
		"jogador_letras": _GS.nome_jogador.length(),
	})


# Só o que correu mal. Contar TODA mensagem daria o ruído de sempre; o que
# interessa a quem lê é se o jogador levou avisos vermelhos e em que turno.
func _ao_mensagem(_texto: String, tipo: String) -> void:
	if tipo == "bad":
		_mensagens_ruins += 1


# ── SAÍDA ──
#
# Ver a nota 4 do cabeçalho. Devolve o registro em texto para quem o queira
# pôr na área de transferência — que é como um arquivo sai de um telefone sem
# cabo. Vazio se nada foi gravado, para quem chama poder dizer isso em vez de
# copiar silêncio.
func texto_para_exportar(todas: bool = false) -> String:
	if not todas:
		if _caminho == "" or not FileAccess.file_exists(_caminho):
			return ""
		return FileAccess.get_file_as_string(_caminho)
	var nomes := _arquivos()
	nomes.sort()
	var partes: PackedStringArray = []
	for n in nomes:
		partes.append(FileAccess.get_file_as_string("%s/%s" % [PASTA, n]))
	return "\n".join(partes)


func linhas_gravadas() -> int:
	return _linhas


func caminho_legivel() -> String:
	return ProjectSettings.globalize_path(_caminho) if _caminho != "" else ""
