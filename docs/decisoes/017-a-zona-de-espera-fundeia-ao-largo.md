# 017 — A Zona de Espera fundeia AO LARGO, e quem diz onde é o mapa

**11/09/2026.** O fecho do item **15** da segunda jogada — *"a área de espera
dos navios pode ficar mais afastada do porto"* —, o próximo da ordem sugerida
depois de o 7, o 6 e o 11 terem fechado.

Nada aqui encosta na economia: o `GameState.gd` não mudou e nenhuma constante
`# TUNING:` foi tocada. O balanceamento continua **100% / 80,2% / 37,3%**, com
a parcela em R$530.000. Mudaram cinco posições no `Main.tscn`, uma chave nova na
tabela de âncoras e um bloco novo no teste de design.

**Metade do item já estava feita.** A outra frase da queixa — *"ao invés de ter
barcos genéricos, pode ter os navios e barcos que realmente podem atracar"* —
fechou em 07/09 e ganhou o eixo do porte em 08/09: o ancorado segue a classe, o
motivo e o valor, e respeita a trava de `009`. Faltava só a distância.

---

## 1. A queixa dizia "afastada" e o defeito era outra coisa

"Afastada" é uma palavra de distância, e a distância não era o problema — a
PROFUNDIDADE era.

O mapa pinta a água em quatro bandas, e três delas **acompanham a costa**:
`agua_baixio` até 1,0 da linha de água, `agua_rasa` até 2,6 e `agua_media` até
6,0. Para lá disso é o largo. Um barco atracado fica a **2,25** da costa, dentro
da `agua_rasa` — é o que os três berços medem.

Medido antes de mexer, perguntando ao mapa que cor ele pinta debaixo de cada
prop: **três dos cinco caíam em `agua_media`**, a banda do meio. Só dois estavam
no largo. E os dois que estavam errados de forma mais falante eram as **boias**
— as peças cuja função é MARCAR o fundeadouro estavam à profundidade de um
berço.

É por isso que os ancorados liam como "mais barcos atracados que erraram o
píer": estavam na água dos atracados.

## 2. A conta em unidades mente, e o mapa não

A primeira medição foi a óbvia — distância em `mx` até a borda do cais da banda
de `my` do prop — e deu **6,85** para o `Ancoragem1`, acima do 6,0 onde o largo
começa. Pela conta, estava no largo. Pela tinta, estava em `agua_media`.

A conta engana porque **a costa é uma escada**. Perto de um degrau, o ponto de
costa mais próximo não é a borda da própria banda: é a face do degrau ao lado,
e as faixas de profundidade seguem o CONTORNO, não a banda. Quem sabe onde
acaba a água costeira é o desenho.

Daí a técnica: rasterizar o mapa com o ThorVG — que é o importador do jogo — e
ler a cor. É exatamente a porta que o **D20** abriu em 08/09 para a rua, virada
agora para a água.

## 3. O número saiu de uma varredura, e depois da imagem

Varrido o afastamento em `+mx` de 0 a 7, meio a meio, perguntando ao mapa em
cada passo:

| afastamento | props no largo |
|---:|:---|
| 0,0 (hoje) | 2 de 5 |
| 2,0 | 4 de 5 |
| 2,5 | **3 de 5** |
| 3,0 | 4 de 5 |
| **3,5** | 5 de 5 |
| 4,0 a 7,0 | 5 de 5 |

⚠️ **A fronteira NÃO é monótona, e é o degrau outra vez.** Entre 2,0 e 3,0 o
número de props no largo sobe, desce e sobe — afastar-se da costa em `+mx`
também desce em `my`, e a meio caminho um prop volta a entrar na banda do degrau
seguinte. Parar em 3,5, que é o primeiro passo que serve, seria assentar em cima
de uma fronteira que se mexe.

Com 3,5, 4,5 e 6,0 renderizados e postos lado a lado, **4,5** foi o escolhido:
o 3,5 separa mas ainda lê como "ao lado"; o **6,0 encosta os navios na borda do
quadro** e a relação com o porto enfraquece. A 4,5 sobram 105 px à direita e 93
abaixo, e o fundeadouro ocupa a metade direita da imagem, que era espaço morto.

## 4. Mover cinco props mexeu na ORDEM, e isso não é enfeite

`mx + my` é profundidade, e a ordem dos irmãos dentro do `Cenario` é o que o
Godot desenha por cima de quê. Afastar 4,5 em `mx` sobe a profundidade dos cinco
em 4,5 e eles passam para o fim da fila — o `BarcoEspera2` do meio da lista para
o último de 27.

Reordenar faz parte da mudança, não é arrumação: sem isso o **D3** reprova, e
com razão. Sete nós trocaram de posição.

## 5. O bloco D21, e por que ele não casa hexadecimal

Nada no projeto perguntava onde a Zona de Espera está. Toda a maquinaria de
cerco mede pegada de prop contra faixa PUBLICADA, e o fundeadouro não tem faixa
nenhuma: são cinco props postos no `Cenario` a olho.

O mapa passou a publicar `cores_da_agua`, dividido em `costeiras` e `largo` —
como já publicava `cores_da_rua` para o D20, e pela mesma razão: uma lista
escrita do lado do Godot envelheceria calada na primeira vez que alguém mexesse
na rampa da água.

⚠️ **E AQUI O HEXADECIMAL EXATO NÃO SERVE, ao contrário da rua.** A primeira
versão do D21 comparava a cor lida com a da paleta, com a folga de 4/255 que o
`_mesma_cor` dá ao antisserrilhado — e **reprovou o berço da doca 3**, que saiu
a `#3aacc7` onde a paleta diz `#3fb6cf`. Não era o porto que estava errado: era
o teste. A rua é tinta chapada; a **água leva coisa por cima** — manchas de
corrente em gradiente radial e duas camadas de espuma, todas semitransparentes.

O que separa as duas famílias com folga é a **luminância**, e o limiar sai
DERIVADO do que o mapa publica: a meio caminho entre a costeira mais escura
(108,7) e o largo mais claro (76,6), o que dá **92,6 com 16 pontos de folga de
cada lado**. Mancha nenhuma atravessa isso — o berço manchado mede 149,7 e o
fundeadouro mede 70,6.

## 6. São DUAS perguntas, e cada uma levou o seu defeito

O D21 afirma duas coisas, e nenhuma implica a outra. Provado nos dois sentidos,
com o defeito injetado no MAPA e não na cena — assim o D3 não pode disparar no
lugar da guarda que se está a testar:

| Defeito injetado | Reprova | Passa |
|---|---|---|
| A banda `agua_media` alargada de 6,0 para 14,0, a engolir o fundeadouro | as **5** do fundeadouro | as 3 do berço |
| As três costeiras encolhidas para 0,5 / 0,3 / 0,2, e o berço fica em mar aberto | as **3** do berço | as 5 do fundeadouro |

Os dois com código de saída lido do teste e não de um cano, e a base a passar
uma vez entre um e o outro.

## 7. O que NÃO se fez

- **Não se mexeu na água nem na costa.** O item era de posição; alargar ou
  reescalar as bandas é a paleta, e a paleta já achatou a imagem uma vez quando
  se lhe mexeu sem medir (`CLAUDE.md`, 02/09).
- **Não se deu mecânica ao fundeadouro.** Ele continua a ser só visual, e
  torná-lo mecânico muda o balanceamento medido.
- **Não se acrescentou um terceiro ancorado.** São dois porque a faixa da
  classe dá dois valores distintos; um terceiro repetiria casco.

## 8. O que provar na imagem

Das nove capturas mudam **sete** — a Zona de Espera é cenário permanente e
aparece em todas as fotos de jogo. `icones` e `frota` têm de sair IGUAIS: se
mudaram, a alteração vazou.

A pergunta para quem olhar, no `porto`: **os dois barcos parados leem como
fundeados ao largo, ou continuam a ler como mais dois atracados que erraram o
píer?**
