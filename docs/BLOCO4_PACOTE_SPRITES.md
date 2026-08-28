# BR Port — Análise do pacote de sprites e mockups (Bloco 4)

> Registro do que chegou em 28/08/2026: 5 sprites PNG, 2 guias de
> implementação e 5 mockups de gameplay (níveis 1 a 5).
>
> Existe para a próxima conversa não reabrir as mesmas decisões nem tentar
> implementar de novo o que já foi descartado por escopo.

---

## 1. O defeito que quase passou batido

**Os 5 PNGs não tinham canal alpha.** O quadriculado cinza-e-branco que
aparece no visualizador estava **pintado na imagem como pixels opacos** — o
cabeçalho do PNG dizia `RGB`, sem alpha.

O guia que veio junto manda "verificar se o alpha foi importado corretamente".
Não havia alpha para importar. Jogados direto no Godot, os cinco sprites
apareceriam dentro de um retângulo quadriculado.

É um artefato conhecido de gerador de imagem: pedir "fundo transparente" faz o
modelo **desenhar** um quadriculado, porque foi isso que ele aprendeu que
"transparente" parece.

### Como foi consertado

`tools/preparar_sprites.py` — fica no repo porque o defeito vai se repetir a
cada leva nova de assets do mesmo gerador.

O script faz três coisas, e a segunda é a que dá trabalho:

1. Marca como fundo os pixels claros e dessaturados **ligados à borda**. Usar
   componentes conexos é o que impede de comer os brancos legítimos de dentro
   do sprite — a cabine do cargueiro, as faixas refletivas do colete.
2. Trata os buracos fechados. O cordame do barco de pesca e a treliça do
   guindaste cercam pedaços de quadriculado que não encostam na borda. Eles
   são identificados por serem **bitonais**: o quadriculado alterna dois
   cinzas fixos, enquanto uma área branca de verdade tem sombreado e espalha
   valores. Sem esse passo sobravam manchas cinza no meio dos sprites.
3. Come 2px na fronteira (mata o halo de antialiasing), recorta a moldura
   vazia e redimensiona.

Rodar de novo:

```
python3 tools/preparar_sprites.py <pasta_original> brport_vs/art/sprites
```

Os originais 1920×1920 (~2,7 MB cada) saem entre 43 e 262 KB.

---

## 2. O que entrou no jogo

Quatro dos cinco sprites têm mecânica correspondente na Fase 1 e foram
integrados de verdade:

| Sprite | Onde | Mecânica que já existia |
|---|---|---|
| `trabalhador.png` | `Worker.tscn` + preview do arrasto | Trabalhadores alocáveis |
| `cargueiro.png` | `Dock.tscn`, quando `large == true` | Barco grande (2 turnos, R$200–300) |
| `barco_pesca.png` | `Dock.tscn`, quando `large == false` | Barco pequeno (1 turno, R$80–200) |
| `caminhao.png` | Painel Escritório no mapa | Decorativo — espelha o pátio do mockup |

O emoji que marcava o tipo do barco (🚢/⛵) saiu: o sprite já diz o que é.

**`guindaste.png` ficou preparado mas não colocado.** Não há mecânica de
guindaste na Fase 1 — o GDD trata construção de equipamento como produção
full. Colocá-lo agora seria enfeite sem função, e enfeite sem função vira
dívida quando a mecânica chegar e o sprite estiver no lugar errado. Está em
`brport_vs/art/sprites/`, pronto, esperando o upgrade de doca.

---

## 3. O que NÃO cabe na Fase 1 (e por quê)

### Os dois guias assumem outra arquitetura

Os guias descrevem um jogo diferente do VS em quase todas as decisões
estruturais:

| Guia manda | O VS é | Consequência |
|---|---|---|
| `Node2D` + `TileMapLayer` + `CharacterBody2D` | Árvore de `Control` (UI) | Seguir o guia é reescrever o jogo |
| Ordenação isométrica por `z_index` = Y | Cartões em container, sem sobreposição | Não se aplica |
| `1280×720` paisagem | **720×1280 retrato** (`project.godot`) | Conflito direto |
| Input Map com WASD, câmera móvel | Sem câmera — tela fixa | Não se aplica |
| `speed_pause` / `speed_up` (tempo real) | **Turnos** — 32 turnos, "Avançar dia" | Descarta o balanceamento do Bloco 3 |
| Trabalhador caminha até o ponto de carga | Trabalhador é alocado por arrasto | Mecânica diferente |

O que **é** aproveitável dos guias: as configurações de importação de PNG
(filtro ligado, mipmaps desligado, compressão lossless) e a ideia de
centralizar escala por categoria em vez de espalhar `scale` por dezenas de
cenas.

### Os 5 mockups mostram o jogo completo, não o VS

São bonitos e úteis como direção visual, mas o HUD deles é quase todo
"VS — OUT":

| No mockup | Situação no VS |
|---|---|
| Relógio `07:00`, `TEMPO RESTANTE: 10 MIN`, velocidade 1x/pause/FF | **Fora** — o jogo é por turnos |
| `$125.000` / `$2.750.000` | **Fora** — é R$, e a Fase 1 abre com R$600 |
| Nível 12, XP `1.250 / 2.500` | **Fora** — não existe progressão por XP |
| `PESQUISA`, `LOJA`, `MISSÕES` | **Fora** — produção full |
| Clima / temperatura | **Fora** |
| 5 docas, estaleiro, oficinas (nível 5) | **Fora** — a Fase 1 tem 2 docas, 3 após o upgrade |
| `CONTRATOS`, `ARMAZÉM`, `REPUTAÇÃO`, `FINANÇAS` | Parcialmente — só reputação existe hoje |
| Escritório, docas rotuladas, zona de espera | **Dentro** — já implementado |

O mockup do nível 1 já mostra 3 docas e um contador de dia 18 com dívida
vencendo — o VS tem 2 docas iniciais e 32 turnos. Ou seja, nem o nível 1 do
pacote é a Fase 1 do VS.

---

## 4. O que fazer com os mockups

Trate-os como **referência de humor**, exatamente como a imagem conceito
anterior (ver `BLOCO4_BRIEFING_VISUAL.md`). O que eles confirmam, e que já
estava decidido:

- Mapa do porto visto de cima, com escritório à esquerda e zona de espera à
  direita. ✅ já implementado
- Docas rotuladas sobre a água. ✅ já implementado
- Painel de contexto no rodapé dizendo o que está acontecendo. ⏳ protótipo em
  `scenes/proto/MapaConceito.tscn`, não integrado

O que eles acrescentam de novo e vale considerar **depois** do VS: a coluna de
botões laterais (Contratos / Missões / Armazém / Mapa / Reputação) é uma
solução de navegação boa para as 12 telas do GDD.

---

## 5. Tamanhos finais dos sprites

Exportados a ~2x do tamanho de exibição, para não borrar em tela densa.

| Arquivo | Arquivo final | Exibição no jogo |
|---|---|---|
| `trabalhador.png` | 121×256 | ~48×86 no cartão do trabalhador |
| `cargueiro.png` | 512×367 | ~130×82 no cartão da doca |
| `barco_pesca.png` | 448×413 | ~130×82 no cartão da doca |
| `caminhao.png` | 313×320 | ~62×62 no painel do escritório |
| `guindaste.png` | 249×320 | não colocado |

---

*BR Port · Análise do pacote de sprites · Fase 4, Bloco 4*
