<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🕐 Unidade de Tempo — Turnos Diários

> Sem idle. Sem obrigação de abrir todo dia.

*O jogador abre o jogo quando quer. Porto Mirim não pune quem tirou uma semana de folga.*

**📅 Como funciona** — Cada sessão avança o jogo em dias completos. O jogador toma as decisões do dia — contratos, funcionários, construção, conversas — e confirma o avanço. O jogo processa os resultados e apresenta o que aconteceu. Nada acontece com o app fechado.

**⏱️ Duração de sessão** — Entre 10 e 20 minutos por sessão típica. O jogador vê o que aconteceu no dia anterior, toma as decisões do dia atual e fecha. Pode jogar todo dia ou uma vez por semana — o jogo não pune a segunda opção.

**💡 Por que não tempo real** — Tempo real cria obrigação. O jogador que não abriu o app em dois dias volta para uma crise que não escolheu enfrentar. Isso vai contra o tom de Porto Mirim — uma cidade que convida, não que pressiona.

**⚡ De onde vem a tensão** — Não do relógio do celular — mas das parcelas ao banco e dos prazos das missões críticas. Essa pressão é controlada pelo design, não pelo sistema operacional.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
