# BR Port — prompt para a próxima conversa (os outros retratos no kit afinado)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para desenhar a forma de cada personagem e ler o veredito
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). A
geração, as provas no jogo e o rasto de prosa descem para **Sonnet** depois de
cada veredito.

**Situação:** a frente 2 do A5 (retratos de fala) fechou o seu primeiro passo:
**a Dona Cida está no jogo** no kit de caixas afinado, nas três expressões, em
**Standard a −0,35 EV** — decisão **`055`**. O código é
`blender/brp_retratos.py`, que o `retratos_de_fala` de `blender/brp_porto.py`
chama para quem está em `_NO_KIT_AFINADO` (hoje, só `"cida"`). O Sr. Ribeiro e
o Arlindo continuam no `_corpo()` de antes, em AgX; o trabalhador do rodapé
também. O caminho até ao modelo está em `art_lab/retratos/cida_seria/` (duas
redondas e três quadradas, cada uma com README).

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/elegant-rubin-qx6ygf`, à frente da `main`
  (`d9ab39e`, o #79 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, a Dona Cida nova
  e a `055` só existem nela.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Primeiro, o olhar do Bruno sobre a preocupada e a contente.** Ele aceitou a
séria na foto do jogo; as outras duas saíram das alavancas do kit e foram
fotografadas no jogo depois (`quadrada_v3/jogo_tres_caras.png`). Mostre-lhas
e pergunte com opções.

⚠️ **Pergunte com opções, e confira a resposta antes de agir.** Nesta frente as
respostas vieram mais de uma vez contraditórias (aceitar e marcar ajustes na
mesma volta); leu-se a principal e disse-se isso antes de agir. Quando ele
escolhe «ajustar» sem dizer o quê, pergunte O QUÊ com a lista do que você vê.

**Depois, o passo seguinte da `055`, e a ordem é dele:**

- **o Sr. Ribeiro e o Arlindo no kit afinado**, cada um com a SUA forma (plano
  de arte P2: ele retangular e alto, o Arlindo de ângulos) — não a da Dona
  Cida com outro cabelo. Cada um como candidata em `art_lab/retratos/`, com a
  mesma prova no jogo, antes do estúdio;
- **o trabalhador do rodapé**: fica ao lado da Dona Cida no boletim, ainda no
  AgX e no desenho de antes;
- **os tiros da preocupada e da contente na bateria** (o boletim ruim e o
  ótimo), com o catálogo de capturas ao nível do TEMPO (`051`).

## 3. O que ficou pendente do Bruno

- **O olhar dele sobre a preocupada e a contente** (§2).
- **AgX ou Standard nos PROPS** (plano de arte §7.1): o estúdio agora ESCREVE
  o AgX (`COR_PADRAO`); a troca global continua por decidir. Contorno por casco
  invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

Estão na `055`, no fim do §7.5 do plano de arte, nos comentários de
`blender/brp_retratos.py` e nos README das candidatas. As que mais servem ao
passo seguinte:

- ⚠️ **O Standard pede a exposição**: a 0 EV, 54% dos pixels claros da gola e
  do olho saíam a 255; a −0,35 EV, zero. A pele clara do Sr. Ribeiro pode
  pedir outra conta — meça o estouro a cada personagem.
- ⚠️ **Com o enquadramento MEDIDO, a pose entra DEPOIS dele**, senão o busto
  muda de sítio de uma expressão para a outra.
- ⚠️ **Com o enquadramento medido pela cabeça, mexer na altura dela mexe no
  tamanho de TUDO o resto** (encurtá-la 12 ampliou o busto 11%).
- ⚠️ **Quando uma correção não muda NADA na imagem, a peça está errada, não o
  número**: esconda peça a peça.
- ⚠️ **O validador do Blender** projeta hoje os vértices (a caixa de uma peça
  redonda tem quinas que não existem) e deixa o retrato sair pela borda de
  BAIXO, só por ela. Um defeito injetado que não reprova pede uma sonda: o M3
  da `055` não tinha chegado ao fora do quadro.
- **A prova no jogo:** uma cópia por `git archive`, só o PNG trocado,
  `--import`, `tools/capturar_evidencia.sh`, comparação em **RGB** contra a
  bateria da árvore de hoje. Uma linha de shell por bateria.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11 (~1 GB, uns
  minutos); o hook não o instala. As pranchas pedem `pillow` no Python do
  sistema.

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `055`, o R1–R9 nem as levas de cor. A próxima
  livre é a **`056`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O veredito do Bruno e o que se fez com ele. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O CI não roda
ao empurrar a branch; o PR só se abre a pedido.
