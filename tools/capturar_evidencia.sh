#!/usr/bin/env bash
# ============================================================
# BR Port — as fotografias que provam o que ficou
#
# Item B3 do plano v3: "o CI prova que nada quebrou; não mostra o que ficou".
# Este script produz a evidência visual — a tela do jogo em vários estados e as
# duas folhas de contato — para o CI a anexar a cada PR e para quem trabalha
# aqui poder gerar exatamente as mesmas imagens.
#
# Uso:
#   tools/capturar_evidencia.sh <caminho-do-projeto> <pasta-de-saida> [godot]
#
# Exemplo, deste clone:
#   tools/capturar_evidencia.sh brport_vs /tmp/fotos "$G"
#
# AS DUAS BANDEIRAS QUE FAZEM A FOTO SER COMPARÁVEL, e ambas custaram medição:
#
#   --semente=  fixa o mundo sorteado. Sem ela, cada captura mostra outra
#   partida — outro caixa, outros barcos, outra barra de reputação — e quem
#   olha duas fotos não sabe o que é a mudança do PR e o que é o sorteio.
#
#   --fixed-fps 60 fixa o tempo. Só a semente NÃO chegou: medido, duas
#   corridas do mesmo código com a mesma semente davam 1.030 pixels
#   diferentes, porque os tweens em laço (o balanço do barco, a lança do
#   guindaste, o pulso do cartão) andam por DELTA e não por frame — cada
#   corrida fotografava outra fase da animação. Com o passo de tempo fixo as
#   duas ficam byte a byte idênticas, e aí a pergunta "a imagem mudou?" passa
#   a ter resposta.
#
# --audio-driver Dummy é só para calar o ALSA: não há placa de som aqui nem no
# runner, e o Godot despeja cinco linhas de erro antes de desistir sozinho.
#
# E CADA TIRO DIZ QUANTOS PAINÉIS ACEITA POR CIMA. A captura do porto
# reconstruído saía com o Boletim Financeiro tapando o mapa inteiro — com a
# semente fixa, doze turnos calham num fim de semana. A imagem chamava-se
# "porto" e mostrava uma tabela. Agora o tiro do mapa exige zero painéis e o do
# menu de pausa exige um: se uma constante deslocar a fronteira da semana, isto
# fica vermelho em vez de anexar a foto errada.
#
# E CADA TIRO DIZ TAMBÉM EM QUE TURNO PÁRA, que é a pergunta que faltava.
# Contar painéis no fim não diz se eles estavam abertos ENQUANTO o turno
# virava: medido em 17/09, `-- 12` fotografava o "Dia 11/32" com o Boletim por
# cima a dizer "Semana 1 de 4" — três turnos avançados por baixo de um modal
# que no jogo tapa o botão de avançar —, e a contagem de painéis via um painel
# e ficava contente. O turno declarado apanha as duas coisas de uma vez.
# ============================================================
set -euo pipefail

PROJETO="${1:?uso: $0 <projeto> <saida> [godot]}"
SAIDA="${2:?uso: $0 <projeto> <saida> [godot]}"
GODOT="${3:-${G:-}}"

if [ -z "$GODOT" ]; then
	GODOT=$(ls "$HOME"/godot-bin/Godot_v*-stable_linux.x86_64 2>/dev/null | head -1 || true)
fi
if [ ! -x "$GODOT" ]; then
	echo "erro: não achei o Godot. Passe o caminho como terceiro argumento ou exporte \$G." >&2
	exit 1
fi

mkdir -p "$SAIDA"

# A tela é retrato travado (720x1280); pedir outra resolução devolve a folha
# de ícones espremida — está escrito no cabeçalho do folha_icones.gd.
comum=(--path "$PROJETO" --resolution 720x1280 --rendering-driver opengl3
       --audio-driver Dummy --fixed-fps 60)

# ⚠️ UMA FOTO NOVA SÓ EXISTE A PARTIR DA MAIN, e isso é do workflow. O
# `captura.yml` fotografa também a BASE do PR, e até 07/09 fazia-o com o
# script DESTE commit apontado ao projeto da base: no dia em que se
# acrescentou a `frota`, o Godot respondeu "File not found" no checkout da
# base e a corrida ficou vermelha por o PR ter acrescentado evidência. Hoje o
# antes é tirado pelo script da própria base, e uma foto que só o HEAD tem
# aparece na tabela como "novo" — mas quem acrescentar um tiro aqui deve
# esperar exatamente isso na primeira corrida, e não um antes/depois.
#
# `xvfb-run -a` porque a captura precisa de contexto gráfico: teste e import
# rodam sem tela, esta não.
# tirar <nome> <painéis esperados, ou "-"> <turno esperado, ou "-"> <args do Godot...>
# ⚠️ E CADA TIRO TEM TETO DE TEMPO, que é a terceira forma de uma captura
# falhar sem nunca reprovar. Medido em 21/09, a construir um mutante: uma
# chamada com o número errado de argumentos dentro do `_process` de um
# `SceneTree` ABORTA a função — e um `--script` que aborta antes do `quit()`
# repete o `_process` a cada frame e NUNCA ENCERRA. A bateria não tinha teto
# nenhum: ficou pendurada, sem log, sem foto e sem uma palavra, até alguém a
# matar à mão. No CI isso não é vermelho, é o job inteiro a morrer de timeout
# vinte minutos depois, sem dizer qual tiro foi.
#
# 180 s é sessenta vezes o tiro típico (a bateria inteira, 24 tiros, corre em
# ~72 s) e ainda assim folgado para o mais lento, que é o `docas` com os
# `--frames=400` de tempo simulado. O `timeout` devolve 124, que cai no mesmo
# ramo de falha abaixo e diz o nome do tiro.
TETO_SEGUNDOS=180

tirar() {
	local nome="$1"; local paineis="$2"; local turno="$3"; shift 3
	local log="$SAIDA/$nome.log"
	timeout "$TETO_SEGUNDOS" xvfb-run -a "$GODOT" "${comum[@]}" "$@" > "$log" 2>&1 || {
		echo "::error::a captura '$nome' falhou (código $?):"; cat "$log"; return 1
	}
	# LOG AUSENTE OU VAZIO É REPROVAÇÃO, e não "nada a relatar". Tudo o que vem
	# a seguir são perguntas AO LOG: sem ele, cada uma delas responderia "não
	# encontrei" e o `grep` da linha de sucesso seria a única a reprovar, por
	# acidente. Uma guarda que depende de um arquivo diz primeiro que ele existe.
	if [ ! -s "$log" ]; then
		echo "::error::a captura '$nome' não deixou log nenhum — não há o que inspecionar." >&2
		return 1
	fi
	# A LINHA DE SUCESSO, NÃO O CÓDIGO DE SAÍDA. É a regra que o CLAUDE.md já
	# cobra da suíte, e vale igual aqui: um erro de compilação do GDScript sai
	# com 0 sem a ferramenta ter feito nada.
	grep -qE "(Tela|Folha) salva em" "$log" || {
		echo "::error::a captura '$nome' não escreveu imagem nenhuma:"
		cat "$log"; return 1
	}
	# ⚠️ E A LINHA DE SUCESSO NÃO DIZ QUE NÃO HOUVE ERRO. É a outra metade da
	# mesma lição de 07/09, e faltava aqui: o `testes.yml` pergunta por
	# `SCRIPT ERROR` em seis passos e a captura não perguntava em nenhum dos
	# dezasseis — uma tela meio montada imprimia "Tela salva em", cumpria a
	# guarda acima e era anexada ao PR como evidência.
	#
	# ⚠️ E O PADRÃO NÃO É `ERROR`, QUE REPROVARIA O CÓDIGO CERTO. Medido em
	# 18/09: a corrida SAUDÁVEL do simulador de 600 partidas imprime
	# `ERROR: 1 resources still in use at exit`, e imprime-o DEPOIS do
	# marcador. Pior, o prefixo não separa as duas coisas — medido numa sonda,
	# `push_error()` sai como `ERROR:` e não como `USER ERROR:`, de modo que a
	# queixa da própria ferramenta ("nao consegui comprar X", que já aconteceu
	# aqui) tem o mesmo prefixo da contabilidade de encerramento do motor.
	# O que as separa é a ORIGEM.
	#
	# ⚠️ E A ORIGEM NÃO SE LÊ NUM CATÁLOGO DE MENSAGENS — o Godot ESCREVE-A.
	# Até 21/09 o par era `SCRIPT ERROR|at: push_error \(`, e ele conhecia
	# duas formas de erro de três. O `PainelCaixa` provou-o: o `setup()` dele
	# exige um `Dictionary`, o `capturar_cena.gd` chamou-o com zero argumentos,
	# e a queixa saiu como
	#
	#     ERROR: Error calling method from 'callv': ... expected 1 argument(s)
	#        at: callv (core/object/object.cpp:888)
	#        GDScript backtrace (most recent call first):
	#            [0] _chamar_setup (res://tools/capturar_cena.gd:134)
	#
	# — `ERROR:` sem `SCRIPT` e `at:` a apontar para C++, porque quem se queixa
	# é o MOTOR sobre uma chamada que o NOSSO script fez. Nenhum dos dois
	# padrões casava, e a foto PRETA seria anexada ao PR com a bateria verde.
	#
	# Quem separa as três é o bloco `GDScript backtrace`, que o Godot só
	# escreve quando o erro tem pilha de script. Medido nesta versão (4.6.3),
	# numa sonda de cada forma:
	#
	#   push_error()                  ERROR:         COM backtrace
	#   erro de execução (nil)        SCRIPT ERROR:  COM backtrace
	#   erro de COMPILAÇÃO (parse)    SCRIPT ERROR:  SEM — `at: GDScript::reload`
	#   chamada falhada (callv)       ERROR:         COM backtrace
	#   ruído de encerramento         ERROR:         SEM — `at:` em C++
	#
	# Logo são estes dois: `SCRIPT ERROR` apanha o que não chega a correr, e
	# `GDScript backtrace` apanha tudo o que correu e se queixou. O
	# `at: push_error (` saiu por ser SUBCONJUNTO do segundo — medido, não
	# suposto —, e a regra deste projeto é apagar a cópia.
	#
	# ⚠️ E O ALARGAMENTO PÁRA AQUI, que é o escopo do defeito. O `testes.yml` e
	# o `balanceamento.yml` continuam com o par antigo de propósito: lá corre o
	# `teste_fumaca`, que imprime um erro de JSON DE PROPÓSITO — o save inválido
	# que ele injeta para provar que o jogo o recusa —, e esse traz backtrace.
	# Esta bateria só roda ferramentas de captura, e nas 17 corridas saudáveis
	# medidas hoje os logs não têm UMA linha `ERROR` sequer.
	if grep -qE "SCRIPT ERROR|GDScript backtrace" "$log"; then
		echo "::error::a captura '$nome' imprimiu erro — a foto não vale o que promete:" >&2
		grep -nE "SCRIPT ERROR|GDScript backtrace" -A 4 "$log" >&2
		return 1
	fi
	if [ "$paineis" != "-" ]; then
		local visto
		visto=$(sed -n 's/^Overlay: \([0-9]*\) .*/\1/p' "$log")
		if [ "$visto" != "$paineis" ]; then
			echo "::error::'$nome' esperava $paineis painel(eis) por cima e viu ${visto:-nenhuma leitura}." >&2
			return 1
		fi
	fi
	# ⚠️ O TURNO EM QUE A FOTO FOI TIRADA, e ele é declarado aqui de propósito.
	# A ferramenta avança o jogo e IMPRIME onde parou; este arquivo diz onde
	# devia parar — duas fontes, como no D20. Até 17/09 ninguém comparava as
	# duas, e `-- 10` entregava o turno 9 porque cada oferta do rival comia uma
	# iteração do laço; `-- 34` entregava o turno 27 e TRÊS Boletins empilhados,
	# avançados por baixo de um modal que o jogador não consegue atravessar.
	# Com esta linha, qualquer uma das duas coisas fica vermelha.
	if [ "$turno" != "-" ]; then
		local visto_turno
		visto_turno=$(sed -n 's/^Overlay: .*turno \([0-9]*\).*/\1/p' "$log")
		if [ "$visto_turno" != "$turno" ]; then
			echo "::error::'$nome' esperava parar no turno $turno e parou no ${visto_turno:-nenhuma leitura}." >&2
			return 1
		fi
	fi
}

# ⚠️ OS TIROS DE MAPA PEDEM `limpo`, E ISSO SUBSTITUIU UM NÚMERO DE SORTE.
# Aqui dizia-se "onze turnos já abrem o Boletim, por isso o mapa é fotografado
# a DEZ" — um turno escolhido para cair rente à fronteira da semana. Quando os
# upgrades mudaram a vazão do porto, o 10 passou para o outro lado dela e a
# foto do `porto` saiu com a tabela por cima do mapa. `limpo` manda a
# ferramenta fechar os painéis de ROTINA, e o tiro deixa de depender de onde a
# semana calha.
tirar inicio  0 1  --script res://tools/capturar_tela.gd -- 0  "$SAIDA/inicio.png" limpo
tirar porto   0 11 --script res://tools/capturar_tela.gd -- 10 "$SAIDA/porto.png" completo limpo
# O NÍVEL DO MEIO. O píer, a lança e os prédios têm três níveis desde 05/09, e
# `inicio` e `porto` só mostram os dois extremos — o do meio não tinha como ser
# olhado, e o gate A5 é olhar. `meio` compra as duas primeiras estruturas, que é
# o que `nivel_pier()` e `nivel_guindaste()` leem como n2.
#
# ⚠️ A ZERO TURNOS, e isto custou uma corrida vermelha. Ela nasceu a 10, por
# cópia do `porto`, e no runner do CI apareceu um painel por cima — a foto é
# tirada com o jogo na FASE em que os turnos o deixaram, e dez turnos são dez
# oportunidades de o deixar numa fase que abre painel. Esta foto existe para
# mostrar a ARTE do nível 2, não a economia: sem turno nenhum não há fase que
# abra nada, e o porto já está montado porque a compra não depende de jogar.
tirar meio    0 1  --script res://tools/capturar_tela.gd -- 0  "$SAIDA/meio.png" meio limpo
# O PORTO A OPERAR, com os camiões nos berços. Ela existe pela mesma razão que
# a folha da frota: a visita à doca só acontece com barco E trabalhador na
# mesma doca, e os cinco tiros acima fotografam sempre o instante em que os
# trabalhadores estão livres — o laço deles aloca ANTES de cada avanço, nunca
# depois do último. A mecânica passava em oito asserções e não aparecia em
# imagem nenhuma.
#
# `--frames=400` são 6,7 segundos de tempo SIMULADO (o `--fixed-fps 60` fixa o
# passo, então a foto continua reprodutível): o camião leva ~1,4s a chegar ao
# acesso e ~3,3s a descê-lo. Dois dos três encostam; o terceiro parte depois do
# acesso dele e segue pela estrada, que é o outro estado que se quer ver.
tirar docas   0 11 --script res://tools/capturar_tela.gd -- 10 "$SAIDA/docas.png" completo limpo alocar --frames=400
# O PORTO EM RUÍNAS A OPERAR, que é onde a frota de PESCA vive.
#
# ⚠️ ELA ENTROU POR UM BURACO MEDIDO, e o buraco é do mesmo feitio do que fez
# nascer a folha da frota. Os barcos de pesca só atracam no porto de NÍVEL 1
# (`docs/decisoes/009`), e das oito imagens de então nenhuma o mostrava a
# trabalhar: o `inicio` é o turno ZERO, com as docas a dizer "aguardando", e o
# `meio`, o `porto` e as `docas` são portos de nível 2 e 3, que recebem
# cargueiro. Os três cascos de pesca de 08/09 chegariam à tela do jogador
# logo no primeiro dia e a foto nenhuma — e o porto em ruínas é onde o perfil
# Descuidado passa a partida inteira.
#
# Seis turnos com os trabalhadores alocados: barco na doca, e os dois
# ancorados da Zona de Espera atrás dele.
tirar pesca   0 7  --script res://tools/capturar_tela.gd -- 6  "$SAIDA/pesca.png" limpo alocar
# ⚠️ O TRABALHADOR ESCOLHIDO, que até 22/09 não estava em foto NENHUMA. O
# cartão dele tem borda própria — âmbar, e do dobro da largura do repouso —, e
# ela chega por um TOQUE: nada nos 24 tiros anteriores tocava num trabalhador,
# logo a última cor de interface fora do tema atravessou quatro levas de
# migração sem que a bateria pudesse vê-la. Um controle positivo sobre um
# estado que nenhuma foto monta mexe em ZERO fotos e não prova nada
# (`docs/decisoes/042`), e é por isso que este tiro faz parte da entrega da
# leva e não de um item de captura à parte.
#
# SEM `alocar`: as duas bandeiras brigam. Alocar tira o trabalhador de livre, e
# o `_pode_ser_selecionado()` limpa a seleção de quem deixou de o ser — a foto
# sairia com o cartão em repouso e passaria por boa.
#
# ⚠️ E NO TURNO 2, NÃO NO 1 (`050`). No turno 1 a doca dizia "aguardando
# barco": a foto mostrava a seleção partindo do LIVRE, que é a única em que
# escolher não serve para nada — tocar numa doca dá "Doca vazia". Só se aloca
# com barco à espera, e aí o cartão vem do PARADO. No turno 2 a doca 1 tem
# barco e está "sem trabalhador", e é essa a troca que o jogador vê.
tirar escolhido 0 2 --script res://tools/capturar_tela.gd -- 1  "$SAIDA/escolhido.png" limpo escolher
# O BOLETIM, E OS 12 SÃO UM TETO E NÃO UMA PROMESSA. Sem `limpo` a ferramenta
# recusa-se a avançar por baixo dele, de modo que o laço acaba no turno em que
# ele abre — o 9, primeiro dia da semana 2. Pedir MAIS do que isso é de
# propósito: é o único tiro da bateria em que o alvo fica por alcançar, e por
# isso o único que denuncia um laço que volte a atravessar o modal. Com `-- 8`
# o alvo e a abertura do Boletim calhariam no mesmo turno, e o defeito passaria
# despercebido — é a armadilha da fixture copiada da execução real.
tirar boletim 1 9  --script res://tools/capturar_tela.gd -- 12 "$SAIDA/boletim.png" completo
# ⚠️ O MENU DE PAUSA ABRE DEPOIS DE JOGAR, e leva `limpo` por causa disso.
# Ele era aberto ANTES dos oito turnos, que corriam por baixo dele — o mesmo
# defeito do Boletim, na tela que existe para PARAR o jogo. Aberto no fim, o
# turno 9 já abriu o Boletim da semana 2: `limpo` fecha-o, como o jogador o
# fecharia antes de pausar, e o painel que sobra é o que se quer fotografar.
tirar pausa   1 9  --script res://tools/capturar_tela.gd -- 8  "$SAIDA/pausa.png" completo pausa limpo
# O DIÁRIO, e ele entrou por uma falha MEDIDA como a da frota. É a PRIMEIRA
# tela que o jogador lê e nenhum dos tiros acima a monta — ela abre uma vez,
# encadeada à tela de nomes, e nenhuma partida fotografada passa por lá. Em
# 11/09 acrescentaram-se três linhas ao texto: ele transbordou a área rolável e
# a primeira tela passou a acabar a meio da frase que fecha o diário, com as
# cinco suítes verdes. Painel de LEITURA tem a altura calibrada contra o texto,
# e texto é o que mais muda — então ele fotografa-se.
tirar diario  - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/PainelDiario.tscn "$SAIDA/diario.png"
# A PARCELA, COM O DESCONTO À VISTA — e o estado é montado de propósito. O
# abatimento por antecipação (`docs/decisoes/019`) só existe com a parcela por
# pagar e o vencimento ainda longe; um `GameState` recém-nascido está no FIM do
# prazo, onde o desconto é zero por construção, e a foto sairia verdadeira e
# sobre outra coisa. `turn=8` põe-na na semana 1, com 24 turnos de antecipação
# e R$31.800 de abatimento — que é a única forma de alguém OLHAR a mecânica.
#
# Este painel era incapturável até 12/09, e em silêncio: o `capturar_cena.gd`
# só chamava `setup()` quando havia argumentos extra, e os quatro painéis de
# `setup()` sem argumento obrigatório saíam como um escurecer vazio que passava
# por bom. O Diário escapou por montar no `_ready()`.
tirar parcela - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/PainelParcela.tscn "$SAIDA/parcela.png" turn=8 cash=900000
# AS DUAS CENAS COM GENTE DENTRO, e nenhuma delas tinha foto. Desde 13/09 a
# Dona Cida, o Arlindo e o Sr. Ribeiro têm RETRATO ao lado da fala, e das doze
# imagens desta bateria só o boletim mostrava um dos três — as outras duas
# cenas nunca foram fotografadas por ninguém, nem antes dos retratos. É o
# buraco da frota outra vez: arte que existe, é validada por duas suítes e não
# aparece em imagem nenhuma que se possa olhar.
#
# O VALOR DA PARCELA VEM DA CONSTANTE (`@PARCELA_AMOUNT`) e não escrito aqui:
# a fala dele diz o número, e um número cravado numa ferramenta de evidência
# envelhece calado — ver o cabeçalho do `_chamar_setup`.
#
# ⚠️ E CADA UMA É MAIS DE UMA TELA. Até 23/09 fotografava-se só o primeiro
# tempo: a resposta do Sr. Ribeiro e a despedida do Arlindo só tinham sido
# vistas à mão, e a despedida trazia "Cliente ouvindo a proposta. (2
# tentativas)" por baixo de um negócio já fechado (`docs/decisoes/051`). O
# segundo tempo alcança-se pelo BOTÃO (`--tocar=`), e cada tiro diz em que
# tempo pára (`--tempo=`) — o painel diz onde está, e as duas fontes têm de
# bater, como o turno dos tiros de jogo.
#
# ⚠️ E O SR. RIBEIRO SÓ VEM NO VENCIMENTO. `parcela=vencida` joga a partida
# até lá pelo `advance_turn()`: fora da fase "debt_payment" o `pay_debt()` sai
# calado, e a foto do "Pagar" mostraria a resposta de quem pagou sem o dinheiro
# ter mudado de mãos. A entrada passou a dizer o dinheiro de quem chega ao
# vencimento sem jogar (R$336.000), e não o do turno 1. "Pagar" só está ligado
# com dinheiro para a parcela (`cash=@PARCELA_AMOUNT`); "Não consigo pagar" só
# existe sem ele.
tirar ribeiro - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/DebtPaymentPanel.tscn "$SAIDA/ribeiro.png" @PARCELA_AMOUNT parcela=vencida --tempo=entrada
tirar ribeiro_pagou - - --script res://tools/capturar_cena.gd -- res://scenes/panels/DebtPaymentPanel.tscn "$SAIDA/ribeiro_pagou.png" @PARCELA_AMOUNT parcela=vencida cash=@PARCELA_AMOUNT --tocar=Pagar --tempo=pagou
tirar ribeiro_nao_pagou - - --script res://tools/capturar_cena.gd -- res://scenes/panels/DebtPaymentPanel.tscn "$SAIDA/ribeiro_nao_pagou.png" @PARCELA_AMOUNT parcela=vencida --tocar=Não --tempo=nao_pagou
tirar contraoferta - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/CounterOfferPanel.tscn "$SAIDA/contraoferta.png" barco=0 0 --tempo=rodada
# A despedida pelo "Igualar", que fecha SEMPRE: é a fala de quem perdeu. A de
# quem ganhou pede duas apostas falhadas, e isso é sorteio — o mesmo tempo, com
# outra frase, e quem a mede a caber no cartão é o F10.
tirar contraoferta_fim - - --script res://tools/capturar_cena.gd -- res://scenes/panels/CounterOfferPanel.tscn "$SAIDA/contraoferta_fim.png" barco=0 0 --tocar=Igualar --tempo=despedida
# O MENU-CELULAR (item 17). Ele é a primeira tela deste jogo com fundo ESCURO,
# e a captura é a única coisa que responde se um rótulo herdou a cor de texto
# de cartão branco e sumiu — o D23 mede o contraste das VARIAÇÕES do tema, que
# é outra pergunta: um `Label` que esqueça a variação não reprova nada e sai
# navy sobre navy.
#
# `turn=9` põe-no na semana 2, e é escolha e não sorte: a barra de status diz
# "Dia N/32 · Semana S" e num `GameState` recém-nascido as duas metades leriam
# 1 e 1, que é o único estado em que um erro de conta entre elas não apareceria.
tirar menu    - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/PainelMenu.tscn "$SAIDA/menu.png" turn=9
# O HISTÓRICO DA FAIXA (R5 da §7.1). Ele é a única resposta à pergunta "o que
# passou enquanto eu olhava para o mapa?", e nenhum dos tiros acima o monta:
# abre por um TOQUE na faixa de mensagem, depois de a sessão ter acumulado o
# que dizer. Fotografá-lo com `capturar_cena.gd` daria a tela do vazio — uma
# foto verdadeira de um estado que só existe no primeiro segundo do jogo, que
# é a armadilha que o `capturar_cena` já levou uma vez com o `setup()` saltado.
tirar mensagens 1 11 --script res://tools/capturar_tela.gd -- 10 "$SAIDA/mensagens.png" completo limpo mensagens

# ══ OS CINCO PAINÉIS QUE NENHUMA FOTO MOSTRAVA ═══════════════════════════════
#
# Medido em 21/09: das treze telas do jogo, oito tinham tiro aqui e CINCO não —
# Construir, Calendário, Docas, Reputação e Caixa. Três delas são exactamente
# as que o R7 e o R8 mexeram naquele dia (`docs/decisoes/036` e `037`), e as
# duas sessões olharam à mão, fora da bateria: o que não deixa antes/depois no
# PR e não se repete sozinho. A regra 5 do `CLAUDE.md` manda tirar uma captura
# e olhar quando se mexe no visual; isto é essa captura.
#
# ⚠️ E OS CINCO VÃO PELO `capturar_tela.gd`, e não pelo `capturar_cena.gd` que
# fotografa os outros painéis. Três razões, todas medidas:
#
#   1. O ESTADO. Um painel instanciado solto nasce numa partida RECÉM-CRIADA, e
#      é aí que estes cinco não dizem nada: no dia 1 o calendário não tem dia
#      passado, no porto em ruínas o Construir não tem uma estrutura verde, e
#      com UMA doca a contagem nunca passa de 1 — que é precisamente onde o
#      singular e o plural do R8 dão o mesmo texto. O estado que estes painéis
#      precisam é uma partida JOGADA, e jogar é o que esta ferramenta faz.
#   2. O `PainelCaixa` PEDE UM `Dictionary`, que a linha de comando não sabe
#      escrever. Aqui quem lho passa é o `_on_caixa_pilula_input` do jogo, com
#      `GameState.resumo_do_dia()` — DERIVADO, que é a regra desta bateria.
#   3. AS DUAS GUARDAS. Os tiros de `capturar_cena.gd` passam "- -" porque
#      aquela ferramenta não imprime a linha `Overlay:`; por aqui cada um
#      declara quantos painéis aceita e em que turno pára, como os de mapa.
#
# Cada um abre pela PORTA DO JOGADOR (`--painel=`, a tabela `PAINEIS` do
# `capturar_tela.gd`): a mesma pílula do HUD que ele toca.

# O CONSTRUIR COM OS TRÊS ESTADOS DE CARTÃO NA MESMA FOTO, que é o que `meio`
# dá e nenhum outro estado dá: duas estruturas CONSTRUÍDAS (o verde e o
# "Construída"), quatro com BOTÃO, e o cais BLOQUEADO — que é o cartão que o R6
# encurtou em 60px ao tirar de lá o botão desligado, trocando-o pela frase
# "Precisa antes de: Guindaste de pórtico." (`docs/decisoes/035`). Com o porto
# em ruínas não há verde nenhum; com `completo` são sete verdes e mais nada.
#
# ⚠️ FICA DE FORA O IMPEDIMENTO POR DINHEIRO ("Faltam R$…"), e é por
# construção: o `meio` soma ao caixa o custo de TODAS as estruturas antes de
# comprar duas, então aqui nada é caro demais. O cartão bloqueado desta foto
# é-o pelo `requer`, e é o mesmo desenho.
#
# A zero turnos pela razão do tiro `meio` ao lado: dez turnos são dez
# oportunidades de o jogo parar numa fase que abre painel, e esta foto é sobre
# os cartões, não sobre a economia.
tirar construir  1 1  --script res://tools/capturar_tela.gd -- 0  "$SAIDA/construir.png" meio limpo --painel=construir
# O CALENDÁRIO COM DIA PASSADO, que é o estado que a régua do contraste NÃO
# monta. O percurso dos 19 estados do `medir_contraste_ui.gd` abre o calendário
# no dia 1 — e foi por isso que a cor dos dias já vividos viveu escrita à mão
# no painel, a 0,52, enquanto o tema dizia 0,50 (`docs/decisoes/036`). Hoje ela
# é a variação `RotuloApoio`, e esta é a primeira foto em que alguém a vê.
#
# O dia 10 monta as três cores de uma vez — nove dias PASSADOS, o de HOJE em
# âmbar a 17px, e o resto por vir — mais os dois marcadores que a legenda
# traduz: o "•" do fecho de cada semana e o "!" do vencimento da parcela.
# `limpo` porque o turno 9 abre o Boletim da semana 2, e sem ele o laço pára lá.
tirar calendario 1 10 --script res://tools/capturar_tela.gd -- 9  "$SAIDA/calendario.png" limpo --painel=calendario
# AS DOCAS COM A CONTAGEM ACIMA DE UM, que é a única forma de a frase do R8
# provar alguma coisa. Medido: com o porto de uma doca `ocupadas` nunca passa
# de 1, e a 1 a versão certa e a errada escrevem o mesmo texto. No turno 10 do
# porto completo são DUAS ocupadas e uma à espera — o plural que sai do
# `Narrativa.concordar` ao lado do "1 esperando trabalhador", que é o gerúndio
# que o R8 decidiu NÃO concordar (`docs/decisoes/037`). As duas regras na mesma
# linha, numa foto.
#
# ⚠️ O NOME É `painel_docas` PORQUE `docas` JÁ EXISTE — é o tiro do mapa com os
# camiões nos berços, lá em cima. Renomear aquele para libertar o nome custaria
# o antes/depois dele: o `captura.yml` casa as duas corridas pelo NOME do
# arquivo, e uma foto renomeada aparece como uma removida e uma nova.
#
# ⚠️ E FICA DE FORA A SECÇÃO "A PRÓXIMA DOCA", com o impedimento da estrutura
# que abre o berço seguinte: ela só existe com UMA ou DUAS docas, e aí a
# contagem volta a não passar de 1. As duas metades deste painel não cabem no
# mesmo estado; escolheu-se a que o R8 mexeu.
tirar painel_docas 1 10 --script res://tools/capturar_tela.gd -- 9 "$SAIDA/painel_docas.png" completo limpo --painel=docas
# A REPUTAÇÃO FORA DO PATAMAR DE PARTIDA. O jogo abre em 65,0 ("Respeitado"), e
# uma foto tirada aí não distinguiria um "▸" que ANDA de um "▸" pregado na
# terceira linha. Treze turnos do porto completo levam-na a 85,6, que é
# "Referência" — o patamar de cima —, e o marcador em âmbar está lá.
#
# O número vem de JOGAR e não de um `reputation=85` escrito à mão: é a mesma
# regra que tirou os R$100.000 cravados do `capturar_tela.gd`.
tirar reputacao  1 13 --script res://tools/capturar_tela.gd -- 12 "$SAIDA/reputacao.png" completo limpo --painel=reputacao
# O CAIXA, QUE ERA INCAPTURÁVEL — e a foto prova as duas metades de uma vez.
#
# O `setup()` dele exige um `Dictionary` e o `capturar_cena.gd` chamava-o com
# zero argumentos: o painel não montava, e a ferramenta imprimia "Tela salva
# em" e saía com código 0 com uma foto PRETA (`docs/decisoes/037`). Por aqui o
# argumento é `GameState.resumo_do_dia()`, montado pelo jogo.
#
# O TURNO 13 É ESCOLHA, e a conta é a do R8: "ONTEM — DIA 12" fecha com DOIS
# barcos atendidos (o plural) e a projeção de hoje diz "1 barco atendido e 2
# perdidos" — o singular e o plural na MESMA frase, que é a concordância
# inteira a funcionar nos dois sentidos. E os dois blocos têm linha de receita,
# de modo que a regra "linha com zero não entra" também se vê.
#
# ⚠️ E ESTE TIRO NÃO LEVA `alocar`, ao contrário do `docas` lá em cima: alocar
# no fim daria trabalhador aos dois barcos à espera e a projeção perderia os
# "2 perdidos", que é o aviso que este painel existe para dar.
tirar caixa      1 13 --script res://tools/capturar_tela.gd -- 12 "$SAIDA/caixa.png" completo limpo --painel=caixa
# ══ E ERAM SETE, NÃO CINCO ══════════════════════════════════════════════════
#
# O briefing desta sessão contou treze telas — oito com tiro e cinco sem. No
# disco são QUINZE, e as duas que faltavam à conta são as duas de baixo.
# Nenhuma das duas é um descuido do briefing: a `TelaNomes` ele mandou
# conferir, e o `EndGame` não vive em `scenes/panels/` — está em
# `scenes/EndGame.tscn`, e por isso escapa a todo inventário que olhe a pasta.
# É a regra do `CLAUDE.md`: antes de herdar o buraco que um briefing anuncia,
# pergunte a que fonte ele o perguntou, e pergunte à outra.

# A PRIMEIRA TELA QUE O JOGADOR VÊ, e nunca ninguém a olhou aqui. Ela não
# aparece em tiro nenhum de jogo por construção: o `capturar_tela.gd` chama
# `definir_nomes()` de propósito para a DISPENSAR, senão ela ficaria por cima
# de tudo o que se queria fotografar. Logo, a única forma de a ver é solta.
#
# Ela monta no `_ready()` como o Diário, portanto não precisa de `setup()`.
tirar nomes   - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/TelaNomes.tscn "$SAIDA/nomes.png"
# O FIM DA FASE 1, primeiro tempo — a narração, que é o painel com mais
# história por fotografar deste projeto. Ele deu 430px a um texto que pede 847:
# o remate ("Em quem tá olhando.", a linha para onde a peça inteira anda) nunca
# esteve na tela sem rolar, com o botão logo abaixo a convidar a sair. A altura
# passou a sair de `altura_do_texto()` e o D22 tranca-a — e esta é a primeira
# imagem em que alguém CONFIRMA que o remate cabe.
#
# `true` é a vitória, e é ela que leva a narração: quem perde vai direto ao
# balanço, de propósito (ler um cais que continua de pé por cima de uma derrota
# seria escárnio — está escrito no cabeçalho do `EndGame.gd`).
#
# O SEGUNDO TEMPO, o balanço, NÃO sai daqui, e a razão é a regra do zero: ele
# lê `GameState.metrics`, que numa cena solta é uma partida recém-criada — a
# foto diria "Barcos atendidos: 0" e isso LÊ-SE COMO MEDIDA. Ele é o tiro
# `balanco`, logo abaixo, que JOGA a partida (`docs/decisoes/051`).
#
# A frase da vitória é a que o `_check_end()` escreve, copiada — e este tempo
# NÃO A MOSTRA (só o balanço usa o `_motivo`), de modo que ela envelhecer aqui
# não muda um pixel desta foto.
tirar fimfase - -  --script res://tools/capturar_cena.gd -- res://scenes/EndGame.tscn "$SAIDA/fimfase.png" true "Você quitou a parcela e manteve o porto no azul!" --tempo=narracao
# O BALANÇO, numa partida JOGADA: o laço de sempre até ao vencimento (turno
# 33), o «Pagar» do Sr. Ribeiro — ligado porque a partida juntou o dinheiro,
# nunca porque a ferramenta o deu — e o «Ver o balanço» da narração. Foi a
# última lacuna declarada da cobertura, e saiu dela no mesmo commit.
#
# ⚠️ É UM PAINEL, e até 23/09 eram três. O «Pagar» fecha a semana 4 e acaba a
# partida na mesma chamada, e o boletim e o fim de fase abriam POR CIMA da
# resposta do Sr. Ribeiro — quem tocava «Jogar de novo» nunca a lia. Hoje o
# `Main` põe-nos em fila (`_na_vez()`, `docs/decisoes/054`): resposta →
# boletim → fim de fase, e a ferramenta percorre-a pelos botões do jogador,
# reprovando em cada passo se o painel de cima não for o da vez ou não estiver
# sozinho. A contagem daqui tranca o fim; os passos trancam a ordem.
tirar balanco 1 33 --script res://tools/capturar_tela.gd -- 32 "$SAIDA/balanco.png" limpo balanco
tirar icones  - -  --script res://tools/folha_icones.gd  --    "$SAIDA/icones.png"
# A FROTA, e ela entrou por uma falha MEDIDA das fotos acima. Em 07/09 os
# cascos passaram a ser seis — um por par de classe e motivo — e os camiões
# oito; as cinco fotos de jogo mostraram DOIS cascos e um camião, porque quem
# escolhe o que atraca é o sorteio da partida. Quatro cascos e sete camiões
# ficavam gerados, validados por duas suítes, e sem ninguém os poder olhar —
# que é o buraco do `barco_medio` outra vez. Uma folha que percorre a tabela
# não depende de sorteio, como a dos ícones já não dependia.
# ⚠️ SÃO DUAS FOLHAS desde 23/09: com os oito camiões do retorno a folha
# única pedia 1.305 px numa tela de 1.280, e a conta dela reprovou. Cada uma
# continua a reprovar se transbordar.
tirar frota   - -  --script res://tools/folha_frota.gd   --    "$SAIDA/frota.png" cascos
tirar camioes - -  --script res://tools/folha_frota.gd   --    "$SAIDA/camioes.png" camioes

# OS TRINTA ROSTOS DO TRABALHADOR (`docs/decisoes/059`), pela mesma razão: o
# porto tem no máximo três trabalhadores e a semente da bateria é fixa, logo as
# fotos de jogo mostram três rostos, e sempre os mesmos. A folha percorre o
# `Retratos.TRABALHADORES` em cartões de verdade e reprova o cartão que mostre
# outro arquivo ou nenhum desenho.
tirar trabalhadores - - --script res://tools/folha_trabalhadores.gd -- "$SAIDA/trabalhadores.png"

# OS PROPS DE MAPA, todos, a 1:1. A segunda metade da medição do gate A5 — o
# plano diz "captura antes/depois lado a lado, E a folha de contato dos props"
# —, e a que faltava desde sempre. A `folha_icones` cobre os ícones e a
# `folha_frota` os cascos e camiões; o resto do catálogo não tinha foto que o
# percorresse, e foi assim que a pasta `art/brp` inteira ficou oito assets
# gerados, validados a cada corrida do CI e invisíveis.
#
# ⚠️ E O CHÃO DE CADA CÉLULA É AMOSTRADO DO MAPA desde 16/09, em vez do fundo
# único que a folha usava. A âncora sai da CENA e a cor sai do raster do mapa —
# duas fontes, como no D20 e no D21 —, e a célula leva uma faixa por chão
# distinto: quem pisa dois (a gaivota, a maria-farinha, o coqueiro) fica em cima
# da emenda. O que não cai em sítio nenhum do mapa sai LISTRADO e escrito, para
# a folha não mentir sobre o que mediu.
#
# ⚠️ AS DUAS PÁGINAS SÃO PARTE DO CONTRATO, e não um detalhe de arrumação. A
# ferramenta conta quantas páginas o catálogo pede e REPROVA se não forem as
# que se pediram aqui: um prop novo que empurre para uma terceira página fica
# vermelho em vez de sair sem foto. Acrescentar a linha faz parte de
# acrescentar o prop.
# E SÃO TRÊS desde 23/09: os oito camiões do retorno levaram o catálogo de 51
# a 59 props, e a ferramenta reprovou as duas páginas até esta linha entrar.
tirar props1  - -  --script res://tools/folha_props.gd   --    "$SAIDA/props1.png" 1 3
tirar props2  - -  --script res://tools/folha_props.gd   --    "$SAIDA/props2.png" 2 3
tirar props3  - -  --script res://tools/folha_props.gd   --    "$SAIDA/props3.png" 3 3

# UMA IMAGEM CHAPADA TAMBÉM É UM PNG. Se o contexto gráfico falhar em silêncio
# — driver de software em falta no runner, por exemplo — a ferramenta salva um
# retângulo de uma cor só e diz "Tela salva", que é a foto mentirosa contra a
# qual o CLAUDE.md avisa. Medido: um PNG 720x1280 de cor única pesa 2,7 KB
# (preto) a 4,5 KB (cinza); as imagens de verdade pesam 87 KB a 517 KB.
# O corte fica em 20 KB, com quatro vezes de folga para o lado que interessa.
MINIMO=20000
for png in "$SAIDA"/*.png; do
	tam=$(wc -c < "$png")
	if [ "$tam" -lt "$MINIMO" ]; then
		echo "::error::$(basename "$png") tem só $tam bytes — a tela saiu chapada." >&2
		exit 1
	fi
	# E CADA FOTO SAI COM O LOG DELA. O `tirar()` já exigiu que o log
	# existisse na hora de o ler; esta pergunta é outra e vem no fim de
	# propósito — ela reprova quem APAGAR os logs depois de as guardas terem
	# passado, que é exatamente o que este arquivo fazia até 18/09 e o que
	# deixava quem baixa o artefato com dezasseis PNGs e nenhuma explicação.
	if [ ! -s "${png%.png}.log" ]; then
		echo "::error::$(basename "$png") ficou sem o log dela — o artefato não explica nada." >&2
		exit 1
	fi
done

# ⚠️ OS LOGS FICAM, e aqui havia um `rm -f "$SAIDA"/*.log`. Eles são a única
# coisa que explica uma captura estranha depois de a corrida acabar: o CI anexa
# esta pasta inteira como `brport-captura`, e sem eles quem baixa o artefato
# tem dezasseis PNGs e nenhuma forma de saber em que turno, em que fase e com
# que avisos cada um saiu. São ~550 bytes cada, dezasseis deles, contra um
# artefato de alguns megabytes — e as guardas do `tirar()` acima já os leram
# um a um, de modo que apagá-los era apagar a prova DEPOIS de ela passar.
# ⚠️ E NO FIM, A PERGUNTA QUE NENHUMA DAS GUARDAS ACIMA FAZ: **todo painel que
# o jogo abre tem fotografia?** Cada `tirar()` responde pelo SEU tiro — a
# imagem saiu, o erro não apareceu, a contagem e o turno batem — e nenhum
# responde pelo catálogo. Foi por aí que cinco painéis viveram sem foto
# nenhuma, e que três sessões seguidas os contaram como treze quando são quinze
# (`docs/decisoes/038`).
#
# ⚠️ E A COBERTURA É MEDIDA, não declarada: as duas ferramentas de captura
# imprimem `Paineis: res://...` com a cena de cada painel que estava na tela, e
# o portão lê os LOGS que ficaram aqui ao lado. Um tiro que prometesse o Caixa
# e fotografasse o Calendário cumpria a contagem de painéis e era apanhado
# aqui. É também a razão de os logs não se apagarem.
#
# Corre por último porque precisa dos logs de todos os tiros, e em Python
# porque aqui uma exceção sai com código ≠ 0 — o mesmo motivo do
# `conferir_escopo_ui.py` e do `conferir_guardas_ci.py`.
RAIZ_REPO=$(cd "$(dirname "$0")/.." && pwd)
python3 "$RAIZ_REPO/tools/conferir_cobertura_paineis.py" "$SAIDA"

ls -la "$SAIDA"
