extends RefCounted

# T33: patamar baixo, memória por entrada e estilo do indicador (`147`).
# As falas são observadas pelo sinal que alimenta a fila, após dois frames.
var gs
var arvore: SceneTree
var falhas := 0
var completo := false
var narradora
var fila: FilaDeMensagens
var falas: Array[String] = []


func conferir(nome: String, ok: bool) -> void:
	print("PASS T33: " if ok else "FAIL T33: ", nome)
	if not ok:
		falhas += 1


func assentar() -> void:
	await arvore.process_frame
	await arvore.process_frame


func ouvir(id: String, _linha: String) -> void:
	falas.append(id)


func montar(valor: float) -> void:
	narradora = null
	gs._rng.seed = 33
	gs.new_game()
	gs.phase = gs.ESTADO_JOGANDO
	gs.turn = 3
	gs.reputation = valor
	falas.clear()
	fila = FilaDeMensagens.new()
	narradora = load("res://scripts/NarradoraDaCida.gd").new(fila)
	narradora.falou.connect(ouvir)
	narradora.conectar()
	await assentar()


func rodar(estado: Node, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	for caso in [[0.0, true], [20.9, true], [21.0, true], [40.99, true],
			[41.0, false], [65.0, false], [100.0, false]]:
		conferir("patamar de alerta em " + str(caso[0]), AvisoDeReputacao.baixa(caso[0]) == caso[1])
	await montar(80.0)
	conferir("início saudável não alarma", not falas.has("reputacao_caiu"))
	gs._change_reputation(-20.0)
	await assentar()
	conferir("queda ainda saudável não alarma", not falas.has("reputacao_caiu"))
	gs._change_reputation(-20.0)
	await assentar()
	conferir("entrar no patamar baixo avisa", falas.count("reputacao_caiu") == 1)
	gs._change_reputation(-5.0)
	gs._change_reputation(-5.0)
	await assentar()
	conferir("permanecer baixo não repete aviso", falas.count("reputacao_caiu") == 1)
	gs._change_reputation(12.0)
	await assentar()
	gs._change_reputation(-3.0)
	await assentar()
	conferir("recuperar e cair de novo permite outro aviso", falas.count("reputacao_caiu") == 2)
	await montar(35.0)
	conferir("abrir já baixo avisa uma vez", falas.count("reputacao_caiu") == 1)
	gs._change_reputation(0.0)
	await assentar()
	conferir("abrir baixo não repete no primeiro sinal", falas.count("reputacao_caiu") == 1)
	await montar(60.0)
	gs._change_reputation(5.0)
	await assentar()
	conferir("subir de patamar mantém elogio", falas.has("reputacao_subiu"))
	var rotulo := Label.new()
	rotulo.theme = load("res://ui/tema_brport.tres")
	arvore.root.add_child(rotulo)
	rotulo.text = "40 Questionável"
	AvisoDeReputacao.atualizar(rotulo, 40.0)
	await assentar()
	conferir("indicador baixo usa estilo de alerta", rotulo.theme_type_variation == &"TextoPilulaAlerta")
	var cor := rotulo.get_theme_color("font_color")
	conferir("cor de alerta é vermelha", cor.r > cor.g and cor.r > cor.b)
	conferir("número e patamar permanecem legíveis", rotulo.text == "40 Questionável")
	AvisoDeReputacao.atualizar(rotulo, 41.0)
	conferir("recuperar restaura estilo habitual", rotulo.theme_type_variation == &"TextoPilulaDestaque")
	rotulo.free()
	await montar(65.0)
	gs.nome_porto = "Cais do alerta"
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	await assentar()
	var hud: Label = main.get_node("HudBar/RepPilula/Linha/RepTexto")
	gs._change_reputation(-30.0)
	await assentar()
	conferir("HUD acompanha entrada no patamar baixo", hud.theme_type_variation == &"TextoPilulaAlerta"
		and hud.text.contains("35") and hud.text.contains("Questionável"))
	gs._change_reputation(6.0)
	await assentar()
	conferir("HUD acompanha recuperação", hud.theme_type_variation == &"TextoPilulaDestaque"
		and hud.text.contains("41") and hud.text.contains("Confiável"))
	main.free()
	narradora = null
	fila = null
	completo = true
