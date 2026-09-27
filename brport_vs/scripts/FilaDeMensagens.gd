class_name FilaDeMensagens
extends RefCounted

# ============================================================
# A FILA DA FAIXA DE MENSAGEM — R5 da §7.1 do plano v3.
#
# O PROBLEMA, MEDIDO. A faixa é um `Label` só, e duas fontes escrevem nele: a
# mensagem do sistema (`GameState.message`) e a voz da Dona Cida. Quem escreve
# por último apaga quem escreveu antes, no mesmo frame, sem deixar rasto.
# Medido em 19/09 com `tools/medir_fila_mensagens.gd`, 15 partidas em cinco
# sementes e três formas de jogar: **861 escritas, 597 vistas, 264 TAPADAS —
# 30,7% de tudo o que o jogo diz**. Comprar uma estrutura escreve 2,29 vezes
# em média e nunca coube; a maior rajada de uma ação são 4.
#
# O R4 já tinha mexido nisto uma vez, e só trocou quem ganha: a fala passou a
# entrar no fim do frame (`call_deferred`) e ficou por cima, de modo que hoje
# quem se perde é sobretudo o SISTEMA — 177 das 264. Mostrar as duas é isto.
#
# ⚠️ NÃO É UM AUTOLOAD, e é decisão. Um autoload carrega também em `--script`,
# logo estaria de pé durante as 600 partidas por perfil do simulador e durante
# as seis suítes — a mesma armadilha que o `Registro.gd` documenta ("nasce
# desarmado, e quem o arma é o jogo"). Isto é um objeto do `Main`, e fora do
# `Main` não existe.
#
# ⚠️ E NÃO FALA COM O `GameState`. É um `class_name`, e o `CLAUDE.md` regista
# que o autoload não resolve pelo nome dentro de um — o erro sairia como
# "Identifier not found: GameState" e derrubaria a suíte inteira. Ela recebe
# texto já resolvido e devolve texto; quem sabe do jogo é quem a alimenta.
#
# ⚠️ E O PREDICADO CONTINUA A SER LIDO ONDE A LINHA É ESCRITA. Esta fila adia
# a APRESENTAÇÃO, nunca a escolha: o que entra aqui é a string final, já
# decidida. É o que impede o defeito que o R4 acabou de fechar de voltar pela
# porta do lado — uma fila que guardasse o *id* e o resolvesse na hora de
# mostrar diria "Barcos na fila" sobre um cais que entretanto esvaziou.
# ============================================================

## A mensagem mudou na tela. Quem ouve é o `Main`, que a escreve no Label.
signal apresentou(texto: String, kind: String)


# ── prioridade ──────────────────────────────────────────────────────────────
#
# ⚠️ ELA DECIDE A PRÓXIMA APRESENTAÇÃO, E NUNCA INTERROMPE A ATUAL. É a
# diferença entre uma fila e uma troca de ordem: o que chega urgente passa à
# frente do que ESPERA, não do que está a ser lido. Interromper seria copiar do
# `Audio.gd` o descarte do perdedor, que ali está certo — dois sons no mesmo
# frame são ruído — e aqui apagaria a frase a meio da leitura.
#
# O eixo é o `kind` que o jogo JÁ usa para colorir a faixa; inventar um segundo
# eixo de importância seria uma segunda verdade a divergir da cor.
const PRIORIDADE := {"bad": 3, "warn": 2, "good": 1, "": 0}


# ── tempo mínimo na tela ────────────────────────────────────────────────────
#
# ⚠️ ESTE NÚMERO NÃO SAI DE VELOCIDADE DE LEITURA PUBLICADA, e a §7.1 diz
# porquê: "velocidade de leitura focada não prova leitura incidental mobile".
# Ninguém aqui consegue medir uma pessoa a ler — é o mesmo buraco do áudio,
# que este contêiner não ouve.
#
# O que se pode medir é a CONSEQUÊNCIA, e é de lá que o número sai: com esta
# conta, a rajada de 4 mensagens segura a faixa 10,6 s, e a ação mediana 2,4 s
# (`tools/medir_fila_mensagens.gd`). O desenho é feito para que o número não
# seja crítico — nada se descarta e o histórico está a um toque —, de modo que
# errá-lo custa espera, nunca informação perdida.
# ⚠️ `BASE` É BASE E NÃO PISO, e o nome errado escondia código morto: com
# `PISO + n * POR_CARACTERE` o resultado nunca cai abaixo de `PISO`, logo o
# limite de baixo de um `clamp` ali nunca faria nada — uma guarda que não
# guarda. Quem o apanhou foi a asserção do T8 que exigia que uma frase curta
# medisse exatamente o piso, e não media.
#
# Os dois números saem de querer ~2,4 s na frase MEDIANA do jogo (54
# caracteres) e ~3,3 s na mais longa (95, o fecho da semana): a reta por esses
# dois pontos dá 0,022 s por caractere e 1,2 s de base.
const BASE := 1.2
const POR_CARACTERE := 0.022
const TETO := 4.0

# O histórico vive na SESSÃO e não no save: a §7.1 pede recuperação "em memória
# da sessão, sem migrar save", e é isso que mantém o `SAVE_VERSION` intocado.
const HISTORICO_MAX := 60
# Uma mensagem sem dia conhecido. Não é zero: zero seria um dia que se lê.
const SEM_DIA := -1

var _fila: Array[Dictionary] = []
var _atual: Dictionary = {}
var _decorrido := 0.0

## O que já foi dito nesta sessão, do mais recente para o mais antigo.
var historico: Array[Dictionary] = []


## Quanto tempo uma frase segura a faixa. Cresce com o texto porque uma frase
## de 95 caracteres não se lê no tempo de uma de 30 — a mais longa do jogo
## hoje é o fecho da semana, com 95.
static func tempo_minimo(texto: String) -> float:
	return minf(BASE + texto.length() * POR_CARACTERE, TETO)


## Põe uma mensagem na fila. Devolve `false` quando ela foi FUNDIDA com uma
## igual que já estava à espera — e só nesse caso.
##
## ⚠️ COALESCÊNCIA É SÓ POR DUPLICATA SEMÂNTICA, que aqui quer dizer o MESMO
## TEXTO. Duas mensagens diferentes da mesma compra — "Píer 2 — pronto" e a
## fala do Zezão — não se fundem, e é isso que a §7.1 exige por escrito. Onde
## isto morde de verdade é na obra a partir da terceira, em que duas compras no
## mesmo turno escrevem a MESMA linha da Dona Cida: essa é a duplicata.
##
## O `dia` é o turno em que foi dita, e serve só ao histórico: a conversa
## separa as mensagens por dia (`docs/decisoes/067`). É da sessão, como o resto
## do histórico — o save não o vê. Quem não o sabe passa `SEM_DIA`, e a
## conversa não abre separador para ela.
##
## O `assunto` é o do aviso do porto (`GameState.message`), e a conversa põe
## o ícone dele na nota. A fala da Dona Cida não tem assunto: tem a cara dela.
##
## O `retrato` é a cara de quem falou naquela fala (a expressão dela), e a
## conversa põe-na no balão. Os avisos do porto não o têm.
func enfileirar(texto: String, kind: String, fonte: String, dia: int = SEM_DIA,
		assunto: String = "", retrato: Texture2D = null) -> bool:
	if texto == "":
		return false
	var entrada := {"texto": texto, "kind": kind, "fonte": fonte, "dia": dia,
		"assunto": assunto, "retrato": retrato}
	if _duplicata(texto):
		return false
	_guardar(entrada)
	if _atual.is_empty():
		_mostrar(entrada)
		return true
	_inserir_por_prioridade(entrada)
	return true


## GRAVA NO HISTÓRICO SEM MOSTRAR NA FAIXA: a fala de um personagem num
## painel (o Sr. Ribeiro, o Arlindo, a Dona Cida no boletim) já está na tela
## dele — pô-la também na faixa seria dizê-la duas vezes (`067`).
func registrar(texto: String, fonte: String, dia: int, retrato: Texture2D) -> void:
	if texto == "":
		return
	_guardar({"texto": texto, "kind": "", "fonte": fonte, "dia": dia,
		"assunto": "", "retrato": retrato})


func _guardar(entrada: Dictionary) -> void:
	historico.push_front(entrada)
	if historico.size() > HISTORICO_MAX:
		historico.resize(HISTORICO_MAX)


## Corre o relógio. Devolve `true` se a faixa mudou neste passo.
func avancar(delta: float) -> bool:
	if _atual.is_empty():
		return false
	_decorrido += delta
	if _decorrido < float(_atual["t_min"]):
		return false
	if _fila.is_empty():
		return false
	_mostrar(_fila.pop_front())
	return true


## Quantas esperam a vez. É o que a faixa mostra ao lado do texto.
func pendentes() -> int:
	return _fila.size()


func atual() -> Dictionary:
	return _atual


# A ATUAL TAMBÉM CONTA COMO DUPLICATA enquanto está na tela: sem isto, uma
# segunda obra igual no mesmo turno poria a mesma frase duas vezes seguidas —
# que é o que a fusão existe para evitar, e o caso que a nota do Bruno de 19/09
# levantou ("mais de uma compra pode ser feita por turno").
func _duplicata(texto: String) -> bool:
	if not _atual.is_empty() and String(_atual["texto"]) == texto:
		return true
	for e in _fila:
		if String(e["texto"]) == texto:
			return true
	return false


func _inserir_por_prioridade(entrada: Dictionary) -> void:
	var p: int = _peso(entrada)
	for i in range(_fila.size()):
		if _peso(_fila[i]) < p:
			_fila.insert(i, entrada)
			return
	_fila.append(entrada)


func _peso(entrada: Dictionary) -> int:
	return int(PRIORIDADE.get(String(entrada["kind"]), 0))


func _mostrar(entrada: Dictionary) -> void:
	_atual = entrada.duplicate()
	_atual["t_min"] = tempo_minimo(String(entrada["texto"]))
	_decorrido = 0.0
	apresentou.emit(String(_atual["texto"]), String(_atual["kind"]))
