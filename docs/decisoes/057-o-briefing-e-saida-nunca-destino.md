# 057 — O briefing é saída da varredura, nunca destino

**24/09/2026 · pedido do Bruno ao fechar a conversa da `056`:** melhorar o
`/fechar-sessao` «para não desperdiçar lições».

## O que se decidiu

**Toda lição que o briefing cita nomeia onde vive, e o conferidor reprova a
que não nomear.** No briefing, ⚠️ marca LIÇÃO; o bloco que o símbolo abre
tem de citar um arquivo que exista (`CLAUDE.md`, um README, o script da
função), uma decisão (`NNN`) ou uma skill (`/arte`). O arquivo das sessões não
conta como destino: apontar para o briefing anterior ou para o `HISTORICO.md` é
apontar para a conversa. Estado e pendência escrevem-se sem ⚠️.

**Só o briefing MAIS RECENTE é conferido**, pela ordem do nome. Os outros são
registo, e reescrevê-los para ficar verde seria apagar o que aconteceu.

**O `/fechar-sessao` passou a ter o briefing como secção própria (§7), escrita
DEPOIS da varredura (§5)**, que percorre também as perguntas feitas ao Bruno e
as respostas dele. A tabela «O que se aprendeu / Onde vive» ganhou duas linhas:
como trabalhar com ele numa frente (a skill da área) e ambiente e ferramentas
(«Como rodar», no `CLAUDE.md`).

## Por que

A §5 perguntava «onde isto está escrito?», e o briefing respondia «aqui». Em
24/09 duas lições só viviam lá — como conduzir o veredito de arte com o Bruno
e o corte do download do `bpy` — e só chegaram à `/arte` e ao `CLAUDE.md`
porque ele perguntou «fechou aprendendo com ela?».

Medido nos 36 briefings do arquivo, com a mesma régua da guarda: **306 avisos,
249 sem destino nomeado**. E a varredura desta sessão achou uma terceira lição
perdida, pior do que as duas: «o CI não roda ao empurrar a branch» viveu em
**trinta briefings seguidos** (18/09 → 24c), nunca chegou ao `CLAUDE.md` — que
no mesmo período dizia que o CI «corre a cada push», e o `COMO_RODAR.md` e a
`/balancear` repetiam-no —, e caiu do 24d sem uma palavra. No de 18/09 ela era
um título com ⚠️; a guarda tê-la-ia reprovado nesse dia.

## Como — a régua e os sete mutantes

- **Aviso é o símbolo seguido de negrito ou maiúscula.** «Os ⚠️ do briefing» é
  o símbolo citado, e o 24d tinha três dessas menções.
- **Cada aviso responde pelo SEU bloco**: do ⚠️ ao próximo, ou ao fim do
  parágrafo ou item. O título com ⚠️ responde pela secção até ao título
  seguinte do mesmo nível.
- **Controle positivo**: o briefing 24d reprova em 7 dos seus 9 avisos — os
  mesmos 7 que o protótipo apontou. Um briefing com todas as formas de destino
  (arquivo, decisão por número e por caminho, skill em crase e nua, título com
  o destino no segundo parágrafo, e o símbolo citado como substantivo) dá zero.

Doze casos injetados como briefing mais recente — cada um reprova uma vez,
menos o controle e a menção, que dão zero — e sete mutantes no código, cada um
apanhado pelo caso escrito para ele:

| mutante | quem apanhou |
|---|---|
| K1 sem a exclusão do arquivo por CAMINHO | `docs/arquivo/HISTORICO.md` passou |
| K1b sem a exclusão por NOME NU | o briefing `24c` e o `HISTORICO` pelo nome nu passaram |
| K2 um destino por parágrafo | a primeira de duas lições no mesmo parágrafo passou |
| K3 parágrafos não separados na linha vazia | o destino do vizinho satisfez o aviso |
| K4 todo símbolo é aviso | o controle e a menção reprovaram (2 e 3) |
| K5 o briefing mais ANTIGO | nenhum caso reprovou |
| K6 o título só pela sua linha | o controle reprovou |

K1 e K1b são duas proteções para duas formas, e tirar uma deixa a outra de pé:
cada uma precisou do seu caso. O caso da «decisão por escrever» citava `057` e
passou a zero no instante em que esta foi escrita — é o comportamento pedido
(o aviso fica verde quando o destino existe), e o caso passou a citar `058`. A ordem do nome foi provada dos dois lados — um
defeito num nome sem letra, do dia `2026-09-24`, não é o mais recente (o
ponto ordena antes da letra), e num `24e` é.

## O que a guarda NÃO cobre

- **Prova que o destino está nomeado e existe, não que a lição esteja lá**, nem
  que a menção seja o ponteiro e não um vizinho: «o `ESTADO_DO_PROJETO.md` tem
  650 bytes de folga» passa. O modo de falhar medido foi ESQUECER o destino,
  não fingi-lo; a skill manda abrir o destino antes de o citar.
- **Só vê o que leva ⚠️.** No 24c o «CI não roda» já estava escrito sem o
  símbolo, e nenhuma régua o teria visto. É por isso que a regra é da skill e
  a guarda só a tranca.
