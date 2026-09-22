# 048 — O que a fala afirma, o estado confirma; e a fala não narra a tela

**23/09/2026 · gate A4, a pedido do Bruno:** *"mude essa frase do senhor
Ribeiro, pois está muito óbvia e sem graça — inclusive evite isso em outras
conversas já geradas e que serão geradas"*, e *"em relação ao boletim da Dona
Cida, faça a medição para evitar erros"*.

## O que se decidiu

1. **O boletim escolhe o tom lendo o resumo inteiro da semana** —
   `Narrativa.tom_do_boletim(resumo)` —, e não só o resultado e a média. Os
   tons passaram de quatro a seis, e cada um só afirma o que a condição dele
   garante:

   | tom | quando | o que afirma |
   |---|---|---|
   | `ruim_ribeiro` | vermelho **e a parcela saiu nesta semana** | que o vermelho é o Sr. Ribeiro |
   | `primeira_ruim` | vermelho na semana 1 | que a parcela ainda não espera |
   | `ruim` | vermelho depois de vermelho | "de novo" |
   | `ruim_virou` | vermelho depois de uma semana que não foi | que a anterior não foi assim |
   | `neutro` / `otimo` | azul | que entrou mais do que saiu — e nada sobre a parcela |

2. **O Sr. Ribeiro não promete o que o jogo não faz.** A resposta a quem não
   paga vinha do rascunho da Fase 1 do GDD (três parcelas, tolerância) — *"uma
   vez eu deixo passar com uma conversa"* — e no VS `fail_debt()` encerra a
   partida: *"Porto perdido"*. Hoje ele diz que o cais passa para o banco. A
   **despedida**, que promete crédito para crescer, e o botão *"Até a
   próxima"* só aparecem a quem pagou; quem não pagou fecha com *"Adeus"*.

3. **A fala não narra o que a tela já mostrou, nem explica o gesto do
   personagem.** É a queixa do Bruno, e ficou como regra no `CLAUDE.md`.
   Reescritas por isso: a entrada do Sr. Ribeiro (*"vim pessoalmente
   porque..."* → o avô que pagava na véspera), a resposta dele a quem paga
   (repetia a despedida), a despedida (*"o banco existe pra isso"*), a
   derrota para o Arlindo (*"Perdeu pro Arlindo"*), a vitória dele (*"sempre
   bom fazer negócio"* → *"a casa agradece"*, o maneirismo do guia de voz) e
   as aberturas do boletim (*"Os números fecharam"*, *"Olha esse resultado"*).

## A medição — `tools/medir_boletim.gd`

Herda o simulador (as mesmas partidas, políticas e sementes que medem o
balanceamento), acrescenta um perfil que **nunca aloca ninguém** — o
principiante do boletim de 12/09 — e escuta o `semana_fechada`, que é o sinal
que abre o boletim no jogo. Cada tom tem as suas afirmações listadas com o
predicado que as torna verdade. 200 partidas × 5 perfis, ~11 s, no CI.

| | antes | depois |
|---|---|---|
| boletins | 4.000 | 4.000 |
| afirmações desmentidas | **2.005** | **0** |
| *"a semana passada foi menos pior"* | falsa em **856 de 856** — nunca foi verdade | saiu |
| *"de novo"* | falsa em 256 de 856 | 0 de 600 |
| *"o Sr. Ribeiro não aceita boa vontade"* | falsa em 252 de 856 — a semana 4 de quem ACABOU de pagar | saiu; esses 252 são o `ruim_ribeiro` |
| *"a parcela da próxima semana"* | falsa em 641 de 1.229 | saiu |

⚠️ **A semana ruim mais comum era a semana em que o jogador pagou.** A Dona
Cida abria-a com *"conseguimos a façanha de gastar mais do que ganhar. De
novo."* — a reclamar de quem acabava de quitar a dívida.

## As guardas, e o que cada mutante mostrou

- **T12** (`run_tests`): os ramos do `tom_do_boletim()` com o esperado literal,
  incluindo os três estados raros — a parcela paga já na semana 1, a semana
  anterior exatamente a zero e a semana 4 de quem paga.
- **T13** (`run_tests`, cena real): a despedida e o *"Até a próxima"* só depois
  de pagar.
- **A régua** no CI, que reprova com código 1 e `BOLETIM OK` ausente.

| mutante | o que reprovou |
|---|---|
| M1 sem o ramo da parcela | T12 (dois casos) — e ⚠️ **a régua PASSAVA** (ver abaixo); depois da correção, a régua reprova em 252 |
| M2 parcela perguntada depois da semana 1 | **só** o T12, no caso da semana 1 — a régua não monta esse estado em 1.000 partidas |
| M3 `anterior <= 0` | **só** o T12, no caso da semana anterior a zero |
| M4 despedida sempre | T13 |
| M5 botão sempre "até a próxima" | T13 |

Base verde conferida entre cada um; originais guardados por `cp`.

⚠️ **AFIRMAÇÃO QUE É A PRÓPRIA CONDIÇÃO DO TOM NÃO REPROVA NUNCA.** A primeira
versão da régua listava para o `ruim` só *"de novo"* — que é exatamente o
`anterior < 0` que o escolhe. Com o ramo da parcela arrancado, a semana paga
caía em `ruim`/`ruim_virou`, as duas cumpriam o que diziam, e a régua dava
verde. O que o texto afirma de verdade, pela ironia de *"conseguimos a
façanha"*, é que **o vermelho é da operação** — e essa afirmação lê a parcela
da semana, um campo que a condição desses tons não lê. Com ela listada, o M1
reprova em 252 boletins.

## O que fica de fora

- **A lista de afirmações é escrita à mão a partir do texto.** A régua garante
  que o estado confirma cada afirmação listada, não que a lista esteja
  completa; quem mudar uma fala do boletim muda a lista.
- **O resto das falas não tem régua de escala.** As da Dona Cida no loop, do
  Arlindo e do Sr. Ribeiro têm as guardas de sempre (F4, F6, F8, T13); o
  critério de "óbvia" é de leitura, e é o gate do A4.
- **A família da semana nova ficou como estava**, por ter sido aprovada pelo
  Bruno na mesma sessão.
- O rascunho de escrita (`docs/design/BR_Port_Frontload_Escrita_VS.md`) guarda
  as versões antigas; o jogo manda.
