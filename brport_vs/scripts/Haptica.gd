class_name Haptica
extends RefCounted

# ============================================================
# BR Port VS — HÁPTICA: o ponto único que vibra (`docs/decisoes/149`)
#
# O desenho é o da `144` («T1 — a háptica»): quem vibra recebe o MOMENTO e
# decide a duração, a preferência e a contagem num lugar só, como o
# `Audio.gd` faz ao som. Medido antes (`144`, e outra vez na `149`): nenhuma
# chamada de vibração no jogo e nenhuma permissão `VIBRATE` no preset.
#
# QUEM PEDE É O TOQUE, e só ele — a mesma porta do assentar (`148`). O
# `obra_concluida` dispara também nas bancadas, nas suítes e no simulador, e o
# `atracar()` e o `pay_debt()` são chamados direto por eles: um ouvinte desses
# sinais contaria partidas que ninguém tocou. Por isso o pedido vive onde o
# dedo cai, depois de o `GameState` aceitar: o cartão ao largo
# (`BarcoFila`), a virada que o «Avançar dia» arma (`Main`), o «Pagar» do Sr.
# Ribeiro e o «Quitar agora». E não é autoload: um autoload carrega também em
# todo `--script`, e o que ele ouvisse por omissão envenenaria quem mede.
#
# ⚠️ A VIRADA SIMPLES NÃO VIBRA, e a segunda chance também não: o boleto
# sai, mas quem o paga é o banco, com acréscimo — a mensagem é um aviso, e
# vibrar a conquista ali seria comemorar a dívida (`149`).
#
# ⚠️ O MOVIMENTO REDUZIDO NÃO CALA A VIBRAÇÃO: são duas preferências, e quem
# pede menos movimento na tela pode querer o retorno no dedo — é dele, nos
# Ajustes, a «Vibração».
#
# ⚠️ NINGUÉM QUE ESCREVEU ISTO SENTIU ESTA VIBRAÇÃO. O contêiner não tem
# motor, e no Linux o `vibrate_handheld` não faz nada nem se queixa (sondado
# na `149`, com e sem tela). O que as suítes provam é a contagem; se vibra, e
# se a duração se sente, prova-se no telefone.
# ============================================================

## Momento → duração em ms (`144`): o atracar é um toque curto, a obra pronta
## e a parcela paga o dobro, que são conquistas e não gestos.
const DURACAO_MS := {
	"atracar": 20,
	"obra_pronta": 40,
	"parcela_paga": 40,
}

## Os pedidos que chegaram ao aparelho, por momento, desde que o processo
## abriu ou desde o `zerar()`. É a régua das suítes (D54): o
## `vibrate_handheld` não devolve nada, e aqui nada vibra.
static var pedidos: Dictionary = {}


static func pedir(momento: String) -> void:
	# Acesso direto: um momento mal escrito rebenta em vez de vibrar 0 ms.
	var ms: int = DURACAO_MS[momento]
	if not PreferenciasDeApresentacao.atual().vibrar:
		return
	pedidos[momento] = int(pedidos.get(momento, 0)) + 1
	Input.vibrate_handheld(ms)


static func zerar() -> void:
	pedidos.clear()
