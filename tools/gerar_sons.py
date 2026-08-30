#!/usr/bin/env python3
"""
BR Port — gerador dos efeitos sonoros de rascunho.

POR QUE SINTETIZAR EM VEZ DE ENCOMENDAR
---------------------------------------
Suno e ElevenLabs são serviços web que o Bruno usa à mão; nenhuma sessão aqui
consegue chamá-los. Se a engenharia de áudio esperasse pelos arquivos, o bloco
ficava bloqueado na primeira linha.

Sintetizar resolve duas coisas de uma vez:

1. **Destrava o encanamento.** Bus, autoload, ligação com os sinais,
   anti-empilhamento e sliders de volume ficam todos construídos e testados
   antes de existir um único som "de verdade". Quando os WAV reais chegarem, é
   trocar arquivo por arquivo — o código não muda.
2. **Dá o que verificar.** Com som de duração conhecida dá para afirmar "toca
   0,42 s no evento X" e provar. Som encomendado só se pode ouvir, e ouvir é
   exatamente o que este contêiner não faz (ver §2 do briefing de áudio).

A REGRA QUE VALE PARA TODO ESTE ARQUIVO
---------------------------------------
**Ninguém aqui ouviu estes sons.** Tudo o que se afirma sobre eles é o que a
máquina mede: duração, taxa, pico, valor eficaz, ausência de estouro e — a que
mais importa — ausência de degrau no primeiro e no último quadro, que é o que
produz o "tec" seco na borda. Se soa bem é julgamento do Bruno.

DEPENDÊNCIA
-----------
Nenhuma. `wave`, `array`, `math` e `random` são biblioteca padrão de propósito:
uma ferramenta de repositório que precisa de `pip install` é uma ferramenta que
alguém um dia não vai conseguir rodar.

USO
---
    python3 tools/gerar_sons.py brport_vs/audio/sfx
    python3 tools/gerar_sons.py brport_vs/audio/sfx sfx_ui_click
"""

import array
import math
import os
import random
import sys
import wave

TAXA = 32000          # Nyquist a 16 kHz: chega de sobra para efeito curto, e
                      # é metade do peso de 44,1 kHz num jogo mobile.
PICO = 0.82           # margem para o bus não estourar ao somar dois sons


# ---------------------------------------------------------------- primitivas
def _env(n, ataque, decaimento, sustento=0.0, solta=None):
    """Envelope ADSR em fração da duração. Ataque nunca é zero.

    Ataque zero é o que faz o som começar com um degrau, e degrau é ESTALO —
    o defeito mais comum de efeito sintetizado, e o único que dá para medir
    sem ouvir (ver `conferir` lá embaixo).
    """
    solta = solta if solta is not None else 1.0 - ataque - decaimento
    a, d, s = int(n * ataque), int(n * decaimento), int(n * solta)
    a = max(a, 24)
    corpo = max(n - a - d - s, 0)
    saida = []
    for i in range(a):
        saida.append(i / a)
    for i in range(d):
        saida.append(1.0 - (1.0 - sustento) * (i / max(d, 1)))
    saida += [sustento] * corpo
    for i in range(s):
        saida.append(sustento * (1.0 - i / max(s, 1)))
    while len(saida) < n:
        saida.append(0.0)
    return saida[:n]


def _tom(freq, dur, forma="seno", detune=0.0):
    """Um tom puro. `forma` muda o timbre sem mudar a altura."""
    n = int(TAXA * dur)
    fora = []
    for i in range(n):
        t = i / TAXA
        f = freq * (1.0 + detune * t)
        fase = 2.0 * math.pi * f * t
        if forma == "seno":
            v = math.sin(fase)
        elif forma == "triangulo":
            # Triângulo por série ímpar: três harmônicas chegam, e o corte
            # evita o brilho de serra que soa barato.
            v = sum((-1) ** k / (2 * k + 1) ** 2 * math.sin((2 * k + 1) * fase)
                    for k in range(3)) * 8.0 / (math.pi ** 2)
        elif forma == "quadrada":
            v = sum(math.sin((2 * k + 1) * fase) / (2 * k + 1) for k in range(4))
        else:
            raise ValueError("forma desconhecida: %s" % forma)
        fora.append(v)
    return fora


def _ruido(dur, r):
    return [r.uniform(-1.0, 1.0) for _ in range(int(TAXA * dur))]


def _passa_baixa(sinal, corte):
    """Um pólo só. Basta: aqui o filtro serve para TIRAR O CHIADO agudo do
    ruído branco, não para desenhar uma curva."""
    a = math.exp(-2.0 * math.pi * corte / TAXA)
    y, fora = 0.0, []
    for x in sinal:
        y = (1.0 - a) * x + a * y
        fora.append(y)
    return fora


def _mistura(*partes):
    n = max(len(p) for p in partes)
    fora = [0.0] * n
    for p in partes:
        for i, v in enumerate(p):
            fora[i] += v
    return fora


def _aplica(sinal, envelope, ganho=1.0):
    return [s * e * ganho for s, e in zip(sinal, envelope)]


def _atrasa(sinal, segundos):
    return [0.0] * int(TAXA * segundos) + list(sinal)


def _normaliza(sinal, pico=PICO):
    """Normaliza e garante que a borda começa e acaba em zero.

    O zero forçado nos dois extremos não é preciosismo: sem ele, um som que
    acaba a meio de um ciclo dá um estalo ao parar, e o mesmo som repetido
    vinte vezes por partida vira um tique que ninguém sabe de onde vem.
    """
    m = max(abs(v) for v in sinal) or 1.0
    saida = [v / m * pico for v in sinal]
    borda = max(int(TAXA * 0.004), 8)
    for i in range(borda):
        f = i / borda
        saida[i] *= f
        saida[-1 - i] *= f
    return saida


# ---------------------------------------------------------------- os efeitos
# Cada função devolve a onda pronta. As durações vêm do guia de áudio
# (docs/design/BR_Port_Guia_Audio_Suno_ElevenLabs.md, bloco de SFX) para que a
# troca pelo som real não mexa no ritmo da interface.

def sfx_ui_click(r):
    """Toque na interface. 0,09 s — curto ao ponto de não se notar."""
    dur = 0.09
    corpo = _aplica(_tom(880, dur, "triangulo"), _env(int(TAXA * dur), 0.06, 0.5))
    pele = _aplica(_passa_baixa(_ruido(dur, r), 2600),
                   _env(int(TAXA * dur), 0.02, 0.28), 0.35)
    return _normaliza(_mistura(corpo, pele), 0.55)


def sfx_ui_success(r):
    """Deu certo. Duas notas subindo (dó5 → sol5): intervalo de quinta, que é
    o que o ouvido lê como resolução sem precisar de acorde."""
    a = _aplica(_tom(523.25, 0.16, "triangulo"), _env(int(TAXA * 0.16), 0.05, 0.6))
    b = _aplica(_tom(783.99, 0.26, "triangulo"), _env(int(TAXA * 0.26), 0.04, 0.7))
    return _normaliza(_mistura(a, _atrasa(b, 0.14)))


def sfx_ui_warn(r):
    """Não deu, mas não é grave — doca vazia, trabalhador já alocado.
    Duas notas descendo pouco: avisa sem repreender."""
    a = _aplica(_tom(392.00, 0.13, "triangulo"), _env(int(TAXA * 0.13), 0.05, 0.6))
    b = _aplica(_tom(329.63, 0.20, "triangulo"), _env(int(TAXA * 0.20), 0.05, 0.7))
    return _normaliza(_mistura(a, _atrasa(b, 0.11)), 0.72)


def sfx_ui_error(r):
    """Deu errado de verdade — cliente foi embora, caixa insuficiente.
    Mais grave e mais longo que o aviso, e com um leve batimento de duas
    frequências próximas, que é o que soa 'errado' sem ser estridente."""
    n = int(TAXA * 0.34)
    env = _env(n, 0.03, 0.35, 0.42)
    a = _aplica(_tom(220.00, 0.34, "quadrada"), env, 0.6)
    b = _aplica(_tom(207.65, 0.34, "triangulo"), env, 0.5)
    return _normaliza(_mistura(a, b), 0.70)


def sfx_moeda(r):
    """Entrou dinheiro. Três parciais altas e desafinadas entre si: é assim
    que metal soa, e é por isso que um seno puro nunca soa a moeda."""
    partes = []
    for i, (f, atraso, g) in enumerate([(1860, 0.0, 1.0), (2490, 0.045, 0.8),
                                        (3130, 0.085, 0.6)]):
        dur = 0.24 - i * 0.04
        s = _aplica(_tom(f, dur, "seno"), _env(int(TAXA * dur), 0.01, 0.9), g)
        partes.append(_atrasa(s, atraso))
    return _normaliza(_mistura(*partes), 0.62)


def sfx_alerta(r):
    """Atenção — oferta do rival, parcela vencendo. Dois toques iguais, que é
    a forma universal de alarme sem ser sirene."""
    def toque():
        n = int(TAXA * 0.15)
        return _aplica(_tom(659.25, 0.15, "quadrada"), _env(n, 0.04, 0.5), 0.7)
    return _normaliza(_mistura(toque(), _atrasa(toque(), 0.22)), 0.72)


def sfx_navio_chega(r):
    """Apito de navio. Fundamental grave com harmônicas e ataque LENTO — é a
    lentidão do ataque que dá o tamanho: som grande demora a nascer."""
    dur = 1.10
    n = int(TAXA * dur)
    env = _env(n, 0.22, 0.18, 0.72)
    camadas = [_aplica(_tom(f, dur, "seno", detune=-0.004), env, g)
               for f, g in [(116.0, 1.0), (174.0, 0.55), (232.0, 0.30),
                            (349.0, 0.12)]]
    sopro = _aplica(_passa_baixa(_ruido(dur, r), 700), env, 0.10)
    return _normaliza(_mistura(*camadas, sopro), 0.68)


def sfx_construir(r):
    """Estrutura pronta. Pancada de madeira: um baque grave que cai depressa,
    mais um estalo de tábua por cima."""
    baque = _aplica(_tom(96.0, 0.30, "seno", detune=-0.35),
                    _env(int(TAXA * 0.30), 0.006, 0.85))
    tabua = _aplica(_passa_baixa(_ruido(0.16, r), 1900),
                    _env(int(TAXA * 0.16), 0.004, 0.7), 0.55)
    tilim = _aplica(_tom(1244.5, 0.22, "seno"), _env(int(TAXA * 0.22), 0.02, 0.85), 0.30)
    return _normaliza(_mistura(baque, tabua, _atrasa(tilim, 0.06)), 0.78)


def sfx_vitoria(r):
    """Fim de jogo, ganhou. Arpejo maior de quatro notas — dó, mi, sol, dó."""
    partes = []
    for i, f in enumerate([523.25, 659.25, 783.99, 1046.50]):
        dur = 0.34 if i == 3 else 0.20
        s = _aplica(_tom(f, dur, "triangulo"), _env(int(TAXA * dur), 0.04, 0.55, 0.35))
        partes.append(_atrasa(s, i * 0.115))
    return _normaliza(_mistura(*partes))


def sfx_derrota(r):
    """Fim de jogo, perdeu. As mesmas quatro notas ao contrário e em menor —
    a simetria com a vitória é de propósito: o jogador reconhece a forma e
    percebe que ela desabou."""
    partes = []
    for i, f in enumerate([523.25, 415.30, 349.23, 261.63]):
        dur = 0.46 if i == 3 else 0.24
        s = _aplica(_tom(f, dur, "triangulo"), _env(int(TAXA * dur), 0.05, 0.5, 0.4))
        partes.append(_atrasa(s, i * 0.145))
    return _normaliza(_mistura(*partes), 0.74)


EFEITOS = {
    "sfx_ui_click": sfx_ui_click,
    "sfx_ui_success": sfx_ui_success,
    "sfx_ui_warn": sfx_ui_warn,
    "sfx_ui_error": sfx_ui_error,
    "sfx_moeda": sfx_moeda,
    "sfx_alerta": sfx_alerta,
    "sfx_navio_chega": sfx_navio_chega,
    "sfx_construir": sfx_construir,
    "sfx_vitoria": sfx_vitoria,
    "sfx_derrota": sfx_derrota,
}

# Semente fixa por efeito: o ruído entra em três deles, e sem semente o mesmo
# comando devolvia um arquivo diferente a cada rodada — o que faz um `git
# diff` acusar mudança onde não houve nenhuma.
SEMENTE = 20260830


# ---------------------------------------------------------------- escrita
def gravar(caminho, sinal):
    dados = array.array("h")
    for v in sinal:
        dados.append(int(max(-1.0, min(1.0, v)) * 32767))
    with wave.open(caminho, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(TAXA)
        f.writeframes(dados.tobytes())


def conferir(nome, sinal):
    """O que dá para afirmar sobre um som sem o ouvir.

    O degrau de borda é o que mais importa: é ele que vira estalo, e é o
    defeito que passa despercebido justamente por quem não consegue ouvir.
    """
    n = len(sinal)
    pico = max(abs(v) for v in sinal)
    eficaz = math.sqrt(sum(v * v for v in sinal) / n)
    borda = max(abs(sinal[0]), abs(sinal[-1]))
    # Cruzamentos por zero: proxy grosseiro de brilho. Serve para separar um
    # apito grave de um tilintar agudo sem análise espectral.
    cruz = sum(1 for i in range(1, n)
               if (sinal[i - 1] < 0) != (sinal[i] < 0)) * TAXA / n / 2.0
    ok = pico <= 1.0 and borda < 0.002 and n > 0
    print("  %-18s %6.0f ms  pico %.2f  eficaz %.3f  borda %.5f  ~%5.0f Hz  %s"
          % (nome, n / TAXA * 1000.0, pico, eficaz, borda, cruz,
             "ok" if ok else "PROBLEMA"))
    return ok


# O Godot 4.4+ importa WAV como QOA (`compress/mode=2`), que é compressão COM
# PERDAS. Para música seria a escolha certa; para um clique de 90 ms não é —
# o conjunto inteiro tem 320 kB, e trocar isso por artefato num som que ninguém
# aqui consegue ouvir é um mau negócio. O `.import` é escrito pelo Godot, mas
# os `[params]` ele preserva: acertar aqui basta, e fica junto de quem gera os
# arquivos em vez de virar um passo manual que alguém esquece.
def pcm_sem_perdas(destino: str, nomes) -> int:
    ajustados, faltando = 0, []
    for nome in nomes:
        caminho = "%s/%s.wav.import" % (destino, nome)
        if not os.path.exists(caminho):
            faltando.append(nome)
            continue
        texto = open(caminho, encoding="utf-8").read()
        if "compress/mode=0" in texto:
            continue
        novo_texto = texto.replace("compress/mode=2", "compress/mode=0") \
                          .replace("compress/mode=1", "compress/mode=0")
        if novo_texto != texto:
            open(caminho, "w", encoding="utf-8").write(novo_texto)
            ajustados += 1
    if ajustados:
        print("\n%d .import passado(s) para PCM sem perdas (compress/mode=0)."
              % ajustados)
    if faltando:
        print("\n%d arquivo(s) ainda sem .import: %s"
              % (len(faltando), ", ".join(faltando)))
        print("Rode o Godot com --import e depois este script outra vez, para")
        print("que eles também saiam de QOA. O teste de áudio pega se ficar.")
    return ajustados


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if not args:
        print(__doc__.strip().splitlines()[-1])
        return 2
    destino = args[0].rstrip("/")
    pedidos = args[1:] or sorted(EFEITOS)

    desconhecidos = [p for p in pedidos if p not in EFEITOS]
    if desconhecidos:
        print("efeito desconhecido: %s" % ", ".join(desconhecidos))
        print("disponíveis: %s" % ", ".join(sorted(EFEITOS)))
        return 2

    os.makedirs(destino, exist_ok=True)
    print("gerando %d efeito(s) a %d Hz, 16 bits, mono:" % (len(pedidos), TAXA))
    tudo_ok = True
    for nome in pedidos:
        r = random.Random(SEMENTE + sum(ord(c) for c in nome))
        sinal = EFEITOS[nome](r)
        gravar("%s/%s.wav" % (destino, nome), sinal)
        tudo_ok &= conferir(nome, sinal)

    pcm_sem_perdas(destino, pedidos)

    print("\nNINGUÉM AQUI OUVIU ISTO. Os números acima são o que a máquina "
          "mede;\nse presta é julgamento de quem tem placa de som.")
    return 0 if tudo_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
