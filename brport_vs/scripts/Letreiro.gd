extends Control
class_name Letreiro

## A placa que nomeia um lugar do mapa: chapa escura, contorno âmbar, mastro
## descendo até o telhado.
##
## POR QUE ISTO VIROU SCRIPT EM 05/09
## ----------------------------------
## Os três letreiros eram offsets cravados no `Main.tscn`, e os offsets
## carregavam DOIS erros que ninguém via:
##
## 1. **A placa do armazém não encostava no prédio.** O pé do mastro ficava
##    12px ACIMA do telhado, e a placa lia-se como etiqueta a pairar. Não era
##    regressão do enquadramento — medido, ela já flutuava 18px antes dele.
##    O bloco D7 conferia o pé contra o QUADRO DE 512 do prop, e um prédio
##    desenhado ocupa 103px desse quadro: sobravam duzentos pixels de folga
##    para o teste dizer "apoiado".
## 2. **A placa era mais larga do que o prédio que nomeia** — 132px de chapa
##    para 81px de texto e um escritório de 103px. Os 132 não eram um tamanho
##    necessário: eram um `offset_right` escrito à mão, com 27px a mais do que
##    o próprio conteúdo pedia.
##
## Os dois têm a mesma causa, e é a que este projeto já conhece: número em
## PIXEL escrito à mão numa cena envelhece calado quando o que ele descreve
## muda de tamanho. Agora a placa mede-se pelo texto e planta-se no prédio, e
## quem mexer na câmera outra vez não tem nada para acertar aqui.
##
## O QUE ELE PLANTA, E ONDE
## ------------------------
## O pé do mastro vai ao telhado MAIS BAIXO dos dois estados (ruína e
## consertado) e entra nele `MORDIDA` pixels; a placa fica `FOLGA` acima do
## telhado mais ALTO. É o que faz a placa não pular quando o jogador conserta o
## prédio — a razão pela qual o mastro era fixo — sem que ela flutue no estado
## em que o prédio é mais baixo, que era o preço que se estava a pagar por isso.

## Quanto o mastro entra no telhado. Sem isto ele acaba EM CIMA da aresta, e a
## um pixel de distância a placa volta a ler-se como etiqueta colada.
const MORDIDA := 5.0

## Quanto a placa se afasta do telhado mais alto. Menos do que isto e o canto
## de baixo da chapa toca a telha do estado consertado.
const FOLGA := 8.0

## O prédio que esta placa nomeia, em `MapaWrap/Cenario`. Vazio = a placa fica
## onde a cena a pôs — é o caso da ZONA DE ESPERA, que nomeia água aberta e
## não tem prop nenhum por baixo.
@export var prop: String = ""

## As duas texturas do prédio. Precisa das DUAS porque o telhado muda de
## altura entre elas, e a placa tem de servir aos dois estados.
@export var estados: Array[Texture2D] = []


## O ponto do mundo em que a placa sem prédio se centra. Guardado na primeira
## plantação porque `plantar()` é chamado outra vez pelo teste de design, e um
## `position.x += ...` chamado duas vezes anda duas vezes.
var _centro_pedido := NAN


func _ready() -> void:
	plantar()


## Mede a chapa e planta o mastro. Público, e IDEMPOTENTE, porque o bloco D7
## do teste de design o chama antes de medir: a suíte roda o jogo por fora e
## não processa frames, então sem isto ela leria os offsets que a cena trazia
## em vez do que o jogador vê. O que está sob teste é a GEOMETRIA — que o
## `_ready` a dispara prova-se na captura.
func plantar() -> void:
	var placa := get_node_or_null("Placa") as Control
	var mastro := get_node_or_null("Mastro") as Control
	if placa == null or mastro == null:
		return
	# A chapa mede-se pelo que tem dentro. É `get_combined_minimum_size()` e
	# não `reset_size()`: aquele só toma efeito no passo de layout seguinte, e
	# quem lê a placa no mesmo frame — o teste de design, a captura — vê zero.
	# Este responde na hora.
	var pedido := placa.get_combined_minimum_size()
	placa.size = pedido
	placa.position = Vector2.ZERO
	var larg := pedido.x
	var alt_placa := pedido.y
	mastro.position.x = roundf((larg - mastro.size.x) / 2.0)
	mastro.position.y = alt_placa

	if prop.is_empty() or estados.is_empty():
		# Sem prédio, só se centra a chapa no ponto que a cena escolheu — a
		# posição continua a ser dela.
		if is_nan(_centro_pedido):
			_centro_pedido = position.x + size.x / 2.0
		position.x = roundf(_centro_pedido - larg / 2.0)
		size = Vector2(larg, alt_placa + mastro.size.y)
		return

	var no := get_node_or_null("../../Cenario/%s" % prop) as TextureRect
	if no == null:
		return
	var baixo := -INF          # o telhado mais baixo: é onde o mastro planta
	var alto := INF            # o mais alto: é o que a placa tem de livrar
	var centro := 0.0
	for t in estados:
		if t == null:
			continue
		var u := t.get_image().get_used_rect()
		var topo: float = no.position.y + float(u.position.y)
		baixo = maxf(baixo, topo)
		alto = minf(alto, topo)
		centro += no.position.x + float(u.position.x) + float(u.size.x) / 2.0
	centro /= float(estados.size())

	# O mastro vai do PÉ ao fundo da placa, e mais nada. Escrevê-lo como
	# `pe - (alto - FOLGA) - alt_placa` — que foi a primeira tentativa —
	# desconta a altura da chapa duas vezes: ela já entra depois, no `size`.
	# O erro não dava erro: o mastro caía no piso de 6px e a placa pousava
	# EM CIMA do telhado do estado consertado.
	var pe := baixo + MORDIDA
	mastro.size.y = maxf(6.0, pe - (alto - FOLGA))
	size = Vector2(larg, alt_placa + mastro.size.y)
	position = Vector2(roundf(centro - larg / 2.0), roundf(pe - size.y))
