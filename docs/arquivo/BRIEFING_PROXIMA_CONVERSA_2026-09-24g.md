# BR Port — prompt para a próxima conversa (depois das caras)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para a primeira mensagem, que é uma escolha do Bruno entre
frentes e o desenho da que ele escolher (F1); o que for receita desce para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** as **nove caras de fala** têm foto na bateria (`060`). As
ferramentas de captura imprimem `Retratos: <arquivo>` só depois de esconder a
cara e ver a foto mudar, e o `conferir_cobertura_paineis.py` exige cada cara do
`Retratos.POR_EXPRESSAO` nalgum log. Três tiros novos — `boletim_ruim`
(`ocioso`), `boletim_otimo` (`completo --boletim=2`) e `contraoferta_pressao`
(`aposta=recusada`) —, e a bateria tem 35. A formal do Sr. Ribeiro já tinha
foto: o briefing anterior contou-a mal.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/intelligent-cori-ts6fib`, à frente da
  `main` (`d7a9fa8`, o #83 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, a `060` e os
  três tiros só existem nela.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.
- O `docs/ESTADO_DO_PROJETO.md` tem ~500 bytes de folga no teto: desça o
  histórico ANTES de escrever nele (`/fechar-sessao` §6).

## 2. O que esta conversa faz

**Não há fila ordenada** (a §7.1 fechou): a primeira mensagem pergunta ao
Bruno qual das frentes abaixo vem a seguir, e só então desenha a escolhida.
Junto com a pergunta, mostre-lhe as três fotos novas — `boletim_ruim.png`,
`boletim_otimo.png` e `contraoferta_pressao.png`, da bateria — para o A5.

## 3. O que ficou pendente do Bruno

- **O sistema de RH** (currículo e negociação de salário, com o rosto de cada
  um) — só desenhado nas palavras dele; não há item na fila.
- **O emblema do jogador** no adesivo do capacete (`058`).
- **AgX ou Standard nos PROPS** (plano de arte §7.1) e o contorno por casco
  invertido (P5).
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.
- **O A4** (ler em voz alta as falas reescritas) e **o A6** (ouvir), que não
  precisam de sessão ligada.

## 4. Armadilhas que servem a este passo

- ⚠️ **A técnica de um asset é escolha do Bruno**: achou que a técnica em uso
  não alcança o pedido, pergunte antes de produzir (`CLAUDE.md`, Arte).
- ⚠️ **Uma tela não é uma cara**: arte que um estado do jogo destrava pede o
  tiro que monta esse estado, e a cobertura já pergunta por cara (`CLAUDE.md`,
  regra 6; `060`).
- ⚠️ **A guarda contra a sorte não reprova com a semente que calhou bem**:
  prove-a variando a semente (`CLAUDE.md`, regra 7; `060`).
- ⚠️ **Buraco previsto num briefing pergunta-se de que fonte foi lido** — este
  incluído (`CLAUDE.md`, «O que cabe numa sessão»).
- ⚠️ **A prancha e a pergunta saem na MESMA chamada de ferramentas**, se a
  frente for de arte (`/arte`).

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `060`, o R1–R9 nem as levas de cor. A próxima
  livre é a **`061`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O `/fechar-sessao`: a varredura primeiro, depois o briefing a partir dela. **O
briefing seguinte entra no mesmo commit de fecho**, com a linha no índice de
`docs/arquivo/README.md`, **e vai também na resposta, inteiro, num bloco de
código copiável.** O CI não corre ao empurrar a branch; o PR só se abre a
pedido.
