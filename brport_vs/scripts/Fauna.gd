extends Node2D

# Cada espécie tem um CICLO, não uma decoração eterna. A gaivota atravessa o
# quadro; a maria-farinha pertence a uma toca; a tartaruga sobe, nada no baixio
# e mergulha. Tudo usa tempo e sorteio determinísticos para as fotos do CI
# continuarem comparáveis.
@export_enum("gaivota", "maria_farinha", "tartaruga_verde") var especie := "gaivota"
@export var atraso_inicial := -1.0
@export var semente := 0

signal estado_mudou(especie_atual: String, estado: StringName)

enum Estado { ESPERANDO, APARECENDO, PRESENTE, SAINDO }

const NOMES_ESTADO := [&"esperando", &"aparecendo", &"presente", &"saindo"]
const TAMANHO_MAPA := Vector2(720.0, 720.0)
const MARGEM_FORA := 28.0
const ATRASOS_INICIAIS := {
	"gaivota": 0.35,
	"maria_farinha": 1.80,
	"tartaruga_verde": 3.60,
}
const ESPERAS := {
	"gaivota": Vector2(8.0, 16.0),
	"maria_farinha": Vector2(5.5, 10.0),
	"tartaruga_verde": Vector2(9.0, 17.0),
}
const DURACOES_PRESENTE := {
	"maria_farinha": Vector2(7.0, 10.0),
	"tartaruga_verde": Vector2(9.0, 14.0),
}
const SEMENTES := {
	"gaivota": 202609131,
	"maria_farinha": 202609132,
	"tartaruga_verde": 202609133,
}

@onready var _sprite: Sprite2D = $Sprite
@onready var _toque: Area2D = $Toque

var _sorteio := RandomNumberGenerator.new()
var _origem := Vector2.ZERO
var _estado := Estado.ESPERANDO
var _tempo_estado := 0.0
var _duracao_estado := 1.0

# Travessia da gaivota.
var _voo_inicio := Vector2.ZERO
var _voo_fim := Vector2.ZERO
var _voo_curva := 0.0

# Corrida/retorno dos animais presos ao habitat.
var _direcao := 1.0
var _inicio_saida := Vector2.ZERO

# Desenho procedural que vive atrás do sprite: toca na areia e ondulações.
var _buraco_alpha := 0.0
var _poeira_alpha := 0.0
var _onda_alpha := 0.0
var _onda_fase := 0.0


func _ready() -> void:
	_origem = position
	_sorteio.seed = semente if semente != 0 else int(SEMENTES[especie])
	_toque.input_event.connect(_ao_input)
	_entrar_espera(atraso_inicial if atraso_inicial >= 0.0
		else float(ATRASOS_INICIAIS[especie]))


func _process(delta: float) -> void:
	_tempo_estado += delta
	var progresso := clampf(_tempo_estado / _duracao_estado, 0.0, 1.0)

	match _estado:
		Estado.ESPERANDO:
			if _tempo_estado >= _duracao_estado:
				aparecer_agora()
		Estado.APARECENDO:
			_animar_aparicao(progresso)
			if _tempo_estado >= _duracao_estado:
				_entrar_presente()
		Estado.PRESENTE:
			_animar_presenca(progresso)
			if _tempo_estado >= _duracao_estado:
				if especie == "gaivota":
					_concluir_ciclo()
				else:
					sumir_agora()
		Estado.SAINDO:
			_animar_saida(progresso)
			if _tempo_estado >= _duracao_estado:
				_concluir_ciclo()

	if especie != "gaivota":
		queue_redraw()


func estado_atual() -> StringName:
	return NOMES_ESTADO[_estado]


func esta_presente() -> bool:
	return _estado != Estado.ESPERANDO and _sprite.visible


# API pequena de coordenação: permite ao ambiente (e à prova) adiantar um
# avistamento sem conhecer a máquina de estados interna.
func aparecer_agora() -> void:
	_restaurar_sprite()
	_sprite.visible = true
	_toque.input_pickable = true
	match especie:
		"gaivota":
			_preparar_gaivota()
		"maria_farinha":
			_direcao = -1.0 if _sorteio.randi_range(0, 1) == 0 else 1.0
			position = _origem
			_sprite.scale = Vector2(0.48, 0.08)
			_sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
			_buraco_alpha = 0.18
			_mudar_estado(Estado.APARECENDO, 0.62)
		"tartaruga_verde":
			_direcao = -1.0 if _sorteio.randi_range(0, 1) == 0 else 1.0
			position = _origem + Vector2(-14.0 * _direcao, 7.0)
			_sprite.flip_h = _direcao < 0.0
			_sprite.scale = Vector2(0.58, 0.58)
			_sprite.modulate = Color(0.62, 0.90, 1.0, 0.0)
			_onda_alpha = 0.0
			_mudar_estado(Estado.APARECENDO, 0.90)


func sumir_agora() -> void:
	if _estado in [Estado.ESPERANDO, Estado.SAINDO]:
		return
	_inicio_saida = position
	match especie:
		"gaivota":
			# Mantém a direção do voo, mas uma ave espantada ganha velocidade e
			# procura a borda em vez de voltar à antiga âncora.
			var rumo := (_voo_fim - _voo_inicio).normalized()
			_voo_inicio = position
			_voo_fim = position + rumo * 900.0
			_voo_curva = 0.0
			_mudar_estado(Estado.SAINDO, 1.35)
		"maria_farinha":
			_mudar_estado(Estado.SAINDO, 0.78)
		"tartaruga_verde":
			_mudar_estado(Estado.SAINDO, 0.86)


func _preparar_gaivota() -> void:
	var horizontal := _sorteio.randf() < 0.72
	if horizontal:
		_voo_inicio = Vector2(-MARGEM_FORA, _sorteio.randf_range(80.0, 610.0))
		_voo_fim = Vector2(TAMANHO_MAPA.x + MARGEM_FORA,
				_sorteio.randf_range(70.0, 620.0))
	else:
		# A faixa vertical fica mais para o mar: evita a ave atravessar o HUD e
		# ainda dá variedade sem escolher uma rota impossível pelo casario.
		_voo_inicio = Vector2(_sorteio.randf_range(360.0, 690.0), -MARGEM_FORA)
		_voo_fim = Vector2(_sorteio.randf_range(300.0, 700.0),
				TAMANHO_MAPA.y + MARGEM_FORA)
	if _sorteio.randi_range(0, 1) == 0:
		var troca := _voo_inicio
		_voo_inicio = _voo_fim
		_voo_fim = troca
	_voo_curva = _sorteio.randf_range(-46.0, 46.0)
	position = _voo_inicio
	_sprite.flip_h = _voo_fim.x < _voo_inicio.x
	var velocidade := _sorteio.randf_range(50.0, 64.0)
	_mudar_estado(Estado.PRESENTE, _voo_inicio.distance_to(_voo_fim) / velocidade)


func _entrar_presente() -> void:
	_restaurar_sprite()
	_sprite.visible = true
	_toque.input_pickable = true
	match especie:
		"maria_farinha":
			position = _origem
			_buraco_alpha = 0.30
			_mudar_estado(Estado.PRESENTE,
					_sortear(DURACOES_PRESENTE[especie]))
		"tartaruga_verde":
			position = _origem + Vector2(-14.0 * _direcao, 0.0)
			_sprite.flip_h = _direcao < 0.0
			_mudar_estado(Estado.PRESENTE,
					_sortear(DURACOES_PRESENTE[especie]))


func _entrar_espera(duracao: float) -> void:
	position = _origem
	_restaurar_sprite()
	_sprite.visible = false
	_toque.input_pickable = false
	_poeira_alpha = 0.0
	_onda_alpha = 0.0
	_buraco_alpha = 0.13 if especie == "maria_farinha" else 0.0
	_mudar_estado(Estado.ESPERANDO, duracao)
	queue_redraw()


func _concluir_ciclo() -> void:
	_entrar_espera(_sortear(ESPERAS[especie]))


func _mudar_estado(novo: Estado, duracao: float) -> void:
	_estado = novo
	_tempo_estado = 0.0
	_duracao_estado = maxf(duracao, 0.001)
	estado_mudou.emit(especie, estado_atual())


func _restaurar_sprite() -> void:
	rotation = 0.0
	scale = Vector2.ONE
	modulate = Color.WHITE
	_sprite.position = Vector2.ZERO
	_sprite.rotation = 0.0
	_sprite.scale = Vector2.ONE
	_sprite.modulate = Color.WHITE
	_sprite.flip_h = false


func _animar_aparicao(p: float) -> void:
	var suave := _suave(p)
	match especie:
		"maria_farinha":
			position = _origem + Vector2(_direcao * (1.0 - suave) * 2.5, 0.0)
			_sprite.scale = Vector2(lerpf(0.48, 1.0, suave),
					lerpf(0.08, 1.0, suave))
			_sprite.modulate.a = suave
			_poeira_alpha = sin(p * PI) * 0.34
			_buraco_alpha = lerpf(0.18, 0.30, suave)
		"tartaruga_verde":
			position = (_origem + Vector2(-14.0 * _direcao, 7.0)).lerp(
					_origem + Vector2(-14.0 * _direcao, 0.0), suave)
			_sprite.scale = Vector2.ONE * lerpf(0.58, 1.0, suave)
			_sprite.modulate = Color(lerpf(0.62, 1.0, suave),
					lerpf(0.90, 1.0, suave), 1.0, suave)
			_onda_alpha = sin(p * PI) * 0.22
			_onda_fase = p


func _animar_presenca(p: float) -> void:
	match especie:
		"gaivota":
			_animar_voo(p, false)
		"maria_farinha":
			_animar_maria_farinha()
		"tartaruga_verde":
			_animar_tartaruga(p)


func _animar_voo(p: float, fuga: bool) -> void:
	var linha := _voo_inicio.lerp(_voo_fim, p)
	var rumo := (_voo_fim - _voo_inicio).normalized()
	var normal := Vector2(-rumo.y, rumo.x)
	position = linha + normal * sin(p * PI) * _voo_curva

	# Rajada curta de batidas, depois planeio. A pose única não vira borracha:
	# só comprime 18% no eixo das asas, e durante o planeio quase não mexe.
	var fase := fmod(_tempo_estado, 2.70)
	var batendo := fuga or fase < 0.92
	if batendo:
		var pulso := 0.5 + 0.5 * cos(_tempo_estado * (10.5 if fuga else 8.2))
		_sprite.scale = Vector2(1.02, lerpf(0.82, 1.0, pulso))
	else:
		_sprite.scale = Vector2(1.0, 0.98)
	_sprite.rotation = sin(p * PI) * signf(_voo_curva) * 0.055
	var borda := minf(clampf(p / 0.045, 0.0, 1.0),
			clampf((1.0 - p) / 0.055, 0.0, 1.0))
	_sprite.modulate.a = borda


func _animar_maria_farinha() -> void:
	var agora := _deslocamento_maria(_tempo_estado)
	var antes := _deslocamento_maria(maxf(0.0, _tempo_estado - 0.04))
	var correndo := clampf(absf(agora - antes) / 0.55, 0.0, 1.0)
	position = _origem + Vector2(agora * _direcao, 0.0)
	_sprite.flip_h = _direcao < 0.0
	_sprite.rotation = sin(_tempo_estado * 9.0) * 0.035 * correndo
	_sprite.scale = Vector2(1.0 + correndo * 0.08, 1.0 - correndo * 0.04)
	_buraco_alpha = 0.30
	_poeira_alpha = correndo * 0.10


func _deslocamento_maria(tempo: float) -> float:
	# Corridas curtas intercaladas por vigília. O caranguejo sempre regressa à
	# mesma toca antes de sumir, em vez de deslizar em seno para sempre.
	var fase := fmod(tempo, 5.40)
	if fase < 0.72:
		return lerpf(0.0, 9.0, _suave(fase / 0.72))
	if fase < 1.55:
		return 9.0
	if fase < 2.42:
		return lerpf(9.0, -6.0, _suave((fase - 1.55) / 0.87))
	if fase < 3.25:
		return -6.0
	if fase < 4.18:
		return lerpf(-6.0, 0.0, _suave((fase - 3.25) / 0.93))
	return 0.0


func _animar_tartaruga(p: float) -> void:
	var inicio := _origem + Vector2(-14.0 * _direcao, 0.0)
	var fim := _origem + Vector2(18.0 * _direcao, -9.0)
	var rumo := (fim - inicio).normalized()
	var normal := Vector2(-rumo.y, rumo.x)
	position = inicio.lerp(fim, p) + normal * sin(p * TAU * 1.35) * 2.2
	_sprite.flip_h = _direcao < 0.0
	# O pulso pequeno sugere a propulsão das nadadeiras dianteiras sem deformar
	# o casco; uma pausa a cada ciclo quebra o metrônomo de um seno contínuo.
	var impulso := maxf(0.0, sin(_tempo_estado * 3.3))
	_sprite.scale = Vector2(1.0 + impulso * 0.035, 1.0 - impulso * 0.025)
	_sprite.rotation = sin(_tempo_estado * 1.1) * 0.045
	_onda_alpha = 0.10 + impulso * 0.08
	_onda_fase = _tempo_estado


func _animar_saida(p: float) -> void:
	var suave := _suave(p)
	match especie:
		"gaivota":
			_animar_voo(p, true)
		"maria_farinha":
			var corrida := _suave(clampf(p / 0.68, 0.0, 1.0))
			position = _inicio_saida.lerp(_origem, corrida)
			var enterra := _suave(clampf((p - 0.56) / 0.44, 0.0, 1.0))
			_sprite.scale = Vector2(lerpf(1.08, 0.42, enterra),
					lerpf(0.96, 0.06, enterra))
			_sprite.modulate.a = 1.0 - enterra
			_poeira_alpha = sin(enterra * PI) * 0.42
			_buraco_alpha = lerpf(0.30, 0.13, enterra)
		"tartaruga_verde":
			position = _inicio_saida + Vector2(6.0 * _direcao * suave,
					7.0 * suave)
			_sprite.scale = Vector2.ONE * lerpf(1.0, 0.32, suave)
			_sprite.modulate = Color(lerpf(1.0, 0.55, suave),
					lerpf(1.0, 0.86, suave), 1.0, 1.0 - suave)
			_onda_alpha = (1.0 - suave) * 0.26
			_onda_fase = 1.0 + p * 2.0


func _ao_input(_viewport: Node, evento: InputEvent, _forma: int) -> void:
	var tocou := evento is InputEventScreenTouch and (evento as InputEventScreenTouch).pressed
	if evento is InputEventMouseButton:
		var mouse := evento as InputEventMouseButton
		tocou = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if not tocou or not esta_presente():
		return
	get_viewport().set_input_as_handled()
	reagir()


func reagir() -> void:
	if not esta_presente() or _estado == Estado.SAINDO:
		return
	match especie:
		"gaivota":
			Audio.tocar("gaivota")
		"maria_farinha":
			Audio.tocar("areia")
		"tartaruga_verde":
			Audio.tocar("mergulho")
	sumir_agora()


func _sortear(intervalo: Vector2) -> float:
	return _sorteio.randf_range(intervalo.x, intervalo.y)


func _suave(valor: float) -> float:
	return smoothstep(0.0, 1.0, clampf(valor, 0.0, 1.0))


func _draw() -> void:
	if especie == "maria_farinha" and _buraco_alpha > 0.0:
		# A toca fica na âncora mesmo enquanto o caranguejo corre: como o nó se
		# move, desenha-se no deslocamento inverso para ela não o acompanhar.
		var toca_local := _origem - position
		draw_set_transform(toca_local, 0.0, Vector2(1.0, 0.42))
		draw_circle(Vector2.ZERO, 4.8,
				Color(0.23, 0.18, 0.11, _buraco_alpha))
		draw_arc(Vector2.ZERO, 5.3, 0.05, PI * 1.08, 16,
				Color(0.82, 0.72, 0.49, _buraco_alpha * 0.95), 1.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if _poeira_alpha > 0.0:
			for grao in [Vector2(-6, -1), Vector2(-3, 3), Vector2(4, 2), Vector2(7, -2)]:
				draw_circle(toca_local + grao, 0.9,
						Color(0.90, 0.82, 0.63, _poeira_alpha))

	if especie == "tartaruga_verde" and _onda_alpha > 0.0:
		draw_set_transform(Vector2(0.0, 2.5), 0.0, Vector2(1.0, 0.42))
		for i in range(2):
			var ciclo := fposmod(_onda_fase * 5.0 + float(i) * 5.0, 10.0)
			var alpha := _onda_alpha * (1.0 - ciclo / 10.0)
			draw_arc(Vector2.ZERO, 4.0 + ciclo, 0.15, PI - 0.15, 18,
					Color(0.80, 0.96, 1.0, alpha), 1.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
