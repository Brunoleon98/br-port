<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📊 Variação Dinâmica de Preços

> O mercado de Porto Mirim é pessoal, não abstrato

*Os preços mudam por causa de pessoas e eventos, não de algoritmos invisíveis.*

**🐟 Oferta e demanda local** — Se muitos barcos chegam juntos trazendo peixe, o preço cai naquela semana. Se houve tempestade e a frota não saiu, o preço sobe. O jogador vê isso como uma tag simples ao lado da carga: 'mercado saturado' ou 'produto escasso'. Sem gráficos complexos.

**📅 Sazonalidade como base de preços** — A variação de preço não é um sistema separado — é consequência da sazonalidade já definida. Em janeiro, equipamentos turísticos valem mais. Em maio, qualquer carga rende menos. Quem leu a sazonalidade já entende a lógica dos preços sem tutorial adicional.

**📰 Eventos que distorcem o mercado** — Uma greve no porto de outra cidade faz contratos de frete regional chegarem em dobro com urgência. Um escândalo de produto adulterado derruba determinada carga por duas semanas. Esses eventos são anunciados pela Bela no jornal local antes de acontecerem — quem lê as matérias dela leva vantagem competitiva.

**🚫 O que não entra no sistema** — Sem inflação contínua, moeda que deprecia ou gráficos de mercado complexos. Porto Mirim é uma cidade pequena — a economia dela é reativa e humana, não financeira.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
