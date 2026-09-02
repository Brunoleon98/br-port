<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 📔 Diário do Porto

> Centro emocional — onde o porto ganha memória

*Não é tela de stats. É como o jogador vai lembrar deste jogo daqui a um ano.*

**📖 Estrutura do diário** — Organizado em três camadas: linha do tempo (entradas automáticas e manuais em ordem cronológica), capítulos (uma página por ato narrativo concluído) e arquivo (busca por NPC, por carga, por evento). A interface lembra um caderno de capa de couro envelhecido — não um app. Folheável página por página. Funciona offline integralmente — é o único sistema do jogo que pode ser revisitado sem progredir a campanha.

**✍️ Entradas automáticas** — Geradas em marcos: primeiro contrato fechado, primeiro funcionário contratado, primeira parcela paga, conclusão de fase, eventos sazonais, conclusão de hobby, viagem a evento do setor, visita importante em casa, descoberta de segredo. Cada entrada tem data in-game, ícone temático, uma a três linhas de texto na voz do protagonista, e quando aplicável uma polaroid anexa.

**📝 Página de reflexão — texto livre opcional** — Em momentos específicos (final de mês, conclusão de capítulo, evento marcante), o jogo abre uma página em branco e oferece ao jogador escrever uma reflexão livre. Sem limite mínimo. Pular não tem consequência. Quem escreve constrói um diário pessoal único que o próprio jogador relê meses depois. NPCs nunca leem o que o jogador escreveu — é privado mesmo dentro do jogo.

**💬 Frase da semana — citações de NPCs** — Toda semana, uma fala real dita por algum NPC durante aquele período é destacada como 'frase da semana' no diário — selecionada pelo jogo conforme o impacto narrativo. Dona Cida em semana ruim, Toninho num momento de afeto, Zezão num raro instante reflexivo. Cria álbum de citações ao longo da campanha. Um dos prazeres do final do jogo é folhear isso de trás pra frente.

**🎞️ Cápsulas do tempo de cada fase** — Ao completar cada fase, o Diário fecha um capítulo com cápsula: foto do porto no momento, lista dos NPCs ativos, estado financeiro resumido em duas linhas, contrato mais memorável, e a citação mais impactante. Comparar a cápsula da Fase 1 com a Fase 4 é um dos momentos mais emocionantes do final do jogo.

**🔍 Por que é o centro emocional** — Em jogos de gestão, o jogador termina a campanha com nada além de números finais. Aqui termina com um livro — literalmente folheável — contando a história do porto dele, com a voz dele, as escolhas dele e as pessoas que ficaram. Isso é o que mantém o jogo lembrado depois de meses. Não é feature lateral — é o produto final invisível.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
