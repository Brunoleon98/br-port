<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🎣 Mini-game de Pesca

> Pausa do porto — ritmo diferente, recompensa real

*Seu Biu pesca o mesmo lugar há quarenta anos. Não é burrice — é sabedoria que parece igual.*

**📍 Locais e desbloqueio** — Cinco pontos de pesca conforme progressão do mapa: Píer do Cais Mirim (disponível desde o início), Enseada da Foz do Tucunaré (fase 2), Recife das Pedras Brancas (fase 2 — Seu Biu guia pessoalmente), Mar Aberto (fase 3, requer embarcação própria ou alugada) e Lagoa da Capital Regional (fase 4, pesca em água doce, espécies diferentes). Cada local tem clima, profundidade, espécies e dificuldade próprios.

**🐟 Mecânica — três fases por pescaria** — Escolha de isca (afeta quais espécies aparecem e probabilidade de fisgada), Espera (animação de água com variação de clima — vento e maré afetam o tempo de espera e a força do peixe) e Resgatar (minigame de tensão: barra de força do peixe vs. tensão da linha — puxar demais quebra a linha; soltar demais perde o peixe). Peixe maior = mecânica mais intensa. Peixe de profundidade = janela de resgatar mais curta. Falhar gera comentário de Seu Biu — nunca repetido, sempre levemente diferente.

**🌦️ Clima como variável real** — O sistema de clima já definido no GDD afeta diretamente a pesca. Mar agitado (agosto): menos espécies mas maior probabilidade de peixe grande. Dias de chuva: pesca em rio melhora, marítima piora. Alta temporada turística (janeiro): os locais mais próximos ficam cheios — pescadores NPCs ocupam espaço e reduzem a paciência disponível para esperar. Seu Biu comenta o clima antes de cada sessão sem ser solicitado.

**🎁 Recompensas e integração com o loop principal** — Peixe pescado vai direto para o inventário do porto como carga fresca com prazo de 24h. Espécies raras desbloqueiam itens decorativos para o escritório ou diálogos únicos com NPCs. Pescar regularmente com Seu Biu constrói vínculo com ele — parte das informações que ele guarda (segredos do porto, movimentos noturnos suspeitos) só são reveladas depois de algumas sessões de pesca compartilhadas.

**⏸️ Como quebra o ritmo** — O mini-game está disponível a qualquer momento entre turnos, sem custo de tempo de jogo. É a única atividade que pausa o loop econômico sem consequências: sem parcelas vencendo, sem rivais agindo, sem notificações. Apenas água, linha e o silêncio de Seu Biu ao lado. Essa zona de calma é intencional. O jogador que só otimiza o porto nunca pesca. O jogador que pesca às vezes descobre coisas que o otimizador perdeu.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
