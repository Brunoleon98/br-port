extends "res://scripts/Main.gd"

# A SONDA DA FAIXA DE MENSAGEM — recolhe tudo o que ENTRA na fila, das duas
# fontes, e a sonda do que SAI é o sinal `apresentou` da própria fila.
#
# ⚠️ ELA ESCUTA NOS DOIS PONTOS DE ENTRADA, e não num só. Até o R5 havia um
# funil único — o `_on_message` — e bastava interceptá-lo; com a fila, o
# `_cida_agora` passou a enfileirar direto, e uma sonda que só ouvisse o
# `_on_message` relataria **zero falas da Dona Cida**. Foi o que aconteceu na
# primeira corrida depois da fila: 443 escritas, todas do sistema, e
# "-194 nunca apresentadas" — um número negativo, que é o sintoma a apontar
# para a causa. É a regra do `CLAUDE.md` outra vez: quando uma régua devolve
# zero em tudo, a primeira pergunta é se ela consegue devolver outra coisa.
#
# ⚠️ E ELA NÃO REPLICA ESCOLHA NENHUMA. O `Narrativa.cida(id)` aqui é a MESMA
# consulta que o código real faz uma linha abaixo, não uma segunda decisão:
# quem escolheu o `id` foi o jogo, e é esse id que a sonda regista.
#
# ⚠️ E ELA NÃO PODE SER `preload`ADA de um `--script`: este arquivo herda o
# `Main.gd`, que fala do autoload pelo nome, e compilá-lo antes de a árvore
# estar de pé devolve um GDScript VAZIO. Quem a usa carrega-a com `load()`
# dentro do `_process`.
var registo: Array[Dictionary] = []


func _on_message(text: String, kind: String) -> void:
	registo.append({"texto": text, "kind": kind, "fonte": "sistema", "id": ""})
	super(text, kind)


func _cida_agora(id: String) -> void:
	var linha := Narrativa.cida(id)
	if linha != "":
		registo.append({"texto": linha, "kind": "", "fonte": "cida", "id": id})
	super(id)
