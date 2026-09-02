<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# ♿ Acessibilidade & Localização

Como o jogo funciona para quem tem necessidades específicas — daltonismo, baixa visão, leitor de tela — e como a localização preserva a alma brasileira em outras línguas.

## 👁️ Visão e cor

**Daltonismo — sinais nunca dependem só de cor** — Toda informação crítica codificada por cor é redundante por forma, ícone ou texto. Status verde/amarelo/vermelho (caixa, Rivalômetro, saúde de estrutura) sempre acompanhado de ícone distinto (✓ / ! / ✗). Modo daltônico opcional em Configurações ajusta paleta para deuteranopia, protanopia e tritanopia.

**Tamanho de fonte ajustável** — 3 níveis: Pequena (padrão), Média (+25%), Grande (+50%). Aplicado em todos os textos do jogo, exceto títulos decorativos. Tela de configurações tem preview em tempo real.

**Alto contraste opcional** — Modo de alto contraste reforça bordas de UI e aumenta a saturação de elementos interativos. Pensado para baixa visão (não cegueira total).

## 🦻 Leitor de tela e som

**Suporte a leitor de tela em menus** — Todos os botões de UI, lista de contratos, ficha de NPC, configurações e diálogos suportam VoiceOver (iOS) e TalkBack (Android) via AccessibilityNode do Godot 4. Ordem de leitura: topo → baixo, esquerda → direita. Não cobre o mapa animado (fora de escopo do MVP).

**Legendas em todo áudio narrativo** — Cutscenes, falas de NPCs e efeitos sonoros importantes (alerta de crise, chegada de navio) têm legenda opcional sempre que houver áudio. Ativadas por padrão em mercados com leitura forte de legenda.

**Música e SFX independentes** — Sliders separados para Música, Efeitos sonoros, Ambiente e Diálogos. Cada um de 0 a 100. Mute total possível em qualquer canal.

## 🌍 Localização — preservando a alma brasileira

**Estratégia: traduzir significado, preservar referente** — Personagens mantêm nomes em português (Toninho, Seu Biu, Dona Cida, Bela, Zezão, Kinha) em todas as línguas — esses nomes são parte da identidade do mundo. Apelidos têm tradução cuidada: 'chefia' vira 'boss' em inglês mas com nota de intimidade respeitosa, não corporativa. Eventos culturais (Festa de São Pedro, Carnaval, baião, choro) têm glossário in-game acessível pelo HUD em ❓.

**Hobby de idioma é separado da UI** — O jogador pode jogar em inglês mas o protagonista, dentro da ficção, fala português como nativo. O hobby de idioma estrangeiro cobre inglês ou espanhol como segunda língua do personagem — independe da língua da interface.

**Plataforma de tradução** — Todos os textos do jogo em arquivos de localização (não hardcoded). Plataforma sugerida: Weblate ou Crowdin para gestão de tradutores voluntários e profissionais. Tokens como {portName} preservados em todas as traduções.

**Idiomas MVP** — Lançamento: EN-US + PT-BR simultâneos. Roadmap pós-lançamento: ES-LA, FR, DE, JA, ZH-CN — nessa ordem, conforme demanda da comunidade.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
