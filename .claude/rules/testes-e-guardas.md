---
paths:
  - "brport_vs/tests/**"
  - "brport_vs/scripts/validation/**"
  - "tools/conferir_*.py"
  - "tools/medir_*.py"
  - "brport_vs/tools/medir_*.gd"
  - "brport_vs/tools/sonda_mensagens.gd"
  - ".github/workflows/**"
---

# Regras — testes e guardas

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

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
  um bónus em vez de uma quantidade.
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
