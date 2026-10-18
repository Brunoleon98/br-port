extends Node

signal concluida(sucesso: bool)

var _tentativa := 0
var _aceita: JavaScriptObject
var _recusa: JavaScriptObject


func copiar(texto: String) -> void:
	_tentativa += 1
	var tentativa := _tentativa
	if OS.has_feature("web"):
		# clipboard_set() não informa se a promessa do navegador foi recusada.
		# A chamada fica no gesto do botão; só a resolução autoriza «copiado».
		var ponte: Object = Engine.get_singleton("JavaScriptBridge")
		var navegador = ponte.get_interface("navigator")
		if navegador.clipboard == null:
			concluida.emit(false)
			return
		_aceita = ponte.create_callback(_terminar_web.bind(tentativa, true))
		_recusa = ponte.create_callback(_terminar_web.bind(tentativa, false))
		navegador.clipboard.writeText(texto).then(_aceita).catch(_recusa)
		# Uma promessa que não termina não prende o botão para sempre. Uma
		# resposta atrasada não pode confirmar a tentativa seguinte.
		get_tree().create_timer(5.0).timeout.connect(_terminar.bind(tentativa, false))
	elif DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		DisplayServer.clipboard_set(texto)
		_terminar(tentativa, DisplayServer.clipboard_get() == texto)
	else:
		_terminar(tentativa, false)


func _terminar_web(_argumentos: Array, tentativa: int, sucesso: bool) -> void:
	_terminar(tentativa, sucesso)


func _terminar(tentativa: int, sucesso: bool) -> void:
	if tentativa != _tentativa:
		return
	_tentativa += 1
	concluida.emit(sucesso)
