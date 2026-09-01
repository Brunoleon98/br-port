class_name Narrativa
extends RefCounted

# ============================================================
# BR Port VS — o texto narrativo, num lugar só
#
# Item A4 do plano v3: as telas que carregam a Fase 1 como HISTÓRIA. O jogo
# tinha o loop inteiro e nenhum NPC — a Dona Cida não aparecia uma única vez no
# código, e o Sr. Ribeiro era uma linha de texto solta num painel.
#
# Este arquivo é para o texto o que o `Icones.gd` é para o ícone: o único lugar
# que sabe qual palavra é de quem. A alternativa — cada painel carregando as
# suas falas — foi o que aconteceu com os emojis, e trocar um custava caçar
# string por string em sete scripts.
#
# A FONTE é `docs/design/BR_Port_Frontload_Escrita_VS.md`, escrito no Bloco 1
# justamente para o texto não ser inventado à pressa na hora de codar. O que
# está aqui é aquele rascunho, com três desvios que o jogo OBRIGOU e que ficam
# registrados por escrito:
#
# 1. O FIM DE FASE FALAVA DE DOZE SEMANAS. O texto original abria com "Doze
#    semanas / Trinta e seis turnos de decisão / Três parcelas" — que é a Fase 1
#    inteira do GDD. O VS tem `WEEKS_TOTAL` semanas e UMA parcela. Escrever doze
#    seria mentir para o jogador sobre o jogo que ele acabou de jogar, então os
#    números saem das constantes (ver `fim_de_fase`) e não do texto: assim eles
#    não podem envelhecer quando o VS crescer.
#
# 2. O NOME DO JOGADOR PODE ESTAR VAZIO. O GDD dá padrão ao nome do porto
#    ("Cais Mirim") e não dá ao do jogador, e inventar um seria pôr palavra na
#    boca de quem não a escolheu. Toda fala com vocativo tem variante sem ele —
#    ver `_vocativo`. O Toninho já trata por "chefia" e o Arlindo por "sobrinho",
#    então ninguém fica sem forma de tratamento.
#
# 3. PORTO MIRIM É A CIDADE, CAIS MIRIM É O PORTO. São coisas diferentes e o
#    rascunho usa as duas: o banco do Sr. Ribeiro é de Porto Mirim (fixo) e o
#    cais é o que o jogador batiza. Trocar um pelo outro é o tipo de erro que
#    só se vê lendo em voz alta.
#
# Os tokens `{portName}` e `{playerName}` são resolvidos por
# `GameState.texto()`, que é o único ponto de substituição. Quem escrever texto
# novo aqui NÃO deve substituir à mão.
# ============================================================


# ── DIÁRIO DO PORTO — primeira página ──
# Abre uma vez, na semana 1. Primeira pessoa, incerteza com leveza.
const DIARIO_PRIMEIRA_PAGINA := """Nunca pensei que ia escrever nesse diário.

O avô escrevia aqui toda semana — vinte e três anos de {portName}, letra miúda, tinta azul. Eu achava piegas.

Hoje abri a primeira página em branco.

O {portName} tem dívida, tem madeira podre no píer e tem um rival que sabe o meu nome antes de eu saber o dele direito.

Mas tem gente que acreditou o suficiente pra estar aqui na semana 1.
Dona Cida. Toninho. Zezão.

Talvez o avô soubesse o que tava fazendo quando deixou tudo isso pra mim.

Talvez."""

const DIARIO_CABECALHO := "Porto Mirim, Semana 1"


# ── DONA CIDA — o boletim financeiro semanal ──
# Três tons, e o gatilho de cada um é o resultado da semana contra a média das
# anteriores. A faixa do meio existe para a comemoração ser RARA: sem ela,
# qualquer semana no azul soaria a festa e o tom perderia o valor.
const CIDA_BOLETIM_RUIM := """Conseguimos a façanha de gastar mais do que ganhar. De novo.
A semana anterior foi melhor — mas "melhor" aqui é comparativo de "ruim", então não comemora não.
A parcela não vai ter dó."""

const CIDA_BOLETIM_NEUTRO := """Os números fecharam. Receita cobre despesas, sobrou margem.
Nada extraordinário — mas porto que fecha no azul é porto que abre segunda-feira."""

const CIDA_BOLETIM_OTIMO := """Chefia. Olha esse resultado.
Não vou fazer festa — porque a parcela da próxima semana vai precisar desse dinheiro todo.
Mas por hoje: bem feito."""

# Acima de quanto da média das semanas anteriores o resultado conta como
# excepcional. Fonte: o próprio arquivo de escrita ("+30%").
const CIDA_LIMIAR_OTIMO := 0.30


# ── DONA CIDA — as linhas do loop ──
# Reagem a evento, não a turno: uma linha por semana viraria papel de parede.
# A chave é o id do evento; quem dispara é o `Main`.
const CIDA_LINHAS := {
	"reputacao_subiu": "O pessoal tá falando bem do cais, chefia. Raro. Aproveita.",
	"reputacao_caiu": "Dois contratos recusados essa semana. Arlindo vai saber antes de nós.",
	"caixa_baixo": "A conta tá mais fina que folha de papel. A parcela não vai esperar.",
	"perdeu_para_arlindo": "Perdeu pro Arlindo. Mas perdeu perdendo bem — não por desatenção.",
	"bom_contrato": "Esse contrato fecha o mês. Anota aí.",
	"semana_nova": "Semana nova. Barcos na fila, caixa no limite. Dia típico.",
	"upgrade_pronto": "Zezão terminou. Demorou o dobro do previsto, mas ficou bom.",
	"arlindo_indireto": "O Porto Farol tá aceitando tudo que a gente recusa. Coincidência, chefia?",
}


# ── ARLINDO — a contra-oferta ──
# Ele NÃO fala com o jogador: fala com o cliente, e o jogador ouve. É o que
# torna a tela uma negociação assistida em vez de uma discussão.
const ARLINDO_ABERTURA := "{portName} fez uma proposta. Entendo. Mas eu consigo cobrir isso — e um pouco mais."

# A reação sai do preset escolhido. As chaves batem com as três opções do
# painel; ver RIVAL_DISCOUNT / RIVAL_HALF_DISCOUNT / manter, no GameState.
const ARLINDO_REACOES := {
	"igualar": "Ficou nervoso, hein? Bom sinal.",
	"metade": "Metade do esforço. Respeito a tentativa.",
	"manter": "Autoconfiante. Gosto. Autoconfiante não paga conta — mas gosto.",
}

const ARLINDO_ULTIMA_TENTATIVA := "Minha oferta não expira. A paciência do senhor, sim."
const ARLINDO_VENCEU := "Sempre bom fazer negócio. Boa sorte pro {portName}."
const ARLINDO_PERDEU := "Dessa vez não. Mas tem mais semanas pela frente, sobrinho."


# ── SR. RIBEIRO — a cena da parcela ──
# Cena tensa, sem penalidade mecânica: o que ele traz é peso, não número. O
# número já está no botão.
const RIBEIRO_ENTRADA := """Boa tarde{vocativo}. Rivaldo Ribeiro, Banco Porto Mirim.
Fui amigo do seu avô — uns trinta anos, se não me engano.
Vim pessoalmente porque o {portName} merece esse respeito."""

const RIBEIRO_A_DIVIDA := """A Parcela vence hoje: {valor}. Tenho o documento aqui se quiser conferir.
O Seu Maneco assinou isso. Agora é seu."""

const RIBEIRO_PAGOU := """Perfeito. Eu sabia que dava.
Guarda esse recibo — o banco não esquece quem paga em dia, e eu também não.
Se precisar de fôlego em algum momento, me procura antes de ter problema. Não depois."""

const RIBEIRO_NAO_PAGOU := """Os juros já estão correndo. Não é punição, é contrato.
Mas vim pessoalmente porque sei que é o primeiro mês.
Uma vez eu deixo passar com uma conversa. Na segunda, o contrato fala por mim."""

const RIBEIRO_DESPEDIDA := """Uma coisa antes de ir.
O Seu Maneco me disse uma vez que o maior erro de um portuário é achar que pode resolver tudo sozinho.
Se precisar de crédito pra crescer — e vai precisar — o banco existe pra isso.
Não deixa chegar no desespero pra me ligar."""


# ── BOLETIM DO DIA ──
# Abre o turno com o que mudou desde ontem. Curto de propósito: é a tela que
# mais vezes se vê na partida inteira, e tela repetida cansa por acumulação.
const BOLETIM_DIA_TITULO := "Semana {semana}, dia {dia}"


# O AUTOLOAD NÃO RESOLVE PELO NOME AQUI DENTRO, e custou uma corrida a
# descobrir. `GameState.x` funciona num script de cena, que o Godot compila com
# os autoloads já registrados como identificadores; NÃO funciona dentro de um
# `class_name` alcançado a partir de um script de `--script`, porque essa classe
# é compilada antes disso. O erro sai como *"Compile Error: Identifier not
# found: GameState"* e derruba a suíte inteira, não só a linha culpada.
#
# É a irmã da regra do `GS` destipado que já está no CLAUDE.md, e tem a mesma
# origem: a suíte roda o jogo POR FORA, e por fora nem tudo o que existe em
# jogo existe. Buscar pela árvore funciona nos dois mundos.
#
# O tipo de retorno é `Node`, então quem receber algo dele escreve o tipo à
# mão — `var n: int = _gs().WEEKS_TOTAL`, nunca `:=`.
static func _gs() -> Node:
	return Engine.get_main_loop().root.get_node("GameState")


# O vocativo do jogador, com a vírgula que o precede — ou nada, se ele deixou o
# nome em branco. Devolver a vírgula junto é o que impede "Boa tarde ,." de
# aparecer na tela: a pontuação faz parte da decisão, não do modelo.
static func _vocativo() -> String:
	var nome: String = _gs().nome_jogador
	return ", " + nome if nome != "" else ""


# A fala de entrada do Sr. Ribeiro, já com vocativo resolvido. Os tokens de
# nome continuam a passar pelo `GameState.texto()`, que é o ponto único.
static func ribeiro_entrada() -> String:
	return _gs().texto(RIBEIRO_ENTRADA.replace("{vocativo}", _vocativo()))


static func ribeiro_a_divida(valor: int) -> String:
	return _gs().texto(RIBEIRO_A_DIVIDA.replace("{valor}", _gs().moeda(valor)))


# Qual dos três tons da Dona Cida a semana merece. `media_anterior` vem do
# histórico; na primeira semana não há com que comparar, e aí o que decide é só
# o sinal do resultado — comparar contra zero seria chamar de excepcional
# qualquer semana que fechasse no azul.
static func tom_do_boletim(resultado: int, media_anterior: float, tem_historico: bool) -> String:
	if resultado < 0:
		return CIDA_BOLETIM_RUIM
	if not tem_historico:
		return CIDA_BOLETIM_NEUTRO
	if float(resultado) > media_anterior * (1.0 + CIDA_LIMIAR_OTIMO):
		return CIDA_BOLETIM_OTIMO
	return CIDA_BOLETIM_NEUTRO


# A narração de fim de Fase 1.
#
# OS NÚMEROS SAEM DAS CONSTANTES, e é o ponto todo desta função. O rascunho
# dizia "Doze semanas / Trinta e seis turnos / Três parcelas", que é a Fase 1
# do GDD e não o VS — e um texto com número escrito à mão é um número a mais
# para envelhecer, que é exatamente o problema que a tabela dos números existe
# para resolver.
static func fim_de_fase() -> String:
	var semanas: int = _gs().WEEKS_TOTAL
	var turnos: int = _gs().TURNS_TOTAL
	var modelo := """%d semanas.

%d turnos de decisão.
Uma parcela.
E ela venceu.

O {portName} respira.

Ainda tem dívida?
Tem.

Ainda tem Arlindo no horizonte?
Tem.

Mas o cais que o Seu Maneco deixou
ainda é nosso.

—

O píer é o mesmo.

A mesma madeira velha.
O mesmo cheiro de maresia.
Os mesmos trabalhadores que conhecem cada tábua podre de cor.

Mas tem alguma coisa diferente.

Não no píer.

Em quem tá olhando.""" % [semanas, turnos]
	return _gs().texto(modelo)


# O texto do diário, com os nomes já resolvidos.
static func diario() -> String:
	return _gs().texto(DIARIO_PRIMEIRA_PAGINA)


# Uma linha da Dona Cida por id de evento. Devolve vazio para id desconhecido
# em vez de rebentar: uma fala que falta é um silêncio, não um crash — e o
# `teste_fumaca` confere que os ids usados pelo jogo existem todos aqui.
static func cida(id: String) -> String:
	return _gs().texto(String(CIDA_LINHAS.get(id, "")))
