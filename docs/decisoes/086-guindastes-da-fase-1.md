# 086 — O guindaste de madeira permanece na Fase 1

**08/10/2026.** Main `0d6705e`, após o merge do PR #108 (`085`), confirmado
no GitHub; nenhum PR aberto, decisão 086 livre reconferida antes de escrever.
Branch `codex/frente-5-guindastes-fase-1`, um recorte da frente 5.

## Escolha do Bruno e limite

Bruno escolheu **“Guindastes da Fase 1 (recomendado)”**: manter o aparelho
aprovado de madeira durante toda a Fase 1 e reservar o intermediário para
a Fase 2. O GDD foi lido antes do recorte: `docs/gdd/conceitos/construcao.md`
descreve consertos e pequenas melhorias no porto herdado; fases de construção
não são atos narrativos. Não se inventou prazo, preço ou condição de avanço
para a Fase 2. A Fase 1 conserva as doze semanas, as três cobranças e os
reparos da `085`. Obras, crédito opcional, cancelamento de trabalho, tutorial
e mais trabalhadores por píer seguem pendentes. Carros e imóveis são futuros.

## Comportamento e arte

Comprar píer 2, armazém ou pátio não promove mais o guindaste ao nível 2.
O porto recebe pesca durante os 84 dias, porque a classe depende do menor
nível entre píer e guindaste. O Construir explica a madeira e reserva novos
guindastes para a Fase 2. Até dois píeres e seus trabalhadores permanecem.

A base da máquina é parte do PNG do píer: trocar só a lança deixava madeira
sobre torre metálica. `Dock.gd` usa o conjunto n1 aprovado enquanto a máquina
for de madeira. Capacidade e arquivos de arte não mudaram. Bancadas continuam
montando e animando os níveis 2/3 aprovados; o intermediário só existe como
metadado efêmero em processos `--script`, não é compra nem campo do save.
Partida nova e carregamento válido limpam essa montagem; recusa não toca o
estado vivo. Isso preserva os testes da arte futura sem promovê-la no jogo.

## Economia medida, sem reajuste

600 partidas por perfil, semente 20260825, Godot 4.6.3. A rodada antes foi
refeita na main e é idêntica à escolha final `credito_inicial_final` da `085`;
as propostas descartadas daquele JSON não são a base. Mesmos preços,
crédito R$400 mil, parcelas R$140 mil e juros R$20 mil. Antes/depois e todos
os quantis, desbloqueios, compras, margens e tamanhos das amostras vivem em
`docs/arquivo/MEDICOES_GUINDASTES_FASE_1_2026-10-08.json`.

Cada célula de caixa abaixo é **P10 / P50 / P90**, em reais. Chegaram/pagaram
refere-se à cobrança real; no Antecipado, caixa e saldo são do instante da
antecipação dentro da janela, não uma fotografia tirada no vencimento.

| Perfil | Dia | Chegaram / pagaram | n antes / depois | Caixa antes da decisão | Saldo após pagar | P50 após pagar na base |
|---|---:|---:|---:|---:|---:|---:|
| Ótimo | 28 | 600 / 600 | 600 / 600 | 356.121 / 381.062 / 407.503 | 216.121 / 241.062 / 267.503 | 222.930 |
| Ótimo | 56 | 600 / 600 | 600 / 600 | 533.118 / 576.735 / 615.175 | 393.118 / 436.735 / 475.175 | 424.335 |
| Ótimo | 84 | 600 / 600 | 600 / 600 | 837.043 / 888.560 / 933.638 | 697.043 / 748.560 / 793.638 | 747.474 |
| Mediano | 28 | 600 / 600 | 600 / 600 | 276.661 / 312.709 / 349.150 | 136.661 / 172.709 / 209.150 | 155.522 |
| Mediano | 56 | 600 / 600 | 600 / 600 | 378.730 / 450.345 / 502.482 | 238.730 / 310.345 / 362.482 | 272.835 |
| Mediano | 84 | 600 / 600 | 600 / 600 | 626.551 / 708.051 / 767.493 | 486.551 / 568.051 / 627.493 | 530.529 |
| Descuidado | 28 | 600 / 600 | 600 / 600 | 430.796 / 453.759 / 475.885 | 290.796 / 313.759 / 335.885 | 313.759 |
| Descuidado | 56 | 600 / 600 | 600 / 600 | 333.441 / 366.603 / 395.312 | 193.441 / 226.603 / 255.312 | 226.603 |
| Descuidado | 84 | 600 / 600 | 600 / 600 | 238.436 / 277.814 / 313.952 | 98.436 / 137.814 / 173.952 | 137.814 |
| Antecipado | 28 | 600 / 600 | 600 / 600 | 250.000 / 250.000 / 250.000 | 119.565 / 119.565 / 119.565 | 119.565 |
| Antecipado | 56 | 600 / 600 | 600 / 600 | 176.945 / 205.720 / 226.656 | 43.399 / 72.174 / 93.110 | 71.946 |
| Antecipado | 84 | 600 / 600 | 600 / 600 | 198.380 / 240.447 / 295.155 | 61.647 / 103.714 / 158.422 | 100.650 |

Não houve travamento. Taxas atuais ficam no `CLAUDE.md`. A madeira não ameaça
os boletos nesta amostra; o Mediano melhora porque atende pesca de um dia em
vez de prender berços com cargueiros de dois dias. A margem em regime passa
de R$115.996 para R$111.849 no Ótimo; Mediano R$99.228 e Descuidado R$12.339.
O Descuidado não constrói em nenhum dos cenários e seus JSONs são idênticos.
Ótimo, Mediano e Antecipado terminam com todos os três reparos em 600 partidas.

**Limitação do pátio:** permanece disponível no dia 29 após a primeira cobrança,
mas seu bônus de contêiner não é acionado por pesqueiros. O pátio **continua dobrando a renda semanal dos píeres alugáveis**; ele não
é uma compra sem retorno. Só a parcela do efeito vinculada a contêiner fica
reservada à chegada desse cliente em fases futuras. Revisar catálogo/explicação
em recorte próprio com Bruno; não se inventaram clientes nem se mexeu em
preços para compensar. Dois píeres e armazém também conservam seus efeitos.

O simulador rápido usa o mesmo GameState. Dez partidas por perfil com e sem
autosave deram JSONs idênticos campo a campo. O projetor calibrou sem alterar
tolerância: erros de 0,7% no Mediano/Antecipado, 0,5% no Ótimo; Descuidado passa
pelo piso existente de meio barco (R$1.526 < R$3.250). Isso não valida Fases 2/3.
Crédito não é lucro, patrimônio não é caixa e receita do porto não é dinheiro
pessoal. Preços continuam ficcionais; tarifas por quantidade não certificam
contratos agregados sem toneladas, metros e horas. Bots não validam compreensão.

## Save e verificação

**PR em rascunho, bloqueado para merge.** `SAVE_VERSION` permanece em 12;
a autorização explícita para 13 foi solicitada ao Bruno conforme `AGENTS.md`
e continua pendente. O `CLAUDE.md` exige nova versão quando a interpretação
muda: saves 12 antigos podem conter cargueiros incompatíveis com a montagem
de madeira. Não migrar nem liberar o PR antes de recusar esses saves pela
versão, antes de aplicar campos, e provar essa recusa. A `085` permanece
entregue na main; este recorte ainda não está concluído para o jogador.

As seis suítes passaram com seus marcadores, sem erro de script: lógica,
design, áudio, fumaça, registro e assets. T14 percorre os 84 dias, inclusive
saves entre cobranças; reintroduzir promoção por duas estruturas reprovou
a madeira dos dias 8–84, e o original foi restaurado byte a byte. T5l prova
que o save conserva os reparos e limpa o nível artificial da bancada. D39
prova a lança e a base de madeira após os três reparos pela porta real.

65 capturas com guardas de turno/painéis e PNGs 720×1280; cobertura de todos
os 17 painéis, 11 tempos e nove expressões. Conjunto n1 após píer 2/armazém,
Construir e guindaste intermediário inspecionados; arquivos de arte sem diff.
Suítes e captura foram sequenciais, em perfil isolado. Cinco arquivos de
sentinela permaneceram idênticos byte a byte. Despejo/tabela, calibração,
documentos, escopo de UI e guardas do CI conferidos; não se afrouxou portão.
No Windows a base falhou com CRLF no literal da narração; seu conteúdo LF,
igual ao blob Git, passou sem mudar a peça. Receita registrada no `CLAUDE.md`.

Estado, plano, decisão, medição e briefing entram no mesmo commit do rascunho.
A próxima conversa conclui a compatibilidade no mesmo PR, sem abrir outro
recorte enquanto essa pendência estiver ativa.
