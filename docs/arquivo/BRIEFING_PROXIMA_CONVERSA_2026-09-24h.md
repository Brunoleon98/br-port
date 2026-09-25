# BR Port — prompt para a próxima conversa (depois das duas despedidas)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para a primeira mensagem, porque ela pede ao Bruno a escolha
entre frentes e desenha a escolhida (F1); a execução que for receita desce para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** o PR **#85** está fundido na `main`. A bateria tem **36 fotos**:
além das nove caras de fala da `060`, há agora as DUAS despedidas do Arlindo.
`contraoferta_fim` fotografa quem perdeu para o jogador por «Igualar»;
`contraoferta_venceu` fotografa quem ganhou o cliente depois de duas apostas
recusadas. As 35 fotos anteriores ficaram 35 de 35 idênticas, byte a byte.

---

## 1. Comece pelo estado real

- Rode `git fetch origin main` um ref de cada vez e confirme que a `main`
  contém o merge do **PR #85**. Leia `AGENTS.md` e, por ele, o `CLAUDE.md`
  inteiro antes de mudar qualquer coisa.
- Veja os PRs abertos do Codex e do Claude antes de editar arquivo partilhado.
- Leia `docs/ESTADO_DO_PROJETO.md` e a §7 de
  `docs/design/BR_Port_Plano_v3_Claude_Code.md`. A §7.1 acabou; não há fila
  operacional ordenada.

## 2. O que esta conversa faz

**Primeiro, mostra ao Bruno as quatro fotos recentes do A5**, na mesma mensagem
em que pergunta a próxima frente: `boletim_ruim.png`, `boletim_otimo.png`,
`contraoferta_pressao.png` e `contraoferta_venceu.png`. Gere-as pela bateria de
`tools/capturar_evidencia.sh`; a última tem de dizer «A casa agradece a
preferência. Boa sorte pro Cais Mirim.», sem a linha do humor do cliente.

**Depois, pergunta qual frente vem a seguir e só então age.** As opções abertas
que já têm fonte no projeto são:

1. **A5, frente 3:** redesenhar a interface, começando pelas referências do
   Bruno e por UMA família de painéis;
2. **A5, frente 4:** mapa, frota e animação no Blender;
3. **A5, frente 5:** rumo além do VS — expansão que cruza `GameState`,
   balanceamento e save, portanto pede recorte antes de código;
4. **A5, frente 6:** melhorar a folha de contato dos props com referências;
5. **gates humanos:** releitura A4 ou escuta A6 pelo protocolo;
6. **ideias ainda sem item:** sistema de RH, emblema no capacete, decisão
   AgX/Standard dos props, galpão F1 V3 e vegetação.

Não escolha por ele nem transforme todas em uma sessão.

## 3. O que fechou na conversa anterior

- `tools/capturar_evidencia.sh` ganhou `contraoferta_venceu`, montado por
  `barco=0 0 aposta=recusada --tocar=Manter --tocar=Manter
  --tempo=despedida`.
- `brport_vs/tools/capturar_cena.gd` ganhou a prova optativa
  `--provar=arlindo_venceu`: exige exatamente
  `metrics["rival_refused"] == 1`, consequência exclusiva de
  `_perder_para_rival()` numa partida nova.
- A injeção trocou o segundo «Manter» por «Igualar». O painel chegou ao MESMO
  tempo `despedida`, mas a guarda reprovou com «esperava … = 1 e viu 0»; depois
  o defeito foi restaurado.
- No Ubuntu: seis suítes verdes, bateria com `COBERTURA OK`, 35 de 35 PNGs
  antigas idênticas e 36 finais. A foto nova foi olhada: fala certa, sem humor
  do cliente e cartão inteiro.

## 4. Armadilhas que servem ao próximo passo

- ⚠️ **O tempo e a cara não provam quem venceu:** as duas saídas usam
  `despedida`, e o sorriso já tinha foto. A prova vem do estado que só
  `_perder_para_rival()` muda; a razão e o mutante vivem no comentário de
  `brport_vs/tools/capturar_cena.gd`.
- ⚠️ **A guarda contra a sorte tem de reprovar com o defeito que promete
  apanhar.** Aqui «Igualar» conservou o mesmo tempo e zerou a métrica. A regra
  geral vive no `CLAUDE.md`, regra 7; o caso concreto vive em
  `tools/capturar_evidencia.sh`.
- ⚠️ **Uma tela não é uma cara nem um resultado.** A cobertura automática lê
  painel, tempo e retrato; o desfecho exclusivo precisou de uma prova separada.
  O contrato de cobertura vive em `tools/conferir_cobertura_paineis.py`, e a
  prova do resultado em `brport_vs/tools/capturar_cena.gd`.
- Se a frente escolhida for arte, a prancha e a pergunta saem na MESMA chamada
  de ferramentas (`.claude/skills/arte/SKILL.md`).

## 5. Restrições

- Nenhum asset entra em `brport_vs/` sem o aceite do Bruno na foto do jogo;
  nenhum prop do mapa sai de gerador de imagem; a técnica é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento do
  mapa, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `060`, o R1–R9 nem as levas de cor. A próxima
  decisão livre na `main` é a **`061`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PRs em inglês.

## 6. Ao encerrar

Use `/fechar-sessao`: varredura primeiro, briefing depois. O briefing seguinte
entra no mesmo commit de fecho, com a linha no índice de
`docs/arquivo/README.md`, e vai também na resposta inteira, em bloco copiável.
O CI não corre só ao empurrar a branch; PR apenas quando pedido.
