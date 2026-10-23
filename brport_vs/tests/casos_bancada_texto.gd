extends RefCounted

# A bancada ainda não é uma preferência do jogo. Estas provas perguntam se
# a régua mede o aumento e denuncia texto para fora; não aprovam o leiaute.
# Os pares que cabem/transbordam usam a mesma fonte e a mesma caixa.
var falhas := 0
var completo := false


func conferir(rotulo: String, ok: bool) -> void:
	if ok:
		print("  PASS  BT: ", rotulo)
	else:
		print("  FALHA BT: ", rotulo)
		falhas += 1


func rodar(arvore: SceneTree) -> void:
	var medidor: Script = load("res://tools/medir_texto_bancada.gd")
	var tela := Control.new()
	tela.theme = load("res://ui/tema_brport.tres")
	arvore.root.add_child(tela)
	# A suíte pode ter alterado a janela física; a régua trabalha no retângulo
	# lógico do Viewport, que também é o limite do texto na aplicação.
	tela.size = tela.get_viewport_rect().size
	var curto := _rotulo(tela, "Cabe", "OK", Vector2(20, 20))
	var longo := _rotulo(tela, "Transborda", "WWWWWWWWWWWWWWWWWWWW", Vector2(20, 100))
	var fora := _rotulo(tela, "Fora", "WWWWWWWWWWWWWWWWWWWW",
		Vector2(tela.size.x - 8, 180))
	fora.clip_text = false
	var botao := Button.new()
	botao.name = "Acao"
	botao.text = "Voltar"
	botao.position = Vector2(20, 280)
	botao.add_theme_font_size_override("font_size", 19)
	tela.add_child(botao)
	medidor.aplicar(tela, 1.25)
	conferir("amplia o override real do rotulo e do botao de 19 para 24",
		curto.get_theme_font_size("font_size") == 24
		and botao.get_theme_font_size("font_size") == 24)
	medidor.aplicar(tela, 1.25)
	conferir("reaplicar no mesmo no nao acumula escala",
		curto.get_theme_font_size("font_size") == 24)
	medidor.aplicar(tela, 1.0)
	medidor.aplicar(tela, 1.5)
	conferir("voltar ao padrao e ampliar conserva a base 19",
		curto.get_theme_font_size("font_size") == 29
		and botao.get_theme_font_size("font_size") == 29)
	medidor.aplicar(tela, 1.0)
	# Sem um Container, a caixa permanece de largura fixa. Consultar o mínimo
	# atualiza a composição do Label mesmo na suíte síncrona, sem renderizar.
	for rotulo in [curto, longo, fora]:
		rotulo.get_minimum_size()
		rotulo.size = Vector2(100, 60)
	var dados: Dictionary = medidor.medir(tela)
	var por_nome := {}
	for texto in dados["textos"]:
		por_nome[texto["no"]] = texto
	conferir("a mesma caixa distingue texto que cabe de texto que transborda",
		por_nome["Cabe"]["excesso_local"] == 0.0
		and por_nome["Transborda"]["excesso_local"] > 100.0)
	conferir("texto fora da janela nao recebe o zero do texto dentro",
		por_nome["Cabe"]["excesso_janela"] == 0.0
		and por_nome["Fora"]["excesso_janela"] > 100.0)
	arvore.root.remove_child(tela)
	tela.free()
	completo = true


func _rotulo(tela: Control, nome: String, texto: String, posicao: Vector2) -> Label:
	var rotulo := Label.new()
	rotulo.name = nome
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.clip_text = true
	rotulo.add_theme_font_size_override("font_size", 19)
	tela.add_child(rotulo)
	rotulo.size = Vector2(100, 60)
	return rotulo
