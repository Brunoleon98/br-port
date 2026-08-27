# BR Port — Style Guide de Flat Design

> Primeira tarefa do Bloco 4 (`docs/design/BR_Port_Plano_Fase_2_Producao_VS.md`,
> Bloco 4 item 1): "paleta, peso de linha, proporções. Sem isso, cada asset
> sai diferente." Este documento é a referência única para qualquer arte
> nova — sprite, ícone ou tela — a partir de agora.
>
> Não substitui `brport_vs/ui/tema_brport.tres` — formaliza por escrito as
> regras que o tema já segue, e estende a paleta para o mapa do porto
> (Bloco 4, item 2). Mudar um valor aqui sem mudar no tema (ou vice-versa)
> é a própria dívida técnica que este guia existe para evitar.

---

## 1. Duas paletas, um sistema

O jogo tem **HUD/UI** (cartões, botões, barras) e vai passar a ter
**mapa/cenário** (água, píer, escritório). São paletas diferentes que
precisam ler como o mesmo jogo — por isso os tons de mundo derivam das
mesmas famílias de cor da UI (o telhado usa o mesmo laranja que já existia
no protótipo, por exemplo), em vez de inventar uma paleta à parte.

### 1.1 Paleta de UI (já validada, portada do protótipo HTML)

Fonte: `brport_vs/ui/tema_brport.tres`. Não muda neste documento — só
registrada aqui para as duas paletas ficarem num lugar só.

| Token | Hex | Uso |
|---|---|---|
| `navy` | `#1c3454` | Texto padrão, botões, cabeçalho escuro |
| `navy2` | `#24466e` | Hover/ênfase, borda de doca grande |
| `amber` | `#e09a10` | Destaque, barra de progresso cheia, título |
| `amber2` | `#f5b93a` | Reserva — variação clara do amber |
| `cream` | `#f0f6ff` | Fundo da tela |
| `white` | `#ffffff` | Cartões |
| `border` | `#d0dff0` | Borda neutra de cartão |
| `green` | `#1a7a40` | Estado "livre/disponível/sucesso" |
| `red` | `#c23030` | Estado "alerta/rival/perigo" |
| `warn` | `#d97706` | Estado "atenção" (faixa de mensagem) |
| `orange` | `#c85420` | Reserva do protótipo — reaproveitado no mapa (telhado) |
| `gray` | `#8299b4` | Texto secundário, estado "ocupado/indisponível" |

### 1.2 Paleta de mapa/cenário (nova — Bloco 4)

Estética tropical brasileira, conforme o GDD ("Flat Design 2D — estética
tropical brasileira"; atmosfera "casas coloridas, mangue, coqueiros, barcos
de madeira"). Cores sólidas, sem gradiente — blocos de flat design, não
render sombreado.

| Token | Hex | Uso |
|---|---|---|
| `agua` | `#2f7690` | Mar aberto — fundo do mapa do porto |
| `agua_clara` | `#5fb4d1` | Reserva — água rasa perto do píer (uso futuro) |
| `areia` | `#efe0c0` | Terreno/pátio do escritório |
| `madeira` | `#8a5a34` | Estrutura de píer/madeira |
| `madeira_escura` | `#6b4423` | Contorno de madeira, postes |
| `telhado` | `#c85420` (= `orange`) | Telhados de galpão/escritório |
| `folhagem` | `#2d7a3a` | Reserva — coqueiro/mangue (cenário, uso futuro) |
| `folhagem_clara` | `#4a9c58` | Reserva — variação clara de folhagem |

As entradas "reserva" ainda não têm nó nenhum no tema — existem para a
próxima leva de cenário (coqueiros, mangue) não inventar tom novo.

---

## 2. Peso de linha e cantos

| Escala | Valor | Uso |
|---|---|---|
| Borda fina | 1px | Cartão estático (`Cartao`) |
| Borda média | 2px | Estado interativo padrão (doca com barco, trabalhador livre/alocado) |
| Borda grossa | 3px | Ênfase/alerta (doca grande, oferta do rival, prédio do escritório) |
| Canto pequeno | 8px | Faixa de mensagem |
| Canto médio | 10px | Botões, painéis de mapa (`Escritorio`, `ZonaEspera`) |
| Canto padrão | 12px | Cartões, docas, trabalhadores |
| Canto grande | 14px | Painel escuro, fundo do mapa (`MapaAgua`) |
| Pílula | 99px | Barras de progresso |

Nunca pintar cor ou canto direto em script — sempre como `StyleBoxFlat` no
tema (`tema_brport.tres`) ou no `.tscn` da cena. Isso é o que permite trocar
placeholder por arte final trocando recurso, sem tocar em lógica.

## 3. Espaçamento

Valores já em uso nos containers (`theme_override_constants/separation` /
margens): **2, 6, 8, 10, 12, 14, 20**. Não são múltiplos redondos de uma
grade única — são os valores que o protótipo validado já usava. Todo nó
novo deve escolher um destes, não inventar um espaçamento diferente.

## 4. Proporções — tamanhos canônicos para arte futura

Estas são as caixas que a arte final (Bloco 4, itens 2–4 do plano) precisa
respeitar — o placeholder já define o espaço; o sprite entra dentro dele.

| Elemento | Caixa (px) | Nota |
|---|---|---|
| Trabalhador (`Worker.tscn`) | 96×96 | Figura de pé, centralizada, margem interna ~8px |
| Doca (`Dock.tscn`) | 150×170 | Retrato — arte do barco/píer ocupa a faixa superior (~100px), texto/estado embaixo (~70px) |
| Escritório (mapa) | 90×170 | Alinhado à mesma altura da doca, para a leitura da fileira ficar nivelada |
| Zona de espera (mapa) | 90×170 | Mesma altura da doca; largura menor porque é só marcador, não slot operável |
| Ícone inline (emoji hoje, vetor depois) | 13–28px | Tamanho de fonte onde o ícone é usado hoje — usar como guia de escala do sprite final |

## 5. Cor por estado (convenção que se repete em UI e mapa)

| Estado | Família de cor | Onde já aparece |
|---|---|---|
| Livre / disponível | Verde (`green`) | `TrabLivre` |
| Em andamento / normal | Navy claro / azul (`navy2`, `border`) | `DocaBarco`, `TrabAlocado` |
| Ocupado / indisponível | Cinza (`gray`) | `TrabOcupado` |
| Alerta / rival / perigo | Vermelho (`red`) | `DocaRival` |
| Ênfase / grande | Navy escuro, borda grossa (`navy2` @ 3px) | `DocaGrande` |

Qualquer elemento novo do mapa que precise comunicar um desses cinco
estados usa a família já definida — não cria cor de estado nova.

## 6. Iconografia

Hoje todo ícone é emoji (⚓ 💰 📅 ⭐ 👷 🚢 ⛵ 🏦 🏢 🌊). É placeholder de
propósito. Quando entrar arte final (Bloco 4, item 5 — "UI das 12 telas"),
o ícone vetorial troca o emoji **no mesmo slot de texto/tamanho**, mantendo
o peso de linha da seção 2. Não trocar emoji por ícone com estilo diferente
(ex.: outline fino) sem atualizar este guia primeiro.

## 7. O que este guia NÃO decide

- Sprites de personagem e cenário (Bloco 4, itens 3–4) — vêm depois, dentro
  destas caixas e desta paleta.
- Áudio (Bloco 4, item 6).
- Layout das 12 telas da UI além do que já existe (Bloco 4, item 5).

---

*BR Port · Style Guide de Flat Design · Fase 4, Bloco 4, item 1*
