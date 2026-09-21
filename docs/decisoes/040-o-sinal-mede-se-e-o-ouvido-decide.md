# 040 — O sinal MEDE-SE; o ouvido decide, e as duas coisas não se misturam

**21/09/2026 · item R9 da §7.1 · origem: `docs/REVISAO_GERAL_2026-09-17.md` §3
e a pesquisa externa · a metade da escuta fica com o Bruno, por construção**

## A pergunta que faltava

A revisão de 17/09 mediu os 14 WAV e escreveu o que dava para provar sem placa
de som: duração, pico de amostra, RMS, bordas, DC e saturação. O
`tests/teste_audio.gd` cobre o ENCANAMENTO — o arquivo carrega, o bus existe, o
sinal certo pede o som certo, a espera mínima segura a repetição.

**Nenhum dos dois pergunta pela ONDA dentro do arquivo.** E há quatro coisas
ali que nenhuma daquelas perguntas alcança:

| | o que escapava, e a quem |
|---|---|
| **true peak** | o pico de AMOSTRA não vê o que acontece ENTRE duas amostras |
| **descontinuidade interna** | a conferência de bordas só olha a primeira e a última |
| **espectro** | ninguém perguntava ONDE mora a energia |
| **soma offline** | ninguém perguntava qual é o teto de três vozes |

## A decisão 1 — o que é ALERTA e o que é DESCRITOR

É a decisão inteira desta sessão, e a ficha do R9 já a enquadrava: *"sem limiar
perceptual validado, emitir descritor/alerta"*. Ninguém aqui validou limiar
perceptual nenhum, porque validar um exige ouvir.

**São dois alertas, e a razão de ambos é a mesma: decidem-se por aritmética
sobre a onda, e nenhum precisa de ouvido.**

- **true peak >= 0 dBTP.** Acima de 0 o conversor do aparelho não tem para onde
  ir. Não tem parâmetro livre: 0 é 0.
- **salto isolado >= 3,0x o p99,9 do próprio arquivo.** Este TEM um número
  escolhido — ver a decisão 3.

**Tudo o resto é descritor**, com o número e sem julgamento. Em particular não
se emite veredito sobre qual banda devia dominar, nem sobre se 8 dB entre a
interface e o mar é hierarquia ou é interface aos gritos. Isso é o A6.

## A decisão 2 — a régua calibra-se ANTES de medir, e recusa-se a medir se falhar

⚠️ **E aqui isso não é zelo: é a única defesa que existe.** Nenhum dos 14
arquivos chega perto de 0 dBFS — o mais alto mede −1,72 dBTP. Uma régua de true
peak que devolvesse simplesmente o pico de amostra daria os mesmos "sem
saturação" para sempre, e ninguém notaria. É *"quando uma régua nova devolve
zero em TUDO, a primeira pergunta é se ela consegue devolver outra coisa"*, com
um verde no lugar do zero.

O `--autoteste` corre antes de qualquer medição e faz seis perguntas, das quais
três são casos de resposta **analítica** — não amostras do projeto:

1. um seno a fs/4 amostrado nos cruzamentos ±A/√2 tem pico verdadeiro A e pico
   de amostra A/√2: **+3,01 dB que o pico de amostra não vê, por construção**
   (medido: +2,93, dentro do erro conhecido do interpolador de 4x);
2. o piso: no miolo de uma contínua não há nada a ganhar (mede 0,5000);
3. o invariante `true peak >= pico de amostra`, sempre;
4. a otimização por candidatos contra a força bruta, **o mesmo número**;
5. o estalo no meio com as bordas a zero;
6. um tom de 1 kHz tem de cair na banda de 1 kHz.

E a ferramenta **não imprime medição nenhuma** se a calibração falhar, porque
um número de uma régua por calibrar vira a conclusão da sessão.

⚠️ **E ELA APANHOU DOIS DEFEITOS NA PRÓPRIA RÉGUA, no dia em que foi escrita.**
Os dois na primeira corrida, antes de um único número dos 14 arquivos sair:

- **o "ganho" de borda era o TESTE, não o filtro.** A asserção montava uma
  contínua de 512 amostras e exigia true peak 0,5; deu **0,5623**. A causa: uma
  contínua que COMEÇA na amostra 0 é um DEGRAU, e a reconstrução limitada em
  banda de um degrau ultrapassa mesmo (Gibbs). Os 12% a mais eram verdade sobre
  o sinal que o teste montou, e não sobre o que ele queria perguntar. Para os
  14 arquivos o zero à volta é FÍSICO — todos começam e acabam em 0 —, portanto
  quem mudou foi o teste, que passou a perguntar no miolo.
- **o defeito injetado caiu num cruzamento de zero e não pegou.** A asserção do
  estalo fazia `sujo[1600] = -sujo[1600]`, e um seno de 300 Hz a 32 kHz vale
  ZERO em n=1600: inverter zero não muda nada, e a razão dava 2,0 dos dois
  lados. Hoje o valor é cravado longe da curva e há um `assert` a exigir que os
  dois sinais DIFIRAM antes de os comparar. É a regra do `CLAUDE.md` — *"confira
  que o defeito injetado pegou"* — a morder dentro da ferramenta escrita para a
  cumprir.

## A decisão 3 — o único número escolhido está medido dos dois lados

O corte da descontinuidade é o único parâmetro livre desta ferramenta, e por
isso foi varrido em vez de arbitrado. Injetando UM salto isolado no meio, por
amplitude:

| arquivo | intacto | 0,05 | 0,1 | 0,2 | 0,4 | 0,6 | 0,9 |
|---|---:|---:|---:|---:|---:|---:|---:|
| `sfx_amb_mar` | 1,2 | 1,2 | 1,2 | 1,8 | 3,0 | 4,1 | 5,9 |
| `sfx_ui_click` | 1,1 | 1,1 | 1,1 | 1,5 | 2,8 | 4,1 | 6,1 |
| `sfx_navio_chega` | 1,1 | **8,2** | 10,4 | 14,8 | 23,6 | 32,3 | 45,5 |
| `sfx_fauna_gaivota` | 1,1 | 1,1 | 1,1 | 1,5 | 3,1 | 4,6 | 6,9 |
| `sfx_ui_success` | 1,0 | 2,2 | 2,7 | 3,7 | 5,7 | 7,7 | 10,7 |

Os 14 intactos medem 1,0 a 1,2. **O corte em 3,0 deixa 2,5x de folga** acima do
maior legítimo e fica abaixo de todo defeito de amplitude >= 0,4.

⚠️ **E O QUE ELE NÃO APANHA ESTÁ ESCRITO AO LADO DELE.** Num som TEXTURADO um
salto abaixo de ~0,2 não se separa da textura do próprio arquivo e passa. A
sensibilidade varia **10x entre arquivos** — o apito do navio, liso e grave,
denuncia 0,05 — e isso é propriedade do sinal, não do corte. É *"uma guarda
defende o que defende; o que não se pode é fingir que ela defende mais"*.

## A decisão 4 — a soma offline só fala porque o bus layout foi LIDO

A ficha avisa: *"soma offline não é mix real sem comprovar buses/ganhos/
efeitos"*. Então comprova-se, e não se supõe: a ferramenta lê o
`default_bus_layout.tres` e exige ganho 0 dB e zero efeitos. Estão os dois
assim, e é isso — e só isso — que autoriza a linha do teto.

Três vozes (`VOZES = 3`) no pior alinhamento dariam **+7,68 dBTP**. É um teto
aritmético e está rotulado como tal: a mix real tem a fase de cada som, o
instante em que cada um entra e o volume do jogador, e o `Audio.gd` só deixa UM
pedido vencer por frame. Se um dia alguém puser um limitador no SFX, a
ferramenta deixa de citar a soma em vez de a citar errada.

## ⚠️ O achado: seis dos catorze sons vivem abaixo dos 500 Hz

Não estava previsto, e é o que a escuta ganha desta sessão. Um alto-falante de
telefone começa a perder o grave por volta dos 500 Hz — a energia existe no
arquivo e pode não sair do aparelho.

| som | <500 Hz | centroide |
|---|---:|---:|
| `sfx_navio_chega` | **100%** | 138 Hz |
| `sfx_ui_warn` | **99%** | 356 Hz |
| `sfx_construir` | 92% | 212 Hz |
| `sfx_ui_error` | 88% | 297 Hz |
| `sfx_derrota` | 80% | 372 Hz |
| `sfx_fauna_mergulho` | 72% | 1211 Hz |

O caso que interessa é o **aviso**: o `sfx_ui_warn` é o som que diz ao jogador
que a ação não deu, e mora inteiro na faixa que o telefone entrega pior.

⚠️ **E A MEDIÇÃO CONFIRMA-SE POR DUAS FONTES QUE NADA OBRIGA A CONCORDAR** —
a régua mede o espectro do WAV, e o `gerar_sons.py` DECLARA as frequências:

| | centroide dito pelo gerador | medido pela régua |
|---|---:|---:|
| `sfx_navio_chega` | 138 Hz | **138 Hz** |
| `sfx_ui_warn` | 361 Hz | **356 Hz** |
| `sfx_construir` | 191 Hz | 212 Hz |

O `sfx_ui_warn` são duas notas de triângulo a **392,00 e 329,63 Hz**, escritas
no gerador. O `construir` diverge para cima, e na direção esperada: a conta do
"dito" ignora o ruído da tábua e o tilim de 1244 Hz, que puxam o centroide.

⚠️ **E ISTO É DESCRITOR, NÃO VEREDITO.** Ninguém aqui mediu alto-falante
nenhum, e o ouvido reconstrói a fundamental a partir das harmónicas: pode estar
perfeito. A pergunta está escrita em `docs/PROTOCOLO_DE_ESCUTA.md` §4, com o
conserto conhecido caso a resposta seja "somem" — subir uma harmónica no
gerador, **nunca subir o volume**.

## Os mutantes

Os três que a ficha nomeia, cada um sozinho, em CÓPIAS dos WAV, com controlo
positivo verde entre eles e o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| X0 | cópia sem defeito (controlo positivo) | verde, como devia |
| X1 | pico ENTRE amostras: rajada a fs/4 com fase 45° | **reprovou**, +2,50 dBTP |
| X1b | o MESMO arquivo, pela regra VELHA | **passa**: pico de amostra 0,950, zero saturadas, bordas a zero |
| X2 | salto no MEIO, bordas intocadas | **reprovou**, razão 6,0 na amostra 57.601 |
| X2b | o MESMO arquivo, pela regra das BORDAS | **passa**: bordas 0,0 / 0,0 |
| X3 | banda rotulada errada (limites de 2k-6k no rótulo `500-2k`) | **reprovou na calibração**, e a ferramenta recusou-se a medir |

⚠️ **O X1b E O X2b SÃO O PAR QUE PROVA A SESSÃO.** Sozinhos, o X1 e o X2 só
mostram que a régua nova reprova alguma coisa. O que justifica a ferramenta
existir é que o MESMO arquivo passa por tudo o que este projeto já tinha —
pico, saturadas e bordas — e é exactamente a armadilha do *"confira QUAL guarda
está a segurar a asserção"*, com a guarda antiga a não segurar nada.

⚠️ **E O X1 NÃO PEGOU À PRIMEIRA.** A rajada foi escrita com `a = 0,95/√2`
quando o que punha as amostras em ±0,95 era `0,95·√2`: o espectro mudou (prova
de que o arquivo foi mesmo escrito) e o pico ficou em 0,550, parado. Um defeito
que muda o arquivo sem tocar na grandeza sob teste **lê-se como "a guarda não
pega"** — e o que o denunciou foi a coluna do espectro ter-se mexido enquanto a
do pico não.

## O que fica de fora, dito

- **NADA AQUI DIZ QUE OS SONS SÃO BONS**, e é a razão de o item ter duas
  metades. A segunda é `docs/PROTOCOLO_DE_ESCUTA.md` e **só o Bruno a passa**.
- **LUFS não entra**, como a ficha manda: a janela de 400 ms da BS.1770 não
  define alvo para um efeito de 90 ms, e o resultado dependeria do enchimento.
  Medir e publicar um número sem significado é pior do que não o medir.
- **FFmpeg não entra** — não existe neste contêiner (medido), e a ficha proíbe
  dependência pesada. Tudo isto é biblioteca padrão, 1,5 s nos 14 arquivos.
- **A mistura REPRESENTATIVA não se mediu, só o teto.** Medir a mix a sério
  exige gravar a saída do Godot, e o contêiner não tem placa de som — é o
  problema a morder a própria medição.
- **O corte da descontinuidade viu UM defeito**, não dois, e não se apertou por
  causa disso. A tabela da decisão 3 é o que autoriza o número que lá está.
