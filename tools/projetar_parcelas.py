#!/usr/bin/env python3
"""Projeta as Parcelas 2 e 3 do GDD a partir da Fase 1 MEDIDA no jogo.

Segunda metade do item A2 da fila do Plano v3. A errata da economia
(`BR_Port_GDD_V7_ERRATA_ECONOMIA.md`) deixou escrito que a Parcela 1 foi
revalidada por medição e que as Parcelas 2 (R$16.000, semana 8) e 3 (R$24.000,
semana 12) seguem **não verificadas** — não erradas, desconhecidas.

O QUE ISTO É, E O QUE NÃO É. Verificar as Parcelas 2 e 3 por MEDIÇÃO exigiria
um jogo com as Fases 2 e 3 implementadas, e a própria errata diz que construir
isso antes de o Vertical Slice sair é a ordem errada. Então aqui não se mede:
projeta-se. O que torna a projeção defensável, e não mais um modelo de
planilha como o que já falhou uma vez, são duas amarras:

  1. Os números da Fase 1 NÃO são digitados. Vêm de `simular_balanceamento.gd`
     (a economia da semana em regime, medida no jogo que existe) e de
     `despejar_constantes.gd` (as constantes que o jogo usa de verdade).
  2. O modelo tem de RECONSTRUIR a Fase 1 medida antes de ter licença para
     falar das outras duas. Se ele erra a semana que dá para conferir, não há
     razão para acreditar nas que não dão — e o programa recusa-se a projetar.

As faixas de contrato e os valores das parcelas saem do GDD 7 lido no disco,
não de constantes copiadas para cá: era a cópia que envelhecia.

    python3 tools/projetar_parcelas.py --medicao m.json --constantes c.json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GDD = RAIZ / "docs" / "design" / "BR_Port_GDD_V7.jsx"

# O modelo tem de errar menos do que isto na Fase 1 para poder falar das
# outras. 5% é folgado o bastante para o ruído de 600 partidas e apertado o
# bastante para reprovar um modelo que perdeu uma parcela da conta.
TOLERANCIA = 0.05

# ⚠️ O PORTÃO PRECISA DE UMA MEDIÇÃO, E 30 PARTIDAS NÃO SÃO UMA MEDIÇÃO. É o
# que o próprio simulador imprime em letras garrafais na rodada curta, e o CI
# alimentava este portão com esse número — até 06/09, quando ele reprovou o
# Mediano por 5,4% contra uma tolerância de 5%.
#
# O modelo estava certo. Medido com cinco sementes a 30 partidas, a MARGEM EM
# REGIME oscila sozinha: o Ótimo entre R$604.597 e R$722.194 (±9% em torno dos
# R$674.019 de 600 partidas), o Mediano entre R$446.201 e R$502.417 (±6%), o
# Descuidado entre R$87.335 e R$106.535 (±9%). Comparar um modelo contra um
# alvo que se move mais do que a tolerância é um portão que reprova por
# sorteio — e a semente do CI calhava dar o Mediano mais baixo dos cinco.
#
# O corte é o mesmo que o simulador usa para separar medida de fumaça. Abaixo
# dele o portão RECLAMA em vez de calar-se ou de acusar o modelo: dizer "não
# sei" alto é o que impede que ele volte a ser alimentado com sorteio.
PARTIDAS_PARA_CALIBRAR = 100

# ...E UM PISO ABSOLUTO, em barcos. A percentagem sozinha deixou de servir
# quando a economia passou a ter CUSTO FIXO GRANDE (manutenção de R$40.000/sem
# contra o R$30 de antes, em 02/09): a margem de um perfil de baixa vazão passou
# a ser a diferença pequena entre dois números grandes, e aí um erro absoluto
# irrelevante vira uma percentagem enorme.
#
# Medido no dia em que isto apareceu: o perfil Descuidado dava 6,6% de erro
# sobre uma diferença de R$6.586/semana — um quarto de barco — enquanto os
# outros dois davam 0,1% e 0,5%. Um modelo partido não erra em UM perfil só.
#
# O piso é meio barco médio porque barco é a unidade natural desta economia, e
# porque metade de um é pequeno o suficiente para não deixar passar a mudança
# de constante que este portão existe para pegar: mexer num `# TUNING:` desloca
# a margem em vários barcos, não em meio.
PISO_EM_BARCOS = 0.5


class ModeloNaoCalibra(Exception):
    pass


def ler_faixas_do_gdd(gdd: Path) -> dict[int, tuple[int, int]]:
    """Faixas de valor de contrato por fase, do card "Valor de contratos"."""
    texto = gdd.read_text(encoding="utf-8")
    faixas: dict[int, tuple[int, int]] = {}
    for m in re.finditer(
        r"Fase (\d+): R\$\s?([\d.]+)[–-]([\d.]+)", texto
    ):
        fase = int(m.group(1))
        lo = int(m.group(2).replace(".", ""))
        hi = int(m.group(3).replace(".", ""))
        faixas.setdefault(fase, (lo, hi))
    if not faixas:
        raise ModeloNaoCalibra(
            "não achei as faixas de contrato no GDD — o card 'Valor de "
            "contratos' mudou de forma?")
    return faixas


def ler_parcelas_do_gdd(gdd: Path) -> dict[int, tuple[int, int]]:
    """Parcela -> (semana, valor), do card "Parcelas validadas"."""
    texto = gdd.read_text(encoding="utf-8")
    parcelas: dict[int, tuple[int, int]] = {}
    for m in re.finditer(
        r"Parcela (\d+) \(sem\.? (\d+)\): R\$\s?([\d.]+)", texto
    ):
        parcelas.setdefault(
            int(m.group(1)),
            (int(m.group(2)), int(m.group(3).replace(".", ""))))
    if len(parcelas) < 3:
        raise ModeloNaoCalibra(
            "não achei as três parcelas no GDD — o card 'Parcelas validadas' "
            "mudou de forma?")
    return parcelas


def faixas_das_classes(faixa: tuple[int, int], k: dict) -> dict:
    """Onde cai a faixa de cada CLASSE de navio dentro da faixa de uma fase.

    O jogo não sorteia uniforme entre os extremos: cada classe tem a sua faixa,
    e o GDD só dá o mínimo e o máximo de cada fase. O que se leva da Fase 1
    para as outras são as PROPORÇÕES — onde começa e acaba o pesqueiro dentro
    do intervalo total, onde o cargueiro, onde o longo curso. Inventar uma
    uniforme seria enfeitar a conta a favor da conclusão.
    """
    classes = k["CLASSES_DE_NAVIO"]
    base_lo = min(float(c["valor_min"]) for c in classes.values())
    base_hi = max(float(c["valor_max"]) for c in classes.values())
    largura = max(base_hi - base_lo, 1e-9)
    lo, hi = faixa
    out = {}
    for nome, c in classes.items():
        f_min = (float(c["valor_min"]) - base_lo) / largura
        f_max = (float(c["valor_max"]) - base_lo) / largura
        out[nome] = (lo + f_min * (hi - lo), lo + f_max * (hi - lo))
    return out


def mistura_de_classes(k: dict, niveis: dict) -> dict:
    """Com que frequência cada CLASSE de navio chega, dado até que nível o
    porto do perfil chegou.

    ⚠️ ISTO NÃO SE DEDUZ DAS FRAÇÕES DE ESTRUTURA, e foi por isso que a medição
    passou a exportar `niveis` em 06/09. O nível 2 é "duas estruturas
    quaisquer": somar a fração do armazém com a do pátio não diz em quantas
    partidas houve DUAS ao mesmo tempo. E o nível é o que decide tudo aqui —
    o perfil Descuidado chega ao nível 2 em 96% das partidas e ao 3 em
    NENHUMA, então o navio de longo curso não existe na economia dele.

    Os pesos renormalizam-se dentro das classes disponíveis, exatamente como o
    `_sortear_classe()` do jogo faz: um porto de nível 1 vê só pesqueiro, e o
    peso das outras redistribui-se sem nenhum número escrito para esse caso.
    """
    classes = k["CLASSES_DE_NAVIO"]
    out = {nome: 0.0 for nome in classes}
    for nivel_txt, frac in niveis.items():
        if frac <= 0.0:
            continue
        nivel = int(nivel_txt)
        disponiveis = {n: c for n, c in classes.items()
                       if int(c["nivel"]) <= nivel}
        soma = sum(float(c["peso"]) for c in disponiveis.values())
        if soma <= 0.0:
            continue
        for nome, c in disponiveis.items():
            out[nome] += frac * float(c["peso"]) / soma
    return out


def valor_medio(faixa: tuple[int, int], k: dict, niveis: dict) -> float:
    """Valor bruto médio de um navio, na FORMA que o jogo usa."""
    faixas = faixas_das_classes(faixa, k)
    mistura = mistura_de_classes(k, niveis)
    total = 0.0
    for nome, (lo, hi) in faixas.items():
        total += mistura[nome] * (lo + hi) / 2.0
    return total


def valor_com_motivos(faixa: tuple[int, int], k: dict, niveis: dict,
                      estruturas: dict) -> float:
    """O valor médio recebido: o bruto MAIS o que a estrutura acrescenta.

    ⚠️ O BÓNUS DEIXOU DE SER UM MULTIPLICADOR ÚNICO EM 06/09, e um modelo que o
    trate como tal erra para os dois lados de uma vez. Ele depende do MOTIVO do
    barco, e o motivo sorteia-se DENTRO DA CLASSE — o armazém paga em 45% dos
    pesqueiros e 25% dos navios de longo curso, o pátio não paga em pesqueiro
    nenhum. Como a trava do nível decide quais classes chegam, quem levanta o
    porto muda também a frequência de cada bónus, sem nenhuma constante de
    valor ter mudado. O portão de calibração reprova se esta conta voltar a
    somar +50% em tudo: medido nesse estado, ele saiu 15,7% acima do medido.
    """
    faixas = faixas_das_classes(faixa, k)
    mistura = mistura_de_classes(k, niveis)
    classes = k["CLASSES_DE_NAVIO"]
    total = 0.0
    for nome, (lo, hi) in faixas.items():
        medio = (lo + hi) / 2.0
        pesos = classes[nome]["motivos"]
        soma = sum(float(v) for v in pesos.values())
        if soma <= 0.0:
            continue
        for motivo, peso in pesos.items():
            dados = k["MOTIVOS"][motivo]
            estrutura = str(dados["estrutura"])
            bonus = 0.0
            if estrutura:
                bonus = float(dados["bonus"]) * estruturas.get(estrutura, 0.0)
            total += mistura[nome] * (float(peso) / soma) * medio * (1.0 + bonus)
    return total


def desconto_medio_do_rival(k: dict, barcos_por_semana: float) -> float:
    """Quanto o Arlindo custa, em média, por real de contrato.

    Só uma fração dos barcos recebe oferta (no máximo uma por turno, e só
    quando algum barco chegou), e sobre essa fração o desconto depende de como
    o jogador negoceia. Modela-se o jogador que arrisca o meio-termo e recua —
    o mesmo do perfil Ótimo.

    LIMITAÇÃO CONHECIDA, e medida: desde o A3 a reputação mexe na chance de o
    cliente aceitar, e esta conta não sabe disso — usa as constantes cruas. O
    efeito é uma sobreestimação do desconto para quem tem reputação alta, e em
    01/09 ela cabia folgadamente na tolerância (erros de 1,4% / 0,1% / 1,3%
    nos três perfis). Quem AUMENTAR `REPUTACAO_EFEITO_NEGOCIACAO` deve olhar
    para o portão de calibração antes de olhar para a projeção: é ele que vai
    reclamar primeiro.
    """
    turnos = float(k["TURNS_PER_WEEK"])
    ofertas = turnos * float(k["RIVAL_TRIGGER_CHANCE"])
    fracao = min(1.0, ofertas / max(barcos_por_semana, 1e-9))
    aceita = float(k["RIVAL_HALF_CHANCE"])
    esperado = (aceita * float(k["RIVAL_HALF_DISCOUNT"])
                + (1.0 - aceita) * float(k["RIVAL_DISCOUNT_AFTER_FAIL"]))
    return fracao * esperado


PORTO_COMPLETO = {"armazem": 1.0, "patio": 1.0, "escritorio": 1.0}


def margem_semanal(k: dict, barcos: float, faixa: tuple[int, int],
                   trabalhadores: float, passivo_extra: int,
                   estruturas: dict, niveis: dict) -> dict:
    """A conta de uma semana, na mesma ordem em que o jogo a faz.

    `estruturas` é a FRAÇÃO das partidas em que cada uma acabou de pé, e não um
    sim/não. O perfil Descuidado levanta o armazém em 96% das partidas e o
    terceiro píer em nenhuma: arredondar isso para "tem" ou "não tem" seria
    projetar um porto que ninguém joga.
    """
    bruto = valor_medio(faixa, k, niveis)
    liquido = valor_com_motivos(faixa, k, niveis, estruturas)
    liquido *= (1.0 - desconto_medio_do_rival(k, barcos))
    contratos = barcos * liquido

    pier = k["PIER_SLOTS"] * k["PIER_RATE_PER_SLOT"]
    pier *= 1.0 + float(k["PATIO_BONUS_PIER"]) * estruturas.get("patio", 0.0)
    passivo = pier + passivo_extra

    salarios = (k["SALARY_PER_WORKER"] * trabalhadores
                * (1.0 - float(k["ESCRITORIO_DESCONTO_SALARIO"])
                   * estruturas.get("escritorio", 0.0)))
    custos = salarios + k["MAINTENANCE_WEEKLY"]

    return {
        "barcos": barcos, "valor_bruto": bruto, "valor_liquido": liquido,
        "contratos": contratos, "passivo": passivo, "custos": custos,
        "trabalhadores": trabalhadores,
        "margem": contratos + passivo - custos,
    }


def calibrar(k: dict, medicao: dict, faixas: dict) -> list[str]:
    """O modelo reconstrói a Fase 1 medida? Se não, não fala das outras.

    Os três perfis entram, inclusive o que perde sempre. Calibrar só contra o
    porto bem jogado seria escolher o caso que favorece o modelo — e o perfil
    Descuidado é o mais exigente dos três, porque o porto dele está incompleto
    e a conta tem de acertar mesmo assim.
    """
    partidas = int(medicao.get("partidas", 0))
    if partidas < PARTIDAS_PARA_CALIBRAR:
        raise ModeloNaoCalibra(
            "a medição tem %d partidas por perfil, e o portão precisa de pelo "
            "menos %d.\n"
            "  Abaixo disso a MARGEM MEDIDA oscila mais do que a tolerância de "
            "%.0f%% — medido\n"
            "  em 06/09: ±6%% a ±9%% conforme a semente. Reprovar aí seria "
            "reprovar sorteio,\n"
            "  e aprovar seria aprovar sorteio.\n"
            "  Rode `simular_balanceamento.gd -- 600 20260825 <saida.json>` e "
            "passe esse arquivo."
            % (partidas, PARTIDAS_PARA_CALIBRAR, 100 * TOLERANCIA))

    queixas = []
    for nome, dados in medicao["perfis"].items():
        barcos = float(dados["atendidos_em_regime"])
        medido = float(dados["margem_em_regime"])
        if barcos <= 0:
            continue
        previsto = margem_semanal(
            k, barcos, faixas[1], float(dados["trabalhadores_medios"]), 0,
            dados["estruturas"], dados["niveis"])["margem"]
        desvio = abs(previsto - medido)
        erro = desvio / max(abs(medido), 1.0)
        # Passa por percentagem OU por piso absoluto — ver PISO_EM_BARCOS.
        piso = PISO_EM_BARCOS * valor_medio(faixas[1], k, dados["niveis"])
        passa = erro <= TOLERANCIA or desvio <= piso
        marca = "ok" if passa else "FORA"
        queixas.append("  %-11s medido R$%-7d  modelo R$%-7d  erro %5.1f%%  %s"
                       % (nome, round(medido), round(previsto), 100 * erro, marca))
        if passa and erro > TOLERANCIA:
            queixas.append("    (passa pelo piso: desvio de R$%d < meio barco, R$%d)"
                           % (round(desvio), round(piso)))
        if not passa:
            queixas.append("    ↑ acima da tolerância de %.0f%% E de meio barco (R$%d)"
                           % (100 * TOLERANCIA, round(piso)))
    return queixas


def main() -> int:
    # `ModeloNaoCalibra` sai como MENSAGEM e não como traceback: ela existe
    # para ser lida por quem vê o CI vermelho, e uma pilha de chamadas em cima
    # dela esconde a única linha que interessa.
    try:
        return _main()
    except ModeloNaoCalibra as e:
        print("O modelo não tem licença para projetar:\n  %s" % e,
              file=sys.stderr)
        return 1


def _main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--medicao", required=True,
                   help="JSON de simular_balanceamento.gd -- N SEMENTE saida.json")
    p.add_argument("--constantes", required=True,
                   help="JSON de despejar_constantes.gd")
    p.add_argument("--perfil", default="Ótimo",
                   help="perfil a projetar (padrão: Ótimo)")
    args = p.parse_args()

    medicao = json.loads(Path(args.medicao).read_text(encoding="utf-8"))
    k = json.loads(Path(args.constantes).read_text(encoding="utf-8"))
    faixas = ler_faixas_do_gdd(GDD)
    # ⚠️ A FASE 1 SAI DO CÓDIGO, NÃO DO GDD, e é a regra do projeto: onde os
    # dois divergirem, quem manda é o código. Divergiram em 06/09 — o GDD tem
    # R$8.000–70.000 e as classes de navio passaram a ir de R$12.000 a
    # R$88.000 —, e o portão reprovou os TRÊS perfis por ~23% de uma vez. Três
    # fora ao mesmo tempo nunca é métrica: é o modelo a ler a faixa errada. As
    # Fases 2 e 3 continuam a sair do GDD, porque delas o código não sabe nada.
    classes = k["CLASSES_DE_NAVIO"]
    faixas[1] = (min(int(c["valor_min"]) for c in classes.values()),
                 max(int(c["valor_max"]) for c in classes.values()))
    parcelas = ler_parcelas_do_gdd(GDD)
    # E a Parcela 1 também: o GDD tem R$550.000 congelados e o jogo cobra o que
    # está em `PARCELA_AMOUNT`. Imprimir o número do GDD ao lado de uma Fase 1
    # medida com outro seria a mesma divergência calada, um campo ao lado.
    parcelas[1] = (parcelas[1][0], int(k["PARCELA_AMOUNT"]))

    print("=== Parcelas 2 e 3 — projeção a partir da Fase 1 medida ===")
    print("Medição: %d partidas por perfil, semente %d (simular_balanceamento.gd)"
          % (medicao["partidas"], medicao["semente"]))
    print("GDD: faixas %s · parcelas %s"
          % ({f: "R$%d–%d" % v for f, v in sorted(faixas.items()) if f <= 3},
             {n: "R$%d (sem. %d)" % (v[1], v[0]) for n, v in sorted(parcelas.items())}))
    print("")

    print("1. O modelo reconstrói a semana em REGIME da Fase 1?")
    linhas = calibrar(k, medicao, faixas)
    print("\n".join(linhas))
    if any("FORA" in l for l in linhas):
        print("")
        print("O modelo não reproduz a Fase 1 que dá para medir. Ele não tem "
              "licença\npara falar das Fases 2 e 3 — corrija-o antes de olhar "
              "para os números\nabaixo, que não foram calculados.")
        return 1
    print("  → calibrado. O modelo pode falar das Fases 2 e 3.\n")

    perfil = medicao["perfis"][args.perfil]
    barcos_f1 = float(perfil["atendidos_em_regime"])
    docas = max(1.0, float(perfil["docas_medias"]))
    trabalhadores_f1 = float(perfil["trabalhadores_medios"])
    semanas_por_fase = k["WEEKS_TOTAL"]

    # DUAS leituras, porque a diferença entre elas é uma decisão de design que
    # ninguém tomou ainda: o porto para de crescer depois da Fase 1, ou
    # continua? O GDD tem "Doca extra: R$1.200" no card de custos de
    # construção, mas não diz quantas por fase.
    cenarios = {
        "porto parado": {"docas_por_fase": 0, "passivo_por_fase": 0},
        "porto cresce": {"docas_por_fase": 1, "passivo_por_fase": 300},
    }

    for nome_cenario, cfg in cenarios.items():
        print("2. Cenário «%s» — perfil %s" % (nome_cenario, args.perfil))
        if cfg["docas_por_fase"]:
            print("   +%d doca e +%d trabalhador por fase; armazém alugado "
                  "R$%d/sem a partir da Fase 2 (GDD, 'Renda passiva semanal')"
                  % (cfg["docas_por_fase"], cfg["docas_por_fase"],
                     cfg["passivo_por_fase"]))
        else:
            print("   o porto fica como acaba a Fase 1: %.0f docas, nada de novo. "
                  "Só o\n   valor do contrato sobe, como o GDD manda." % docas)
        print("")
        print("   %-6s │ %-13s │ %8s │ %9s │ %10s │ %11s │ %s"
              % ("Fase", "Contrato", "Barcos", "Margem/sem", "4 semanas",
                 "Parcela", "Sobra"))

        # O jogador entra na semana 5 com caixa ZERO: acabou de pagar a
        # Parcela 1. É o pior caso honesto — quem chegou lá com folga só tem
        # mais.
        caixa = 0.0
        for fase in (2, 3):
            d = docas + cfg["docas_por_fase"] * (fase - 1)
            barcos = barcos_f1 * (d / docas)
            trabalhadores = trabalhadores_f1 + cfg["docas_por_fase"] * (fase - 1)
            passivo = cfg["passivo_por_fase"] * (fase - 1)
            # O porto das fases seguintes é o que acabou a Fase 1: o mesmo
            # nível, e por isso as mesmas classes de navio a atracar.
            m = margem_semanal(k, barcos, faixas[fase], trabalhadores, passivo,
                               perfil["estruturas"], perfil["niveis"])
            acumulado = m["margem"] * semanas_por_fase
            caixa += acumulado
            semana, valor = parcelas[fase]
            sobra = caixa - valor
            print("   %-6d │ R$%-4d–%-6d │ %8.1f │ R$%8d │ R$%8d │ R$%9d │ %s"
                  % (fase, faixas[fase][0], faixas[fase][1], barcos,
                     round(m["margem"]), round(acumulado), valor,
                     ("+R$%d (%.1f×)" % (round(sobra), caixa / valor))
                     if sobra >= 0 else "FALTA R$%d" % round(-sobra)))
            caixa -= valor
        print("")

    # A leitura sai da conta, não de quem lê a tabela. O ponto não é se as
    # parcelas fecham: é a VELOCIDADE relativa das duas curvas.
    print("=== Leitura ===")
    # O contrato médio de um PORTO COMPLETO: é a comparação que interessa
    # entre fases, e é a única leitura em que o nível não varia — quem chega à
    # Fase 2 chegou lá com o porto de pé.
    porto_no_topo = {"1": 0.0, "2": 0.0, "3": 1.0}
    v1 = valor_medio(faixas[1], k, porto_no_topo)
    v2 = valor_medio(faixas[2], k, porto_no_topo)
    v3 = valor_medio(faixas[3], k, porto_no_topo)
    _, p1 = parcelas[1]
    _, p2 = parcelas[2]
    _, p3 = parcelas[3]
    print("· Valor médio de contrato: R$%d → R$%d → R$%d (×%.1f, depois ×%.1f)"
          % (round(v1), round(v2), round(v3), v2 / v1, v3 / v2))
    print("· Parcela:                 R$%d → R$%d → R$%d (×%.1f, depois ×%.1f)"
          % (p1, p2, p3, p2 / p1, p3 / p2))
    print("")
    if v2 / v1 > p2 / p1 and v3 / v2 > p3 / p2:
        print("· A RECEITA CRESCE MAIS DEPRESSA QUE A DÍVIDA, nas duas passagens de")
        print("  fase. É por isso que as Parcelas 2 e 3 fecham com tanta folga — e")
        print("  também por que a pressão da Fase 1 desaparece a partir da semana 5.")
        print("")
        print("  E ISTO É DE PROPÓSITO desde 02/09 — ver")
        print("  docs/decisoes/005-o-jogo-e-tranquilo-a-divida-nao-e-o-motor.md.")
        print("  A dívida é o motor da Fase 1 e mais nada; o que pressiona daí em")
        print("  diante é a EXPANSÃO e a MANUTENÇÃO. Uma folga grande aqui não é")
        print("  um defeito da economia: é o desenho escolhido.")
        print("")
        # A TAXA SAI DA MEDIÇÃO, e não escrita à mão. Esta prosa dizia "a Fase 1
        # mede 47%" — verdade até 02/09 e mentira no dia seguinte, impressa no
        # log do CI a cada corrida. Número em prosa é um número a mais para
        # envelhecer, que é o problema que a tabela dos números existe para
        # resolver; aqui o valor vem do JSON que acabou de ser medido.
        mediano = medicao["perfis"].get("Mediano")
        if mediano is None or "taxa" not in mediano:
            # Barulhento de propósito. Se a forma da medição mudar, isto tem de
            # aparecer — um bloco que se cala sozinho é como o número cravado
            # volta sem ninguém reparar.
            print("  ⚠️  não achei a taxa do perfil Mediano na medição — o formato")
            print("      de simular_balanceamento.gd mudou?")
        else:
            partidas = int(medicao.get("partidas", 0))
            print("  O jogador mediano ganha %.1f%% na Fase 1 — medido nesta mesma"
                  % float(mediano["taxa"]))
            print("  corrida, com %d partidas por perfil%s." % (
                partidas,
                " (amostra de fumaça: ±18 pontos)" if partidas < 200 else ""))
            print("  As fases seguintes seriam mais folgadas ainda. Quem decide se")
            print("  isso é o desejado não é esta ferramenta — a decisão 005 já disse")
            print("  que sim.")
    else:
        print("· A dívida cresce pelo menos tão depressa quanto a receita. A tensão")
        print("  da Fase 1 sobrevive às fases seguintes.")
    print("")
    print("NOTA — isto é PROJEÇÃO, não medição. A Fase 1 acima é medida no jogo")
    print("que existe; as Fases 2 e 3 são a mesma conta com os números que o GDD")
    print("dá para elas. Vira medição quando as Fases 2 e 3 estiverem")
    print("implementadas — e a errata é explícita em que isso não se faz antes de")
    print("o Vertical Slice sair.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
