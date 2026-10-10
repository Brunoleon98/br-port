---
paths:
  - "brport_vs/autoload/Audio.gd"
  - "brport_vs/audio/**"
  - "brport_vs/scripts/AmbienteCosteiro.gd"
  - "brport_vs/scripts/PainelAjustes.gd"
  - "brport_vs/tests/teste_audio.gd"
  - "tools/gerar_sons.py"
  - "tools/medir_audio.py"
  - "docs/PROTOCOLO_DE_ESCUTA.md"
  - "docs/design/BR_Port_Plano_Audio.md"
---

# Regras — áudio

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Áudio

- **Este contêiner NÃO tem placa de som.** Ninguém aqui consegue ouvir o que
  produz. Nunca escrever "o som ficou bom" num commit — escrever "toca no
  evento X, dura Y ms, roteado no bus Z", que é o que dá para provar.
- Som sai por `Audio.tocar(id)` — um ponto só, como `Icones.gd` para ícone.
  `AudioStreamPlayer` espalhado por cena é o que se está a evitar.
- **Pedir não é tocar.** Avançar o dia emite quatro sinais no mesmo frame; só
  o de maior prioridade soa. Cada som tem também uma espera mínima própria.
- Os WAV são **gerados** por `tools/gerar_sons.py` (sem dependência nenhuma) e
  forçados a PCM sem perdas — o Godot 4.4+ importa WAV como QOA por omissão,
  que é compressão com perdas.
- `tests/teste_audio.gd` cobre o que é verificável. Espera `AUDIO OK`.
- **E o SINAL dentro do arquivo é outra pergunta, com outra ferramenta.** O
  `teste_audio` responde pelo ENCANAMENTO — carrega, bus, sinal certo, espera
  mínima. Quem responde pela ONDA é `tools/medir_audio.py`, que espera
  `SINAL OK`: true peak, descontinuidade interna, espectro e a soma offline.
  Biblioteca padrão só, 1,5 s, no CI.
  ⚠️ **O MARCADOR NÃO PODE CONTER `AUDIO OK`**, e por pouco não conteve:
  "MEDIDA DE AUDIO OK" tem `AUDIO OK` como substring, e o passo do
  `teste_audio.gd` procura exactamente essa string — dois marcadores a casar no
  mesmo `grep` é o "FORA DO PORTÃO" outra vez. Daí `SINAL OK`.
- ⚠️ **PICO DE AMOSTRA NÃO É PICO.** Entre duas amostras a onda reconstruída
  sobe, e o conversor do aparelho toca essa subida. Medido num mutante: um
  arquivo com pico de AMOSTRA 0,950, zero amostras saturadas e as duas bordas
  em zero — verde por toda regra antiga deste projeto — mede **+2,50 dBTP** e
  satura no telefone. Quem pergunta é a sobre-amostragem 4x da BS.1770-4.
- ⚠️ **E A CONFERÊNCIA DE BORDAS NÃO VÊ O MEIO DO ARQUIVO.** Ela pergunta pela
  primeira e pela última amostra; um estalo no meio passa inteiro, com as duas
  bordas a zero. O que o apanha é o salto comparado com o p99,9 **do próprio
  arquivo** — comparação do arquivo consigo mesmo, que é o que a torna cega a
  o som ser suave ou percussivo.
  ⚠️ **E A SENSIBILIDADE DISSO VARIA 10x ENTRE ARQUIVOS**: o apito do navio,
  que é liso e grave, denuncia um salto de 0,05; o mar, o clique e a gaivota
  precisam de ~0,4. O corte está em 3,0 com 2,5x de folga acima do maior valor
  legítimo, e o que fica de fora está escrito ao lado dele.
- ⚠️ **SOMA OFFLINE NÃO É A MIX, e o que a autoriza lê-se do bus layout.** Os
  dois buses estão a 0 dB e sem efeito — conferido, não suposto —, e só por
  isso a soma dos true peaks diz alguma coisa. Ela é um TETO aritmético
  (+7,68 dBTP com três vozes), nunca uma previsão: a mix real tem fase,
  instante de entrada e o volume que o jogador escolheu.
- ⚠️ **SEIS DOS CATORZE SONS VIVEM ABAIXO DOS 500 Hz**, que é onde o
  alto-falante de um telefone começa a perder. O aviso (`sfx_ui_warn`) é o caso
  que interessa: duas notas de triângulo a 392 e 330 Hz, **99% da energia
  abaixo de 500**. Isto é DESCRITOR e não veredito — ninguém aqui mediu
  alto-falante nenhum, e o ouvido reconstrói fundamental a partir de harmónica.
  A pergunta está escrita em `docs/PROTOCOLO_DE_ESCUTA.md` §4, e é do Bruno.
- ⚠️ **E A RÉGUA DE ÁUDIO CALIBRA-SE ANTES DE MEDIR, senão o número mente por
  omissão.** Nenhum dos 14 arquivos chega perto de 0 dBFS, então uma régua de
  true peak que devolvesse só o pico de amostra passaria despercebida para
  sempre. O `--autoteste` corre ANTES de tudo e a ferramenta **recusa-se a
  imprimir medição** se ele falhar. Ele apanhou dois defeitos na própria régua
  no dia em que foi escrita: um ganho de borda (Gibbs num degrau, que era o
  TESTE errado e não o filtro) e um defeito injetado que caiu num cruzamento de
  zero e **não pegou**.
