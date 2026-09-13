extends Node2D

# O mar ocupa uma voz baixa e espaçada; a gaivota aparece bem menos. Os dois
# usam a mesma fila de prioridade dos SFX, portanto uma decisão do jogo sempre
# vence o ambiente se os pedidos coincidirem no mesmo frame.
const INTERVALO_MAR := Vector2(6.5, 9.5)
const INTERVALO_GAIVOTA := Vector2(42.0, 72.0)

var _sorteio := RandomNumberGenerator.new()
var _mar := Timer.new()
var _gaivota := Timer.new()


func _ready() -> void:
	_sorteio.seed = 20260913
	_configurar(_mar, _ao_mar)
	_configurar(_gaivota, _ao_gaivota)
	_programar(_mar, 2.0)
	_programar(_gaivota, _sorteio.randf_range(INTERVALO_GAIVOTA.x,
			INTERVALO_GAIVOTA.y))


func _configurar(timer: Timer, chamada: Callable) -> void:
	timer.one_shot = true
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.timeout.connect(chamada)
	add_child(timer)


func _programar(timer: Timer, segundos: float) -> void:
	timer.start(segundos)


func _ao_mar() -> void:
	Audio.tocar("mar")
	_programar(_mar, _sorteio.randf_range(INTERVALO_MAR.x, INTERVALO_MAR.y))


func _ao_gaivota() -> void:
	Audio.tocar("gaivota")
	_programar(_gaivota, _sorteio.randf_range(INTERVALO_GAIVOTA.x,
			INTERVALO_GAIVOTA.y))
