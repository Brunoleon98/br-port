# BR Port — briefing da próxima conversa

> Fechado em 16/09/2026. Ponto de entrada curto; o estado canónico continua em
> `docs/ESTADO_DO_PROJETO.md` e a ordem, na §7 do plano v3.

## O que esta sessão fez, em quatro blocos

**1. O raster da água: construído a 1080, medido e REJEITADO** (`docs/decisoes/026`).
O que sobrava da alavanca A. Pico da fronteira 29,73 → **29,71**; maior Δ de
canal na janela **4/255**, com ZERO pixels a chegarem ao piso de Weber — por
**1,8× o tempo de geração** dos dois mapas grandes. E o `.pck` **encolhe** 39 KB,
porque o pacote leva o `.ctex` e nunca o SVG. *Resolução só se paga onde há
FRONTEIRA para afiar*, e aquele campo é uma rampa contínua.

**2. A tabela de custo da `025` §5 fechou**, com o APK e o `brport-web` lidos dos
artefatos do CI do PR 51 contra a corrida da base: **APK +413.696 B (+1,31%)** e
**Web +412.320 B (+0,98%)**.

**3. A trilha de arte inteira, capturada e publicada** — a metade de MÁQUINA do
gate A5. `tools/trilha_de_arte.sh` + `.py` correm a bateria nos **30 pontos** da
história que tocaram em arte (02/09 → hoje), com o `.godot` apagado em cada um, e
daí saem **133 pares antes/depois** mais 23 quadros que nasceram pelo caminho.

**4. A folha de contato dos props** — a outra metade. Os **51 props de mapa a
1:1**, em duas páginas, dentro da bateria desde hoje.

E de caminho, `tools/arte_orfa.py`: a pergunta que nada mais neste projeto faz —
**que arte NÃO chega à tela**. Acha **11 de 109**.

## ⚠️ O QUE ESTÁ À ESPERA DO BRUNO, E É O MAIS ATRASADO

**ANALISAR A TRILHA DE ARTE.** A página está montada, o veredito de cada quadro
é guardado, e **nada disso vale enquanto ele não olhar**:

<https://claude.ai/artifact/8k28N6G5ALgU3rSkQaVWxu>

Toca-se na imagem e ela pisca entre antes e depois no mesmo sítio; há um botão
que abre cada quadro a 720 (o tamanho em que foi tirado); em cada um diz-se
**Bom** ou **Não**. Lê-se de volta com `read_db` na coleção `veredito` — é assim
que a resposta dele entra na fila em vez de se perder na conversa.

**E o PR desta branch continua por abrir.**

## O item da próxima sessão: a folha C — o fundo AMOSTRADO

A `folha_props.gd` de hoje desenha tudo sobre **um fundo só** (o asfalto do
pátio), e isso é uma limitação assumida e escrita: contraste depende do FUNDO, e
um casco julgado sobre asfalto não diz nada sobre um casco na água. A folha
responde hoje *"dá para olhar?"*, não *"separa do fundo?"*.

**O C é derivar o fundo de cada prop do próprio mapa**: em vez de declarar um
habitat, amostra-se a cor que o mapa pinta debaixo da âncora do prop — que é
exactamente o que o D20 e o D21 já fazem para outra pergunta. Duas fontes, e não
um espelho.

⚠️ **E ele tem um buraco conhecido antes de começar:** prop sem âncora não tem
ponto para amostrar — as alternativas (`galpao_velho`, `escritorio_ruina`,
`pier_vazio`), os nove barcos (que nascem em `Dock.tscn`, não no mapa) e o órfão
`doca_concreto`. Esses precisam de um fundo de recurso **declarado como tal na
folha**, senão a folha mente sobre o que mediu.

⚠️ **E NÃO AGRUPE POR `habitat`** — está medido e não dá: o campo existe nas 44
entradas do manifest, mas só 26 dos 51 props lá estão e 20 desses 26 são
`terra`. Ele foi desenhado para a fauna.

## Os outros itens abertos, e a ordem é do Bruno

1. **A alavanca B da resolução** — props 512 → 768. Sessão inteira só para a
   mecânica, e ⚠️ **é aqui que a armadilha da constante em pixel vale de
   verdade**, ao contrário da A: os props são desenhados nas unidades da saída.
2. **O detalhe que a resolução PAGA** — a tabela da Etapa 7 do plano de arte.
   **Resolução sozinha compra nitidez, não detalhe.** Cinco ou seis sessões.
3. **Os 11 órfãos do `arte_orfa.py`** — a pasta `art/brp` inteira, dois SVG de
   píer na raiz e o `doca_concreto`. Entram no jogo ou saem do catálogo: **é
   decisão dele**, e o `--reprovar` existe para o dia em que estiver tomada.
4. **O tronco do coqueiro** — índice 0,491, três na tela. Curvar o EIXO não foi
   medido. Sessão pequena.
5. **A rua parou em 1,8** — alargá-la empurra o `RUA_RECUO` e o enquadramento
   inteiro (`012`). Sessão própria.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md e
docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-16.md.

PRIMEIRO, me lembre de analisar a Trilha de Arte — a página está montada e
parada à minha espera: https://claude.ai/artifact/8k28N6G5ALgU3rSkQaVWxu
Se eu já tiver julgado alguns quadros, leia os vereditos com read_db na coleção
`veredito` e me diga o que eles pedem antes de fazer qualquer outra coisa.

O ITEM DESTA SESSÃO É A FOLHA C: dar à folha de contato dos props o fundo
AMOSTRADO do mapa, em vez do fundo único de hoje. A `brport_vs/tools/
folha_props.gd` já entrega os 51 props de mapa a 1:1 em duas páginas, dentro da
bateria; o que falta é o chão certo debaixo de cada um.

Amostre a cor que o mapa pinta debaixo da âncora de cada prop — é o que o D20 e
o D21 já fazem para outra pergunta, e são duas fontes em vez de um espelho.
⚠️ Prop sem âncora (galpao_velho, escritorio_ruina, pier_vazio, os nove barcos
que nascem em Dock.tscn, e o órfão doca_concreto) precisa de um fundo de recurso
DECLARADO COMO TAL na folha, senão ela mente sobre o que mediu.
⚠️ E não agrupe por `habitat`: está medido e não dá (026 e o A5 do plano).

Mantenha as duas guardas que a folha já tem — o nome que não cabe na célula, e a
contagem de páginas que reprova quando o catálogo cresce — e injete defeito em
qualquer guarda nova.

QUANDO ACABAR O C, ME MANDE OS ARQUIVOS das folhas para eu olhar.

Feche com as suítes, a bateria de capturas, o conferir_docs e o fechar-sessao.
```
