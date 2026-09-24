extends RefCounted

# ============================================================
# BR Port VS — as CARAS que uma foto mostra
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# As duas ferramentas de captura imprimem `Paineis:` e `Tempo:`, e o
# `conferir_cobertura_paineis.py` exige foto de cada painel e de cada tempo.
# Nenhuma das duas perguntas desce à CARA: a Dona Cida tem três, e a cena
# dela é uma só (o boletim) — até 24/09 a bateria mostrava a séria e nunca a
# preocupada nem a contente, com a cobertura verde. Um painel não é uma tela
# (`051`), e uma tela não é uma cara (`060`).
#
# ⚠️ A CARA LÊ-SE NA FOTO, NUNCA NA FALA. O painel pede a cara pela fala
# (`Narrativa.retrato()`), e a pedida pode não ser a que fica: a cena da
# parcela troca a cara no segundo tempo, e a contra-oferta troca-a três vezes
# na mesma tela. É a regra do `CLAUDE.md` — fala disparada não é fala vista —
# com um retrato no lugar do texto. Daqui sai o que o NÓ mostra no instante
# da foto, e só depois de provar que ele chegou aos pixels.
#
# ⚠️ E A PROVA É A DAS FOLHAS DE CONTATO (`049`): «esconder a peça muda a
# foto?». Uma cara com o nó certo e a textura certa pode não desenhar nada —
# `self_modulate` a zero, um cartão por cima, uma caixa de tamanho zero —, e
# uma guarda que perguntasse à textura passaria com ela. Aqui são TRÊS fotos:
#
#   · a foto, que é a que se grava;
#   · a mesma cena dois frames depois, SEM mexer em nada — a régua do ruído.
#     Na janela da cara ela tem de dar ZERO exato; se algo lá dentro se mexe
#     sozinho, a terceira foto mediria o movimento e não a cara, e a
#     ferramenta reprova em vez de publicar um número que não quer dizer nada;
#   · a cena com as caras escondidas — os pixels que mudam são a cara.
#
# ⚠️ E O QUE CONTA COMO CARA É O NOME DO ARQUIVO (`retrato_*`), não o registo.
# De propósito: o catálogo sai do `Retratos.gd`, e se esta ferramenta também
# lesse de lá as duas fontes seriam uma. A convenção de nome só pode falhar
# para o lado VERMELHO — uma cara registada com outro nome nunca apareceria
# aqui, e o conferidor dava-a por sem foto —, e uma cara com este nome que o
# registo não conhece é um painel a carregar retrato por fora do `Retratos.gd`,
# que o conferidor também reprova.
#
# Uso, de dentro de uma ferramenta de `--script` (carregue com `load()`):
#   var prova = load("res://tools/caras_na_foto.gd").new(painel, foto)
#   ... a cada `_process`: if prova.andar(root): (acabou) prova.falhas / prova.linhas
# ============================================================

const PREFIXO := "retrato_"

# Medido em 24/09 na bateria, as nove caras: a menor mudou 9.390 px ao ser
# escondida (a Dona Cida preocupada, na caixa de 112 x 152) e a maior 12.463
# (o Sr. Ribeiro cordial). O defeito — a cara escondida também na foto — tem
# de dar ZERO exato (ver a `060`); o corte fica a meio da banda.
const DESENHO_MIN := 4695

# Frames entre mexer e fotografar. A foto é o ÚLTIMO FRAME DESENHADO: o que se
# muda nesta volta só chega ao seguinte — o primeiro mutante da folha dos
# trabalhadores escondia os retratos na volta errada e passou (`059`). Dois,
# como o `_f8_esperar()` da suíte de fumaça.
const FRAMES := 2

var linhas: PackedStringArray = []
var falhas: PackedStringArray = []

var _caras: Array = []
var _com: Image
var _ruido: Image
var _etapa := 0
var _frames := 0


func _init(painel: Node, foto: Image) -> void:
	_com = foto
	if painel != null:
		_achar(painel)


func _achar(no: Node) -> void:
	if no is TextureRect and not no.is_queued_for_deletion() \
			and (no as TextureRect).is_visible_in_tree() \
			and (no as TextureRect).texture != null \
			and (no as TextureRect).texture.resource_path.get_file().begins_with(PREFIXO):
		_caras.append(no)
	for filho in no.get_children():
		_achar(filho)


## Uma volta do `_process` de quem chama. Devolve `true` quando acabou; aí
## `linhas` traz uma `Retratos: <arquivo>` por cara provada, e `falhas` o que
## não se provou. Sem cara nenhuma no painel acaba logo, sem linha.
func andar(janela: Viewport) -> bool:
	if _caras.is_empty():
		return true
	_frames += 1
	if _frames < FRAMES:
		return false
	_frames = 0
	if _etapa == 0:
		_ruido = janela.get_texture().get_image()
		for cara in _caras:
			(cara as CanvasItem).self_modulate.a = 0.0
		_etapa = 1
		return false
	var sem := janela.get_texture().get_image()
	for cara in _caras:
		var rect: Rect2 = (cara as Control).get_global_rect()
		var arquivo: String = (cara as TextureRect).texture.resource_path
		var ruido := PropIso.desenho_na_foto(_com, _ruido, rect)
		var desenho := PropIso.desenho_na_foto(_com, sem, rect)
		if ruido != 0:
			falhas.append("a janela de %s mexe-se sozinha (%d px sem esconder nada) — a prova mediria o movimento, e não a cara"
				% [arquivo, ruido])
		elif desenho < DESENHO_MIN:
			falhas.append("%s não chegou à foto: %d px mudam ao escondê-la (mínimo %d)"
				% [arquivo, desenho, DESENHO_MIN])
		else:
			linhas.append("Retratos: %s  (%d px)" % [arquivo, desenho])
	return true
