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
# ⚠️ A EXPRESSÃO TEM UM TAMANHO MÍNIMO, e é este. O busto foi desenhado com a
# cabeça a valer 47% da altura justamente para caber cara aqui dentro: a 96px
# a cara tem 44 e o olho tem 5, e a diferença entre uma boca reta e uma boca
# descontente é de 2 pixels — que se veem. A 64px seria 1 pixel, e as nove
# imagens seriam três. Quem encolher isto tem de reabrir a folha de contato e
# olhar, e não confiar em que "ainda dá para ver que é uma pessoa".
const TAMANHO := 96


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
# PNG de 512 sai minúsculo no cartão por mais certo que esteja o resto. Por
# isso o estúdio enche o quadro (`_K` e `_MEIO` em `brp_porto.py`) — e por
# isso o teste de fumaça mede a caixa opaca dos nove PNG em vez de confiar.
static func imagem(retrato: Texture2D, tamanho: int = TAMANHO) -> TextureRect:
	var img := TextureRect.new()
	img.texture = retrato
	img.custom_minimum_size = Vector2(tamanho, tamanho)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# O retrato não recebe toque: ele é ilustração ao lado do texto, e um alvo
	# de toque de 96px em cima de um painel de decisão rouba o clique do botão
	# que está por baixo em metade dos telefones.
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Alinhado ao TOPO do balão. Centrado, um retrato de 96px ao lado de uma
	# fala de duas linhas fica com a cara a meia altura do texto e a olhar para
	# o nada; encostado em cima, ele olha para a primeira linha.
	img.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return img
