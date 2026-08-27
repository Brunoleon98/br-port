# BR Port — Briefing do Bloco 4 (parte gráfica e HUD)

> Documento de entrada para a conversa que vai fazer a base visual. Escrito em
> 27/08/2026, logo após o Bloco 3 fechar.
>
> **Leia este arquivo primeiro, e depois `docs/ESTADO_DO_PROJETO.md`.**
> Ele existe para a conversa nova não repetir perguntas já respondidas nem
> refazer decisões já tomadas.

---

## As três decisões já tomadas (não reabrir)

O Bruno enviou uma imagem de referência (descrita adiante) e decidiu, sobre ela:

| Questão | Decisão |
|---|---|
| A arte da imagem substitui a paleta atual? | **Não. A imagem é só referência de humor.** A arte segue o *style guide de flat design* do GDD — que ainda precisa ser criado, e é a primeira tarefa do Bloco 4. |
| Docas como cartões ou mapa do porto visto de cima? | **Mapa visto de cima**, como na imagem. É a mudança grande deste bloco. |
| Entra relógio / tempo real? | **Não. O jogo continua por turnos** ("Avançar dia", 32 turnos). O relógio da imagem, se aparecer, é decoração sem função. |

---

## A imagem de referência

O arquivo não está no repositório (veio como anexo de conversa). Descrição, para
quem não a viu:

Vista **de cima** de um porto, em estilo ilustrado/industrial escuro, moldura
com cantos em colchete e brilho ciano. De cima para baixo:

- **Barra de HUD** no topo: quatro contadores com ícone (caminhão, guindaste,
  algo azul, carga) todos zerados, um valor em dinheiro, um segundo medidor com
  o mesmo valor, um relógio, e engrenagem de opções.
- **Cena central**: à esquerda o **escritório principal** com galpões,
  caminhões estacionados e um trabalhador; ao centro três píeres rotulados
  **DOCA 1, 2 e 3**, cada um com navio atracado e boia; à direita a
  **ZONA DE ESPERA**, com cinco navios ancorados (ícone de âncora).
- **Rodapé**: um tablet e um painel de pedido — "PEDIDO ATUAL #M-102",
  "STATUS: EM PROCESSAMENTO", "PRÓXIMO VEÍCULO: M/V SEAHAWK (DOCA 2)",
  "TEMPO RESTANTE: 10 MIN".

### O que APROVEITAR dela

1. **A vista de cima do porto** — é o que motivou a decisão do mapa.
2. **A separação espacial** entre escritório, docas e zona de espera. Ela
   comunica o estado do porto de relance, coisa que uma linha de cartões não faz.
3. **A barra de HUD como faixa contínua** no topo, com números curtos e ícones.
4. **O painel de contexto no rodapé** — a ideia de sempre haver uma linha
   dizendo "o que está acontecendo agora".

### O que IGNORAR dela (importante)

Estes pontos da imagem **contradizem o projeto** e parecem artefato de geração
por IA, não decisão de design:

| Na imagem | No projeto | Por quê |
|---|---|---|
| Relógio `07:00`, "TEMPO RESTANTE: 10 MIN" | Turnos, sem relógio | GDD define turnos; o balanceamento do Bloco 3 foi medido em 32 turnos |
| `$125.000` | **R$**, Fase 1 abre com **R$600** | Moeda e escala erradas; a parcela da Fase 1 é R$8.000 |
| Formato quadrado / paisagem | **Retrato 720×1280** | O VS é mobile retrato (`project.godot`) |
| Render detalhado, sombreado | **Flat design** | Escopo congelado no GDD |
| "PRÓXIMO VEÍCULO" | Navio / barco | Vocabulário do jogo é náutico |

Se a conversa nova seguir a imagem ao pé da letra, constrói um jogo em tempo
real com dólares — e descarta o Bloco 3 inteiro.

---

## Achado que facilita o mapa

A **ZONA DE ESPERA** da imagem não é invenção: ela corresponde à tela **(3) Fila
de barcos/contratos com tap pra detalhes**, que já está na lista das 12 telas do
GDD e **nunca foi implementada**.

Ou seja, o mapa visto de cima permite **fundir as telas (2) e (3) do GDD numa
só** — doca com drag-and-drop e fila de barcos no mesmo lugar. Isso está dentro
do escopo congelado, não o amplia.

> ⚠️ **Mas atenção, porque aqui tem uma armadilha de gameplay.** Hoje os barcos
> nascem **direto dentro das docas** (`_spawn_boats()` em `GameState.gd`). Uma
> zona de espera pode ser:
>
> - **Só visual** — mostra os barcos que vão chegar, sem o jogador interagir.
>   Não muda nada do balanceamento. **Comece por aqui.**
> - **Mecânica** — o jogador puxa o barco da espera para a doca. Isso é uma
>   decisão nova no loop e **muda o balanceamento medido**. Se for por esse
>   caminho, é obrigatório rodar `tools/simular_balanceamento.gd` de novo e
>   atualizar os números registrados.

---

## De onde partir (o que já existe e ajuda)

O Bloco 3 deixou a base pronta justamente para isso:

| Onde | O que é |
|---|---|
| `brport_vs/ui/tema_brport.tres` | **Todo o estilo num arquivo.** Cores, cantos, botões, e estilos nomeados por estado de doca e trabalhador (`DocaVazia`, `DocaBarco`, `DocaGrande`, `DocaRival`, `TrabLivre`, `TrabAlocado`, `TrabOcupado`). |
| `brport_vs/scenes/*.tscn` | Telas como árvore de nós. Os scripts **não constroem nem pintam nada** — só alimentam texto e escolhem qual estilo do tema vale. |
| `brport_vs/tools/capturar_tela.gd` | Renderiza o jogo e salva um PNG, sem abrir o editor. **Use isso a cada mudança visual** — teste verde não prova que ficou bonito. |
| `brport_vs/tests/run_tests.gd` | 33 asserções. Duas delas instanciam cenas reais e conferem botões. |

**A paleta atual é clara** (creme `#f0f6ff` sobre navy `#1c3454`), portada do
protótipo HTML validado. Ela **não está decidida como definitiva** — a decisão
foi que o style guide do GDD manda. Mas ela é o ponto de partida, e foi bem
recebida no playtest.

---

## Ordem de trabalho (do Plano de Produção, Bloco 4)

O plano é explícito e vale seguir:

1. **Style guide de flat design — ANTES de qualquer sprite.** Paleta, peso de
   linha, proporções. Sem isso cada asset sai diferente. *(É a tarefa nº 1.)*
2. **Estrutura do mapa com placeholder** — posições de doca, zona de espera,
   escritório, ainda com formas simples. Valida se a leitura melhora **antes**
   de encomendar arte.
3. Sprites de personagem — Dona Cida primeiro (mais usada), depois Arlindo,
   Sr. Ribeiro, trabalhadores.
4. Sprites de cenário — píer e barcos (3 variações visuais, mesma mecânica).
5. UI das 12 telas.
6. Áudio.
7. Integração progressiva — cada asset entra no projeto assim que sai, sem
   acumular para o fim.

---

## Restrições que não podem ser violadas

- **Turnos, não tempo real.** 32 turnos, 8 por semana, 4 semanas.
- **R$**, não `$`. Fase 1: caixa inicial R$600, barcos R$80–300, parcela
  R$8.000 na semana 4.
- **Retrato 720×1280**, mobile.
- **Nada de pintar cor em script.** Estilo vai no tema; cena vai no `.tscn`.
- **Rodar os testes antes e depois.** Espera-se `TODOS OS TESTES PASSARAM`.
- **Mexeu em regra de jogo? Remedir** com o simulador e atualizar os números
  em `docs/ESTADO_DO_PROJETO.md` e `docs/BLOCO3_MARCO_INTERMEDIARIO.md`.

---

## Pendências herdadas (não são do Bloco 4, mas estão registradas)

- **Parcelas 2 e 3 (R$16.000 e R$24.000) não foram verificadas.** Ver
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. Checar antes de codar a
  economia da Fase 2 — não agora.
- **A reputação não afeta nada** mecanicamente, só o rótulo na HUD.
- **A derrota por caixa negativo é código morto** — o píer sozinho paga os
  custos, então a única forma de perder é a parcela.

---

## Como abrir a conversa nova

Cole isto:

> Continuando o BR Port. Leia `docs/BLOCO4_BRIEFING_VISUAL.md` e depois
> `docs/ESTADO_DO_PROJETO.md`. Vamos começar o Bloco 4 pela base visual: o
> style guide de flat design e a estrutura do mapa do porto visto de cima, com
> placeholder. As decisões sobre a imagem de referência já estão no briefing —
> não precisa reabrir.

E anexe a imagem de referência de novo, se quiser que ela seja vista.

---

*BR Port · Briefing do Bloco 4 · Fase 4 (Produção do VS)*
