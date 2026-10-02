# 075 — O trabalhador que anda: o degrau 1 da família animação

**02/10/2026 · frente 4 do A5, família animação**: a última família da frente,
depois da escala e dos camiões (`069`, `070`), da frota (`071`–`073`) e da
ruína (`074`). Ela responde à nota de 23/09, *«o trabalhador animado (andar,
pallets, empilhadeira) e uma transição suave entre turnos»* (plano v3, §7,
item 4). A primeira candidata foi vista em GIF, nos três píeres, e o Bruno
mandou-a para o jogo no nível 1.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| Por onde começa a família | **O trabalhador no píer** (a recomendada), contra a empilhadeira, a transição e uma passagem leve nas três |
| O que ele faz | **Vai e volta com carga** (recomendada): do barco a uma pilha, em laço |
| A técnica do andar | **Quadros do Blender** (recomendada), contra o sprite a deslizar |
| A figura | **Pelo sexo**, duas figuras (a recomendada era a genérica) |
| O caminho, com prévia em ASCII | **Atravessa o tabuado** (recomendada): sobe à direita, longe do barco |
| A carga | **Pelo serviço do barco**, ao ombro (recomendada) |
| A pilha | **Fixa enquanto opera** (recomendada) |
| Depois do GIF, em texto | o guindaste podia ajudar; no futuro, mais de um trabalhador por píer; uma máquina a pegar pallets no lugar dos sacos; tudo a abrir com o nível do píer e do guindaste |
| Os níveis | **Um degrau por nível** (recomendada): 1 ao ombro; 2 o guindaste tira a carga e ele desengata; 3 pallets e empilhadeira |
| A máquina | **Empilhadeira** (recomendada), e não retroescavadeira |
| O que entra agora | **O nível 1 no jogo** (recomendada). Mais de um trabalhador por píer vai para a frente 5 |

## O que está no jogo

- **O boneco articulado**, em `tools/gerar_props_iso.py`. Tem pernas com
  bota, braços de manga laranja com mão de pele, e a mesma régua da pessoa
  (`069`). O ciclo usa três quadros, na ordem 0-1-2-1. Ele vai ao barco de
  frente e vazio (`trab_<sexo>_vai_*`) e volta de costas com o braço direito
  a segurar a carga (`trab_<sexo>_volta_*`).
  - O `trabalhador` passou a ser o quadro do meio do homem: o parado e a régua
    das ferramentas.
  - A marca dela é o cabelo. A primeira versão do rabo de cavalo não se via;
    a segunda tem mechas até ao ombro e um rabo mais grosso.
- **A carga e a pilha** são PNGs à parte. A carga é filha do nó do
  trabalhador e desliza com ele. A pilha tem duas colunas, de três e dois
  andares; a primeira era uma camada e meia, com 1,5 px na tela, e lia como
  uma poça.
- **Quem anda é o nó.** Todo quadro nasce no mesmo ponto do mundo, e o
  `Dock.gd` desliza-o pelo `CAMINHO_TELA`, de 23,6 px. A pose sai do
  `pose_no_ciclo()`, uma função pura: pausa no barco, volta, pausa na pilha,
  ida.
  - Cada trecho leva 2,2 s, a 8 poses por segundo.
  - Uma assinatura do estado impede que o `refresh()` de cada turno o devolva
    ao barco a meio do caminho.
- **Nos níveis 2 e 3** ele fica de pé, com a figura do seu sexo e o balanço de
  3 px de antes, até essas animações existirem.

## O que a medição mudou

- **Ele anda assim que é alocado, e não com `progress > 0`.** O pesqueiro
  serve num turno, e o `progress` chega a 1 no avanço em que ele parte.
  Medido em 20 partidas: 449 instantes de trabalhador alocado a um barco no
  nível 1, e nenhum com `progress > 0`. A animação estaria ligada e validada e
  nunca tocaria. O balanço antigo também nunca tinha tocado ali.
- **Só a caixa de peixe chega à tela.** Com o guindaste de nível 1 o porto só
  recebe o pesqueiro (`009`), e é nesse nível que ele anda. O papelão e o
  saco foram desenhados e aprovados na mesma prancha, e ficam no gerador fora
  da regeração completa (`PROXIMO_NIVEL`) até o nível 2 os pôr em cena.
- **O saco de ráfia leva uma faixa verde.** Sobre o concreto do píer 3, o
  creme dava 0,11 de Weber pela mediana. O branco não resolve, porque o AgX
  segura-o perto de 0,5 de luminância e o concreto está a 0,39. A faixa e as
  sombras entre os sacos separam-no na escala do jogo. Isto vale para o nível
  2; no 1 não há saco.

## As guardas

O **D39** do teste de design faz cinco perguntas:

1. Toda classe que o nível 1 recebe tem carga e pilha. A lista sai das
   classes do `GameState`, não da tabela do `Dock`.
2. Os dois sexos chegam, com figuras distintas, e o passo troca de perna.
3. O ciclo não salta, e a carga só existe na volta.
4. Ele pára encostado à pilha. A banda é −10,8 a −0,2 px, medida no motor:
   −5,5 com o caminho certo, −16,1 com metade e +5,1 com 1,5 vezes.
5. Na doca montada, ele anda com `progress` 0, um `refresh()` a meio não o
   teletransporta, e no nível 2 ou sem trabalhador a pilha sai.

Foram injetados **dez defeitos**, e todos reprovaram, cada um na sua guarda:

- sem a armazenagem do pesqueiro;
- sexo sempre homem;
- ela a vestir os quadros dele;
- a pausa da pilha posta no barco;
- carga na ida;
- meio caminho;
- sem a assinatura;
- só com `progress > 0`;
- a pilha esquecida ao liberar;
- um passo sem troca de perna.

## O custo

O `.pck` cresceu **33.012 bytes, +0,24%**: são 13 PNGs novos no
atlas, e o `trabalhador` foi regerado. A folha de props passou a 5 páginas
(88 props).

## O que fica de fora

- **Os níveis 2 e 3**, uma sessão cada: o guindaste a tirar a carga do barco,
  depois os pallets e a empilhadeira. A empilhadeira do pátio está fora da
  régua (47 px de altura, contra 37 do camião), porque a `069` não chegou a
  ela.
- **A transição suave entre turnos**, a outra metade do item 4.
- **Mais de um trabalhador por píer**, que mexe no `GameState`, no
  balanceamento e no `SAVE_VERSION`: está na frente 5 do plano.
