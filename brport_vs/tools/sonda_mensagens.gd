extends "res://scripts/Main.gd"

# A SONDA DA FAIXA DE MENSAGEM — recolhe TODA escrita, das duas fontes.
#
# ⚠️ ELA NÃO REPLICA A ESCOLHA DE NENHUMA FALA, e é de propósito: o `_cida()`
# resolve o id em texto e chama `_on_message`, que desde 18/09 é o funil único
# das duas fontes. Uma sonda que se ligasse aos sinais do GameState teria de
# repetir aqui a lógica que escolhe a variante — o espelho que o `CLAUDE.md`
# descreve —, e mediria a cópia em vez do jogo.
#
# ⚠️ E A FONTE NÃO SE ADIVINHA PELO `kind`. A primeira versão desta sonda
# chamava "Dona Cida" a toda escrita com kind vazio, porque é assim que o
# `_cida_agora` chama o `_on_message` — e o `GameState` tem uma mensagem de
# SISTEMA com kind vazio também ("Trabalhador #N liberado", `:880`). Quem sabe
# de onde veio a linha é quem a escreveu, e é por isso que a marca sai daqui.
#
# ⚠️ E ELA NÃO PODE SER `preload`ADA de um `--script`: este arquivo herda o
# `Main.gd`, que fala do autoload pelo nome, e compilá-lo antes de a árvore
# estar de pé devolve um GDScript VAZIO. Quem a usa carrega-a com `load()`
# dentro do `_process`.
var registo: Array[Dictionary] = []

var _de_cida := false


func _cida_agora(id: String) -> void:
	_de_cida = true
	super(id)
	_de_cida = false


func _on_message(text: String, kind: String) -> void:
	registo.append({
		"texto": text,
		"kind": kind,
		"fonte": "cida" if _de_cida else "sistema",
	})
	super(text, kind)
