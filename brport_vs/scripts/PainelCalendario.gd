extends PainelNarrativo

# ============================================================
# BR Port VS — o calendário, ao toque no chip "Dia" do HUD
#
# Terceiro e quarto itens do primeiro playtest viram UM painel só, de
# propósito: "tocar no chip do dia abre detalhe" e "calendário nos dias, com
# eventos sinalizados" são a mesma pergunta — o que este número de dia
# esconde. Abrir dois painéis diferentes para a mesma pergunta seria repetir
# trabalho para o jogador comparar.
#
# LÊ `GameState.calendario()`, e não recalcula nada aqui — a mesma razão de
# sempre: a conta vive uma vez, o teste confere essa vez, este painel só
# desenha.
#
# A OFERTA DO RIVAL NÃO ESTÁ NO CALENDÁRIO. Ela é sorteada turno a turno, não
# amarrada a um dia — um calendário que a marcasse de antemão estaria a
# inventar uma certeza que o jogo não tem (ver o comentário de `calendario()`
# no GameState).
# ============================================================

const LARGURA := 480
const ALTURA := 0

const COR_HOJE := Color(0.878, 0.604, 0.063)
# ⚠️ MEDIDO, NÃO REAPROVEITADO. O cinzento-azulado que `Main.gd` usa para
# texto neutro (0.51, 0.6, 0.706) foi calibrado para o FUNDO ESCURO do jogo —
# aqui o cartão é branco, e o mesmo tom mede 2,93:1, abaixo até do corte de
# texto grande (3,0). Este tom mede 5,42:1 no mesmo cartão.
const COR_PASSADO := Color(0.35, 0.42, 0.52)

const LARG_CELULA := 44.0
const ALT_CELULA := 30.0


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.DIA, "Calendário")
	paragrafo("Semana %d de %d — dia %d de %d"
		% [GameState.current_week(), GameState.WEEKS_TOTAL,
		   mini(GameState.turn, GameState.TURNS_TOTAL), GameState.TURNS_TOTAL])

	var dias: Array = GameState.calendario()
	var semana_atual := -1
	var grade: GridContainer
	for dia in dias:
		var semana: int = int(dia["semana"])
		if semana != semana_atual:
			semana_atual = semana
			secao("SEMANA %d" % semana)
			grade = GridContainer.new()
			grade.columns = GameState.TURNS_PER_WEEK
			grade.add_theme_constant_override("h_separation", 4)
			grade.add_theme_constant_override("v_separation", 2)
			_vbox.add_child(grade)
		grade.add_child(_celula(dia))

	fio()
	secao("LEGENDA")
	_linha_legenda(Icones.CAIXA, "fecho de semana — entra o aluguel do píer, saem salários e manutenção")
	_linha_legenda(Icones.PARCELA, "vencimento da parcela do Sr. Ribeiro")

	botao_fechar("Fechar")


func _celula(dia: Dictionary) -> Control:
	var rotulo := Label.new()
	rotulo.custom_minimum_size = Vector2(LARG_CELULA, ALT_CELULA)
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# O MARCADOR VAI NO TEXTO, e não num ícone dentro da célula — a 44px de
	# largura um ícone de 19px não sobra espaço para o número ao lado, e
	# jogo nenhum deste projeto encolhe ícone abaixo do que a folha de
	# contato mede. "!" pela parcela (o dia que decide a partida) e "•" pelo
	# fecho de semana — a legenda logo abaixo é que traduz os dois em ícone.
	var marca := ""
	if bool(dia["parcela_vence"]):
		marca = "!"
	elif bool(dia["fecha_semana"]):
		marca = "•"
	rotulo.text = "%d%s" % [int(dia["turno"]), marca]

	if bool(dia["hoje"]):
		rotulo.add_theme_color_override("font_color", COR_HOJE)
		rotulo.add_theme_font_size_override("font_size", 17)
	elif bool(dia["passado"]):
		rotulo.add_theme_color_override("font_color", COR_PASSADO)
	return rotulo


func _linha_legenda(icone: Texture2D, texto: String) -> void:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	_vbox.add_child(linha)

	var img := TextureRect.new()
	img.custom_minimum_size = Vector2(Icones.TAM_TEXTO, Icones.TAM_TEXTO)
	img.texture = icone
	img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	linha.add_child(img)

	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(rotulo)
