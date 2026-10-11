extends RefCounted

# ============================================================
# BR Port VS — a VEZ DAS TELAS QUE ABREM SOZINHAS
#
# O Sr. Ribeiro, o boletim, o fim de fase e — quando chega ao pagar — o
# Arlindo: as telas que o jogo abre sem o jogador pedir. Quem tem a vez está
# na tela; os outros esperam na fila, pela ordem em que chegaram, e a vez
# passa quando a tela sai da árvore. Até ao M8 da revisão de 09/10
# (`docs/decisoes/097`) vivia no `Main.gd`; saiu palavra por palavra, e o que
# mudou está dito abaixo.
#
# ⚠️ NÃO É UM `class_name`, pela razão do trânsito e da narradora (`095`,
# `096`): a regra do `gdscript.md` sobre o autoload. Este não lê o
# `GameState`, mas a forma das três extrações é uma só, e quem a vir aqui não
# tem de perguntar porque esta é diferente. O `Main` carrega-o por `preload`.
#
# ⚠️ E É UM OBJETO DO `Main`, como a fila da faixa: não desenha nada e não abre
# painel nenhum. Quem abre é a função que o `Main` lhe entrega — ela sabe que
# cena é e que `setup()` leva —, e este objeto só decide QUANDO a chamar. Do
# `Main` guarda uma coisa: a pergunta «ainda estás na árvore?», que o
# `_passar_a_vez()` lhe faz (era o `is_inside_tree()` do próprio `Main`).
#
# O que mudou nas linhas movidas, e só isto: o `na_vez()` e o `painel_da_vez`
# perderam o sublinhado — o `Main` chama um e lê o outro, e o `run_tests` lê o
# segundo —, e o `is_inside_tree()` passou a ser perguntado ao dono.
# ============================================================

# QUEM TEM A VEZ. Público para LER — o `Main` pergunta se é o Sr. Ribeiro
# antes de pôr o Arlindo na fila, e o T16 fecha-o pela mão do jogador. Quem o
# escreve é só este script.
var painel_da_vez: Control = null
# Os outros, pela ordem em que chegaram: cada um é a função que o abre.
var _fila_da_vez: Array[Callable] = []
# O `Main`, para a pergunta do `_passar_a_vez()` e para mais nada.
var _dono: Node


func _init(dono: Node) -> void:
	_dono = dono


# A VEZ DAS TELAS QUE ABREM SOZINHAS — o Sr. Ribeiro, o boletim e o fim de
# fase.
#
# Na última parcela, o «Pagar» fecha a semana e acaba a partida NA MESMA CHAMADA —
# `pay_debt()` → `_fechar_resumo_da_semana()` → `_check_end()` —, e cada sinal
# abria o seu painel por cima do anterior: o fim de fase no topo, o boletim da
# semana 4 debaixo dele e a resposta do Sr. Ribeiro no fundo. O toque só
# alcança o painel de cima, e o fim de fase oferece «Jogar de novo»: quem o
# tocava nunca via a resposta do banqueiro nem o último boletim. A foto
# `balanco` de 23/09 mostrou a pilha (três painéis), e a ordem passou a ser
# decisão do Bruno: resposta → boletim → fim de fase.
#
# O mesmo empilhamento acontecia no «Não consigo pagar», e em quem quitou antes
# do prazo — aí é o `advance_turn()` que fecha a semana e acaba a partida
# seguidos, sem Sr. Ribeiro. A fila cobre os três sem saber qual deles é: quem
# tem a vez fica na tela, e quem chega depois espera por ordem de chegada.
#
# A contra-oferta habitual do Arlindo continua a abrir por cima do boletim:
# é uma decisão que trava o turno. A exceção é a chegada sorteada ao pagar
# a parcela, ainda na resposta do Ribeiro: espera resposta → boletim e então
# abre a oferta (`087`, T16), sem esconder a confirmação do pagamento.
#
# ⚠️ QUEM PASSA A VEZ É O `tree_exited`, e não o `fechou`. É o único sinal por
# onde passa toda saída de um painel: o `_fechar()` do andaime, o
# `queue_free()` seco do «Fechar» do fim de fase e o `remove_child()` com que
# as ferramentas de captura dispensam o boletim. Uma fila à espera de um sinal
# que uma dessas portas não emite fica com o resto por abrir, sem erro nenhum —
# medido com a fila ligada ao `fechou`: as seis suítes passam (a jogar, todo
# painel que tem a vez sai pelo `_fechar()`), e o tiro `balanco` da captura
# chega ao vencimento em "debt_payment" SEM painel nenhum na tela — o Sr.
# Ribeiro preso na fila, porque o primeiro boletim saiu pelo `remove_child()`
# da ferramenta e nunca passou a vez. Fase que trava o turno sem painel para a
# resolver é o travamento calado que o `_recuperar_fase()` existe para evitar.
#
# Tudo isto vive na tela — no `Main` e neste objeto dele — e nada no
# GameState: os sinais saem na ordem de sempre, e o simulador, que não abre
# painel, não tem o que medir — é a regra "tela nova é overlay" do
# `CLAUDE.md` aplicada à ORDEM das telas.
func na_vez(abrir: Callable) -> void:
	_fila_da_vez.append(abrir)
	# Um painel mandado embora ainda segura a vez até sair, no fim do frame: é
	# o `tree_exited` dele que a passa, e quem chegou entretanto espera por ele.
	if not is_instance_valid(painel_da_vez):
		_dar_a_vez_ao_proximo()


func _dar_a_vez_ao_proximo() -> void:
	painel_da_vez = null
	if _fila_da_vez.is_empty():
		return
	var abrir: Callable = _fila_da_vez.pop_front()
	painel_da_vez = abrir.call()
	painel_da_vez.tree_exited.connect(_passar_a_vez, CONNECT_ONE_SHOT)


func _passar_a_vez() -> void:
	# O Main também sai da árvore — «Jogar de novo» recarrega a cena, e as
	# suítes libertam-no com painéis abertos. Os filhos saem com ele, e abrir
	# o próximo da fila nessa altura falha: medido sem esta guarda, libertar o
	# Main com dois painéis na fila dá "Parent node is busy setting up children,
	# `add_child()` failed" e deixa 36 nós órfãos.
	if not _dono.is_inside_tree():
		painel_da_vez = null
		return
	_dar_a_vez_ao_proximo()
