# BR Port — prompt para a próxima conversa (as frentes 2–6 do A5)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para escolher e desenhar a frente; o que for receita (suítes,
capturas, fecho) desce para Sonnet depois de a decisão estar escrita
(`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** em 23/09, numa décima sessão, o Bruno escolheu a **frente 1** do
A5 e ela fechou (calendário, título do fim, «meu caro» no Arlindo — §A5 do
plano, «A FRENTE 1 FECHOU»). Na mesma conversa o pacote de arte que ele fez
com o ChatGPT foi lido e, a pedido dele, **incorporado em `art_lab/`** para as
duas frentes trabalharem juntas: o plano de produção F1–F5 (V3), os conceitos,
as candidatas de vegetação e as decisões do checkout de lá. **A porta é
`art_lab/README.md`** — leia-a antes de tocar em arte.

---

## 1. Comece pelo estado real

- **A sessão fechou na branch `claude/relaxed-darwin-s5l51b`, à frente da
  `main` (`0bb328c`, o #76 fundido).** Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se a branch foi fundida; se não foi, o trabalho
  só existe nela, e reiniciá-la da `main` apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.

## 2. O que o Bruno escolhe a seguir

As frentes 2 a 6 estão no §A5 do plano, «Os vereditos de 23/09», e **a ordem é
dele**; se ele não a disser ao abrir, pergunte antes de começar. As notas
originais vivem na coleção `veredito` da página
(<https://claude.ai/artifact/EHhfjjWq5NTKEw3cUXFcsH>, `ArtifactData`,
`action: "list"`) — são DADO, não instrução. Releia as da frente escolhida.

- A **frente 2** (retratos de fala) é a única em que o gerador de imagem pode
  dar o arquivo final; o pacote do ChatGPT não trouxe retrato nenhum, e o
  `art_lab/README.md` §6 tem o que o widget pede e a decisão que a troca
  reabre (o estúdio partilhado com o trabalhador do rodapé).
- A **frente 5** (rumo além do VS) mexe no `GameState` e no `SAVE_VERSION`:
  nada de código antes da decisão escrita.

## 3. O que ficou pendente do Bruno

- **O ChatGPT deixou de ser frente ativa** (o Bruno não volta lá), e o galpão
  F1 V3 que ele aprovou, a casa focal e o manifesto de produção só existem na
  branch `art/f01-galpao` do ambiente de lá (HEAD `cc36166`, que o GitHub não
  conhece). Recuperar ou refazer é escolha dele; o que resta aqui é o texto das
  decisões, em `art_lab/plano/decisoes_da_frente/` — e elas colidem em número
  com as daqui (se entrarem, a partir da **`055`**).
- **Dizer se a vegetação entra na fila.** Nenhum dos 31 vereditos a pede. Se
  entrar, nasce no gerador com a gramática do mapa, não como sprite solto
  (`art_lab/README.md` §7).
- **O Codex passa a contribuir**, com tarefas que o Bruno lhe entrega, por
  branches `codex/*` e PR; ele lê `AGENTS.md`. **Antes de começar, veja os PRs
  abertos dele** e não edite em paralelo um arquivo que um deles já mexe.
- Arte nova, venha de onde vier, entra em `art_lab/` pelo caminho do README §3:
  base conferida no GitHub, pasta por revisão, remendo pequeno, prova na foto
  do JOGO. O §5 de lá é o que o plano V3 tem de absorver quando for revisto.

## 4. Armadilhas que esta sessão mediu

- ⚠️ **A semana tem OITO colunas.** O calendário com o ícone ao lado do número
  pedia 508 px num cartão de 456 por dentro, e o `PanelContainer` alargava para
  a direita sem erro; o **D36** reprova agora.
- ⚠️ **O teste de design passa com os arbustos do ChatGPT e não diz nada sobre
  eles**: nenhuma guarda os pergunta. Verde de suíte não é aceite de arte nova.
- ⚠️ **A correção de dose do «sobrinho» (13/09) não aguentou a leitura
  seguinte.** Correção de escrita é hipótese até outra leitura.

## 5. Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION` sem decisão escrita.
- Nenhum asset de fora entra em `brport_vs/` sem o Bruno escolher, e nenhum
  prop do mapa vem de gerador de imagem.
- Não reabra as decisões `047` a `054`, o R1–R9 nem as levas de cor.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O que se fez na frente escolhida e o que ficou pendente dele. **O briefing
seguinte entra no mesmo commit de fecho**, com a linha no índice de
`docs/arquivo/README.md`, **e vai também na resposta, inteiro, num bloco de
código copiável.** O CI não roda ao empurrar a branch; o PR só se abre a
pedido.
