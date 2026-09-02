<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 🗺️ Mapa & Espaço

O porto é um grid que cresce para a direita e para o sul. O cais do avô fica sempre no canto noroeste.

## 🔲 Sistema de grid

**Célula base: 64×64px** — Tamanho padrão de célula na resolução mobile base. Estruturas ocupam 1×1, 2×1 ou 2×2 células.

**Grid snapping automático** — Ao arrastar uma construção, ela encaixa automaticamente na célula mais próxima.

**Estruturas têm tamanho fixo** — Não é possível redimensionar construções. O tamanho é intrínseco ao tipo — não ao nível de upgrade.

## 📐 Expansão de área por fase

| | |
|---|---|
| **Fase 1 — Cais básico** | 8 × 6  (48 células) |
| **Fase 2 — Com oficina** | 12 × 8  (96 células) |
| **Fase 3 — Porto regional** | 16 × 10  (160 células) |
| **Fase 4 — Porto nacional** | 20 × 12  (240 células) |
| **Fase 5 — Grande porto** | 24 × 14  (336 células) + área estaleiro separada |

## 🏗️ Regras de construção e layout

**Expansão em L (direita + sul)** — Porto cresce para a direita (terra, cidade) e para o sul (mar, docas). O eixo narrativo é sempre o mesmo.

**Âncora visual: cais do avô** — O cais original herdado fica fixo no canto noroeste. Remover custa mais recursos — mecânica de valor sentimental.

**Estruturas únicas por mapa** — Torre de Controle, Aduana e Estaleiro: máximo 1 cada por mapa. Reforçam marcos de progressão.

**Sobreposição proibida** — Nenhuma estrutura pode ser colocada em célula ocupada — inclusive área de água e área de cidade (fora dos limites do porto).

## ✅ Decisões de design fechadas

**🔲 Grid por fase** · 8×6 → 24×14 em 5 fases

F1: 8×6 (48 células). F2: 12×8. F3: 16×10. F4: 20×12. F5: 24×14 + área estaleiro separada. Expansão acontece automaticamente ao avançar de fase.

**↗️ Direção de expansão** · Cresce à direita e ao sul

Porto cresce para a direita (mais terra, mais cidade) e para o sul (mais mar, mais docas). O cais original do avô fica sempre no canto noroeste — âncora visual da narrativa.

**📐 Tamanho das estruturas** · 1×1, 2×1 ou 2×2 células

Pequenas (grua, posto de guarda): 1×1. Médias (galpão, oficina): 2×1. Grandes (armazém, terminal): 2×2. Estaleiro: 3×2, único no mapa. Grid snapping automático.

**🎨 Perspectiva visual** · Top-down 30°, z-ordering por y

2D com profundidade simulada — sem z-axis real. Godot 4 gerencia depth sorting via z_index automático: estruturas mais ao sul renderizam na frente. Perspectiva top-down leve (~30°), não isométrica. Sem estruturas de múltiplos andares no MVP.

**🚫 Cap de construções** · Espaço livre + 4 exceções hard-capped

Maioria limitada só por espaço. Cap hard por fase: Torre de Controle (1 total), Aduana (1 total), Estaleiro (1 total), Oficina Naval (máx. 2). Evita exploits sem excesso de restrições artificiais.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
