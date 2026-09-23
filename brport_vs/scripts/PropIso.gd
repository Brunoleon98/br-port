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
##
## ⚠️ E DESDE 23/09 A TEXTURA DE UM PROP DE MAPA NÃO É O QUADRO — É O DESENHO
## (`docs/decisoes/049`). Os 60 props de `art/props` que não são retrato de fala
## importam como `texture_atlas`: o importador apara a moldura transparente e
## devolve um `AtlasTexture` cuja MARGEM repõe o quadro. O tamanho continua 768
## e o desenho cai no mesmo sítio — quem só mostra o prop não vê diferença —,
## mas o `get_image()` devolve a REGIÃO, com o canto em (0, 0). Uma régua que
## lesse o `get_used_rect()` dela apontaria 300 px ao lado; por isso quem lê
## pixel de um prop pede-o a `imagem()`, e nunca ao `get_image()` direto.

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
	var r := imagem(tex).get_used_rect()
	return Rect2(Vector2(r.position) * k - Vector2(MEIO, MEIO),
		Vector2(r.size) * k)


## A imagem do QUADRO inteiro, como o PNG em disco a desenha — o que o
## `get_image()` devolvia antes de os props entrarem em atlas.
##
## Num `AtlasTexture` a região é colada de volta no sítio que a margem guarda,
## num quadro transparente do tamanho que a textura reporta. Custa uma imagem
## de 768 por chamada, e só as réguas a pedem: o jogo desenha pela textura.
static func imagem(tex: Texture2D) -> Image:
	if tex == null:
		return null
	var img := tex.get_image()
	if not (tex is AtlasTexture) or img == null:
		return img
	var a := tex as AtlasTexture
	var quadro := Image.create_empty(tex.get_width(), tex.get_height(), false,
		img.get_format())
	quadro.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()),
		Vector2i(a.margin.position))
	return quadro


## O desenho de um prop como textura própria, sem a moldura — para quem quer
## MOSTRAR só a peça, ampliada (as folhas de contato).
##
## ⚠️ UM `AtlasTexture` POR CIMA DE OUTRO NÃO COMPÕE, e não dá erro. As duas
## folhas faziam `atlas = <textura do prop>` com a região do `get_used_rect()`;
## com o prop já em atlas, o `get_image()` do conjunto devolvia o desenho
## inteiro e o `draw` desenhava a MARGEM vazia — medido em 23/09, a folha da
## frota saiu com todos os quadros em branco e imprimiu "Folha salva em". Por
## isso o recorte aponta para o atlas de BAIXO, cuja região já é o desenho.
static func recorte(tex: Texture2D) -> AtlasTexture:
	var r := AtlasTexture.new()
	if tex is AtlasTexture:
		r.atlas = (tex as AtlasTexture).atlas
		r.region = (tex as AtlasTexture).region
	else:
		r.atlas = tex
		r.region = Rect2(imagem(tex).get_used_rect())
	return r


## Quantos pixels de `rect` mudam entre a foto COM a peça e a foto SEM ela.
##
## É a prova de que a peça chegou à foto, e responde pelo DESENHO e não pela
## textura: o recorte da armadilha acima tinha `get_image()` cheio e desenhava
## vazio, e uma guarda que perguntasse à textura passaria com ele posto. Não
## compara com a cor do chão, porque o chão pode ser listrado e o filtro mistura
## as listras; compara a foto consigo mesma, o que dá zero exato onde nada se
## desenhou.
static func desenho_na_foto(com: Image, sem: Image, rect: Rect2) -> int:
	var r := Rect2i(rect).intersection(Rect2i(Vector2i.ZERO, com.get_size()))
	var n := 0
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var a := com.get_pixel(x, y)
			var b := sem.get_pixel(x, y)
			if maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), absf(a.b - b.b)) > 2.0 / 255.0:
				n += 1
	return n
