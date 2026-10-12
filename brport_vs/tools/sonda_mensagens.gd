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
# ⚠️ E A FALA OUVE-SE PELO `falou` DA NARRADORA, e não por herança. Até ao
# segundo corte do M8 (`096`) esta sonda sobrescrevia o `_cida_agora` do
# `Main`; a narradora saiu para um script seu, e herdar o `Main` deixou de
# chegar a ela. A sonda de antes, posta a correr com a narradora fora, nem
# compilou — o `super(id)` não tem a quem chamar — e a régua imprimiu o
# marcador com zero ações; sem o `super`, compilaria e nunca seria chamada.
# É a armadilha do parágrafo acima com outra causa, e a régua passou a
# recusar uma fonte a zero.
#
# ⚠️ E ELA NÃO REPLICA ESCOLHA NENHUMA. O texto vem no próprio sinal, que a
# narradora emite no instante em que enfileira: quem escolheu o `id` foi o
# jogo, e é esse id que a sonda regista.
#
# ⚠️ E ELA NÃO PODE SER `preload`ADA de um `--script`: este arquivo herda o
# `Main.gd`, que fala do autoload pelo nome, e compilá-lo antes de a árvore
# estar de pé devolve um GDScript VAZIO. Quem a usa carrega-a com `load()`
# dentro do `_process`.
var registo: Array[Dictionary] = []


func _on_message(text: String, kind: String, assunto: String = "") -> void:
	registo.append({"texto": text, "kind": kind, "fonte": "sistema", "id": ""})
	super(text, kind, assunto)


# ANTES do `super()`: a narradora já existe (é um membro do `Main`, montado
# com a cena), e as ligações dela aos sinais do jogo só se fazem lá dentro.
#
# ⚠️ E O TONINHO É A TERCEIRA FONTE desde a `101`: o tutorial do dia 1 fala
# para a mesma fila, e uma sonda presa às duas de antes contá-lo-ia como
# apresentado sem nunca o ter visto entrar — a regra da sonda presa a um
# ponto de passagem (`gerais.md`). O `tutorial` é `@onready`, e já está de pé
# quando este `_ready()` corre.
func _ready() -> void:
	narradora.falou.connect(_registar_fala)
	tutorial.falou.connect(_registar_toninho)
	super()


func _registar_fala(id: String, linha: String) -> void:
	registo.append({"texto": linha, "kind": "", "fonte": "cida", "id": id})


func _registar_toninho(id: String, linha: String) -> void:
	registo.append({"texto": linha, "kind": "", "fonte": "toninho", "id": id})
