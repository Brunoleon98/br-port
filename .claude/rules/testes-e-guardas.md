---
paths:
  - "brport_vs/tests/**"
  - "brport_vs/scripts/validation/**"
  - "tools/conferir_*.py"
  - "tools/mutantes.toml"
  - "tools/medir_*.py"
  - "brport_vs/tools/medir_*.gd"
  - "brport_vs/tools/sonda_mensagens.gd"
  - ".github/workflows/**"
---

# Regras — testes e guardas

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## O defeito injetado fica no catálogo (`117`)

**O defeito que provou uma guarda entra em `tools/mutantes.toml`**, e não
num `cp` que se desfaz: até 15/10 cada um corria uma vez e ficava em prosa,
e nada voltava a perguntar se a guarda ainda o apanhava. Quem o corre é
`tools/conferir_mutantes.py`, que faz sozinho o que as lições abaixo mandam
fazer à mão — base verde antes e depois, o original por bytes, a guarda
DECLARADA a reprovar, o mutante que não compila recusado, teto por corrida
— e o CI reinjeta o catálogo inteiro a cada PR (job «Defeitos já provados»),
em três fatias de quatro cópias, que um job final exige somarem o catálogo
(`137`). Aqui: `--trabalhadores 4`, ~30 min (191 em 24/10).

- **Guarda nova:** escreva o `[[mutante]]` sem `reprova`, rode
  `--explorar --so <id> --suites <a suíte>`, e declare a asserção que É a
  guarda nova — não a primeira que reprovou. Depois `--so <id>` sem
  `--explorar` espera `MUTANTES OK`.
- **Bug corrigido:** o bug é o primeiro mutante — o `antes` é a linha
  corrigida, o `depois` é a de antes da correção. Sem guarda que o apanhe,
  o mutante não entra, e é aí que se escreve a guarda (F6).
- **Mutante órfão** (o `antes` deixou de existir): o código mudou de forma,
  e o defeito continua possível na forma nova. Reescreva-o contra ela e
  rode `--explorar`; apagar a entrada é apagar a prova, e só se faz quando
  o defeito deixou de poder existir, dito no commit.
- ⚠️ **EM PARALELO, O MARCADOR DE UM TRABALHADOR NÃO É O DO JOB.** O pai
  repassa a saída de cada cópia com `[tN]` à frente e não repassa o
  `MUTANTES OK` deles; o CI procura-o no início da linha. Sem as duas
  coisas, dois trabalhadores verdes e um furado davam o job por verde
  (`137`; `tools/testar_conferir_mutantes.py` reinjeta este e os outros
  defeitos da camada paralela).
- ⚠️ **O FIM DO CATÁLOGO É ONDE OS DOIS AGENTES COLIDEM.** Os dois
  acrescentam mutantes lá, a junção conflita, e o pré-PR acusa órfãos que
  são só os dois catálogos por juntar (`136`, contra o PR #148). Mutantes de
  um tema novo vão numa secção própria, ao lado das irmãs dela.

⚠️ **E DEFEITO EM ARTE IMPORTADA SÓ CHEGA À SUÍTE PELO `--import`.** O
`teste_design` lê o mapa pela textura do cache, de propósito (o `_mapa_lido`
diz porquê), e o primeiro mutante de mapa (`123`) SOBREVIVEU com a guarda
certa: o SVG mudou e a textura não. O executor reimporta quando o alvo tem
`.import` ao lado, e outra vez ao desfazer; a base do fim prova que o cache
voltou. E o alvo é o arquivo GERADO, não o gerador — o executor troca texto,
não regera.
⚠️ **E O EXECUTOR MORTO A MEIO RESTAURA O ARQUIVO, MAS NÃO O CACHE.** Em
18/10 (`130`) o catálogo inteiro passou do teto de 30 min que o segundo
plano desta sessão dá por omissão e foi morto no mutante do mar: o SVG
voltou ao certo — confere byte a byte com o gerador —, a reimportação não
chegou a correr, e a corrida seguinte deu a BASE do `teste_design`
vermelha, com a mancha clara do mutante. Depois de um executor
interrompido, `--import` antes de outra coisa; e o catálogo corre com o
teto de tempo dado à mão.
⚠️ **E O RÓTULO DECLARADO NÃO LEVA O QUE O GERADOR RENUMERA.** O do coreto
dizia «o praca (lote 4)», e a vila nova pôs a praça no lote 7: a guarda certa
reprovou e o executor deu o mutante por FURADO. «pinta telha_d à volta»
sobrevive a qualquer implantação (`123`).
⚠️ **E A GUARDA DECLARADA SAI DO `--explorar`, NUNCA DO PALPITE.** Na
medição da `117`, seis dos 35 defeitos reconstruídos reprovaram por outra
asserção que não a que eu escrevi — e era essa a guarda verdadeira deles.
⚠️ **E MARCA DE TEMPO SÓ PROVA COM O RELÓGIO A ANDAR.** O A4 do
`teste_audio` provava a espera mínima pedindo o som duas vezes seguidas e
conferindo que a marca não mudava; o relógio do `Audio` anda ao
milissegundo, e no mesmo milissegundo a marca fica igual, toque ou não
toque. O mutante sem a espera passou verde. A marca vai agora METADE da
espera para trás, e o controle — passada a espera, o som toca — é o que
prova que a régua consegue ver um toque (`117`).
⚠️ **E O AUTOLOAD QUE NÃO COMPILA PENDURA A SUÍTE**, não a reprova: com o
`GameState.gd` partido, o `run_tests` correu até ao teto. Quem lê só o
código de saída vê um timeout; o `Parse Error` está na saída parcial, e é
por isso que o executor julga a compilação antes do teto (`117`).

⚠️ **E O CORTE MEDIDO VALE PARA O DESENHO MEDIDO.** Os dois cortes do D46
foram a meio da banda três vezes na mesma sessão, porque cada passagem de
arte mexia no que eles medem: as correntes escuras do largo levaram a «pior
subida» do mapa certo de 3,9 a 7,3 (sair de uma faixa escura também é
subir), e a inclinação do degradê invertido de +0,13 a −0,17. Guarda raster
sobre arte que ainda se está a desenhar re-mede o PAR — o certo e o defeito
do catálogo — a cada passagem, antes do `--so` (`124`).

## O que as suítes executam e não conferem (`137`)

Medido em 24/10: as seis suítes executam 741 das 757 funções do jogo, e de
205 defeitos plausíveis sorteados NESSAS funções, 99 passam verdes (15
equivalentes). A lógica perguntada está guardada; o que escapa é outra coisa:

- ⚠️ **PAINEL QUE ABRE E CABE NÃO PROVA O QUE MOSTRA NEM O QUE O BOTÃO FAZ.**
  O bloco «Entrou» do caixa só com receita zero, o confirmar do cancelamento
  que some ou que cancela duas vezes, a meta e a parcela sem botão de fechar,
  o cartão da doca sem o valor — todos verdes. Guarda de painel abre-o pela
  porta do jogador e pergunta pelo TEXTO e pela AÇÃO, não só pelo encaixe.
- **E o que se GRAVA, se AGENDA e se CONTA:** o volume que não grava, o som do
  mar que nunca toca, a telemetria do playtest com o contador trocado.
- **Executar não é conferir.** A cobertura por função diz que a linha correu;
  só um defeito posto nela diz se alguém olhou. A medição e o instrumentador
  estão em `docs/arquivo/MEDICOES_VELOCIDADE_TESTES_2026-10-24/`.
- ⚠️ **E O BOTÃO ESCOLHE-SE PELO QUE ELE DIZ, NÃO PELO NOME DO NÓ.** O RB5
  premia o `TextoMaior` pelo nome, e os rótulos Padrão e Maior trocados
  passavam verdes; o T24 chamava `confirmar()` direto, e o botão podia sair
  da árvore (`138`). E o toque do telefone prova-se com `ScreenTouch` e
  `ScreenDrag` no `push_input`, que os entrega crus: o rato emulado é do
  `Input`, e o gesto do rato rolava com o ramo do dedo partido.
- ⚠️ **E A GRAVIDADE DE UMA AMOSTRA LIDA À MÃO É HIPÓTESE.** Dois dos treze
  «graves» da `137` não chegavam ao jogador: «confirmar duas vezes cancela
  duas vezes» o jogo recusa, e a meta da Fase 1 o `Main` nunca abre. Antes de
  escrever a guarda, siga o defeito até à tela, e escreva ao lado dela o que
  ela defende de verdade (`138`). Das médias, o calendário era equivalente
  (trocar o VALOR de uma chave que se lê por `has()` não muda nada), e os
  recordes só vazavam com um campo de outro tipo: a chave em falta, que a
  primeira guarda montou, o `.get(nome, {})` já zerava.
- ⚠️ **E ONDE UM DEFEITO DE LEIAUTE SE VÊ DIZ-O UMA SONDA COM E SEM ELE.** A
  acomodação do Maior desligada deu a mesma geometria em quase todo painel a
  1280; correr o percurso do contraste nas duas árvores, a três alturas, e
  comparar as caixas achou o único caso que muda à vista — o Construir, que
  a 1000 px começava em −37 (`138`).

## O jogador ao acaso (T26, `118`)

O T26 joga partidas inteiras ao acaso, com semente, e confere a cada passo o
que vale sempre. Três lições custaram a medição dele:

- ⚠️ **ROBÔ SEM CONTROLE DE EXERCÍCIO PASSA VERDE SEM TER JOGADO.** A primeira
  versão guardava os invariantes em 24 partidas e nunca tinha cancelado um
  serviço — a ação nem chegava a existir. O controle «cada ação foi aceite ao
  menos uma vez» é que o disse, três vezes seguidas, cada uma com uma causa.
- ⚠️ **O ACASO PURO NÃO CHEGA AO FIM DO JOGO.** Sem pagar, nenhuma partida
  chegava à Fase 2; com a treliça comprada, a reputação ao acaso ficava abaixo
  do piso e os cargueiros eram suspensos (a regra a funcionar). Inclinações
  medidas, perfis por semente e a «máscara» de ações legais — o robô vê o que
  se pode cancelar — são o que o leva lá. Ao mexer no robô, leia a linha
  `-> fase 2 em N de 24` antes de acreditar no verde.
- ⚠️ **SUÍTE QUE DEVOLVE `false` NO `_process` PENDURA SE O `_run()`
  ABORTAR.** O vigia de frames do `run_tests` e do `teste_fumaca` reprova com
  nome; um mutante que fazia o T4d rebentar pendurava a suíte até ao teto.
- **Bloco novo vive num arquivo próprio** (como o T24, o T25 e o T26), e o rótulo de
  falha tem `FAIL`/`FALHA`/`FALHOU` seguido de espaço — é por aí que o
  executor de mutantes sabe que guarda reprovou (`119`).

## Do «Antes de fechar», item 7 — escrever a guarda

A regra é o item 7 do núcleo; as lições que valem para qualquer régua
estão em `gerais.md`, que carrega sempre. Aqui ficam as de suíte e de
guarda.

   ⚠️ **E MUTANTE QUE SÓ UMA SUÍTE APANHA NÃO É SUÍTE A MAIS — é o que a
   outra não tem como ver.** Medido no R5 (`034`): dos três defeitos
   injetados na fila de mensagens, o de "interromper antes do tempo mínimo"
   reprovou **só** o bloco de aritmética pura. O bloco de integração drena a
   fila com passos de 99 s — ele pergunta o que chega à tela, não quando —, e
   é cego ao tempo por construção. Antes de dar um teste por redundante,
   pergunte que defeito ele vê que o outro não vê.
   ⚠️ **E O DEFEITO PODE CABER TODO NA ISENÇÃO DA GUARDA.** O D42 perguntava
   se o pallet anda com a empilhadeira e isentava o pallet «no pouso», onde
   ele espera no chão; o mutante que o deixava lá enquanto ela andava passou
   verde, porque cabia inteiro na isenção. O que separa os dois casos é ONDE
   ELA ESTÁ, não onde ele está (`079`). Guarda com exceção mede-se com o
   defeito que mora na exceção.
   ⚠️ **E A LISTA DE ISENÇÕES PERGUNTA-SE A SI PRÓPRIA.** O F19 isenta o
   literal declarado como «não é membro» (um sufixo de PNG), e a primeira
   versão da declaração isentava o `"_cida"` — que é um método do `Main`, e
   que o F4 procura no código dele. A asserção que reprova a isenção cujo nome
   É membro de um alvo apanhou-o na estreia (`093`). O que se isenta confere-se
   contra o que a guarda sabe, e não só contra o texto.
   **E CONTAGEM SÓ SE TESTA ACIMA DE UM.** Em 03/09 injetou-se um `break` que
   fazia o contador parar no primeiro trabalhador livre, e o teste passou: o
   porto abre com UM trabalhador e uma doca, e com esses números contar um e
   contar todos dá a mesma resposta. O bloco passou a montar três e dois.
   **E defeito injetado numa regra que existe em DOIS sítios nunca reprova.**
   No mesmo dia, tirar `if phase != "playing"` de `trabalho_parado()` não
   reprovou nada, porque `doca_aceita_trabalhador()` carregava a mesma guarda.
   Quando um defeito não pega, a primeira suspeita é que a regra esteja
   duplicada — e a correção é apagar a cópia, não reforçar o teste.
   **E confira QUAL guarda está a segurar a asserção.** Mordeu duas vezes em
   03/09, e não é a regra duplicada: são duas guardas DIFERENTES a proteger a
   mesma asserção, e a errada a segurar. Tirar o `not parcela_paid` de quem
   quita a dívida não reprovou nada, porque quitar deixa o caixa abaixo da
   parcela e a guarda do DINHEIRO fechava a porta no lugar dela; e tirar o
   teto de profundidade da marcha do caminhão não reprovou nada, porque o teto
   de gosto (42px) era mais apertado. Em ambos os casos a correção é montar o
   estado em que a guarda sob teste é a que APERTA — caixa de sobra, vizinho
   mais perto — e não reforçar a asserção.
   ⚠️ **E ASSERÇÃO RELACIONAL PEDE O ESTADO CERTO DO OUTRO LADO — «relacional»
   não é, sozinho, o contrário de «espelho».** Mesma armadilha com duas
   VARIAÇÕES no lugar de duas guardas. Em 22/09 o D34 perguntava se a seleção
   muda a borda do trabalhador comparando-a com o **repouso OBSERVADO**, e o
   mutante que matava o canal da cor **passou**: o HUD abre com trabalho
   parado, logo o repouso é o `TrabParado` de borda LARANJA, e pintar a
   seleção do verde do `TrabLivre` continua a diferir dele. Quem a seleção
   substitui é o cartão LIVRE — derivado, não suposto —, e contra ele o
   defeito reprova. **Antes de comparar dois estados, pergunte qual deles o
   estado sob teste REALMENTE substitui**, que quase nunca é o que a tela
   calha mostrar (`docs/decisoes/045`).
   ⚠️ **E «SUBSTITUI» TEM DUAS RESPOSTAS: a do RECURSO e a da MECÂNICA.** A de
   cima é a do recurso — a seleção veste o fundo do livre —, e está certa para
   o cartão. Para a TROCA que o jogador vê, a resposta é da mecânica: só se
   aloca com barco à espera, e aí o cartão é PARADO. Contra ele a borda mudava
   **1,33:1**, não os 2,26 publicados, e a foto da bateria mostrava a única
   seleção que não serve para nada (`050`). Pergunte de que lado está a
   pergunta antes de escolher o estado.
   ⚠️ **E QUEM PROVA QUE UM NÓ LARGA UM ESTADO PROVA-O NO MESMO NÓ.** A
   primeira guarda do reset do selo olhava o cartão depois de alocado, e o
   mutante sem o reset PASSOU: o `_refresh_workers()` RECRIA os cartões, e o
   nó novo nunca teve selo. O caminho em que o mesmo nó sai da seleção é o
   segundo toque, e é lá que a guarda vive (`050`).
   ⚠️ **E NEM TODA GUARDA NOVA PRECISA DE SER SUSTENTADORA — o que precisa é
   que a AFIRMAÇÃO ao lado dela seja verdadeira.** É o X1b/Y2b visto do outro
   lado: ali o par prova que a peça nova faz falta; aqui ele provou que NÃO
   fazia. No mesmo dia, o mutante com a guarda da derivação retirada reprovou
   na mesma por outras três, e o comentário que eu já tinha escrito — «sem
   esta linha as outras passariam contentes» — era falso. A guarda ficou,
   porque nomeia a CAUSA onde as outras nomeiam o sintoma; o comentário é que
   passou a dizer a verdade. **Comentário que atribui poder a uma asserção
   mede-se como se mede a asserção.**
   ⚠️ **E A GUARDA CONTRA A SORTE NÃO REPROVA COM A SEMENTE QUE CALHOU BEM.**
   O tiro da pressão do Arlindo semeia o dado para a aposta falhar, e o
   mutante sem a semeadura PASSOU: a semente da ferramenta já recusava. O que
   a prova é variar a semente — sem ela, duas de seis aceitavam (`060`).
   ⚠️ **E A PREVISÃO DE QUEM REPROVA «NO DIA EM QUE» MEDE-SE NESSE DIA.** O
   conferidor das capturas dizia que, com a lista de lacunas vazia, uma
   expressão partida só seria apanhada pela linha do catálogo vazio. Em 23/09
   a lista esvaziou e eu escrevi ao lado «medido, não suposto» antes de
   medir: quem reprovou foi outra guarda, sete vezes, e a linha calou-se
   (`053`). Comentário escrito no futuro é a forma mais barata de o ser falso.
   ⚠️ **E A GUARDA QUE ESCREVE ELA PRÓPRIA O ESTADO PROVA A LEITURA, NÃO A
   ESCRITA.** Para pôr um camião a meio da ré, a varredura do D35 marca-o como
   a sair à mão — e prova que a previsão lê a marca. O mutante que tirava a
   linha do JOGO que a escreve passou verde, porque a fixture fazia o trabalho
   dela. Quando o teste monta um estado que o jogo devia montar, a outra ponta
   — o jogo a escrevê-lo — pede a sua guarda (`052`). E um sub-bloco leva a
   sua BANDEIRA: um erro de execução lá dentro só aborta ele, e a bandeira do
   chamador ficava verde.
   ⚠️ **E O ESTADO ESCRITO À MÃO NÃO CHEGA A QUEM OUVE O SINAL.** Na `104`
   o F23 escrevia `GS.reputation = 100` para provar que a Dona Cida não
   anuncia o recomeço da passagem, e o mutante sem a correção PASSOU: a
   narradora só sabe a faixa que viu passar, e a primeira que vê ela só
   regista. Quem prova uma reação a um sinal monta o estado anterior PELO
   SINAL, e acrescenta o controlo de que a reação existe (uma queda de
   verdade, depois, é anunciada).
   ⚠️ **E CAMINHO QUE REPROVA CEDO ESCONDE O QUE OS OUTROS VERIAM.** O F11
   nasceu com três caminhos em fila num bloco só, e o primeiro vermelho saía
   do bloco: a primeira leva de mutantes deu UMA reprovação a cada um, e os
   outros dois caminhos nem tinham corrido. Separados, cada um com a sua
   bandeira, o M1 e o M4 reprovaram nos três — e só assim se pôde perguntar
   o que o terceiro vê de único (`054`). Antes de dizer que uma guarda NÃO
   reprova, confira que ela chegou a correr.
   **E ASSERÇÃO QUE MONTA O ESPERADO DA MESMA FONTE DO DEFEITO NÃO TESTA
   NADA.** Em 06/09 o teste do sorteio de motivos montava a lista do que devia
   aparecer LENDO OS PESOS, e comparava com o que apareceu: pôr o peso de um
   motivo a zero tirava-o dos dois lados ao mesmo tempo, e a asserção passava
   contente com o motivo desaparecido do jogo. O defeito só reprovou depois de
   entrar uma pergunta que NÃO sai dos pesos — "todo motivo escrito na tabela
   chega ao jogo?", que é a irmã do `barco_medio` renderizado, validado e nunca
   posto em doca nenhuma. Antes de escrever o esperado, pergunte de onde ele
   vem: se vem de onde o defeito vai morar, o teste é um espelho.
   **E `mini` TROCADO POR `maxi` PODE PASSAR EM TUDO.** Em 06/09 a trava do
   nível do navio é `mini(nivel_pier(), nivel_guindaste())`, e trocar o `mini`
   por `maxi` não reprovou uma única asserção — porque em quase todo estado do
   jogo os dois níveis são IGUAIS, e aí min e max dão o mesmo. O estado que
   APERTA é um só: pórtico comprado e cais ainda não. Antes de dar um defeito
   por não pegado, pergunte em que estado as duas versões DIVERGEM — e monte
   esse estado, que costuma ser um só entre muitos.
   ⚠️ **E FUNÇÃO COM GUARDA NÃO É RAMO COM GUARDA.** Em 23/09 a
   `silhueta_do_trecho()` tinha duas asserções a perguntar-lhe trecho a trecho,
   e nenhuma passava o `de_re` — o argumento opcional que decide a ré do camião:
   apagar o ramo dele não reprovava nada. Antes de dar uma função por coberta,
   pergunte que ARGUMENTOS as asserções lhe passam; o que tem valor por omissão
   é, quase sempre, o que ninguém passa (`047`).
   ⚠️ **E ESSE ESTADO PODE SER O QUE O JOGO NÃO FAZ — aí a fixture REALISTA é a
   que não prova nada.** A regra acima manda montar o estado em que as duas
   versões divergem; esta diz o que fazer quando ele é justamente o estado raro.
   Em 17/09, na Leitura do simulador, trocar PONTOS percentuais por diferença
   RELATIVA não reprovou asserção nenhuma: com o Ótimo a 100%, `100 − 30 = 70` e
   `(100 − 30)/100 = 70%` dão o mesmo número — e o Ótimo a 100% é o jogo de
   hoje. O defeito só cai com o Ótimo FORA do teto (a 80%: 50 pontos contra
   62,5%), que é um estado sintético de propósito. **Fixture copiada da medição
   real é a mais fácil de escrever e a que mais vezes calha no ponto cego**;
   depois de a escrever, calcule à mão o que o defeito daria ali e exija que os
   dois números sejam diferentes.
   **E confira que quem reprovou foi a guarda que se estava a testar.** No
   mesmo dia, o primeiro defeito injetado nesse sorteio reprovou — pela
   asserção dos PESOS, que somam 100 e denunciam qualquer peso mexido. A do
   conjunto, que era a que se queria provar, nunca chegou a ser exercida. O
   defeito seguinte teve de mexer em dois pesos ao mesmo tempo, para a soma
   continuar em 100 e só a guarda certa poder reprovar.
   ⚠️ **E RENOMEAR SÓ A DECLARAÇÃO PARTE O SCRIPT, não a leitura.** Para
   provar que o F19 apanha um privado renomeado, o primeiro mutante mudou a
   linha do `var` e deixou os usos: o script deixou de compilar, a suíte caiu
   em cascata e o F19 reprovou por «alvo sem membros» — verde de graça com
   cara de vermelho. Renomeado em TODO o arquivo, ele compila e o F19 nomeia a
   leitura órfã (`095`). Mutante de nome renomeia o nome, não a linha.
   ⚠️ **E QUEM SOBRESCREVE O NOME É O TERCEIRO CLIENTE, e o F19 não o vê.**
   Um nome que muda de dono tem quem o lê por string (o F19), quem o chama
   direto (grita) e quem o SOBRESCREVE numa subclasse — a sonda da régua da
   faixa herdava o `Main` e sobrescrevia o `_cida_agora`. Com a narradora
   fora (`096`), a sonda velha não compilou (o `super()` pede ao pai um nome
   que ele já não tem) e a régua imprimiu o marcador com zero ações e zero
   falas, código 0; sem o `super()` compilaria e nunca seria chamada. Ao
   mudar um método de dono, procure também `extends` do arquivo de onde ele
   sai.
   ⚠️ **E A LINHA QUE A EXTRAÇÃO MUDA DE FORMA PEDE O SEU MUTANTE — a bateria
   igual ao byte não responde por ela.** No terceiro corte do M8 (`097`) a
   única linha de comportamento que mudou foi o `is_inside_tree()` passado
   ao dono; tirá-la passou nas seis suítes e na bateria, na main e na
   branch. O igual-ao-byte prova que o que se vê não mudou, não que a linha
   mexida tenha quem a veja. A guarda nova conta os nós órfãos pelo motor
   (`OBJECT_ORPHAN_NODE_COUNT`) antes e depois de soltar o `Main`.
   **E o defeito pode pegar e o teste passar na mesma.** Aconteceu em 02/09:
   tirar `tests/*` do filtro de export não reprovou nada, porque o teste
   perguntava `contains("tests/*")` e o `scenes/tests/*` que ficou no arquivo
   contém essa string. Num arquivo de configuração, `contains()` quase nunca é
   a pergunta que se quer fazer — separe a lista e compare ITEM a item. Vale a
   mesma desconfiança ao ler chave de config: uma linha dentro de um
   COMENTÁRIO satisfaz uma busca no arquivo inteiro.
   ⚠️ **E NÚMERO DE TURNO CRAVADO NUMA ASSERÇÃO REPROVA O CÓDIGO CERTO.** É a
   regra do "número em pixel escrito à mão" que este arquivo já carrega, com o
   CALENDÁRIO no lugar do tamanho. O bloco 7b do `run_tests.gd` amostrava o
   desconto da parcela em `[4, 12, 20, 28, PARCELA_DUE_TURN]`, e aqueles 28 são
   o penúltimo turno de uma semana de OITO: com `TURNS_PER_WEEK = 7` o prazo
   passa a 28, a lista fica com o vencimento DUAS vezes, os dois custos saem
   iguais e a asserção reprova uma mudança que estava certa. **Amostrar um
   intervalo derivado custa o mesmo que percorrê-lo inteiro** — e percorrer não
   crava nada, além de cobrir os turnos que a amostra saltava.
   ⚠️ **E GUARDA DE «NÃO HOUVE ERRO» ESCOLHE-SE MEDINDO O QUE A CORRIDA
   SAUDÁVEL IMPRIME.** O marcador diz que a ferramenta chegou ao fim; não diz
   que ela não se queixou pelo caminho, e o Godot encerra com 0 nas duas
   situações. Só que a guarda óbvia — `grep ERROR` — reprovaria quase tudo o
   que está certo: medido em 18/09, em corridas VERDES, **cinco das seis
   suítes** e o simulador encerram com `ERROR: 1 resources still in use at
   exit` — e no simulador isso sai DEPOIS do marcador —, e o `teste_fumaca`
   imprime um `ERROR: Parse JSON failed` **de propósito**, que é o save
   inválido que ele injeta para provar que o jogo o recusa.
   ⚠️ **E ESSE RUÍDO NÃO É CONSTANTE.** Em 11/10 a régua do boletim, na
   mesma árvore, imprimiu `ObjectDB instances leaked` numa corrida e não na
   seguinte. Quem compara a saída de dois lados (a `main` e a branch) tira
   as linhas de encerramento antes de atribuir a diferença à mudança, e
   corre cada lado duas vezes se ela for a única (`094`).
   ⚠️ **E O PREFIXO NÃO SEPARA AS CLASSES:** medido numa sonda, `push_error()`
   sai como `ERROR:` e não como `USER ERROR:` — a queixa da FERRAMENTA tem o
   prefixo do barulho do MOTOR. Quem separa é a ORIGEM, escrita na linha `at:`:
   só quem chamou `push_error` traz `at: push_error (`. O par das SUÍTES é
   `SCRIPT ERROR|at: push_error \(`, e quem DERIVA do workflow a lista de quem
   o tem é `tools/conferir_guardas_ci.py` — ela era escrita à mão, e foi por
   isso que faltou em cinco dos onze passos (`docs/decisoes/031`).
   ⚠️ **E SÃO TRÊS FORMAS, NÃO DUAS — o par das suítes conhece duas.** Medido
   em 21/09, uma sonda por forma: `push_error()` e o erro de EXECUÇÃO trazem
   ambos o bloco `GDScript backtrace`; o erro de COMPILAÇÃO traz `SCRIPT ERROR`
   e NÃO traz backtrace (`at: GDScript::reload`); e a **chamada falhada** —
   `Error calling method from 'callv'` — sai como `ERROR:` com `at:` em C++ e
   backtrace, porque quem se queixa é o MOTOR sobre uma chamada que o NOSSO
   script fez. Nenhum dos dois padrões a apanha, e foi assim que o `PainelCaixa`
   saiu PRETO com a bateria verde. Quem escreve a origem é o Godot, no bloco do
   backtrace — o ruído de encerramento não o tem. A **bateria de captura** varre
   hoje `SCRIPT ERROR|GDScript backtrace`, e as suítes NÃO: o `teste_fumaca`
   imprime de propósito um erro de JSON que traz backtrace, e alargar lá poria
   uma suíte verde a vermelho (`docs/decisoes/038`).
   ⚠️ **E MUTANTE QUE MUDA A LINHA E DEIXA A ANTIGA DE PÉ É EQUIVALENTE.**
   Na `102` o mutante «a dívida escrita antes do `_baixar_parcela()`»
   acrescentou a escrita antes e deixou a de depois no lugar: o
   comportamento era o mesmo, e as duas suítes passaram. Não era a guarda
   que falhava — era o defeito que não existia. Antes de concluir «não
   pega», leia o mutante como diff e pergunte se o jogo mudou mesmo; refeito
   sem a linha de depois, reprovou nas duas.
   ⚠️ **E LAÇO DE SUÍTE QUE JOGA ATÉ UM ESTADO LEVA TETO DE VOLTAS.** No mesmo
   dia, o mutante do save sem a dívida pôs o T14 preso no vencimento — o
   `pay_debt()` recusa calado, o `advance_turn()` volta calado, e o dia não
   anda —, e o `run_tests` nunca acabou: no CI isso é o job a morrer de
   timeout sem dizer qual bloco. Com o teto e uma asserção sobre ele, o
   mesmo defeito reprova com nome.
   ⚠️ **E A QUARTA FORMA DE FALHAR É NÃO ACABAR.** Chamada com o número errado
   de argumentos dentro do `_process` de um `SceneTree` ABORTA a função, e um
   `--script` que aborta antes do `quit()` repete o `_process` a cada frame e
   NUNCA ENCERRA — sem log, sem foto e sem uma palavra. É a irmã da regra do
   teto de voltas do laço de turnos, um andar acima: no CI aquilo não é
   vermelho, é o job a morrer de timeout sem dizer qual passo foi. Toda bateria
   de ferramentas leva teto de tempo POR TIRO (`timeout 180` no `tirar()`).
   ⚠️ **E O ESCOPO DA GUARDA É O ESCOPO DO DEFEITO.** A primeira versão desse
   portão exigia a varredura de todo arquivo de um passo que rodasse
   `--script`, e reprovou a saída de um leitor em **Python** — onde uma exceção
   sai com código ≠ 0 e o `set -e` apanha. Sair com zero depois de um erro é
   problema do Godot e só dele. Antes de alargar uma guarda ao passo inteiro,
   pergunte de QUE ferramenta é o defeito que ela caça.
   **E TESTE QUE LÊ ARTE GERADA LÊ O ARQUIVO, NUNCA O `load()` DA TEXTURA.**
   `load("res://art/porto_mapa_iso.svg")` devolve o `.ctex` de
   `.godot/imported/`, que é de quando o projeto foi importado: com o mapa
   regerado na mesma sessão, o D20 reprovou a apontar para um defeito que já
   tinha sido corrigido — verdadeiro, e de ontem. Rasterize o arquivo
   (`load_svg_from_string`, que é o mesmo ThorVG); o cache do importador é uma
   resposta velha, e num teste isso mente nas duas direções.
   **E "TODOS APARECEM" NÃO IMPLICA "NA ORDEM CERTA", nem o contrário.** Duas
   guardas sobre a mesma tabela e nenhuma delas de graça: uma conta pode
   devolver os três portes de barco ao CONTRÁRIO e cumprir a alcançabilidade,
   e pode manter a ordem perfeita alcançando só dois. Quando duas perguntas se
   parecem, o teste é montar o estado em que UMA falha e a outra passa; se esse
   estado não existir, a segunda é confiança de graça — e se existir dos dois
   lados, são duas asserções e não uma.
   ⚠️ **E MÉTRICA DE FORMA LIDA DE NÚMERO PUBLICADO MEDE O ARREDONDAMENTO.**
   Em 14/09 a guarda nova da costa (D28) media "a maior reta" juntando segmentos
   cujo ângulo batesse a menos de meio grau — e o defeito injetado, a costa de
   volta à escada, **não a reprovou**: a tabela publica pixel com UMA casa
   decimal, e meio pixel de arredondamento num segmento de 6,7 px vale 0,43
   grau. Cada par de segmentos colineares parecia dobrar, e a reta de 224 px
   saía partida em trinta. O que reprovou foi a asserção da QUINA, ao lado — a
   armadilha do "confira QUAL guarda reprovou" com outra roupa. A métrica que
   pega é a de uma **régua pousada em cima do desenho**: até onde ela vai sem
   que a linha se afaste mais de um pixel dela. Antes de medir forma, pergunte
   quanto ruído o número que se vai ler já traz consigo.
   ⚠️ **E PROVA DE FRONTEIRA POR PRIMEIRA TRAVESSIA NÃO SOBREVIVE AO ENFEITE.**
   No mesmo bloco, a asserção que procurava a borda da água atravessando a linha
   de 1 em 1 px reprovou o mapa CERTO por 9 px: sobre a rampa da praia pousam
   pedras cinzento-azuladas, e a varredura vinda da areia dava a água por
   começada em cima da primeira delas. Fronteira mede-se por **contagem** (uma
   pedra de dois pixels desloca o total em dois) e não pela primeira amostra que
   troca de lado — e quando nem a contagem separa, a asserção pode simplesmente
   não valer o que custa: aquela foi construída, medida e RETIRADA, depois de se
   confirmar que o defeito que ela caçava reprovava noutra pergunta.
   ⚠️ **E UM CORTE COLADO A UMA PONTA DA BANDA MEDIDA É SORTEIO.** A irmã das
   duas regras abaixo, e a mais fácil de cometer depois de medir bem: em 14/09 a
   janela nova do D20 dava **5** px no mapa certo e **42** com o defeito
   injetado, e o corte que eu tinha escolhido era **41** — reprovava por UM
   pixel. O número estava medido e mesmo assim não servia. Quando os dois lados
   estão medidos, o corte vai para o MEIO da banda, e diz-se a folga que ficou
   de cada lado (4x e 2,1x).
   ⚠️ **E NÃO SE APERTA O TETO DE UMA GUARDA ATÉ ELA APANHAR UM SEGUNDO
   DEFEITO.** É a irmã do "portão alimentado com fumaça", do outro lado: ali a
   tolerância era folgada demais para o ruído do número; aqui é a tentação de a
   fechar até o defeito seguinte cair dentro. No D29 (14/09) o primeiro defeito
   reprovou os oito cascos e o segundo só UM; baixar o teto de 62% para 57%
   apanharia seis dos oito — e deixaria o arrasteiro BOM a passar por dois
   pontos, o que é vermelho na primeira vez que alguém mexer num casco. O teto
   ficou onde estava. **Uma guarda defende o que defende; o que não se pode é
   fingir que ela defende mais** — escreva ao lado dela o que fica de fora, e
   quem prova o resto é a medição registada. Nem tudo o que se mede precisa de
   asserção.
   ⚠️ **E DUAS PROTEÇÕES DIFERENTES PEDEM UM DEFEITO QUE QUEBRE AS DUAS.** Não é
   a regra da "regra duplicada", é o contrário dela: ali a correção era apagar a
   cópia, aqui as duas guardas defendem coisas distintas e ambas são precisas. A
   areia não chega à pista por DOIS motivos — o recuo do mundo põe-na longe, e a
   ordem de desenho põe a rua por cima —, e em 14/09 quebrar cada um sozinho não
   reprovou nada. Antes de dar uma asserção por morta, conte quantas coisas
   diferentes impedem o defeito de chegar até ela.
   ⚠️ **E COR MISTURADA NUNCA CASA COM UM TOM PUBLICADO.** Na mesma caça, o
   defeito das manchas secas não pegou porque elas saem a `opacity="0.45"`: a
   asserção da areia do D20 só apanha areia OPACA, e isso nunca estava escrito.
   Quando um defeito de COR não pega, pergunte primeiro se o que ele pinta chega
   ao pixel puro.
   **E ANTES DE CULPAR A MUDANÇA, MEÇA A VERSÃO ANTIGA COM O MESMO DEFEITO.**
   A janela nova do D20 não apanhava a areia e a suspeita óbvia era a janela.
   Baixar o mínimo a 1 — mais sensível do que o pixel único que lá estava —
   continuou a dar zero, o que prova que a limitação é ANTERIOR e que a mudança
   não perdeu poder nenhum. É barato, e é a diferença entre registar um achado e
   reforçar um teste às cegas.
   **E DEFEITO INJETADO LONGE DA LINHA AMOSTRADA NÃO CHEGA A ELA.** Um bloco
   que percorre um caminho só vê o que o caminho cruza. Pintar a passadeira com
   a cor da calçada não reprovou o D20 e não foi falha dele: com passo
   `RUA_LARG/8`, a barra n.º 6 acaba em `dentro + 1,35`, que é ao milésimo a
   faixa por onde o camião anda — o defeito passou rente. Ao injetar num teste
   que amostra uma linha, ponha o defeito EM CIMA dela.

## Provas sobre o desenho (da seção «Arte»)

- **E a guarda que DUAS outras já implicam nunca reprova.** Irmã da regra de
  injetar defeito, um andar acima: a primeira asserção do desvio varria-o contra
  o retângulo do acesso, e o desvio é uma reta entre dois pontos que outras duas
  asserções já prendem aos números publicados — com aquelas de pé, esta não
  tinha como falhar. Antes de escrever a terceira asserção sobre a mesma coisa,
  pergunte que estado a violaria **sem violar as outras**; se não houver, ela é
  confiança de graça.
- **Uma conta que só divergiria com um modificador ativo não se testa num
  porto em ruínas.** A projeção do dia (item da interface, 03/09) e o fecho
  real da semana partilham `_custos_da_semana()` de propósito — e o teste que
  provava isso rodava sem pátio nem escritório construídos, onde a fórmula
  errada e a certa dão o mesmo número por acidente (nenhuma das duas aplica
  bónus nenhum). Só com os dois construídos um defeito injetado na cópia
  reprovou. É a mesma lição de "contagem só se testa acima de um", aplicada a
  um bónus em vez de uma quantidade. E vale para a ida e volta do save: com o
  exemplo do dia 1, o `load_game()` podia esquecer a obra e o F21 passava; o
  exemplo é jogado até ter os campos cheios, e confere-se que os tem (`098`).
- **⚠️ PROVA POR PIXEL ÚNICO É FRÁGIL, E A JANELA TEM DE SER DA ESCALA DA
  PEÇA.** A primeira metade já estava escrita no D17 — pergunte quanto DESENHO
  há à volta do ponto, e nunca se o ponto cai na caixa. A segunda custou dois
  defeitos injetados que **não pegaram** (13/09, D24): com um raio único de
  12 px, tirar o campanário da igreja passava porque a janela ainda apanhava o
  remate 7 px abaixo, e dar um telhado à obra passava porque à volta dela há
  creme por todo o lado. Uma peça de 18 px pede uma janela de 9×9; uma laje de
  50, uma de 21×21 — e o raio vive na PROVA, não numa constante do teste.
  E o pixel único mentiu três vezes antes disso, sempre reprovando o que estava
  certo: por mirar o meio de um volume (que em isométrico cai na FACE lateral e
  não no topo), por cair debaixo de uma peça elevada (que se projeta para cima
  e para TRÁS, tapando todo ponto de `mx + my` menor) e por cair dentro de uma
  copa.
- **⚠️ E A GUARDA QUE SE SATISFAZ COM O VIZINHO NÃO GUARDA NADA.** É o que
  estava por trás dos dois defeitos acima, e apareceu três vezes no mesmo dia: a
  prova do piso da praça contava os pixels da CALÇADA DA RUA, que passa a poucos
  pixels dali — teria passado com a praça inteira apagada. Antes de escolher o
  que provar, pergunte o que é EXCLUSIVO da peça: a praça passou a ser provada
  pelo coreto, que é a única coisa que só ela tem. E quando a peça se define por
  uma AUSÊNCIA, a prova é negativa — ter laje creme não distingue uma obra das
  casas, que são do mesmo creme; **não ter telha por cima**, sim.
- **⚠️ E «VERDE DOMINANTE» NÃO É RELVADO.** O D27 conferia o habitat do cão
  caramelo pedindo `g > r e g > b` no pixel dele, e a vila nova (`123`)
  pô-lo em cima do muro de uma casa verde-água — que passa nesse teste. Quem
  o viu foi a folha dos props, que mudou de chão. A pergunta certa é a cor
  do relvado medida contra as que podem estar lá por engano (o muro, a
  parede, a copa), com o corte a meio da banda; e mexer na vila pergunta
  que props pousam por cima dela. E mexer no CHÃO pergunta que bichos: a
  areia da restinga caiu debaixo do quero-quero (`127`).
- **⚠️ CONTORNO POR COLUNA É O MÍNIMO DA COLUNA, e a guarda que pergunta se
  ele VÊ uma casa só aperta onde a casa é o mais alto.** O mutante do D47
  que subia um lote 60 px sobreviveu: em quase toda coluna o contorno vem
  de 100 a 350 px acima, de casas e quintais de trás, fora do quadro. O
  defeito que a pergunta caça é o contorno CEGO nas colunas da casa, e é
  esse o mutante (`127`).
- **⚠️ MUTANTE QUE TROCA ARTE CONFERE QUE A NOVA EXISTE ONDE É LIDA.** O do
  telhado (`130`) trocava uma moita embutida por uma copa que o SVG não tem
  nas `<defs>`: o `<use>` não desenha nada, o mutante APAGAVA a moita em vez
  de a crescer, e sobreviveu. E o do destaque tapado nasceu fraco (73%,
  abaixo do corte): o mutante que fica é o caso que PEDIU a guarda, não um
  parecido com ele.
- **PROP NOVO NO `Cenario` RESPONDE ÀS GUARDAS DE TODOS OS PROPS.** As plantas
  da restinga caíram no D2 (seis no asfalto, verdade) e no D15 (equipamento de
  porto na praia — que elas não são). A isenção é pelo nome e diz a espécie,
  nunca o sítio: `Arvore` pode estar no `my` da praia e continua proibida na
  areia (`127`).
- **⚠️ E O SPRITE DA FAUNA TAMBÉM É ATLAS.** A pergunta do D47 «nenhum bicho
  em cima de uma árvore» lia a caixa pelo `get_image()` — a região, com o
  canto em (0, 0) (`049`) — e media 256 px ao lado do bicho: verde de graça
  até o mutante sobreviver duas vezes. Régua que lê pixel de textura de
  prop ou de bicho passa pelo `PropIso` (`127`).

## Do «Estilo de código»

- **Erro de execução DENTRO de um teste aborta a função e a suíte passa na
  mesma.** Aconteceu em 02/09: uma chamada com o número errado de argumentos
  matou o bloco T5g inteiro e o `run_tests.gd` imprimiu `TODOS OS TESTES
  PASSARAM` com sete asserções por correr. É a irmã da regra acima — o erro sai
  no `stderr`, o contador de falhas fica em zero, e nada reprova. Todo bloco de
  teste novo põe uma bandeira na ÚLTIMA linha e quem o chama confere que ela
  ficou verdadeira; só assim "passou" quer dizer "correu".
- **⚠️ E ANIMAÇÃO PROVA-SE SEM ESPERAR FRAME NENHUM.** Num teste síncrono — o
  `teste_design` devolve `true`, e um `await` lá nunca volta — o tween que o
  jogo cria apanha-se pela diferença de `get_processed_tweens()` antes e depois
  da ação, e anda-se com `custom_step()`, lendo o NÓ a cada passo, que é o que o
  jogador vê. O passo tem de ser menor do que o trecho mais curto, senão um
  trecho inteiro cabe num passo e nunca é lido; e a ação que não criou tween
  tem de REPROVAR, senão a lista vazia passa por "nada de errado" (`047`).
- **⚠️ E NUMA SUÍTE QUE NUNCA DEIXA PASSAR UM FRAME, OS TWEENS NUNCA SAEM DA
  LISTA.** O motor só tira os acabados e os mortos no `process` seguinte, e o
  `teste_design` corre inteiro num `_process`: ao D35 chegavam 983. Perguntar
  `Array.has()` a cada um, a cada passo, fez um bloco custar 62 s a uma suíte
  de 3; um `Dictionary` devolveu-a a 9 (`052`).
- **⚠️ RÉGUA QUE VARRE CÓDIGO LÊ O ARQUIVO INTEIRO, NUNCA LINHA A LINHA — e a
  que não o faz não REPROVA, escapa CALADA.** O `CLAUDE.md` já registava isto
  para o `grep` de facto em prosa; em 21/09 mordeu dentro da guarda escrita
  para o caçar. O bloco F9 varria linha a linha e achou **6 das 11** chamadas:
  o código deste repositório também quebra aos ~79 caracteres, e cinco delas
  têm a chamada numa linha e os argumentos na seguinte. As cinco não entravam
  na lista e não havia queixa nenhuma.
  ⚠️ **E QUEM AS APANHOU FOI A CONTA POR DOIS CAMINHOS**: quantas vezes o nome
  aparece no texto, contra quantos casos a expressão conseguiu ler, com a
  asserção a exigir que os dois números sejam iguais. É *"uma régua que
  responde à mesma pergunta por dois caminhos denuncia-se sozinha"* aplicada a
  uma VARREDURA — e é ela que faz uma chamada de forma nova reprovar em vez de
  ser ignorada. Sem ela, a versão errada dizia verde (`docs/decisoes/037`).
  ⚠️ **E O ID QUE É TAMBÉM NOME DE ESTADO SATISFAZ A BUSCA ENTRE ASPAS.** A
  pergunta «toda fala chega ao jogo?» procura o id entre aspas nos painéis,
  e isso serve-lhes. No `TutorialDoToninho.gd` (`101`), «atracar» e
  «avancar» são também os nomes dos PASSOS (`passo = "atracar"`): apagar a
  fala deixaria o passo a satisfazer a busca. Ali procura-se o argumento de
  quem põe a fala na fila (`_dizer("…")`), por dois caminhos — chamadas
  contra lidas —, e o id composto (`"ava" + "ncar"`) reprovou, injetado.
  ⚠️ **E A DEFINIÇÃO NÃO É UMA CHAMADA.** `func _abrir_painel(cena: PackedScene)`
  casa tão bem quanto uma chamada de verdade: a primeira versão do portão das
  capturas exigiu fotografia de um painel chamado `cena: PackedScene`. Quem
  varre CHAMADAS exclui a definição (`(?<!func )`), e lê o argumento com
  **parênteses equilibrados** — `[^)]*` para no primeiro fecho e parte ao meio a
  chamada que traz outra dentro (`docs/decisoes/039`).
  ⚠️ **E O ARGUMENTO PODE TER PARÊNTESES *E* ASPAS DENTRO.** `int(dia["servidos"])`
  parte as duas expressões óbvias: a que casa a primeira string a seguir ao
  parêntesis lê `"servidos"` como argumento, e a que proíbe parênteses salta a
  chamada inteira. O que se casa são os ÚLTIMOS argumentos antes do fecho.
  ⚠️ **E A GUARDA QUE VARRE O PRÓPRIO ARQUIVO LÊ OS FIXTURES DELA COMO DADO.**
  Irmã do corte dos comentários do F9, do lado do código: o F19 varre `tests/`,
  e a primeira corrida reprovou nove literais sem dono — a lista dos nomes
  ESPERADOS do fixture, escrita entre aspas. Uma guarda que varre a pasta onde
  mora monta o fixture sem a forma que caça (as aspas por `%s`) e compara o
  esperado sem ela (`093`).
- **Teste que JOGA fixa a semente.** `new_game()` chama `_spawn_boats()`, que
  tem 30% de abrir contra-oferta — e nessa fase o `advance_turn()` retorna
  CALADO. Um bloco de teste que avance o turno logo a seguir reprova em cerca
  de 3 de cada 10 corridas por uma razão que nada tem a ver com o que ele
  testa. Teste intermitente no CI é pior do que teste nenhum: ensina a ignorar
  vermelho.
  ⚠️ **E FIXAR A SEMENTE NO TOPO DO BLOCO NÃO CHEGA: o ESTADO dela anda com
  quem a usa.** Em 06/09 acrescentaram-se 1.500 sorteios ao meio de um bloco de
  teste, e o `new_game()` de um bloco POSTERIOR — que passava havia semanas —
  passou a calhar numa contra-oferta, onde `comprar_estrutura()` recusa calado.
  Nada mudou nesse bloco; mudou o que veio antes. Todo bloco que jogue resolve
  a oferta pendente antes de contar com o estado (`if GS.phase ==
  "rival_offer": GS.resolve_rival_offer(true)`), em vez de confiar na semente
  de quem o precede.
- **⚠️ TROCAR O VERBO DO JOGO DEIXA OS LAÇOS QUE JOGAM A JOGAR NADA, verdes.**
  Na `083` o «Alocar todos» saiu, e o T6 do `run_tests` continuou a correr as
  quarenta partidas dele sem servir um barco: a partida acaba na mesma, e nada
  reprovava. Quem joga conta o que jogou (`servidos > 40`). E o
  `capturar_tela.gd` reconhecia a contra-oferta pelo nome de uma propriedade
  (`dock_index`), que mudou com a fila: deixou de a reconhecer, sem erro. Ao
  mudar o verbo, procure quem o CHAMA e quem RECONHECE o que ele abre.
