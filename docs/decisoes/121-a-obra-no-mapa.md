# 121 — A obra no mapa: o que se está a construir, dia a dia

**16/10/2026 · frente 4 do A5, as «obras» que a `074` deixou de fora** — a
continuação da melhoria gráfica da Fase 1 que o Codex começou no telefone e
não chegou ao GitHub (nenhum ramo `codex/*` depois do fecho do #134). **Em
produção: candidata, sem aceite.**

## Porque agora

A `074` refez a ruína e deixou as obras fora porque obra que leva turnos era
mecânica nova. A `087` trouxe essa mecânica: píer 2 e armazém levam dois dias
jogados, o pátio três, uma obra por vez e paga ao iniciar. Mas o mapa não
soube dela: do dia da compra ao dia em que fica pronto, o porto mostra a
mesma ruína, as mesmas estacas e a mesma terra batida, e a obra só existe no
texto do botão Construir («obra em andamento»). O jogador paga R$ e não vê
nada mudar durante dois ou três dias — o mesmo defeito que o
`_refresh_estruturas()` diz combater: «comprar uma estrutura é só um número
que baixa».

A `036` do ChatGPT dizia «não existe imagem `construction`: a compra do
armazém continua instantânea». Deixou de ser verdade com a `087`, e por isso
um estado de obra deixou de ser estado sem mecânica.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O item gráfico pendente da Fase 1 | **O estado «em obra» no mapa**, contra o armazém recuperado V3 (que ele lembra de ter aprovado: foi no checkout do ChatGPT, e o jogo ainda usa o galpão de 05/09) |
| A composição | **Andaime + material**, a recomendada: cada obra mostra o que está a ser feito, contra o tapume que fecha tudo e a só sinalização |
| A progressão | **Avança por dia**, contra um estado só: dois estágios no píer e no armazém, três no pátio |
| Pessoas na obra | **Sem pessoas**, a recomendada: a obra é contratada e não tira trabalhadores (`087`) |
| O cartão da doca durante a obra do píer | **«píer em obra · pronto no dia N»**, a recomendada, com o prazo do `prazo_da_obra()` |

## O estágio de cada dia

O estágio sai do `obra_em_andamento`: `dias_da_obra − dias_restantes`, que
é 0 no dia da compra e chega a `dias_da_obra − 1` no último dia antes de
ficar pronta. A obra comprada no dia 1 com dois dias mostra o estágio 0 no
dia 1, o 1 no dia 2, e o prédio pronto no dia 3.
