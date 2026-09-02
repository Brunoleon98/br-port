<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📋 Interface de Negociação

> Tela inteira em modo retrato sem scroll — requisito de design

*Contrato que exige scroll vai ser ignorado por jogadores mobile.*

**👤 Três elementos visíveis ao mesmo tempo** — O cliente com seu rosto e uma linha de diálogo contextual. Os termos propostos. Duas ou três variáveis ajustáveis pelo jogador.

**🎚️ Variáveis ajustáveis** — Sempre as mesmas: preço, prazo de entrega e uma condição especial que varia por contrato — prioridade de atendimento, seguro incluído, exclusividade de rota. O jogador desliza cada variável dentro de uma faixa possível.

**😐 Feedback visual, não numérico** — Conforme o jogador ajusta, o rosto do cliente reage: satisfeito, neutro, resistente. Não há número de 'felicidade' visível. A leitura é intuitiva — como ler uma pessoa numa conversa.

**⏳ Deixar em aberto** — O contrato pode ser aceito, recusado ou deixado em aberto por 24 horas de jogo. Deixar em aberto é uma estratégia: às vezes o cliente volta com condições melhores. Às vezes vai ao Porto Farol.

**🔄 Limiar de paciência do cliente — decisão fechada na Fase 1 do roadmap** — Em vez do rival simplesmente dumpar preço sem resposta, o jogador pode contra-negociar. Versão simplificada do VS: (1) Input da contra-oferta — 3 presets em botões (ex: 'Igualar rival −15%' / 'Cortar metade −7%' / 'Manter preço'), sem slider e sem input numérico — a granularidade fina é decisão de produção full. (2) Limiar de paciência — máximo 2 tentativas antes de o cliente encerrar a conversa e ir ao Porto Farol, visualizado por uma mood face do cliente com 3 estados discretos: 2 tentativas restantes = neutro, 1 restante = preocupado, 0 = saindo. O VS testa se essa dinâmica é divertida; o detalhamento completo (mais presets, animações, condições de oferta especial) entra na produção full.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
