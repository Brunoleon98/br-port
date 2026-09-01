extends SceneTree

# ============================================================
# BR Port VS — recorta e amplia um pedaço de uma captura
#
# Existe porque a regra 5 do CLAUDE.md ("mexeu no visual? tire uma captura e
# OLHE") esbarra num detalhe prático: a 720×1280 um ícone tem 19 pixels, e
# 19 pixels não se julgam. Esta ferramenta amplia o pedaço com vizinho mais
# próximo — sem suavizar, porque suavizar inventa detalhe que não está lá.
#
# Pagou no primeiro uso: o painel da tela de nomes abria com o ícone `doca`,
# que é traço creme e só sobrevive em fundo escuro (o `Icones.gd` avisa por
# escrito). Na captura inteira ele passava por "está lá"; ampliado, era um
# fantasma pálido sobre o branco.
#
# CUIDADO COM AS COORDENADAS. Recorte de PROP no mapa não usa a coordenada que
# sai da projeção: o `MapaWrap` tem `offset_top = 62` e é preciso somar isso.
# Três recortes já foram ao telhado do lado por causa disto (CLAUDE.md, regra
# 5). Para painel de interface, que flutua sobre tudo, não há offset nenhum.
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tools/recortar_captura.gd \
#     -- entrada.png saida.png X Y LARG ALT [ZOOM]
# ============================================================

const ZOOM_PADRAO := 4


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 6:
		print("uso: -- <entrada.png> <saida.png> <x> <y> <larg> <alt> [zoom]")
		quit(1)
		return

	var origem := Image.load_from_file(args[0])
	if origem == null:
		print("FALHA: nao consegui abrir %s" % args[0])
		quit(1)
		return

	var x := int(args[2])
	var y := int(args[3])
	var larg := int(args[4])
	var alt := int(args[5])
	# Um recorte que saia da imagem devolve um PNG preto sem dizer nada, e aí
	# olha-se para o nada a concluir que o elemento sumiu. Melhor reprovar.
	if x < 0 or y < 0 or x + larg > origem.get_width() or y + alt > origem.get_height():
		print("FALHA: o recorte (%d,%d %dx%d) sai da imagem de %dx%d" % [
			x, y, larg, alt, origem.get_width(), origem.get_height()])
		quit(1)
		return

	var zoom := int(args[6]) if args.size() > 6 else ZOOM_PADRAO
	var recorte := origem.get_region(Rect2i(x, y, larg, alt))
	recorte.resize(larg * zoom, alt * zoom, Image.INTERPOLATE_NEAREST)
	recorte.save_png(args[1])
	print("Recorte %dx%d (zoom %d) salvo em %s" % [
		larg * zoom, alt * zoom, zoom, args[1]])
	quit(0)
