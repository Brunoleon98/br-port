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
tirar() {
	local nome="$1"; local paineis="$2"; local turno="$3"; shift 3
	local log="$SAIDA/$nome.log"
	xvfb-run -a "$GODOT" "${comum[@]}" "$@" > "$log" 2>&1 || {
		echo "::error::a captura '$nome' falhou:"; cat "$log"; return 1
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
	# O que as separa é a origem, e ela vem escrita na linha `at:`: só quem
	# chamou `push_error` traz `at: push_error (`. Fica de fora, de propósito,
	# todo `ERROR:` do motor sem rasto de GDScript.
	if grep -qE "SCRIPT ERROR|at: push_error \(" "$log"; then
		echo "::error::a captura '$nome' imprimiu erro — a foto não vale o que promete:" >&2
		grep -nE "SCRIPT ERROR|at: push_error \(" -A 4 "$log" >&2
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
tirar ribeiro - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/DebtPaymentPanel.tscn "$SAIDA/ribeiro.png" @PARCELA_AMOUNT
tirar contraoferta - -  --script res://tools/capturar_cena.gd -- res://scenes/panels/CounterOfferPanel.tscn "$SAIDA/contraoferta.png" barco=0 0
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
tirar icones  - -  --script res://tools/folha_icones.gd  --    "$SAIDA/icones.png"
# A FROTA, e ela entrou por uma falha MEDIDA das fotos acima. Em 07/09 os
# cascos passaram a ser seis — um por par de classe e motivo — e os camiões
# oito; as cinco fotos de jogo mostraram DOIS cascos e um camião, porque quem
# escolhe o que atraca é o sorteio da partida. Quatro cascos e sete camiões
# ficavam gerados, validados por duas suítes, e sem ninguém os poder olhar —
# que é o buraco do `barco_medio` outra vez. Uma folha que percorre a tabela
# não depende de sorteio, como a dos ícones já não dependia.
tirar frota   - -  --script res://tools/folha_frota.gd   --    "$SAIDA/frota.png"

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
tirar props1  - -  --script res://tools/folha_props.gd   --    "$SAIDA/props1.png" 1 2
tirar props2  - -  --script res://tools/folha_props.gd   --    "$SAIDA/props2.png" 2 2

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
ls -la "$SAIDA"
