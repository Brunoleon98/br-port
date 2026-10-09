extends Control

# Vaga de doca no mapa do porto — a metade de CENÁRIO de uma doca.
#
# Desde o Bloco 4 a doca não é mais um cartão numa fileira: é uma POSIÇÃO no
# mapa visto de cima. O mapa desenha 3 vagas fixas; quantas estão construídas
# vem de GameState.docks. A vaga além do que existe mostra o píer por
# construir — é o que faz "Reconstruir o píer" ter consequência visível no
# mapa em vez de só somar um cartão.
#
# O TEXTO NÃO MORA MAIS AQUI. Ele desceu para DocaCartao.tscn, na barra sob o
# mapa: a chip escura pousada no tabuado tapava justamente o barco, o
# guindaste e o trabalhador que explicam o turno. O que ficou foi o alvo de
# arrasto e um realce que acende quando esta doca aceita quem está selecionado.
#
# A árvore de nós mora em Dock.tscn e o estilo no tema. Este script não
# constrói nem pinta nada: só escolhe qual textura e qual animação valem agora.

# Props ISOMÉTRICOS, gerados por tools/gerar_props_iso.py. São quadros de 512
# COORDENADAS cujo centro é a origem do mundo — a cena os ancora por aí, então
# trocar de textura nunca desloca o píer.
#
# ⚠️ E O PIXEL JÁ NÃO É A COORDENADA: desde a alavanca B o PNG tem 768 px
# dentro do mesmo quadro (`docs/decisoes/029`). Quem desfaz a diferença é o
# `expand_mode = 1` dos nós em `Dock.tscn`, e quem a traduz para uma régua é o
# `PropIso`. Este arquivo só troca texturas, então não tem conta nenhuma a
# fazer — mas o `pivot_offset` do nó `Lanca` é de COORDENADA, e o gerador
# imprime as duas linhas para não haver dúvida sobre qual copiar.
const ArtePierVazio := preload("res://art/props/pier_vazio.png")

# O PÍER E A LANÇA TÊM TRÊS NÍVEIS, e desde os upgrades quem escolhe são DUAS
# leituras — `nivel_pier()` e `nivel_guindaste()`, cada uma presa ao seu
# upgrade comprável. Eram uma só enquanto o nível era derivado da contagem de
# estruturas; separar foi o que impediu que comprar o guindaste engrossasse a
# laje do píer, que é o jogador ver mudar o que não comprou.
#
# ⚠️ AS TRÊS LANÇAS GIRAM NO MESMO PONTO. O `pivot_offset` do nó `Lanca` é UM,
# e as três foram construídas a partir do mesmo topo de torre para caberem
# nele. O bloco D17 do teste de design tranca isso.
const ArtePier := [
	preload("res://art/props/pier_n1.png"),
	preload("res://art/props/pier_n2.png"),
	preload("res://art/props/pier_n3.png"),
]
const ArteLanca := [
	preload("res://art/props/lanca_n1.png"),
	preload("res://art/props/lanca_n2.png"),
	preload("res://art/props/lanca_n3.png"),
]

# OS CASCOS, por CLASSE e por MOTIVO da escala. Não são sprites ilustrados em
# 3/4: aqueles têm a perspectiva assada dentro da imagem e ficam atravessados
# em cima de um píer isométrico, que é o erro que já custou duas levas de arte.
#
# ⚠️ O `barco_medio` EXISTIA E NUNCA ENTRAVA EM DOCA até 05/09 — era gerado,
# validado e usado só como enfeite na Zona de Espera, porque o jogo escolhia
# entre dois cascos por um booleano. Depois disso passou a ser escolhido pelo
# VALOR do contrato; desde 06/09 é a CLASSE que o escolhe, que é a mesma
# informação sem o intermediário: a classe já traz a faixa de valor consigo.
#
# ⚠️ E DESDE 07/09 A CLASSE NÃO CHEGA. Os motivos da escala
# (`docs/decisoes/008`) deram ao jogo a informação de que carga cada navio
# traz, e os dois cargueiros continuavam a levar as mesmas caixinhas
# coloridas: a mecânica existia e o desenho não a dizia. Agora o casco sai do
# par (classe, motivo) — a classe dá o PORTE e o motivo dá o CONVÉS.
#
# ⚠️ O PESQUEIRO CONTINUA A NÃO MUDAR COM O MOTIVO, E ISSO É AFIRMAÇÃO. Ele
# chega com `pescado` ou com `armazenagem`, que é o mesmo peixe a ir para o
# mercado ou para a câmara do armazém — o DESTINO da carga muda, o barco não.
# Escrever a mesma lista duas vezes é o que faz esta tabela ser percorrível
# pelo D17 sem uma exceção escrita em código.
#
# ⚠️ E DESDE 08/09 CADA FOLHA É UMA LISTA, ordenada do menor porte para o
# maior. O eixo novo é o PORTE, e ele NÃO é o motivo: a trava de
# `docs/decisoes/009` prende o pesqueiro ao nível 1, então o porto em ruínas
# recebia o mesmo barco em todas as docas, em todos os turnos, a partida
# inteira. Quem escolhe entre os portes é o VALOR do contrato — um bote de
# linha não traz uma escala de R$28.000 —, e é por isso que a variedade não
# custou um sorteio: o valor já nasce com o barco (`docs/decisoes/014`).
#
# ⚠️ A LISTA DE UM ELEMENTO NÃO É UM CASO ESPECIAL, é a mesma tabela. As
# classes de carga separam-se pelo CONVÉS e não pelo porte, e escrevê-las com
# uma folha de um elemento é o que evita a forma variável — dicionário aqui e
# lista ali — que faria esta tabela deixar de se percorrer.
const CASCOS := {
	"pesqueiro": {
		"pescado": [
			preload("res://art/props/barco_pesca_bote.png"),
			preload("res://art/props/barco_pesca_traineira.png"),
			preload("res://art/props/barco_pesca_arrasteiro.png"),
		],
		"armazenagem": [
			preload("res://art/props/barco_pesca_bote.png"),
			preload("res://art/props/barco_pesca_traineira.png"),
			preload("res://art/props/barco_pesca_arrasteiro.png"),
		],
	},
	"medio": {
		"armazenagem": [preload("res://art/props/barco_medio_geral.png")],
		"conteiner": [preload("res://art/props/barco_medio_conteiner.png")],
		"granel": [preload("res://art/props/barco_medio_granel.png")],
	},
	"grande": {
		"armazenagem": [preload("res://art/props/barco_grande_geral.png")],
		"conteiner": [preload("res://art/props/barco_grande_conteiner.png")],
		"granel": [preload("res://art/props/barco_grande_granel.png")],
	},
}


# ── O PAU-DE-CARGA QUE DESCARREGA (02/10, `docs/decisoes/075`, `076`) ──
#
# Quem descarrega é o GUINDASTE, e o trabalhador opera-o — escolha do Bruno,
# depois de ver o trabalhador a levar a carga ao ombro (`075`): «é ele que
# sempre fará isso». No nível 1 o pau-de-carga gira do porão do pesqueiro à
# pilha no tabuado, o gancho desce, sobe com a lingada de peixe, gira, desce e
# larga; o trabalhador fica no guincho ao pé do mastro. No nível 2 o guindaste
# dele descarrega e ele desengata, e depois leva a carga ao camião (`077`, mais
# abaixo); no 3 o pórtico descarrega e ele leva o pallet de empilhadeira
# (`079`, mais abaixo).
#
# O sexo de quem está alocado sai do rosto dele (`Retratos`). O PARADO do
# homem é o `trabalhador` de sempre — a régua da fauna e da página de escala.
const QUADROS_TRABALHADOR := {
	"h": {
		"parado": preload("res://art/props/trabalhador.png"),
		"guincho": [
			preload("res://art/props/trab_h_guincho_0.png"),
			preload("res://art/props/trab_h_guincho_1.png"),
		],
		# No n2, ao pé da pilha: à espera e a soltar o gancho (`077`).
		"pilha": [
			preload("res://art/props/trab_h_pilha_0.png"),
			preload("res://art/props/trab_h_pilha_1.png"),
		],
		"leva": [
			preload("res://art/props/trab_h_leva_0.png"),
			preload("res://art/props/trab_h_leva_1.png"),
			preload("res://art/props/trab_h_leva_2.png"),
		],
		"volta": [
			preload("res://art/props/trab_h_volta_0.png"),
			preload("res://art/props/trab_h_volta_1.png"),
			preload("res://art/props/trab_h_volta_2.png"),
		],
	},
	"m": {
		"parado": preload("res://art/props/trab_m_parado.png"),
		"guincho": [
			preload("res://art/props/trab_m_guincho_0.png"),
			preload("res://art/props/trab_m_guincho_1.png"),
		],
		"pilha": [
			preload("res://art/props/trab_m_pilha_0.png"),
			preload("res://art/props/trab_m_pilha_1.png"),
		],
		"leva": [
			preload("res://art/props/trab_m_leva_0.png"),
			preload("res://art/props/trab_m_leva_1.png"),
			preload("res://art/props/trab_m_leva_2.png"),
		],
		"volta": [
			preload("res://art/props/trab_m_volta_0.png"),
			preload("res://art/props/trab_m_volta_1.png"),
			preload("res://art/props/trab_m_volta_2.png"),
		],
	},
}

# OS QUADROS DO PAU-DE-CARGA. Cada um é o pau renderizado no seu ângulo — a
# 60° de giro a imagem girada no plano da tela já não é um pau visto em
# isométrico. `g0`..`g6` vão do porão (18°) à pilha (80°), `c` é com a lingada
# pendurada, e `barco`/`pilha` são o gancho em baixo nas duas pontas. O `g0`
# vazio é o `lanca_n1` de repouso, o mesmo que o `ArteLanca` varre.
const LANCA_N1 := {
	"g0": preload("res://art/props/lanca_n1.png"),
	"g1": preload("res://art/props/lanca_n1_g1.png"),
	"g2": preload("res://art/props/lanca_n1_g2.png"),
	"g3": preload("res://art/props/lanca_n1_g3.png"),
	"g4": preload("res://art/props/lanca_n1_g4.png"),
	"g5": preload("res://art/props/lanca_n1_g5.png"),
	"g6": preload("res://art/props/lanca_n1_g6.png"),
	"g0c": preload("res://art/props/lanca_n1_g0c.png"),
	"g1c": preload("res://art/props/lanca_n1_g1c.png"),
	"g2c": preload("res://art/props/lanca_n1_g2c.png"),
	"g3c": preload("res://art/props/lanca_n1_g3c.png"),
	"g4c": preload("res://art/props/lanca_n1_g4c.png"),
	"g5c": preload("res://art/props/lanca_n1_g5c.png"),
	"g6c": preload("res://art/props/lanca_n1_g6c.png"),
	"barco": preload("res://art/props/lanca_n1_barco.png"),
	"barco_c": preload("res://art/props/lanca_n1_barco_c.png"),
	"pilha": preload("res://art/props/lanca_n1_pilha.png"),
	"pilha_c": preload("res://art/props/lanca_n1_pilha_c.png"),
}

# O CICLO, em quadros e segundos, a começar no porão com o gancho em cima.
# Uma tabela e não uma conta, porque as pausas são de pessoa e não de
# geometria: o gancho demora mais em baixo (a engatar, a soltar) do que a
# passar por um ângulo. ~10° de giro a cada 0,22 s.
const CICLO_N1 := [
	["g0", 0.25], ["barco", 0.45], ["barco_c", 0.45], ["g0c", 0.25],
	["g1c", 0.22], ["g2c", 0.22], ["g3c", 0.22], ["g4c", 0.22], ["g5c", 0.22],
	["g6c", 0.22], ["pilha_c", 0.45], ["pilha", 0.45], ["g6", 0.25],
	["g5", 0.22], ["g4", 0.22], ["g3", 0.22], ["g2", 0.22], ["g1", 0.22],
]
# O operador troca de mão na alavanca a este ritmo enquanto o pau trabalha.
const OPERADOR_SEG := 0.35

# A PILHA, pelo par (classe, motivo) — a mesma chave do casco. O pesqueiro
# leva peixe nos DOIS motivos, pela razão que o `CASCOS` já escreve: a
# armazenagem dele é o mesmo peixe a ir para a câmara do armazém.
#
# ⚠️ SÓ O PESQUEIRO ESTÁ AQUI, e não é esquecimento: com o guindaste de nível
# 1 o porto só recebe o pesqueiro (`docs/decisoes/009`), e a lingada dos
# quadros do `LANCA_N1` é de peixe por isso mesmo. Quem tranca que toda classe
# alcançável no nível 1 tem a sua linha é o D39.
const PILHAS_N1 := {
	"pesqueiro": {
		"pescado": preload("res://art/props/pilha_peixe.png"),
		"armazenagem": preload("res://art/props/pilha_peixe.png"),
	},
}


# ── O GUINDASTE DO NÍVEL 2 QUE DESCARREGA (02/10, `docs/decisoes/077`) ──
#
# Escolhas do Bruno: o guindaste tira a lingada do barco e pousa-a numa pilha
# no tabuado, o trabalhador DESENGATA-A, e nos serviços de mais de um turno
# leva a carga ao camião. No PRIMEIRO turno do serviço (`progress` 0) o
# guindaste descarrega; a partir do segundo pára, e é a vez dele.
#
# O ciclo é o do pau do n1, passo a passo — os mesmos nomes no `CICLO_N1`, o
# mesmo raio e o mesmo giro no gerador —, e por isso a pilha do peixe serve
# aos dois níveis. O que muda é a CARGA: quatro tipos, e ela é uma textura à
# parte (`LINGADAS_N2`), no nó `Carga`, em vez de vir dentro do quadro da
# lança: com ela dentro seriam 36 quadros de treliça.

# O tipo de carga do serviço, pelo par (classe, motivo) — a mesma chave do
# casco. Acesso DIRETO, como no casco: um par que o nível 2 receba sem tipo
# tem de rebentar no `refresh()`, e não deixar o guindaste parado calado. O
# D40 tranca que todo par alcançável no nível 2 tem a sua linha.
const CARGA_DO_SERVICO := {
	"pesqueiro": {"pescado": "peixe", "armazenagem": "peixe"},
	"medio": {"armazenagem": "caixa", "granel": "saco", "conteiner": "conteiner"},
	# O navio de longo curso só atraca no nível 3 (`079`), e leva o mesmo que
	# o cargueiro: o motivo é que diz a carga, e a classe o porte.
	"grande": {"armazenagem": "caixa", "granel": "saco", "conteiner": "conteiner"},
}

# A lança girada: `g0` é o repouso (o mesmo `lanca_n2` que o `ArteLanca`
# varre), `g6` está sobre a pilha.
const LANCA_N2 := {
	"g0": preload("res://art/props/lanca_n2.png"),
	"g1": preload("res://art/props/lanca_n2_g1.png"),
	"g2": preload("res://art/props/lanca_n2_g2.png"),
	"g3": preload("res://art/props/lanca_n2_g3.png"),
	"g4": preload("res://art/props/lanca_n2_g4.png"),
	"g5": preload("res://art/props/lanca_n2_g5.png"),
	"g6": preload("res://art/props/lanca_n2_g6.png"),
}

# O gancho em BAIXO, nas duas pontas, por tipo: cada carga pousa a outra
# altura — em cima da palete, da tampa do porão, do contêiner de baixo.
const PONTAS_N2 := {
	"peixe": {
		"barco": preload("res://art/props/lanca_n2_barco_peixe.png"),
		"pilha": preload("res://art/props/lanca_n2_pilha_peixe.png"),
	},
	"caixa": {
		"barco": preload("res://art/props/lanca_n2_barco_caixa.png"),
		"pilha": preload("res://art/props/lanca_n2_pilha_caixa.png"),
	},
	"saco": {
		"barco": preload("res://art/props/lanca_n2_barco_saco.png"),
		"pilha": preload("res://art/props/lanca_n2_pilha_saco.png"),
	},
	"conteiner": {
		"barco": preload("res://art/props/lanca_n2_barco_conteiner.png"),
		"pilha": preload("res://art/props/lanca_n2_pilha_conteiner.png"),
	},
}

# A carga pendurada, por tipo e por posição do gancho. Nasce no quadro do
# PÍER e já no sítio do gancho daquele passo: o nó só troca de textura.
const LINGADAS_N2 := {
	"peixe": {
		"barco": preload("res://art/props/lingada_peixe_barco.png"),
		"g0": preload("res://art/props/lingada_peixe_g0.png"),
		"g1": preload("res://art/props/lingada_peixe_g1.png"),
		"g2": preload("res://art/props/lingada_peixe_g2.png"),
		"g3": preload("res://art/props/lingada_peixe_g3.png"),
		"g4": preload("res://art/props/lingada_peixe_g4.png"),
		"g5": preload("res://art/props/lingada_peixe_g5.png"),
		"g6": preload("res://art/props/lingada_peixe_g6.png"),
		"pilha": preload("res://art/props/lingada_peixe_pilha.png"),
	},
	"caixa": {
		"barco": preload("res://art/props/lingada_caixa_barco.png"),
		"g0": preload("res://art/props/lingada_caixa_g0.png"),
		"g1": preload("res://art/props/lingada_caixa_g1.png"),
		"g2": preload("res://art/props/lingada_caixa_g2.png"),
		"g3": preload("res://art/props/lingada_caixa_g3.png"),
		"g4": preload("res://art/props/lingada_caixa_g4.png"),
		"g5": preload("res://art/props/lingada_caixa_g5.png"),
		"g6": preload("res://art/props/lingada_caixa_g6.png"),
		"pilha": preload("res://art/props/lingada_caixa_pilha.png"),
	},
	"saco": {
		"barco": preload("res://art/props/lingada_saco_barco.png"),
		"g0": preload("res://art/props/lingada_saco_g0.png"),
		"g1": preload("res://art/props/lingada_saco_g1.png"),
		"g2": preload("res://art/props/lingada_saco_g2.png"),
		"g3": preload("res://art/props/lingada_saco_g3.png"),
		"g4": preload("res://art/props/lingada_saco_g4.png"),
		"g5": preload("res://art/props/lingada_saco_g5.png"),
		"g6": preload("res://art/props/lingada_saco_g6.png"),
		"pilha": preload("res://art/props/lingada_saco_pilha.png"),
	},
	"conteiner": {
		"barco": preload("res://art/props/lingada_conteiner_barco.png"),
		"g0": preload("res://art/props/lingada_conteiner_g0.png"),
		"g1": preload("res://art/props/lingada_conteiner_g1.png"),
		"g2": preload("res://art/props/lingada_conteiner_g2.png"),
		"g3": preload("res://art/props/lingada_conteiner_g3.png"),
		"g4": preload("res://art/props/lingada_conteiner_g4.png"),
		"g5": preload("res://art/props/lingada_conteiner_g5.png"),
		"g6": preload("res://art/props/lingada_conteiner_g6.png"),
		"pilha": preload("res://art/props/lingada_conteiner_pilha.png"),
	},
}

# A pilha no tabuado, por tipo, no mesmo ponto em todos — o do peixe do n1.
const PILHAS_N2 := {
	"peixe": preload("res://art/props/pilha_peixe.png"),
	"caixa": preload("res://art/props/pilha_caixa.png"),
	"saco": preload("res://art/props/pilha_saco.png"),
	"conteiner": preload("res://art/props/pilha_conteiner.png"),
}


## O passo do ciclo do n2 no instante `t`: a posição da lança (`g0`..`g6`,
## `barco` ou `pilha`), a da carga pendurada (a mesma, ou "" sem carga) e o
## quadro de quem desengata (1 com o gancho em baixo na pilha: está a soltá-lo).
## Aritmética pura, como a do n1, e sobre a MESMA tabela.
static func pose_n2(t: float) -> Dictionary:
	var passo := String(pose_do_guindaste(t)["lanca"])
	var com_carga := passo.ends_with("c")
	var lugar := passo.trim_suffix("_c")
	if lugar.begins_with("g"):
		lugar = lugar.trim_suffix("c")
	return {
		"lanca": lugar,
		"carga": lugar if com_carga else "",
		"trabalhador": 1 if lugar == "pilha" else 0,
	}


## O tipo de carga deste barco no guindaste do n2.
static func tipo_de_carga(classe: String, motivo: String) -> String:
	return String(CARGA_DO_SERVICO[classe][motivo])


# ── A IDA AO CAMIÃO (02/10, `077`) ──
#
# A partir do SEGUNDO turno do serviço o guindaste pára, e se o camião do
# serviço está encostado no berço — de ré, com as portas para o píer — ele
# leva a carga da pilha às portas de trás dele, ao ombro, e volta. Sem camião espera ao pé da pilha. Só o papelão e o saco vão
# ao ombro: o contêiner sai pelo pátio no nível 3 (escolha do Bruno), e o
# pesqueiro serve num turno, logo nunca chega aqui.
#
# Todo quadro nasce no mesmo ponto — à frente da pilha —, e quem anda é o nó,
# como no andar da `075`. O FIM do caminho não está escrito aqui: são as
# portas de trás do camião que o `Main` encostou (`camiao_no_berco()`), e é
# por isso que três docas e oito camiões não precisam de um número cada.
const CARGAS_AO_OMBRO := {
	"caixa": preload("res://art/props/carga_caixa.png"),
	"saco": preload("res://art/props/carga_saco.png"),
}
# ⚠️ ONDE ELE ENTREGA NÃO ESTÁ AQUI: são as PORTAS DE TRÁS do camião, que
# encosta de ré com elas viradas para o píer (escolha do Bruno, `077`), e é o
# `Main` que as lê no desenho do camião que parou (`portas_do_camiao()`). A
# primeira versão entregava no flanco, com um ponto escrito aqui: na doca 2 o
# flanco fica no corredor atrás do armazém, e ele saía pintado por cima do
# prédio (o D40 mediu 117 px).
# O passo da `075`: 23,6 px de tela em 2,2 s, a 8 poses por segundo.
const ANDAR_PX_POR_SEG := 10.7
const POSES_POR_SEG := 8.0
# As pausas nas pontas: a apanhar a carga na pilha, a entregá-la no camião.
const PAUSA_PEGA := 0.5
const PAUSA_ENTREGA := 0.5
const _PASSOS := [0, 1, 2, 1]


## O passo da ida no instante `t`, para um trecho de `trecho` segundos: o
## sentido ("leva", de costas com a carga, ou "volta"), o quadro do passo, a
## fração do caminho andada e se a carga vai ao ombro. Aritmética pura, como
## a do guindaste: o teste pergunta-lhe o ciclo inteiro sem esperar frames.
static func pose_da_ida(t: float, trecho: float) -> Dictionary:
	t = fposmod(t, duracao_da_ida(trecho))
	var passo: int = _PASSOS[int(t * POSES_POR_SEG) % _PASSOS.size()]
	if t < PAUSA_PEGA:
		return {"sentido": "leva", "passo": 1, "fracao": 0.0, "carga": true}
	t -= PAUSA_PEGA
	if t < trecho:
		return {"sentido": "leva", "passo": passo, "fracao": t / trecho, "carga": true}
	t -= trecho
	if t < PAUSA_ENTREGA:
		return {"sentido": "leva", "passo": 1, "fracao": 1.0, "carga": true}
	t -= PAUSA_ENTREGA
	return {"sentido": "volta", "passo": passo, "fracao": 1.0 - t / trecho,
		"carga": false}


static func duracao_da_ida(trecho: float) -> float:
	return PAUSA_PEGA + trecho + PAUSA_ENTREGA + trecho


# ── O PÓRTICO DO NÍVEL 3 E A EMPILHADEIRA (03/10, `docs/decisoes/079`) ──
#
# Escolhas do Bruno: no nível 3 o PÓRTICO tira a carga do barco e pousa-a num
# pallet a meio do cais, e o trabalhador alocado leva o pallet de EMPILHADEIRA
# pelo comprimento do píer até à pilha da raiz — ou ao camião, se ele estiver
# encostado. Os dois trabalham ao mesmo tempo, o serviço inteiro: com o
# pórtico, ~72% dos serviços do nível 3 duram um turno, e o «primeiro
# descarrega, depois leva» do n2 quase não aconteceria. O contêiner fica como
# no n2 — pousa no cais —, e a empilhadeira espera, com ele ao volante.
#
# O ciclo do pórtico é o do n1 e do n2, pelos MESMOS nomes do `CICLO_N1`: o
# passo «pilha» é aqui o pouso, a meio do cais. O gerador gira a lança do
# porão ao pouso e recolhe o carro ao longo dela.
const LANCA_N3 := {
	"g0": preload("res://art/props/lanca_n3.png"),
	"g1": preload("res://art/props/lanca_n3_g1.png"),
	"g2": preload("res://art/props/lanca_n3_g2.png"),
	"g3": preload("res://art/props/lanca_n3_g3.png"),
	"g4": preload("res://art/props/lanca_n3_g4.png"),
	"g5": preload("res://art/props/lanca_n3_g5.png"),
	"g6": preload("res://art/props/lanca_n3_g6.png"),
}

# O spreader em BAIXO, nas duas pontas, por tipo. O passo chama-se «pilha»
# como no ciclo, e o quadro «pouso», que é o que ele é no n3.
const PONTAS_N3 := {
	"peixe": {
		"barco": preload("res://art/props/lanca_n3_barco_peixe.png"),
		"pilha": preload("res://art/props/lanca_n3_pouso_peixe.png"),
	},
	"caixa": {
		"barco": preload("res://art/props/lanca_n3_barco_caixa.png"),
		"pilha": preload("res://art/props/lanca_n3_pouso_caixa.png"),
	},
	"saco": {
		"barco": preload("res://art/props/lanca_n3_barco_saco.png"),
		"pilha": preload("res://art/props/lanca_n3_pouso_saco.png"),
	},
	"conteiner": {
		"barco": preload("res://art/props/lanca_n3_barco_conteiner.png"),
		"pilha": preload("res://art/props/lanca_n3_pouso_conteiner.png"),
	},
}

# A carga pendurada do spreader, por tipo e por passo: o pallet em quatro
# cintas, ou o contêiner preso nas travas. Nasce no quadro do PÍER.
const LINGADAS_N3 := {
	"peixe": {
		"barco": preload("res://art/props/lingada_n3_peixe_barco.png"),
		"g0": preload("res://art/props/lingada_n3_peixe_g0.png"),
		"g1": preload("res://art/props/lingada_n3_peixe_g1.png"),
		"g2": preload("res://art/props/lingada_n3_peixe_g2.png"),
		"g3": preload("res://art/props/lingada_n3_peixe_g3.png"),
		"g4": preload("res://art/props/lingada_n3_peixe_g4.png"),
		"g5": preload("res://art/props/lingada_n3_peixe_g5.png"),
		"g6": preload("res://art/props/lingada_n3_peixe_g6.png"),
		"pilha": preload("res://art/props/lingada_n3_peixe_pouso.png"),
	},
	"caixa": {
		"barco": preload("res://art/props/lingada_n3_caixa_barco.png"),
		"g0": preload("res://art/props/lingada_n3_caixa_g0.png"),
		"g1": preload("res://art/props/lingada_n3_caixa_g1.png"),
		"g2": preload("res://art/props/lingada_n3_caixa_g2.png"),
		"g3": preload("res://art/props/lingada_n3_caixa_g3.png"),
		"g4": preload("res://art/props/lingada_n3_caixa_g4.png"),
		"g5": preload("res://art/props/lingada_n3_caixa_g5.png"),
		"g6": preload("res://art/props/lingada_n3_caixa_g6.png"),
		"pilha": preload("res://art/props/lingada_n3_caixa_pouso.png"),
	},
	"saco": {
		"barco": preload("res://art/props/lingada_n3_saco_barco.png"),
		"g0": preload("res://art/props/lingada_n3_saco_g0.png"),
		"g1": preload("res://art/props/lingada_n3_saco_g1.png"),
		"g2": preload("res://art/props/lingada_n3_saco_g2.png"),
		"g3": preload("res://art/props/lingada_n3_saco_g3.png"),
		"g4": preload("res://art/props/lingada_n3_saco_g4.png"),
		"g5": preload("res://art/props/lingada_n3_saco_g5.png"),
		"g6": preload("res://art/props/lingada_n3_saco_g6.png"),
		"pilha": preload("res://art/props/lingada_n3_saco_pouso.png"),
	},
	"conteiner": {
		"barco": preload("res://art/props/lingada_n3_conteiner_barco.png"),
		"g0": preload("res://art/props/lingada_n3_conteiner_g0.png"),
		"g1": preload("res://art/props/lingada_n3_conteiner_g1.png"),
		"g2": preload("res://art/props/lingada_n3_conteiner_g2.png"),
		"g3": preload("res://art/props/lingada_n3_conteiner_g3.png"),
		"g4": preload("res://art/props/lingada_n3_conteiner_g4.png"),
		"g5": preload("res://art/props/lingada_n3_conteiner_g5.png"),
		"g6": preload("res://art/props/lingada_n3_conteiner_g6.png"),
		"pilha": preload("res://art/props/lingada_n3_conteiner_pouso.png"),
	},
}

# A CARGA NO GARFO, no ponto de pouso: «baixo» é a que o spreader larga no
# chão e a que entra na pilha; «alto» é a que anda. O nó `Carga` mostra a de
# baixo enquanto ela espera no chão, e a empilhadeira apanha a MESMA imagem —
# a troca de nó não se vê.
const GARFO_N3 := {
	"peixe": {
		"baixo": preload("res://art/props/carga_n3_peixe_baixo.png"),
		"alto": preload("res://art/props/carga_n3_peixe_alto.png"),
	},
	"caixa": {
		"baixo": preload("res://art/props/carga_n3_caixa_baixo.png"),
		"alto": preload("res://art/props/carga_n3_caixa_alto.png"),
	},
	"saco": {
		"baixo": preload("res://art/props/carga_n3_saco_baixo.png"),
		"alto": preload("res://art/props/carga_n3_saco_alto.png"),
	},
}

# A pilha: a dos pallets na raiz, com o da FRENTE no sítio exato onde a
# empilhadeira larga o dela; a do contêiner no ponto de pouso, como no n2.
const PILHAS_N3 := {
	"peixe": preload("res://art/props/pilha_n3_peixe.png"),
	"caixa": preload("res://art/props/pilha_n3_caixa.png"),
	"saco": preload("res://art/props/pilha_n3_saco.png"),
	"conteiner": preload("res://art/props/pilha_n3_conteiner.png"),
}

# A EMPILHADEIRA, no quadro do píer, com o pallet dela no ponto de pouso:
# parada e sem ninguém, e por sexo com o garfo em baixo e levantado. Quem a
# anda é o nó, como o andar da `075`.
const EMPILHADEIRA_N3 := preload("res://art/props/empilhadeira_n3.png")
const QUADROS_EMPILHADEIRA := {
	"h": {
		"baixo": preload("res://art/props/emp_h_baixo.png"),
		"alto": preload("res://art/props/emp_h_alto.png"),
	},
	"m": {
		"baixo": preload("res://art/props/emp_m_baixo.png"),
		"alto": preload("res://art/props/emp_m_alto.png"),
	},
}

# OS TEMPOS DA EMPILHADEIRA, a contar do instante em que o spreader larga o
# pallet no pouso (o começo do passo «pilha»). Ela espera atrás do pouso,
# encosta, levanta o garfo, leva, pousa na pilha e volta de ré — e tem de estar
# outra vez à espera antes de o pallet seguinte começar a descer.
const N3_ENCOSTA := 0.40
const N3_LEVANTA := 0.25
const N3_POUSA := 0.25
## A velocidade dela, em px de tela por segundo. Até à pilha são ~25 px, e a
## ida e a volta cabem no ciclo do pórtico com folga. Até ao camião são 80 a
## 88 px (medido pelo D42 com as oito transportadoras), e ela acelera até ao
## TETO; o que ainda não couber abranda o ciclo inteiro, pórtico incluído.
## ⚠️ SEM O TETO ELA ANDAVA A 52 px/s, ~43 km/h na régua — o D42 mediu-o na
## primeira versão, que só acelerava. O camião encosta pouco, e o pórtico mais
## lento nessas voltas lê-se menos do que uma empilhadeira a voar.
const EMPILHADEIRA_PX_POR_SEG := 20.0
const EMPILHADEIRA_PX_POR_SEG_MAX := 36.0
## Onde ela espera, contra o ponto em que apanha o pallet: 0,45 de mundo
## para trás, em `+mx` — (Δmx − Δmy)·20 e (Δmx + Δmy)·10 na tela. O pallet
## desce à frente dela sem lhe tocar no garfo, e a traseira dela fica longe
## da casa de máquinas do pórtico.
const ESPERA_N3 := Vector2(9.0, 4.5)


## O instante do ciclo em que o spreader larga a carga: o começo do passo
## «pilha». Sai da tabela, e não de um número.
static func instante_da_solta() -> float:
	var t := 0.0
	for passo in CICLO_N1:
		if String(passo[0]) == "pilha":
			return t
		t += float(passo[1])
	return t


## A janela que a empilhadeira tem para ir e voltar: o ciclo, menos o que ela
## gasta parada nas pontas, menos o passo em que o pallet seguinte desce
## («pilha_c») — nele ela já tem de estar à espera.
static func janela_n3() -> float:
	var desce := 0.0
	for passo in CICLO_N1:
		if String(passo[0]) == "pilha_c":
			desce = float(passo[1])
	return duracao_do_ciclo() - desce - N3_ENCOSTA - N3_LEVANTA - N3_POUSA


## O passo do degrau 3 no instante `t`: o do pórtico — o mesmo ciclo do n2,
## pelos mesmos nomes — e o da empilhadeira, para um trecho de ida de `leva`
## segundos e um de volta de `volta`. `trecho` diz onde ela está (espera,
## encosta, levanta, leva, pousa, volta) e `fracao` quanto dele andou; `chao`
## diz que o pallet largado espera no pouso, e `leva` que vai no garfo.
## Aritmética pura, como a do n1: o teste pergunta-lhe o ciclo inteiro sem
## esperar frames.
static func pose_n3(t: float, leva: float, volta: float) -> Dictionary:
	t = fposmod(t, duracao_do_ciclo())
	var g := pose_n2(t)
	var r := {"lanca": g["lanca"], "carga": g["carga"], "chao": false,
		"trecho": "espera", "fracao": 0.0, "garfo": "baixo", "leva": false}
	var e := fposmod(t - instante_da_solta(), duracao_do_ciclo())
	if e < N3_ENCOSTA:
		r["trecho"] = "encosta"
		r["fracao"] = e / N3_ENCOSTA
		r["chao"] = true
		return r
	e -= N3_ENCOSTA
	if e < N3_LEVANTA:
		r["trecho"] = "levanta"
		r["leva"] = true
		return r
	e -= N3_LEVANTA
	if e < leva:
		r["trecho"] = "leva"
		r["fracao"] = e / leva
		r["garfo"] = "alto"
		r["leva"] = true
		return r
	e -= leva
	if e < N3_POUSA:
		r["trecho"] = "pousa"
		r["fracao"] = 1.0
		r["leva"] = true
		return r
	e -= N3_POUSA
	if e < volta:
		r["trecho"] = "volta"
		r["fracao"] = e / volta
	return r


## O passo do ciclo no instante `t`: o quadro do pau e o do operador. É
## aritmética pura, e de propósito: o teste pergunta-lhe o ciclo inteiro sem
## esperar um frame, e o tween só a aplica.
static func pose_do_guindaste(t: float) -> Dictionary:
	t = fposmod(t, duracao_do_ciclo())
	var operador := int(t / OPERADOR_SEG) % 2
	for passo in CICLO_N1:
		if t < float(passo[1]):
			return {"lanca": String(passo[0]), "operador": operador}
		t -= float(passo[1])
	return {"lanca": String(CICLO_N1[-1][0]), "operador": operador}


static func duracao_do_ciclo() -> float:
	var total := 0.0
	for passo in CICLO_N1:
		total += float(passo[1])
	return total


## O sexo de quem está alocado, pelo rosto dele: "h" ou "m".
static func sexo_do_trabalhador(worker_id: int) -> String:
	var w = GameState._find_worker(worker_id)
	return Retratos.sexo_do_rosto(int(w["rosto"]))


## Em que PORTE cai um contrato de `valor` nesta classe, entre `portes` faixas.
##
## ⚠️ A FAIXA INTEIRA DA CLASSE DIVIDIDA EM PARTES IGUAIS, e o `+ 1` não é
## enfeite: `randi_range` é fechado nas duas pontas, então entre `valor_min` e
## `valor_max` há `max - min + 1` inteiros. Sem ele o valor máximo cairia
## sozinho numa faixa a mais, que ficaria alcançável por UM valor em dezasseis
## mil — um porte gerado, validado e praticamente sem uso, que é a forma exata
## do buraco do `barco_medio`. O bloco D17 percorre a faixa e exige que todos
## os portes sejam alcançáveis.
static func porte_do_barco(classe: String, valor: int, portes: int) -> int:
	if portes <= 1:
		return 0
	var dados: Dictionary = GameState.CLASSES_DE_NAVIO[classe]
	var vmin: int = int(dados["valor_min"])
	var vmax: int = int(dados["valor_max"])
	@warning_ignore("integer_division")
	var faixa: int = ((valor - vmin) * portes) / (vmax - vmin + 1)
	return clampi(faixa, 0, portes - 1)


## O casco deste navio. Acesso DIRETO nos dois primeiros níveis: uma classe sem
## casco, ou um motivo que a classe possa sortear e para o qual não haja convés
## desenhado, têm de rebentar aqui e não desenhar o barco errado calados.
static func arte_do_barco(classe: String, motivo: String, valor: int) -> Texture2D:
	var portes: Array = CASCOS[classe][motivo]
	return portes[porte_do_barco(classe, valor, portes.size())]

var dock_index: int = -1

# ── ANIMAÇÃO ──
# O barco, a lança e o realce são Tween sobre os sprites que já existem: o
# balanço dá vida ao barco parado, a chegada explica de onde ele veio, e o
# realce aponta o berço onde o próximo barco ao largo vai atracar. O trabalhador
# do nível 1 é o único que anda por QUADROS (`QUADROS_TRABALHADOR`, `075`).
const BALANCO_PX := 5.0
const BALANCO_SEG := 1.7
## A chegada e a partida do barco, na virada do dia (`078`). A partida
## acelera para fora (`EASE_IN`) onde a chegada trava (`EASE_OUT`): quem sai
## ganha velocidade, quem chega encosta devagar. Eram 0,5 s cada, e o Bruno
## achou-as rápidas no GIF; 0,8 s foi o que a opção dele propunha.
const CHEGADA_SEG := 0.8
const PARTIDA_SEG := 0.8
## A fração do trajeto em que o barco fica transparente: só a PONTA de fora —
## os últimos 30% da partida e os primeiros 30% da chegada. No primeiro GIF ele
## esmaecia o trajeto inteiro e passava pela frente do píer e das gruas meio
## transparente: «barco parece fantasma». Opaco, ele lê como casco que sai.
const ESMAECER := 0.3
## De onde o barco vem e para onde vai: a FAIXA DO BERÇO, ao longo do píer,
## para o largo — abaixo e à direita na tela. O casco atraca do lado de baixo
## do píer com a proa para o mar, e assim sai de proa e entra de ré pelo mesmo
## lado. ⚠️ A chegada antiga usava `(90, -45)`, para cima e à direita, e esse
## rumo ATRAVESSA O TABUADO (o `Barco` desenha-se depois do `Pier`): ninguém o
## viu porque aquela chegada nunca correu. Viu-se na primeira foto da partida.
const RUMO_DO_MAR := Vector2(90, 45)
const PULSO_SEG := 0.9
const REALCE := Color(1.45, 1.22, 0.72)

var _barco_base := Vector2.ZERO
var _trabalhador_base := Vector2.ZERO
var _barco_id_anterior: int = -1
var _tw_balanco: Tween
# A TROCA DE BARCO: a partida do que estava e a chegada do seguinte, em fila,
# num tween só (`078`). `_barco_alvo` é a arte em que ela vai acabar.
var _tw_troca: Tween
var _barco_alvo: Texture2D = null
# A primeira vista não anima: o porto que se abre (partida nova, save
# carregado) mostra os barcos onde estão. Daí em diante toda troca anima.
var _vista_feita := false
var _tw_realce: Tween
var _tw_trabalho: Tween
var _tw_lanca: Tween
# O que o trabalhador está a fazer, numa string. O `refresh()` corre a cada
# turno, compra e alocação, e recomeçar o tween a cada uma teletransportava-o
# de volta ao barco a meio do caminho; com a mesma assinatura, ele continua.
var _assinatura_trabalho := ""
var _quadros: Dictionary = {}
# O tipo de carga do serviço que o guindaste do n2 está a descarregar, e o
# sexo de quem lá está — o que o aviso do camião precisa para rearmar a ida.
var _tipo_n2 := ""
var _sexo_n2 := "h"
# As portas de trás do camião encostado no berço desta doca, em coordenada da
# doca, ou `null`. Quem as escreve é o `Main`, que é quem encosta o camião
# (`077`).
var _camiao: Variant = null
# O caminho da ida ao camião, dos pés dele à entrada, em coordenada de tela.
var _caminho_ida := Vector2.ZERO
var _trecho_ida := 1.0
# O degrau 3 (`079`): o tipo e o sexo do serviço, o caminho do pouso à
# entrega (a pilha ou o camião), os dois trechos dele, e onde a empilhadeira
# repousa no nó. `_ocupada` diz que alguém trabalha nesta doca — no n3 ele vai
# na empilhadeira, e o nó do trabalhador fica escondido.
var _tipo_n3 := ""
var _destino_n3 := Vector2.ZERO
var _leva_n3 := 1.0
var _volta_n3 := 1.0
var _t_n3 := 0.0
# Quanto o ciclo do n3 se estica quando o caminho não cabe ao teto (1 = não).
var _escala_n3 := 1.0
var _emp_base := Vector2.ZERO
var _ocupada := false

@onready var _pier: TextureRect = $Pier
@onready var _barco: TextureRect = $Barco
@onready var _trabalhador_prop: TextureRect = $Trabalhador
@onready var _pilha: TextureRect = $Pilha
@onready var _lanca: TextureRect = $Lanca
@onready var _carga: TextureRect = $Carga
@onready var _ombro: TextureRect = $Trabalhador/Ombro
@onready var _empilhadeira: TextureRect = $Empilhadeira
@onready var _garfo: TextureRect = $Garfo


func setup(index: int) -> void:
	dock_index = index
	# setup() pode ser chamado antes de a cena entrar na árvore, quando os
	# @onready ainda são null. Nesse caso o refresh acontece no _ready().
	if is_node_ready():
		refresh()


func _ready() -> void:
	# Guardar a posição de repouso é obrigatório: num Control o `position` É o
	# offset, então zerá-lo não "volta ao lugar" — atira o nó para o canto do
	# pai e apaga a ancoragem da cena.
	_barco_base = _barco.position
	_trabalhador_base = _trabalhador_prop.position
	_emp_base = _empilhadeira.position
	if dock_index >= 0:
		refresh()


## O camião do serviço encostou no berço desta doca — `ancora` é o chão à
## frente das portas de trás dele, em coordenada da doca — ou largou-o
## (`null`). Chamada pelo `Main`, no instante em que um ou outro acontece.
##
## ⚠️ NÃO REFRESCA A DOCA INTEIRA: o camião só mexe na ida ao camião, e só
## quando ela está armada — o segundo turno de um serviço do n2. O `refresh()`
## releria o barco todo a cada manobra do trânsito; com os barcos de ensaio do
## D35, que só trazem o que o trânsito lê, rebentava no `value` do casco.
func camiao_no_berco(ancora: Variant) -> void:
	_camiao = ancora
	if _assinatura_trabalho.begins_with("n2|false|"):
		_animar_n2(false, _sexo_n2, _tipo_n2)
	elif _assinatura_trabalho.begins_with("n3|"):
		_animar_n3(_sexo_n2, _tipo_n3)


func esta_construida() -> bool:
	return dock_index >= 0 and dock_index < GameState.docks.size()


func refresh() -> void:
	if dock_index < 0:
		return
	_ocupada = false
	_refresh_cena()
	_vista_feita = true
	# Toda saída do `_refresh_cena()` que não põe ninguém a trabalhar para-o
	# aqui, num sítio só: são quatro `return` antes disso, e a pilha esquecida
	# num deles ficaria no tabuado de uma doca vazia.
	if not _ocupada:
		_parar_trabalho()


func _refresh_cena() -> void:
	_trabalhador_prop.visible = false
	# O REALCE APONTA O BERÇO QUE O PRÓXIMO TOQUE ENCHE (`083`). Apontava a
	# doca para o trabalhador escolhido, e a escolha passou para a fila: tocar
	# num barco ao largo atraca-o no primeiro berço livre, e é esse que acende.
	_acender_realce(GameState.atracagem_pendente() != Vector2i.ZERO
		and GameState.berco_livre() == dock_index)

	# A lança só existe onde há píer: numa vaga por construir há só estacas.
	# ⚠️ E COM O PAU-DE-CARGA A TRABALHAR ELA NÃO VARRE NEM VOLTA AO REPOUSO:
	# quem lhe escolhe o quadro é o ciclo (`_aplicar_guindaste`). Este
	# `refresh()` corre a cada turno e alocação, e repor a textura aqui pô-la
	# um frame em repouso a meio do giro.
	var opera := _guindaste_opera()
	_mostrar_lanca(esta_construida(), not opera)

	# Dois níveis independentes: o guindaste é do `guindaste`, a laje é do
	# `cais`. Uma leitura só faria o jogador ver mudar o que não comprou.
	var nivel_lanca: int = int(GameState.nivel_guindaste())
	var nivel_pier: int = int(GameState.nivel_pier())
	if not opera:
		_lanca.texture = ArteLanca[nivel_lanca - 1]
	# A empilhadeira é do cais do nível 3 (`079`): parada à espera, sem
	# ninguém, enquanto a doca não trabalha.
	_empilhadeira.visible = esta_construida() and nivel_lanca == 3
	if not esta_construida():
		_pier.texture = ArtePierVazio
		_mostrar_barco(-1, null)
		return

	# A base do guindaste está embutida no PNG do píer. Com madeira, usar
	# o n2 deixava a lança de pau sobre uma torre metálica (`086`). O conjunto
	# n1 aprovado mantém a Fase 1 coerente sem repintar arte ou mudar vagas.
	_pier.texture = ArtePier[0 if nivel_lanca == 1 else nivel_pier - 1]
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_mostrar_barco(-1, null)
		return

	_mostrar_barco(int(boat["id"]), arte_do_barco(String(boat["classe"]),
		String(boat["motivo"]), int(boat["value"])))

	if boat.get("rival", false) and not boat.get("matched", false):
		return

	if dock["worker_id"] != null:
		# QUEM ALOCA A MEIO DA CHEGADA ENCOSTA O BARCO JÁ. O guindaste
		# descarrega do porão no berço, e com o casco ainda a deslizar a
		# carga sairia da água ao lado dele.
		concluir_troca()
		_ocupada = true
		var sexo := sexo_do_trabalhador(int(dock["worker_id"]))
		# No nível 3 ele vai na EMPILHADEIRA, e o pórtico descarrega o
		# serviço inteiro (`079`). Acesso DIRETO à tabela, como no n2.
		if nivel_lanca == 3:
			_animar_n3(sexo, tipo_de_carga(String(boat["classe"]),
				String(boat["motivo"])))
			return
		# A figura no tabuado é o que faz "doca ocupada" ler sem texto.
		_trabalhador_prop.visible = true
		# No nível 2 o guindaste descarrega no PRIMEIRO turno do serviço, e
		# a pilha fica no tabuado o serviço inteiro (`077`). Acesso DIRETO à
		# tabela, como no casco: um par sem tipo de carga rebenta aqui.
		if nivel_lanca == 2:
			_animar_n2(int(boat["progress"]) == 0, sexo,
				tipo_de_carga(String(boat["classe"]), String(boat["motivo"])))
			return
		var pilha: Texture2D = null
		# Acesso DIRETO à tabela no nível 1, como no casco: uma classe que o
		# nível 1 receba sem pilha desenhada tem de rebentar aqui, e não
		# deixar o guindaste parado calado.
		if opera:
			pilha = PILHAS_N1[String(boat["classe"])][String(boat["motivo"])]
		_animar_trabalho(int(boat["progress"]) > 0, sexo, pilha)


## O guindaste a descarregar: há píer, barco que é nosso e trabalhador nele.
## É a mesma condição que mostra o trabalhador, lida antes, porque a lança é
## decidida antes dele. No nível 1 trabalha o serviço inteiro (o pesqueiro
## serve num turno); no 2 só no PRIMEIRO turno do serviço — depois o
## guindaste pára e a vez é do trabalhador (`077`). No 3 o pórtico trabalha o
## serviço inteiro, ao mesmo tempo que a empilhadeira (`079`).
func _guindaste_opera() -> bool:
	var nivel := int(GameState.nivel_guindaste()) if esta_construida() else 0
	if nivel < 1 or nivel > 3:
		return false
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]
	if boat == null or dock["worker_id"] == null:
		return false
	if boat.get("rival", false) and not boat.get("matched", false):
		return false
	return nivel != 2 or int(boat["progress"]) == 0


# O píer também é alvo de toque, como o cartão: devolve o barco ao largo
# enquanto a operação não começou (`083`). Até lá recebia o trabalhador
# arrastado da fileira, que deu o lugar à fila.
func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not esta_construida():
		return
	if GameState.docks[dock_index]["boat"] != null:
		GameState.desatracar(dock_index)
		accept_event()


# ── as animações ──
## O BARCO QUE A DOCA MOSTRA, e a troca até ele (`078`). Até 03/10 o barco
## servido sumia de um quadro para o outro e o seguinte aparecia no lugar: a
## chegada deslizante estava escrita e NUNCA corria, porque a virada esvazia a
## doca (`turn_advanced`) antes de a encher (`boats_spawned`), o esvaziar
## zerava o id, e a chegada só deslizava quando havia um barco ANTERIOR.
## Medido em 24 viradas: 21 barcos novos, zero chegadas.
##
## Agora a troca é uma fila: o barco que está na água parte pelo
## `RUMO_DO_MAR`, e só então entra o seguinte, pelo mesmo lado. Pedir outra
## troca a meio refaz a fila a partir de onde o casco ESTÁ — é o que acontece
## em toda virada, com o esvaziar e o encher no mesmo quadro: o segundo
## pedido encontra o barco velho ainda no berço e parte com ele.
func _mostrar_barco(barco_id: int, textura: Texture2D) -> void:
	if barco_id == _barco_id_anterior:
		return                      # mesmo barco: já está balançando
	_barco_id_anterior = barco_id
	_barco_alvo = textura
	for tw in [_tw_troca, _tw_balanco]:
		if tw != null and tw.is_valid():
			tw.kill()

	var na_agua := _barco.texture != null and _barco.modulate.a > 0.0
	if not _vista_feita or (not na_agua and textura == null):
		_pousar_barco(textura)
		return

	_tw_troca = create_tween()
	if na_agua:
		_tw_troca.tween_property(_barco, "position", _barco_base + RUMO_DO_MAR,
			PARTIDA_SEG).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_tw_troca.parallel().tween_property(_barco, "modulate:a", 0.0,
			PARTIDA_SEG * ESMAECER).set_delay(PARTIDA_SEG * (1.0 - ESMAECER))
	if textura == null:
		_tw_troca.tween_callback(_pousar_barco.bind(null))
		return
	_tw_troca.tween_callback(_entrar_barco.bind(textura))
	_tw_troca.tween_property(_barco, "position", _barco_base, CHEGADA_SEG) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw_troca.parallel().tween_property(_barco, "modulate:a", 1.0, CHEGADA_SEG * ESMAECER)
	_tw_troca.tween_callback(_pousar_barco.bind(textura))


## Leva a troca ao fim já: o barco seguinte no berço, a balançar, ou a doca
## vazia. É o que um toque em «Avançar dia» a meio da virada faz (`078`).
func concluir_troca() -> void:
	if _tw_troca == null or not _tw_troca.is_valid():
		return
	_tw_troca.kill()
	_pousar_barco(_barco_alvo)


## O centro do quadro do barco no berço, em coordenada GLOBAL. O quadro de
## 512 tem a origem do mundo no meio, e é aí que o casco está desenhado.
func centro_do_barco() -> Vector2:
	return get_global_transform() * (_barco_base + _barco.size * 0.5)


## A troca de barco ainda está a correr.
func em_troca() -> bool:
	return _tw_troca != null and _tw_troca.is_valid() and _tw_troca.is_running()


func _entrar_barco(textura: Texture2D) -> void:
	_barco.texture = textura
	_barco.position = _barco_base + RUMO_DO_MAR
	_barco.modulate.a = 0.0


func _pousar_barco(textura: Texture2D) -> void:
	_barco.texture = textura
	_barco.position = _barco_base
	_barco.modulate.a = 1.0
	if _tw_balanco != null and _tw_balanco.is_valid():
		_tw_balanco.kill()
	if textura != null:
		_iniciar_balanco()


func _iniciar_balanco() -> void:
	_barco.modulate.a = 1.0
	if _tw_balanco != null and _tw_balanco.is_valid():
		_tw_balanco.kill()
	_tw_balanco = create_tween().set_loops()
	_tw_balanco.tween_property(_barco, "position:y",
		_barco_base.y - BALANCO_PX, BALANCO_SEG).set_trans(Tween.TRANS_SINE)
	_tw_balanco.tween_property(_barco, "position:y",
		_barco_base.y, BALANCO_SEG).set_trans(Tween.TRANS_SINE)


# "Solte aqui": o PRÓPRIO PÍER acende, em vez de uma moldura por cima dele.
# A primeira versão era um retângulo âmbar arredondado sobre a vaga, e num
# cenário isométrico um retângulo alinhado à tela não pertence a nada — lia
# como recorte de interface pousado no mapa. Iluminar o sprite segue a forma
# real do píer e não introduz geometria nova.
#
# Pisca devagar: com três vagas acesas ao mesmo tempo, brilho fixo vira
# decoração e deixa de apontar.
func _acender_realce(ligado: bool) -> void:
	if _tw_realce != null and _tw_realce.is_valid():
		_tw_realce.kill()
	if not ligado:
		_pier.modulate = Color.WHITE
		return
	_tw_realce = create_tween().set_loops()
	_tw_realce.tween_property(_pier, "modulate", REALCE, PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)
	_tw_realce.tween_property(_pier, "modulate", Color.WHITE, PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)


# Enquanto a operação corre, o trabalhador se mexe. Parado, fica de pé.
#
# No nível 1 (`pilha` dada) ele OPERA O GUINCHO: o pau-de-carga corre o
# `CICLO_N1` — do porão à pilha e de volta — e a pilha fica no tabuado. O
# nível 2 e o 3 têm animação própria (`_animar_n2`, `_animar_n3`). O balanço
# de 3 px de sempre fica para quem não tiver pilha.
#
# ⚠️ NO NÍVEL 1 ELE TRABALHA ASSIM QUE É ALOCADO, e não com `progress > 0`,
# que é o «operando» do balanço. O pesqueiro serve num turno só: o `progress`
# chega a 1 no mesmo avanço em que o barco parte, e com ele atracado nunca
# passa de zero. Medido em 20 partidas, 449 instantes de trabalhador alocado a
# um barco no nível 1 e ZERO com `progress > 0` (`075`).
func _animar_trabalho(operando: bool, sexo: String, pilha: Texture2D) -> void:
	var guindaste := pilha != null
	operando = operando or guindaste
	var assinatura := "%s|%s|%s" % [operando, sexo,
		pilha.resource_path if guindaste else ""]
	if assinatura == _assinatura_trabalho and _tw_trabalho != null \
			and _tw_trabalho.is_valid():
		return
	_parar_trabalho()
	_assinatura_trabalho = assinatura
	_quadros = QUADROS_TRABALHADOR[sexo]
	_trabalhador_prop.texture = _quadros["parado"]
	if not operando:
		return
	_tw_trabalho = create_tween().set_loops()
	if guindaste:
		_pilha.texture = pilha
		_pilha.visible = true
		_aplicar_guindaste(0.0)
		_tw_trabalho.tween_method(_aplicar_guindaste, 0.0, duracao_do_ciclo(),
			duracao_do_ciclo())
		return
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y - 3.0, 0.42).set_trans(Tween.TRANS_SINE)
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y, 0.42).set_trans(Tween.TRANS_SINE)


func _aplicar_guindaste(t: float) -> void:
	var p := pose_do_guindaste(t)
	_lanca.texture = LANCA_N1[p["lanca"]]
	_trabalhador_prop.texture = _quadros["guincho"][int(p["operador"])]


# O NÍVEL 2 (`077`). Com `descarrega` — o primeiro turno do serviço — o
# guindaste corre o ciclo e ele, ao pé da pilha, solta o gancho quando a
# lingada pousa. Depois o guindaste pára (o `refresh()` já o pôs a varrer em
# repouso) e ele fica à espera ao pé da pilha; a ida ao camião vem a seguir.
#
# ⚠️ ELE PASSA PARA DEPOIS DA CARGA na ordem dos nós, e só aqui. Está à
# frente da pilha, do lado da câmara, e a lingada pousa atrás dele; com a
# ordem da cena a carga desenhava-se por cima dos braços dele. Nos outros
# níveis ele fica antes do barco, à beira do costado, onde o casco o tapa.
func _animar_n2(descarrega: bool, sexo: String, tipo: String) -> void:
	var assinatura := "n2|%s|%s|%s|%s" % [descarrega, sexo, tipo, _camiao != null]
	if assinatura == _assinatura_trabalho and (not descarrega
			or (_tw_trabalho != null and _tw_trabalho.is_valid())):
		return
	_parar_trabalho()
	_assinatura_trabalho = assinatura
	_quadros = QUADROS_TRABALHADOR[sexo]
	_tipo_n2 = tipo
	_sexo_n2 = sexo
	_pilha.texture = PILHAS_N2[tipo]
	_pilha.visible = true
	move_child(_trabalhador_prop, _carga.get_index())
	_trabalhador_prop.texture = _quadros["pilha"][0]
	if not descarrega:
		if CARGAS_AO_OMBRO.has(tipo):
			_animar_ida(tipo)
		return
	# FASE POR DOCA, como a varrida da lança: com «Alocar todos» as três
	# começam no mesmo frame, e os três guindastes giravam como um mecanismo
	# só — visto no GIF da primeira passagem.
	var fase := duracao_do_ciclo() * float(maxi(dock_index, 0)) / 3.0
	_aplicar_n2(fase)
	_tw_trabalho = create_tween().set_loops()
	_tw_trabalho.tween_method(_aplicar_n2, fase, fase + duracao_do_ciclo(),
		duracao_do_ciclo())


# A IDA AO CAMIÃO: ele espera à frente da pilha, de frente, e com o camião no
# berço leva a carga até às portas de trás dele e volta. O caminho mede-se dos PÉS do
# quadro (o fundo do desenho) ao ponto de entrega, e o trecho dura o que o
# passo da `075` levaria a andá-lo.
func _animar_ida(tipo: String) -> void:
	_trabalhador_prop.texture = _quadros["volta"][1]
	_ombro.texture = CARGAS_AO_OMBRO[tipo]
	if _camiao == null:
		return
	var r := PropIso.desenho(_quadros["leva"][1])
	var pes := _trabalhador_base + Vector2(PropIso.MEIO, PropIso.MEIO) \
		+ Vector2(r.get_center().x, r.end.y)
	_caminho_ida = (_camiao as Vector2) - pes
	_trecho_ida = maxf(_caminho_ida.length() / ANDAR_PX_POR_SEG, 0.1)
	_aplicar_ida(0.0)
	_tw_trabalho = create_tween().set_loops()
	_tw_trabalho.tween_method(_aplicar_ida, 0.0, duracao_da_ida(_trecho_ida),
		duracao_da_ida(_trecho_ida))


func _aplicar_ida(t: float) -> void:
	var p := pose_da_ida(t, _trecho_ida)
	_trabalhador_prop.texture = _quadros[p["sentido"]][int(p["passo"])]
	_trabalhador_prop.position = _trabalhador_base + _caminho_ida * float(p["fracao"])
	_ombro.visible = bool(p["carga"])


func _aplicar_n2(t: float) -> void:
	var p := pose_n2(t)
	var lugar: String = p["lanca"]
	_lanca.texture = LANCA_N2[lugar] if lugar.begins_with("g") \
		else PONTAS_N2[_tipo_n2][lugar]
	_carga.visible = p["carga"] != ""
	if _carga.visible:
		_carga.texture = LINGADAS_N2[_tipo_n2][p["carga"]]
	_trabalhador_prop.texture = _quadros["pilha"][int(p["trabalhador"])]


# O DEGRAU 3 (`079`): o pórtico corre o ciclo de sempre, e a empilhadeira,
# com ele ao volante, apanha cada pallet no pouso e leva-o à pilha da raiz —
# ou às portas de trás do camião, se ele estiver encostado. O contêiner pousa
# no cais como no n2, e ela espera com ele ao volante.
#
# ⚠️ O PALLET NO CHÃO E O PALLET NO GARFO SÃO O MESMO NÓ, `Garfo`, e vem
# ANTES da empilhadeira na ordem da cena: está à frente dela, do lado de
# longe da câmara. Enquanto ela encosta o pallet fica no pouso; depois anda
# com ela. O spreader larga-o no passo «pilha», e é aí que ele aparece.
func _animar_n3(sexo: String, tipo: String) -> void:
	var assinatura := "n3|%s|%s|%s" % [sexo, tipo, _camiao]
	if assinatura == _assinatura_trabalho and _tw_trabalho != null \
			and _tw_trabalho.is_valid():
		return
	# Quem rearma a meio (o camião que encosta ou larga) continua do mesmo
	# instante do ciclo: o pórtico não salta, só o destino dela muda.
	var continua := _assinatura_trabalho.begins_with("n3|%s|%s|" % [sexo, tipo])
	var t0 := _t_n3
	_parar_trabalho()
	_assinatura_trabalho = assinatura
	_tipo_n3 = tipo
	_sexo_n2 = sexo
	_empilhadeira.visible = true
	_pilha.texture = PILHAS_N3[tipo]
	_pilha.visible = true
	if not GARFO_N3.has(tipo):
		# O contêiner: o pórtico pousa-o, ela espera com ele ao volante.
		_empilhadeira.texture = QUADROS_EMPILHADEIRA[sexo]["baixo"]
		_empilhadeira.position = _emp_base + ESPERA_N3
	else:
		_destino_n3 = _destino_da_empilhadeira(tipo)
		var ida := _destino_n3.length()
		var volta := (_destino_n3 - ESPERA_N3).length()
		# Os tempos dela contam-se em tempo do CICLO; esticado, o ciclo corre
		# mais devagar, e ela com ele.
		var v := clampf((ida + volta) / janela_n3(), EMPILHADEIRA_PX_POR_SEG,
			EMPILHADEIRA_PX_POR_SEG_MAX)
		_escala_n3 = maxf(1.0, (ida + volta) / v / janela_n3())
		_leva_n3 = maxf(ida / v / _escala_n3, 0.1)
		_volta_n3 = maxf(volta / v / _escala_n3, 0.1)
	var fase := duracao_do_ciclo() * float(maxi(dock_index, 0)) / 3.0
	if continua:
		fase = t0
	_aplicar_n3(fase)
	_tw_trabalho = create_tween().set_loops()
	_tw_trabalho.tween_method(_aplicar_n3, fase, fase + duracao_do_ciclo(),
		duracao_do_ciclo() * _escala_n3)


## Do ponto onde ela apanha o pallet ao ponto onde o larga, em tela. Sem
## camião é a FRENTE DA PILHA, e não se escreve: o pallet da frente da pilha e
## o do garfo são o mesmo desenho, e o canto de baixo-direita da pilha é o
## dele. Com camião é o chão à frente das portas de trás, que o `Main` lê no
## camião que parou: o CENTRO do pallet pára lá. As portas ficam 0,14 além da
## traseira e o pallet tem 0,17 de meio comprimento, logo a frente dele entra
## pelas portas — a primeira versão parava meio pallet antes, e o D42 mediu-o
## a 0% de camião à volta.
func _destino_da_empilhadeira(tipo: String) -> Vector2:
	var carga := PropIso.desenho(GARFO_N3[tipo]["baixo"])
	if _camiao == null:
		var pilha := PropIso.desenho(PILHAS_N3[tipo])
		return pilha.end - carga.end
	var centro := _emp_base + Vector2(PropIso.MEIO, PropIso.MEIO) + carga.get_center()
	return (_camiao as Vector2) - centro


func _aplicar_n3(t: float) -> void:
	_t_n3 = fposmod(t, duracao_do_ciclo())
	var p := pose_n3(t, _leva_n3, _volta_n3)
	var lugar: String = p["lanca"]
	_lanca.texture = LANCA_N3[lugar] if lugar.begins_with("g") \
		else PONTAS_N3[_tipo_n3][lugar]
	_carga.visible = p["carga"] != ""
	if _carga.visible:
		_carga.texture = LINGADAS_N3[_tipo_n3][p["carga"]]
	if not GARFO_N3.has(_tipo_n3):
		return
	var onde := Vector2.ZERO
	var f: float = p["fracao"]
	match String(p["trecho"]):
		"espera":
			onde = ESPERA_N3
		"encosta":
			onde = ESPERA_N3.lerp(Vector2.ZERO, f)
		"leva", "pousa":
			onde = _destino_n3 * f
		"volta":
			onde = _destino_n3.lerp(ESPERA_N3, f)
	# NO CAMIÃO O GARFO NÃO DESCE: a carga entra pelas portas de trás à
	# altura a que vinha, e some lá dentro. Na pilha ela pousa no chão, no
	# lugar do pallet da frente.
	var garfo: String = p["garfo"]
	if _camiao != null and String(p["trecho"]) == "pousa":
		garfo = "alto"
	_empilhadeira.position = _emp_base + onde
	_empilhadeira.texture = QUADROS_EMPILHADEIRA[_sexo_n2][garfo]
	_garfo.visible = bool(p["chao"]) or bool(p["leva"])
	if _garfo.visible:
		_garfo.texture = GARFO_N3[_tipo_n3][garfo]
		_garfo.position = _emp_base + (onde if p["leva"] else Vector2.ZERO)


func _parar_trabalho() -> void:
	if _tw_trabalho != null and _tw_trabalho.is_valid():
		_tw_trabalho.kill()
	_assinatura_trabalho = ""
	_trabalhador_prop.position = _trabalhador_base
	_pilha.visible = false
	_carga.visible = false
	_ombro.visible = false
	# A empilhadeira volta a esperar, parada e sem ninguém (`079`).
	_escala_n3 = 1.0
	_garfo.visible = false
	_empilhadeira.texture = EMPILHADEIRA_N3
	_empilhadeira.position = _emp_base + ESPERA_N3
	# A ordem da cena de volta: logo depois da pilha, antes do barco.
	if _trabalhador_prop.get_index() != _pilha.get_index() + 1:
		move_child(_trabalhador_prop, _pilha.get_index() + 1)


# A lança do guindaste varre devagar. É o único movimento do porto que não
# depende de haver barco — dá sinal de vida a uma doca vazia.
func _mostrar_lanca(ligado: bool, varre: bool = true) -> void:
	_lanca.visible = ligado
	if _tw_lanca != null and _tw_lanca.is_valid():
		_tw_lanca.kill()
	if not varre:
		# Os quadros do pau-de-carga já trazem o ângulo dentro; a imagem não
		# gira por cima deles.
		_lanca.rotation = 0.0
	if not ligado or not varre:
		return
	# Fase por doca, senão as três varrem como um só mecanismo.
	var fase := 0.9 * float(max(dock_index, 0))
	_tw_lanca = create_tween().set_loops()
	if fase > 0.0:
		_tw_lanca.tween_interval(fase)
	_tw_lanca.tween_property(_lanca, "rotation", 0.13, 3.4).set_trans(Tween.TRANS_SINE)
	_tw_lanca.tween_property(_lanca, "rotation", -0.05, 3.4).set_trans(Tween.TRANS_SINE)
