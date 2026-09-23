# BR Port — prompt para a próxima conversa (a Dona Cida: redonda ou quadrada?)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler a escolha do Bruno e decidir o que muda no desenho
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). Se ele
aprovar sem pedir mudança, a integração no estúdio e o rasto de prosa descem
para **Sonnet**.

**Situação:** a frente 2 do A5 (retratos de fala) está no Blender. O Bruno
rejeitou a v1 redonda da Dona Cida séria e pediu para «melhorar o modelo como
um todo»; saiu a **v2 redonda**. Com ela à frente, pediu **«uma versão
melhorada da Dona Cida quadrada, para ver qual modelo escolho para
melhorar»**; saiu a **quadrada v1**. Há DUAS candidatas, e a pergunta desta
conversa é qual ele escolhe:

- **`art_lab/retratos/cida_seria/v2/`** — a REDONDA: metaball suavizado, olhos
  em esfera, nariz à parte sem sombra, tronco por anéis com ombro, gola de
  pontas, cabelo em casca colada ao crânio com sulcos até ao coque;
- **`art_lab/retratos/cida_seria/quadrada_v1/`** — a QUADRADA: o kit de caixas
  (prismas oitavados, placas, sombreado chapado, `chanfrar()`), a mesma oficina
  do trabalhador do rodapé, com a cabeça larga em vez do moai de hoje, olho com
  íris, brilho e pálpebra, calote com mechas até ao coque e tronco com ombro.

As duas partilham tudo o que não é forma — estúdio, enquadramento (a cabeça
com o coque a 60% do quadro), materiais sem ruído, brilho no olho, gola de
pontas, lápis por cima da orelha e o AgX de hoje —, para a escolha ser só do
MODELO. Cada uma foi fotografada no jogo numa cópia: **muda 1 foto em 31** (o
`boletim`), só na caixa do retrato. **Nada disto está em `brport_vs/`**: o
retrato do jogo continua o de `blender/brp_porto.py`.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/elegant-rubin-qx6ygf`, à frente da `main`
  (`d9ab39e`, o #79 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, as duas
  candidatas só existem nela.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Pede ao Bruno a escolha entre as duas, se ele ainda não a deu, e age
conforme ela.** Mostre-lhe a `quadrada_v1/prancha_hoje_quadrada_v2.png` (hoje,
a quadrada e a v2 na caixa do telefone e a 50%) e a
`quadrada_v1/jogo_boletim_quadrada_vs_v2.png` (o cartão do boletim com cada
uma). Leia antes os dois README.

⚠️ **Pergunte com opções, e confira a resposta antes de agir.** Na conversa
anterior uma resposta veio contraditória e a seguinte em texto livre; leu-se
como pedido, e isso foi dito antes de modelar.

- **O que a escolha arrasta, e deve ir na pergunta:**
  - **quadrada** → a oficina não muda: o Sr. Ribeiro, o Arlindo e o
    trabalhador do rodapé já são de caixas, e recebem as mesmas melhorias
    (olho, proporção por personagem, tronco com ombro, cabelo);
  - **redonda** → o Sr. Ribeiro e o Arlindo seguem-na, e fica a pergunta do
    trabalhador do rodapé (redondo também, ou de caixas).
- **Se ele pedir mudanças** na escolhida: refaça numa pasta nova ao lado
  (`v3/` ou `quadrada_v2/`), pelo script dela (`PREVIA=1` para iterar: 384 px e
  16 amostras), e prove outra vez no jogo pela mesma receita (§4).
- **Se aprovar:** as outras duas expressões dela (preocupada, contente), com a
  pose da tabela `_CARAS`, e depois os outros personagens.
- **Só com o aceite na foto do jogo** a peça passa para o estúdio
  (`blender/brp_porto.py`, o código sai do script da candidata) e para
  `brport_vs/`, com a decisão escrita em `docs/decisoes/` — a próxima livre é a
  **`055`** (`art_lab/README.md` §3).

## 3. O que ficou pendente do Bruno

- **A escolha do modelo** (§2).
- **AgX ou Standard** (plano de arte §7.1): o pipeline renderiza pelo AgX sem o
  declarar. Nas duas candidatas a gola sai **acinzentada** por isso (`#eef2f5`
  → ~191), e o AgX lava a pele clara (Sr. Ribeiro: saturação 0,34 contra 0,44).
  Contorno por casco invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

Estão no fim do §7.5 do plano de arte e nos comentários dos dois scripts. As
que mais servem ao passo seguinte:

- ⚠️ **Quando uma correção não muda NADA na imagem, a peça está errada, não o
  número.** Na quadrada, uma pala clara na linha do cabelo resistiu a três
  mudanças na calote; escondidas peça a peça, as três prévias mostraram-na
  igual — era a quina do crânio de tampo chato a furar o cabelo. Um script de
  sonda que esconde peças por prefixo resolve isto em três prévias.
- ⚠️ **Peça que sombreia outra sai da malha e deixa de projetar sombra** (o
  nariz, como os aros dos óculos), e **posição de feição mede-se na IMAGEM**
  (o que avança desce; o queixo recua).
- ⚠️ **Casca cortada apagando vértices sai SERRILHADA** (redonda); **ripas
  soltas por troço leem como telhas** (quadrada) — faixas contínuas, com a
  normal média na dobra.
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
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `054`, o R1–R9 nem as levas de cor.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

A escolha do Bruno e o que se fez com ela. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O CI não roda
ao empurrar a branch; o PR só se abre a pedido.
