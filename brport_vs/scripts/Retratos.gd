class_name Retratos
extends RefCounted

# ============================================================
# BR Port VS — registro dos retratos de fala
#
# O que o `Icones.gd` é para o ícone, este arquivo é para a cara: o único
# lugar que sabe qual PNG é qual personagem com qual expressão. A alternativa
# — cada painel a escrever o caminho do arquivo — é o que aconteceu com os
# emojis, e trocar um custava caçar string por string em sete scripts.
#
# A DIVISÃO DE TRABALHO COM A `Narrativa.gd` É A MESMA DO TEXTO E DO ÍCONE:
# lá vive QUE expressão cada fala pede; aqui vive QUE ARQUIVO é cada
# expressão. Duas perguntas diferentes, e por isso duas tabelas — o bloco F6
# do teste de fumaça cruza-as, e cruza as duas com o DISCO, que é a terceira
# fonte e a única que não é opinião de nenhuma delas.
#
# OS PNG SAEM DO ESTÚDIO PARTILHADO (`blender/brp_porto.py`, `retratos_de_fala`)
# e não de gerador de imagem. A regra do `CLAUDE.md` permite gerador em painel
# e proíbe-o no mapa; aqui não se usa mesmo assim, porque estes três têm de
# pertencer à mesma oficina do trabalhador do rodapé — e um gerador não erra o
# desenho, erra o ÂNGULO.
# ============================================================

const CIDA_SERIA := preload("res://art/props/retrato_cida_seria.png")
const CIDA_PREOCUPADA := preload("res://art/props/retrato_cida_preocupada.png")
const CIDA_CONTENTE := preload("res://art/props/retrato_cida_contente.png")

const ARLINDO_SORRISO := preload("res://art/props/retrato_arlindo_sorriso.png")
const ARLINDO_PRESSAO := preload("res://art/props/retrato_arlindo_pressao.png")
const ARLINDO_CONTRARIADO := preload("res://art/props/retrato_arlindo_contrariado.png")

const RIBEIRO_CORDIAL := preload("res://art/props/retrato_ribeiro_cordial.png")
const RIBEIRO_FORMAL := preload("res://art/props/retrato_ribeiro_formal.png")
const RIBEIRO_GRAVE := preload("res://art/props/retrato_ribeiro_grave.png")

const POR_EXPRESSAO := {
	"cida": {
		"seria": CIDA_SERIA,
		"preocupada": CIDA_PREOCUPADA,
		"contente": CIDA_CONTENTE,
	},
	"arlindo": {
		"sorriso": ARLINDO_SORRISO,
		"pressao": ARLINDO_PRESSAO,
		"contrariado": ARLINDO_CONTRARIADO,
	},
	"ribeiro": {
		"cordial": RIBEIRO_CORDIAL,
		"formal": RIBEIRO_FORMAL,
		"grave": RIBEIRO_GRAVE,
	},
}

# O tamanho a que o cartão mostra o retrato, e ele NÃO é escolha de gosto.
#
# ⚠️ A EXPRESSÃO TEM UM TAMANHO MÍNIMO. O busto foi desenhado com a cabeça a
# valer 59% da altura justamente para caber cara aqui dentro: a este tamanho a
# cara tem ~50px e o olho tem 6, e a diferença entre uma boca reta e uma boca
# descontente é de 2 pixels — que se veem. Metade disto seria um pixel, e as
# nove imagens seriam três. Quem encolher isto tem de reabrir a folha de
# contato e olhar, e não confiar em que "ainda dá para ver que é uma pessoa".
#
# ⚠️ E A CAIXA NÃO É QUADRADA, porque o PNG é. Um busto é mais alto do que
# largo — 62% da largura do quadro por 90% da altura, o que era 338 x 460 num
# quadro de 512 e é 507 x 690 num de 768 (`029`) —, e num `TextureRect` quadrado
# com `KEEP_ASPECT_CENTERED` quem manda é o QUADRO: a imagem inteira encolhe
# para caber, o busto sai com 86px de altura e sobram 33px de transparência de
# cada lado, dentro do cartão, a pagar largura que o balão queria. Com a caixa
# na proporção do BUSTO e o modo `COVERED` (mais o `clip_contents`), a margem
# transparente é que fica de fora e o mesmo desenho aparece 29% maior sem
# roubar um pixel ao texto.
const LARGURA := 112
const TAMANHO := 152


# A textura de um personagem numa expressão. Devolve `null` para um par
# desconhecido em vez de rebentar — um retrato que falta é um balão sem cara,
# não um crash —, e o bloco F6 do fumaça é que garante que não falta nenhum.
static func de(personagem: String, expressao: String) -> Texture2D:
	var caras: Dictionary = POR_EXPRESSAO.get(personagem, {})
	return caras.get(expressao, null)


# Um TextureRect pronto para sentar ao lado de um balão de fala.
#
# ⚠️ `KEEP_ASPECT_CENTERED` ESCALA O QUADRO INTEIRO, transparência incluída, e
# é a armadilha que o retrato do trabalhador já pagou: um busto pequeno num
# PNG de 512 saía minúsculo no cartão por mais certo que estivesse o resto — e
# a alavanca B não muda isto num pixel, porque o que decide é a FRAÇÃO do
# quadro que o busto ocupa, e ela é a mesma a 512 e a 768. Por
# isso o estúdio enche o quadro (`_K` e `_MEIO` em `brp_porto.py`) — e por
# isso o teste de fumaça mede a caixa opaca dos nove PNG em vez de confiar.
static func imagem(retrato: Texture2D, altura: int = TAMANHO) -> TextureRect:
	var img := TextureRect.new()
	img.texture = retrato
	img.custom_minimum_size = Vector2(int(round(altura * float(LARGURA) / TAMANHO)), altura)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	# Sem isto o `COVERED` desenha para FORA da caixa e o busto passa por cima
	# do balão de fala — o modo cobre a área e não corta nada sozinho.
	img.clip_contents = true
	# O retrato não recebe toque: ele é ilustração ao lado do texto, e um alvo
	# de toque de 92 x 124 em cima de um painel de decisão rouba o clique do botão
	# que está por baixo em metade dos telefones.
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Alinhado ao TOPO do balão. Centrado, um retrato deste tamanho ao lado de uma
	# fala de duas linhas fica com a cara a meia altura do texto e a olhar para
	# o nada; encostado em cima, ele olha para a primeira linha.
	img.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return img
