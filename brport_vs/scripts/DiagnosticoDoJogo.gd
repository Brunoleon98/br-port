extends RefCounted

# Nenhum autoload de partida entra nesta consulta (`128`). O recurso é
# produzido ANTES do export; o editor ignora sobras de exports anteriores.
const IDENTIFICACAO := "res://dados/identificacao_build.tres"


static func validar(recurso: Resource) -> Dictionary:
	if recurso == null or recurso.get_meta("formato", 0) != 1:
		return {}
	var commit: Variant = recurso.get_meta("commit", "")
	var modificado: Variant = recurso.get_meta("modificado", null)
	if not commit is String or not modificado is bool:
		return {}
	var padrao := RegEx.new()
	padrao.compile("^[0-9a-f]{40}$")
	if padrao.search(commit) == null:
		return {}
	return {"commit": commit, "modificado": modificado}


static func identificacao() -> Dictionary:
	if OS.has_feature("editor") or not ResourceLoader.exists(IDENTIFICACAO):
		return {}
	return validar(load(IDENTIFICACAO))


static func versao(dados: Dictionary) -> String:
	if dados.is_empty():
		return "Execução local · build não identificado" if OS.has_feature("editor") else "Build não identificado"
	return "Build %s%s" % [String(dados["commit"]).left(10),
		" · modificado" if dados["modificado"] else ""]


static func texto(dados: Dictionary) -> String:
	var linhas := PackedStringArray([String(ProjectSettings.get_setting("application/config/name")),
		versao(dados)])
	if not dados.is_empty():
		linhas.append("Commit: " + String(dados["commit"]))
	linhas.append("Godot: " + String(Engine.get_version_info()["string"]))
	linhas.append("Plataforma: " + OS.get_name())
	linhas.append("Renderização: " + RenderingServer.get_current_rendering_method())
	return "\n".join(linhas)
