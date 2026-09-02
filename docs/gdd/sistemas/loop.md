<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🔄 Core Loop de Sessão

O que o jogador faz nos primeiros 5 minutos após abrir o app — e o que o faz voltar amanhã.

## 🌅 Fluxo de uma sessão típica

**1. Abertura — Boletim do Porto** — O app exibe automaticamente o resumo do último turno em 3 itens: navio chegado, ação rival, prazo urgente. ≤ 5 segundos de leitura. Depois, mapa do dia atual.

**2. Verificação — Estado do porto** — O jogador vê quais navios estão na doca, quais trabalhadores estão ociosos, quais contratos estão ativos. Tudo visível sem abrir menus.

**3. Decisão — Alocar e priorizar** — Arrastar trabalhadores → definir prioridade de doca → aceitar ou rejeitar contratos da fila. A maioria das sessões termina aqui (5–10 min).

**4. Construção — Expandir quando necessário** — Sessões mais longas (20–30 min) incluem decisões de infraestrutura: o que construir, o que demolir, o que fazer upgrade.

**5. Narrativa — Missões e diálogos de NPCs** — Quando disponível, o jogador interage com NPCs e toma decisões de missão. Acontece uma vez por semana de jogo, não em toda sessão.

**6. Confirmar avanço — Fim do turno** — Quando todas as decisões do dia foram tomadas, o jogador toca em 'Próximo dia'. O jogo processa o dia, mostra um resumo curto do que aconteceu e abre o próximo turno.

## 📱 Política de offline e sessão

**App fechado = jogo pausado** — Nada acontece sem o jogador. Navios não chegam, contratos não vencem, rivais não agem enquanto o app está fora.

**Contratos não têm relógio do mundo real** — Prazo medido em dias de jogo. O dia só passa quando o jogador confirma o avanço — não quando o relógio do celular bate meia-noite.

**Sessão curta é suportada** — Uma sessão de 5 minutos — só verificar o Boletim, tomar 1–2 decisões e fechar — é válida e produtiva. O jogador pode avançar 1 dia e parar.

## 📅 A unidade é o dia, não o minuto

**Sem velocidade variável** — Não há 1×/2×/½× — não há relógio correndo. O jogador toma as decisões do dia, confirma o avanço, e o jogo processa o resultado em 1–2 segundos de animação (pulável).

**Por que turn-based** — Tempo real cria obrigação. O jogador que não abriu o app em dois dias volta para uma crise que não escolheu enfrentar. Isso vai contra o tom de Porto Mirim — uma cidade que convida, não que pressiona.

**De onde vem a tensão** — Não do relógio do celular — mas das parcelas ao banco e dos prazos das missões críticas, medidos em dias de jogo. Essa pressão é controlada pelo design, não pelo sistema operacional.

## ✅ Decisões de design fechadas

**📰 Boletim de abertura** · 3 itens em ≤ 5 segundos

Ao abrir o app, o jogo exibe o Boletim do Porto: resumo do dia anterior em 3 itens — navio chegado, ação rival, prazo urgente. O jogador lê e vai direto ao mapa para tomar as decisões do dia atual.

**📅 Avanço por turno** · 1 sessão = 1 ou mais dias

Cada sessão é um conjunto de decisões diárias. O jogador confirma o avanço quando quiser; o jogo processa o dia e mostra o resultado. Não há relógio correndo — a unidade é o dia, não o minuto.

**⏱️ Duração de sessão** · 10–20 min típicos

Tempo médio de uma sessão saudável. O jogador pode jogar todo dia ou uma vez por semana — o jogo não pune nem recompensa frequência. Pular dias avança o calendário só quando o jogador escolhe avançar.

**🔔 Notificações push** · Só lembretes opcionais, sem urgência

Push é desativado por padrão. Quando ativado pelo jogador, serve apenas como lembrete suave ('Faz 4 dias que você não visita o porto') — nunca alerta de crise, pois nada acontece com o app fechado. Silêncio automático 23h–8h horário local.

**🔕 Sem progresso offline** · App fechado = jogo pausado

Porto não opera com o app fechado. Não há fila de navios queimando prazo, contrato vencendo ou rival agindo enquanto o jogador está fora. A campanha avança exclusivamente quando o jogador joga.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
