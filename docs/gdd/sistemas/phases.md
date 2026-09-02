<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🏗️ Progressão & Desbloqueio

Cada fase exige metas de reputação + infraestrutura construída — mais uma missão narrativa de conclusão.

## 📈 Como subir de fase

**Reputação mínima** — Cada fase exige um patamar de reputação atingido e mantido por 3 dias consecutivos.

**Infraestrutura obrigatória** — Certas construções precisam estar erguidas antes de avançar.

**Missão narrativa** — Uma cutscene + evento especial marca a virada de fase — ex: primeiro navio grande aportando.

## 🗺️ As 5 fases

| Fase | Nome | Destrava | Reputação | Infra | Cidade | Visual |
|---|---|---|---|---|---|---|
| 01 | Trabalhador do Cais | Contratos de pesca e pequenas cargas | 0 – 200 | Cais básico + 1 galpão | Porto Mirim tem 1 rua principal e mercado de peixe | Cais de madeira, barcos pequenos, 1 grua enferrujada |
| 02 | Cais com Oficina | Reparo de barcos, clientes regionais | 200 – 600 | Oficina naval + 2 docas | Surgem novos estabelecimentos, calçadão na orla | Oficina, espaço para 2 navios, guindastes novos |
| 03 | Porto Regional | Rotas fixas, leilões regionais, rivais mais agressivos | 600 – 1.400 | Armazém + torre de controle | Porto Mirim vira atração, turistas aparecem | Píer ampliado, armazéns coloridos, placa oficial |
| 04 | Porto Nacional | Contratos nacionais, autoridade portuária, crise com Atlântico S.A. | 1.400 – 3.000 | Terminal de contêineres + aduana | Grua gigante vista de longe, novos bairros na cidade | Contêineres empilhados, navios cargueiros, heliponto |
| 05 | Grande Porto + Estaleiro | Construção e reparo naval, rotas internacionais, final narrativo | 3.000+ | Estaleiro completo + doca seca | Porto Mirim virou cidade portuária — aeroporto, hotelaria | Estaleiro imponente, navios em construção, farol renovado |

## ✅ Decisões de design fechadas

**📉 Regressão de fase** · Parcial com trava

Fase conquistada é permanente. Mas se a reputação cair abaixo do mínimo, contratos e clientes somem até ela se recuperar.

**📊 Condições de avanço** · Simultâneas + painel claro

As 3 barras correm em paralelo. Reputação, infraestrutura e missão narrativa avançam de forma independente. O avanço só ocorre quando as três estão ativas.

**⏳ Limite de tempo** · Pressão narrativa, sem timer

Não há prazo rígido. Quanto mais tempo o jogador demora, mais o Sr. Abutre intensifica a pressão — urgência orgânica.

**🏚️ Demolição** · Custo parcial (50%)

Pode demolir qualquer construção, recuperando 50% dos recursos. Construções herdadas do avô custam mais — o jogo reconhece o valor sentimental.

**🏗️ Upgrades vs. novas** · Ambos, com lógica clara

Estruturas principais evoluem in-place até 3 níveis. Estruturas de expansão exigem espaço novo. Cada categoria tem sua regra.

**🏙️ Porto Mirim** · Mecânica leve e passiva

Cidade maior = mais trabalhadores no mercado. Alta temporada = renda passiva automática. Sem gestão ativa da cidade.

**📅 Eventos sazonais** · Calendário fixo com aviso

2–3 eventos por fase (Festa de São Pedro, alta temporada jan., vento sul ago.). Boletim avisa com antecedência.

**📖 Diário do Porto** · Cápsula do tempo por fase

Cada missão de virada de fase vai para o Diário com artefatos: fotos do porto, cartas de NPCs, manchetes do jornal local.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
