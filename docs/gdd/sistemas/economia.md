<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📊 Tabela de Referência Econômica

Números de balanceamento iniciais validados por modelo semanal (v1.0). Todos sujeitos a ajuste pós-playtest — o propósito aqui é ter uma base comum entre designer e programador.

## 💵 Abertura de caixa — Semana 1

| | |
|---|---|
| **Caixa inicial (herança do avô)** | R$ 600 |
| **Custo obrigatório — limpeza do galpão (sem. 1)** | R$ 400 |
| **Caixa disponível após limpeza** | R$ 200 ⚠️ |
| **Alerta de design** | Nenhum outro custo pode ser obrigatório antes do 1º barco. R$ 200 não tem margem. |

## 🏦 Dívida — Parcelas ao Sr. Ribeiro

| | |
|---|---|
| **Parcela 1 — fim da Semana 4 (Ato 1)** | R$ 8.000 |
| **Parcela 2 — fim da Semana 8 (Ato 2)** | R$ 16.000 |
| **Parcela 3 — fim da Semana 12 (Ato 3)** | R$ 24.000 |
| **Total da dívida** | R$ 48.000 |
| **Ponto de ruptura** | Parcela 3 — a maior. Exige terceira fonte de renda ativa. |

## 📊 Cenários de viabilidade — modelo 12 semanas

| | |
|---|---|
| **🔴 Conservador (píer R$ 0 + 1 barco/sem)** | INVIÁVEL — margem negativa |
| **🟡 Base (píer R$ 40/vaga + 2 barcos/sem)** | Viável — caixa final ~R$ 300 ⚠️ |
| **🟢 Otimista (píer R$ 80/vaga + 3 barcos/sem)** | Folgado — caixa final ~R$ 4.000+ |
| **Margem operacional semanal (cenário base)** | R$ 370 / semana |
| **Margem × 4 semanas (sem upgrades)** | R$ 1.480 — insuficiente para Parcela 3 isolado |

## 🚨 Riscos identificados & decisões obrigatórias

**RISCO CRÍTICO — Parcela 3 não fecha sem 3ª fonte de renda** — O cenário base (píer + barcos) não cobre os R$ 24.000 da Parcela 3. DECISÃO OBRIGATÓRIA antes de codar: (A) disponibilizar armazém como renda passiva desde a semana 2 (R$ 150/sem mínimo) — não semana 5 como estava implícito no GDD — OU (B) reduzir a Parcela 3 de R$ 24.000 para R$ 18.000. Uma das duas é necessária. Ambas funcionam narrativamente.

**RISCO MÉDIO — Semana 1 sem margem de erro** — Caixa de R$ 200 após a limpeza do galpão. Qualquer custo extra não previsto no design nessa semana quebra o jogo antes de começar. Blindagem: garantir que Zezão não cobre nada além da limpeza, que não haja evento gerador de custo antes do 1º barco, e que o primeiro barco apareça na semana 1.

**RISCO MÉDIO — Cenário conservador é matematicamente inviável** — O jogador que escolher píer R$ 0 + docagem mínima entra em espiral. Isso é design intencional — as consequências das escolhas importam — mas o jogo precisa comunicar claramente (via Dona Cida) o impacto financeiro de cada decisão de aluguel. Sem esse feedback, o jogador se sente punido sem saber por quê.

## ✅ Recomendações de ajuste (pré-código)

**1. Armazém disponível como renda desde a semana 2** — R$ 150/sem resolve o gap do cenário base e torna o jogo viável mesmo com 2 barcos/sem. Narrativamente: Zezão termina a limpeza e o armazém começa a receber pequenas cargas locais espontaneamente — sem nova missão necessária.

**2. Aviso de Sr. Ribeiro 2 semanas antes de cada parcela** — O GDD já prevê isso. É essencial para o jogador planejar, não só reagir. Implementar como evento fixo no calendário de semanas 2, 6 e 10 — não como push notification, mas como diálogo em jogo.

**3. Tutorial deve mostrar impacto financeiro de cada aluguel de píer** — Dona Cida comenta o valor escolhido com ironia calibrada (já previsto no GDD). Incluir explicitamente a projeção semanal: 'Com R$ 40 por vaga, o píer rende R$ 240 por semana. Com R$ 0, rende zero.' Simples e suficiente.

**4. Manter parcelas sem alteração se armazém for adiantado** — Se a decisão for (A) — armazém na semana 2 — as parcelas de R$ 8k/16k/24k permanecem. Elas criam a tensão dramática correta e são atingíveis. Se a decisão for (B) — reduzir Parcela 3 — considerar R$ 18.000 como valor alternativo.

## 🏗️ Custo de construção (referência inicial)

| | |
|---|---|
| **Galpão pequeno** | R$ 300 |
| **Cais básico** | R$ 500 |
| **Grua básica** | R$ 800 |
| **Doca extra** | R$ 1.200 |
| **Oficina naval** | R$ 1.500 |
| **Armazém** | R$ 2.500 |
| **Torre de Controle** | R$ 4.000 |
| **Aduana** | R$ 5.000 |
| **Terminal de contêineres** | R$ 8.000 |
| **Estaleiro completo** | R$ 15.000 |

## 👷 Salários semanais — tabela base por especialidade

| | |
|---|---|
| **Estivador básico (entrada)** | R$ 80 / sem |
| **Carpinteiro naval (entrada)** | R$ 120 / sem |
| **Guarda noturno (entrada)** | R$ 100 / sem |
| **Logística administrativa** | R$ 160 / sem |
| **Mecânico naval** | R$ 200 / sem |
| **Gerente / Contadora** | R$ 250 / sem |
| **Hora noturna (add-on)** | +40% sobre o salário base |
| **Rescisão sem aviso** | 2 semanas de salário |

## 👤 Salários dos NPCs nomeados (com senioridade)

| | |
|---|---|
| **Toninho — Estivador-chefe** | R$ 210 / sem (base + 162% por 20 anos no porto) |
| **Marina — Operadora de guindaste** | R$ 180 / sem (especialização) |
| **Carol — Logística** | R$ 160 / sem (base) |
| **Kinha — Mecânica → Chefe de manutenção** | R$ 200 / sem (F2-F3) → negociável a R$ 280+ na F3 quando promovida |
| **Seu Biu — Vigia noturno (contratado)** | R$ 120 / sem (base + 20%, pela permanência e confiança) |
| **Dona Cida — Gerente / Contadora** | R$ 250 / sem (base — função única) |
| **Nota: NPCs aceitam negociação** | Salários acima da base refletem experiência. Pagar abaixo da expectativa cai a lealdade. |

## 📋 Faixa de valor de contratos por fase

| | |
|---|---|
| **Fase 1** | R$ 80 – R$ 300 por contrato |
| **Fase 2** | R$ 300 – R$ 800 |
| **Fase 3** | R$ 800 – R$ 2.000 |
| **Fase 4** | R$ 2.000 – R$ 6.000 |
| **Fase 5** | R$ 6.000 – R$ 20.000 |
| **Leilões (premium)** | 1,5× o teto da fase vigente |
| **Carga ilegal** | 2× com risco de reputação se descoberto |

## 💰 Renda passiva semanal estimada

| | |
|---|---|
| **Píer — aluguel pescadores (F1)** | R$ 150 / sem (base: 6 vagas × R$ 40) |
| **Píer — aluguel pescadores (F5)** | R$ 600 / sem |
| **Armazém (disponível sem. 2+)** | R$ 150 / sem mínimo ← DECISÃO v1.0 |
| **Armazém alugado (F2+)** | R$ 300 / sem |
| **Armazém alugado (F5)** | R$ 800 / sem |
| **Bônus alta temporada turística** | +30% sobre toda a renda passiva |
| **Manutenção de infra** | ~5% do valor total das construções / sem (~R$ 30 na F1) |

## ✅ Decisões de design fechadas

**🏗️ Custos de construção** · R$ 300 – R$ 15.000

Galpão: R$ 300. Cais básico: R$ 500. Grua: R$ 800. Oficina naval: R$ 1.500. Doca extra: R$ 1.200. Armazém: R$ 2.500. Torre de Controle: R$ 4.000. Aduana: R$ 5.000. Terminal contêineres: R$ 8.000. Estaleiro: R$ 15.000.

**👷 Salários semanais** · R$ 80 – R$ 250 / trabalhador (base)

Tabela base por especialidade: Estivador R$ 80/sem. Guarda R$ 100/sem. Carpinteiro R$ 120/sem. Logística R$ 160/sem. Mecânico R$ 200/sem. Gerente R$ 250/sem. NPCs nomeados pagam acima da base por senioridade (ex.: Toninho R$ 210 como estivador-chefe, Marina R$ 180 como operadora especializada). Hora noturna: +40% sobre o base. Rescisão sem aviso: 2 semanas de salário.

**📋 Valor de contratos** · R$ 8 mil → R$ 5 milhões

Fase 1: R$ 8.000–70.000. Fase 2: R$ 25.000–200.000. Fase 3: R$ 60.000–500.000. Fase 4: R$ 150.000–1.500.000. Fase 5: R$ 500.000–5.000.000. Leilões: 1,5× teto da fase. Carga ilegal: 2× com risco de reputação.

**💰 Renda passiva semanal** · R$ 150 – R$ 1.200 / semana

Píer (pescadores): R$ 150 (F1) → R$ 600 (F5). Armazém alugado: R$ 300 (F2) → R$ 800 (F5). Alta temporada turística: +30% sobre passivo total. Manutenção de infra: ~5% do valor total/semana.

**🔄 Demolição e recuperação** · 50% de retorno (herdadas: 30%)

Demolir qualquer construção recupera 50% do custo original. Construções herdadas do avô retornam apenas 30% — o jogo reflete o custo emocional de apagar a história.

**⚠️ Multas e penalidades** · Referência de perdas

Contrato quebrado: 20% do valor em multa + queda de reputação proporcional. Navio esperando >1 dia sem doca: −R$ 50/dia. Trabalhador demitido sem aviso: rescisão = 2 semanas de salário.

**💵 Abertura de caixa** · R$ 600 → R$ 200 após limpeza

Caixa herdado: R$ 600. Limpeza obrigatória do galpão (semana 1): R$ 400. Caixa disponível para operar: R$ 200. Cenário extremo — qualquer custo extra não planejado nessa semana levaria à crise antes do primeiro barco. DECISÃO: nenhuma outra despesa obrigatória pode existir antes do primeiro barco ser docado. Mesmo no pior cenário, NÃO há game over imediato (alinhado com Conceitos): a sequência de proteção é Dona Cida avisa → Sr. Ribeiro entra → Abutre oferece resgate. A semana 1 tem margem mínima, não morte súbita.

**🏦 Parcelas validadas** · R$ 550k / R$ 1,1M / R$ 1,65M

Parcela 1 (sem. 4): R$ 550.000. Parcela 2 (sem. 8): R$ 1.100.000. Parcela 3 (sem. 12): R$ 1.650.000. Total: R$ 3.300.000. ⚠️ A marca 'VALIDADO por modelo de balanceamento (v1.0)' foi RETIRADA em 26/08/2026: o cenário base que a sustentava (2 barcos/sem) não paga nem a Parcela 1 — ver o card 'Margem operacional base'. Apenas a Parcela 1 foi revalidada, por medição em 2.000 partidas do Vertical Slice (vazão de ~13,6 contratos/sem, 8 turnos/sem): fecha com ~20% de folga. As Parcelas 2 e 3 seguem NÃO VERIFICADAS e dependem da vazão e dos valores de contrato das Fases 2 e 3. Ver docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md.

**📊 Margem operacional base** · ~R$ 2.400/sem (Fase 1, corrigido)

CORRIGIDO em 26/08/2026 — o modelo anterior não fechava. Ele dizia: píer R$ 240 + contratos R$ 360 (2 barcos × R$ 180) = R$ 600, custos R$ 230, margem R$ 370/sem, e 4 semanas = R$ 1.480 — contra uma Parcela 1 de R$ 8.000. Faltava 5,4×. O erro não estava no valor do contrato (R$ 80–300 está certo) e sim na VAZÃO: 2 barcos por semana é pouco demais. Modelo corrigido e medido em 2.000 partidas: 8 turnos por semana, 2–3 docas, ~13,6 contratos/semana a R$ 184 médio = R$ 2.500 + píer R$ 240 − custos R$ 230/330 = ~R$ 2.400/sem. Em 4 semanas ≈ R$ 9.600, cobrindo a Parcela 1 com ~20% de folga. ATENÇÃO: as Parcelas 2 e 3 (R$ 16.000 e R$ 24.000) carregam a mesma aritmética não verificada — ver docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md.

**🚨 Risco crítico da Parcela 3** · Exige terceira fonte de renda

Sem armazém ativo desde a Fase 1, o cenário base não cobre a Parcela 3 (R$ 24.000). DECISÃO: o armazém deve estar disponível como fonte de renda passiva a partir da semana 2 (não semana 5 como era), gerando R$ 150/sem mínimo. Alternativa: reduzir Parcela 3 de R$ 24.000 para R$ 18.000. Uma das duas mudanças é obrigatória antes de codar a economia.

**🔴 Cenário conservador** · Inviável — não fecha

Píer R$ 0 (como o avô) + 1 barco/sem = margem operacional negativa. O jogo só funciona se o jogador cobrar aluguel E docar barcos regularmente. O tutorial deve deixar clara a consequência financeira de cada escolha de aluguel — não como punição, mas como consequência natural (Dona Cida comenta).

**🟢 Cenário otimista** · Píer R$ 80 + 3 barcos — folgado

Receita: R$ 480 (píer) + R$ 540 (3 barcos) = R$ 1.020/sem. Margem: R$ 790/sem. Caixa final semana 12: ~R$ 4.000+ após todas as parcelas. Deixa espaço para upgrades, construções e eventos adversos sem risco de falência. É o 'bom jogador' — não o esperado.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
