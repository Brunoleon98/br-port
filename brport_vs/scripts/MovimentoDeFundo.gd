class_name MovimentoDeFundo
extends Node

# Só os ciclos decorativos explicitamente inventariados entram aqui. Não
# recebe tweens de serviço, trânsito, espera de ação ou virada de página.
var _ciclos: Array[Dictionary] = []


func _ready() -> void:
	PreferenciasDeApresentacao.atual().mudou.connect(_aplicar)


func guardar(tween: Tween, no: Node, repouso: Dictionary) -> void:
	_limpar()
	var ciclo := {"tween": tween, "no": weakref(no), "repouso": repouso}
	_ciclos.append(ciclo)
	_ajustar(ciclo, PreferenciasDeApresentacao.atual().reduzir_movimento)


func _limpar() -> void:
	_ciclos = _ciclos.filter(func(c: Dictionary) -> bool:
		return c["no"].get_ref() != null and c["tween"].is_valid())


func _aplicar(reduzido: bool) -> void:
	_limpar()
	for ciclo in _ciclos:
		_ajustar(ciclo, reduzido)


func _ajustar(ciclo: Dictionary, reduzido: bool) -> void:
	var tween: Tween = ciclo["tween"]
	var no: Node = ciclo["no"].get_ref()
	if reduzido:
		tween.pause()
		for propriedade in ciclo["repouso"]:
			no.set_indexed(NodePath(propriedade), ciclo["repouso"][propriedade])
	else:
		tween.play()
