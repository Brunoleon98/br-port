# Dona Cida, séria — QUADRADA v3: o kit de caixas, afinado

**Estado: ✅ ACEITA pelo Bruno na foto do jogo (24/09) e no jogo** — a
decisão é a `055`. O código passou para o estúdio (`blender/brp_retratos.py`),
e as três expressões da Dona Cida saem de lá; este script fica como registo
do caminho.

**Base:** `main` em `d9ab39e` (o merge do #79), mais a v2 redonda (`../v2/`),
de onde o script importa o raio, o enquadramento e os materiais.

## De onde vem

Sobre a `quadrada_v2`, o Bruno pediu (24/09) mais ajustes nos quatro pontos —
cabelo, cores, rosto e corpo — e **escolheu a cor: Standard nos retratos**
(plano de arte §7.1 e P6). Os props do mapa continuam no AgX; essa metade da
pergunta continua a ser dele.

| Na quadrada v2 | Na quadrada v3 |
|---|---|
| **cabelo:** a rampa da calote acendia-se numa faixa que lembrava franja curta, e o cabelo com o coque subia alto | calote 6 mais baixa, **repartido ao meio** (seis mechas e a risca no meio), a calote no **tom de sombra** do cabelo por baixo das mechas (as frestas ficam escuras e o cabelo lê em fios) e o coque 8 mais baixo e mais atrás |
| **cores:** o AgX punha a gola e o branco do olho a ~191 e lavava a pele | **Standard**, com a exposição a **−0,35 EV** (ver abaixo); o brilho do olho volta à força 1 |
| **rosto:** sobrancelhas em barra de 34 × 7 azul-quase-preto, nariz em bloco, boca em fita | sobrancelhas **em arco** de duas placas, 5 px, **castanhas** (`porta`); nariz em **cunha** (estreito na cana, largo e saliente na ponta); a boca com **lábio** de cor (`telha_cume`) em cima e em baixo; maçãs do rosto rasas |
| **corpo:** busto largo para a cabeça | tronco **12% mais estreito** (ombro a 238 em vez de 270); a gola e o bolso acompanham |

## Como se refaz

```sh
pip install "bpy==4.5.0"          # Python 3.11
python3.11 art_lab/retratos/cida_seria/quadrada_v3/gerar_retrato_cida_quadrada_v3.py art_lab/retratos/cida_seria/quadrada_v3
PREVIA=1 python3.11 ...           # 384 px e 16 amostras
```

~16 s ao todo, **14,5 s de render**. ⚠️ O PNG não é byte-reprodutível (o
denoiser e o carimbo de data do Blender); quem pergunta "mudou?" é
`tools/comparar_props.py`.

## Medido

| | hoje (AgX) | quadrada v2 (AgX) | quadrada v3 (Standard, −0,35 EV) |
|---|---|---|---|
| busto em x (a caixa mostra 101..667) | 131..636 | 142..625 | **169..598** |
| topo do cabelo | 16 px | 15 px | **15 px** |
| lum. máx. / p99 | 196 / 189 | 234 / — | **244 / 239** |
| pixels estourados (algum canal ≥ 254) | 0% | 0% | **0%** |
| alfa a 0 ou 255 | 99,2% | 99,4% | **99,4%** |

⚠️ **O STANDARD PEDE A EXPOSIÇÃO.** A 0 EV, **54% dos pixels claros** (a gola,
o branco do olho, os botões) saíam a 255 — branco chapado, sem o sombreado das
facetas —, com 4,24% de todos os pixels opacos estourados; no AgX eram 0%. A
pesquisa de 23/09 media Standard sem estouro nos retratos de hoje, que têm
menos branco virado para a luz-chave. Varrido na prévia:

| exposição | pixels estourados | claros a 255 | p99 | saturação da pele |
|---|---|---|---|---|
| −0,2 EV | 0,07% | 0% | 250 | 0,58 |
| **−0,35 EV** | **0%** | **0%** | **239** | **0,58** |
| −0,5 EV | 0% | 0% | 228 | 0,59 |

## As tentativas, e o que cada uma ensinou

Tudo em comentário no script, junto da linha que corrige:

1. **o arco da sobrancelha saiu FRANZIDO**: no kit, `inclina` positivo do lado
   esquerdo baixa a ponta de DENTRO (é a cara «franzida» da tabela `_CARAS`);
   o arco quer o sinal contrário;
2. **as maçãs do rosto a 20 × 12 com 2,5 de saliência leram como dois
   curativos**; mais largas e rasas ficam só o fio de luz;
3. **a calote no tom das mechas acendia as frestas como elas**, e a rampa da
   testa lia como UMA placa. É a regra do kit para a pele (`pele_sombra`), com
   o cabelo: o tom de baixo leva o degrau abaixo;
4. **o Standard a 0 EV estourou a gola** (acima).

## Limitações — o que esta versão NÃO resolve

- **O tom de sombra do cabelo (`#3b2513`) não está na paleta**: é o
  `madeira_esc` a 60%, o degrau que a paleta dá à pele e não dava ao cabelo.
  Na integração, entra na `PALETA` do gerador.
- **As maçãs do rosto quase não se veem** na caixa do telefone.
- **Uma expressão só.** As outras duas (preocupada, contente) usam a pose da
  tabela `_CARAS`; o arco das sobrancelhas e o lábio são as alavancas novas.
- **O que o aceite arrasta**: a decisão `055`, o Standard e a exposição no
  estúdio dos retratos, e o Sr. Ribeiro, o Arlindo e o trabalhador com as
  mesmas melhorias — a oficina não muda.

## Arquivos

| Arquivo | O que é |
|---|---|
| `gerar_retrato_cida_quadrada_v3.py` | o script (hash em `sha256.txt`) |
| `retrato_cida_seria.png` | o PNG 768×768 |
| `prancha_hoje_q2_q3.png` | hoje, a quadrada v2 e a v3, na caixa do telefone (168×228) e a 50% |
| `jogo_boletim_quadrada_v3.png` | a foto do JOGO com esta (tiro `boletim`, 720×1280) |
| `jogo_boletim_hoje_vs_q3.png` | o cartão do boletim, hoje e com esta, lado a lado |
| `jogo_tres_caras.png` | **já do estúdio, no jogo**: o boletim com a séria (da bateria), com a preocupada (semana de prejuízo) e com a contente (semana acima da média) |

## A prova no jogo

A mesma receita das outras: uma cópia da árvore (`git archive d9ab39e`) com
SÓ este PNG trocado, `--import` e a bateria inteira
(`tools/capturar_evidencia.sh`, semente e passo fixos), contra a bateria da
árvore de hoje, comparadas em **RGB**:

- **mudou 1 foto em 31** — o `boletim`, o único tiro onde a Dona Cida aparece
  com a cara `seria`;
- **e só dentro da caixa de 100×149 px do retrato** (x 158..258, y 755..904);
- a mesma foto dos dois lados dá zero exato, e as outras 30 saíram iguais.

⚠️ **E NO JOGO ELA É A ÚNICA EM STANDARD.** No cartão do boletim o trabalhador
do rodapé, ao lado, continua no AgX; e os outros oito retratos também. A
integração regera os nove no estúdio dos retratos (o briefing diz como).

## Depois do aceite: as três caras no jogo

O código passou para `blender/brp_retratos.py` (`055`), e o estúdio gera as
três expressões com as alavancas do kit (boca, sobrancelha, olhar, pose). A
séria do estúdio é esta: `tools/comparar_props.py` dá 0,0081 (um pixel de
deslocamento dá 0,022). ⚠️ **A preocupada e a contente não têm tiro na
bateria** — o boletim da bateria calha num lucro na média, e a cara sai séria.
As fotos delas em `jogo_tres_caras.png` saíram de uma cópia da árvore, com a
ferramenta de cena a aceitar o resumo da semana em JSON; pô-las na bateria é
trabalho à parte (o catálogo de capturas desce ao TEMPO de cada painel, e o
boletim tem dois que nenhum tiro monta).

