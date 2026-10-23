class_name MemoriaDeLeitura
extends RefCounted

# Caractere e distância da dobra, para a leitura sobreviver à quebra de
# linhas. O caminho permite reencontrar o texto quando a ajuda troca de página.
static func marcar(rolo: ScrollContainer) -> Dictionary:
	var topo := rolo.global_position.y
	for no in TextoDaInterface.descendentes(rolo):
		if not (no is Label or no is Button) or not no.is_visible_in_tree() or no.text.is_empty():
			continue
		if no.get_global_rect().end.y <= topo:
			continue
		var caractere := 0
		var deslocamento: float = no.global_position.y - topo
		if no is Label:
			for i in no.text.length():
				var letra: Rect2 = no.get_character_bounds(i)
				if letra.size.y > 0 and no.global_position.y + letra.end.y > topo:
					caractere = i
					deslocamento += letra.position.y
					break
		return {"no": no, "caminho": String(rolo.get_path_to(no)),
			"caractere": caractere, "deslocamento": deslocamento}
	return {}


static func restaurar(rolo: ScrollContainer, marca: Dictionary) -> void:
	if marca.is_empty():
		rolo.scroll_vertical = 0
		return
	var no: Control = marca.no if is_instance_valid(marca.no) else rolo.get_node_or_null(marca.caminho)
	if no == null:
		return
	var y := no.global_position.y
	if no is Label:
		y += no.get_character_bounds(marca.caractere).position.y
	rolo.scroll_vertical += roundi(y - rolo.global_position.y - marca.deslocamento)
