---
paths:
  - "brport_vs/tools/capturar_*.gd"
  - "brport_vs/tools/folha_*.gd"
  - "brport_vs/tools/recortar_captura.gd"
  - "brport_vs/tools/caras_na_foto.gd"
  - "brport_vs/tools/estado_da_bancada.gd"
  - "tools/capturar_evidencia.sh"
  - "tools/conferir_cobertura_paineis.py"
  - "tools/trilha_de_arte.*"
  - "tools/medir_nitidez_captura.py"
  - ".github/workflows/captura.yml"
---

# Regras — captura e folhas de contato

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## Do «Antes de fechar», item 5 — tire uma captura e olhe

O passo está no item 5 do núcleo. As armadilhas:

   ⚠️ **E A SEMENTE DO JOGO NÃO É A SEMENTE GLOBAL.** O `seed()` do Godot
   semeia o gerador global; o `GameState` sorteia com um
   `RandomNumberGenerator` próprio, que o `_ready()` dele `randomize()` — quem
   quiser foto reprodutível escreve `GS._rng.seed`. O `capturar_tela.gd`
   fazia-o e o `capturar_cena.gd` não, e isso só apareceu no dia em que um
   painel fotografado passou a ler o sorteio: duas corridas do mesmo código
   deram R$16.104 e R$0.
   **Captura só se compara com semente E passo de tempo fixos.** É o que o
   `tools/capturar_evidencia.sh` faz, e as duas fazem falta: com a semente
   sozinha, duas corridas do MESMO código davam 1.030 pixels diferentes,
   porque os tweens em laço andam por *delta* e não por frame. Quem tirar a
   captura à mão sem `--fixed-fps 60` tem uma foto para olhar, não uma para
   comparar.
   ⚠️ **E FERRAMENTA DE EVIDÊNCIA QUE CONTA VOLTAS NÃO ENTREGA O QUE PROMETE.**
   O `capturar_tela.gd -- N` contava iterações de laço, e a oferta do rival
   gastava uma sem virar o dia: medido em 18/09, `-- 10` entregava o turno 9,
   `-- 34` entregava o 27. Ferramenta que promete um ESTADO avança até o estado
   — `while GS.turn < alvo`, e um teto de voltas para o caso de o estado nunca
   chegar (`docs/decisoes/031`).
   ⚠️ **E CONTAR O QUE ESTÁ ABERTO NO FIM NÃO DIZ O QUE ESTAVA ABERTO
   DURANTE.** A contagem de painéis existe desde que o `porto` saiu com o
   Boletim por cima, e não podia apanhar o defeito irmão: a ferramenta avançava
   turnos por BAIXO do modal — no jogo o botão "Avançar dia" fica debaixo do
   escurecer de todo `PainelNarrativo`, que é um `ColorRect` a tela cheia no
   `CanvasLayer`, logo aquelas fotos são estados que ninguém alcança a jogar.
   Medido: com o defeito injetado, o tiro do boletim chegou ao turno 13 **com
   um painel**, que é exatamente o número que a guarda velha exigia. Guarda de
   ESTADO FINAL não prova PROCESSO — cada tiro passou a declarar também o TURNO
   em que pára, e é isso que reprova.
   E ao recortar a captura para conferir um detalhe, lembre que
   **o mapa não começa no topo da tela**: `MapaWrap` tem `offset_top = 62`, e
   as coordenadas que saem da projeção são do MAPA. Somar os 62 é a diferença
   entre olhar o prop e olhar o telhado ao lado dele — três recortes já foram
   ao lugar errado por causa disto.
   ⚠️ **E VALE IGUAL PARA QUEM ANDA PELA ÁRVORE DE NÓS, que é onde ele se
   disfarça.** Uma ferramenta que some os `offset` de pai em pai apanha o do
   `MapaWrap` sem o ver, e o erro não se parece nada com um recorte torto — sai
   uma cor plausível, do sítio errado. Quem lê coordenada de mapa começa a
   contar NO `MapaWrap`, e não na raiz da cena (mordeu na `folha_props`, 16/09).

## Do «Antes de fechar», item 6

6. **Captura de painel sem tema é uma fotografia mentirosa.** No jogo quem
   aplica o tema é o `_abrir_painel()`; cena instanciada solta nasce com o
   cinzento padrão do Godot. O `capturar_cena.gd` já o aplica, e também chama
   `setup()` com os argumentos extra — sem isso os painéis que dependem dele
   saem VAZIOS e a captura passa por "a cena abre" sem mostrar nada.
   ⚠️ **E O AUTOLOAD NÃO NASCE VAZIO — ele tenta `load_game()` ANTES de
   `new_game()`.** Logo toda ferramenta que fotografe uma cena solta herda o
   autosave que estiver em `user://`, e a bateria tira as fotos de JOGO
   primeiro, que gravam. Medido em 12/09: o painel da parcela afirmava que
   R$498.200 eram "menos de uma das estruturas que faltam" porque o save da
   foto anterior já tinha as SETE construídas — com partida nova a mesma
   quantia compra quatro. **Foto que depende do que está no disco não compara
   nada**, e é a regra de a ferramenta DERIVAR o estado outra vez: o
   `capturar_tela.gd` já fazia `clear_save()` + semente + `new_game()`, o
   `capturar_cena.gd` não fazia, e o que prova o conserto é rodar a bateria
   DUAS vezes e exigir os mesmos bytes.
   ⚠️ **E A SUÍTE DE DESIGN TAMBÉM O HERDAVA:** o `_main` dela nascia do save
   que a ferramenta anterior deixou — 1114 asserções com o disco em ruínas e
   1148 com o porto completo, verde nas duas (`081`). Desde 09/10 o `_rodar`
   deriva o estado e o D14 monta ele próprio a ruína e o porto completo: os
   três discos dão as mesmas linhas, uma a uma (`REVISAO_GERAL_2026-10-09.md`).
   ⚠️ **E A GUARDA QUE PULA O `setup()` CAVA O BURACO QUE O COMENTÁRIO AO LADO
   DESCREVE.** No mesmo dia: o `capturar_cena.gd` só chamava `setup()` quando
   havia argumentos extra na linha de comando, e os quatro painéis cujo
   `setup()` não EXIGE argumento — Calendário, Docas, Parcela, Reputação —
   nunca o recebiam. A captura saía com o escurecer e um cartão de altura zero,
   imprimia "Tela salva em" e passava por boa; o Diário escapou por montar no
   `_ready()`, e foi por isso que isto viveu escondido. **Condição de atalho
   numa ferramenta de evidência é uma foto que ninguém tirou.**
   ⚠️ **E PAINEL FOTOGRAFADO EM PARTIDA NOVA PROVA QUE A CENA ABRE E MAIS
   NADA.** A cena solta nasce no turno 1 do porto em ruínas, e é exactamente aí
   que os painéis do HUD não dizem nada: no dia 1 o calendário não tem dia
   PASSADO, em ruínas o Construir não tem cartão VERDE, com uma doca a contagem
   nunca passa de 1 — que é onde o singular e o plural dão o mesmo texto — e a
   reputação está no patamar de partida, onde um "▸" que ande não se distingue
   de um pregado. Escrever o estado à mão (`turn=9`) põe o rótulo certo com o
   resto parado no dia 1: verdadeiro no rótulo, falso no resto. Uma partida
   JOGADA deriva tudo de uma vez — é o `--painel=<nome>` do `capturar_tela.gd`,
   que abre cada um pela PORTA DO JOGADOR e traz de graça as guardas do turno e
   da contagem de painéis, que a cena solta não tem (`docs/decisoes/038`).
   ⚠️ **E A PORTA DO JOGADOR TAMBÉM TEM FASE.** Tocar no botão verdadeiro não
   basta: o `pay_debt()` sai CALADO fora de `debt_payment`, e numa cena solta
   o «Pagar» mostrava a resposta de quem pagou sem o dinheiro ter mudado de
   mãos — texto certo, estado que não existe a jogar. A montagem
   `parcela=vencida` chega lá pelo `advance_turn()`, e o F10 prova-o pelo
   `parcela_paid` (`051`).
   ⚠️ **E COBERTURA DECLARADA MENTE; COBERTURA MEDIDA NÃO.** Cada guarda de
   captura responde pelo SEU tiro — a imagem saiu, o erro não apareceu, a
   contagem e o turno batem — e **nenhuma responde pelo CATÁLOGO**, que é como
   cinco painéis viveram sem foto. A saída fácil é o tiro declarar ao lado dele
   o que cobre, e essa declaração mente: medido, um tiro que prometia o Caixa e
   fotografava o Calendário passou a contagem (1 painel), o turno (13) e o
   tamanho (306.639 bytes). Quem o apanhou foi a FOTO — as duas ferramentas
   imprimem `Paineis: res://...` com a cena de cada painel na tela, e o
   `tools/conferir_cobertura_paineis.py` lê os logs contra o que o `Main` abre
   (`docs/decisoes/039`).
   ⚠️ **E INVENTÁRIO QUE OLHA UMA PASTA PERDE O QUE NÃO ESTÁ NELA.** Três
   sessões contaram os painéis deste jogo e as três disseram treze; são
   **quinze**. O `EndGame.tscn` não vive em `scenes/panels/` — está em
   `scenes/`, e por isso escapou a todos —, e a `TelaNomes` escapa por outro
   caminho: o `capturar_tela.gd` dispensa-a DE PROPÓSITO, com `definir_nomes()`,
   para ela não tapar o que se ia fotografar. **A convenção de pasta é uma
   suposição sobre o conteúdo**, e quem conta pergunta ao que o jogo ABRE, não
   ao que a pasta guarda.
   ⚠️ **E UM PAINEL NÃO É UMA TELA.** A cobertura perguntava por CENA, e a do
   Sr. Ribeiro são três — entrada, pagou, não pagou. A bateria fotografava só
   o primeiro tempo de cada painel, e a despedida do Arlindo viveu dez dias a
   dizer «Cliente ouvindo a proposta. (2 tentativas)» por baixo de um negócio
   fechado. Hoje o catálogo desce ao TEMPO (`tempo = &"<id>"`, sempre
   literal), e o que não se pode fotografar fica DECLARADO como lacuna — a
   afirmação perigosa é a positiva, e a lacuna só envelhece para o lado que
   reprova (`docs/decisoes/051`).
   ⚠️ **E UMA TELA NÃO É UMA CARA.** O boletim é um painel de um tempo só, e
   a Dona Cida tem nele três caras — a do tom da semana: a bateria mostrava a
   séria, e a cobertura por tempo dava-o por fotografado. Hoje as ferramentas
   imprimem `Retratos:` só depois de ESCONDER a cara e ver a foto mudar (com
   o ruído da janela a zero), e o conferidor lê o `POR_EXPRESSAO`. E a cara de
   um tempo lê-se no nó, não no nome: a «entrada» do Sr. Ribeiro mostra a
   FORMAL, e o briefing contou-a como sem foto (`060`).
   Para olhar um detalhe pequeno, `tools/recortar_captura.gd` amplia sem
   suavizar: a 19px um ícone não se julga a olho na captura inteira, e foi
   ampliando que se viu que o ícone `doca` era um fantasma no painel branco.
   **E a própria ferramenta de captura tem números que envelhecem.** O
   `capturar_tela.gd -- N foto.png completo` dava R$100.000 ao jogador para
   comprar o porto inteiro; depois da reescala o porto passou a custar
   R$785.000, as duas últimas compras falhavam, e a foto saía com o porto A
   MEIO chamando-se "completo". O caixa vem da tabela de preços agora — como
   na suíte. Ferramenta que finge um estado tem de o DERIVAR do estado.

## Foto adiantada e asset velho (do item 7)

   ⚠️ **E FOTO ADIANTADA É PIOR DO QUE FOTO ERRADA, porque parece um defeito
   do que se acabou de construir.** É a regra dos dois frames com a roupa de
   uma captura. Em 19/09 o tiro novo do histórico de mensagens abria o painel
   na mesma volta em que o laço de turnos acabava: a lista saía com CINCO
   entradas enquanto a faixa por trás já anunciava "+7", porque três falas
   daquele turno ainda estavam em `call_deferred`. A foto era verdadeira do
   instante em que foi tirada e mentia sobre o sistema. **Ferramenta que
   fotografa depois de agir espera o que a ação deixou pendente** — e num
   projeto onde a fala entra por `call_deferred`, esperar é medido em frames.
   ⚠️ **E A FERRAMENTA JOGA NO FRAME EM QUE MONTA O `Main`.** O
   `capturar_tela.gd` vira os N dias todos dentro do `_montar()`, antes de
   correr um único `call_deferred`: o que espera o fim do frame não vê o
   primeiro dia. Em 12/10 o tutorial do Toninho olhava o fundeadouro no fim
   do frame, e a foto do dia 2 saiu sem a fala séria — um instante que
   nenhum jogador alcança, mas que mostrou que a fala dependia do FRAME e não
   do estado.
   Corrigiu-se o tutorial, não a ferramenta (`101`): comportamento que muda
   com o frame em que o dia vira é o defeito, e a foto foi quem o viu.
  ⚠️ **E VALE IGUAL PARA A CAPTURA: regerou arte, `--import` ANTES de
  fotografar.** Em 13/09 duas rondas de retratos foram fotografadas ao asset
  VELHO — o Godot desenha o `.ctex` de `.godot/imported/`, e a foto saiu
  bonita, verdadeira na aparência e sobre o desenho de antes. É pior do que
  não fotografar, porque se passou a discutir o que já estava corrigido.

## O prop que a captura não vê (da seção «Arte»)

- **Prop que a captura não vê é prop que ninguém revê.** A travessia do
  caminhão nasceu com um desvanecer de 1,1 s no INÍCIO do ciclo, e as cinco
  fotos do CI assentam em poucos frames: o caminhão saía invisível de todas
  elas. Animação nova começa no estado VISÍVEL, e o desvanecer vai no fim.
  ⚠️ **E A CAPTURA DE JOGO SÓ MOSTRA O QUE O SORTEIO ESCOLHEU.** Em 07/09 os
  cascos passaram a ser seis (um por par de classe e motivo) e os camiões oito;
  as cinco fotos de jogo mostraram **dois** cascos e **um** camião, porque quem
  decide o que atraca é a partida. Passaram no `asset_validator`, no D13 e no
  D17 — nenhuma dessas perguntas é "dá para olhar". Arte que varia com sorteio
  prova-se com uma FOLHA DE CONTATO que percorre a tabela: é o que a
  `folha_icones.gd` já fazia para os ícones e o que a `folha_frota.gd` passou a
  fazer para a frota.
  ⚠️ **E ARTE PRESA A UM ESTADO DO JOGO NÃO É SORTEIO — É PIOR.** O sorteio ao
  menos pode calhar; um estado que nenhuma foto monta não calha nunca. Os
  barcos de pesca só atracam no porto de NÍVEL 1, e das oito imagens do CI de
  então o `inicio` era o turno ZERO (docas vazias) e as outras portos de nível 2 e
  3: a frota inteira do começo do jogo não tinha foto nenhuma, e é o estado onde
  o perfil Descuidado passa a partida toda. Ao acrescentar arte que uma
  condição do jogo destrava, pergunte QUAL das capturas monta essa condição —
  e se nenhuma monta, o tiro novo faz parte da entrega.
  ⚠️ **E A PRANCHA NÃO ALCANÇA UM DIA DE OBRA** (`122`). Ela joga 16 turnos à
  espera de ver o prop e reprova («não teve foto do jogo em 16 turnos»): o
  pátio só abre depois da primeira cobrança e a obra dura dois ou três dias.
  Quem monta a obra no quadro pedido, com os vizinhos de uma partida semeada,
  é `brport_vs/tools/capturar_obra.gd`, e troca a textura de um nó por uma
  candidata lida do arquivo — a mesma foto que a prancha daria, sem os números.
  ⚠️ **E O ESTADO PODE NÃO EXISTIR NUNCA, com tudo verde.** A animação do
  trabalhador ia ligar-se com `progress > 0`, o «operando» de sempre — e o
  pesqueiro, o único barco do nível 1, parte no MESMO avanço em que o
  `progress` chega a 1. Medido em 20 partidas: 449 instantes de alocado com
  barco, zero com `progress > 0`; o balanço antigo nunca tinha tocado ali.
  Antes de prender arte a um predicado, meça-o no estado em que ela aparece
  (`075`).
  ⚠️ **E CÓDIGO QUE NUNCA CORREU ESCONDE O DEFEITO DELE.** A chegada
  deslizante do barco estava escrita desde o início e não corria: a virada
  esvazia a doca e enche-a em dois sinais, e o primeiro zerava o id de que
  ela dependia — 0 de 21 barcos. O rumo dela atravessava o píer, sem ninguém
  o ver, e a primeira pergunta ao Bruno descreveu-a como se corresse, lida no
  comentário. Antes de herdar um comportamento escrito, ou de o descrever,
  meça se ele dispara (`078`).
  ⚠️ **E «AS FOTOS NÃO MUDARAM» PEDE UM CONTROLE POSITIVO, senão é verde de
  graça.** A calibração — duas corridas da MESMA árvore com os mesmos hashes —
  prova que a bateria não tem ruído PRÓPRIO; **não** prova que ela veria a
  mudança que se acabou de fazer. Medido em 22/09, ao escurecer o texto de
  aviso da faixa de mensagem: mudaram **zero** das 24. O controle responde —
  pintar o texto NEUTRO da mesma faixa de vermelho mexeu **12 das 24**, logo a
  bateria vê a faixa em metade das fotos, e **as doze mostram-na sempre no
  estado neutro**. A cor mudada não aparece em foto nenhuma. É a regra do
  mesmo arquivo dos dois lados com um PNG no lugar do arquivo: zero só quer
  dizer zero depois de um par que se sabe diferente ter dado muito
  (`docs/decisoes/042`).
  ⚠️ **E A CALIBRAÇÃO CORRE-SE, NÃO SE SUPÕE: a bateria tem uma foto que
  muda sozinha.** Medido em 11/10, duas corridas da mesma árvore: 65 de 66
  iguais ao byte, e a `trabalhadores.png` a mudar 24.896 pixels — a
  `folha_trabalhadores.gd` sorteia o valor e o motivo dos cartões sem
  semente. Até ela ser semeada, essa foto não prova nada em nenhuma direção:
  o antes/depois do PR #117, que só mexia em suítes, marcou-a «MUDOU» com as
  outras 65 iguais, por baixo de «as imagens são função só do código» (`094`).
  ⚠️ **E A SEMENTE SOZINHA NÃO A SEGURAVA:** a classe do barco de cada cartão
  sai do nível do porto, e esse vinha do save da foto anterior. Semeada e com
  `new_game()`, como o `capturar_tela.gd`, a bateria deu 66 de 66 iguais em
  duas corridas — e é contra esses hashes que o M8 prova cada extração
  (`095`).
  ⚠️ **E O `getbbox()` DO PILLOW NUM RGBA SÓ OLHA PARA O ALFA.** Em 23/09 a
  comparação das 30 fotos contra as da `main` deu **zero** mudadas, com os
  camiões todos noutra faixa: a diferença de duas fotos opacas tem o alfa a
  zero em todo o lado, e o `getbbox()` devolvia `None`. Os `md5` diferiam — foi
  isso que o denunciou. Em RGB, e com o mesmo arquivo dos dois lados a dar zero
  exato, mudaram 14 (`052`).
  ⚠️ **E FOLHA DE CONTATO QUE CRESCE SOZINHA TEM DE REPROVAR AO TRANSBORDAR.**
  Ela é uma captura de 720×1280 e ganha linhas a cada porte, motivo ou classe
  nova: o que passar da última linha é recortado sem uma palavra, e o prop fica
  exatamente como estava — gerado, validado e por olhar, que é o buraco que a
  folha existe para tapar. A conta da altura reprova em vez de recortar.
  ⚠️ **E QUANDO ELA TEM PÁGINAS, QUEM CHAMA DIZ QUANTAS ESPERA.** A dos props
  não cabe numa tela (51 props a 1:1, 28 por página), e uma folha que decida
  sozinha o número de páginas escreve a página nova onde ninguém a vai buscar —
  o `capturar_evidencia.sh` nomeia cada arquivo. Ela recebe `<página> <total>`,
  conta o que o catálogo pede e REPROVA se não bater: acrescentar a chamada faz
  parte de acrescentar o prop.
  ⚠️ **E QUADRO VAZIO NÃO É ERRO PARA QUEM NÃO O PERGUNTA.** Em 23/09 as folhas
  de contato gravaram os doze cascos EM BRANCO e imprimiram "Folha salva em"
  (`049`). A pergunta que apanha é **"esconder a peça muda a foto?"** — duas
  fotos, com e sem a arte, e a diferença por peça: dá zero exato no defeito,
  não depende da cor do chão e não pode ser enganada pelo `get_image()`, que era
  quem mentia. Ferramenta de evidência prova que o que declara ESTÁ na foto.

## Captura no Windows (de «Como rodar»)

**Captura no Windows precisa conferir o tamanho do PNG** (`085`). A criação
da janela encolheu 720×1280 para 720×1175, e o `canvas_items` produziu um PNG
660×1175: a régua de retratos usava coordenadas da viewport sobre pixels
reduzidos. Reaplicar `root.size` com o tamanho configurado depois de a árvore
estar ativa, esperando dois frames, resolveu em wrappers locais das ferramentas.
Não reduza o corte da prova nem altere arte ou viewport para passar essa régua.
