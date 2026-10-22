---
paths:
  - "brport_vs/scenes/**/*.tscn"
  - "brport_vs/ui/**"
  - "brport_vs/scripts/Painel*.gd"
  - "brport_vs/scripts/Main.gd"
  - "brport_vs/scripts/DocaCartao.gd"
  - "brport_vs/scripts/Icones.gd"
  - "brport_vs/scripts/TelaNomes.gd"
  - "brport_vs/scripts/TelaInicial.gd"
  - "brport_vs/scripts/FolhaDoCaderno.gd"
  - "brport_vs/scripts/UpgradePanel.gd"
  - "brport_vs/scripts/CounterOfferPanel.gd"
  - "brport_vs/scripts/DebtPaymentPanel.gd"
  - "brport_vs/scripts/EndGame.gd"
  - "brport_vs/scripts/PauseMenu.gd"
  - "brport_vs/scripts/FilaDeMensagens.gd"
  - "brport_vs/scripts/VezDasTelas.gd"
  - "brport_vs/scripts/BarcoFila.gd"
  - "brport_vs/scripts/validation/contraste_ui.gd"
  - "brport_vs/tools/medir_contraste_ui.gd"
  - "brport_vs/art/icones/**"
  - "tools/conferir_escopo_ui.py"
  - "tools/excecoes_cor_ui.json"
---

# Regras — interface

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Interface

- **Tela nova é OVERLAY, nunca fase do `GameState`.** Uma fase nova que bloqueie
  o turno não dá erro nenhum: o `advance_turn()` retorna calado fora de
  `"playing"`, e o laço do `simular_balanceamento.gd` só sabe resolver
  `rival_offer` e `debt_payment`. Medido: uma fase a mais fez **24 de 30
  partidas não terminarem**, e o CI passava na mesma porque só procurava a
  linha `=== Leitura ===`. Hoje ele também reprova `possível travamento`, mas a
  regra vale antes do CI: como overlay, o balanceamento medido fica intocado
  **por construção**, e não por cuidado de quem escreveu.
- **Fala de personagem vai em BALÃO, informação do jogo não.** As telas
  narrativas misturam dois registros e, sem diferença visual, a fala da Dona
  Cida lia como rodapé de planilha. O balão é o DA PESSOA que fala — o mesmo
  tom no celular e no cartão, com o retrato numa placa do mesmo matiz e a fala
  em letra regular (`082`); `RotuloSecao` é o rótulo que guia e sai da
  frente; `RotuloTotal` é a linha única que o olho tem de encontrar primeiro —
  duas em destaque é nenhuma em destaque.
  ⚠️ **E A LETRA DO GODOT TEM UM PESO SÓ**: a padrão é a Open Sans seminegrita,
  e tudo o que não declara fonte sai nela. Peso diferente é ARQUIVO de fonte
  (`ui/fontes/`, numa variação do tema), não uma propriedade a ligar.
- **Linha com valor zero não entra em tabela.** O boletim mostrava
  `Armazém R$0` e `Parcela R$0` nas semanas em que não havia nem um nem outro:
  ruído que o olho descarta toda semana para chegar ao que mudou.
- Painel novo herda de `PainelNarrativo.gd` — o andaime (escurecer, cartão,
  título, parágrafo, botão, seção, total, fala, fio) num lugar só. `montar(largura, 0)` faz o cartão
  **ajustar-se ao conteúdo**; altura fixa só quando há área de rolagem. Três
  painéis saíram com uma faixa branca debaixo do botão por causa disto, e o
  mesmo painel muda de tamanho conforme o caso.
- **Tela que abre SOZINHA passa pela vez** (`na_vez()`, em `VezDasTelas.gd`
  desde a `097`; até lá, `_na_vez()` no `Main`). Três
  sinais do mesmo instante abriam três painéis empilhados, e o toque só
  alcança o de cima: a resposta do Sr. Ribeiro ficava por baixo do fim de
  fase, que oferece «Jogar de novo». Quem tem a vez fica na tela, os outros
  esperam por ordem de chegada, e a vez passa pelo `tree_exited`, que é por
  onde passa TODA saída de painel — o `fechou` não passa pelo `remove_child`
  das ferramentas, e aí o turno ficou preso sem painel (`054`).
  A chegada sorteada ao pagar pode trazer oferta do Arlindo: enquanto a
  resposta do banco tem a vez, ela espera resposta → boletim → oferta
  (`087`, T16). A oferta habitual mantém prioridade sobre um boletim comum.
  Teste que espera `process_frame` precisa manter o SceneTree vivo:
  `_process()` devolve false e só o `quit()` final encerra a suíte; true
  encerrava T16 antes de conferir os painéis seguintes.
- **Mecânica nova precisa de um sítio onde se LEIA, ou não existe.** A trava do
  nível do navio (06/09) seria invisível — o jogador veria o navio grande
  deixar de aparecer sem saber que é o porto dele que não o aguenta. Hoje o
  painel Construir abre com "Porto nível 1 — recebe pesqueiro / Ainda não
  aguenta: cargueiro, navio de longo curso", e a linha PERCORRE a tabela das
  classes em vez de as listar à mão. É a mesma regra do motivo no cartão da
  doca, e a mesma do `barco_medio`: o que o jogo tem e não mostra não conta.
- Nada de interface pousa sobre o mapa. Uma doca tem duas metades:
  `Dock.tscn` (cenário) e `DocaCartao.tscn` (texto e alvo de toque).
  A exceção é o «+R$» que sobe do barco na virada do dia (`078`): dura
  1,2 s e não recebe toque. A regra nasceu de nomes e chips PERMANENTES.
- **⚠️ O PAINEL É BRANCO E A COR NEUTRA DO JOGO É PARA FUNDO ESCURO** — e isto
  já mordeu TRÊS vezes com a mesma cor. O cinzento-azulado 0,51/0,6/0,706 mede
  **2,93:1** sobre branco, abaixo do corte de texto GRANDE da WCAG (3,0), e
  todo texto de painel é menor do que isso. Foi apanhado no calendário em
  03/09, e o painel Construir carregava-o em OITO rótulos até 06/09 sem que
  nada perguntasse. Sobre branco use 0,35/0,42/0,50, que mede 5,46:1 e passa o
  AA. O bloco **D19** do teste de design percorre os rótulos e mede.
  ⚠️ **E FORAM QUATRO, E À QUARTA ELA VEIO PELO TEMA.** Em 20/09 a mesma cor
  estava na linha `RotuloSecao` de `tema_brport.tres`, que vive em NOVE painéis
  — e as três guardas de contraste que havia percorriam **um painel cada** (o
  D19 o Construir, o D23 o menu-celular, o D32 a faixa de mensagem). **Guarda
  que pergunta por um sítio não responde pelos outros treze**, e um defeito que
  desce do tema toca em todos de uma vez. Medidos os 19 estados, reprovavam
  **22** textos por **quatro** causas distintas, e a revisão externa nomeava
  uma. Hoje quem percorre tudo é o **D33**, e `tools/medir_contraste_ui.gd`
  imprime a tabela do mesmo motor (`docs/decisoes/035`).
  ⚠️ **E O QUINTO ENDEREÇO NÃO ERA UM RÓTULO**: era a SUGESTÃO do campo
  (`font_placeholder_color`), a 2,70:1, que as quatro caças anteriores não
  citavam por não estarem à procura de um `LineEdit`. Ao varrer uma cor,
  pergunte que OUTROS papéis de texto existem além do rótulo.
  ⚠️ **E "O PAINEL É BRANCO" NÃO É O FUNDO REAL.** A mesma variação mede
  5,46:1 no cartão, **5,03:1** no balão da fala (#f0f6ff) e **5,27:1** no creme
  da faixa; o neutro media 2,93 no cartão e **2,70** no campo. Mede-se contra o
  `bg_color` composto alfa sobre alfa até ao primeiro opaco, com o `modulate`
  aplicado ao texto e ao fundo por cadeias SEPARADAS — são duas, porque começam
  em nós diferentes.
  ⚠️ **E UMA IMAGEM POR TRÁS DO TEXTO NÃO TEM COR QUE SE LEIA.** A régua
  subia pelos antepassados até ao primeiro fundo opaco — e o papel de parede
  do celular é um IRMÃO do conteúdo, desenhado por cima desse fundo. Um nome
  de app posto direto na imagem media-se contra o navy da tela, e passava
  (mutante medido em 26/09). Hoje um `TextureRect` por trás, num contentor que
  empilha ou ancorado ao pai inteiro, dá PENDÊNCIA; texto sobre ilustração
  vive numa peça opaca, leva um CONTORNO opaco de pelo menos `CONTORNO_MIN`
  px — que a régua mede como o fundo da letra —, ou fica `fora` com o motivo
  escrito (`066`).
  ⚠️ **E COMPOSIÇÃO QUE NÃO FECHA É PENDÊNCIA, NUNCA VERDE.** Onde o que está
  por trás é desconhecido — o cartão da doca tem alfa 0,96 e pousa sobre o
  MAPA —, a resposta honesta são DUAS: o pior sobre preto e o pior sobre
  branco. Se as duas pontas concordarem em passar, passa; se discordarem,
  reprova e vai à mão. Escolher a ponta que convém é a irmã de arredondar para
  aprovar.
- **⚠️ A ISENÇÃO DA WCAG PARA TEXTO INATIVO PODE ENGOLIR O MOTIVO DO
  BLOQUEIO.** A 1.4.3 isenta o texto de um componente desligado, e a isenção é
  legítima — o desastre é quando a única frase que explica POR QUE ele está
  desligado é o rótulo dele. O painel Construir fazia `btn.text = ... else
  impedimento`: a explicação saía a **2,16:1** e uma régua correta dava-a por
  isenta com razão. E não se conserta acrescentando uma linha (o cartão já
  crescia a ~920px numa tela de 1280, com o "Fechar" rente à borda):
  conserta-se **tirando o botão**, que é um convite falso — o cartão ficou
  60px mais curto. A pergunta que separa o caso bom do mau **deriva do
  percurso**: a forma do rótulo inativo tem de aparecer VIVA nalgum estado.
  "Pagar R$…" aparece, logo descreve a AÇÃO; "Precisa antes de: …" só existe
  bloqueada, logo é a EXPLICAÇÃO. A primeira versão da guarda perguntava "o
  painel tem algum texto legível?", que é confiança de graça — todo painel tem
  um título, e ela passava com o defeito posto (`docs/decisoes/035`).
  ⚠️ **E UMA BORDA TEM DUAS ADJACÊNCIAS, e medir só uma engana.** Texto tem um
  fundo; uma borda tem o que está DENTRO e o que está FORA, e o número muda de
  veredito entre os dois. Medido no pixel da captura em 22/09, a borda do
  trabalhador escolhido dá **7,37:1** contra a barra escura por fora e
  **2,24:1** contra o fundo do cartão por dentro — a primeira leitura da
  sessão publicou o 2,24 como se fosse «a» medida e concluiu que a seleção
  quase não se via. Vê-se: o corte de 3,0 da WCAG **1.4.11** (o que identifica
  ESTADO de componente, e não o 4,5 do texto) passa com folga por fora. O que
  ficava abaixo era outra pergunta — distinguir os dois ESTADOS pela cor, 2,26:1
  entre o âmbar e o verde de repouso —, e quem a responde é a LARGURA, 2px para
  4px. **Antes de julgar uma borda, diga contra QUAL dos dois lados mediu, e
  separe «vê-se a fronteira?» de «distinguem-se os estados?»** (`045`).
  ⚠️ **E NENHUM TOM GANHA DOIS FUNDOS — na interface, quem resolve é trocar
  TEXTO por FUNDO.** É a regra do pau-de-carga (*"UM PROP SÓ ATRAVESSA DOIS
  FUNDOS"*) com um rótulo no lugar do prop. O âmbar de marca mede 2,39:1 sobre
  o cartão branco, e escurecê-lo até passar o AA (5,06:1 a V=0,58) custa a
  separação contra o navy à volta, de 5,27:1 para **2,49:1**. Aceitou-se, e a
  razão é a mesma da telha: **quem separa ali é o MATIZ, não o valor** — estão
  a ~180° um do outro, e a captura confirma. Quem quiser a separação de volta
  não muda a cor, muda a MASSA: âmbar de FUNDO com texto navy mede 5,27:1 e já
  existe no `BotaoPrimario`.
  ⚠️ **E ISSO TEM CONTA: um tom ENTRE dois vizinhos só passa 3:1 contra os dois
  se eles estiverem a 9:1 um do outro**, e abaixo disso o melhor possível é a
  raiz da razão entre eles. A borda do trabalhador escolhido fica entre o verde
  que substitui e o fundo claro, a 5,05:1 — e o âmbar já estava nos 2,25 da
  raiz: "subir a cor" não tinha para onde ir. Faça a conta ANTES de varrer
  cores. Quem deu a troca pela cor foi a MASSA — um selo no rótulo, e não o
  cartão inteiro, porque o retrato tem a luminância do âmbar escuro (0,149
  contra 0,158) e sumia nele: **fundo escolhe-se também contra a ARTE que mora
  nele**, que o D33 não mede (`050`).
  ⚠️ **E COR ESCURA CLAREADA COM BRANCO PERDE O MATIZ.** Os balões por pessoa
  saíram da roupa de cada retrato, e a mistura com branco pôs os três a ΔE
  2,4 a 8,5 uns dos outros — o fato do Sr. Ribeiro e a camisa do Arlindo a
  2,4–3,8: três pessoas no mesmo balão. Tom claro derivado de cor escura escolhe-se
  com o matiz dela e a croma à mão (OKLCH), e mede-se o ΔE entre os IRMÃOS,
  não só o contraste do texto; dois matizes a 16° não se separam claros, e o
  terceiro separou-se pela croma (`067`).
- **⚠️ «ESTA COR É LEGÍVEL?» E «DE ONDE VEIO ESTA COR?» SÃO DUAS PERGUNTAS, e
  quem só tem a primeira acrescenta cor à mão sem ver.** Medido em 21/09: no
  MESMO commit em que migrou três overrides para o tema, o R6 **acrescentou um
  quarto** — e o D33 estava certo em deixá-lo passar, porque a cor nova mede
  5,46:1. O briefing seguinte anunciou "ficaram 18", que é 21 − 3 feito de
  cabeça; contado no HEAD eram **19**. Hoje quem pergunta a segunda é
  `tools/conferir_escopo_ui.py` (`ESCOPO UI OK`), e o registro das exceções é
  `tools/excecoes_cor_ui.json` (`docs/decisoes/036`).
  ⚠️ **E A SUPERFÍCIE ERA O DOBRO DO QUE SE DIZIA, porque cor de interface não
  chega só por chamada.** Contado no que o jogo exporta: 19
  `add_theme_color_override`, mas também **10 `theme_override_colors/*` em
  cena**, **4 cores de `StyleBoxFlat`** em `sub_resource` e **1 pintada num
  StyleBox em código** — 34 ao todo, e as 15 últimas nunca tinham sido contadas
  por ninguém. Todo inventário anterior procurava a CHAMADA.
  ⚠️ **E A EXCEÇÃO DECLARA-SE PELO TRIO (arquivo, receptor, propriedade), COM
  CONTAGEM.** Por arquivo a ficha proíbe — e foi por arquivo que a chamada nova
  passou, já que aquele arquivo tinha outras. Por LINHA não, que é a regra do
  número em pixel escrito à mão com outra roupa. E a CONTAGEM entra na chave
  porque sem ela uma segunda chamada da mesma forma — mesmo nó, mesma
  propriedade, mesma cor — passa por declarada.
  ⚠️ **E A LEVA ESCOLHE-SE PELO QUE A RÉGUA ALCANÇA, nunca pelo tamanho
  dela.** Migrar uma cor que o portão de contraste não monta troca dívida
  VISÍVEL por invisível: o verde do `UpgradePanel` só existe com estrutura
  construída e o âmbar do `DocaCartao` só com doca sob oferta, e o percurso não
  monta nenhum dos dois. A primeira leva foi a barra escura por ser a única em
  que ele já media tudo menos um estado — e esse ganhou-se ANTES de a cor
  migrar, que é a ordem (`docs/decisoes/041`).
  ⚠️ **E «JÁ É MEDIDO PELO D33» É AFIRMAÇÃO A CONFERIR, NUNCA A HERDAR.** O
  registro de exceções afirmava que o contraste dos QUATRO estados da faixa de
  mensagem já era medido, e o briefing da conversa repetia-o. Medido: o
  `_message_label` dava **três linhas em 237**, e as três eram o mesmo estado
  NEUTRO — os outros três nunca tinham sido medidos, e um deles reprovava. A
  afirmação perigosa é a POSITIVA: quando uma entrada diz que o estado NÃO é
  alcançado, a régua confirma-a ao não publicar a linha; «já é medido» só se
  confere CONTANDO as linhas na tabela (`docs/decisoes/042`).
  ⚠️ **E FALA DISPARADA NÃO É FALA VISTA — VALE PARA A RÉGUA DO CONTRASTE.** A
  `033` registou isto para o jogador; a régua caiu no mesmo buraco, por duas
  razões que se somam. O `acao` do percurso corre ANTES de a cena existir, logo
  o `message` que ele provoca sai para ninguém; e mesmo emitido depois, o texto
  entra numa FILA com tempo mínimo, e o que fica no rótulo é a mensagem de
  ABERTURA. Medido: o estado "HUD (nada parado)" tinha uma mensagem BOA presa
  com `pendentes() == 1`, e a régua publicava a neutra de trás dela — uma linha
  com razão e veredito, a descrever OUTRO estado. **Quem mede uma tela que tem
  fila, drena a fila.**
  ⚠️ **E DRENAR SÓ NO FIM NÃO CHEGA, porque a fila ordena por PRIORIDADE.**
  `bad > warn > good`, então duas ações seguidas entregam na tela a de MENOR
  prioridade e não a última: medido, com um dreno único no fim o caso do aviso
  publicava o VERDE da ação anterior. Drena-se depois de CADA ação, que é
  também a ordem em que o jogador as veria.
  ⚠️ **E A FORMA DO CÓDIGO ESCOLHE-SE PELO QUE A RÉGUA ALCANÇA.** O `_pintar()`
  ia trocar quatro ramos por um dicionário com `.get()` — mais arrumado, e
  invisível ao portão: o `conferir_escopo_ui.py` procura
  `theme_type_variation = "<nome>"`, e num dicionário o nome não está depois do
  `=`. As quatro variações ficariam fora da guarda que existe para as conferir,
  e um erro de digitação cairia no `Label` base **sem uma palavra** — a
  armadilha escrita no cabeçalho do próprio portão. São quatro literais
  `&"..."`, como a `041` já escrevia.
  ⚠️ **E ONDE A VARREDURA DE TEXTO NÃO ALCANÇA, QUEM ALCANÇA É UMA PERGUNTA EM
  RUNTIME.** A regra acima diz para escolher a forma do código pelo que a régua
  vê; esta diz o que fazer quando a forma já está escrita e não se pode mudar.
  O `DocaCartao` punha a variação do painel por
  `theme_type_variation = StringName(variacao)` — o mutante X6 da `042` VIVO em
  produção, e medido: com o nome trocado à mão, o portão do escopo sai
  **verde**. Nenhuma regex o apanha, porque a expressão é dinâmica. Quem o
  apanhou foi uma guarda que lê o NÓ MONTADO e pergunta que variação ele está a
  vestir: a regex lê a intenção, a guarda lê o resultado, e o resultado não tem
  como ser contornado por forma de código nenhuma (`docs/decisoes/043`).
  ⚠️ **E ESTADO QUE NÃO MONTA PUBLICA LINHAS PLAUSÍVEIS — é a irmã de «fala
  disparada não é fala vista», um andar acima.** Ali a régua media o texto
  errado; aqui ela mede o ESTADO errado, e o caso que o pediu não se queixa: ele
  monta, mede, e publica linhas verdadeiras sobre outra coisa. O percurso do D33
  montava a oferta do rival escrevendo `docks[d]["rival_offer"]`, **uma chave
  que ninguém no projeto lê** — a irmã do `.get(chave, omissão)`, do lado de
  quem ESCREVE —, e o cartão da doca nunca chegou ao quarto fundo dele. Medido:
  com a guarda retirada, o mesmo arquivo fica VERDE e a tabela publica o estado
  «sob oferta do rival» a mostrar a cor CALMA. **Caso que declara um estado
  prova que o obteve**, e a prova é DERIVADA — vai ver a consequência no nó —,
  nunca declarada ao lado dele.
  ⚠️ **E O PISO DESSA PROVA PODE PASSAR: a contagem tem de ser EXATA.** A
  guarda irmã, no painel Construir, contava os rótulos verdes e pedia `>= o
  número de estruturas compradas`, para não se prender ao desenho do cartão.
  Medido: tirar a variação de UM dos DOIS rótulos de uma estrutura deixa a
  contagem a cumprir o piso, e o rótulo órfão cai no `Label` base, que sobre o
  cartão branco mede 12,58:1 e **passa o contraste**. Nada o via. É a condição
  que a regra do «segundo defeito» nomeia, cumprida em vez de invocada — o
  teto aperta-se quando o defeito seguinte cai fora dele E nada de legítimo cai
  dentro, e uma contagem determinística não tem ruído para a proteger. Escreva
  ao lado o preço: quem acrescentar um rótulo sobe o número de propósito
  (`docs/decisoes/044`).
  ⚠️ **E AGIR PARA ALCANÇAR UM ESTADO CAI DOS DOIS LADOS DO FRAME.** Parece um
  mecanismo só e são dois opostos: a faixa de mensagem precisa da ação DEPOIS
  da cena, porque o texto vive numa fila com tempo mínimo; o painel Construir
  precisa dela ANTES, porque lê o `GameState` enquanto se monta. O `acao_vista`
  nem sequer serve a um painel — exige que a cena TENHA fila para drenar, e um
  painel não tem. Antes de reaproveitar o mecanismo que destravou o estado
  anterior, pergunte de que lado do frame o novo é lido.
  ⚠️ **E VERIFICAÇÃO QUE SE IA PROMOVER A REGRA GERAL PROCURA-SE PRIMEIRO A
  EXCEÇÃO.** `comprar_estrutura()` devolve `false` calado, e a tentação era
  reprovar toda ação do percurso que devolvesse `false`. Medido antes de
  escrever: o caso do aviso da faixa chama `assign_worker` **para ser
  recusado** — é a recusa que emite a mensagem que ele mede —, e a regra cega
  teria reprovado o que está certo.
  ⚠️ **E O REGISTRO DIZ ONDE A COR É DECLARADA, NUNCA QUEM CONSOME A PEÇA QUE A
  CARREGA.** O stylebox `pilula` tinha duas cores declaradas e CINCO
  consumidores — as quatro pílulas por `styles/panel` e o botão Pausar por
  `styles/normal` —, e o portão não podia dizê-lo, porque uma referência ao
  stylebox não é uma cor. Movê-lo para o tema pelo inventário das CORES deixou
  o `Main.tscn` sem carregar. Antes de mover uma peça de estilo, procure todo
  `SubResource("<id>")`: a peça tem consumidores que a cor não tem. E um
  `Button` não veste variação de `PanelContainer`.
  ⚠️ **E O FUNDO VERIFICA-SE PELA FRENTE.** Guarda nenhuma aqui mede a cor de um
  FUNDO; o que se mede é o texto CONTRA ele. Logo a prova de que uma variação
  de stylebox chegou mesmo aos nós é pintar o stylebox de outra cor e ver as
  razões moverem-se em bloco — 12 reprovas, que são 4 números × 3 estados.
  ⚠️ **E VARIAÇÃO QUE EMPACOTA TAMANHO COM COR NÃO SERVE A QUEM SÓ QUER A COR.**
  O `RotuloSecao` traz `font_size = 13`, e os quatro rótulos que pediam a cor
  dele medem 12, 13, 15 e 12 px: vesti-los dele encolheria três e mexeria no
  leiaute que o D18 e o D22 medem, numa migração que só devia mexer na COR. Daí
  o `RotuloApoio` ser **só cor** — o irmão do `RotuloAlerta`, que já não declara
  tamanho pela razão simétrica. Duas variações com o mesmo valor não são a
  divergência calada que se veio acabar quando a diferença entre elas é
  ESTRUTURAL; o `COR_PASSADO` a 0,52 contra os 0,50 do tema era cosmética, e
  por isso foi **apagado** em vez de renomeado.
  ⚠️ **E `theme_type_variation` PARA UMA VARIAÇÃO QUE NÃO EXISTE NÃO DÁ ERRO** —
  cai no tipo base e sai com a cor errada, que é a irmã do valor de Godot 3 numa
  chave de Godot 4. O portão exige que toda variação usada esteja no tema.
- **Texto que passa a vir de uma TABELA cresce, e Label que não cabe não dá
  erro — corta.** O motivo da escala pôs no cartão da doca uma palavra vinda de
  `MOTIVOS`, e "Armazenagem" tem quase o dobro de "Granel". Medido: o interior
  do cartão dá 200px, e o nome mais longo no CABEÇALHO, ao lado do valor a
  19px, pede 233 — sairia cortado na captura sem nada a apontá-lo. Quem põe
  texto de tabela na interface mede o PIOR CASO montado à mão, e não o que os
  três cartões calham mostrar: um deles diz "aguardando barco" e passaria
  sempre. O bloco D18 do teste de design faz essa conta.
- **⚠️ E O `size` DO RÓTULO NÃO É O QUE ELE DESENHA.** `AUTOWRAP_WORD` só
  quebra em fronteira de palavra, e a tela de nomes aceita 24 letras sem
  espaço: com elas «Boa tarde, WWWW…» passava por FORA do cartão com o
  retângulo do rótulo intacto. Quem mede o desenho é `get_character_bounds()`,
  e o controle que o prova é medir pela caixa com o defeito posto — ficou
  VERDE. Fala que leva nome quebra por `AUTOWRAP_WORD_SMART`, que num texto sem
  palavra longa dá as mesmas linhas ao pixel (`051`).
- **⚠️ E UM RÓTULO COM QUEBRA AO LADO DE QUEM EXPANDE FICA COM LARGURA ZERO.**
  O `Icones.rotulo` dá ao texto `AUTOWRAP_WORD` e `EXPAND_FILL`, que servem a
  uma linha sozinha. Ao lado de uma coluna que expande, o «Construída» ficou
  com 1 px e desenhou-se por cima da borda do cartão, e o selo «Escolhido»
  saiu como uma lasca — duas vezes numa sessão, com as suítes verdes. O D19
  mede-o: texto de uma linha não pede mais do que o sítio dele (`081`).
- **⚠️ O DESLIGADO ESCOLHE-SE CONTRA O FUNDO ONDE O BOTÃO VIVE.** O `botao_off`
  azul-claro é certo no cartão branco; no rodapé escuro punha o botão que não
  se prime a 12,99:1 contra o fundo e o «AVANÇAR DIA» a 7,38, e o olho ia
  primeiro ao que não se pode fazer. Hierarquia mede-se: o D43 exige que nada
  do rodapé que não seja o primário passe o contraste dele (`081`).
- **⚠️ E ÁREA ROLÁVEL NÃO CORTA — ESCONDE, que não deixa marca.** A regra acima
  é sobre `Label` que corta; num `paragrafo_rolavel` o que não cabe desce para
  baixo da dobra sem sinal nenhum. Acrescentar quatro linhas ao diário (~100px)
  fez a primeira tela acabar a meio de *"Talvez o avô soubesse o que tava
  fazendo quando"* — a frase que FECHA o texto —, com o botão logo abaixo a
  convidar a sair sem rolar. **As cinco suítes passaram; quem apanhou foi a
  captura.** Altura de painel com texto é CALIBRADA contra o texto, e o
  `PainelDiario` até dizia no comentário que já tinha sido medida uma vez: quem
  cresce o texto refotografa o painel e confere qual é a última linha visível.
  ⚠️ **E A ALTURA ESCRITA À MÃO ESCONDEU METADE DA PEÇA DURANTE ONZE DIAS.** A
  lição acima foi aprendida no diário em 11/09 e remediada lá; o painel IRMÃO —
  o fim de Fase 1, o mesmo `paragrafo_rolavel` — nunca foi reaberto. Ele dava
  430 px a um texto que pede **847**: o remate (*"Em quem tá olhando."*, a linha
  para onde a peça inteira anda) nunca esteve na tela sem rolar, com o botão
  logo abaixo a convidar a sair. É a regra "ao corrigir um, VARRA OS IRMÃOS"
  a cobrar a fatura — e a correção certa não é medir outra vez à mão: a altura
  passou a sair de `altura_do_texto()`, e o **D22** tranca-a.
  ⚠️ **E MEDIR TEXTO PEDE O `line_spacing` POR FORA.** O
  `get_multiline_string_size()` devolve só a soma das linhas; o `Label`
  acrescenta o espaçamento ENTRE elas. No fim de fase isso são 99 px em 847
  (33 × 3) — ~12% —, e a conta sem eles esconde a última dobra, que é o mesmo
  defeito a reaparecer dentro da função escrita para o acabar.
- **⚠️ E O PAINEL SÓ É BRANCO ENQUANTO FOR UM CARTÃO.** A regra acima tranca a
  cor NEUTRA sobre o branco; esta é a outra ponta, e apareceu no menu-celular de
  13/09, a primeira tela deste jogo com fundo escuro: a cor de texto **padrão**
  do tema é navy, porque os doze painéis anteriores eram cartões brancos, e
  sobre a tela do aparelho ela sai navy sobre navy — **1,18:1**, invisível, sem
  erro nenhum. Tela de fundo escuro leva variações de rótulo próprias, e o
  **D23** mede-as (o neutro do jogo dá 5,05:1 ali, que é a primeira vez que ele
  está no fundo para o qual foi feito).
- **⚠️ O PIOR CASO DE UM RÓTULO SAI DO QUE O JOGO ESCREVE, não de um texto
  suposto.** Irmã do D18, um passo antes: ali a lição é medir o pior caso em vez
  do que os três cartões calham mostrar; aqui é que **o pior caso também não se
  inventa**. O D23 montou à mão `"Construir · 7 estruturas"` e o jogo escreve
  `"Construir · 7 disponíveis"` — a palavra real é mais longa (240 px contra
  235), e a asserção media um caso mais fácil do que o que o jogador vê. Quem o
  apanhou foi a CAPTURA. Monte o estado, e leia o `text` de quem o escreve.
  ⚠️ **E O FORMATO TAMBÉM NÃO SE COPIA.** O D18 escrevia à mão os formatos do
  cartão da doca e da fila, e um texto mudado no cartão passaria verde contra
  a cópia velha. Os textos dos dois cartões são funções estáticas, e o D18
  chama-as com o pior caso (`083`).
- **⚠️ MEDIR LARGURA DE `Control` TEM DUAS ARMADILHAS, e as duas dão folga que
  não existe.** (a) **`custom_minimum_size` menor do que o conteúdo é
  IGNORADO** — o botão de menu declara 46 e ocupa 54, porque o ícone de 26 mais
  as margens de 14+14 do tema pedem mais; e o defeito injetado que baixava o
  mínimo **não pegou nada**, porque não mexia no que a guarda mede. (b) **`size`
  de um painel acabado de instanciar é o tamanho MÍNIMO**, e num `Button` o
  mínimo sai do próprio texto: `pede <= botao.size.x` passava com 5 px de folga
  e não reprovava alargar o vizinho, porque o esperado e o medido saíam da mesma
  fonte. É a armadilha do espelho em forma de pixel. Derive a largura do
  CONTENTOR — a linha menos o irmão menos a separação — e peça
  `get_combined_minimum_size()` quando quiser o que uma peça ocupa mesmo.
- **⚠️ NUMA GRELHA, UM NOME COMPRIDO ALARGA UMA COLUNA E NÃO TODAS.** Custou um
  defeito injetado que falhou **por 4 px**: com cinco apps em três colunas, o
  nome longo caía sozinho na coluna dele, então a conta não é `3 × maior`, é a
  soma dos máximos por coluna. Ao montar o estado que aperta uma guarda de
  grelha, pergunte em que COLUNA o defeito cai.
- **⚠️ E PROPORÇÃO É O QUE FAZ UMA METÁFORA LER — antes do ícone e antes da
  moldura.** O menu-celular nasceu com o `montar(largura, 0)` do andaime, que
  ajusta a altura ao conteúdo, e saiu **400 × 390**: com cantos redondos, borda
  e grelha de apps, lia-se como mais um cartão. A **680** (1:1,7) ninguém
  pergunta o que é. É a única altura fixa deste projeto que não é defeito, e a
  diferença está escrita na constante: a faixa branca que mordeu três painéis
  era cartão SEM CONTEÚDO; ali é a tela de um telefone com lugar para o que vem.
- **⚠️ NÚMERO QUE O PAINEL PROMETE CONFERE-SE CONTRA O QUE O JOGO FAZ, e
  «usa a mesma função» não é essa prova.** Ela diz que a chamada é a mesma,
  não que o sorteio a aplique, nem que o preço mostrado seja o que o
  `_fechar_negocio()` escreve. O F14 do `teste_fumaca` lê a previsão na TELA e
  o resultado no JOGO — o saldo depois de pagar, o preço de cada botão, o que
  sobra depois de uma recusa, e a chance pela frequência do sorteio; o F15 faz
  o mesmo nos painéis do HUD (`065`). Mostrar a consequência antes da escolha
  é assumir uma promessa: quem a escreve, escreve a guarda
  (`docs/decisoes/062`). Medido na `090`: o dia da obra trocado nos DOIS
  leitores (mensagem e cartão) concordava consigo mesmo, e só a conferência
  contra o jogo o reprovou.
- **⚠️ OS ÍCONES TÊM DOIS DESENHOS, e um deles some no selo claro.** Os do
  HUD são traço CLARO para a barra escura; os de painel têm disco navy. O
  `doca` (traço `#f0f6ff`) foi fantasma no painel branco e, em 26/09, no selo
  do cabeçalho, que é `#f0f6ff` — contraste 1,00. Hoje o **F2b** do
  `teste_fumaca` lê cada ícone que um cabeçalho recebe e exige a MEDIANA dos
  pixels acima de 1,3:1 contra o selo; ele não diz que o âmbar (1,63) se lê
  bem, só que o ícone não é da cor do fundo (`docs/decisoes/066`).
- Alvo de toque mínimo 44px. O teste de design cobre.
- Dinheiro sai por `GameState.moeda()` — separador de milhar, um lugar só.
- O tema (`ui/tema_brport.tres`) é o ponto único de estilo. Script não pinta
  cor na mão.
  **CheckButton ligado sob toque usa `hover_pressed`, não só `pressed`.**
  Sem esse estilo, o padrão do motor pode ser transparente com letra branca
  sobre cartão branco (`132`). Meça os estados normal, hover, pressed e
  hover_pressed; uma foto sem o ponteiro sobre o controle não prova o último.
  ⚠️ **E COMENTÁRIO NO `.tres` LEVA `;` EM CADA LINHA.** Em 25/09 um bloco de
  sete linhas com o `;` só na primeira partiu o parse do tema inteiro: as cenas
  abriram sem ele, e a fumaça passou verde porque conferia que o arquivo
  EXISTE. Hoje o F1 carrega todo `.tres` (`docs/decisoes/064`).
- ⚠️ **UM `Container` DESFAZ O GIRO DO FILHO, e não dá erro.** Ao arrumá-lo
  (`fit_child_in_rect`) ele reescreve a `rotation` e a `scale`: a foto colada
  e a etiqueta do caderno nasceram rodadas num `VBoxContainer` e saíram a
  direito, com o giro escrito ao lado. Peça rodada vive num `Control` simples
  que o contentor arruma, e é ela, lá dentro, que roda (`067`).
- ⚠️ **SHADER SÓ COMPILA ONDE É DESENHADO — e as suítes headless não desenham
  nada.** O primeiro shader da virada da folha redefinia `PI`, e as seis
  suítes passaram verdes; quem o apanhou foi a captura, com `SHADER ERROR` e
  backtrace. **Shader novo leva um tiro na bateria que o DESENHE**, que é a
  única prova de que compila — o `nomes_virando` fotografa a folha a meio da
  curva (`067`). E o `ColorRect` que o carrega tem cor de alfa zero: a régua
  do contraste lê a `color` dele como o fundo do texto, e o shader não a muda.

## Cor e fundo (da seção «Arte»)

- **Contraste depende do FUNDO, e isso vale para sombra como vale para cor.**
  Irmã da regra acima, e mordeu no mesmo dia: a sombra do tema é navy (lum 49)
  e o fundo da barra inferior é #0d1a26 (lum 24) — pôr sombra nos cartões
  escuros desenharia um HALO. Cartão escuro sobre fundo escuro ganha corpo por
  borda, não por sombra. Antes de aplicar profundidade, amostre o fundo.
  **Cor de texto sobre fundo colorido mede-se com a WCAG**, não se escolhe: o
  âmbar do tema com rótulo branco dá 2,39:1 e reprova até o corte de texto
  grande (3,0); com rótulo navy dá 5,27:1 e passa o AA.
- **Cor calibrada para um fundo não atravessa para outro sem medir de novo.**
  O cinzento-azulado que marca texto neutro sobre o fundo ESCURO do jogo
  (0,51/0,6/0,706, usado no aviso de trabalhador ocioso) foi reaproveitado
  sem medir no calendário (03/09), sobre CARTÃO BRANCO: mediu 2,93:1, abaixo
  do corte de texto grande da WCAG (3,0). Reaproveitar cor entre dois fundos
  diferentes é reaproveitar cor nenhuma — é medir duas vezes.
