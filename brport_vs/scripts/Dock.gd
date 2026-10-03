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
# abaixo); no 3 ainda fica de pé, à beira do costado.
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

# Quem está selecionado na fileira de trabalhadores, ou -1. O Main mantém isto
# em dia; a doca só precisa saber para onde mandar o toque.
var trabalhador_selecionado: int = -1

# ── ANIMAÇÃO ──
# O barco, a lança e o realce são Tween sobre os sprites que já existem: o
# balanço dá vida ao barco parado, a chegada explica de onde ele veio, e o
# realce aponta a doca que pode receber o trabalhador escolhido. O trabalhador
# do nível 1 é o único que anda por QUADROS (`QUADROS_TRABALHADOR`, `075`).
const BALANCO_PX := 5.0
const BALANCO_SEG := 1.7
const CHEGADA_SEG := 0.5
const PULSO_SEG := 0.9
const REALCE := Color(1.45, 1.22, 0.72)

var _barco_base := Vector2.ZERO
var _trabalhador_base := Vector2.ZERO
var _barco_id_anterior: int = -1
var _tw_balanco: Tween
var _tw_chegada: Tween
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

@onready var _pier: TextureRect = $Pier
@onready var _barco: TextureRect = $Barco
@onready var _trabalhador_prop: TextureRect = $Trabalhador
@onready var _pilha: TextureRect = $Pilha
@onready var _lanca: TextureRect = $Lanca
@onready var _carga: TextureRect = $Carga
@onready var _ombro: TextureRect = $Trabalhador/Ombro


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


func esta_construida() -> bool:
	return dock_index >= 0 and dock_index < GameState.docks.size()


func refresh() -> void:
	if dock_index < 0:
		return
	_refresh_cena()
	# Toda saída do `_refresh_cena()` que não mostra o trabalhador para-o
	# aqui, num sítio só: são quatro `return` antes dele, e a pilha esquecida
	# num deles ficaria no tabuado de uma doca vazia.
	if not _trabalhador_prop.visible:
		_parar_trabalho()


func _refresh_cena() -> void:
	_trabalhador_prop.visible = false
	# O realce só faz sentido se há alguém escolhido esperando um destino.
	_acender_realce(trabalhador_selecionado >= 0
		and GameState.doca_aceita_trabalhador(dock_index))

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
	if not esta_construida():
		_pier.texture = ArtePierVazio
		_parar_barco()
		_barco.texture = null
		return

	_pier.texture = ArtePier[nivel_pier - 1]
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_parar_barco()
		_barco.texture = null
		return

	_barco.texture = arte_do_barco(String(boat["classe"]), String(boat["motivo"]),
		int(boat["value"]))
	_animar_barco(int(boat["id"]))

	if boat.get("rival", false) and not boat.get("matched", false):
		return

	if dock["worker_id"] != null:
		# A figura no tabuado é o que faz "doca ocupada" ler sem texto.
		_trabalhador_prop.visible = true
		var sexo := sexo_do_trabalhador(int(dock["worker_id"]))
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
## guindaste pára e a vez é do trabalhador (`077`). No 3 ainda não trabalha.
func _guindaste_opera() -> bool:
	var nivel := int(GameState.nivel_guindaste()) if esta_construida() else 0
	if nivel != 1 and nivel != 2:
		return false
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]
	if boat == null or dock["worker_id"] == null:
		return false
	if boat.get("rival", false) and not boat.get("matched", false):
		return false
	return nivel == 1 or int(boat["progress"]) == 0


func _can_drop_data(_at_position: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("worker_id"):
		return false
	return GameState.doca_aceita_trabalhador(dock_index)


func _drop_data(_at_position: Vector2, data) -> void:
	GameState.assign_worker(int(data["worker_id"]), dock_index)


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not esta_construida():
		return

	# Com alguém selecionado na fileira, o toque ALOCA — é o outro lado do
	# toque-para-alocar. Sem seleção, o toque devolve quem está aqui para a
	# fileira, que é como se desfaz um arrasto errado.
	if trabalhador_selecionado >= 0 and GameState.docks[dock_index]["worker_id"] == null:
		GameState.assign_worker(trabalhador_selecionado, dock_index)
		accept_event()
		return

	if GameState.docks[dock_index]["worker_id"] != null:
		GameState.release_worker(dock_index)
		accept_event()


# ── as animações ──
func _parar_barco() -> void:
	_barco_id_anterior = -1
	for tw in [_tw_balanco, _tw_chegada]:
		if tw != null and tw.is_valid():
			tw.kill()
	_barco.position = _barco_base


func _animar_barco(barco_id: int) -> void:
	if barco_id == _barco_id_anterior:
		return                      # mesmo barco: já está balançando
	var era_outro := _barco_id_anterior != -1
	_barco_id_anterior = barco_id

	if _tw_chegada != null and _tw_chegada.is_valid():
		_tw_chegada.kill()
	if _tw_balanco != null and _tw_balanco.is_valid():
		_tw_balanco.kill()

	# Barco novo entra deslizando do lado da zona de espera; o que já estava
	# aqui (ao recarregar um save) simplesmente aparece.
	if not era_outro:
		_barco.position = _barco_base
		_iniciar_balanco()
		return

	_barco.position = _barco_base + Vector2(90, -45)
	_barco.modulate.a = 0.0
	_tw_chegada = create_tween().set_parallel(true)
	_tw_chegada.tween_property(_barco, "position", _barco_base, CHEGADA_SEG) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw_chegada.tween_property(_barco, "modulate:a", 1.0, CHEGADA_SEG * 0.6)
	_tw_chegada.chain().tween_callback(_iniciar_balanco)


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
# nível 2 tem animação própria (`_animar_n2`). No 3, até ter a dele, fica o
# balanço de 3 px de sempre, já com a figura do sexo dele.
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


func _parar_trabalho() -> void:
	if _tw_trabalho != null and _tw_trabalho.is_valid():
		_tw_trabalho.kill()
	_assinatura_trabalho = ""
	_trabalhador_prop.position = _trabalhador_base
	_pilha.visible = false
	_carga.visible = false
	_ombro.visible = false
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
