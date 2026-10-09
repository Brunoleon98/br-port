# 085 — Três cobranças e reparos básicos na Fase 1

**07–08/10/2026.** Continuação autorizada da frente 5 após o PR #107 (`084`,
main `f7138eb`). Main atualizada, nenhum PR aberto e próximo número livre
conferido novamente antes de documentar. Branch `codex/frente-5-tres-cobrancas`.

## Recorte escolhido

Bruno escolheu **12 semanas de 7 dias**, cobranças nos dias **28, 56 e 84**,
reparos básicos e até dois píeres. Píer 2 abre no início; armazém no dia 8;
pátio no dia 29, com primeira parcela quitada. Escritório, píer 3, pórtico e
cais reforçado ficam para fases futuras, com motivo visível no Construir.

As duas primeiras quitações retomam a partida. A terceira encerra a Fase 1
após o dia 84. Antecipar conserva o recibo até fechar a janela, sem abrir a
próxima cobrança nem encurtar a partida. Obras, crédito opcional, cancelamento,
guindastes por fase, tutorial e mais trabalhadores por píer ficam para outros
PRs. A regra visual anterior de nível 2 com duas estruturas permanece; a arte
aprovada não foi redesenhada.

## Crédito e valores

**Escolha final do Bruno:** R$400 mil de caixa como crédito novo inicial,
devolvido em três parcelas menores e iguais, capital mais juros. Substitui
R$30/30/30 mil, a primeira de R$530 mil e a proposta R$530/200/200 mil.
Não há dívida herdada refinanciada nesse contrato. A moeda anterior ao #107
e os custos dos reparos foram restaurados.

O contrato entregue tem **três boletos de R$140 mil**: R$420 mil no total,
R$400 mil de capital e R$20 mil de juros. São 5% do capital no total, não ao
mês. Amortização aproximada de parcelas iguais (~2,48% por período de 28 dias):

| Cobrança | Capital | Juros | Boleto |
|---|---:|---:|---:|
| Dia 28 | R$130.081 | R$9.919 | R$140.000 |
| Dia 56 | R$133.307 | R$6.693 | R$140.000 |
| Dia 84 | R$136.612 | R$3.388 | R$140.000 |

A fórmula anterior sobre todo o boleto podia reduzir o total pago abaixo do
capital recebido. Agora antecipar devolve só a fração dos juros da janela
pelos dias restantes, limitada aos juros. A função genérica anterior continua
separada para contratos futuros. Contrato ficcional simplificado, sem IOF,
tarifas ou CET bancário real; não é cotação de um banco.

Diário, Ribeiro e painel passam a contar a origem do crédito e o total
contratado. É concessão inicial única, não a entrega de empréstimos opcionais.

## Medição e serviços

Cada proposta percorreu 600 partidas por perfil, semente 20260825, com fila,
calendário e desbloqueios reais. A exploração antiga R$30/45/60 mil não foi
tratada como aprovação nem validação. As alternativas descartadas e o
candidato final estão em `docs/arquivo/MEDICOES_FASE_1_2026-10-07.json`.

Só reduzir a dívida deixava o Mediano com caixa final mediano de R$1,87 milhão
em doze semanas. Mediu-se separadamente retorno de serviços em ×0,60 e ×0,45,
com custos dos reparos intactos. Escolheu-se ×0,45 com faixas arredondadas:
**pesqueiro R$4–9 mil, cargueiro R$7–16 mil, longo curso R$18–28 mil**.
Longo curso permanece bloqueado nesta fase; sua faixa pertence ao catálogo
futuro, sem alegar validação de fase ainda não implementada.

Medição final sem travamentos: o Mediano tem saldo mediano após as cobranças
de R$155.522 / R$272.835 / R$530.529; P10 após a primeira R$121.244. No
Antecipado, P10 após a segunda é R$42.898: quitar cedo tem custo de oportunidade.
O Descuidado termina com mediana R$137.814 e sem os reparos: sua reserva de
compra de 4× adia investimento, não representa todos os humanos. Taxas atuais
vivem só no `CLAUDE.md`; alvo tranquilo (`005`), expansão e margem distinguem
as estratégias (`009`). Bots não validam compreensão ou experiência humana.

A pesquisa solicitada vive em `docs/design/BR_Port_Metodo_Balanceamento_Economia.md`:
fontes primárias de GDC e pesquisa acadêmica, fontes/sumidouros, caixa livre,
custos de posse e retorno incremental. Inclui tarifas oficiais de Paranaguá e
composição do crédito do BNDES. Contrato agregado não equivale a tarifa por
tonelada ou metro/hora; faltam essas quantidades no jogo. As faixas não foram
certificadas como preços reais, especialmente para pesca artesanal. A redução
de receita foi escolha de ritmo medida, não conversão automática da tarifa.
Carros e imóveis continuam futuros, sem preços aprovados ou funções adicionadas.

O simulador mede cada cobrança, antecipações, P10/P50/P90 e tamanho de amostra,
saldo após pagar e margem por semana. `--sem-save` usa o mesmo GameState,
substituindo só persistência; os JSONs finais de dez partidas por perfil com
e sem autosave são idênticos campo a campo. A base 084 foi reconstruída de
`f7138eb`. O prêmio da escolha e o estado do porto vêm da mesma população e
semana em regime; pagamentos de todas as parcelas saem da margem operacional.

Não se aumentou tolerância para calibrar o projetor. O Descuidado calibra pelo
piso absoluto já existente de meio barco (desvio R$1.526 menor que R$3.250),
apesar de erro relativo de 12,4%. Os intervalos futuros
continuam saindo do GDD: usar as novas doze semanas ali triplicava a renda.
Fases 2/3 projetadas não validam três cobranças reais na Fase 1.

## Save, interface e regressões

**Save 12, sem migração:** moeda, crédito, calendário, desbloqueios e significado
do recibo mudaram. Guardam-se índice da cobrança, quantidade quitada e total
efetivamente pago. Versões anteriores, versão fracionária/textual e novos
campos inválidos são recusados antes de aplicar qualquer campo no estado vivo.

HUD e cobrança acompanham janela e progresso. Calendário mostra três datas e
rola pelas doze semanas. Caderno aprovado permanece em duas páginas; o recibo
mostra o total efetivamente pago. Portos completos em testes/capturas são
bancadas explícitas de componentes futuros, não compras que contornam bloqueios.
T14 percorre 84 dias pelas portas reais, três cobranças, retomada de saves,
antecipação, idempotência, recusa e insuficiência. Mutantes verificam bloqueio
do armazém e preservação do capital na antecipação.

## Fecho

As seis suítes do Godot 4.6.3 passaram; medição final de 600 partidas por
perfil, paridade de autosave, mutantes, tabela de constantes, documentação,
guardas do CI e escopo de UI verificados. As 64 capturas passaram com cobertura
dos painéis, tempos e expressões; contrato, diário, desbloqueios, calendário,
caderno e balanço foram olhados. A captura do balanço joga a partida real e
registra três quitações, retomadas após as duas primeiras e vitória no dia 85
(após fechar o 84). Bancadas e suítes usaram perfil isolado, sem concorrência
entre capturas e suítes. Sentinela confere arquivos do jogador byte a byte.
Briefing seguinte arquivado no mesmo commit; entrega por PR, sem merge automático.
