extends SceneTree

# ============================================================
# BR Port VS — o ícone da aplicação
#
# POR QUE ISTO EXISTE. O primeiro APK instalado num telefone real apareceu na
# gaveta com O ROBÔ DO GODOT. O exportador do Android resolve o ícone por
# "escolha no preset -> ícone do projeto -> o padrão do motor"
# (platform/android/export/export_plugin.cpp), e o projeto não tinha nenhum dos
# dois. Nenhum teste podia ver isso: o ícone não existe dentro do jogo.
#
# POR QUE GERADO E NÃO DESENHADO. O traço vem do `art/icones/doca.svg`, que já
# é o desenho da âncora que a barra de HUD usa, e a cor vem da mesma navy do
# `Fundo` do Main.tscn. Um PNG desenhado à parte seria uma segunda versão da
# marca a envelhecer sozinha — o mesmo problema dos números em dois sítios.
#
# A âncora é traço CREME e só sobrevive em fundo escuro (ver Icones.gd), o que
# aqui calha: o fundo do ícone é a navy do jogo.
#
#   $G --headless --path brport_vs --script res://tools/gerar_icone_app.gd
#
# Escreve três arquivos, e são três porque o Android quer três:
#   icone_app.png             512  — o ícone clássico (e o `config/icon`)
#   icone_app_frente.png      432  — camada da frente do ícone adaptativo
#   icone_app_fundo.png       432  — camada de trás, chapada
#
# NO ÍCONE ADAPTATIVO O SISTEMA RECORTA. Ele aplica a máscara do fabricante
# (círculo, quadrado redondo, "squircle") sobre os 432, e só os 66% centrais
# são zona segura — 288px. A âncora é desenhada dentro desses 288 de propósito;
# desenhá-la à largura toda dá uma âncora com as pontas cortadas em metade dos
# telefones do mundo.
# ============================================================

# A navy do `Fundo` do Main.tscn — Color(0.051, 0.102, 0.149).
const FUNDO := "#0d1a26"
const CREME := "#f0f6ff"
const AMBAR := "#d97706"

const SAIDA := "res://art/"


func _process(_delta: float) -> bool:
	var traco := _ler_ancora()
	if traco == "":
		push_error("nao achei o desenho da ancora em art/icones/doca.svg")
		quit(1)
		return true

	# Clássico: fundo cheio, âncora a ~60% do quadro, e um fio âmbar em baixo
	# que é a linha-d'água — o mesmo âmbar do resto da interface.
	_escrever("icone_app.png", 512, _svg_completo(traco, true))
	# Adaptativo: a frente é SÓ a âncora, transparente, dentro da zona segura.
	_escrever("icone_app_frente.png", 432, _svg_completo(traco, false))
	# E o fundo é chapado. O sistema é que o recorta.
	_escrever("icone_app_fundo.png", 432,
		'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">' +
		'<rect width="24" height="24" fill="%s"/></svg>' % FUNDO)

	print("ICONE OK — 3 arquivos em art/")
	quit(0)
	return true


# O desenho sai do SVG que o jogo já usa, lido como TEXTO. Carregá-lo como
# textura daria os pixels, não o traço, e o que se quer aqui é redesenhá-lo
# maior sem o borrar.
func _ler_ancora() -> String:
	var f := FileAccess.open("res://art/icones/doca.svg", FileAccess.READ)
	if f == null:
		return ""
	var texto := f.get_as_text()
	var i := texto.find(">")
	var j := texto.rfind("</svg>")
	if i < 0 or j < 0:
		return ""
	return texto.substr(i + 1, j - i - 1).strip_edges()


func _svg_completo(traco: String, com_fundo: bool) -> String:
	var partes: Array[String] = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">']
	if com_fundo:
		partes.append('<rect width="24" height="24" fill="%s"/>' % FUNDO)
		# A linha-d'água. Dá ao ícone um horizonte, que é o que distingue um
		# porto de uma âncora solta.
		partes.append('<path d="M2.6 19.2h18.8" stroke="%s" stroke-width="1.1" stroke-linecap="round" opacity="0.9"/>' % AMBAR)

	# A âncora original vive num viewBox de 24 e ocupa-o quase todo. Aqui ela é
	# encolhida para a zona segura e subida um pouco, para a linha-d'água não
	# lhe passar por cima do arco.
	var escala := 0.62 if com_fundo else 0.60
	var desloca := (24.0 - 24.0 * escala) / 2.0
	partes.append('<g transform="translate(%.3f %.3f) scale(%.3f)">' % [desloca, desloca - 0.9, escala])
	partes.append(traco)
	partes.append('</g></svg>')
	return "".join(partes)


func _escrever(nome: String, lado: int, svg: String) -> void:
	var img := Image.new()
	# A escala é sobre o viewBox de 24: pedir 512 é escala 512/24. Rasterizar
	# no tamanho final em vez de esticar um PNG pequeno é a diferença entre um
	# traço limpo e um traço com serrilha.
	var erro := img.load_svg_from_string(svg, float(lado) / 24.0)
	if erro != OK:
		push_error("SVG nao rasterizou (%s): erro %d" % [nome, erro])
		quit(1)
		return
	if img.get_width() != lado:
		# O ThorVG arredonda; forçar o lado exato evita um 431x431 que o
		# Android aceita mas descentra.
		img.resize(lado, lado, Image.INTERPOLATE_LANCZOS)
	var e2 := img.save_png(SAIDA + nome)
	if e2 != OK:
		push_error("nao gravou %s: erro %d" % [nome, e2])
		quit(1)
		return
	print("  %-26s %dx%d" % [nome, img.get_width(), img.get_height()])
