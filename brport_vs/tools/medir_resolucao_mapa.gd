extends SceneTree

# BR Port — a régua da ALAVANCA A: quanta fronteira de valor sobrevive ao
# antisserrilhado, hoje e com o `svg/scale` a 1,5.
#
# POR QUE EM GODOT, E NÃO EM PYTHON
# ---------------------------------
# Pela mesma razão do `medir_enquadramento.gd`: este contêiner não tem
# rasterizador de SVG nenhum, e o do Godot é o ThorVG — o MESMO que importa o
# mapa no jogo. Medir aqui mede o que o jogador vê.
#
# A COMPARAÇÃO HONESTA NÃO É 720 CONTRA 1080
# ------------------------------------------
# Com `stretch/mode="canvas_items"` o jogo desenha na resolução NATIVA do
# aparelho: num telefone de 1080 de largura, os 720 do viewport são só
# coordenadas. Logo o que o jogador vê hoje é a textura de 720 AMPLIADA 1,5x
# pela GPU, e o que veria depois é uma textura de 1080 desenhada 1:1. As duas
# imagens têm 1080 px; comparar 720 com 1080 compararia tamanhos.
#
#   ANTES   ThorVG a 720  ->  resize bilinear para 1080   (o que a GPU faz)
#   DEPOIS  ThorVG a 1080 ->  1:1
#
# A MÉTRICA, E POR QUE NÃO É A SOMA DA ENERGIA
# --------------------------------------------
# A energia total de gradiente de uma fronteira é o salto de valor dela, e
# isso NÃO muda quando ela se espalha por mais pixels — ampliar uma imagem
# conserva a soma quase toda. O que ampliar destrói é o PICO: a mesma fronteira
# passa a subir ao longo de 1,5 px em vez de 1, e o degrau por pixel cai.
#
# Por isso a medida é a CONTAGEM de pixels cujo gradiente local passa de um
# piso de leitura, e a energia ACIMA desse piso. O piso é 6/255 de luminância,
# que é ~0,05 de contraste de Weber a meio tom — o mesmo corte que este
# projeto usa para dizer que uma peça "some" contra o fundo.
#
# E O MAPA TEM DUAS CAMADAS COM ESCALAS DIFERENTES
# ------------------------------------------------
# ⚠️ O campo de cor da água é um PNG de 720x720 EMBUTIDO no SVG, esticado sobre
# o `viewBox` de 1080. Subir o `svg/scale` não lhe acrescenta um pixel de
# informação: ele é o único sítio do mapa onde a precisão que falta não está no
# arquivo. Medir o quadro inteiro de uma vez misturaria o ganho real do vetor
# com o zero garantido do raster, e daria uma média que não descreve nem um nem
# outro.
#
# A máscara sai do próprio SVG: rasteriza-se uma segunda vez com a `<image>`
# retirada, e onde as duas versões diferem é onde o raster está à vista.
#
# ⚠️ E ELA NÃO SERVE PARA AS DUAS ESPUMAS, que são vetor semitransparente
# sobre fundo TRANSPARENTE. A luminância aqui ignora o alfa, então o que ela lê
# na borda de cada elipse é o salto entre o RGB da espuma e o RGB indefinido do
# pixel vazio — um pico de 215 num desenho cuja maior diferença real vale uma
# fração disso. Corra-a nos dois mapas, que são opacos; nas espumas o número
# sai e não quer dizer nada.
#
# Uso: $G --headless --path brport_vs \
#        --script res://tools/medir_resolucao_mapa.gd -- <svg> <dir_saida>

const PISO := 6.0          # 6/255 de luminância ~ 0,05 de Weber a meio tom
const JANELA_ALT := 660    # o `MapaWrap` corta o mapa em 660 dos 720


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("uso: --script res://tools/medir_resolucao_mapa.gd -- <svg> <dir>")
		quit(1)
		return
	var caminho: String = args[0]
	var dir: String = args[1]
	DirAccess.make_dir_recursive_absolute(dir)

	var f := FileAccess.open(caminho, FileAccess.READ)
	if f == null:
		printerr("não abre: %s" % caminho)
		quit(1)
		return
	var fonte := f.get_as_text()
	f.close()

	# A mesma fonte sem o raster da água. É uma `<image>` só, e o regex dela é
	# barato porque o `href` não tem `>` dentro (base64 não o usa).
	var re := RegEx.new()
	re.compile("<image[^>]*/>")
	var sem_raster := re.sub(fonte, "", true)
	var achou := re.search(fonte) != null

	var base := caminho.get_file().get_basename()
	print("=== %s ===" % base)
	print("raster embutido: %s" % ("sim" if achou else "NÃO"))

	# ANTES: 720 ampliado para 1080 pela GPU. DEPOIS: 1080 nativo.
	var antes := _rasterizar(fonte, 1.0)
	var depois := _rasterizar(fonte, 1.5)
	if antes == null or depois == null:
		quit(1)
		return
	var lado := depois.get_width()
	antes.resize(lado, lado, Image.INTERPOLATE_BILINEAR)

	var mascara := _mascara_do_raster(fonte, sem_raster, lado) if achou else null

	var janela := int(round(float(JANELA_ALT) / 720.0 * float(lado)))
	print("quadro %dx%d, janela %dx%d" % [lado, lado, lado, janela])

	var res := {}
	for regiao in ["tudo", "vetor", "raster"]:
		var m: Image = null
		var inverter := false
		if regiao == "vetor":
			if mascara == null:
				continue
			m = mascara
			inverter = true          # fora do raster
		elif regiao == "raster":
			if mascara == null:
				continue
			m = mascara
		var a := _medir(antes, janela, m, inverter)
		var d := _medir(depois, janela, m, inverter)
		res[regiao] = {"antes": a, "depois": d}
		var ganho := 0.0
		if a["acima"] > 0:
			ganho = (float(d["acima"]) / float(a["acima"]) - 1.0) * 100.0
		# ⚠️ A CONTAGEM MEDE A LARGURA DA FRONTEIRA, NÃO QUANTAS HÁ: uma
		# fronteira borrada espalha-se por mais pixels e cada um passa o piso.
		# Quem responde "mais afiada" é o PICO e a energia acima do piso.
		print("  %-7s  px %8d | px acima do piso (LARGURA): antes %7d  depois %7d  (%+6.1f%%)"
			% [regiao, a["total"], a["acima"], d["acima"], ganho])
		var ge := 0.0
		if a["energia"] > 0.0:
			ge = (d["energia"] / a["energia"] - 1.0) * 100.0
		print("           energia acima do piso: antes %10.0f  depois %10.0f  (%+6.1f%%)"
			% [a["energia"], d["energia"], ge])
		print("           pico médio da fronteira: antes %6.2f  depois %6.2f  (%+5.1f%%)"
			% [a["pico"], d["pico"],
			   (d["pico"] / a["pico"] - 1.0) * 100.0 if a["pico"] > 0.0 else 0.0])
		var e := _erro_visivel(antes, depois, janela, m, inverter)
		res[regiao]["erro"] = e
		print("           o que o jogador vê MUDAR: %.2f%% dos px passa de %d/255, %.2f%% passa de %d/255"
			% [e["frac_piso"] * 100.0, int(PISO), e["frac_2piso"] * 100.0, int(PISO) * 2])
		print("           |ΔL| médio %5.2f   p99 %6.2f   máx %6.2f"
			% [e["medio"], e["p99"], e["maximo"]])

	var saida := {"svg": base, "piso": PISO, "lado": lado,
				  "janela": janela, "regioes": res}
	var jf := FileAccess.open(dir.path_join("%s.json" % base), FileAccess.WRITE)
	jf.store_string(JSON.stringify(saida, "  "))
	jf.close()
	print("gravado em %s" % dir.path_join("%s.json" % base))
	quit(0)


func _rasterizar(fonte: String, escala: float) -> Image:
	var img := Image.new()
	var erro := img.load_svg_from_string(fonte, escala)
	if erro != OK:
		printerr("ThorVG falhou a %.2f: %d" % [escala, erro])
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


# Onde o raster da água está à vista: a diferença entre o SVG inteiro e o
# mesmo SVG sem a `<image>`. Rasterizado a 1,0 e ampliado — a máscara só
# precisa de dizer ONDE, e a fronteira dela não entra em conta nenhuma.
func _mascara_do_raster(fonte: String, sem: String, lado: int) -> Image:
	var a := _rasterizar(fonte, 1.0)
	var b := _rasterizar(sem, 1.0)
	if a == null or b == null:
		return null
	var m := Image.create(a.get_width(), a.get_height(), false, Image.FORMAT_L8)
	for y in a.get_height():
		for x in a.get_width():
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			var dif := absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			m.set_pixel(x, y, Color.WHITE if dif > 0.002 else Color.BLACK)
	m.resize(lado, lado, Image.INTERPOLATE_NEAREST)
	return m


# O gradiente local é o maior degrau de luminância para o vizinho da direita e
# para o de baixo. Conta-se o que passa do piso; a energia é o excedente.
func _medir(img: Image, janela: int, mascara: Image, inverter: bool) -> Dictionary:
	var larg := img.get_width()
	var total := 0
	var acima := 0
	var energia := 0.0
	var soma_pico := 0.0
	for y in janela - 1:
		for x in larg - 1:
			if mascara != null:
				var dentro := mascara.get_pixel(x, y).r > 0.5
				if dentro == inverter:
					continue
			total += 1
			var l := _lum(img.get_pixel(x, y))
			var g := maxf(absf(_lum(img.get_pixel(x + 1, y)) - l),
						  absf(_lum(img.get_pixel(x, y + 1)) - l))
			if g >= PISO:
				acima += 1
				energia += g - PISO
				soma_pico += g
	return {"total": total, "acima": acima, "energia": energia,
			"pico": (soma_pico / float(acima)) if acima > 0 else 0.0}


# O PORTÃO desta sessão: quanto do que o jogador vê muda de facto. A energia
# de gradiente diz que as fronteiras ficam mais afiadas; isto diz se essa
# diferença tem tamanho para se ver. O corte é o mesmo piso de Weber.
func _erro_visivel(antes: Image, depois: Image, janela: int,
				   mascara: Image, inverter: bool) -> Dictionary:
	var larg := antes.get_width()
	var hist := PackedInt32Array()
	hist.resize(256)
	var total := 0
	var soma := 0.0
	for y in janela:
		for x in larg:
			if mascara != null:
				var dentro := mascara.get_pixel(x, y).r > 0.5
				if dentro == inverter:
					continue
			var dl := absf(_lum(depois.get_pixel(x, y)) - _lum(antes.get_pixel(x, y)))
			total += 1
			soma += dl
			hist[mini(int(dl), 255)] += 1
	var acima_piso := 0
	var acima_2piso := 0
	var maximo := 0
	for v in range(255, -1, -1):
		if hist[v] > 0:
			maximo = v
			break
	for v in range(int(PISO), 256):
		acima_piso += hist[v]
	for v in range(int(PISO) * 2, 256):
		acima_2piso += hist[v]
	var alvo := int(float(total) * 0.99)
	var acc := 0
	var p99 := 0
	for v in 256:
		acc += hist[v]
		if acc >= alvo:
			p99 = v
			break
	return {"frac_piso": float(acima_piso) / float(maxi(total, 1)),
			"frac_2piso": float(acima_2piso) / float(maxi(total, 1)),
			"medio": soma / float(maxi(total, 1)),
			"p99": float(p99), "maximo": float(maximo)}


func _lum(c: Color) -> float:
	return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0
