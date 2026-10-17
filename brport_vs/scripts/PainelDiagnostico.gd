extends PainelNarrativo

const Conteudo := preload("res://scripts/DiagnosticoDoJogo.gd")
const Copia := preload("res://scripts/CopiaDoDiagnostico.gd")
const LARGURA := 560
const ALTURA_BOTAO := 56

var tempo: StringName = &"consulta"
var _previa: Label
var _aviso: Label
var _copiar: Button
var _copiador: Node


func _ready() -> void:
	super._ready()
	_copiador = Copia.new()
	add_child(_copiador)
	_copiador.connect("concluida", _ao_copiar)
	montar(LARGURA, 0)
	titulo_encorpado(Icones.AJUSTES, "Versão e diagnóstico")
	var apoio := paragrafo("Confira abaixo o texto que será copiado. Depois você pode colar numa conversa para relatar um problema.")
	apoio.theme_type_variation = &"RotuloApoio"
	fio()
	_previa = paragrafo(Conteudo.texto(Conteudo.identificacao()))
	_previa.name = "Previa"
	_previa.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fio()
	var privacidade := paragrafo("Inclui apenas informações do jogo. Não inclui nomes, partida salva ou registro. Nada é enviado por esta tela.")
	privacidade.theme_type_variation = &"RotuloApoio"
	_copiar = Button.new()
	_copiar.name = "Copiar"
	_copiar.text = "Copiar diagnóstico"
	_copiar.custom_minimum_size.y = ALTURA_BOTAO
	_copiar.pressed.connect(_copiar_diagnostico)
	_vbox.add_child(_copiar)
	_aviso = paragrafo("")
	_aviso.name = "Resultado"
	_aviso.theme_type_variation = &"RotuloApoio"
	_aviso.visible = false
	var voltar := botao_fechar("Voltar")
	voltar.name = "Voltar"
	voltar.custom_minimum_size.y = ALTURA_BOTAO


func _copiar_diagnostico() -> void:
	if _copiar.disabled:
		return
	_copiar.disabled = true
	_aviso.visible = true
	_aviso.text = "Aguardando a cópia…"
	_copiador.call("copiar", _previa.text)


func _ao_copiar(sucesso: bool) -> void:
	_copiar.disabled = false
	_aviso.visible = true
	if sucesso:
		tempo = &"copiado"
		_aviso.text = "Diagnóstico copiado. Cole onde quiser compartilhar."
	else:
		tempo = &"indisponivel"
		_aviso.text = "Não foi possível copiar. Tente novamente ou faça uma captura desta tela."
