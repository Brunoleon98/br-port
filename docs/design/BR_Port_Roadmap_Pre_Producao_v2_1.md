# BR Port — Roadmap (Objetivo: Fazer o Jogo)
**Versão 2.1 · Vendas são bônus — o critério de avanço é "ainda quero jogar isso?"**

> **Mudanças do v2.0 → v2.1** (concluídas na Fase 1 do roadmap, junto com o GDD 6.5):
> - Duração alvo do VS jogado: **5–10 min → 15–25 min** — ajustado para a duração natural da Fase 1 do JOGO (Ato 1 — Início).
> - Os 3 ajustes do V3 saíram de "opções a decidir" para **decisões fechadas** — ver Fase 2 abaixo.
> - Escopo do VS detalhado no GDD 6.5 (telas, sistemas, assets, OUT, marco de revisão, critério de conclusão).

---

## Fase 1 — Revisão crítica do GDD 6 → 6.5 ✅ CONCLUÍDA

**Entrega:** GDD 6.5 aprovado e congelado para o VS — ✅ entregue junto deste Roadmap v2.1.

- Revisão única: melhorias + problemas na mesma passagem
- Foco em decisões de design que o VS vai precisar implementar — deixar narrativa e polish para depois
- Fechar qualquer decisão de mecânica ainda em aberto
- Definir o escopo do VS aqui e não mudar depois que a produção começar

**Critério para avançar:** GDD relido, decisões fechadas, escopo do VS escrito — ✅ atingido.

**Decisões fechadas nesta fase** (registradas no GDD 6.5):
1. Dificuldade semanas 3–4 → **parcela final mais pesada** (sem rival agressivo nem evento extra no VS)
2. Feedback visual de reputação → **cor pulsante + ícone de NPC adjacente (Dona Cida)**
3a. Input da contra-oferta → **3 presets em botões** (sem slider)
3b. Limiar de paciência → **mood face do cliente** (3 estados discretos: 2/1/0 tentativas restantes)
4. Escopo de "uma fase completa" → **Fase 1 do JOGO (Ato 1 — Início), 15–25 min jogados**
5. NPC do VS → **Dona Cida**
6. Rival do VS → **Arlindo visível desde o começo, sem Rivalômetro**
7. UI do VS → 12 telas production-quality (inclui Sr. Ribeiro com sprite/diálogo curto + Diário do Porto mínimo)
8. Áudio → **SFX core + ambiente loop + 1 música Suno** (timebox 1 dia, fallback sem música)
9. Marco de revisão intermediário → **loop core jogável end-to-end com arte placeholder**

---

## Fase 2 — Planejamento do Vertical Slice (próxima)

**Entrega:** plano de produção do VS com lista de assets, estimativa de tempo por item e cronograma

- Escopo já fechado na Fase 1 (ver GDD 6.5 — seção Protótipo / "VS — Telas IN", "Sistemas IN", "Assets a produzir")
- **Duração alvo do VS jogado: 15–25 minutos** (atualizado do alvo original de 5–10 min para refletir Fase 1 do jogo completa)
- Estimativa de tempo por asset com base na lista do GDD 6.5
- Marco de revisão intermediária: loop core jogável end-to-end com arte placeholder
- Os 3 ajustes do Playtest V3 já têm decisão fechada no GDD 6.5 — replicar abaixo só pra referência operacional:
  - Dificuldade semanas 3–4 → parcela final mais pesada
  - Reputação → cor pulsante + ícone NPC (Dona Cida)
  - Negociação → 3 presets em botões + mood face do cliente

**Critério para avançar:** plano escrito, escopo não vai aumentar depois

---

## Fase 3 — GDD 6.5 → 7

**Entrega:** GDD 7 pronto para guiar a produção do VS

- Incorporar decisões do planejamento
- Congelar — nada entra durante a produção

**Critério para avançar:** GDD atualizado e congelado

---

## Fase 4 — Produção do Vertical Slice

**Entrega:** VS jogável publicado no itch.io (Android + WebGL)

- Arte final, não placeholder
- Build publicada ao concluir — ter uma URL real fecha a fase

**Critério para avançar:** você jogou do início ao fim sem quebrar

---

## Fase 5 — Testes e correções

**Entrega:** lista de bugs corrigidos + lista de ajustes de design priorizados

Dois tipos de problema — tratar separado:

| Tipo | O que é | Prioridade |
|---|---|---|
| Bug (QA) | Algo quebrado que impede jogar | Corrigir antes de avançar |
| Feedback de design | Algo que funciona mas não é divertido | Avaliar se entra no GDD 8 |

- Você + 2–3 pessoas jogando e observando (sem explicar o jogo)
- Gravar a tela — comportamento importa mais que opinião
- Bugs bloqueantes: corrigir agora. O resto: listar para a próxima fase

**Critério para avançar:** nenhum bug que impeça completar o VS

---

## Fase 6 — GDD 7 → 8 + Decisão de produção full

**Entrega:** decisão documentada + GDD 8 se avançar

A pergunta não é "vai vender?". É: **você ainda quer jogar esse jogo depois de ter feito o VS?**

- Sim, com energia → produção full
- Sim, mas cansado → reduzir escopo da produção antes de começar
- Não → pausar e entender por quê antes de investir mais tempo

Se avançar, definir aqui:
- Escopo final do jogo (quantas fases, quantos NPCs, etc.)
- Ritmo de trabalho sustentável (horas por semana)
- Data alvo de conclusão — sem data, o projeto não termina

---

## Fase 7 — Produção completa

**Entregas progressivas:** uma fase por vez, cada uma publicada no itch.io como atualização

- Produzir fase por fase — não tentar fazer tudo de uma vez
- Cada fase entregue é um marco real, não só progresso interno
- QA contínuo a cada fase entregue, não só no final

---

## Sobre vender (se chegar lá)

Se o jogo estiver bom o suficiente para você querer compartilhar:

- Steam page + itch.io com preço → custo zero de marketing inicial
- Postar devlogs onde já estiver (Reddit, TikTok, Twitter) — construir audiência organicamente
- Soft launch Brasil antes de global

Não precisa decidir isso agora. Essa conversa acontece depois da Fase 6.

---

## Glossário rápido

| Termo | Definição |
|---|---|
| Vertical Slice | Fatia polida do jogo — prova que você consegue produzir no padrão final |
| QA | Quality Assurance — caça a bugs antes de avançar de fase |
| D1 / D7 | Retenção de jogadores no dia 1 e dia 7 (relevante só se publicar para o público) |
| Congelar o GDD | Parar de adicionar — o que não está no GDD não entra na produção dessa fase |

---

*BR Port · Roadmap v2.1 · Objetivo: fazer o jogo. Vendas são bônus.*
