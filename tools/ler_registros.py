#!/usr/bin/env python3
"""Lê os registros de partida do BR Port e resume o que cinco partidas dizem
e nenhuma diz sozinha — item B7 do plano v3, a metade de máquina do A7.

QUEM ESCREVE O QUE ISTO LÊ é `brport_vs/autoload/Registro.gd`: uma linha JSON
por acontecimento, uma partida por arquivo.

POR QUE UM LEITOR SEPARADO, E NÃO UM RELATÓRIO NO JOGO. O roadmap já mandava
"grave a tela — comportamento importa mais que opinião", e está certo. Só que
ver gravação é caro e NÃO SE SOMA: cinco gravações são cinco horas e continuam
a ser cinco impressões. Cinco arquivos destes somam-se, e a soma responde
perguntas que nenhuma partida responde — em que semana o dinheiro trava, se o
jogador perde barco por esquecimento ou por escolha, quanto tempo ele fica
parado antes de avançar o dia.

E RESPONDE UMA PERGUNTA QUE ESTE PROJETO TINHA EM ABERTO. O
`simular_balanceamento.gd` mede a dificuldade com três perfis de jogador cujos
números são um MODELO de como alguém erra — `chance_esquecer_doca`,
`estilo_negociacao`, `chance_igualar_rival`. Nunca foram medidos: foram
estimados, e o balanceamento inteiro assenta neles. A última seção deste
relatório imprime o valor MEDIDO de cada um, lado a lado com o que o simulador
assume. É a única forma de saber se os perfis descrevem gente.

Uso:
    python3 tools/ler_registros.py registros/*.jsonl
    python3 tools/ler_registros.py --pasta ~/Downloads/registros
    pbpaste | python3 tools/ler_registros.py -        # colado do telefone

    python3 tools/ler_registros.py --autoteste      # só a prova do leitor

O `-` existe porque no telefone o registro sai pela área de transferência (o
`user://` do Android é privado da aplicação). Coladas várias partidas de
seguida, elas separam-se sozinhas: cada `"e":"abriu"` começa uma nova.

O AUTOTESTE CORRE ANTES DE TODA LEITURA, e sem ele não há leitura: um leitor
que tira a semana errada publica um número plausível, e ninguém o confere à
mão (é o `--autoteste` do `medir_audio.py`, `CLAUDE.md`). Ele lê uma partida
fabricada de 84 dias e 7 por semana e exige a primeira e a última semana
certas, o «não sei» de quem não traz o calendário e o dia pronto de cada obra.

Espera `LEITURA OK` na última linha.
"""
import argparse
import contextlib
import io
import json
import os
import statistics
import sys

# A forma de evento que este leitor conhece. Registro de outra versão NÃO se
# descarta — ao contrário do save, cujo comentário no `load_game()` explica por
# que ali é o oposto: um save errado estraga a partida em curso, um registro
# velho continua a ser um dado que alguém produziu jogando. Lê-se o que se
# reconhece e DIZ-SE o que ficou de fora.
VERSAO_CONHECIDA = 2

# A primeira versão do gravador que ouve o `obra_concluida` (`088`). É a
# VERSÃO, e não a ausência da linha, que separa «não acabou» de «não sei»: na
# versão 1 a conclusão nunca foi gravada — antes da `087` a compra ERA a obra
# pronta, e depois dela não.
VERSAO_COM_OBRA_PRONTA = 2

# O dia pronto de uma obra que o registro não sabe dizer. Um objeto e não um
# número: zero ou −1 liam-se como dia (`CLAUDE.md`, «zero é o pior valor de
# omissão»), e `None` já quer dizer «não acabou até ao fim do registro».
NAO_SEI = object()

# O que o simulador de balanceamento ASSUME sobre o jogador, para a última
# seção poder pôr medida ao lado de palpite. Copiado à mão de
# `brport_vs/tools/simular_balanceamento.gd`; se lá mudar, muda aqui — e é por
# isso que o relatório imprime a fonte em vez de fingir que a leu.
PERFIS_DO_SIMULADOR = {
    "otimo": {"esquecer": 0.00, "iguala_de_cara": 0.00},
    "medio": {"esquecer": 0.12, "iguala_de_cara": 0.65},
    "ruim": {"esquecer": 0.30, "iguala_de_cara": 0.10},
}


def carregar(linhas, origem):
    """Parte uma sequência de linhas JSON em partidas.

    Uma partida começa em `"e":"abriu"`. Linhas antes da primeira abertura são
    de um arquivo truncado — conta-se e segue-se, porque metade de uma partida
    real vale mais do que uma exceção.
    """
    partidas, atual, orfas, ilegiveis = [], None, 0, 0
    for linha in linhas:
        linha = linha.strip()
        if not linha:
            continue
        try:
            ev = json.loads(linha)
        except json.JSONDecodeError:
            # Última linha cortada ao meio é o que acontece quando o Android
            # mata a aplicação a meio de uma escrita. Não é corrupção do
            # arquivo inteiro.
            ilegiveis += 1
            continue
        if not isinstance(ev, dict):
            ilegiveis += 1
            continue
        if ev.get("e") == "abriu":
            atual = {"cabecalho": ev, "eventos": [], "origem": origem}
            partidas.append(atual)
        elif atual is None:
            orfas += 1
        else:
            atual["eventos"].append(ev)
    return partidas, orfas, ilegiveis


def so(partida, nome):
    return [e for e in partida["eventos"] if e.get("e") == nome]


def _inteiro_positivo(v):
    if isinstance(v, bool):
        return None
    if isinstance(v, int) and v > 0:
        return v
    if isinstance(v, float) and v.is_integer() and v > 0:
        return int(v)
    return None


def calendario(cabecalho):
    """`(turnos_por_semana, turnos_totais)` do cabeçalho, ou `None`.

    ⚠️ SEM VALOR DE OMISSÃO, de propósito. O leitor tirava as semanas de
    `t <= 8` e `t > 24`, que eram as de 8 dias numa fase de 4: com 12 de 7
    (`085`), a «semana 4» publicada ia da 4 à 12, sem erro nenhum. Supor 7
    num registro antigo repetia o defeito com outro número — o `.get(chave,
    omissão)` do `CLAUDE.md`. Quem não traz o campo fica a «não sei».
    """
    tps = _inteiro_positivo(cabecalho.get("turnos_por_semana"))
    total = _inteiro_positivo(cabecalho.get("turnos_totais"))
    if tps is None or total is None:
        return None
    return tps, total


def dia_do_tempo(ev):
    """O dia em que o jogador gastou o `ms` de uma linha `turno`.

    A linha sai quando o dia VIRA, com o `t` do dia NOVO; o tempo que ela leva
    é o do dia que acabou de fechar. Lido pelo `t`, o primeiro dia jogado
    saía como «t2» e a primeira semana de 7 ficava com seis dias.
    """
    return int(ev["t"]) - 1


def tempos_das_pontas(partidas):
    """Os tempos por dia da primeira e da última semana, cada partida pelo
    calendário do SEU cabeçalho — um registro de antes de uma reescala não se
    mede com as semanas de hoje."""
    primeira, ultima, semanas, sem_calendario = [], [], set(), 0
    for p in partidas:
        cal = calendario(p["cabecalho"])
        if cal is None:
            sem_calendario += 1
            continue
        tps, total = cal
        n = -(-total // tps)            # a última semana, mesmo que incompleta
        semanas.add(n)
        for e in so(p, "turno"):
            if "ms" not in e:
                continue
            dia = dia_do_tempo(e)
            if 1 <= dia <= tps:
                primeira.append(int(e["ms"]))
            if (n - 1) * tps < dia <= total:
                ultima.append(int(e["ms"]))
    return {"primeira": primeira, "ultima": ultima, "semanas": semanas,
            "sem_calendario": sem_calendario}


def obras_de(partida):
    """Uma entrada por obra PAGA: `id`, dia `pago` e dia `pronto`.

    Desde a `087` pagar não é levantar: a obra leva dias. O `pronto` é o dia da
    linha `obra_pronta` que casa com ela, `None` se não acabou até ao fim do
    registro, ou `NAO_SEI` numa versão que não a grava.

    Também devolve as prontas SEM pagamento neste arquivo: quem fecha a
    aplicação a meio da obra e volta paga num arquivo e conclui no outro.
    """
    sabe = int(partida["cabecalho"].get("versao", 0)) >= VERSAO_COM_OBRA_PRONTA
    prontas = [(e["id"], int(e["t"])) for e in so(partida, "obra_pronta")]
    usadas = set()
    obras = []
    for e in so(partida, "obra"):
        pago = int(e["t"])
        pronto = NAO_SEI
        if sabe:
            pronto = None
            for i, (oid, t) in enumerate(prontas):
                if i not in usadas and oid == e["id"] and t >= pago:
                    pronto = t
                    usadas.add(i)
                    break
        obras.append({"id": e["id"], "pago": pago, "pronto": pronto})
    soltas = [prontas[i] for i in range(len(prontas)) if i not in usadas]
    return obras, soltas


def resumo_de_uma(p):
    turnos = so(p, "turno")
    fim = so(p, "fim")
    fim = fim[-1] if fim else None
    cab = p["cabecalho"]
    return {
        "origem": p["origem"],
        "quando": cab.get("quando", "?"),
        "plataforma": cab.get("plataforma", "?"),
        "versao": int(cab.get("versao", 0)),
        "turnos": len(turnos),
        "turnos_totais": int(cab.get("turnos_totais", 0)),
        # Uma partida sem `fim` é uma partida ABANDONADA, e isso é dado e não
        # defeito: é a leitura mais dura que um playtest dá.
        "terminou": fim is not None,
        "ganhou": bool(fim.get("ganhou")) if fim else None,
        "motivo": fim.get("motivo", "") if fim else "(sem linha de fim)",
        # Abrir a aplicação com um save por acabar arma o gravador a meio de
        # uma partida, e o arquivo anterior fica sem linha de fim sem ninguém
        # ter desistido de nada.
        "retomada": bool(cab.get("retomada", False)),
        "t_inicial": int(cab.get("t_inicial", 1)),
        "caixa_final": (fim or turnos[-1] if turnos else {}).get("caixa", 0),
        "rep_final": (fim or turnos[-1] if turnos else {}).get("rep", 0),
        "obras": [o["id"] for o in so(p, "obra")],  # pagas, prontas ou não
        "metrics": (fim or {}).get("metrics", {}),
        "anonimo": (fim or {}).get("jogador_anonimo"),
        "porto": (fim or {}).get("porto", ""),
    }


def barra(fracao, largura=24):
    cheio = int(round(max(0.0, min(1.0, fracao)) * largura))
    return "█" * cheio + "·" * (largura - cheio)


def ms_legivel(ms):
    if ms is None:
        return "—"
    s = ms / 1000.0
    return "%.1fs" % s if s < 60 else "%dm%02ds" % (int(s // 60), int(s % 60))


def relatar(partidas, orfas, ilegiveis):
    print("=" * 66)
    print("BR PORT — LEITURA DE %d PARTIDA(S)" % len(partidas))
    print("=" * 66)

    desconhecidas = [p for p in partidas if int(p["cabecalho"].get("versao", 0)) != VERSAO_CONHECIDA]
    if desconhecidas:
        print("\n⚠ %d partida(s) de outra versão de registro (este leitor lê a %d)."
              % (len(desconhecidas), VERSAO_CONHECIDA))
        print("  Lidas na mesma, e o que este leitor não reconhecer fica de fora.")
    if orfas or ilegiveis:
        print("\n⚠ %d linha(s) antes de qualquer abertura, %d ilegível(eis)."
              % (orfas, ilegiveis))
        print("  Normal em registro colado a meio ou cortado por fecho de aplicação.")

    resumos = [resumo_de_uma(p) for p in partidas]

    # ── 1. UMA LINHA POR PARTIDA ──
    print("\n── Cada partida ──")
    print("  %-19s %5s %9s %5s  %s" % ("quando", "turno", "caixa", "rep", "fim"))
    for r in resumos:
        print("  %-19s %2d/%-2d %9d %5.1f  %s%s" % (
            r["quando"][:19], r["turnos"], r["turnos_totais"],
            r["caixa_final"], r["rep_final"],
            ("ganhou" if r["ganhou"] else "perdeu") if r["terminou"] else "sem fim",
            "  (retomada no t%d)" % r["t_inicial"] if r["retomada"] else "",
        ))

    terminadas = [r for r in resumos if r["terminou"]]
    # ABANDONADA é a leitura mais dura que um playtest dá, e por isso é a que
    # menos pode ser dada de graça. Uma partida sem linha de fim SEGUIDA de
    # uma retomada é a mesma sessão continuada noutro arquivo — quem fechou a
    # aplicação e voltou não desistiu de nada.
    houve_retomada = any(r["retomada"] for r in resumos)
    sem_fim = [r for r in resumos if not r["terminou"]]
    if sem_fim:
        print("\n  %d de %d partidas não têm linha de fim, no turno %s." % (
            len(sem_fim), len(resumos), ", ".join(str(r["turnos"]) for r in sem_fim)))
        if houve_retomada:
            print("  Há retomadas nestes registros: parte delas é a mesma sessão")
            print("  continuada depois de fechar a aplicação, não desistência.")
        else:
            print("  Nenhuma retomada — estas foram mesmo abandonadas.")

    # ── 2. O CAIXA, TURNO A TURNO, SOBREPOSTO ──
    #
    # A curva de uma partida diz se aquele jogador se safou. Cinco curvas
    # sobrepostas dizem ONDE o jogo aperta, que é outra pergunta.
    print("\n── O caixa por turno (mediana das partidas) ──")
    por_turno = {}
    for p in partidas:
        for e in so(p, "turno"):
            por_turno.setdefault(int(e["t"]), []).append(int(e["caixa"]))
    if por_turno:
        pico = max(max(v) for v in por_turno.values())
        for t in sorted(por_turno):
            v = por_turno[t]
            mediana = statistics.median(v)
            print("  t%-3d %s %9d  (n=%d)" % (t, barra(mediana / pico if pico else 0), mediana, len(v)))

    # ── 3. QUANTO TEMPO O JOGADOR FICA EM CADA TURNO ──
    #
    # A pergunta que o A7 faz por escrito. Um turno lento no início é
    # aprendizagem; um turno lento no fim é confusão, e são coisas opostas.
    print("\n── Quanto tempo se fica num dia ──")
    tempos = [(dia_do_tempo(e), int(e["ms"])) for p in partidas for e in so(p, "turno") if "ms" in e]
    if tempos:
        todos = [ms for _, ms in tempos]
        print("  mediana %s · o mais demorado %s · total jogado %s" % (
            ms_legivel(statistics.median(todos)), ms_legivel(max(todos)),
            ms_legivel(sum(todos))))
        lentos = sorted(tempos, key=lambda x: -x[1])[:5]
        print("  os cinco dias mais demorados: %s" % ", ".join(
            "dia %d (%s)" % (d, ms_legivel(ms)) for d, ms in lentos))
        # Primeira semana contra a última: é onde se vê se o jogo foi
        # aprendido ou só suportado. As semanas saem do cabeçalho.
        pontas = tempos_das_pontas(partidas)
        if pontas["primeira"] and pontas["ultima"]:
            ultima = ("semana %d" % next(iter(pontas["semanas"]))
                      if len(pontas["semanas"]) == 1 else "a última semana")
            print("  semana 1: %s por dia · %s (a última): %s por dia" % (
                ms_legivel(statistics.median(pontas["primeira"])), ultima,
                ms_legivel(statistics.median(pontas["ultima"]))))
        if pontas["sem_calendario"]:
            print("  semana 1 e última: não sei em %d partida(s) — o cabeçalho não traz"
                  % pontas["sem_calendario"])
            print("  `turnos_por_semana` (registro anterior à versão 2), e o leitor não")
            print("  supõe 7 nem 8. Ficam fora da linha das semanas.")
    else:
        print("  (nenhum dia trouxe tempo)")

    # ── 4. AS OBRAS, E QUANDO ──
    #
    # Desde a `087` pagar não é levantar: a obra leva dias, e só a pronta
    # entra no porto. Até 10/10 esta seção publicava o dia PAGO com este
    # título, e contava como feita a obra a meio (`088`).
    print("\n── O porto que se levanta (dia pago → dia pronto) ──")
    por_obra, soltas = {}, 0
    for p in partidas:
        obras, sem_pagamento = obras_de(p)
        soltas += len(sem_pagamento)
        for o in obras:
            por_obra.setdefault(o["id"], []).append(o)
    for oid in sorted(por_obra, key=lambda k: statistics.median(o["pago"] for o in por_obra[k])):
        os_ = por_obra[oid]
        pagos = [o["pago"] for o in os_]
        prontos = [o["pronto"] for o in os_ if isinstance(o["pronto"], int)]
        print("  %-12s paga em %d de %d partidas, dia mediano %d (do %d ao %d)" % (
            oid, len(pagos), len(partidas), statistics.median(pagos), min(pagos), max(pagos)))
        if prontos:
            print("  %-12s pronta em %d, dia mediano %d (do %d ao %d)" % (
                "", len(prontos), statistics.median(prontos), min(prontos), max(prontos)))
        por_acabar = sum(1 for o in os_ if o["pronto"] is None)
        if por_acabar:
            print("  %-12s %d %s por acabar até ao fim do registro" % (
                "", por_acabar, "ficou" if por_acabar == 1 else "ficaram"))
        nao_sei = sum(1 for o in os_ if o["pronto"] is NAO_SEI)
        if nao_sei:
            print("  %-12s pronta: não sei em %d — registro anterior à versão %d, que"
                  % ("", nao_sei, VERSAO_COM_OBRA_PRONTA))
            print("  %-12s não grava a conclusão" % "")
    if soltas:
        print("  %d obra(s) pronta(s) com o pagamento noutro arquivo (partida retomada)." % soltas)
    nunca = [r for r in resumos if not r["obras"]]
    if nunca:
        print("  %d partida(s) não começaram obra nenhuma." % len(nunca))

    # ── 5. A SEMANA COMO A DONA CIDA A CONTA ──
    print("\n── O resultado de cada semana (mediana) ──")
    por_semana = {}
    for p in partidas:
        for e in so(p, "semana"):
            por_semana.setdefault(int(e["semana"]), []).append(e)
    for s in sorted(por_semana):
        evs = por_semana[s]
        med = lambda k: statistics.median([int(e.get(k, 0)) for e in evs])
        print("  semana %d  receita %8d  despesa %8d  resultado %+9d  (n=%d)" % (
            s, med("receita"), med("despesa"), med("resultado"), len(evs)))

    # ── 6. O QUE O SIMULADOR ADIVINHA, MEDIDO ──
    #
    # A seção que justifica este arquivo existir. Os perfis do
    # `simular_balanceamento.gd` são um modelo de como alguém erra, e o
    # balanceamento inteiro assenta neles. Aqui eles encontram gente.
    print("\n── O jogador medido, contra o jogador que o simulador supõe ──")
    print("  (perfis em brport_vs/tools/simular_balanceamento.gd)")

    barcos_parados, barcos_com_barco = 0, 0
    for p in partidas:
        for e in so(p, "turno"):
            com = int(e.get("barcos", 0))
            aloc = int(e.get("alocados", 0))
            barcos_com_barco += com
            barcos_parados += max(0, com - aloc)
    if barcos_com_barco:
        medido = barcos_parados / barcos_com_barco
        print("\n  chance_esquecer_doca — barco que virou o turno sem trabalhador")
        print("    MEDIDO   %.3f  (%d de %d barcos-turno)" % (medido, barcos_parados, barcos_com_barco))
        for nome, v in PERFIS_DO_SIMULADOR.items():
            print("    %-8s %.3f%s" % (nome, v["esquecer"],
                  "   ← o mais próximo" if _mais_proximo(medido, "esquecer") == nome else ""))
    else:
        print("\n  chance_esquecer_doca — sem barcos-turno para medir")

    negs = [e for p in partidas for e in so(p, "negociou")]
    if negs:
        primeiras = [e for e in negs if int(e.get("tentativa", 1)) == 1]
        igualou = sum(1 for e in primeiras if e.get("acao") == "igualar")
        frac = igualou / len(primeiras) if primeiras else 0.0
        print("\n  chance_igualar_rival — igualou de cara, sem arriscar")
        print("    MEDIDO   %.3f  (%d de %d primeiras rodadas)" % (frac, igualou, len(primeiras)))
        for nome, v in PERFIS_DO_SIMULADOR.items():
            print("    %-8s %.3f%s" % (nome, v["iguala_de_cara"],
                  "   ← o mais próximo" if _mais_proximo(frac, "iguala_de_cara") == nome else ""))

        print("\n  O que se escolheu na contra-oferta, e no que deu:")
        combos = {}
        for e in negs:
            combos[(e.get("acao"), e.get("resultado"))] = combos.get((e.get("acao"), e.get("resultado")), 0) + 1
        for (acao, res), n in sorted(combos.items(), key=lambda kv: -kv[1]):
            print("    %-9s → %-9s %3d  (%4.1f%%)" % (acao, res, n, 100.0 * n / len(negs)))
        tempos_neg = [int(e["ms"]) for e in negs if "ms" in e]
        if tempos_neg:
            print("    tempo a decidir: mediana %s, o mais longo %s" % (
                ms_legivel(statistics.median(tempos_neg)), ms_legivel(max(tempos_neg))))
    else:
        print("\n  chance_igualar_rival — nenhuma contra-oferta nestes registros")

    # ── 7. O QUE O JOGO DISSE QUE CORREU MAL ──
    ruins = sum(int(e.get("avisos_ruins", 0)) for p in partidas for e in so(p, "turno"))
    servidos = sum(int(e.get("servidos", 0)) for p in partidas for e in so(p, "turno"))
    perdidos = sum(int(e.get("perdidos", 0)) for p in partidas for e in so(p, "turno"))
    print("\n── O saldo do jogo ──")
    print("  %d barcos servidos · %d perdidos · %d avisos vermelhos" % (servidos, perdidos, ruins))
    if servidos + perdidos:
        print("  taxa de atendimento %.1f%%" % (100.0 * servidos / (servidos + perdidos)))

    anon = [r for r in terminadas if r["anonimo"]]
    if terminadas:
        print("  %d de %d jogadores deixaram o nome em branco" % (len(anon), len(terminadas)))
        portos = [r["porto"] for r in terminadas if r["porto"]]
        if portos:
            print("  portos batizados: %s" % ", ".join(portos))

    print("\n" + "=" * 66)
    print("LEITURA OK")


def _mais_proximo(medido, chave):
    return min(PERFIS_DO_SIMULADOR, key=lambda n: abs(PERFIS_DO_SIMULADOR[n][chave] - medido))


# ── O AUTOTESTE ──
#
# Uma partida FABRICADA de 84 dias e 7 por semana, em que o tempo de cada dia
# é o número da semana em segundos: a semana 1 inteira vale 1000 ms e a 12
# vale 12000. Assim a resposta certa é uma LISTA exata, e não uma mediana —
# com o 8 cravado a primeira semana leva o dia 8 (2000 ms) e a mediana dos
# oito continuava a dar 1000, passando por certa. Medido em 10/10 (`088`).

def _fixture(versao=VERSAO_CONHECIDA, com_calendario=True, com_prontas=True):
    cab = {"e": "abriu", "versao": versao, "quando": "fixture", "plataforma": "autoteste",
           "turnos_totais": 84, "t_inicial": 1, "retomada": False}
    if com_calendario:
        cab["turnos_por_semana"] = 7
    linhas = [cab, {"e": "obra", "id": "pier_2", "t": 1, "caixa": 0, "custo": 1}]
    for t in range(2, 86):
        dia = t - 1
        linhas.append({"e": "turno", "t": t, "s": (t - 1) // 7 + 1, "ms": 1000 * ((dia - 1) // 7 + 1),
                       "caixa": 0, "rep": 50.0})
        if t == 3 and com_prontas:
            linhas.append({"e": "obra_pronta", "id": "pier_2", "t": 3})
        if t == 10:
            linhas.append({"e": "obra", "id": "armazem", "t": 10, "caixa": 0, "custo": 1})
    linhas.append({"e": "fim", "ganhou": True, "motivo": "fixture", "t": 85, "caixa": 0, "rep": 50.0})
    # Pelo `carregar()`, como um arquivo de verdade: a fixture prova também a
    # partição das partidas, e não só as contas sobre elas.
    partidas, _, _ = carregar([json.dumps(l) for l in linhas], "fixture")
    return partidas


def _relatado(partidas):
    saida = io.StringIO()
    with contextlib.redirect_stdout(saida):
        relatar(partidas, 0, 0)
    return saida.getvalue()


def autoteste():
    falhas = []

    def confere(rotulo, ok, detalhe=""):
        if not ok:
            falhas.append("%s%s" % (rotulo, ("  — " + detalhe) if detalhe else ""))

    # As semanas, do cabeçalho.
    pontas = tempos_das_pontas(_fixture())
    confere("a semana 1 são os SETE primeiros dias jogados, e só eles",
            pontas["primeira"] == [1000] * 7, str(pontas["primeira"]))
    confere("a última semana é a 12, com os sete últimos dias",
            pontas["ultima"] == [12000] * 7, str(pontas["ultima"]))
    confere("e o leitor sabe que são doze", pontas["semanas"] == {12}, str(pontas["semanas"]))
    confere("e não conta a partida como sem calendário", pontas["sem_calendario"] == 0)
    texto = _relatado(_fixture())
    confere("o texto publica a semana 12 como a última", "semana 12 (a última)" in texto)

    # Sem o campo, não sabe — e diz que não sabe.
    pontas = tempos_das_pontas(_fixture(versao=1, com_calendario=False, com_prontas=False))
    confere("registro sem turnos_por_semana não entra nas semanas",
            pontas["primeira"] == [] and pontas["ultima"] == [],
            "primeira=%d ultima=%d" % (len(pontas["primeira"]), len(pontas["ultima"])))
    confere("e conta-se como sem calendário", pontas["sem_calendario"] == 1)
    texto = _relatado(_fixture(versao=1, com_calendario=False, com_prontas=False))
    confere("o texto diz «não sei» e não publica semana nenhuma",
            "não sei em 1 partida" in texto and "por dia ·" not in texto)

    # A obra: pago e pronto.
    obras, soltas = obras_de(_fixture()[0])
    por_id = {o["id"]: o for o in obras}
    confere("o píer 2 foi pago no dia 1 e ficou pronto no 3",
            por_id.get("pier_2", {}).get("pago") == 1 and por_id.get("pier_2", {}).get("pronto") == 3,
            str(por_id.get("pier_2")))
    confere("o armazém pago no dia 10 ficou por acabar (None, não 10)",
            por_id.get("armazem", {}).get("pago") == 10 and por_id.get("armazem", {}).get("pronto") is None,
            str(por_id.get("armazem")))
    confere("e não sobra pronta sem pagamento", soltas == [], str(soltas))
    texto = _relatado(_fixture())
    confere("o texto publica o dia pronto e a obra por acabar",
            "pronta em 1, dia mediano 3" in texto and "1 ficou por acabar" in texto)

    obras, _ = obras_de(_fixture(versao=1, com_calendario=False, com_prontas=False)[0])
    confere("na versão 1 o dia pronto é «não sei», e não «por acabar»",
            all(o["pronto"] is NAO_SEI for o in obras) and len(obras) == 2,
            str([o["pronto"] for o in obras]))

    if falhas:
        print("AUTOTESTE DO LEITOR FALHOU — %d verificação(ões):" % len(falhas))
        for f in falhas:
            print("  FALHA %s" % f)
        return 1
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("arquivos", nargs="*", help="arquivos .jsonl, ou - para ler da entrada padrão")
    ap.add_argument("--pasta", help="lê todos os .jsonl de uma pasta")
    ap.add_argument("--autoteste", action="store_true",
                    help="só a prova do leitor, sem ler registro nenhum")
    args = ap.parse_args()

    # Antes de tudo, e sem ele não há leitura (ver o cabeçalho).
    if autoteste() != 0:
        print("O leitor reprovou o próprio autoteste: não publico leitura nenhuma.")
        return 1
    if args.autoteste:
        print("AUTOTESTE DO LEITOR OK")
        return 0

    fontes = []
    if args.pasta:
        for n in sorted(os.listdir(args.pasta)):
            if n.endswith(".jsonl"):
                fontes.append(os.path.join(args.pasta, n))
    fontes += [a for a in args.arquivos if a != "-"]

    partidas, orfas, ilegiveis = [], 0, 0
    for caminho in fontes:
        with open(caminho, encoding="utf-8") as f:
            ps, o, i = carregar(f, os.path.basename(caminho))
        partidas += ps
        orfas += o
        ilegiveis += i

    if "-" in args.arquivos or (not fontes and not sys.stdin.isatty()):
        ps, o, i = carregar(sys.stdin, "(colado)")
        partidas += ps
        orfas += o
        ilegiveis += i

    if not partidas:
        print("Nenhuma partida encontrada. Aponte arquivos .jsonl, --pasta, ou cole na entrada padrão.")
        return 1

    relatar(partidas, orfas, ilegiveis)
    return 0


if __name__ == "__main__":
    sys.exit(main())
