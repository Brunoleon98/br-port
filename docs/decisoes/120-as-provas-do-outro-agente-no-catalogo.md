# 120 — As provas do outro agente entram no catálogo

**16/10/2026.** Branch `claude/gracious-mendel-oiww62`, com a main `7a8ec41`
juntada (PR #134, a ajuda «Como jogar», fundido pelo Bruno); nenhum PR
aberto, nenhum ramo do Codex mais novo. 120 livre pelo
`tools/conferir_colaboracao.py`. Pedido do Bruno: *criar o PR com o que foi
aprendido aqui, aplicando-o no projeto, e ver antes o que o Codex fez de novo.*

## O que o Codex tinha feito

As duas entregas mais recentes dele provaram-se com defeitos injetados, como
a regra manda — e as provas ficaram onde a `117` diz que não ficam:

- o **cancelamento** (`111`) com oito mutantes num executor próprio,
  `tools/testar_integracao_cancelamento.py`, que só corre quando alguém se
  lembra de o correr — não está em workflow nenhum;
- a **ajuda** (`115`) com seis defeitos descritos em prosa, numa tabela do
  arquivo de verificação, sem código que os repita.

E o #134 trouxe um **T25** (a ajuda), o mesmo número do jogador ao acaso
desta branch.

## O que mudou

- **Treze defeitos dele no catálogo**, um por troca exata, cada um explorado
  e declarado pela asserção dele que o apanha: sete do cancelamento (o
  oitavo, o orçamento ignorado, já lá estava pela `118`) e os seis da ajuda.
  Passam a correr a cada PR, dos dois agentes, no job «Defeitos já
  provados». O catálogo tem 58.
- **O jogador ao acaso passou a T26**, pelo `tools/renumerar_decisao.py
  --bloco`, que troca o nome do bloco só nas linhas que esta branch
  escreveu — as citações do T25 do Codex ficaram como estavam.
- **O pré-PR confere o bloco repetido também contra a base**, e não só
  contra os outros ramos: foi contra a `main` que o T25 colidiu.

## O que a reconstrução ensinou

⚠️ **O defeito em prosa pode ser reconstruído EQUIVALENTE.** A `115` dizia
«fundo e raiz deixam o toque passar»; a primeira reconstrução mexeu só na
raiz da cena — um sítio, uma linha —, e passou verde: o fundo escurecido,
filho dela, continuava a segurar o toque, e o jogo não mudava. Com os dois,
reprova «toque no fundo não atravessa a ajuda». É a razão de a prova viver
como troca exata e não como frase: a frase deixa quem a reconstrói escolher
um defeito mais fraco do que o que foi provado.

Os outros doze reprovaram pela guarda do Codex na primeira corrida.

## O que fica de fora

- **O executor próprio do Codex** fica onde está: é dele, e apagá-lo é
  decisão do Bruno. Hoje é redundante com o catálogo para os sete que
  entraram.
- **Os defeitos das entregas mais antigas** dele (a frente 5) continuam em
  prosa nas decisões; entram quando alguém mexer naquele código.
