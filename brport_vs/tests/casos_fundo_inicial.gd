extends RefCounted

# A identidade da fonte aceita e os consumidores reais protegem a separação
# entre inicial e celular. O gosto e o espaço de água foram julgados na foto.
var falhas := 0
var completo := false


func conferir(rotulo: String, ok: bool) -> void:
	print("  PASS  D48: " if ok else "  FALHA D48: ", rotulo)
	if not ok:
		falhas += 1


func rodar(arvore: SceneTree) -> void:
	var tela: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(tela)
	var textura: Texture2D = tela.get_node("Fundo").texture
	var caminho := "res://art/tela_inicial/fundo_inicial.png"
	conferir("inicial desenha a fonte v3 aceita", textura.resource_path == caminho
		and FileAccess.get_sha256(caminho) == "c8dd35c73b11a13da9d3f773ba916cce10b9307c8d7d1addb79faf9571e7ec6f")
	var celular: Control = load("res://scripts/PainelCelular.gd").new()
	celular.theme = load("res://ui/tema_brport.tres")
	arvore.root.add_child(celular)
	celular.call("montar_celular", true)
	var parede: TextureRect = celular.find_child("PapelDeParede", true, false)
	conferir("celular conserva o degrade", parede != null and
		parede.texture.resource_path == "res://art/tela_inicial/fundo_provisorio.svg")
	celular.free()
	tela.free()
	completo = true
