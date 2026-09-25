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

# ⚠️ O DIA DE HOJE SAI DO TEMA DESDE 20/09, e a constante que aqui estava era
# o âmbar de marca: media 2,39:1 sobre este cartão, contra um corte de 4,5. A
# variação `RotuloAlerta` é esse mesmo âmbar escurecido até 5,06:1
# (`docs/decisoes/035`), e vive no tema porque o mesmo papel aparece no HUD e
# na Reputação — três cópias à mão seriam três cores a divergirem.
# ⚠️ MEDIDO, NÃO REAPROVEITADO. O cinzento-azulado que `Main.gd` usa para
# texto neutro (0.51, 0.6, 0.706) foi calibrado para o FUNDO ESCURO do jogo —
# aqui o cartão é branco, e o mesmo tom mede 2,93:1, abaixo até do corte de
# texto grande (3,0). Este tom mede 5,42:1 no mesmo cartão.

# ⚠️ O ÍCONE VAI POR BAIXO DO NÚMERO, e a largura é medida. A semana tem
# `TURNS_PER_WEEK` colunas — OITO, não sete —, e o cartão tem 456 px por
# dentro (480 menos as margens de 12 do tema). Lado a lado, o último dia pede
# número + dois ícones = 60 px, e oito colunas de 60 com a separação dão 508:
# medido, o cartão alargava para 534 e saía descentrado. Por baixo, a célula
# só precisa dos dois ícones (40 px), e 52 deixa 12 px de folga. O D36 do
# teste de design reprova se a grelha voltar a alargar o cartão.
const LARG_CELULA := 52.0
const ALT_CELULA := 44.0

# ⚠️ A LEGENDA E A GRELHA LEEM ESTA TABELA, e até 23/09 eram duas. A grelha
# marcava o dia com "•" e "!" no texto e a legenda traduzia os dois em ÍCONE,
# de modo que quem lia a legenda procurava na grelha um desenho que ela não
# tinha — foi o veredito do Bruno no gate do A5: «os itens da legenda não
# aparecem no calendário». Uma tabela só faz as duas pontas mostrarem o mesmo
# desenho por construção, e a ordem dela é a da legenda.
#
# ⚠️ E O DIA PODE TER AS DUAS MARCAS. O último dia fecha a semana E vence a
# parcela, e o "!" escondia o "•" — a semana 4 era a única sem fecho marcado.
# A célula mostra todas as que valem, na ordem da tabela.
const MARCAS := [
	{
		"campo": "fecha_semana",
		"icone": Icones.CAIXA,
		"legenda": "fecho de semana — entra o aluguel do píer, saem salários e manutenção",
	},
	{
		"campo": "parcela_vence",
		"icone": Icones.PARCELA,
		"legenda": "vencimento da parcela do Sr. Ribeiro",
	},
]


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.DIA, "Calendário")
	# O DIA DE HOJE NA TARJA (26/09, `065`): é a resposta à pergunta do chip,
	# e a semana e o vencimento vão na linha de apoio, que é o contexto dele.
	# Tom neutro: um dia não é resultado nenhum.
	var vence := ("a parcela vence no dia %d" % GameState.PARCELA_DUE_TURN) \
		if not GameState.parcela_paid else "a parcela já está paga"
	tarja("Dia %d de %d" % [mini(GameState.turn, GameState.TURNS_TOTAL), GameState.TURNS_TOTAL],
		"Semana %d de %d · %s" % [GameState.current_week(), GameState.WEEKS_TOTAL, vence])

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
	for marca in MARCAS:
		_linha_legenda(marca["icone"], marca["legenda"])

	botao_fechar("Fechar")


func _celula(dia: Dictionary) -> Control:
	# ⚠️ O MARCADOR ERA TEXTO porque "a 44px um ícone de 19px não deixa espaço
	# para o número", e a legenda traduzia-o num ícone que a grelha não tinha.
	# A saída não foi encolher o ícone — ele fica nos 19 px que a folha de
	# contato mede —, foi pô-lo por BAIXO, como o autocolante num calendário de
	# parede. O número vai ao TOPO em toda célula, com ou sem ícone, senão a
	# linha do dia 8 sairia desalinhada da dos sete dias antes dele.
	var celula := VBoxContainer.new()
	celula.name = "Dia%d" % int(dia["turno"])
	celula.custom_minimum_size = Vector2(LARG_CELULA, ALT_CELULA)
	celula.add_theme_constant_override("separation", 0)
	celula.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var rotulo := Label.new()
	rotulo.name = "Numero"
	rotulo.text = str(int(dia["turno"]))
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	celula.add_child(rotulo)

	var marcas := HBoxContainer.new()
	marcas.name = "Marcas"
	marcas.alignment = BoxContainer.ALIGNMENT_CENTER
	marcas.add_theme_constant_override("separation", 2)
	marcas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	celula.add_child(marcas)
	for marca in MARCAS:
		if bool(dia[marca["campo"]]):
			marcas.add_child(Icones.imagem(marca["icone"]))

	if bool(dia["hoje"]):
		rotulo.theme_type_variation = "RotuloAlerta"
		# O TAMANHO FICA AQUI e não na variação: ela é usada a 13, 15 e 17px, e
		# um tamanho lá dentro encolheria o dia de hoje para o do aviso do HUD.
		rotulo.add_theme_font_size_override("font_size", 17)
	elif bool(dia["passado"]):
		# ⚠️ ERA UM `COR_PASSADO := Color(0.35, 0.42, 0.52)` ESCRITO AQUI, e o
		# tema dizia 0,50 — duas grafias quase iguais da mesma cor, a medir
		# 5,42:1 e 5,46:1. Nenhuma reprovava nada, e era exatamente por isso
		# que ninguém a via. O percurso dos 19 estados também não a media: ele
		# abre o calendário no dia 1, onde não há dia passado nenhum.
		rotulo.theme_type_variation = "RotuloApoio"
	return celula


func _linha_legenda(icone: Texture2D, texto: String) -> void:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	_vbox.add_child(linha)

	# ⚠️ O ÍCONE ESTICAVA COM A LINHA. Com `EXPAND_FIT_WIDTH_PROPORTIONAL` a
	# largura segue a ALTURA, e a legenda do fecho de semana quebra em duas
	# linhas: o saco de dinheiro saía com o dobro do tamanho do banco logo
	# abaixo. `Icones.imagem()` fixa os 19 px e centra na vertical.
	linha.add_child(Icones.imagem(icone))

	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(rotulo)
