# 014 — A frota de pesca tem três portes, e quem escolhe é o valor do contrato

**08/09/2026.** O fecho do item **7** da segunda jogada — *"variedade de barcos
de PESCA"* —, escolhido pelo Bruno como arte pequena e independente.

Nada aqui encosta na economia: o `GameState.gd` não mudou e nenhuma constante
`# TUNING:` foi tocada. O balanceamento continua **100% / 80,2% / 37,3%**, com
a parcela em R$530.000.

---

## 1. Por que era um buraco, e não um capricho

A trava de `docs/decisoes/009` prende o pesqueiro ao **nível 1** do porto. O
porto abre em ruínas, e o que isso quer dizer, lido do outro lado, é que
**enquanto o jogador não constrói nada ele só recebe pesqueiro** — e havia um
pesqueiro só. Todas as docas, todos os turnos, a partida inteira.

O perfil Descuidado nunca sai daí: em 600 partidas ele não vê um navio de longo
curso, e a maior parte das escalas dele são de pesca. **A frota de 07/09
resolveu a variedade onde ela já existia** — seis cascos para as duas classes de
carga, que são justamente as que o jogador mais avançado vê — e deixou intacto o
único barco que o jogador mais atrasado vê.

É o buraco do `barco_medio` com o sinal trocado outra vez, e é a terceira vez
que ele aparece com outra cara: ali um prop existia e não chegava à tela; aqui
um prop chegava à tela e não tinha companhia nenhuma.

## 2. O eixo é o PORTE, e NÃO o motivo — a afirmação de 010 fica de pé

`docs/decisoes/010` diz, com todas as letras, que o pesqueiro leva o mesmo casco
em `pescado` e em `armazenagem`: *o mesmo peixe indo para o mercado ou para a
câmara do armazém — o DESTINO da carga muda, o barco não.* Isso continua verdade
e continua trancado pelo D17: as duas folhas do pesqueiro são a **mesma lista de
três barcos**, e a regra de partilha total ou nenhuma passou a comparar a folha
inteira em vez de um casco.

O que varia é outro eixo, e ele já estava no barco: **o valor do contrato**. Um
bote de linha não traz uma escala de R$28.000, e um arrasteiro não sai ao mar
por R$12.000. A faixa da classe (R$12.000–28.000) divide-se em três partes
iguais e cada uma tem o seu barco.

**Isto custou zero sorteios**, e a razão é a mesma que fez os camiões de 07/09
saírem do índice da doca em vez de um `randf()`: o `RandomNumberGenerator` do
jogo é o que o simulador mede, e um enfeite a gastar um sorteio deslocaria a
sequência que as 600 partidas por perfil medem. O `value` nasce com o barco no
`_make_boat()`, nunca é reescrito (o desconto da contra-oferta vai para
`matched_value`) e já entra no save — **nenhum campo novo, e o `SAVE_VERSION`
não subiu.**

E a leitura que sai daí é melhor do que a que se foi buscar: o jogador vê o
valor no cartão da doca e o barco ao lado dele, e as duas coisas concordam.

## 3. A tabela passou a ter uma LISTA em cada folha, inclusive as de um

`CASCOS[classe][motivo]` era uma textura e passou a ser um `Array` ordenado do
menor porte para o maior. As classes de carga declaram folhas de **um**
elemento — elas separam-se pelo convés, não pelo porte.

Escrever a folha de um em vez de aceitar as duas formas é o que mantém a tabela
percorrível: dicionário aqui e lista ali seria uma tabela que o D17 e a
`folha_frota.gd` teriam de perguntar antes de ler, e a lição desta pasta é que
uma tabela com exceção em código deixa de ser percorrida.

## 4. Três gramáticas, não um barco esticado

A regra que o armazém pagou em 05/09 e que a frota repetiu em 07/09: **repintar
ou reescalar o mesmo desenho daria três barcos iguais e três etiquetas de
tamanho.** Os três partilham o `casco()` — como os cargueiros partilham o
costado — e separam-se pelo que têm em cima:

| | Faixa | Silhueta | Gramática do convés |
|---|---|---|---|
| **Bote** (44px) | R$12.000–17.333 | baixa, sem vertical | convés ABERTO: caixas de peixe à vista, console de pilotagem, motor de popa. Sem vigia nenhuma — vigia é janela de compartimento, e ele não tem compartimento |
| **Traineira** (68px) | R$17.334–22.666 | cabine + mastro | o barco de sempre: pau-de-carga, rede e boia |
| **Arrasteiro** (82px) | R$22.667–28.000 | pórtico de popa | casa do leme à frente e a POPA a trabalhar: arco de popa com a rede içada, tambor de rede, escotilha de porão, dois tangones |

O contorno **escala-se**, nunca se reescreve ponto a ponto — é a regra do
`galpao` ("encolher um prop escala-se no GRUPO") um andar acima: catorze números
escritos três vezes seriam catorze chances de um ficar por escalar, e um casco
com a proa de um porte e a popa de outro não dá erro nenhum.

**E nenhum deles enferruja, nem o maior.** A conta que isentou o pesqueiro em
07/09 era de tamanho (67px contra 97) e o arrasteiro tem 82 — perto o suficiente
para a pergunta voltar. A resposta continua a ser não, e agora por outra razão:
ferrugem em UM dos três leria como marca de porte, e o que separa estes três é a
gramática. Quem enferruja é a classe de carga, inteira.

## 5. O que a construção corrigiu de caminho, e não estava no pedido

Ambos foram vistos **olhando o render ampliado**, e ambos são lições que este
repositório já tinha escrito noutro prop.

**A popa do arrasteiro nasceu no fundo da imagem.** Nesta câmera o `-x` é o
fundo, e a primeira versão pôs lá o arrasto inteiro: o tambor saiu invisível e o
pórtico leu como uma parede. A ordem certa é a que a traineira já usava sem o
dizer — a cabine recua para `-x` e o que se quer VER avança para `+x`. Aqui isso
põe a casa do leme à frente e o convés de trabalho atrás dela, que é a planta de
um arrasteiro de popa: a leitura e a verdade do barco calharam do mesmo lado.

**O pau-de-carga da traineira lia como uma CRUZ.** A lição está escrita no
`deck_geral` dos cargueiros desde 07/09 — *erguido no plano do mastro ele
projeta-se como dois traços a cortar a vertical, que é o desenho de uma antena e
não o de um guindaste* — e ao pesqueiro nunca chegou, porque ninguém voltou a
olhar para o prop depois de o fazer. Girado 38° para `-y`, ele sai por cima da
amurada como quem iça o cesto do peixe.

**E a amurada da traineira era branca com a cabine também branca**, duas peças
de `cabine` encostadas: a lição do `pilha_caixotes` outra vez, e a razão de o
barco inteiro ler como uma mancha clara. As três amuradas são hoje vermelha,
azul e amarela; o verde do fundo é o que os três partilham.

Isto quebra a promessa que a primeira versão deste desenho fazia — *"a traineira
é o barco de sempre, sem uma linha mexida"* —, e quebra-a de propósito: manter um
defeito medido por causa de um comentário escrito na mesma sessão seria pôr a
prosa à frente do desenho.

## 6. O que NÃO se fez, e por quê

**Nenhum porte novo nas classes de carga.** O cargueiro e o navio de longo curso
separam-se pelo CONVÉS, que é a decisão `010`, e dar-lhes portes seria multiplicar
seis cascos por três. A tabela suporta-o — a folha de um elemento é a mesma
folha —, e o dia em que se quiser é escrever a lista.

**Nenhum barco de pesca no mapa como cenário.** A Zona de Espera passou a mostrar
DOIS portes diferentes em vez do mesmo casco duas vezes, mas continua a ser
visual, e torná-la mecânica muda o balanceamento medido.

**Nenhuma fala nova.** O motivo já se lê no cartão da doca desde `008`; o porte
lê-se no valor ao lado dele.

## 7. O que passou a ser verificável

Seis asserções novas, cada uma provada com **defeito injetado**, com a base
conferida limpa entre cada e o código de saída lido de arquivo — nunca do fim de
um cano.

- **D17 · forma** — toda folha da tabela é um `Array` não vazio. *(defeito:
  textura solta no lugar da lista)*
- **D17 · sem repetição dentro da folha** — dois portes a apontar para o mesmo
  PNG são uma faixa de valor que existe na tabela e não existe na tela. *(defeito:
  o bote escrito duas vezes)*
- **D17 · alcançabilidade** — percorrendo a faixa de valor da classe inteira
  pelo `arte_do_barco()`, que é a porta que o jogo usa, **todos** os portes têm
  de sair. Um porte inalcançável é o `barco_medio` num eixo novo, e não daria
  erro nenhum: daria uma linha a mais numa lista. *(defeito: divisor com
  `portes - 1`)*
- **D17 · ordem** — o porte nunca decresce quando o valor cresce. Não é implicada
  pela anterior: uma conta pode alcançar os três portes e devolvê-los ao
  contrário, cumprindo a alcançabilidade e invertendo o sentido. *(defeito: o
  índice espelhado)*
- **D17 · partilha total ou nenhuma** — reescrita para comparar a FOLHA inteira
  em vez de um casco. *(defeito: `medio/granel` a apontar para a folha do
  `medio/armazenagem`)*
- **`folha_frota.gd` · transbordo** — a folha é uma captura de 720×1280 e cresce
  sozinha a cada porte, motivo ou classe nova. Uma folha cortada é pior do que
  nenhuma: ela existe para provar que a arte que o sorteio esconde chega a
  alguém, e o que cai abaixo da linha 1280 fica exatamente como estava. *(defeito:
  um quarto porte; ela pediu 1.394px e reprovou)*

⚠️ **O defeito da repetição fez disparar DUAS guardas**, e é esperado: com dois
portes no mesmo arquivo o `find()` colapsa-os e a alcançabilidade cai junto. A
guarda sob teste — a da repetição — foi a primeira da lista, e é ela que nomeia
o problema.

## 8. E uma foto que faltava há três sessões

Das oito imagens do CI, **nenhuma mostrava o porto em ruínas a trabalhar**. O
`inicio` é o turno ZERO, com as docas ainda a dizer "aguardando barco"; o `meio`,
o `porto` e as `docas` são portos de nível 2 e 3, que por `009` recebem
cargueiro. Os três cascos de pesca chegariam à tela do jogador no primeiro dia e
a foto nenhuma — e o porto em ruínas é onde o perfil Descuidado passa a partida
inteira.

O tiro `pesca` são seis turnos com os trabalhadores alocados: barco na doca, e
os dois ancorados da Zona de Espera atrás dele. Na primeira corrida ela aparece
como **novo** na tabela do `captura.yml`, porque o antes é tirado pelo script da
base — está escrito no cabeçalho do `capturar_evidencia.sh` e é o esperado.
