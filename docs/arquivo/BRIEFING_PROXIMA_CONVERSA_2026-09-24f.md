# BR Port — prompt para a próxima conversa (as caras sem foto)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para desenhar os tiros novos e a guarda que pergunta por CARA,
e para escolher o defeito injetado de cada uma (F1 e F6); as corridas da
bateria, as fotos e o rasto de prosa descem para **Sonnet** (`CLAUDE.md`,
«Qual MODELO faz o quê»).

**Situação:** o trabalhador do rodapé tem **30 rostos** no jogo — 2 sexos × 3
idades × as 5 cores do IBGE, aceites pelo Bruno na v3 e na foto do jogo, sem
perda (`059`). Cada trabalhador nasce com o seu `rosto` (campo no save,
`SAVE_VERSION` 8) por um sorteio próprio que não mexe no da partida: o
balanceamento mede o mesmo 100,0% / 80,2% / 37,3%. O construtor é o
`trabalhador(M, cara, perfil)` de `blender/brp_retratos.py`, e a tabela dos 30
é o `TRABALHADOR_PERFIS` de `blender/brp_porto.py`. A bateria ganhou a folha
`trabalhadores` (32 tiros).

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/optimistic-babbage-08c35t`, à frente da
  `main` (`194ebd9`, o #82 fundido), com o PR
  https://github.com/Brunoleon98/br-port/pull/83 aberto. Antes de qualquer
  checkout, confira no GitHub se ele foi fundido; se não foi, a `059` e os 29
  retratos novos só existem nela.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.
- O `docs/ESTADO_DO_PROJETO.md` tem ~300 bytes de folga no teto: desça o
  histórico ANTES de escrever nele (`/fechar-sessao` §6).

## 2. O que esta conversa faz

**Os tiros das caras sem foto**, o item que ficou de duas conversas: a
**preocupada** e a **contente** da Dona Cida (o boletim ruim e o ótimo), a
**formal** do Sr. Ribeiro («a dívida») e a **pressão** do Arlindo («a última
tentativa»), com o catálogo de capturas ao nível do TEMPO (`051`). Hoje só a
séria, a cordial, a grave, o sorriso e o contrariado têm foto.

O caminho: F1 desenha como cada cara chega à tela pela PORTA DO JOGADOR (que
estado da partida produz o boletim ruim e o ótimo, a fase da dívida, a última
tentativa do rival) e a guarda que pergunta, nos logs da bateria, se toda
expressão do `Retratos.POR_EXPRESSAO` aparece nalguma foto — a mesma forma da
`conferir_cobertura_paineis.py`, uma pergunta por CARA em vez de por painel.

## 3. O que ficou pendente do Bruno

- **O sistema de RH** (currículo e negociação de salário, com o rosto de cada
  um) — só desenhado nas palavras dele; não há item na fila.
- **O emblema do jogador** no adesivo do capacete (`058`).
- **AgX ou Standard nos PROPS** (plano de arte §7.1) e o contorno por casco
  invertido (P5).
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que servem a este passo

- ⚠️ **Painel fotografado em partida nova prova que a cena abre e mais nada**:
  o boletim ruim e o ótimo pedem uma partida JOGADA até lá (`CLAUDE.md`, regra
  6 do fecho).
- ⚠️ **A porta do jogador também tem fase**: a dívida só se mostra dentro de
  `debt_payment` (`CLAUDE.md`, regra 6; `051`).
- ⚠️ **Um painel não é uma tela**: a cobertura desce ao TEMPO, e a de cara
  desce um andar mais (`CLAUDE.md`, regra 6).
- ⚠️ **Cobertura declarada mente; cobertura medida não**: a guarda lê o que a
  foto MOSTROU, não o que o tiro promete (`CLAUDE.md`, regra 6).
- ⚠️ **Fala disparada não é fala vista**: a cara que a fala pede pode não ser a
  que fica na tela (`CLAUDE.md`, Narrativa).
- ⚠️ **A foto é o último frame desenhado**: o que se muda na mesma volta só
  chega à seguinte — um defeito injetado ali não chega à foto
  (`brport_vs/tools/folha_trabalhadores.gd`).
- ⚠️ **Trabalhador montado à mão nos testes passa por `GS.novo_trabalhador()`**,
  senão o save dele é recusado (`brport_vs/autoload/GameState.gd`).
- ⚠️ **A chave que escolhe a arte só alcança tantas peças quantos valores
  toma** — antes de ligar arte a um estado, conte os estados (`CLAUDE.md`,
  Arte).
- ⚠️ **A prancha e a pergunta saem na MESMA chamada de ferramentas**, e não
  no turno seguinte: nesta conversa o envio saiu sozinho três vezes (`/arte`).

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `059`, o R1–R9 nem as levas de cor. A próxima
  livre é a **`060`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O `/fechar-sessao`: a varredura primeiro, depois o briefing a partir dela. **O
briefing seguinte entra no mesmo commit de fecho**, com a linha no índice de
`docs/arquivo/README.md`, **e vai também na resposta, inteiro, num bloco de
código copiável.** O CI não corre ao empurrar a branch; o PR só se abre a
pedido.
