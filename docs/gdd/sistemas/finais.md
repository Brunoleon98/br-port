<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🏁 Condições de Final & Desfechos

Cinco finais com condições qualitativas — três positivos, um negativo, um secreto. O que o jogador construiu ao longo da campanha determina o que está disponível.

## 🏁 Os cinco finais

**Final A — Porto Unificado** — Condições: aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Arlindo, sabendo que o Abutre o absorveria depois, une o Porto Farol ao Cais Mirim numa operação conjunta sob o nome do avô. O Grupo Atlântico recua. Epílogo: cena de Seu Biu na ponta do cais ao amanhecer. Ele não diz nada. Não precisa.

**Final B — Porto da Cidade** — Condições: mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Cais Mirim permanece independente. A câmara municipal vota contra o resort. Toninho conta o segredo do avô numa cena noturna no galpão. Epílogo: o jogador vê a cidade cinco anos depois — os pescadores do píer ainda estão lá. Variação se Memorial completo: cena adicional em frente ao Memorial.

**Final C — Sobrevivência Pura** — Condições: terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. O cais sobrevive. O protagonista honrou a dívida. Mas Porto Mirim ficou igual. Epílogo: sem cena especial. O jogo mostra o cais em dia normal de operação. Toninho varrendo o píer. Isso é tudo.

**Final D — Venda ao Grupo Atlântico** — Condições: aceitar a proposta do Abutre no Ato 3 (disponível quando dívida alta + sem aliança comunitária). O Cais Mirim vira terminal do Grupo Atlântico. Pescadores perdem as vagas. Toninho não aparece na cena final. Bela publica — o jogador lê a manchete como epílogo. Dona Cida deixa o porto no dia seguinte. Variação por desespero (cascade de falência → aceitar resgate do Abutre): mesma estrutura, cena mais curta e mais pesada, o avô não aparece, só o cais vazio.

**Final E — O Custo do Conhecimento (secreto)** — Condições obrigatórias (todas): seguir o fio da carga sem nota até o fim + revelar o contato interno do Grupo Atlântico para o Abutre em pessoa + reputação comunitária abaixo de 40. O Abutre usa a informação para purgar o contato interno e faz oferta melhorada. O jogador ganhou poder de negociação mas perdeu a cidade. Sem música na cena final.

## 🕯️ Conexão com o Memorial do Avô

**Memorial completo desbloqueia variação do Final B** — Não é um final separado. O jogador que descobriu todas as peças do Memorial e construiu a estrutura tem uma cena adicional no Final B: conversa com Toninho em frente ao memorial, ele entrega um único objeto guardado por 20 anos, o ciclo se fecha. Camada emocional adicional, não condição de novo final.

**Memorial não é pré-requisito de outros finais** — Memorial completo enriquece o Final B. Não afeta os Finais A, C, D ou E — eles permanecem acessíveis nas suas próprias condições, com ou sem Memorial.

## 📡 Como o jogo sinaliza os finais sem spoilar

**O Diário do Porto como mapa de caminhos** — Fragmentos acumulados no Diário sugerem que há mais de um desfecho possível — sem descrevê-los. Quem leu tudo percebe. Quem não leu chega na câmara com o que construiu.

**NPCs deixam pistas qualitativas, nunca números** — Toninho menciona o avô em referências que apontam Final B. Bela pergunta sobre o Porto Farol quando Arlindo está como aliado (sugere Final A). Sr. Ribeiro fala em 'unificação' quando o jogador se aproxima do Final A. Nenhum NPC fala em pontos de reputação. O Final E nunca é insinuado por NPC algum.

**O jogo NUNCA revela quantos finais existem** — Sem painel de progresso de finais. Sem 'desbloqueado 2/5'. O jogador descobre o número total apenas relendo o Diário após a primeira campanha ou conversando com outros jogadores.

## ⚠️ Cascade de falência — como o jogo avisa que está indo mal

**Nível 1 — Sinal precoce (semanas antes do prazo)** — Dona Cida comenta no início do dia: 'A margem tá ficando apertada, chefia.' Sr. Ribeiro envia carta 2 semanas antes da parcela. O HUD não muda ainda. Quem lê os diálogos sabe.

**Nível 2 — Pressão visível (1 semana antes)** — O contador de caixa no HUD muda de cor: verde → amarelo. Uma linha discreta aparece embaixo: 'Parcela em X dias'. Arlindo intensifica ações — o jogo acumula pressão de fora e de dentro ao mesmo tempo.

**Nível 3 — Crise ativa (menos de 3 dias, caixa insuficiente)** — HUD vira laranja. Sr. Ribeiro visita pessoalmente pela primeira vez. Dona Cida apresenta lista de cortes possíveis — o jogador pode demitir, cancelar construção, aceitar condições piores em contratos. A música diminui (ver Conceitos).

**Nível 4 — Oferta de resgate (caixa negativo)** — O Abutre aparece com oferta de compra apresentada como 'parceria'. Aceitar neste momento ativa a variação pesada do Final D — diferente de escolher o Final D voluntariamente no Ato 3. A cutscene é mais curta e mais pesada.

**Não existe game over imediato** — O jogo nunca trava numa tela de 'você perdeu'. A falência é uma narrativa que o jogador entra de olhos abertos — sempre há um caminho ainda em aberto, mesmo que seja vender. O último recurso disponível antes da venda forçada é sempre visível.

**Sem reinício forçado** — Se o jogador aceitar a venda no nível 4, o Diário fica acessível. É um final, não um game over. Quem quiser jogar de novo cria um novo save — não é forçado.

## ✅ Decisões de design fechadas

**🤝 Final A — Porto Unificado** · Aliança Arlindo + rep comunitária >70

Arlindo, sabendo que o Abutre o absorveria depois, une o Porto Farol ao Cais Mirim numa operação conjunta sob o nome do avô. Grupo Atlântico recua. Condições: aliança com Arlindo ativa no Ato 3 + reputação comunitária acima de 70 + terceira parcela paga. Epílogo: Seu Biu na ponta do cais ao amanhecer.

**🌿 Final B — Porto da Cidade** · Mangue defendido + vínculos altos

Cais Mirim permanece independente. Câmara municipal vota contra o resort. Toninho conta o segredo do avô. Condições: mangue defendido + vínculo alto com pescadores e Bela + terceira parcela paga sem aceitar proposta do Abutre. Variação especial se Memorial completo: cena final em frente ao Memorial com objeto guardado por 20 anos. Epílogo: cidade cinco anos depois, pescadores ainda no píer.

**💼 Final C — Sobrevivência Pura** · Parcela paga, sem alianças, sem segredos

O cais sobrevive. O protagonista honrou a dívida. Mas Porto Mirim ficou igual. Condições: terceira parcela paga, sem alianças fortes, sem resolução dos segredos, sem arco do mangue. Epílogo: sem cena especial. Cais em dia normal. Toninho varrendo o píer.

**⚠️ Final D — Venda ao Atlântico** · Aceitar proposta do Abutre

O Cais Mirim vira terminal do Grupo Atlântico. Pescadores perdem as vagas. Toninho não aparece na cena final. Bela publica — manchete como epílogo. Dona Cida deixa o porto no dia seguinte. Disponível como decisão consciente no Ato 3 OU como resgate de desespero quando dívida alta + sem aliança comunitária (versão pesada, mais curta).

**🔒 Final E — Custo do Conhecimento** · Secreto · Carga sem nota + rep < 40

Condições obrigatórias: seguir o fio da carga sem nota até o fim + revelar o contato interno do Grupo Atlântico para o Abutre em pessoa + reputação comunitária abaixo de 40. O Abutre usa a informação para purgar o contato e faz oferta melhorada. O jogador ganhou poder de negociação mas perdeu a cidade. Sem música na cena final. NPC algum insinua a existência deste final.

**💬 Sinalização sem spoiler** · Pistas qualitativas, nenhuma explícita

Pistas no Diário (fragmento da carta do avô para Final A), Bela (pergunta sobre Porto Farol quando Arlindo aliado), Sr. Ribeiro (menciona unificação ao se aproximar do Final A), Toninho (referências ao avô que apontam Final B). O Final E nunca é insinuado por NPC. O jogo NUNCA revela quantos finais existem — o jogador descobre jogando.

**📔 Diário pós-final** · Sem NG+, memória completa

Após qualquer final, o Diário do Porto fica acessível com todos os fragmentos desbloqueados. O jogador pode reler a campanha inteira. Replayability via 5 finais distintos.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
