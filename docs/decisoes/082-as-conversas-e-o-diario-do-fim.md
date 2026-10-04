# 082 — As conversas como no celular, e o fim de fase no diário

**04/10/2026 · segunda parte da melhoria de design** (plano v3, §7): a
conversa abriu com a pergunta do escopo, e o Bruno escolheu **as telas
narrativas** (a recomendada), entre o mapa e os props e o design de jogo.
**Aceite do Bruno em 04/10**: as conversas na segunda passagem, o fim de fase
na terceira.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A parte do jogo | **As telas narrativas** (a recomendada: o fim de fase, o momento de mais peso, lia-se como um extrato; o mapa acabava de ter dez passagens aceites) |
| O que corrigir nas conversas | As quatro: **o balão na cor da pessoa**, **o retrato solto no branco**, **o título que não muda**, **tudo no mesmo peso** |
| O fim de fase | **Página do diário** (a recomendada) |
| Por onde começar | **As conversas** (a recomendada) |
| Veredito da primeira passagem | **«Ajustar»** nas duas, com o troféu de volta, o celular no seminegrito, o remate no pé da página 2, e no «Outro»: *«Verifique melhorias que podem ser feitas para deixar o design mais bonito e faça»* |
| Veredito da segunda | Conversas **«Aceito»**; fim de fase **«Ajustar»**: *«Tem um texto isolado na segunda página. Veja melhorias para isso e outras coisas»* |
| Veredito da terceira | Fim de fase **«Aceito»** |

## As conversas (Sr. Ribeiro, Arlindo, Dona Cida no boletim)

- **O balão é o da pessoa**, os mesmos três tons do celular (`067`), e o
  retrato senta numa **placa** do mesmo matiz e croma em OKLCH, a L 0,84 — a
  ΔE 16–17 do cartão branco, a mesma moldura para os três. ⚠️ **Menos a do Sr.
  Ribeiro, a 0,88**: o grisalho dele media 1,34:1 contra a placa de 0,84 e
  sumia; a 0,88 fica a ΔE 12,6 do cabelo e 12,0 do branco.
- **A fala longa parte-se em balões, um por parágrafo**, como no celular. A
  primeira versão esticava a placa até ao fim do balão, e o Sr. Ribeiro, que
  fala dez linhas, ficava com 150 px de placa vazia por cima da cabeça. A
  segunda punha os seguidos por baixo da placa, e o vão entre dois balões saía
  do comprimento do primeiro (76 px num, 6 noutro). Na versão que ficou, os
  seguidos descem colados ao primeiro, na mesma coluna.
- **O primeiro balão tem um rabicho** a apontar para a cara (melhoria por
  conta própria, que o «Outro» liberou). O bico do celular — o canto de cima
  quase reto — mal se lia como fala num cartão de cena.
- **A fala é Open Sans Regular** (`ui/fontes/`, OFL, 63 KB em woff2): a letra
  padrão do Godot é a seminegrita e mais nenhuma, e fala, título, tarja e botão
  saíam todos com o mesmo peso. ⚠️ **O celular ficou no seminegrito**, a pedido
  do Bruno: a primeira passagem tinha-o posto também em regular.
- **O título do Arlindo é a pessoa** («Arlindo — Porto Farol»), como o do Sr.
  Ribeiro. Dizia «fez uma oferta» também na despedida, com o negócio fechado.
- A linha de fala vive num sítio só (`PainelNarrativo.linha_de_fala()`), e a
  contra-oferta, que não herda do andaime, deixou de ter a cópia dela. A regra
  do balão de cada pessoa também: o celular usa a do andaime.

## O fim de fase

- **A narração é uma entrada do diário** que o diário abriu na primeira
  semana: «Porto Mirim, quarta semana» (o ordinal sai do `WEEKS_TOTAL`), em
  duas páginas, porque a peça pede 34 linhas de pauta com a data e a folha
  leva 26. **O «—» do meio é a virada da folha**, a mesma da tela de nomes —
  que passou para o andaime (`virar_folha()`), com a foto `nomes_virando`
  igual byte a byte depois da mudança. O texto da peça não mudou.
- **O título fica fora do caderno**, com o troféu, como o «O cais é seu» da
  tela de nomes.
- **O recibo da parcela vai colado na segunda página**, com o picote e o
  carimbo «PAGO»: Banco Porto Mirim, parcela 1 de `PARCELAS_NA_FASE`, o
  valor do `PARCELA_AMOUNT` pelo `moeda()`. Ele veio na terceira passagem: a
  segunda descera o remate ao pé da folha com linhas em branco, e lia-se
  «isolado». O remate voltou ao lugar dele; o vão é do papel que se guarda.
- Depois da segunda página, o «Ver o balanço» abre o balanço de sempre.

## As guardas, e os defeitos que as provam

- **D44** (nova): nos três cartões, o balão e a placa têm o matiz da roupa do
  retrato de quem fala (lido do PNG, como o D38); a fala pesa menos do que o
  título; e a fala de dois parágrafos sai em dois balões, só o primeiro com
  bico.
- **D22** reescrito: as duas páginas juntas são a peça inteira; a data sai por
  extenso; cada página cabe na folha com o nome mais comprido; e a segunda,
  com o recibo montado, também.
- **F10**: vira a folha pelo botão, espera o tempo `segunda_pagina` e confere
  que cada página mostra a sua metade; o **F14** vai ao balanço pelo mesmo
  caminho. As ferramentas de captura esperam o tempo prometido em vez de contar
  frames, e há o tiro `fimfase_2`.

| Defeito injetado | Quem reprovou |
|---|---|
| A cena do Sr. Ribeiro passa a Dona Cida como quem fala | D44 (a placa e os dois balões) |
| As placas do Ribeiro e do Arlindo trocadas | D44 (a placa) |
| A `TextoFala` sem a fonte | D44 (os quatro balões: 600 contra 600) |
| A fala sem partir em parágrafos | D44, só ele — o F17 e o T13 comparam texto, e o texto continua certo |
| A fala sem o segundo parágrafo | D44, F17 e T13 |
| A virada partida no `\n\n` em vez do «—» | D22 (13 páginas) |
| O ordinal em dígito | D22 |
| A segunda página com a primeira metade | F10 |
| O remate uma linha abaixo do pé (segunda passagem; a guarda saiu com ele) | D22 |
| O recibo a pedir 500 px | D22 (pede 866, cabe 804) |

## O que se achou pelo caminho

- **Uma função nova na classe base partilha o nome com uma das filhas**, e a
  filha deixa de compilar: o `_vestir_balao()` estático do andaime colidia com
  o do `PainelMensagens`, e o `run_tests` imprimiu `TODOS OS TESTES PASSARAM`
  com o `SCRIPT ERROR` na saída (`CLAUDE.md`, «Estilo de código»).
- **O rótulo com quebra automática pede 5.136 px** ao `get_combined_minimum_size()`
  antes de um passe de layout: a coluna da página não se mede inteira, e o D22
  mede o texto pela pauta e o recibo, que não quebra, pelo tamanho dele.
- **O sublinhado da data é da DATA**: a página que continua uma entrada pauta
  pelo próprio texto, e a primeira foto saiu com o traço por baixo de «O píer
  é o mesmo» (`FolhaDoCaderno.sublinhar`).
- **O `HSeparator` girado sai em escada**: é uma linha de 1 px sem suavização.
  O picote do recibo é um tracejado suavizado.

## O que não se fez

- **O balão do Sr. Ribeiro continua quase branco** no cartão (ΔE 4,6): foi
  oferecido duas vezes, com o filete na cor da placa, e o Bruno não o marcou.
- O rabicho não foi ao celular, e a página 1 do fim de fase guarda as linhas
  em branco por baixo de «ainda é nosso.» — ofereci, e não foram marcadas.
- O balanço que vem a seguir ao caderno não mudou.
- Os textos novos — «Porto Mirim, quarta semana», «Virar a página», o recibo e
  «Arlindo — Porto Farol» — entram na leitura em voz alta do A4.
