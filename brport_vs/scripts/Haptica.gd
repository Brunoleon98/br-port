class_name Haptica
extends RefCounted

# ============================================================
# BR Port VS — HÁPTICA: o ponto único que vibra (`docs/decisoes/149`)
#
# O desenho é o da `144` («T1 — a háptica»): quem vibra recebe o MOMENTO e
# decide o padrão, a preferência e a contagem num lugar só, como o
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
# na `149`, com e sem tela). O que as suítes provam é a contagem e os pulsos
# pela ordem; se vibra, e se o padrão se sente, prova-se no telefone.
# ============================================================

## Momento → os pulsos, `[ms, força]` (`149`, a segunda passagem, pelas
## boas práticas que o Bruno pediu):
##
## - CLARO, NÃO ZUMBIDO: a orientação do Android desaconselha a vibração
##   longa de um tiro só — o motor continua a ressoar depois dela —, e pede
##   pulsos curtos. Nenhum passa de 40 ms; a força vai na amplitude (0–1).
##   No telefone sem controlo de amplitude, e no Web, ela é ignorada e o
##   pulso sai inteiro: curto, continua a ler como um toque.
## - A FORÇA SEGUE A IMPORTÂNCIA: o atracar é o gesto de todos os dias, e é
##   o mais leve; a parcela paga é o marco da fase, e é a mais forte.
## - O SUCESSO TEM FORMA PRÓPRIA: dois toques a subir, o «confirmado» do
##   Android, na obra pronta e na parcela paga. Um toque só é «feito».
## A primeira passagem tinha um pulso por momento (20 e 40 ms à força do
## aparelho), e a obra e a parcela eram iguais.
const PADROES := {
	"atracar": [[15, 0.4]],
	"obra_pronta": [[18, 0.5], [28, 0.8]],
	"parcela_paga": [[22, 0.6], [36, 1.0]],
}
## Entre os pulsos de um padrão: curto o bastante para ler como um gesto só,
## longo o bastante para o motor parar entre os dois.
const INTERVALO_SEG := 0.08

## Os pedidos por momento, desde que o processo abriu ou desde o `zerar()`:
## a régua do D54, que não deixa passar quadros.
static var pedidos: Dictionary = {}
## Os pulsos que chegaram ao aparelho, `[ms, força]`, pela ordem: a régua do
## F24, que espera os quadros do segundo. O `vibrate_handheld` não devolve
## nada, e aqui nada vibra.
static var pulsos: Array = []


static func pedir(momento: String) -> void:
	# Acesso direto: um momento mal escrito rebenta em vez de vibrar nada.
	var padrao: Array = PADROES[momento]
	if not PreferenciasDeApresentacao.atual().vibrar:
		return
	pedidos[momento] = int(pedidos.get(momento, 0)) + 1
	_pulsar(padrao[0])
	# O resto do padrão pelo relógio da árvore, que corre também com o jogo
	# em pausa (`create_timer` processa sempre): o painel que abre a seguir
	# não corta o segundo toque.
	var arvore := Engine.get_main_loop() as SceneTree
	for i in range(1, padrao.size()):
		var pulso: Array = padrao[i]
		arvore.create_timer(INTERVALO_SEG * i).timeout.connect(func(): _pulsar(pulso))


static func _pulsar(pulso: Array) -> void:
	pulsos.append(pulso)
	Input.vibrate_handheld(int(pulso[0]), float(pulso[1]))


static func zerar() -> void:
	pedidos.clear()
	pulsos.clear()
