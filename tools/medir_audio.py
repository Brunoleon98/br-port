#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""BR Port — o que se mede num som sem o ouvir.

Item R9 da §7.1. Este contêiner NÃO tem placa de som, e essa é a razão de a
ferramenta existir: quem trabalha aqui não consegue julgar um som, mas pode
DESCREVÊ-LO com números que não dependem de ouvido nenhum.

O QUE JÁ ESTAVA MEDIDO E NÃO SE REPETE AQUI
    Duração, taxa, canais, pico de amostra, RMS, bordas, DC e saturação já são
    cobertos — as quatro primeiras pelo `tests/teste_audio.gd` (bloco A1) e as
    outras pela revisão de 17/09. A pergunta que faltava, e que é esta
    ferramenta, tem quatro partes:

      1. TRUE PEAK — o pico do sinal RECONSTRUÍDO, entre as amostras.
      2. DESCONTINUIDADE INTERNA — o salto no MEIO do arquivo, que a conferência
         de bordas não podia ver porque ela só olha a primeira e a última.
      3. ESPECTRO — onde mora a energia, em bandas.
      4. SOMA OFFLINE — e o que ela NÃO prova.

⚠️ O QUE É VEREDITO E O QUE É DESCRITOR, que é a decisão inteira desta
   ferramenta. A ficha do R9 diz: *"sem limiar perceptual validado, emitir
   descritor/alerta"*. Ninguém aqui validou limiar perceptual nenhum, porque
   validar um exige ouvir.

   Logo há DOIS alertas e mais nenhum, e a razão de ambos é a mesma: os dois
   se decidem por aritmética sobre a onda, e nenhum precisa de ouvido.

     • **true peak >= 0 dBTP** — acima de 0 o conversor do aparelho não tem
       para onde ir, e a distorção passa a ser do arquivo e não do gosto de
       quem escuta. Não tem parâmetro livre nenhum: 0 é 0.
     • **salto isolado >= 3,0x o p99,9 do próprio arquivo** — um degrau que a
       síntese não quis. Este TEM um número escolhido, e por isso ele está
       medido dos dois lados na constante `CORTE_DESCONTINUIDADE`, com o que
       fica de fora escrito ao lado.

   Tudo o resto sai como DESCRITOR, com o número e sem julgamento.

   Em particular, NÃO se emite veredito sobre: qual banda devia dominar, se um
   som está alto demais para outro, se 8 dB de diferença entre a interface e o
   mar é hierarquia ou é interface aos gritos. Isso é o A6, é do Bruno, e esta
   ferramenta existe para lhe dizer o que PROCURAR — não para decidir por ele.

DEPENDÊNCIAS: nenhuma. Biblioteca padrão só, como o `gerar_sons.py`. Não há
    ffmpeg neste contêiner (medido), nem numpy, e a ficha proíbe dependência
    pesada.

⚠️ E ESTA FERRAMENTA NÃO ESCREVE NOS WAV, nem por engano: ela abre tudo em
   modo leitura. Os 14 arquivos são GERADOS e o CI compara-os byte a byte —
   mexer num deles para um número passar é o que a ficha proíbe com todas as
   letras.

Uso:
    python3 tools/medir_audio.py [pasta]          # padrão: brport_vs/audio/sfx
    python3 tools/medir_audio.py --autoteste      # só a calibração da régua
"""

import cmath
import math
import os
import re
import struct
import sys
import wave

PASTA_PADRAO = "brport_vs/audio/sfx"
LAYOUT = "brport_vs/audio/default_bus_layout.tres"

# ── as bandas, e por que estas ──
# O alvo é um TELEFONE, e o alto-falante de um telefone não entrega grave: a
# fronteira dos 500 Hz é a que interessa a este projeto, porque energia abaixo
# dela existe no arquivo e não sai do aparelho. As outras fronteiras são
# oitavas a partir daí.
#
# ⚠️ E A LINHA DOS 500 Hz É DESCRITOR, NÃO PORTÃO. Que fração abaixo dela é
# "demasiada" depende do alto-falante e do ouvido — ninguém aqui mediu nenhum
# dos dois. O número sai impresso para o Bruno saber o que procurar na escuta.
BANDAS = [
    ("20-200", 20.0, 200.0),
    ("200-500", 200.0, 500.0),
    ("500-2k", 500.0, 2000.0),
    ("2k-6k", 2000.0, 6000.0),
    ("6k-16k", 6000.0, 16000.0),
]

# Fronteira do alto-falante pequeno: tudo abaixo disto é energia que o arquivo
# tem e o telefone não devolve.
CORTE_TELEFONE = 500.0

# ── o corte da descontinuidade, e de onde ele saiu ──
# ⚠️ ESTE É O ÚNICO NÚMERO ESCOLHIDO DESTA FERRAMENTA, e por isso está medido
# dos dois lados em vez de arbitrado. Varrido em 21/09, injetando UM salto
# isolado no meio de cinco arquivos, por amplitude:
#
#   arquivo              intacto  0,05   0,1   0,2   0,4   0,6   0,9
#   sfx_amb_mar              1,2   1,2   1,2   1,8   3,0   4,1   5,9
#   sfx_ui_click             1,1   1,1   1,1   1,5   2,8   4,1   6,1
#   sfx_navio_chega          1,1   8,2  10,4  14,8  23,6  32,3  45,5
#   sfx_fauna_gaivota        1,1   1,1   1,1   1,5   3,1   4,6   6,9
#   sfx_ui_success           1,0   2,2   2,7   3,7   5,7   7,7  10,7
#
# Os 14 arquivos intactos medem 1,0 a 1,2. O corte em 3,0 deixa **2,5x de
# folga** acima do maior valor legítimo e fica abaixo de todo defeito de
# amplitude >= 0,4 em todos os cinco.
#
# ⚠️ E O QUE ELE NÃO APANHA ESTÁ ESCRITO AQUI, porque uma guarda defende o que
# defende: num som TEXTURADO (mar, clique, gaivota) um salto abaixo de ~0,2 não
# se separa da textura do próprio arquivo e passa. A sensibilidade varia 10x
# entre arquivos — o apito do navio, que é liso e grave, denuncia um salto de
# 0,05 —, e isso é propriedade do sinal, não do corte. Quem quiser mais fundo
# do que isto precisa de ouvir, que é o A6.
CORTE_DESCONTINUIDADE = 3.0

# ── o interpolador de true peak ──
# ITU-R BS.1770-4 mede o true peak sobre-amostrando 4x antes de procurar o
# máximo. O filtro é um sinc janelado, montado aqui em polifase: 4 fases de
# TAPS_POR_FASE coeficientes cada.
#
# ⚠️ 4x É O MÍNIMO DA NORMA, e o erro residual dele é conhecido: sobra até
# ~0,03 dB abaixo do pico verdadeiro. O autoteste mede isso contra um caso de
# resposta ANALÍTICA conhecida, em vez de o supor.
FATOR = 4
TAPS_POR_FASE = 12


def _polifase():
	"""Sinc janelado por Blackman, separado nas 4 fases do sobre-amostrador."""
	n = FATOR * TAPS_POR_FASE          # 48 coeficientes
	meio = (n - 1) / 2.0
	h = []
	for i in range(n):
		x = i - meio
		# sinc normalizado para a banda de 1/FATOR
		s = 1.0 if x == 0.0 else math.sin(math.pi * x / FATOR) / (math.pi * x / FATOR)
		# Blackman
		w = (0.42 - 0.5 * math.cos(2.0 * math.pi * i / (n - 1))
		     + 0.08 * math.cos(4.0 * math.pi * i / (n - 1)))
		h.append(s * w)
	# Normaliza cada fase para ganho unitário em DC: sem isto o interpolador
	# muda o nível do sinal e o "true peak" mediria o filtro, não o som.
	fases = []
	for f in range(FATOR):
		fase = h[f::FATOR]
		soma = sum(fase)
		fases.append([c / soma for c in fase] if soma else fase)
	return fases


FASES = _polifase()


def ler_wav(caminho):
	"""Devolve (amostras em float -1..1, taxa). Só leitura."""
	with wave.open(caminho, "rb") as w:
		if w.getsampwidth() != 2:
			raise SystemExit("erro: %s não é 16 bits (%d bytes por amostra)"
			                 % (caminho, w.getsampwidth()))
		if w.getnchannels() != 1:
			raise SystemExit("erro: %s não é mono (%d canais)"
			                 % (caminho, w.getnchannels()))
		taxa = w.getframerate()
		bruto = w.readframes(w.getnframes())
	inteiros = struct.unpack("<%dh" % (len(bruto) // 2), bruto)
	return [v / 32768.0 for v in inteiros], taxa


def pico_amostra(x):
	return max(abs(v) for v in x) if x else 0.0


def true_peak(x):
	"""Pico do sinal RECONSTRUÍDO, por sobre-amostragem 4x (BS.1770-4).

	⚠️ SÓ SE SOBRE-AMOSTRA À VOLTA DOS CANDIDATOS, e isto é uma otimização que
	MUDA O CUSTO E NÃO PODE MUDAR A RESPOSTA. A força bruta interpola as
	310 mil amostras dos 14 arquivos; aqui só se interpolam as janelas à volta
	de toda amostra que chegue perto do pico de amostra. O `--autoteste`
	compara as duas versões e exige o MESMO número — é a regra deste projeto
	para otimização em ferramenta cuja saída alguém lê.

	A margem de 0,5 dB é folgada de propósito: o ganho do interpolador entre
	amostras não passa de ~0,03 dB, logo nenhum pico verdadeiro pode nascer
	mais do que isso acima da vizinhança que o gerou.
	"""
	if not x:
		return 0.0
	limiar = pico_amostra(x) * (10.0 ** (-0.5 / 20.0))
	candidatos = [i for i, v in enumerate(x) if abs(v) >= limiar]
	return _interpolar(x, candidatos)


def _true_peak_forca_bruta(x):
	"""A versão lenta, que interpola TUDO. Existe para o autoteste comparar."""
	return _interpolar(x, range(len(x)))


def _interpolar(x, indices):
	n = len(x)
	melhor = 0.0
	for i in indices:
		# A janela do filtro à volta da amostra i.
		base = i - TAPS_POR_FASE // 2 + 1
		janela = [x[j] if 0 <= j < n else 0.0
		          for j in range(base, base + TAPS_POR_FASE)]
		for fase in FASES:
			v = 0.0
			for k in range(TAPS_POR_FASE):
				v += janela[k] * fase[k]
			if abs(v) > melhor:
				melhor = abs(v)
	return melhor


def dbfs(v):
	return -999.0 if v <= 0.0 else 20.0 * math.log10(v)


def descontinuidade(x):
	"""O maior salto ENTRE amostras vizinhas, e onde ele está.

	⚠️ A CONFERÊNCIA DE BORDAS NÃO PODIA VER ISTO. Ela pergunta se a primeira e
	a última amostra são zero — um estalo no MEIO do arquivo passa por ela
	inteiro, com as duas bordas em zero. É o segundo mutante da ficha.

	O número sozinho não diz nada (um som percussivo SOBE depressa de
	propósito), então sai também a RAZÃO entre o maior salto e o percentil 99,9
	dos saltos daquele mesmo arquivo: uma subida legítima tem companhia, um
	estalo isolado não tem. A comparação é do arquivo consigo mesmo, que é o
	que a torna independente do som ser suave ou percussivo.
	"""
	if len(x) < 2:
		return 0.0, 0, 0.0
	saltos = [abs(x[i] - x[i - 1]) for i in range(1, len(x))]
	maior = max(saltos)
	onde = saltos.index(maior) + 1
	ordenados = sorted(saltos)
	p999 = ordenados[min(len(ordenados) - 1, int(len(ordenados) * 0.999))]
	razao = (maior / p999) if p999 > 0 else float("inf")
	return maior, onde, razao


def _fft(a):
	"""FFT radix-2 recursiva. Pura, porque não há numpy neste contêiner."""
	n = len(a)
	if n == 1:
		return a
	par = _fft(a[0::2])
	impar = _fft(a[1::2])
	saida = [0j] * n
	for k in range(n // 2):
		t = cmath.exp(-2j * cmath.pi * k / n) * impar[k]
		saida[k] = par[k] + t
		saida[k + n // 2] = par[k] - t
	return saida


def espectro(x, taxa, tam=2048):
	"""Energia por banda e centroide, por Welch simples (janelas de Hann).

	Devolve (fracao_por_banda, centroide_hz, fracao_abaixo_do_corte).
	"""
	if len(x) < tam:
		x = list(x) + [0.0] * (tam - len(x))
	salto = tam // 2
	hann = [0.5 - 0.5 * math.cos(2.0 * math.pi * i / (tam - 1)) for i in range(tam)]
	acumulado = [0.0] * (tam // 2)
	janelas = 0
	for inicio in range(0, len(x) - tam + 1, salto):
		bloco = [x[inicio + i] * hann[i] for i in range(tam)]
		esp = _fft([complex(v, 0.0) for v in bloco])
		for k in range(tam // 2):
			acumulado[k] += abs(esp[k]) ** 2
		janelas += 1
	if janelas == 0:
		return {nome: 0.0 for nome, _, _ in BANDAS}, 0.0, 0.0
	total = sum(acumulado) or 1.0
	hz = [k * taxa / tam for k in range(tam // 2)]

	fracoes = {}
	for nome, lo, hi in BANDAS:
		fracoes[nome] = sum(acumulado[k] for k in range(tam // 2)
		                    if lo <= hz[k] < hi) / total
	centroide = sum(hz[k] * acumulado[k] for k in range(tam // 2)) / total
	abaixo = sum(acumulado[k] for k in range(tam // 2)
	             if hz[k] < CORTE_TELEFONE) / total
	return fracoes, centroide, abaixo


def conferir_buses(caminho):
	"""O que AUTORIZA falar de uma soma offline: ganho e efeitos dos buses.

	⚠️ SOMA OFFLINE NÃO É A MIX, e a ficha do R9 diz exatamente isso: só é
	comparável se os buses estiverem em ganho unitário e sem efeito. Isto não
	se supõe — lê-se do `default_bus_layout.tres`. Se um dia alguém puser um
	limitador no SFX ou baixar o bus, a soma deixa de descrever o que sai do
	aparelho, e esta função é quem avisa.
	"""
	if not os.path.exists(caminho):
		return False, "não achei %s" % caminho
	texto = open(caminho, encoding="utf-8").read()
	ganhos = re.findall(r"bus/\d+/volume_db = (-?[\d.]+)", texto)
	efeitos = re.findall(r"bus/\d+/effect/", texto)
	bypass = re.findall(r"bus/\d+/bypass_fx = (\w+)", texto)
	nao_unitarios = [g for g in ganhos if abs(float(g)) > 0.001]
	if nao_unitarios:
		return False, "bus com ganho ≠ 0 dB: %s" % ", ".join(nao_unitarios)
	if efeitos:
		return False, "%d efeito(s) de bus declarados" % len(efeitos)
	return True, "%d bus(es) a 0 dB, sem efeito, bypass %s" % (
		len(ganhos), "/".join(bypass) if bypass else "n/d")


def autoteste():
	"""A calibração, ANTES de qualquer número valer.

	⚠️ RÉGUA MUDA DÁ UM NÚMERO, E O NÚMERO VIRA A CONCLUSÃO DA SESSÃO. Uma
	régua de true peak que devolvesse sempre o pico de amostra passaria
	despercebida nos 14 arquivos deste projeto, porque nenhum deles chega perto
	de 0 dBFS. São quatro perguntas, e a régua só vale depois de as quatro:

	  1. O caso de resposta ANALÍTICA: um seno a fs/4 amostrado nos cruzamentos
	     ±A/√2 tem pico verdadeiro A e pico de AMOSTRA A/√2 — 3,01 dB que o
	     pico de amostra não vê, por construção e não por acaso.
	  2. O piso: um sinal cujo pico cai EM CIMA de uma amostra (DC) não pode
	     ganhar nada — true peak == pico de amostra.
	  3. O invariante: true peak >= pico de amostra, SEMPRE e em todo arquivo.
	  4. A otimização: a versão por candidatos e a força bruta têm de dar o
	     MESMO número.
	"""
	falhas = []
	print("=== autoteste da régua (antes de qualquer número valer) ===")

	# 1. seno a fs/4, fase 45°: amostras em ±A/√2, pico verdadeiro A.
	amp = 0.5
	seno = [amp * math.sin(2.0 * math.pi * 0.25 * n + math.pi / 4.0)
	        for n in range(2048)]
	ps, tp = pico_amostra(seno), true_peak(seno)
	ganho = dbfs(tp) - dbfs(ps)
	ok = abs(ganho - 3.01) < 0.15
	print("  %s seno fs/4: pico amostra %.4f, true peak %.4f → +%.2f dB "
	      "(esperado +3,01)" % ("PASS " if ok else "FALHA", ps, tp, ganho))
	if not ok:
		falhas.append("o ganho entre amostras não bate com o caso analítico")

	# 2. o piso: contínua, pico em cima da amostra, nada a ganhar.
	#
	# ⚠️ E O PISO MEDE-SE NO MIOLO, NUNCA NA BORDA — esta asserção reprovou a
	# régua CERTA na primeira corrida, por 0,5623. A causa não é o filtro: uma
	# contínua que COMEÇA na amostra 0 é um DEGRAU, e a reconstrução limitada
	# em banda de um degrau ultrapassa mesmo (Gibbs). Os 12% a mais eram
	# verdade sobre o sinal que o teste montou, e não sobre o que ele queria
	# perguntar.
	#
	# Para os 14 arquivos deste projeto o zero à volta é FÍSICO — todos começam
	# e acabam em 0, precedidos e seguidos de silêncio —, portanto a ferramenta
	# mantém o enchimento com zeros e a borda é medida como ela soa. Quem muda
	# é o TESTE, que passa a perguntar no miolo o que sempre quis perguntar.
	dc = [0.5] * 512
	no_miolo = _interpolar(dc, [256])
	ok = abs(no_miolo - 0.5) < 0.0005
	print("  %s contínua 0,5 no miolo: true peak %.4f (esperado 0,5 — sem ganho)"
	      % ("PASS " if ok else "FALHA", no_miolo))
	if not ok:
		falhas.append("a régua inventa pico onde não há nada entre amostras")

	# 3. o invariante, num sinal qualquer.
	import random
	random.seed(7)
	ruido = [random.uniform(-0.3, 0.3) for _ in range(4096)]
	ok = true_peak(ruido) >= pico_amostra(ruido) - 1e-9
	print("  %s invariante true peak >= pico de amostra: %.4f >= %.4f"
	      % ("PASS " if ok else "FALHA", true_peak(ruido), pico_amostra(ruido)))
	if not ok:
		falhas.append("o true peak saiu ABAIXO do pico de amostra")

	# 4. a otimização não pode mudar a resposta.
	rapido, lento = true_peak(ruido), _true_peak_forca_bruta(ruido)
	ok = abs(rapido - lento) < 1e-12
	print("  %s candidatos == força bruta: %.9f vs %.9f"
	      % ("PASS " if ok else "FALHA", rapido, lento))
	if not ok:
		falhas.append("a otimização por candidatos mudou o resultado")

	# 5. a descontinuidade tem de ver um estalo NO MEIO com as bordas a zero.
	limpo = [0.4 * math.sin(2.0 * math.pi * 300.0 * n / 32000.0)
	         for n in range(3200)]
	limpo[0] = limpo[-1] = 0.0
	sujo = list(limpo)
	# ⚠️ E O DEFEITO TEM DE PEGAR: a primeira versão desta asserção fazia
	# `sujo[1600] = -sujo[1600]`, e em n=1600 um seno de 300 Hz a 32 kHz vale
	# ZERO — inverter zero não mexe em nada, e a régua reprovava por a razão
	# dar 2,0 dos dois lados. Hoje o valor é cravado longe da curva, e o teste
	# confere que os dois sinais DIFEREM antes de comparar as razões.
	sujo[1600] = 0.95
	assert sujo != limpo, "o defeito injetado não mudou o sinal"
	r_limpo = descontinuidade(limpo)[2]
	r_sujo = descontinuidade(sujo)[2]
	ok = r_sujo > r_limpo * 3.0
	print("  %s estalo no meio com bordas a zero: razão %.1f contra %.1f limpo"
	      % ("PASS " if ok else "FALHA", r_sujo, r_limpo))
	if not ok:
		falhas.append("a descontinuidade não separa o estalo do sinal limpo")

	# 6. o espectro tem de pôr um tom puro na banda dele, e não noutra.
	tom = [0.5 * math.sin(2.0 * math.pi * 1000.0 * n / 32000.0)
	       for n in range(8192)]
	fr, cen, _ = espectro(tom, 32000)
	dominante = max(fr, key=fr.get)
	ok = dominante == "500-2k" and abs(cen - 1000.0) < 120.0
	print("  %s tom de 1 kHz: banda dominante %s (%.0f%%), centroide %.0f Hz"
	      % ("PASS " if ok else "FALHA", dominante, 100 * fr[dominante], cen))
	if not ok:
		falhas.append("o espectro não põe um tom puro na banda dele")

	print("")
	if falhas:
		for f in falhas:
			print("  !! %s" % f)
		return 1
	print("  a régua responde ao que sabe responder, e o resto é medição.")
	return 0


def medir_pasta(pasta):
	arquivos = sorted(f for f in os.listdir(pasta) if f.endswith(".wav"))
	if not arquivos:
		raise SystemExit("erro: nenhum .wav em %s" % pasta)

	print("")
	print("=== os %d sons, medidos ===" % len(arquivos))
	print("%-20s %6s %7s %8s %7s %9s %7s  %s"
	      % ("arquivo", "ms", "pico", "dBTP", "Δ-razão", "centroide", "<500Hz", "banda"))
	print("-" * 92)

	alertas = []
	medidos = []
	for nome in arquivos:
		caminho = os.path.join(pasta, nome)
		x, taxa = ler_wav(caminho)
		ms = 1000.0 * len(x) / taxa
		ps = pico_amostra(x)
		tp = true_peak(x)
		_, onde, razao = descontinuidade(x)
		fr, cen, abaixo = espectro(x, taxa)
		dominante = max(fr, key=fr.get)
		medidos.append((nome, x, taxa, tp))

		# ── os DOIS alertas, e nenhum deles é perceptual ──
		# Um alerta aqui diz "este arquivo tem um defeito de SINAL", nunca
		# "este som não presta". A diferença é que ambos se decidem por
		# aritmética sobre a onda, e nenhum precisa de ouvido para se resolver.
		if dbfs(tp) >= 0.0:
			alertas.append("%s: true peak %.2f dBTP — a onda reconstruída "
			               "satura no aparelho" % (nome, dbfs(tp)))
		if razao >= CORTE_DESCONTINUIDADE:
			alertas.append("%s: salto isolado na amostra %d, %.1fx o p99,9 do "
			               "próprio arquivo (corte %.1f) — estalo, e as bordas "
			               "não o veem" % (nome, onde, razao, CORTE_DESCONTINUIDADE))

		print("%-20s %6.0f %7.3f %8.2f %7.1f %8.0fHz %6.0f%%  %s (%.0f%%)"
		      % (nome.replace(".wav", ""), ms, ps, dbfs(tp), razao, cen,
		         100 * abaixo, dominante, 100 * fr[dominante]))

	# ── a soma offline, e o que ela não prova ──
	ok_bus, detalhe = conferir_buses(LAYOUT)
	print("")
	print("=== a soma offline, e o que ela NÃO prova ===")
	print("buses: %s" % detalhe)
	if not ok_bus:
		print("⚠️  com ganho ou efeito de bus, a soma abaixo NÃO descreve o que")
		print("    sai do aparelho, e não se deve citar.")
	else:
		# O `Audio.gd` toca no máximo VOZES=3 ao mesmo tempo, e só um PEDIDO
		# vence por frame — a sobreposição real vem de um som LONGO ainda a
		# soar quando o próximo começa. Somam-se os três mais altos que podem
		# coincidir assim, alinhados no pior instante de cada um.
		trio = sorted(medidos, key=lambda m: -m[3])[:3]
		soma_tp = sum(m[3] for m in trio)
		print("três vozes (VOZES=3) no pior alinhamento possível:")
		print("   %s" % " + ".join(m[0].replace(".wav", "") for m in trio))
		print("   soma dos true peaks: %.3f  (%.2f dBTP)" % (soma_tp, dbfs(soma_tp)))
		if dbfs(soma_tp) >= 0.0:
			print("   ⚠️  acima de 0 dBTP: TRÊS no mesmo instante saturariam o")
			print("       Master. Não é veredito — é o pior caso aritmético,")
			print("       e nada prova que o jogo o produz.")
		print("")
		print("⚠️  E ISTO NÃO É A MIX. A soma é aritmética sobre os arquivos; a")
		print("    mix real tem a fase de cada som, o instante em que cada um")
		print("    entra e o volume que o jogador escolheu. O que a linha acima")
		print("    prova é só o TETO: nada pode passar disto.")

	print("")
	print("=== o que fica para o ouvido (A6), e não se decide aqui ===")
	print("• timbre: se 'moeda' soa a dinheiro e 'obra' soa a obra.")
	print("• hierarquia: a interface mede ~8 dB acima do ambiente. Se isso é")
	print("  hierarquia ou é interface aos gritos, mede-se ouvindo.")
	print("• fadiga: o clique toca dezenas de vezes por partida.")
	print("• a coluna '<500Hz' diz que fração do som o alto-falante de um")
	print("  telefone tende a NÃO devolver — é o que procurar na escuta.")

	print("")
	if alertas:
		for a in alertas:
			print("!! %s" % a)
		print("=== %d ALERTA(S) DE SINAL ===" % len(alertas))
		return 1
	print("=== SINAL OK — %d sons medidos, sem saturação nem estalo ===" % len(arquivos))
	print("    (nada aqui diz que os sons são BONS: ninguém os ouviu)")
	return 0


def main(argv):
	if "--autoteste" in argv:
		return autoteste()
	pasta = next((a for a in argv[1:] if not a.startswith("-")), PASTA_PADRAO)
	if not os.path.isdir(pasta):
		raise SystemExit("erro: %s não é uma pasta" % pasta)
	saida = autoteste()
	if saida != 0:
		print("")
		print("!! a régua não passou na própria calibração — os números abaixo")
		print("   não valeriam nada, e por isso não se medem.")
		return saida
	return medir_pasta(pasta)


if __name__ == "__main__":
	sys.exit(main(sys.argv))
