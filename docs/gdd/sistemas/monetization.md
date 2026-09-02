<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 💰 Modelo de Negócio

Compra única — sem energia, sem anúncios forçados, sem pay-to-win. O jogador paga uma vez e tem tudo.

## 🏷️ Estrutura de preço

**Preço base sugerido** — R$ 19,90 / US$ 3,99 — competitivo para mobile premium.

**Demo gratuita** — Fase 1 completa grátis. Para avançar para a Fase 2, compra o jogo completo.

**Sem assinatura** — Pagamento único, acesso vitalício a todo o conteúdo lançado junto ao jogo.

## 📦 Expansões opcionais (DLC)

**DLC de história** — Arcos extras de NPCs — ex: passado misterioso do Capitão Arlindo.

**DLC de cenário** — Nova cidade costeira com mecânicas únicas — ex: porto no Pantanal fluvial.

**Pack cosmético** — Skins de pixel art para construções e barcos. 100% opcional, sem impacto no jogo.

**Edição de colecionador** — Trilha sonora + artbook digital + itens cosméticos exclusivos por preço único.

## ✅ Princípios anti-frustração

**Sem energia limitada** — Jogador nunca é bloqueado de jogar por falta de energia ou cooldown.

**Sem anúncios** — Zero anúncios — nem opcionais. A experiência é limpa do início ao fim.

**Sem pay-to-win** — Nenhum item vendável acelera o jogo ou dá vantagem sobre rivais.

**Saves na nuvem** — Progresso sincronizado entre dispositivos incluído sem custo adicional.

## ✅ Decisões de design fechadas

**🎮 Conteúdo da demo** · Fase 1 completa + rivais

Demo inclui toda a Fase 1: contratos, NPCs, construção e a primeira aparição do Arlindo com evento rival simplificado. Avanço à Fase 2 exige compra.

**🔓 Fluxo de unlock** · IAP iOS · loja própria Android

iOS: IAP in-app obrigatório. Android: canal próprio (permitido desde 2022). Os dois em paralelo maximizam margem sem violar regras.

**📦 Distribuição de DLCs** · IAP pequeno · produto grande

DLC de história e cosméticos = IAP in-app. DLC de cenário = produto separado nas lojas — página própria, descoberta orgânica.

**🖥️ Plataformas** · Mobile → Steam em 6–12 meses

Lança mobile, valida com dados reais, financia redesign com a receita. Steam é segunda janela de lançamento com elegibilidade ao Next Fest.

**☁️ Save na nuvem** · Nativo + exportação manual

Google Play Games e iCloud nativos (gratuito, sem backend). Exportação de save como arquivo cobre migração entre plataformas.

**👤 Múltiplos perfis** · Sim, nas configurações

Um perfil ativo por padrão. Criar ou trocar perfil fica nas configurações — invisível para quem não precisa.

**💲 Precificação** · US$ 3,99 · regional + promo

Preço global US$ 3,99. Ajuste regional em Brasil, Índia e Sudeste Asiático. Promoção de 30% nas primeiras 2 semanas.

**🔄 Updates** · Fixes grátis · DLC pago · mimos

Bug fixes sempre gratuitos. Conteúdo grande vai para DLC pago. Eventos extras e diálogos de NPCs vão gratuitos como goodwill.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
