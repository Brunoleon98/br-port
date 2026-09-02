<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🎮 Sistema de Contratos & Tempo

Turnos diários — cada sessão avança o jogo em dias completos, no ritmo do jogador. Sem app aberto, nada acontece.

## ⏱️ Fluxo de tempo

**Avanço por turno** — Cada sessão avança o jogo em dias completos. O jogador toma as decisões do dia — contratos, funcionários, construção, conversas — e confirma o avanço. O jogo processa os resultados e apresenta o que aconteceu. Nada acontece com o app fechado.

**Duração de sessão** — Sessão típica de 10 a 20 minutos: ler o que aconteceu, decidir e fechar. O jogo não pune quem joga uma vez por semana.

**Sem velocidade variável** — Não há 1×/2×/½× — não há relógio correndo. A unidade é o dia. Animações de processamento entre turnos podem ser puladas ou aceleradas, mas isso não afeta a economia do jogo.

**Alertas no Boletim, não em push** — Tudo o que o jogador precisa saber chega no Boletim do Porto na abertura do próximo turno. Push notifications são opcionais e só servem para lembrar de jogar, nunca para criar urgência fora do jogo.

## 📋 Sistema de contratos

**Contratos fixos** — Sempre disponíveis na Bolsa do Porto. Prazo, carga e valor definidos. Aceitar ou recusar.

**Contratos negociados** — Clientes especiais propõem condições. Jogador pode contrapropor prazo ou bônus.

**Leilões ocasionais** — Contratos premium surgem toda semana. Rivais também fazem lances. Quem oferece melhor reputação + preço vence.

**Penalidade por quebra** — Contrato não cumprido = queda de reputação + multa. Reincidência afasta clientes.

## ⚙️ Decisões táticas

**Alocação de trabalhadores** — Distribuir equipes entre carga, reparo de barcos e construção.

**Prioridade de doca** — Qual navio entra primeiro quando há fila? O jogador decide.

**Aceitação de risco** — Contratos de alta reputação têm prazos agressivos. Risco x recompensa.

## 🕹️ Loop de sessão — os 10 minutos típicos

**Abertura (0–1 min): o boletim do dia** — O jogador abre o app e vê 3 itens: navio aguardando doca, ação rival pendente, prazo urgente. Nada mais. Decide se vai jogar 5 minutos ou 20.

**Decisão principal (1–4 min): alocar e contratar** — Verifica fila de barcos, aloca trabalhadores para as docagens mais vantajosas, aceita ou recusa o contrato em aberto desde ontem. Cada decisão leva 15–30 segundos. É aqui que mora 80% do engajamento da sessão.

**Gestão rápida (4–7 min): checar, reagir, planejar** — Abre a correspondência (1–2 cartas novas). Lê a matéria da Bela se saiu hoje. Vê se Arlindo fez algum movimento. Decide se vai ao Bar do Mané nessa noite — um tap, sem animação longa.

**Gancho de saída (7–10 min): o que fica pendente** — O jogo sempre deixa algo inacabado ao fechar: um contrato expira amanhã, uma carta que precisa de resposta, Toninho mencionou algo mas o jogador não teve tempo de checar o galpão. Esse gancho é o motivo do retorno no dia seguinte. Não é notificação push — é narrativa.

**Sessão longa (20–40 min): mesma estrutura, mais profundidade** — O jogador que tem mais tempo simplesmente vai mais longe: vai ao Bar do Mané, dedica um turno a hobby, lê todas as cartas, faz uma negociação de salário. O loop não muda de forma — escala em profundidade, não em obrigação.

## ✅ Decisões de design fechadas

**📋 Cap de contratos** · Dinâmico por fase

Fase 1: até 3 contratos simultâneos. Cresce até 8–10 na Fase 5. O limite desaparece junto com o crescimento do porto.

**👷 Especialização** · Com penalidade de eficiência

Cada trabalhador tem função principal. Pode exercer outra com 30–40% menos eficiência. Estratégico sem ser irreversível.

**💛 Trabalhadores** · Só moral — sem cansaço

Moral sobe com bônus e promessas cumpridas, cai com exploração. Moral baixa = menor rendimento. Pode culminar em demissão.

**💰 Fluxo de caixa** · Híbrido passivo + ativo

Renda passiva semanal (píer, armazém) cobre custos fixos. Contratos entregam o lucro real. O passivo é o chão; o ativo é o teto.

**🏦 Porto sem dinheiro** · 3 camadas narrativas

1. Sr. Ribeiro avisa — sem penalidade. 2. Vaga do píer penhorada. 3. Sr. Abutre faz oferta — aceitar é o único final ruim.

**⛈️ Clima** · Existe, aviso de 1 dia

Boletim avisa antes da tempestade. Efeitos: navios atrasam, guindaste para, prazos curtos em risco. Sem destruição de infra.

**🌙 Dia e noite** · Custo e oportunidade

Noite: hora extra, turismo e aduana fechados. Recompensa: navios especiais e missões narrativas exclusivos do período noturno.

**🔧 Upgrades** · Clicando no objeto no mapa

Clicar na estrutura abre o painel dela. Construções novas ficam no menu de construção geral. Cada objeto gerencia a si mesmo.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
