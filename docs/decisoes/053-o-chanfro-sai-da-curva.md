# 053 — O chanfro sai da curva, e não a curva do chanfro

**23/09/2026 · opção (i) do briefing `23i`, escolhida pelo Bruno** junto com a
(g) e a (h) («faça os três»). A `052` deixou-a por decidir porque MUDA o mapa,
que o CI compara byte a byte.

## O que se decidiu

**A ordem entre o mapa e o caminho inverteu-se.** Até aqui o gerador chanfrava
as duas quinas salientes de cada cotovelo em meia rua (0,9), e o `Main.gd`
derivava desse chanfro a diagonal com que a curva aberta corta a quina. Hoje a
diagonal é do `Main.gd` — `corte_da_curva()`, a meia faixa do vértice, o MESMO
0,636 de antes —, e o gerador deriva o chanfro dela e do maior camião:

    chanfro = RUA_LARG/2 + corte_da_curva − (chassi + largura)/2
            = 0,9 + 0,6364 − (1,4112 + 0,4464)/2 = 0,6076  →  0,60

arredondado PARA BAIXO ao centésimo: arredondar para baixo é arredondar para
o lado do asfalto, e número que entra em toda coordenada da rua tem de ser
exato. **O caminho dos camiões não mudou um bit** (o corte novo e o velho dão o
mesmo `float`, conferido); mudou o desenho das dez quinas.

## Por que — a conta, e depois a medição

Na diagonal, o camião anda com a silhueta do eixo do trecho a que cada metade
pertence: um retângulo alinhado ao eixo a andar a 45°. Somadas as distâncias
às duas bordas de fora, o caminho está a `0,9 + 0,636 = 1,536`, e a quina da
carroçaria que aponta para a ponta chanfrada fica `(chassi + largura)/2` para
dentro dessa linha — `0,607` no porta-contêiner. Com o chanfro a 0,9 ela ficava
**0,207 além do asfalto**, na perpendicular do chanfro: por cima do meio-fio e
do passeio. É o 0,21 que a `052` registou.

| | antes | depois |
|---|---:|---:|
| chanfro | 0,9 (meia rua) | **0,60** |
| a quina de carroçaria que mais se aproxima da borda (D13 §7j) | **0,207 fora** | **0,005 dentro** |
| caminho dos camiões | — | idêntico (o mesmo `float`) |
| arquivos regerados | — | os dois mapas de rua e as âncoras; as duas espumas ficam byte a byte |

A esquina continua chanfrada. O que o 4b pediu (`013`) é que ela não acabe em
ponta de 90°, e não um tamanho: a ponta recua menos. A viela, de que o chanfro
de 0,9 comia 0,08, deixa de ser tocada — abre a 0,82 da quina.

## A guarda que faltava

**D13 §7j** — com três fontes, e nenhuma espelho de outra: o caminho sai do
`Main.gd` (`trechos_de()`), o chanfro das âncoras (o gerador), e o tamanho de
cada camião do `D35_CHASSI`, que o copia do kit do Blender. Para cada meia
diagonal das duas rotas (20, dez curvas abertas), para cada camião e oito
posições ao longo dela, as quatro quinas do chassi têm de ficar dentro das duas
bordas retas e do chanfro. Escrita ANTES da mudança, reprovou no mapa velho com
0,207, o número da conta.

**D13 §7i** mudou de pergunta: conferia que o `Main.gd` repetia o chanfro do
mapa, e o `Main.gd` já não o tem. Confere agora que a diagonal do `Main.gd` é a
de que o gerador derivou o chanfro — as âncoras publicam `corte_da_curva`.

O gerador guarda a sua cópia do maior camião (`CAMIAO_MAIOR`). Se o camião
crescer no Blender e a cópia não, o chanfro sai grande demais e é o §7j que
reprova, pela cópia do D35.

| mutante | o que reprovou |
|---|---|
| I1 o gerador volta ao chanfro de meia rua | o §7j, 0,207 |
| I2 o gerador deriva do camião do granel | o §7j, 0,122 — no porta-contêiner |
| I3 o gerador arredonda em vez de arredondar para baixo (0,61) | o §7j, 0,002 |
| I4 o `Main.gd` alarga a curva 10% sem regerar o mapa | **só** o §7i: o §7j, o D20 e o D35 passam nesse estado, com mais folga |

Base verde conferida antes e depois; originais guardados por `cp`; nos três
do gerador, só a tabela de âncoras regerada entrou no projeto, e o script
exigia que ela tivesse mudado.

## O que fica de fora

- **A curva fechada** continua com o palmo de 0,25 do porta-contêiner, e ali
  ele cai na OUTRA faixa, que é asfalto; separa-os o tempo (`052`).
- **Mede-se a pegada do chassi**, como o D35. Um retrovisor ou um monte de
  granel acima da borda não entram, e o que o olho lê numa curva é do A5.
- **A folga é 0,005** — a quina da carroçaria roça o meio-fio. É o que a conta
  pede sem inventar margem; quem quiser folga visível baixa o chanfro, e o
  §7j continua a passar.
