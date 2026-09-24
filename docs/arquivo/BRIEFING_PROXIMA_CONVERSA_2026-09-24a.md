# BR Port — prompt para a próxima conversa (a Dona Cida quadrada v2: o aceite e o passo seguinte)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler o veredito do Bruno e decidir o que muda no desenho
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). Se ele
aceitar sem pedir mudança, a integração no estúdio e o rasto de prosa descem
para **Sonnet** — menos a decisão `055`, que se escreve em Opus.

**Situação:** a frente 2 do A5 (retratos de fala) está no Blender, e **o
modelo está escolhido: a QUADRADA** — o kit de caixas, a mesma oficina do
trabalhador do rodapé. O caminho até aqui, em `art_lab/retratos/cida_seria/`:
a redonda `v1` (rejeitada), a redonda `v2` (não escolhida), a `quadrada_v1`
(escolhida por ele contra a v2, com ajustes pedidos) e a **`quadrada_v2`**,
que é a candidata: mechas que convergem para o coque e nascem da calote,
têmporas com cabelo, coque numa bola só, óculos oitavados finos, tronco de 12
lados com ombro (trapézio, prateleira, deltoide), carcela e bolso, cabeça mais
baixa com olho maior e aberto e queixo com volume. Fotografada no jogo numa
cópia: **muda 1 foto em 31** (o `boletim`), só na caixa do retrato. **Nada
disto está em `brport_vs/`**: o retrato do jogo continua o de
`blender/brp_porto.py`.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/elegant-rubin-qx6ygf`, à frente da `main`
  (`d9ab39e`, o #79 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, as candidatas só
  existem nela.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Pede o veredito do Bruno sobre a `quadrada_v2`, se ele ainda não o deu, e
age conforme ele.** Mostre-lhe a `quadrada_v2/prancha_hoje_q1_q2.png` e a
`quadrada_v2/jogo_boletim_hoje_vs_q2.png`, e leia antes o README dela.

⚠️ **Pergunte com opções, e confira a resposta antes de agir.** Nesta frente
já vieram respostas contraditórias e em texto livre; leu-se como pedido, e
isso foi dito antes de modelar.

- **Se ele pedir mudanças:** `quadrada_v3/`, pelo script da v2 (`PREVIA=1`
  para iterar: 384 px e 16 amostras), e a mesma prova no jogo (§4).
- **Se aceitar na foto do jogo**, é a integração — e ela é maior do que um
  PNG:
  1. a decisão **`055`** em `docs/decisoes/` (o modelo quadrado fica; porquê;
     o que se mediu), antes do código;
  2. o código sai do script da candidata para o estúdio
     (`blender/brp_porto.py`): as peças da Dona Cida e o `_corpo()` que os três
     partilham. ⚠️ O retrato de hoje é montado pelo `_corpo()` + `_cida()` e
     girado por `_girar_para_a_camera`; a candidata usa o `enquadrar()` da v2
     redonda. A integração escolhe UM enquadramento para os nove retratos —
     e os números `_K` e `_MEIO` do estúdio são medidos no PNG;
  3. as três expressões dela (séria, preocupada, contente), com a pose da
     tabela `_CARAS` — boca, sobrancelha e olho em placas, como hoje;
  4. os nove PNG regerados só se o `_corpo()` mudar para todos; se não, os
     três dela. Suítes, a bateria inteira, as folhas de contato;
  5. depois, o Sr. Ribeiro, o Arlindo e o trabalhador com as mesmas melhorias
     (olho, proporção por personagem, tronco, cabelo) — é a mesma oficina, e é
     por isso que o Bruno a escolheu.

## 3. O que ficou pendente do Bruno

- **O veredito da `quadrada_v2`** (§2).
- **AgX ou Standard** (plano de arte §7.1): o pipeline renderiza pelo AgX sem o
  declarar. Nas candidatas a gola sai **acinzentada** por isso (`#eef2f5` →
  ~191), e o AgX lava a pele clara (Sr. Ribeiro: saturação 0,34 contra 0,44).
  Contorno por casco invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

Estão no fim do §7.5 do plano de arte e nos comentários dos scripts. As que
mais servem ao passo seguinte:

- ⚠️ **Com o enquadramento medido pela cabeça, mexer na altura dela mexe no
  tamanho de TUDO o resto**: encurtá-la 12 ampliou o busto 11%.
- ⚠️ **Quando uma correção não muda NADA na imagem, a peça está errada, não o
  número.** Uma pala na linha do cabelo resistiu a três mudanças na calote;
  escondidas peça a peça, as prévias mostraram-na igual — era a quina do
  crânio a furar o cabelo. Um script de sonda que esconde peças por prefixo
  resolve isto em três prévias.
- ⚠️ **Um ombro não é uma curva contínua** (anéis a alargar por igual dão um
  sino), e **uma faixa que acaba numa aresta viva acende-se** (afinada até
  zero, ela nasce da superfície).
- **A prova no jogo:** uma cópia por `git archive`, só o PNG trocado,
  `--import`, `tools/capturar_evidencia.sh`, comparação em **RGB** contra a
  bateria da árvore de hoje. ⚠️ Uma linha de shell por bateria: num
  `a && b && (x) & (y) & wait` as variáveis do `&&` não chegam ao `(y)`.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11 (~1 GB, uns
  minutos); o hook não o instala. As pranchas pedem `pillow` no Python do
  sistema.

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `054`, o R1–R9 nem as levas de cor.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O veredito do Bruno e o que se fez com ele. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O CI não roda
ao empurrar a branch; o PR só se abre a pedido.
