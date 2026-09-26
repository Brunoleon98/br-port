# 066 — A família do sistema: tela inicial, três espaços de save e a pausa curta

**26/09/2026 · terceira família da frente 3 do A5**: o sistema. O Bruno
escolheu esta família entre as que restavam (a outra são as telas de texto:
diário, mensagens e nomes) e respondeu duas rodadas de perguntas antes do
desenho. **Vereditos: «Continue» na primeira, aceite na segunda («siga para
o celular»)**; a terceira, o celular, está no fim deste arquivo e espera o
dele.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A tela para onde «salvar e sair» leva | **Cena própria, ilustrada** — não o porto vivo por trás |
| O «Novo jogo (apaga progresso)» da pausa | **«Salvar as partidas em diferentes espaços, que nem é feito em outros jogos»** (no campo livre) |
| A forma da pausa | **Pausa curta + tela Ajustes** |
| O celular | as quatro: **moldura de aparelho, barra de status de verdade, papel de parede, ícones com cor própria** (reabre a `021` no cadeado único) |
| A técnica da ilustração | **gerador de imagem, pelo `art_lab/`** |
| Quantos espaços | **3** |
| Os botões da tela inicial | **Continuar, Nova partida, Carregar, Ajustes** |
| O papel de parede | **a ilustração da tela inicial** — uma peça, dois usos |

Três passagens, e esta é a primeira: **espaços, tela inicial, pausa e
Ajustes**, com um fundo provisório. A segunda é a ilustração (do Bruno, pelo
briefing em `art_lab/tela_inicial/BRIEFING.md`); a terceira, o celular.

## O que se decidiu

**Os espaços** (`GameState`):

- **O espaço 1 é o `savegame.json` de sempre**; o 2 e o 3 são
  `savegame_2.json` e `savegame_3.json`. A partida que o jogador já tinha
  aparece no espaço 1 sem migração nenhuma, e o **`SAVE_VERSION` fica em 9**:
  a forma do save não mudou, só o número de arquivos. Mover o arquivo para um
  nome novo seria código que corre uma vez no aparelho de cada um.
- **Ler não é carregar.** `resumo_do_espaco()` lê o arquivo sem tocar no
  estado vivo nem no disco. As recusas do `load_game()` passaram para uma
  função que só LÊ (`_save_aceite`), e os dois a usam: um resumo que aceitasse
  o que a carga recusa mostraria um porto que, tocado, abre partida nova. O
  `load_game()` continua a apagar o que recusa; o resumo lê-o como livre, e
  quem o apaga é a partida nova que ocupar o espaço.
- **O porto sem nome é livre.** O `new_game()` grava antes da tela dos nomes,
  e uma «Nova partida» abandonada deixa um dia 1 sem lance nenhum no disco.
- **O jogado por último é a hora do arquivo**, e não um carimbo no JSON, que
  mudaria a forma e subiria a versão — descartando outra vez a partida do
  Bruno, um dia depois da `065`. Todo lance grava, e um segundo de resolução
  chega para «qual jogou por último».
- **O arranque abre o espaço mais recente**, e sem nenhum ocupado, o 1.

**A tela inicial** (`scenes/TelaInicial.tscn`, agora a cena principal):

- **É uma cena e não uma fase do `GameState`**: o simulador nunca abre cena,
  e o balanceamento não a vê — a regra «tela nova é overlay» cumprida do lado
  de fora do porto.
- O cartão dos botões é o **cartão branco do tema**, no pé da tela: é o
  vocabulário das duas famílias e o único fundo conhecido por baixo das letras.
  «Continuar» é o `BotaoPrimario`, com a linha «Última partida: …» por cima.
- **Nova partida sem porto guardado não pergunta onde** — vai para o espaço 1.
  Com algum ocupado, abre os espaços.
- **Não há «Sair do jogo»**: no Android a regra do sistema é o Voltar fechar a
  aplicação, e é o que o Voltar faz aqui (com um painel aberto, fecha-o).
- O nome do jogo é um `Label` com contorno navy (`LogoInicial`), sobre o fundo
  **provisório**: um degradê de céu e mar, sem desenho, que não finge ser a
  arte.

**Os espaços na tela** (`PainelEspacos`): um painel, dois modos e três tempos.
No «carregar», o espaço livre não é botão. Na «nova», o ocupado diz
«Substituir» e **não apaga nada**: leva a um terceiro tempo com o porto que se
vai apagar numa tarja do tom ruim e «Apagar e começar». É a única decisão sem
volta da família, e pede o segundo toque.

**A pausa** tem três botões — Continuar (âmbar), Ajustes, Salvar e sair — e a
linha «Cais · dia N de 32 · espaço N de 3»; com a partida acabada, volta o
«Ver o balanço». **Salvar e sair** grava mais uma vez, **desarma o gravador de
partida** e troca a cena: na tela inicial, «Nova partida» e «Carregar» mexem no
estado, e o `Registro` ainda armado escrevia isso no arquivo da partida
deixada. O caminho fica, e a Ajustes da tela inicial copia a última partida.

**A tela Ajustes** tem o volume e o «Copiar registro da partida» que viviam na
pausa, e é UMA tela para as duas portas. O ícone é uma engrenagem nova
(`ajustes.svg`), no desenho do `pausar`.

## As guardas

**F16 do `teste_fumaca`**: o espaço 1 no arquivo de sempre e três arquivos
distintos; cada espaço carrega o seu porto; começar no 3 deixa o 1 e o 2; o
porto sem nome, o de outra versão e o que a carga recusa (sem docas) leem-se
livres, e ler não apaga nem mexe no estado vivo; o mais recente muda com quem
grava (duas esperas de 1,1 s, porque a hora tem um segundo de resolução); a
tela inicial mostra o jogado por último, e não o espaço em uso; a pausa tem as
três saídas e nenhuma destrutiva; «Substituir» não escolhe nada e o porto
continua no disco até ao segundo toque; e o `Main` desarma o gravador ao sair,
com um dia jogado depois a não entrar no registro deixado.

**Catorze defeitos injetados, catorze reprovações pela guarda certa**, com o
original guardado por `cp` e a base verde entre cada um: o espaço 1 com nome
novo (1), o caminho que não acompanha o espaço (8), o `clear_save()` antes de
apontar (7), ler apagando o que recusa (1), o resumo só com a versão (1), o
sem-nome como ocupado (1), o mais recente como o primeiro (1), a tela pelo
espaço em uso (1), «Salvar e sair» ligado ao balanço (1), «Substituir» sem
confirmar (1), o livre como botão ao carregar (1), o `desarmar()` vazio (2), o
«Novo jogo» de volta à pausa (1) e o `Main` sem desarmar (1).

**E uma guarda que não mordia**: com o `desarmar()` vazio, «a partida nova não
escreve no registro deixado» passou verde — aquele `new_game()` não calhou de
emitir nada que o gravador grave. Passou a jogar um dia depois de sair, que
grava sempre, e o mesmo defeito reprova as duas linhas.

**O D33 mede as telas novas**: a Ajustes, os espaços na partida nova e a tela
inicial. O nome do jogo fica **fora, declarado**: é texto sobre ilustração, e
a régua só conhece fundos de stylebox. Um campo novo no percurso (`fora`)
tira o nó com o motivo escrito, e **reprova se o nó sumir**. Dois defeitos: o
nó renomeado reprova pela declaração velha, e o `fora` retirado volta a dar
pendência.

**F2b, e ele nasceu de um defeito desta passagem.** O «Carregar partida»
saiu com o ícone `doca` — traço `#f0f6ff`, a cor exata do selo do cabeçalho
— e a foto mostrou um quadrado vazio; nenhuma suíte o via. Era a segunda vez
do mesmo ícone num fundo claro. O cabeçalho passou ao `barco` (o do painel das
Docas), e o bloco novo lê cada ícone que um script passa a um cabeçalho
(parênteses equilibrados, o ternário do fim de fase incluído) e exige a
MEDIANA dos pixels opacos acima de **1,3:1** contra o selo. Medida a banda nos
24 ícones: o `doca` dá 1,00 e os mais fracos que um cabeçalho usa, o âmbar do
`recomecar` e o do `vitoria`, 1,63 — o corte fica no meio, 1,3× e 1,25× de
folga. Ele não diz que o âmbar se lê bem (separa-se pelo matiz, que a régua
não vê); diz que o ícone não é da cor do fundo. **Dois defeitos**: o `doca` de
volta (reprova com 1,00) e um ícone passado por variável, que a guarda não
teria como ler — reprova por não nomear `Icones.X`. O reencaminhamento do
próprio andaime fica de fora, com o motivo escrito: quem escolhe o ícone é
quem chama.

**A bateria** ganhou cinco tiros — a tela inicial, os três tempos dos espaços
e a Ajustes —, montados pela ferramenta: `espacos=` joga cada partida até ao
dia dela, e as duas ferramentas partem do espaço 1 com os outros vazios (a
pausa diz o espaço, e o número sairia da ordem dos tiros). O `capturar_cena`
passou a ver o painel que um toque abre, e o `conferir_cobertura_paineis.py`
lê o `_abrir_painel` do `Main` e da tela inicial. A sentinela do CI planta
também os espaços 2 e 3.

## Medido

- Contra a `main`, mudaram **2 das 36 fotos**: a pausa e a folha de ícones (a
  engrenagem nova). As outras 34 saíram iguais em RGB, e entraram **5 novas**
  (a tela inicial, os três tempos dos espaços e a Ajustes).
- Seis suítes verdes, `ESCOPO UI OK`, `GUARDAS OK`, `COBERTURA OK`, `TABELA
  OK` (a `ESPACOS` é uma `const` nova do `GameState`); contraste: **430 textos
  em 28 estados**, nenhum abaixo do AA.
- A sentinela do jogador fica intacta com os cinco arquivos, e reprova quando
  se reescreve o `savegame_2.json` no lugar do jogador — o controle positivo.
- O simulador com 600 partidas dá os mesmos **100% / 80,2% / 37,3%**, com a
  mediana do Mediano em R$716.179: a tela inicial é uma cena, e o simulador
  não abre cena nenhuma.

## O que ficou de fora

- **O celular** — a terceira passagem.
- **A ilustração** — é do Bruno, pelo briefing; até lá, o degradê.
- **O contraste do nome do jogo** mede-se no pixel quando a ilustração
  existir; hoje é o contorno que o garante, e a foto.
- **Apagar um espaço** sem ocupar outro: substituir cobre o caso, com três.
- **A hora da última partida** no cartão do espaço: tornava cada foto
  diferente da anterior, e o dia e o dinheiro já reconhecem o porto.
- O «Jogar de novo» do fim de partida escreve no registro velho uma linha do
  `new_game()` antes de o `Main` voltar a armar — é anterior a esta família.
- O Voltar do Android na tela inicial não foi experimentado num aparelho.

## A segunda passagem: os botões dizem o que fazem, e a arte tem pedido

**Veredito do Bruno sobre a primeira: «Continue»**, com três pontos marcados —
o «Continuar» com letra pequena, o «Apagar» igual ao «Voltar», o nome do jogo
só em texto — e um escrito: *«pode melhorar a tela de fundo, por exemplo, com
um navio chegando num porto e uma paisagem brasileira de fundo»*.

O fundo e o logotipo são ARTE, e a técnica é escolha dele (`CLAUDE.md`,
Arte): perguntou-se antes de produzir, e as duas peças são **dele, no
ChatGPT**. O `art_lab/tela_inicial/BRIEFING.md` passou a ter as duas — o fundo
com o navio chegando, os morros de mata atlântica, os coqueiros e a praia, e
o logotipo em PNG com transparência, com a faixa da tela que ocupa e o aviso
de conferir as letras —, e um pedido pronto a colar para cada uma.

O tema desta passagem é o que se faz aqui, **os dois botões**:

- **«Continuar» a 19 px**, a letra do «AVANÇAR DIA» do porto, pela variação
  `BotaoPrimarioGrande`, que é uma variação do `BotaoPrimario` e só muda o
  tamanho — as cores e as caixas continuam num sítio só.
- **«Apagar e começar» vermelho** (`BotaoPerigo`): o vermelho do tom ruim das
  tarjas, que já quer dizer «perde-se aqui», com texto branco a 5,58:1 (4,72
  no hover).

**E o D33 passou a medir a confirmação**, que é o único botão vermelho do jogo
e vivia fora do percurso: um painel de vários tempos só chega ao segundo pelo
toque. O caso declara os espaços ocupados (`espacos`), o botão a tocar
(`tocar`, um só) e o tempo onde tem de parar (`tempo`), e a régua PROVA que
parou lá. O percurso parte do espaço 1 com os outros vazios, pela razão das
ferramentas de captura. **Dois defeitos**: o toque que não dispara reprova
pelo tempo («pediu confirmar e está em nova»), e o vermelho trocado por um
rosa claro reprova o «Apagar» a 1,32:1 — prova de que é medido.

Mudaram **as 5 fotos da tela inicial** contra a primeira passagem (o
«Continuar» aparece por trás de cada painel dela) e nenhuma outra; contra a
`main` continuam a ser a pausa e a folha de ícones, mais as cinco novas. Seis
suítes verdes, `ESCOPO UI OK`, `COBERTURA OK`; contraste **435 textos em 29
estados**, nenhum abaixo do AA.

## A terceira passagem: o celular

**Veredito do Bruno sobre a segunda: aceite, «siga para o celular».** As
quatro coisas que ele marcou no escopo, e cada uma com o que a sustenta:

- **A moldura.** O corpo passou de 26 a **44** de canto e a moldura a 12; a
  câmera é um entalhe no meio da barra de status; há uma barra de gesto no pé
  da tela e três botões laterais a sair do corpo (ligar à direita, volume à
  esquerda), desenhados ANTES dele para o corpo tapar a metade de dentro. O
  **«Guardar o telefone» saiu do aparelho** e ficou por baixo dele: um botão
  do jogo dentro do telefone era o que desfazia a metáfora.
- **A barra de status.** A hora é a **do aparelho**, e anda enquanto o
  telefone está aberto; sob ferramenta é **09:41**, fixa — a bateria compara
  fotos, e a hora de verdade mudaria cada uma. **O sinal e a bateria são
  desenho, e isto está escrito**: sondado, o Godot 4 não lê a bateria nem o
  sinal (`OS` e `DisplayServer` sem `get_power_*`). O dia do jogo, que vivia
  na barra, passou para um **widget** com o número grande, como a data na tela
  de início de um telefone.
- **O papel de parede** é a MESMA constante do fundo da tela inicial
  (`TelaInicial.FUNDO`): quando a ilustração chegar, muda uma linha e mudam os
  dois. A tela recorta os filhos pelo próprio desenho (`clip_children`), e é o
  canto de 32 dela que arredonda a imagem.
- **Os ícones com cor própria** reabrem a `021`, que tinha UM cadeado para
  todas as portas fechadas: cinco ícones novos (`app_*.svg`), cada um um
  quadrado de cor cheia com o desenho branco, a 144 px porque ocupam o tile
  inteiro. Os fechados mostram, sob um véu do corpo a 62%, o que vão ser, com o
  cadeado como selo num canto; o aviso do pé passou a dizer «os apps com
  cadeado abrem na Fase 2».

**Todo texto do celular vive numa peça opaca** — a barra, o widget, a pílula
de cada nome, o cartão do aviso —, e não sobre a imagem: texto sobre uma
ilustração é composição que a régua não sabe fechar.

**E a régua não sabia que não sabia.** O D23 media os rótulos contra a cor da
TELA, que com o papel de parede passou a ser um fundo que o texto não tem — um
espelho sempre verde. Passou a usar o motor do D33, que acha o fundo de cada
texto; e a parte da grelha passou a descontar a margem do miolo, sem a qual
dava 28 px de folga que não existem. **O mutante que tirava a pílula a um nome
PASSOU nas duas**: o motor subia até ao fundo opaco da tela e não via a imagem
desenhada por cima dele. Hoje um `TextureRect` irmão por trás do texto, num
contentor que empilha ou ancorado ao pai inteiro, dá pendência — e o mesmo
mutante reprova no D23 e no D33. A margem do miolo alargada reprova a grelha.

Mudaram **2 fotos** contra a segunda passagem — o menu e a folha de ícones,
que passou a 31 ícones e cabe, pela conta dela, com 64 px de sobra. Contra a
`main` são o menu, a pausa e a folha, mais as cinco novas. Seis suítes
verdes, `ESCOPO UI OK`, `COBERTURA OK`; contraste **436 textos em 29
estados**, nenhum abaixo do AA e nenhum sobre a imagem.


## A quarta passagem: o celular, com os cinco reparos

**Veredito do Bruno sobre a terceira: «continue no celular»**, com cinco
reparos marcados — e cada um com o que se fez:

- **«Melhore os ícones dos aplicativos».** Os cinco `app_*.svg` ganharam um
  degradê vertical da própria cor e um desenho com mais do que uma silhueta:
  o diário é um livro aberto com linhas e a fita; a cidade, o casario de telha
  com a igreja ao meio; as lojas, uma fachada escura com as montras acesas e o
  toldo listrado de bicos (a primeira versão, de bicos para cima, lia-se como
  um castelo, e foi refeita na foto); as missões, uma prancheta com a lista
  marcada; a análise, as barras com a seta de alta. Um brilho de 1 px no topo
  saía por fora do canto arredondado e ficou uma linha cinzenta por cima de
  cada tile — tirado, visto na foto a 1080.
- **«Barra de status escura».** A barra perdeu o fundo (`StyleBoxEmpty`) e a
  hora pousa no papel de parede, como num telefone. **A leitura passou para o
  CONTORNO**: a hora é branca com contorno navy (`TextoCelularStatus`), e os
  ícones do sinal e da bateria levam o contorno desenhado.
- **«Fechados apagados demais».** O véu desceu de 62% para **30%**, e o nome
  dos fechados passou ao claro dos abertos — o cinzento somava-se ao véu e ao
  cadeado a dizer a mesma coisa. Quem diz «fechado» passou a ser o selo.
- **«Cadeado pequeno demais».** O cadeado saiu de dentro do véu, a 22 px,
  para um **selo de 32** num anel creme (`AppSelo`), a sair 8 px para a
  direita do canto — onde a grelha tem 30 de vão — e só 3 para baixo, onde o
  nome está a 6. O aviso do pé usa o mesmo selo: o disco navy do cadeado
  sozinho sumia na placa, navy também.
- **«Widget do dia parece campo».** Um retângulo contornado com duas linhas
  encostadas à esquerda é a forma de uma caixa de texto. O widget perdeu o fio
  e ficou com o canto de 22, mais claro do que a tela, e passou a ter
  hierarquia: «SEMANA 2 DE 4» pequeno em âmbar, «Dia 9» grande com «de 32» na
  linha de base, e a **fita dos dias** — um traço por dia da partida,
  agrupados por semana, derivada de `TURNS_PER_WEEK` e `WEEKS_TOTAL`: o vivido
  em âmbar, o de hoje claro, o que falta apagado.

**A régua aprendeu a ler um contorno** (`contraste_ui.gd`, `CONTORNO_MIN`).
Texto sobre imagem dava pendência, e certa. Com um contorno OPACO de pelo
menos 4 px a letra fica rodeada da cor dele sobre qualquer pixel, e o par que
o olho lê é letra contra contorno — é assim que a hora se mede (16,21:1). O
nome da tela inicial, que era `fora` declarado desde a primeira passagem,
passou a medir-se pela mesma regra (17,60:1): **uma exclusão virou uma
medição**, e tirar-lhe o contorno reprova, o que a exclusão não fazia. A
subida pelos antepassados passou também através de um `StyleBoxEmpty`, que não
desenha nada — sem isso a pendência da barra nomeava o stylebox, e a causa é a
imagem.

⚠️ **E OS DOIS LIMIARES DA REGRA SÓ SE PROVAM NUM ESTADO QUE O JOGO NÃO
MONTA.** O jogo tem dois textos contornados, e os dois passam os limiares: a
fixture realista é a que não prova nada. Os cinco controles novos do D33
montam a mesma letra sobre a mesma imagem e mudam uma coisa no contorno — sem
ele, um px abaixo do mínimo, translúcido, da cor da letra, e no mínimo. Sete
defeitos injetados, todos reprovados, com a base verde entre eles: **apagar o
limiar da largura e o da opacidade (C1, C2) reprovou SÓ nesses controles**;
desligar a regra (C3) reprovou os controles, o D23 e o D33; tirar o contorno à
hora (C4), ao nome (C5), torná-lo translúcido (C7) ou da cor da letra (C6)
reprovou o D23 e o D33, ou o D33 sozinho no caso do nome.

⚠️ **E A COR DE APOIO NÃO ATRAVESSOU PARA A PLACA.** O «de 32» nasceu na cor
neutra do jogo, que media 5,05:1 na tela; na placa do widget, mais clara, deu
**4,44:1** e o D23 reprovou-a. Subiu para 0.6/0.68/0.78, que mede 5,70:1 ali.

O topo do papel de parede provisório é navy (15, 29, 44 no pixel) e o
contorno também (13, 26, 38): **nesta foto o contorno não trabalha**, e a
prova de que ele segura a hora sobre um céu claro é a foto com a ilustração.

Mudaram **2 fotos** contra a terceira passagem — o menu e a folha de ícones —
e as outras 39 são iguais pixel a pixel. Seis suítes verdes, `ESCOPO UI
OK`, `GUARDAS OK`, `COBERTURA OK`; contraste **438 textos em 29 estados**
(mais o «de 32» e o nome da tela inicial, que deixou de estar fora), nenhum
abaixo do AA.

**Veredito do Bruno sobre a quarta: «aceito, feche a família».** A família do
sistema da frente 3 fechou com quatro passagens. O fundo da tela inicial e o
logotipo continuam com ele, no ChatGPT, pelo `art_lab/tela_inicial/BRIEFING.md`
— e a integração troca uma constante (`TelaInicial.FUNDO`) e muda os dois usos.
