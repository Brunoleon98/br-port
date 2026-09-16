class_name PropIso
## O quadro de um prop isométrico — e a ÚNICA conta que traduz pixel de PNG em
## coordenada de nó.
##
## Até 16/09 não havia conta nenhuma a fazer: o PNG tinha 512 px e o nó tinha
## 512 de lado, então quem media no arquivo e quem media na cena chegavam ao
## mesmo número sem nunca ter de dizer qual dos dois estava a medir. A alavanca
## B pôs os props a 768 px dentro do mesmo quadro de 512 coordenadas
## (`docs/decisoes/029`), e os dois números separaram-se.
##
## ⚠️ E É EXATAMENTE A ARMADILHA QUE ESTE PROJETO JÁ REGISTOU: "dois números
## iguais medidos de sítios diferentes não são a mesma guarda". O `MEIO_QUADRO`
## do teste de design era 256 nos dois sentidos, e um deles passou a ser 384.
##
## Quem mostra o prop num `TextureRect` não precisa disto — `expand_mode = 1`
## já desfaz a diferença, como nos três nós de mapa. Quem precisa é o
## `Sprite2D` (a fauna), que desenha a textura ao tamanho nativo, e toda régua
## que leia `get_used_rect()` e queira responder em pixel de TELA.

## O lado do quadro em COORDENADAS. É o `RESOLUCAO_TELA` de
## `tools/gerar_props_iso.py`, e o que as âncoras e os `.tscn` publicam.
const QUADRO := 512.0

## Metade dele: o centro do quadro é a origem do mundo.
const MEIO := QUADRO / 2.0


## Quanto vale um pixel desta textura em coordenada de nó.
##
## Sai da TEXTURA e não de uma constante de propósito: um prop regerado noutra
## resolução acerta-se sozinho, e um prop que tenha ficado por regerar continua
## a ler certo em vez de sair 1,5x fora do sítio.
static func escala(tex: Texture2D) -> float:
	if tex == null or tex.get_width() <= 0:
		return 1.0
	return QUADRO / float(tex.get_width())


## O desenho de um prop — o `get_used_rect()` — em coordenadas de nó,
## relativo à ÂNCORA (o centro do quadro), que é onde o mapa o pousa.
static func desenho(tex: Texture2D) -> Rect2:
	if tex == null:
		return Rect2()
	var k := escala(tex)
	var r := tex.get_image().get_used_rect()
	return Rect2(Vector2(r.position) * k - Vector2(MEIO, MEIO),
		Vector2(r.size) * k)
