# 076 — O pau-de-carga descarrega, e o trabalhador opera o guincho

**02/10/2026 · frente 4 do A5, família animação**: a segunda passagem do
degrau 1, no mesmo dia da `075`, que ela substitui no nível 1. O Bruno viu o
trabalhador levar a caixa ao ombro e escreveu: *«Tem como colocar o guindaste
para ajudar na descarga? Pois é ele que sempre fará isso. Daí o trabalhador
que irá operar esse guindaste inicial. E caso o serviço dure mais de um turno,
pode ter outra animação dele levando a carga para o caminhão.»* A candidata
foi vista em GIF nos três pesqueiros, e a resposta foi «Aceito».

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| Como o pau-de-carga descarrega | **Gira e o gancho desce** (recomendada): sete ângulos, com e sem carga, e o gancho em baixo no porão e na pilha |
| O que o gancho levanta | **Caixas de peixe numa cinta** (recomendada), iguais às da pilha |
| A ida ao camião, nos serviços de mais de um turno | **Depois, com os níveis 2 e 3** (recomendada): só os cargueiros duram mais de um turno, e só atracam nesses níveis |
| O GIF | «Aceito», em texto |

## O que está no jogo

- **O pau-de-carga do nível 1 trabalha**, em `tools/gerar_props_iso.py`. O
  ciclo começa com o pau no porão. O gancho desce e engata duas colunas de
  duas caixas de peixe numa lingada. O pau sobe e gira com a carga até à
  pilha, pousa-a e solta-a, e volta vazio. Dezoito quadros: os sete ângulos
  com e sem carga, mais o gancho em baixo no barco e na pilha, cada um com e
  sem carga. A volta leva ~5 s (`CICLO_N1`).
- **O pau cresceu de 2,10 para 3,30**, e é a geometria que o pede: com o
  alcance antigo o gancho pendia na água. O porão não fica em frente ao mastro.
  Apontado a 0° com 3,15, o gancho descia na proa, ao lado do bote. O porão
  está em (0,3; 2,6) do píer nos três cascos, daí o giro de **18° a 80°**. A
  80° a pilha fica em cima do tabuado; a 90° passava da beira de terra.
- **A pilha** tem três colunas de três caixas na largura do píer. Fica no
  quadro do PÍER, onde o gancho larga, e já não no do trabalhador.
- **O trabalhador opera o guincho**, um tambor azul ao pé do mastro, de frente
  para o barco. Tem dois quadros por sexo, com a alavanca a ir e vir a cada
  0,35 s. O ponto dele sai do deslocamento entre o quadro do píer e o do
  trabalhador, que o gerador lê do `Dock.tscn` (`desloc_trabalhador()`), e
  não de uma cópia.
- **A imagem do pau não gira por cima dos quadros.** Nos níveis 2 e 3, e no
  1 sem barco ou sem trabalhador, o pau varre como antes.
- **O andar saiu.** Os onze quadros de andar e a carga ao ombro saíram de
  `art/props`. O boneco articulado e as cargas do nível 2 (`PROXIMO_NIVEL`)
  ficam no gerador.
- **Ele trabalha assim que é alocado**, como na `075`: o `progress > 0` não
  existe no nível 1.

## As guardas

O **D39** foi reescrito, e faz cinco perguntas:

1. Toda classe que o nível 1 recebe tem pilha.
2. Os dois sexos chegam ao guincho, as figuras são distintas e a alavanca
   mexe.
3. O ciclo, como aritmética:
   - o pau não salta ângulos;
   - o gancho só desce nas pontas;
   - a carga engata no barco e larga na pilha;
   - todo quadro passa.
4. No render:
   - a carga desce dentro dos três cascos (82%, 100% e 100% de casco à volta);
   - pousa em cima da pilha;
   - o operador pisa o tabuado.
5. Na doca montada, com uma MULHER no guincho:
   - o pau trabalha com `progress` 0;
   - os 18 quadros passam pelo nó, e a alavanca dela mexe;
   - o pau não gira;
   - um `refresh()` a meio não o recomeça;
   - no nível 2 o pau varre e a pilha sai.

**A banda da pilha foi medida com a pilha regerada como defeito.** A certa dá
6,0. Com um andar a menos (a carga a pairar) dá 4,0, e com um a mais (a carga
enterrada) 7,33. O corte ficou no meio (5,0 a 7,0): um pixel de PNG de folga
de cada lado.

Foram injetados **doze defeitos**, e todos reprovaram:

- a alavanca parada;
- a carga engatada no ar;
- um ângulo saltado;
- o sexo sempre homem;
- sem o teste do nível;
- o pau a varrer enquanto trabalha;
- sem a assinatura;
- a pilha esquecida ao liberar;
- só com `progress`;
- a pilha no quadro do trabalhador;
- a pilha com dois andares;
- a pilha com quatro andares.

A alavanca parada só reprovou na guarda nova da doca montada: a parte 2 prova
que os dois quadros diferem, e nenhuma outra prova que o ciclo passa pelos
dois.

## O custo

O `.pck` cresceu **168.264 bytes contra a `main`, +1,24% do `.pck`** (135.252
sobre a `075`). São 22 PNGs novos no atlas e 12 saíram; o `pier_n1`, que leva
o guincho, foi regerado.

- A folha de props tem 98 peças, nas mesmas 5 páginas.
- A página de escala passou a contar cada animação pelo quadro de repouso
  (`escala_props.gd`). Os dezoito quadros do pau levavam-na a pedir 1564 px
  numa tela de 1280. Saem das tabelas do `Dock.gd`, e não de uma lista.

## O que fica de fora

- **A ida ao camião**, nos serviços de mais de um turno, vem com os níveis 2
  e 3. Pede quadros a andar no comprimento do píer.
- **O degrau 2** (o guindaste do nível 2 tira a carga, e ele leva-a) e o
  **degrau 3** (pallets e empilhadeira), como na `075`.
- **A transição suave entre turnos**, e **mais de um trabalhador por píer**
  (frente 5).
