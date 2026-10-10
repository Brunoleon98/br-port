# 087 — Obras dos reparos básicos levam dias jogados

**09/10/2026.** Main `f5f88b5`, após confirmar os merges #108 (`085`) e
#109 (`086`) e nenhum PR aberto; 087 livre reconferida antes de escrever.
Branch `codex/frente-5-obras-reparos`, um recorte da frente 5.

## Escolha do Bruno e GDD

Bruno escolheu **1: obras dos reparos da Fase 1**, e respondeu **“sim”** à
proposta completa: píer 2 em dois dias, armazém em dois, pátio em três; uma
obra por vez, sem retirar trabalhadores dos píeres, pagamento ao iniciar,
benefícios ao concluir e **Save 14 com recusa da 13, sem migração**.
Partidas antigas precisam recomeçar. O aceite é novo: a autorização do
Save 13 na `086` não foi reutilizada para mudar outra versão.

GDD lido antes de propor: `docs/gdd/conceitos/tempo.md` diz dias confirmados
pelo jogador e nada com o aplicativo fechado; `docs/gdd/conceitos/construcao.md`
descreve os pequenos reparos executados por Zezão; `docs/gdd/sistemas/tutorial.md`
cita dois dias para a primeira limpeza do armazém. O GDD não define os
outros prazos: dois/três dias são escolha aprovada para este recorte, não
números atribuídos ao GDD. Tutorial e trabalhador da construção não foram
implementados. Os arquivos gerados do GDD congelado permanecem intactos.

## Pagamento, dias e conclusão

`comprar_estrutura()` cobra uma vez e guarda `obra_em_andamento` com id,
dia de início e dia de conclusão. `estruturas` contém somente as prontas.
Os preços, desbloqueios e requisitos da `085` permanecem: início no dia 1,
armazém no 8, pátio no 29 depois da primeira quitação. Não há cancelamento,
reembolso, contratação nem segunda obra concorrente neste recorte.

Dois dias iniciados no dia 1 são os dias 1 e 2, com benefícios no dia 3.
Armazém iniciado no 8 fica pronto no 10; pátio iniciado no 29, no 32.
O fecho processa primeiro serviços e custos da semana do porto antigo;
depois conclui a obra, antes da pausa para dívida e da abertura do novo dia.
Não se paga retroativamente bônus nem salário de trabalhador que acabou
de entrar. Decisões, pagamento de parcela e carregamento não passam dias.
Obra que não terminaria até o fechamento do dia 84 é recusada sem cobrar.

`estrutura_comprada` continua sendo o pagamento registrado e o som de obra.
`obra_concluida` dispara a reação de pronto da Dona Cida; iniciar não diz
“pronto”. HUD e Construir mostram andamento, prazo e pagamento; os benefícios
continuam restritos às estruturas concluídas. Mapa, PNGs, projeção e animações
aprovadas não mudaram. Até dois píeres; madeira em toda a Fase 1 (`086`).
O pátio concluído dobra a renda do píer; só o adicional de contêiner espera
clientes futuros. Bancadas montam explicitamente estruturas prontas para
testar arte/contraste futuro; isso não é progressão do jogador.

## Save 14 e regressão

Obra em andamento é persistida e retoma os mesmos dias e saldo, sem nova
cobrança. `new_game()` limpa-a. A aceitação exige dicionário (vazio ou forma
completa válida), id liberado, datas inteiras, duração correta, início permitido,
dia de conclusão futuro dentro da fase e estrutura ainda não concluída.
Todas as recusas precedem a aplicação de campos. Consulta preserva o arquivo;
carregamento descarta o incompatível. A 12 segue recusada, inclusive com
reparos/cargueiro; a 13 agora também. Metadado de guindaste continua efêmero,
restrito a `--script`, limpo só em nova partida/carregamento válido.

T14 continua percorrendo os 84 dias e retomando as três cobranças reais.
T15 cobre pagamento único, exclusão mútua, dias, retomada, efeitos adiados,
conclusão em vencimento/fecho semanal, teto da fase, nova partida e compara
todo o estado persistido antes/depois de recusas, inclusive obra e bancada.
D23 mede o rótulo real do HUD; D33 cobre contraste do painel em obra.

A captura `balanco` encontrou uma oferta real do Arlindo sorteada dentro do
pagamento da segunda parcela por cima da resposta do Ribeiro. Só esse caminho
agora espera resposta → boletim → oferta; a prioridade habitual do rival
permanece. T16 usa o botão de pagar e as cenas reais, espera sua saída e
confere as duas ordens. Dois defeitos injetados (oferta imediata após pagar e
fila para toda oferta) reprovam sem erro de script e com o bloco completo.
`SceneTree._process()` retorna false até o `quit()` final: true encerrava o
teste assim que ele chegava ao primeiro `await`, sem medir a sequência.

## Economia medida, sem reajuste

600 partidas por perfil, semente 20260825, Godot 4.6.3. A base refeita é
idêntica à medição final da `086`, sem propostas descartadas da `085`.
Crédito R$400 mil, três parcelas R$140 mil, juros totais R$20 mil; antecipar
abate só juros da janela. Dez partidas por perfil com/sem autosave deram
JSONs idênticos, incluindo as novas medições de obras.
Antes/depois completo, quantis, n e desbloqueios/inícios/conclusões:
`docs/arquivo/MEDICOES_OBRAS_FASE_1_2026-10-09.json`.

Cada caixa é **P10 / P50 / P90**, em reais; no Antecipado é a decisão de
antecipação na janela, e não uma fotografia no vencimento.

| Perfil | Dia | Chegaram / pagaram | n antes / depois | Caixa antes da decisão | Saldo após pagar | P50 após pagar na base |
|---|---:|---:|---:|---:|---:|---:|
| Ótimo | 28 | 600 / 600 | 600 / 600 | 336.373 / 365.003 / 390.884 | 196.373 / 225.003 / 250.884 | 241.062 |
| Ótimo | 56 | 600 / 600 | 600 / 600 | 516.639 / 559.937 / 599.519 | 376.639 / 419.937 / 459.519 | 436.735 |
| Ótimo | 84 | 600 / 600 | 600 / 600 | 820.804 / 872.290 / 917.328 | 680.804 / 732.290 / 777.328 | 748.560 |
| Mediano | 28 | 600 / 600 | 600 / 600 | 264.823 / 298.032 / 328.689 | 124.823 / 158.032 / 188.689 | 172.709 |
| Mediano | 56 | 600 / 600 | 600 / 600 | 336.256 / 404.819 / 464.736 | 196.256 / 264.819 / 324.736 | 310.345 |
| Mediano | 84 | 600 / 600 | 600 / 600 | 584.732 / 665.162 / 730.720 | 444.732 / 525.162 / 590.720 | 568.051 |
| Descuidado | 28 | 600 / 600 | 600 / 600 | 430.796 / 453.759 / 475.885 | 290.796 / 313.759 / 335.885 | 313.759 |
| Descuidado | 56 | 600 / 600 | 600 / 600 | 333.441 / 366.603 / 395.312 | 193.441 / 226.603 / 255.312 | 226.603 |
| Descuidado | 84 | 600 / 600 | 600 / 600 | 238.436 / 277.814 / 313.952 | 98.436 / 137.814 / 173.952 | 137.814 |
| Antecipado | 28 | 600 / 600 | 600 / 600 | 250.000 / 250.000 / 250.000 | 119.565 / 119.565 / 119.565 | 119.565 |
| Antecipado | 56 | 600 / 600 | 600 / 600 | 175.244 / 202.601 / 223.521 | 41.698 / 69.055 / 89.975 | 72.174 |
| Antecipado | 84 | 600 / 600 | 600 / 600 | 191.608 / 225.778 / 295.710 | 54.875 / 89.045 / 158.977 | 103.714 |

O custo da espera reduz caixa acumulado; não justifica alterar preços.
Todos os perfis pagaram as três cobranças; não houve travamento. Taxas e
margens atuais ficam no `CLAUDE.md`, com a medição completa no arquivo.
Descuidado não inicia obras e sua economia é idêntica à base; Ótimo, Mediano
e Antecipado concluem os três reparos em todas as 600 partidas.

Dias de início/conclusão são **P10 / P50 / P90**, com n de cada amostra;
desbloqueios observados no dia 1/8/29 em 600 partidas de cada perfil.

| Perfil | Reparo | n início / conclusão | Dia do pagamento | Dia pronto |
|---|---|---:|---:|---:|
| Ótimo | armazem | 600 / 600 | 8 / 8 / 8 | 10 / 10 / 10 |
| Ótimo | patio | 600 / 600 | 29 / 29 / 29 | 32 / 32 / 32 |
| Ótimo | pier_2 | 600 / 600 | 1 / 1 / 1 | 3 / 3 / 3 |
| Mediano | armazem | 600 / 600 | 13 / 17 / 19 | 15 / 19 / 21 |
| Mediano | patio | 600 / 600 | 33 / 35 / 40 | 36 / 38 / 43 |
| Mediano | pier_2 | 600 / 600 | 1 / 1 / 1 | 3 / 3 / 3 |
| Descuidado | armazem | 0 / 0 | — | — |
| Descuidado | patio | 0 / 0 | — | — |
| Descuidado | pier_2 | 0 / 0 | — | — |
| Antecipado | armazem | 600 / 600 | 51 / 55 / 57 | 53 / 57 / 59 |
| Antecipado | patio | 600 / 600 | 29 / 29 / 29 | 32 / 32 / 32 |
| Antecipado | pier_2 | 600 / 600 | 1 / 1 / 1 | 3 / 3 / 3 |

Projetor calibrado sem afrouxar tolerância: Ótimo 0,4%, Mediano/Antecipado
0,2%; Descuidado pelo piso existente (R$1.526 < R$3.250). Isso não valida
Fases 2/3. Crédito não é lucro, patrimônio não é caixa e receita do porto
não é dinheiro pessoal. Preços continuam ficcionais; tarifas por quantidade
não certificam estes contratos sem toneladas/metros/horas correspondentes.

## Fecho e próximo recorte

Verificações, captura e defeitos injetados registrados no JSON da medição.
As seis suítes passaram; quatro defeitos de obra e dois de ordem dos painéis
reprovaram, com originais restaurados byte a byte e verde entre as mutações.
A bateria completa passou: 66 PNGs 720×1280, 17 painéis, todos os 11 tempos e
nove retratos; andamento, reparos prontos e balanço foram olhados. A régua do
boletim confirmou 11.200 boletins em 200 partidas por perfil, incluindo Parado;
cinco gravações passaram no leitor. Sua primeira corrida no Windows atingiu
o limite local de 20 minutos sem marcador; repetida com limite de 40 minutos,
mesma amostra/semente, terminou com `BOLETIM OK`. Tabela, projetor, documentos,
escopo de UI e guardas de CI passaram, sem afrouxar tolerâncias.
Perfil isolado com cinco sentinelas; captura separada das suítes. No Windows,
PNG 720×1280 e conteúdo LF de `Narrativa.gd`, sem alteração semântica.
Documentos e briefing entram no mesmo commit. Próxima decisão esperada: 088,
reconferir na main. Escolher com Bruno entre crédito opcional, cancelamento,
tutorial, mais trabalhadores por píer ou progressão futura, lendo o GDD antes.
Carros/imóveis e preços desses bens continuam fora desta frente.
