# 052 — A mão é a direita, e o cruzamento separa-se no tempo

**23/09/2026 · opção (d) do briefing de 23/09h, "o retorno a entrar nos
berços", escolhida pelo Bruno — e, perguntado, a mão direita**

## O que se decidiu

**Os camiões andam pela DIREITA na tela, como no Brasil.** A ida (que desce)
passou para a faixa do lado da vila, e o retorno (que sobe) para a do lado da
água. Os cotovelos não mudaram: eram eles que já estavam na mão direita.

**O retorno passou a encostar nos berços**, com a carga do navio que lá está.
Com a mão direita é ele que tem a faixa encostada aos acessos: vira à direita e
não atravessa nada. Quem atravessa agora é a ida, e por isso é ela que cede.

**O cruzamento tem quatro regras, e nenhuma pára um camião na rua:**

| Regra | Onde | O que faz |
|---|---|---|
| a **trava do berço** | `_ocupante_do_berco` | um camião por berço, desde o compromisso (ainda na rua) até voltar à faixa |
| a **cedência na boca** | `_boca_livre()` | nenhum camião, nas duas faixas, chega à boca antes de a manobra acabar e sobrar `ESPACO_NA_FAIXA`; quem não pode entrar SEGUE e tenta na volta seguinte |
| a **previsão das curvas** | `_curvas_livres()` | quem entra na rua sabe a que horas passa cada curva, e só entra se nenhuma dessas passagens cair a menos de `JANELA_DA_CURVA` da de um camião do outro sentido |
| o **arranque espaçado** | `_arranque_livre()` | ninguém começa a rota a menos de `ESPACO_NA_FAIXA` de outro |

Quem espera espera fora da rua: no arranque (fora do quadro) ou no fundo do
acesso, a sair de ré. À mesma velocidade, dois camiões na mesma faixa nunca
encurtam a distância, logo basta guardar as ENTRADAS numa faixa.

## Por que — medido antes de mexer

Uma régua nova (a pegada de cada camião, medida pelo nó a cada frame, contra a
dos outros quatro) em cinco corridas de meia hora de jogo:

| Antes | Onde | Quantas |
|---|---|---|
| ida × retorno | os DEZ pontos em que as rotas se cruzavam, dois por cotovelo | **27 a 72** por meia hora, à vista, até 0,76 de fundo |
| ida × ida na boca | a ré largava o berço por cima de quem passava | 1 a 3 |
| ida × ida em comboio | depois disso seguiam colados, com o mesmo período, a roçar em cada cotovelo | até 7 |

⚠️ **A `047` afirmava que as duas rotas "nunca se cruzam, nem na reta nem na
curva".** Era falso, e nada o perguntava: o §7 do D13 conferia cada rota contra
o asfalto, e não uma contra a outra.

⚠️ **E A MÃO ESTAVA TROCADA, por um espelho.** Os comentários diziam que "quem
segue em `+my` tem a água à direita". Com `mx` e `my` lidos como o `x` e o `y`
de um caderno, tem; mas `tela_da_rota()` espelha o chão — `+my` é para baixo e
para a esquerda —, e na tela quem desce tem a VILA à direita. As retas estavam
na mão inglesa e os cotovelos, escritos com a regra ao contrário, na brasileira:
é por isso que as rotas se cruzavam em cada curva. A foto confirmou-o antes de
qualquer mudança.

## A curva aberta em diagonal, e porque não há saída só pela geometria

Com as faixas concêntricas, cada rota faz em cada cotovelo uma curva **fechada**
(rente à quina reentrante) e uma **aberta** (à volta da quina saliente). A
saliente é a que o gerador chanfra em meia rua (`013`), e o vértice da curva
aberta cai **exatamente** na linha do chanfro (0,45 de cada borda). O **D20**
apanhou-o (33 px de calçada na janela), e a foto mostrou o camião com a cabine
em cima do relvado.

A curva aberta corta então a quina por uma diagonal paralela ao chanfro, a meia
faixa dele (`corte_da_curva()`, 0,636), com a silhueta a trocar a meio. A
invasão da carroçaria desce de 0,66 para 0,21 — do tamanho da que qualquer
curva já tinha (0,25 do porta-contêiner desde 07/09).

**Só que a diagonal aproxima a curva aberta de uma rota da fechada da outra**, e
uma busca mostrou que não há geometria que resolva: a sobreposição no pior
instante vale `(aberta − fechada)/2 + 0,028`, e cortar a fechada para dentro
afasta-as. Mas o centro do caminho tem de ficar longe das calçadas — pedi 0,3,
que é a ordem da janela do D20 —, e isso limita a fechada a 0,48 e obriga a
aberta a pelo menos 0,42, quando a sobreposição (com 0,03 de folga) pede a
fechada 0,12 acima da aberta. **Nenhuma das 4.941 combinações** (os dois
cortes, e o ponto da diagonal onde troca a silhueta) passou as três
restrições. Daí a previsão das curvas: medido amostrando os dois caminhos, os
dois porta-contêineres só se tocam com menos de 1,53 unidades de desfasamento
(1,35 s), e a janela é 2,0.

⚠️ **E A PRIMEIRA PASSAGEM NÃO PASSA PELO ARRANQUE.** O `CaminhaoRetorno1`
nascia em (8,55; 17,00), e com a mão direita virava junto com o `Caminhao1` aos
cinco segundos de jogo, em todas as partidas. Passou a (4,55; 13,00), longe dos
camiões da ida na mesma altura.

## Depois

As mesmas cinco corridas: **zero sobreposições à vista**. A ida encosta 13 a
24 vezes por meia hora e o retorno 31 a 43; antes só a ida encostava, 42 a 53.
O berço é servido tanto quanto antes, pelos dois sentidos. As voltas completas
da ida mantêm-se (69–76 contra 59–73); as do retorno descem um pouco (40–46
contra 50), porque ele agora pára nos berços.

Sem arte nova e sem constante de `# TUNING:`: só o `Main.gd`, a `Main.tscn`
(as cinco origens) e os testes. O gerador ganhou só comentário, e os quatro
mapas saem byte a byte iguais. A suíte de design passou de 3 s a 9 s.

A bateria de captura (30 tiros, `COBERTURA OK`) comparada pixel a pixel com a
da `main`, com o mesmo arquivo dos dois lados a dar zero exato: **mudam 14** —
todas as fotos de jogo com o mapa à vista, entre 5 e 10 mil pixels cada — e
**ficam iguais 16**: as folhas de contato (não há arte nova) e os painéis sem
mapa. Na foto `docas` um pescado da ida e um armazenagem do retorno cruzam-se
no cotovelo 1, em faixas paralelas a 0,9 uma da outra; o da frente tapa parte
do de trás, que é o que dois camiões a passar fazem em isométrico.

## As guardas, e os mutantes que as provaram

- **D13 §6c**: a `entrada` publicada cai num reto do RETORNO, e a `virada` da
  ida num reto da IDA, à mesma altura.
- **D13 §7a** passou às frações da mão direita; **§7g** pergunta a mão à
  PROJEÇÃO (o desvio da faixa, projetado, contra a direita do sentido
  projetado); **§7h** exige que os caminhos desenhados não se cruzem; **§7i**
  confere o `RUA_LARG` e o chanfro que o `Main.gd` repete.
- **D20** amostra o caminho DESENHADO (`trechos_de()`), e não a escada.
- **A saída de ré** cobre também o retorno, e exige a marca `_saindo_do_berco`.
- **D35**: anda uma hora de jogo com as docas a receber e largar barcos (zero
  sobreposições à vista, os dois sentidos encostam, a carga casa, todos
  chegam ao fim da rota); varre 4 × 770 posições da pergunta de entrar na rua
  contra uma simulação feita pelo teste; dois arranques seguidos; e as
  primeiras passagens.

| mutante | o que reprovou |
|---|---|
| M1a a ida entra sem ceder | o andar do D35 (3 vezes) |
| M1b a ré sai sem ceder | o andar (22) e a varredura |
| M1c o retorno entra sem ceder | **nada** — ver abaixo |
| M2 sem a previsão das curvas | a varredura (as duas asserções) e o andar (1 vez) |
| M3 arranque sem espaço | o andar (842) e os arranques seguidos |
| M4 sem a trava do berço | o andar (138), e a bandeira do D35 |
| M5 o retorno nunca encosta | «o retorno também (0 vezes)» |
| M6 a carga não casa | «quem encosta leva a carga do navio» |
| M7 sem o corte da curva | o D20, nos dois mapas |
| M8 mão esquerda coerente, com as frações do §a trocadas junto | o **§7g** — e, por nada mais se ter movido, as origens, os acessos, o D20 e o D35; o §a, calado |
| M9 corte grande demais | o §7h, o andar, as primeiras passagens e a varredura |
| M10 a origem antiga, com a ordem do nó acertada | só as primeiras passagens |
| M11 a ré não se marca | a marca da saída de ré |
| M11b a marca do retorno nunca se apaga | a saída de ré do retorno |
| M12a/b a corrida do arranque | os arranques seguidos (e o andar, no retorno) |
| M13 a ré do retorno de frente | a saída de ré do retorno |

Base verde conferida entre cada um; originais guardados por `cp`; cada mutante
só contou depois de o script confirmar que casou uma vez.

⚠️ **O que fica sem guarda, e porquê.** O retorno a entrar pergunta pela boca,
mas vira à direita a partir da faixa encostada aos acessos: o único risco é o
porta-contêiner meter 0,028 da traseira na faixa ao lado durante um instante.
A regra fica (é conservadora e custa nada), e nada a apanha. E a régua é um
retângulo por camião, pivô no centro: ela diz se as PEGADAS se tocam, não o
que o olho vê numa curva.

## As armadilhas, e onde ficaram escritas

- **O arranque é uma pergunta e uma ação**, e a ação era do tween, no passo
  seguinte: dois camiões que perguntassem no mesmo passo saíam juntos. Nenhuma
  agenda o provocava; um mutante de OUTRA regra, que só mexia no tempo, é que o
  expôs. Hoje o camião ocupa a ponta no próprio instante.
- **A suíte nunca deixa passar um frame, e por isso nenhum tween sai da lista**:
  o D35 levava 62 s a uma suíte de 3, com 983 tweens e `Array.has()` a cada
  passo. Um `Dictionary` resolve.
- **Um erro de execução no sub-bloco passou com a bandeira do bloco a verde**,
  porque ela estava no chamador. O sub-bloco tem a sua.
- **A varredura escreve ela própria a marca de saída** para pôr o retorno a meio
  da ré: prova que a previsão a LÊ, não que o jogo a ESCREVE. O M11 passou até
  a outra ponta ser guardada.
- **O `getbbox()` do Pillow num RGBA só olha para o alfa**: a primeira
  comparação das fotos disse que nenhuma mudara. Os `md5` diferiam.
