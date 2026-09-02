<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# ⭐ Sistema de Reputação

> Três eixos independentes — uma leitura integrada

*Reputação não é uma barra. É o que a cidade fala de você quando você não está na sala.*

**📊 Escala e exibição ao jogador** — Cada eixo vai de 0 a 100. Exibido como descrição qualitativa, não número: 0–20 = 'Desconhecido', 21–40 = 'Questionável', 41–60 = 'Confiável', 61–80 = 'Respeitado', 81–100 = 'Referência'. O número interno existe para cálculos — o jogador lê palavras, não pontos. A mudança de faixa é anunciada por uma linha de Dona Cida ou Seu Biu.

**⚡ Feedback visual imediato — decisão fechada na Fase 1 do roadmap** — A barra de reputação em texto puro não foi intuitiva o suficiente para jogadores novos no V3. Decisão fechada para o VS: combinação de dois sinais. (1) Cor pulsante no indicador — animação curta ao mudar de faixa, sinal de baixa latência de que algo aconteceu. (2) Ícone de reação do NPC adjacente — micro-sprite expressivo (Dona Cida no VS) que ancora a mudança em quem reagiu, carregando a identidade narrativa do jogo. A linha de texto contextual fica deferida para a produção full, após o sistema base provar que comunica a intuição. O número interno não muda — só a camada de comunicação visual para o jogador.

**⚓ Eixo 1 — Reputação Comercial** — Afeta quais contratos chegam e a que preço. Acima de 60: clientes de frete regional aparecem. Acima de 80: contratos exclusivos de longa duração disponíveis. Abaixo de 30: só contratos de baixo valor chegam, Arlindo intercepta os bons. Aumenta com: contratos cumpridos no prazo, estrutura bem mantida, zero reclamações. Diminui com: atrasos, reclamações públicas, carga avariada, boatos amplificados por Arlindo.

**🏘️ Eixo 2 — Reputação Comunitária** — Afeta alianças, festividades e finais disponíveis. Acima de 70: vaquinha da crise possível, câmara municipal ouve o jogador no Ato 3. Acima de 85: pescadores defendem o porto ativamente. Abaixo de 40: Final E disponível, Final B bloqueado. Aumenta com: aluguel justo, presença na Festa de São Pedro, defesa do mangue. Diminui com: despejo de pescador, corrupção descoberta.

**📰 Eixo 3 — Reputação com a Imprensa (Bela)** — Afeta cobertura semanal e acesso antecipado a informação. Acima de 65: Bela avisa antes de publicar algo delicado. Acima de 80: compartilha pistas das investigações independentes. Abaixo de 40: ela investiga o porto do protagonista. Abaixo de 20: matéria negativa garantida toda semana. Mentira descoberta reseta 30 pontos de uma vez.

**⚡ Interação entre os eixos** — Reputação com Bela alta + matéria positiva = +5 na comercial por duas semanas. Reputação comunitária abaixo de 35 = Arlindo recruta funcionários com mais facilidade. Reputação comercial abaixo de 25 = Sr. Ribeiro recusa renegociar a dívida.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
