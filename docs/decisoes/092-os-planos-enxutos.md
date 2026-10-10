# 092 — Os planos enxutos: o que fechou desce para o arquivo

**10/10/2026.** Main `b83f617` (PR #115, o M4, fundido; nenhum PR aberto do
Codex); 092 livre conferida na main antes de escrever. É o **M5** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), sem decisão pendente.

## O que mudou

Para retomar o trabalho são dois documentos, o estado e o plano — e o plano
v3 tinha **173.987 bytes**, dois terços deles itens ✅ que quem só quer saber
o que vem a seguir lia na mesma. O plano de arte, a mesma coisa. Hoje:

| Arquivo | Antes | Depois |
|---|---|---|
| `docs/design/BR_Port_Plano_v3_Claude_Code.md` | 2.898 linhas · 173.987 B | 986 · 56.712 |
| `docs/design/BR_Port_Plano_Arte_Blender.md` | 2.077 linhas · 128.973 B | 818 · 52.317 |
| `docs/arquivo/PLANO_V3_FECHADOS.md` | — | 1.994 · 121.113 |
| `docs/arquivo/PLANO_ARTE_FECHADOS.md` | — | 1.294 · 78.767 |

Cada bloco desceu palavra por palavra, na ordem em que estava, sob um título
`##` que diz de que seção saiu; no plano ficou uma linha que o nomeia e aponta
para o arquivo. O plano inteiro de antes continua no commit `b83f617`.

A única palavra que mudou foi um caminho: uma citação do README das
referências escrita relativa à pasta do plano resolvia a partir de
`docs/design/` e, no arquivo, o `conferir_docs.py` reprovou-a — passou a
`docs/design/referencias/README.md`. É um ajuste
declarado no script, que a prova desfaz antes de comparar; afrouxar o
conferidor para o aceitar seria a correção errada.

## O que desce e o que fica

**Desce** a seção cujo título a declara fechada (✅, ❌, ✗, FEITO, FECHOU) e o
item cujo corpo diz que acabou sem nada por fazer: o A1 (a máquina e as duas
jogadas), o A2 (a tabela gerada; o estado já o dava por construído), o A3, o
B1 e o B2, a semana de sete dias (`TURNS_PER_WEEK` 7 entrou com a `085`), a
segunda jogada no telefone e a §7.1 inteira (R1–R9). No plano de arte, as
etapas 1 a 6 e todas as passagens «fora das etapas», mais a vila dos três
lotes.

**Fica** o enquadramento — as §1–§4 e §8–§10 do v3; as §1–§3, §5 e §6 da arte —
e todo item com alguma coisa aberta: o A4 (a leitura), o retrato com reação (a
faixa do rodapé), o A5 com os vereditos e as frentes 2, 4 e 5, o A6 a A9, a
resolução dos assets e, na arte, a Etapa 7 e a §7.

**A exceção, e é a única:** um ✅ que é METADE de um item aberto, e cujo texto
o resto do item ainda usa, fica com ele. São dois casos: as duas metades de
configuração da Etapa 7 (a armadilha da geometria degenerada é para quem
desenhar a tabela que falta) e o fim da §7.5, onde estão as lições «para o
próximo retrato» que os README de `art_lab/retratos/` citam como «o fim do
§7.5».

**E a frente 2 ficou**, porque não é minha para fechar: o título dela é ↩️ e
não ✅, o estado não a dá por fechada, e ela deixa escritos o sistema de RH e
o adesivo do capacete.

## Os sítios que citavam o que desceu

- A **§7.1** é citada por oito decisões (`030`–`037`) e pelo cabeçalho do
  `FilaDeMensagens.gd`: o título ficou, como «fechada», com o ponteiro.
- **«Etapa N do plano de arte»** e **«item BN do plano v3»** aparecem em 29
  linhas de 15 arquivos de código, cena e workflow. Não se mexeu em nenhuma: a
  linha que ficou no plano nomeia as etapas e os B um a um, e leva ao arquivo.
- O cabeçalho do v3 («Fila atualizada em 21/09… próxima sessão: R9») e o item
  2 da §11 («o item seguinte é R4») envelheceram: desceram também, e no lugar
  ficou a fila de hoje.
- As skills que mandam escrever no plano passaram a dizer para onde desce o
  que fecha: o rasto da `/arte` e a §6 da `/fechar-sessao`. Sem isto os planos
  voltariam a crescer, que é o que fizeram de 30/08 a 10/10.

## A prova

Um script de uma vez, fora do repositório, com três perguntas por plano, cada
uma por um caminho:

1. **multiconjunto** — toda linha não vazia do original está no plano novo ou
   no arquivo, contando repetições;
2. **títulos** — os 78 do v3 são 33 no plano e 45 no arquivo, os 72 da arte
   são 32 e 40, na mesma ordem relativa; os ⚠️ somam o mesmo (61 e 39);
3. **contiguidade** — cada bloco está inteiro no arquivo, e o plano novo, com
   cada ponteiro trocado de volta pelo bloco, é o original ao byte.

O que sobra do lado novo imprime-se e lê-se: só ponteiros, os dois cabeçalhos
e os títulos de grupo. **Quatro mutantes, cada um a reprovar pela pergunta
dele, com o controle verde entre todos:** uma linha apagada do arquivo
(multiconjunto e contiguidade); uma de duas ocorrências da mesma linha
apagada — que uma conta por `has()` dava por presente, medido: zero em falta
(multiconjunto); dois blocos trocados de ordem (títulos); e uma linha que
fica, tirada do plano e posta no arquivo — que o multiconjunto deixa passar
(reconstrução). ⚠️ **O primeiro injetor do segundo mutante não achou
candidata, e a prova correu verde sobre a base intacta**: um verde que não
provava nada, apanhado por conferir que o arquivo mudara (`gerais.md`, «confira
que o defeito chegou a quem o havia de ver»).

## Medido de passagem: o que carrega uma regra de tema

A `091` mediu o Read, o Edit, o Write e um `cat`/`head` de um arquivo só.
Nesta sessão carregaram também por **`grep` e `sed -n` de um arquivo só**: a
regra de arte com o `grep` dos títulos do plano de arte (o `paths:` dela
inclui-o), e as de captura e de GDScript com um `sed -n` em `folha_props.gd`
e em `FilaDeMensagens.gd`. Um `grep -rl` pela árvore inteira, antes disso, não
carregou nenhuma — que é o que a `091` já dizia. O núcleo passou a dizê-lo.

## O que fica por fazer

Nenhuma guarda impede um ✅ de se acumular outra vez num plano: a regra vive
nas duas skills, que é onde o fecho a encontra. Uma guarda no
`conferir_docs.py` — título ✅ num plano, fora das metades declaradas —
seria uma asserção nova com o seu defeito injetado (F6, Opus), e não é parte
do M5.
