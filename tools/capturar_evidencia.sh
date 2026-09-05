#!/usr/bin/env bash
# ============================================================
# BR Port — as quatro fotografias que provam o que ficou
#
# Item B3 do plano v3: "o CI prova que nada quebrou; não mostra o que ficou".
# Este script produz a evidência visual — a tela do jogo em três estados e a
# folha de contato dos ícones — para o CI a anexar a cada PR e para quem
# trabalha aqui poder gerar exatamente as mesmas quatro imagens.
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

# `xvfb-run -a` porque a captura precisa de contexto gráfico: teste e import
# rodam sem tela, esta não.
# tirar <nome> <painéis esperados, ou "-"> <argumentos do Godot...>
tirar() {
	local nome="$1"; local paineis="$2"; shift 2
	xvfb-run -a "$GODOT" "${comum[@]}" "$@" > "$SAIDA/$nome.log" 2>&1 || {
		echo "::error::a captura '$nome' falhou:"; cat "$SAIDA/$nome.log"; return 1
	}
	# A LINHA DE SUCESSO, NÃO O CÓDIGO DE SAÍDA. É a regra que o CLAUDE.md já
	# cobra da suíte, e vale igual aqui: um erro de compilação do GDScript sai
	# com 0 sem a ferramenta ter feito nada.
	grep -qE "(Tela|Folha) salva em" "$SAIDA/$nome.log" || {
		echo "::error::a captura '$nome' não escreveu imagem nenhuma:"
		cat "$SAIDA/$nome.log"; return 1
	}
	if [ "$paineis" != "-" ]; then
		local visto
		visto=$(sed -n 's/^Overlay: \([0-9]*\) .*/\1/p' "$SAIDA/$nome.log")
		if [ "$visto" != "$paineis" ]; then
			echo "::error::'$nome' esperava $paineis painel(eis) por cima e viu ${visto:-nenhuma leitura}." >&2
			return 1
		fi
	fi
}

# Onze turnos já abrem o Boletim e ele não fecha sozinho — por isso o mapa é
# fotografado a DEZ, que é o fim da semana 1 com o porto todo de pé.
tirar inicio  0 --script res://tools/capturar_tela.gd -- 0  "$SAIDA/inicio.png"
tirar porto   0 --script res://tools/capturar_tela.gd -- 10 "$SAIDA/porto.png" completo
# O NÍVEL DO MEIO. O píer, a lança e os prédios têm três níveis desde 05/09, e
# `inicio` e `porto` só mostram os dois extremos — o do meio não tinha como ser
# olhado, e o gate A5 é olhar. `meio` compra as duas primeiras estruturas, que é
# o que `GameState.nivel_porto()` lê como n2.
tirar meio    0 --script res://tools/capturar_tela.gd -- 10 "$SAIDA/meio.png" meio
tirar boletim 1 --script res://tools/capturar_tela.gd -- 12 "$SAIDA/boletim.png" completo
tirar pausa   1 --script res://tools/capturar_tela.gd -- 8  "$SAIDA/pausa.png" completo pausa
tirar icones  - --script res://tools/folha_icones.gd  --    "$SAIDA/icones.png"

# UMA IMAGEM CHAPADA TAMBÉM É UM PNG. Se o contexto gráfico falhar em silêncio
# — driver de software em falta no runner, por exemplo — a ferramenta salva um
# retângulo de uma cor só e diz "Tela salva", que é a foto mentirosa contra a
# qual o CLAUDE.md avisa. Medido: um PNG 720x1280 de cor única pesa 2,7 KB
# (preto) a 4,5 KB (cinza); as quatro imagens de verdade pesam 87 KB a 517 KB.
# O corte fica em 20 KB, com quatro vezes de folga para o lado que interessa.
MINIMO=20000
for png in "$SAIDA"/*.png; do
	tam=$(wc -c < "$png")
	if [ "$tam" -lt "$MINIMO" ]; then
		echo "::error::$(basename "$png") tem só $tam bytes — a tela saiu chapada." >&2
		exit 1
	fi
done

rm -f "$SAIDA"/*.log
ls -la "$SAIDA"
