<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 💼 Negociação de Salário

> Cada trabalhador tem um preço — e uma opinião sobre o que vale

*Kinha sabe quanto ela vale. A questão é quando o jogador vai saber também.*

**💬 Como funciona a negociação** — A cada 4 semanas de jogo, cada funcionário pode solicitar revisão salarial — aparece como diálogo opcional, não como demanda agressiva. O jogador pode aumentar (qualquer valor), manter ou reduzir. Manter quando o salário já está abaixo do mercado: lealdade cai 5 pontos. Reduzir: cena de reação proporcional ao personagem — Marina faz uma pergunta calmamente; Kinha não faz pergunta nenhuma e o jogo registra o silêncio.

**📊 Referência de mercado** — Dona Cida mantém uma tabela de mercado regional consultável sob demanda — nunca exibida automaticamente. Cada função tem uma faixa por fase (ex: operador de guindaste: R$ 160–220/semana na Fase 2). Pagar abaixo: risco de proposta de Arlindo. Pagar acima: lealdade sobe, moral sobe, e o funcionário para de atender os telefonemas do rival.

**⚡ Efeito no sistema de moral e lealdade** — Salário é o fator de maior impacto estável sobre lealdade — supera elogios pontuais e eventos especiais. Um funcionário com salário justo absorve uma decisão ruim do jogador sem queda de lealdade. Um mal pago abandona o porto no momento mais inconveniente — durante um contrato de alto valor, geralmente. O jogo não avisa quando o abandono está próximo.

**🎯 Negociações que definem personagens** — Kinha — quando o jogador finalmente paga o que ela vale, ela não agradece: 'Era o que deveria ser.' Se o jogador pagar mais do que ela pediu: ela olha os documentos e pergunta 'Tem um erro aqui?' Carol — se lealdade abaixo de 35 e revisão ignorada por 2 semanas, ela pede demissão levando o conhecimento dos contratos. Toninho — nunca pede aumento. Se o jogador oferecer espontaneamente, ele fica quieto um momento: 'Seu Maneco pagava assim também. No final.'


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
