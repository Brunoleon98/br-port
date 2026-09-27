extends SceneTree

# ============================================================
# BR Port VS — folha de contato dos PROPS DE MAPA
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Desenha todo prop do catálogo a 1:1, no tamanho em que ele chega ao mapa,
# SOBRE O CHÃO QUE O MAPA PINTA DEBAIXO DELE, com o nome do arquivo por baixo.
# É a segunda metade da medição do gate A5 do plano v3 — "captura antes/depois
# lado a lado, E a folha de contato dos props" —, e a primeira metade (a
# trilha) ficou pronta em 14/09.
#
# ⚠️ ELA EXISTE PELA REGRA QUE JÁ PAGOU QUATRO VEZES: prop que a captura não vê
# é prop que ninguém revê. O `barco_medio` era renderizado, validado e nunca
# posto em doca nenhuma; o `doca_concreto` só é referido por um teste que não
# se exporta; e a pasta `art/brp` inteira — oito assets — é validada a cada
# corrida do CI e não aparece em imagem nenhuma. A `folha_icones` e a
# `folha_frota` já tapavam a sua parte do buraco; isto tapa o resto.
#
# ⚠️ O CHÃO É AMOSTRADO DO MAPA, e essa é a pergunta que a folha passou a
# responder em 16/09. Até aqui ela desenhava tudo sobre um fundo só — o asfalto
# do pátio — e isso estava escrito como limitação assumida: contraste depende do
# FUNDO, e um casco julgado sobre asfalto não diz nada sobre um casco na água.
# A folha respondia "dá para olhar?" e não "separa do fundo?".
#
# ⚠️ E SÃO DUAS FONTES, NUNCA UM ESPELHO. A ÂNCORA de cada prop sai da CENA —
# o `offset` do nó que o desenha, que é onde o jogo o põe — e a COR sai do
# RASTER DO MAPA, que sai do gerador. É a mesma porta por onde o D20 pergunta
# se a pista é pista e o D21 onde o barco fundeia: quem diz o sítio e quem diz
# a cor são arquivos diferentes, escritos por mãos diferentes. Uma tabela de
# posições escrita aqui seria o espelho de que o `CLAUDE.md` avisa.
#
# ⚠️ E A ÂNCORA É RELATIVA AO `MapaWrap`, NÃO À TELA. O `MapaWrap` tem
# `offset_top = 62` e o mapa começa lá; somar esse deslocamento põe toda
# amostra 62 px abaixo do prop — que é a armadilha escrita no `CLAUDE.md`
# ("três recortes já foram ao lugar errado por causa disto"), e ela mordeu
# nesta ferramenta na primeira medição. A conta anda do `MapaWrap` para baixo.
#
# ⚠️ E NÃO SE CONFERE AQUI QUE A CENA CONCORDA COM A TABELA DE ÂNCORAS. Já há
# quem o faça, e uma regra que viva em dois sítios nunca reprova num defeito
# injetado: o bloco **D1** do teste de design exige que Píer, Lança e Barco de
# cada uma das três docas caiam em cima do que o `porto_mapa_ancoras.json`
# publica. Esta folha herda esse acordo em vez de o repetir.
#
# ⚠️ E O QUE NÃO TEM ÂNCORA É DECLARADO COMO TAL, senão a folha mente sobre o
# que mediu. Sobra UM prop — ver `SEM_ANCORA` em `catalogo_props.gd` —, e
# ele sai sobre um chão de recurso LISTRADO, que nenhuma amostra do mapa pode
# imitar. A conta é dos dois
# lados: prop sem âncora que não esteja declarado REPROVA, e prop declarado que
# afinal tenha âncora REPROVA também, para a lista não envelhecer calada.
#
# ⚠️ E O QUE SE AMOSTRA É O MAPA, que não é sempre o que o prop pisa. Quem
# pousa em cima de OUTRO prop — o trabalhador e as três lanças, no tabuado do
# píer — sai aqui sobre a ÁGUA DO BERÇO, que é o que o mapa pinta por baixo dos
# dois. É limitação assumida e escrita, como o fundo único era até 16/09: o
# convés do píer não está no mapa, está num PNG, e derivá-lo pediria amostrar
# um prop através de outro. Quem quiser essa pergunta tem a captura de jogo, que
# é onde o píer e o trabalhador aparecem um em cima do outro.
#
# ⚠️ E NÃO SE AGRUPA POR `habitat`. Está medido e não dá (`docs/decisoes/026`,
# §A5 do plano): o campo existe nas 44 entradas do manifest, mas só 26 dos 51
# props de mapa lá estão e 20 desses 26 são `terra`. Ele foi desenhado para a
# FAUNA, onde cada bicho tem o seu. Cobertura não é distribuição.
#
# ⚠️ E A ARTE DE INTERFACE FICA DE FORA, por medição e não por gosto. Os nove
# retratos de fala medem 338x450 e o do trabalhador 138x307, contra os 153x140
# do maior prop de mapa: pô-los aqui faria toda célula ter 479px de altura e a
# folha caberia oito peças. E não se julgam aqui de todo — "peça de INTERFACE
# mede-se no tamanho do widget, não no do quadro", e o widget deles é o cartão
# do painel, onde a captura de jogo já os mostra.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/folha_props.gd \
#     -- <saida.png> <pagina> <total_de_paginas>
# ============================================================

const SAIDA_PADRAO := "user://folha_props.png"
const FRAMES_ATE_ASSENTAR := 8
const PASTA := "res://art/props"

# O catálogo, a régua do mapa, a cena, as famílias e o chão de cada prop vivem
# em `catalogo_props.gd` desde 27/09, que a prancha e a página de escala também
# os perguntam. O que fica aqui é a FOLHA: o layout e as guardas dela.

const FUNDO_FOLHA := Color(0.09, 0.16, 0.24)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)
const TINTA_RECURSO := Color(0.95, 0.75, 0.30)

# ⚠️ "1:1" É O TAMANHO DO JOGO, E ISSO DEIXOU DE SER O PIXEL DO ARQUIVO. Desde
# a alavanca B um prop tem 768 px de textura para 512 de coordenada
# (`docs/decisoes/029`): desenhar o `get_used_rect()` cru poria esta folha a
# 1,5x do jogo — o píer a 210 px em vez de 140 —, as células cresceriam na
# mesma proporção e a conta das páginas reprovaria, a dizer que é preciso uma
# terceira. Nenhuma das duas coisas é sobre o catálogo. O fator sai de cada
# textura, pelo `PropIso`, e é por isso que já não há um ZOOM constante aqui.
const ZOOM := 1                                    # 1:1 — o tamanho do jogo
const MARGEM := 10
# ⚠️ E CADA PEÇA TEM DE CHEGAR À FOTO, que a folha não perguntava. Em 23/09,
# com os props em atlas (`docs/decisoes/049`), um recorte mal montado desenhou
# TODOS os quadros vazios e a folha imprimiu "Folha salva em" na mesma. Hoje ela
# fotografa duas vezes — com a arte e sem ela — e conta, por peça, os pixels
# que mudam (`PropIso.desenho_na_foto`). O defeito dá ZERO exato; o corte fica
# a meio da banda medida, e quem acrescentar uma peça menor do que metade da
# menor de hoje desce-o de propósito.
# Medido: a menor é o `poste_luz`, com 38 px a 1:1 (folga 2x).
const DESENHO_MIN := 19
const RODAPE := 32                                 # as duas linhas de nome
const CABECALHO := 46                              # o título e a legenda
const FONTE_NOME := 11
const FONTE_CHAO := 10

var _cat: RefCounted
var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _pagina := 1
var _total := 1
var _pecas := 0
var _foto: Image = null
var _artes: Array = []


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		if not _montar():
			return true
		return false
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false

	# A foto que se grava é a primeira; a segunda, sem a arte, só serve para
	# provar que cada peça chegou à primeira (`PropIso.desenho_na_foto`).
	if _foto == null:
		_foto = root.get_texture().get_image()
		for par in _artes:
			(par[0] as CanvasItem).hide()
		_frames = 0
		return false
	var ausentes := _pecas_ausentes(_foto, root.get_texture().get_image())
	var img := _foto
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	if ausentes > 0:
		print("FALHOU: %d peça(s) sem desenho na foto — ver acima" % ausentes)
		quit(1)
		return true
	print("Folha salva em %s (%dx%d) — %d peças (página %d de %d)" % [
		_saida, img.get_width(), img.get_height(), _pecas, _pagina, _total])
	quit(0)
	return true


## Conta as peças que NÃO chegaram à foto, e diz a menor que chegou. É a mesma
## função da `folha_frota`: cada folha responde pelas SUAS peças.
func _pecas_ausentes(com: Image, sem: Image) -> int:
	var ausentes := 0
	var menor := -1
	var menor_nome := ""
	for par in _artes:
		var arte := par[0] as TextureRect
		var n := PropIso.desenho_na_foto(com, sem, Rect2(arte.position, arte.size))
		if n < DESENHO_MIN:
			print("FALHOU  %s não chegou à foto: %d px mudam ao escondê-la"
				% [par[1], n])
			ausentes += 1
		if menor < 0 or n < menor:
			menor = n
			menor_nome = par[1]
	print("Menor peça na foto: %d px (%s)" % [menor, menor_nome])
	return ausentes


func _montar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]
	if args.size() >= 3:
		_pagina = int(args[1])
		_total = int(args[2])

	_cat = load("res://tools/catalogo_props.gd").new(root.get_node("GameState"))
	var nomes: Array = _cat.catalogo()
	if nomes.is_empty():
		print("FALHOU — não há prop nenhum em %s" % PASTA)
		quit(1)
		return false

	for caminho in [_cat.MAPA_TERRA, _cat.MAPA_PATIO]:
		if _cat.mapa(caminho).is_empty():
			print("FALHOU — %s não rasteriza num múltiplo coerente dos %d px "
				% [caminho.get_file(), int(_cat.LADO_DO_MAPA)]
				+ "que a tabela de âncoras publica. Rode o --import.")
			quit(1)
			return false

	var r := {"ancoras": {}, "vistas": []}
	_cat.da_cena("res://scenes/Main.tscn", Vector2.ZERO, "./MapaWrap", r)

	# ⚠️ TODA FAMÍLIA APONTA PARA UM NÓ QUE EXISTE, E O QUE A CENA PÕE LÁ
	# PERTENCE À FAMÍLIA. Sem a primeira metade, um nó renomeado faria 23 props
	# caírem calados no chão de recurso — a folha a dizer "sem âncora" sobre
	# props que têm uma. Sem a segunda, uma família podia estar presa ao slot
	# errado e ninguém saberia.
	var familias: Dictionary = _cat.familias(r["ancoras"])
	var na_cena := {}
	for v in r["vistas"]:
		na_cena[String(v[1])] = String(v[0])
	for caminho in familias:
		if not r["ancoras"].has(caminho):
			print("FALHOU — a família de '%s' aponta para um nó que a cena não tem."
				% caminho)
			quit(1)
			return false
		if not na_cena.has(caminho):
			continue
		var posta: String = na_cena[caminho]
		var tem := false
		for t in familias[caminho]:
			if (t as Texture2D).resource_path.get_file() == posta:
				tem = true
		if not tem:
			print("FALHOU — a cena põe '%s' em '%s' e a família desse nó não o "
				% [posta, caminho] + "conhece. Ou o nó mudou de dono, ou a "
				+ "tabela do jogo deixou de o listar.")
			quit(1)
			return false

	var chaos: Dictionary = _cat.chaos(nomes, r)

	# ⚠️ A CONTA DOS SEM-ÂNCORA É DOS DOIS LADOS. Um prop novo que não caia em
	# sítio nenhum do mapa tem de aparecer aqui em vez de ganhar um chão
	# inventado; e um prop declarado que já tenha âncora tem de sair da lista,
	# senão ela envelhece calada — que é o defeito que este projeto apanha uma
	# vez por semana.
	var orfaos: Array = []
	for n in nomes:
		if not chaos.has(n) or (chaos[n] as Array).is_empty():
			orfaos.append(n)
	for n in orfaos:
		if not _cat.SEM_ANCORA.has(n):
			print("FALHOU — '%s' não cai em sítio nenhum do mapa e não está " % n
				+ "declarado em SEM_ANCORA (catalogo_props.gd). Ou o prop entra na cena, ou entra "
				+ "naquela lista com a razão ao lado — um chão inventado "
				+ "faria esta folha mentir sobre o que mediu.")
			quit(1)
			return false
	for n in _cat.SEM_ANCORA:
		if not orfaos.has(n):
			print("FALHOU — '%s' está declarado em SEM_ANCORA (catalogo_props.gd) e a cena já lhe " % n
				+ "dá âncora. Tire-o da lista: ela existe para ser exceção.")
			quit(1)
			return false

	# A CÉLULA SAI DO MAIOR PROP DO CATÁLOGO INTEIRO, e não do maior desta
	# página: duas páginas com células de tamanhos diferentes não se comparam,
	# e comparar tamanhos é metade do que esta folha entrega — a 1:1, ver que
	# um cone tem 30px ao lado de um píer de 140 é informação.
	var texturas := {}
	var recortes := {}
	var tamanhos := {}
	var maior := Vector2.ZERO
	for n in nomes:
		var tex: Texture2D = load("%s/%s" % [PASTA, n])
		texturas[n] = tex
		var rc := PropIso.imagem(tex).get_used_rect()
		recortes[n] = rc
		# O recorte é em pixel da textura (é ele que o `AtlasTexture` corta); o
		# TAMANHO em que ele se desenha é em coordenada, que é o do jogo.
		var tam := Vector2(rc.size) * PropIso.escala(tex) * float(ZOOM)
		tamanhos[n] = tam
		maior.x = maxf(maior.x, tam.x)
		maior.y = maxf(maior.y, tam.y)

	# ⚠️ E O RÓTULO TAMBÉM NÃO PODE SER CORTADO. `Label` que não cabe corta sem
	# dar erro (é o D18 do teste de design, noutra roupa), e um prop sem nome
	# legível nesta folha é um prop que ninguém sabe ir procurar. Mede-se o
	# PIOR do catálogo, não o que calha — e desde 16/09 são DUAS linhas: a
	# segunda diz de que cor é o chão, e ela cresce quando um prop pisa dois.
	# O pior caso sai do que a folha ESCREVE, nunca de um texto suposto.
	#
	# ⚠️ E ESTÁ MEDIDO O QUE CADA LINHA DEFENDE, que não é o mesmo. Quem estava
	# apertado era a PRIMEIRA: `caminhao_armazenagem_mx` pedia 155 px num
	# orçamento de 159, e o `_retorno_mx` (200 px) reprovou — é por isso que a
	# célula passou a sair também do rótulo (ver abaixo). A segunda tem folga — dois chãos pedem 83 px e três pedem 126,
	# e ela só transborda ao QUARTO (170 px, medido com a mesma chamada que a
	# guarda faz). Nenhum prop do catálogo de hoje pisa quatro chãos, então um
	# defeito que baixe o `CORTE_CHAO` a zero não chega a esta guarda — está
	# medido, e escreve-se em vez de se apertar o teto até ele apanhar o
	# defeito seguinte. Desde que a célula cresce com o rótulo, uma fonte maior
	# já não reprova AQUI: medido, a 16 px a célula alarga para duas colunas e
	# quem reprova é a conta das páginas (59 props pedem 5, pediram-se 3).
	var fonte := ThemeDB.fallback_font
	var pior := 0.0
	var pior_texto := ""
	for n in nomes:
		for par in [[n.get_basename(), FONTE_NOME], [_linha_do_chao(n, chaos), FONTE_CHAO]]:
			var w := fonte.get_string_size(String(par[0]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, int(par[1])).x
			if w > pior:
				pior = w
				pior_texto = String(par[0])
	# ⚠️ E A CÉLULA SAI TAMBÉM DO RÓTULO, desde 23/09. Até ali ela saía só do
	# maior DESENHO e o rótulo era conferido depois contra ela — com 4 px de
	# folga, avisava o comentário acima. Os camiões do retorno trouxeram
	# `caminhao_armazenagem_retorno_mx`, que pede 200 px numa célula de 159, e
	# a guarda reprovou como devia. O remédio não é encurtar o nome do arquivo,
	# que é o que o rótulo existe para mostrar: é a célula caber o que ela
	# carrega, desenho E nome. A guarda que sobra é a da PÁGINA.
	var larg_pagina := float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	if pior + 4.0 + 2.0 * MARGEM > larg_pagina:
		print("FALHOU — o rótulo '%s' pede %.0f px e a página dá %.0f."
			% [pior_texto, pior, larg_pagina - 2.0 * MARGEM - 4.0])
		quit(1)
		return false

	var larg := float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var alt := float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var celula := Vector2(maxf(maior.x, pior + 4.0) + MARGEM, maior.y + RODAPE)
	var colunas: int = maxi(1, int((larg - MARGEM) / celula.x))
	var linhas: int = maxi(1, int((alt - CABECALHO - MARGEM) / celula.y))
	var por_pagina := colunas * linhas

	# ⚠️ FOLHA QUE TRANSBORDA CORTA EM SILÊNCIO, e é a regra que a `folha_frota`
	# já carrega — aqui com uma cara a mais, porque esta folha tem PÁGINAS. Um
	# prop novo que empurre o catálogo para uma página a mais não pode sair
	# recortado nem sair sem foto: quem chama diz quantas páginas espera, e a
	# conta reprova se o catálogo já não couber nelas. Acrescentar a chamada da
	# página nova no `capturar_evidencia.sh` faz parte de acrescentar o prop.
	var precisa: int = int(ceil(float(nomes.size()) / float(por_pagina)))
	if precisa != _total:
		print("FALHOU — o catálogo tem %d props e cabem %d por página (%d x %d), "
			% [nomes.size(), por_pagina, colunas, linhas]
			+ "logo precisa de %d páginas e pediram-se %d. " % [precisa, _total]
			+ "Acrescente ou tire uma chamada no capturar_evidencia.sh.")
		quit(1)
		return false
	if _pagina < 1 or _pagina > _total:
		print("FALHOU — pediu-se a página %d de %d." % [_pagina, _total])
		quit(1)
		return false


	var fundo := ColorRect.new()
	fundo.color = FUNDO_FOLHA
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	root.add_child(fundo)

	var titulo := Label.new()
	titulo.text = "PROPS DE MAPA a 1:1 — página %d de %d, %d de %d no catálogo" \
		% [_pagina, _total, mini(por_pagina, nomes.size() - (_pagina - 1) * por_pagina),
		   nomes.size()]
	titulo.position = Vector2(MARGEM, 4)
	titulo.add_theme_color_override("font_color", TINTA)
	titulo.add_theme_font_size_override("font_size", 15)
	root.add_child(titulo)

	var legenda := Label.new()
	legenda.text = "o chão é a cor que o mapa pinta debaixo da âncora do prop · " \
		+ "duas faixas = dois chãos · listrado = sem âncora, chão de recurso"
	legenda.position = Vector2(MARGEM, 25)
	legenda.add_theme_color_override("font_color", TINTA_FRACA)
	legenda.add_theme_font_size_override("font_size", 11)
	root.add_child(legenda)

	var listrado: ImageTexture = _cat.listrado()
	var inicio := (_pagina - 1) * por_pagina
	var fim: int = mini(inicio + por_pagina, nomes.size())
	for i in range(inicio, fim):
		var n: String = nomes[i]
		var k := i - inicio
		var rc: Rect2i = recortes[n]
		var canto := Vector2(MARGEM + (k % colunas) * celula.x,
			CABECALHO + float(k / colunas) * celula.y)
		var piso_tam := Vector2(celula.x - 6, celula.y - RODAPE)
		var tons: Array = chaos.get(n, [])

		if tons.is_empty():
			var listras := TextureRect.new()
			listras.texture = listrado
			listras.stretch_mode = TextureRect.STRETCH_TILE
			listras.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			listras.position = canto
			listras.size = piso_tam
			root.add_child(listras)
		else:
			# UMA FAIXA POR CHÃO, lado a lado, com o prop em cima da emenda.
			for t in range(tons.size()):
				var faixa := ColorRect.new()
				faixa.color = tons[t]
				faixa.position = canto + Vector2(
					piso_tam.x * float(t) / float(tons.size()), 0.0)
				faixa.size = Vector2(piso_tam.x / float(tons.size()), piso_tam.y)
				root.add_child(faixa)

		var arte := TextureRect.new()
		arte.texture = PropIso.recorte(texturas[n])
		# ⚠️ O FILTRO ERA `NEAREST`, E ISSO SÓ ERA VERDADE A 1:1 DE PIXEL. Com a
		# textura a 768 dentro de uma célula de coordenada, `NEAREST` deitaria
		# fora um pixel em cada três e a folha mostraria uma aliasagem que o
		# jogo não tem — o jogo desenha com o filtro padrão do projeto. A folha
		# promete "o tamanho do jogo"; então mostra também a amostragem dele.
		arte.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.stretch_mode = TextureRect.STRETCH_SCALE
		arte.size = tamanhos[n]
		arte.position = canto + Vector2(
			(piso_tam.x - arte.size.x) / 2.0,
			(piso_tam.y - arte.size.y) / 2.0)
		root.add_child(arte)
		_artes.append([arte, n])

		var rotulo := Label.new()
		rotulo.text = n.get_basename()
		rotulo.position = canto + Vector2(2, celula.y - RODAPE)
		rotulo.add_theme_color_override("font_color", TINTA_FRACA)
		rotulo.add_theme_font_size_override("font_size", FONTE_NOME)
		root.add_child(rotulo)

		var chao := Label.new()
		chao.text = _linha_do_chao(n, chaos)
		chao.position = canto + Vector2(2, celula.y - RODAPE + 15)
		chao.add_theme_color_override("font_color",
			TINTA_RECURSO if tons.is_empty() else TINTA_FRACA)
		chao.add_theme_font_size_override("font_size", FONTE_CHAO)
		root.add_child(chao)
		_pecas += 1

	return true


## A segunda linha do rótulo: de que cor é o chão, ou que ele é de recurso.
func _linha_do_chao(png: String, chaos: Dictionary) -> String:
	var tons: Array = chaos.get(png, [])
	if tons.is_empty():
		return "sem âncora · recurso"
	var partes: Array = []
	for c in tons:
		partes.append("#" + (c as Color).to_html(false))
	return " ".join(partes)
