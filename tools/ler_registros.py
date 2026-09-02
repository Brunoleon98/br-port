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

O `-` existe porque no telefone o registro sai pela área de transferência (o
`user://` do Android é privado da aplicação). Coladas várias partidas de
seguida, elas separam-se sozinhas: cada `"e":"abriu"` começa uma nova.

Espera `LEITURA OK` na última linha.
"""
import argparse
import json
import os
import statistics
import sys

# A forma de evento que este leitor conhece. Registro de outra versão NÃO se
# descarta — ao contrário do save, cujo comentário no `load_game()` explica por
# que ali é o oposto: um save errado estraga a partida em curso, um registro
# velho continua a ser um dado que alguém produziu jogando. Lê-se o que se
# reconhece e DIZ-SE o que ficou de fora.
VERSAO_CONHECIDA = 1

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
        "obras": [o["id"] for o in so(p, "obra")],
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
    print("\n── Quanto tempo se fica num turno ──")
    tempos = [(int(e["t"]), int(e["ms"])) for p in partidas for e in so(p, "turno") if "ms" in e]
    if tempos:
        todos = [ms for _, ms in tempos]
        print("  mediana %s · o mais demorado %s · total jogado %s" % (
            ms_legivel(statistics.median(todos)), ms_legivel(max(todos)),
            ms_legivel(sum(todos))))
        lentos = sorted(tempos, key=lambda x: -x[1])[:5]
        print("  os cinco turnos mais demorados: %s" % ", ".join(
            "t%d (%s)" % (t, ms_legivel(ms)) for t, ms in lentos))
        # Primeira semana contra a última: é onde se vê se o jogo foi
        # aprendido ou só suportado.
        primeiros = [ms for t, ms in tempos if t <= 8]
        ultimos = [ms for t, ms in tempos if t > 24]
        if primeiros and ultimos:
            print("  semana 1: %s por turno · semana 4: %s por turno" % (
                ms_legivel(statistics.median(primeiros)), ms_legivel(statistics.median(ultimos))))
    else:
        print("  (nenhum turno trouxe tempo)")

    # ── 4. AS OBRAS, E QUANDO ──
    print("\n── O porto que se levanta ──")
    quando_obra = {}
    for p in partidas:
        for e in so(p, "obra"):
            quando_obra.setdefault(e["id"], []).append(int(e["t"]))
    if quando_obra:
        for oid in sorted(quando_obra, key=lambda k: statistics.median(quando_obra[k])):
            ts = quando_obra[oid]
            print("  %-12s em %d de %d partidas, turno mediano %d (de t%d a t%d)" % (
                oid, len(ts), len(partidas), statistics.median(ts), min(ts), max(ts)))
    nunca = []
    todas_obras = set()
    for r in resumos:
        todas_obras |= set(r["obras"])
    for r in resumos:
        if not r["obras"]:
            nunca.append(r["quando"][:10])
    if nunca:
        print("  %d partida(s) não construíram NADA." % len(nunca))

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


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("arquivos", nargs="*", help="arquivos .jsonl, ou - para ler da entrada padrão")
    ap.add_argument("--pasta", help="lê todos os .jsonl de uma pasta")
    args = ap.parse_args()

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
