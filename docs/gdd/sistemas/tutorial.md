<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🎓 Tutorial & Onboarding

Toninho recebe o jogador nos primeiros 15 minutos. 4 momentos curtos, sem painel separado. Sr. Ribeiro entra depois, com a Parcela 1.

## 🎓 Filosofia de onboarding

**Integrado à narrativa, não separado** — O tutorial é a chegada do herdeiro ao porto. Toninho — o estivador-chefe que estava no cais antes do protagonista nascer — apresenta o lugar como se estivesse mostrando para o neto do amigo. Cada instrução é fala dele, contextualizada no mundo do jogo.

**Nenhuma tela de tutorial separada** — Não existe 'tutorial mode'. O jogador aprende fazendo, no porto, nos primeiros 15 minutos. Nenhum painel sobreposto, nenhuma seta pulsante em cada botão.

**Camadas avançadas chegam depois** — Rivais aparecem progressivamente nas semanas 3–6. Moral, jornada noturna, leilões, espionagem e hobbies são introduzidos quando se tornam relevantes — sempre dentro de um evento narrativo.

## 📅 Os 4 momentos do onboarding (minutos 0–15)

**Minutos 0–3 — A chegada (Toninho)** — O jogador chega ao cais. Toninho espera na entrada e explica em duas linhas: 'Seu Maneco deixou tudo pra você. Inclusive as dívidas.' Primeira ação: clicar no galpão velho. Sem tutorial explica o clique — o galpão pisca. Quem não clica em 10s recebe um empurrão gentil de Toninho.

**Minutos 3–7 — A primeira decisão (Zezão)** — Zezão aparece sem ser chamado. Inspeciona o galpão. Diz que precisa de limpeza: R$ 400 e dois dias. O jogador tem R$ 600. Aceitar ou esperar é a primeira decisão com custo real. Dona Cida comenta a consequência financeira de qualquer escolha.

**Minutos 7–11 — Os pescadores (Seu Biu)** — Seu Biu aparece com dois pescadores para 'renovar o trato com o novo dono.' O avô nunca cobrou. O jogador escolhe entre 3 valores de aluguel (R$ 0, R$ 40, R$ 80 por vaga). Cada opção tem reação visível de Seu Biu. Sem explicar que afeta a reputação comunitária.

**Minutos 11–15 — O primeiro barco e a dívida** — Um barco de passagem aparece. Esse é a primeira mecânica com pressão — mas baixa: traz só R$ 150. Ao final, Dona Cida apresenta a dívida (3 parcelas em 12 semanas) e o mapa do porto abre pela primeira vez. O jogo começa.

## 🏦 Sr. Ribeiro como tutor financeiro (entra na semana 4)

**Sr. Ribeiro não está no onboarding inicial** — Ele é mencionado por Dona Cida na apresentação da dívida, mas só aparece em pessoa na semana 4, quando vence a Parcela 1. Aí introduz os sistemas financeiros (empréstimos, investimentos) progressivamente, como tutor secundário.

**Banco como sistema é desbloqueado com a Parcela 1** — Antes da semana 4, o jogador só interage com a dívida via Dona Cida. Empréstimos voluntários, linhas de crédito e investimentos só ficam disponíveis depois da primeira parcela paga (ou perdida) — quando o jogador já entendeu a dor.

## ▶️ Coach mark de 'Próximo dia' — 1 vez

**Aparece no fim do tutorial (min 15)** — Depois da apresentação da dívida, Dona Cida diz: 'Chefia, quando o senhor terminar de decidir, é só avançar o dia.' O botão 'Próximo dia' fica destacado com seta pulsante.

**Não se repete** — O jogador toca, o dia avança, o coach mark some. Quem descobriu antes (tocou no botão por curiosidade) não vê o coach mark — o sistema checa se o botão já foi usado.

## ✅ Decisões de design fechadas

**👴 Guia: Toninho** · Tutorial integrado, 15 minutos

O estivador-chefe veterano — leal ao avô há 20 anos — recebe o herdeiro e apresenta o porto em 4 momentos curtos (≈3–4 min cada). Cada instrução é fala dele, no contexto. Sem painel de tutorial separado.

**📅 4 momentos do onboarding** · Minutos 0–15, sem painel

Min 0–3: chegada e galpão (Toninho recebe). Min 3–7: primeira decisão de custo com Zezão (limpeza do galpão). Min 7–11: aluguel de píer aos pescadores liderados por Seu Biu (três valores possíveis). Min 11–15: primeiro barco + apresentação da dívida por Dona Cida + mapa abre pela primeira vez.

**🏦 Sr. Ribeiro entra depois** · Semana 4 com a Parcela 1

O banqueiro só aparece como NPC ativo na semana 4, quando vence a primeira parcela. Antes disso, é apenas mencionado em diálogo. Toninho cobre o onboarding inicial; Sr. Ribeiro cobre o sistema financeiro a partir do Ato 1.

**▶️ Coach mark de 'Próximo dia'** · Aparece 1 vez, no fim do tutorial

No fim do minuto 15, Dona Cida diz: 'Chefia, é só avançar o dia.' Botão 'Próximo dia' destacado com seta pulsante. O jogador toca, o dia avança, o tutorial some. Não se repete. Quem descobriu antes não vê o coach mark.

**📚 Camadas avançadas sem painel** · Cada sistema dentro de evento

Moral, jornada noturna, leilões competitivos, espionagem via Bela, hobbies, Diário, fotografias, eventos do setor — todos introduzidos progressivamente em semanas posteriores, sempre dentro de um evento narrativo que os torna relevantes. Sem 'unlock por nível'.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
