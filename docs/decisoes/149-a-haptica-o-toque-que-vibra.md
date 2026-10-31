# 149 — A háptica: o toque que vibra, e só ele

**31/10/2026 · o terceiro item do tema animação e toque, pela ordem do Bruno
(A1′ → A1 → T1 → A3, `144`): a T1, a háptica.** Branch
`claude/hopeful-ride-f61g1m`, que arranca da cabeça da `148`
(`claude/sharp-lamport-kf55gf`, `0e39079`): o PR #160 dela estava aberto, com
o CI a correr, e é acompanhado noutra conversa. Main `d11311b` no arranque.
O pré-PR deu a 149 por livre.

## O que se mediu antes

- **Nenhuma chamada de vibração no jogo e nenhuma permissão `VIBRATE`**,
  como a `144` dizia: o `grep` por `vibrat` nos scripts, cenas e configuração
  só acha o `permissions/custom_permissions=PackedStringArray()` vazio do
  preset Android.
- **No Linux o `Input.vibrate_handheld()` não faz nada e não se queixa**:
  sondado em `--headless` e sob `xvfb-run`, sem uma linha na saída. Por isso
  o ponto único chama-o sempre, sem perguntar a plataforma, e nem as suítes
  nem a bateria de capturas ganham ruído.
- **A chave do preset** sai de `permissions/` + o nome da permissão em
  minúsculas: o binário do Godot 4.6.3 traz `permissions/` e `VIBRATE`.

## A porta: a mesma do assentar

A pergunta do Bruno no arranque — a obra pronta sai do `obra_concluida`, que
também dispara nas bancadas e nas suítes; segue a vibração a porta do
`_virada_armada` da `148`? **Segue, e a regra vale para os três momentos:
quem pede a vibração é o TOQUE, depois de o `GameState` aceitar.** O
`atracar()` e o `pay_debt()` são chamados direto pelo simulador e pelas
suítes, como o `obra_concluida` dispara nas bancadas: um ouvinte desses
sinais contaria partidas que ninguém tocou. Por isso o `Haptica` não é
autoload (um autoload carrega em todo `--script`) nem ouve sinal nenhum; o
pedido vive onde o dedo cai:

| Momento | Quem pede | Duração |
|---|---|---|
| atracar | o cartão «Ao largo» ao soltar, se o `atracar()` aceitar (`BarcoFila`) | 20 ms |
| obra pronta | o `_ao_concluir_obra()` do `Main`, só com a virada armada pelo «Avançar dia» | 40 ms |
| parcela paga | o «Pagar» do Sr. Ribeiro, junto da resposta «pagou» (`DebtPaymentPanel`), e o «Quitar agora», se o `pagar_parcela_adiantado()` aceitar (`PainelParcela`) | 40 ms |

- **O movimento reduzido não cala a vibração**: são duas preferências, e na
  obra pronta a vibração pede-se antes da saída do RB6.
- **A segunda chance não vibra**: o boleto sai, mas quem o paga é o banco,
  com acréscimo, e a mensagem do jogo é um aviso. Vibrar a conquista ali
  seria comemorar a dívida. É escolha desta conversa, e o Bruno pode
  revertê-la.
- **O «Pagar» sem dinheiro nasce desligado**, e o painel inteiro confia nisso
  (a resposta «pagou» não confere). A primeira versão conferia a parcela
  baixada antes de vibrar; provada só premindo o botão desligado pelo
  `pressed.emit()`, um estado que nenhum toque alcança, era a regra em dois
  sítios (`testes-e-guardas.md`), e saiu.

## A T1, como está no jogo

- **`scripts/Haptica.gd`**: `DURACAO_MS` (momento → ms), `pedir(momento)`
  lê a preferência, conta e chama `Input.vibrate_handheld(ms)`; um momento
  fora da tabela rebenta em vez de vibrar 0 ms.
- **«Vibração» nos Ajustes**, ao lado do som (a secção passou a «SOM E
  VIBRAÇÃO», como nos Ajustes do telefone), com uma linha de apoio que diz o
  que se sente. **Ligada por omissão**, guardada na
  `PreferenciasDeApresentacao` (`apresentacao.cfg`, fora do save), lida com
  a mesma recusa de tipo do RB6: um valor que não é booleano mantém a
  omissão.
- **`permissions/vibrate=true` no preset Android.** O Web vibra pelo
  `navigator.vibrate` do navegador, sem permissão (o Chrome do Android sim,
  o Safari não).

## A guarda, e os defeitos que a provam

- **D54** (`tests/casos_haptica.gd`, no `teste_design`): §1 os três momentos
  pela porta do jogador — o cartão tocado pelo `push_input`, o «Avançar dia»
  na véspera de CADA obra do catálogo, o «Pagar» e o «Quitar agora»
  escolhidos pelo que dizem —, cada um com o dicionário de pedidos inteiro;
  §2 nada sem toque ou conquista (a virada simples com barco a pagar, a obra
  a meio, a da bancada, a do `advance_turn()` direto, o atracar e o
  `pay_debt()` diretos, o cartão com o berço cheio, o «Não consigo pagar», a
  segunda chance); §3 a preferência desligada cala os três, e religada
  conta outra vez; §4 o movimento reduzido não cala; §5 os Ajustes (a linha
  mostra, aplica, grava, relê, recusa o tipo, avisa a escrita falhada); §6 o
  atracar é o toque curto.
- **F5** lê a permissão como item da secção de opções do preset Android;
  **F24** confere que o aparelho é chamado uma vez, no `Haptica.gd`, que cada
  momento da tabela é pedido no jogo e que ninguém pede um fora dela (as
  chamadas contadas por dois caminhos, `037`).
- **A linha nova nos Ajustes**: o D33 conta-a (a «Vibração» e a explicação,
  as duas a passar); o RB5 passou a medir também as alternâncias no texto
  Maior, e conta as duas; o T29 (RB6) exige-a alcançável com alvo mínimo a
  cada altura; o T30 mede-lhe os quatro estados, `hover_pressed` incluído
  (`132`).
- **No CI**: `tools/conferir_permissoes_apk.py` procura a permissão no
  manifesto binário do APK exportado (nas duas codificações do pool, e com o
  `uses-permission` ao lado), e prova-se antes com manifestos falsos
  (`--provar`; o defeito injetado nos controles reprovou-os).
- **A bateria**: o tiro `ajustes_vibracao_desligada`, ao lado do
  `ajustes_movimento_ligado`.

Vinte defeitos no catálogo (`tools/mutantes.toml`, secção da `149`):

| Mutante | Quem reprova |
|---|---|
| A preferência ignorada | D54 §3 |
| Vibrar em toda virada | D54 §2, a virada simples |
| A permissão fora; a permissão no preset do Web | F5 (dois) |
| A obra pronta fora da porta | D54 §2, a bancada |
| O movimento reduzido cala a vibração | D54 §4 |
| O atracar recusado vibra; o atracar pendurado no sinal | D54 §2 (dois) |
| A segunda chance vibra | D54 §2 |
| O «Quitar agora» esquecido | D54 §1 |
| Desligada por omissão; os Ajustes sem gravar; a linha a mostrar errado | D54 §5 (três) |
| A duração trocada | D54 §6 |
| O ponto único sem o aparelho; um momento renomeado | F24 (dois) |
| A linha escondida | RB5, as alternâncias contadas |
| A linha abaixo do alvo de toque | T29 |
| O `hover_pressed` vazio | T30 |
| A explicação ilegível | D33, a linha contada |

## O custo

Nenhum asset, nenhuma chamada de desenho no mapa, nenhum tween: um
`RefCounted` estático e dois nós nos Ajustes (o interruptor e a linha de
apoio): o cartão cresceu 111 px (676 → 787, medido nas duas fotos a 1280),
e cabe a 1152, 1280 e 1600 (T29). No telefone,
uma vibração de 20 ou 40 ms por toque que conquista.

## O gate

O telefone, que só o Bruno tem: o APK sai do CI do PR (`brport-apk`). O que
sentir em cada momento está no briefing desta conversa. Veredito por
perguntar.

## O que fica de fora

- **O casco que rola (A3)**, a conversa seguinte, com o desenho na `144`;
  depois a esteira, a fumaça e o fundeadouro (a ordem entre os três a
  perguntar). E as duas melhorias da `148` que o Bruno não pediu.
- **O `hover` dos interruptores dos Ajustes depois do toque**: desligada, a
  «Vibração» fica no tom claro do `hover`, porque o rato emulado fica onde o
  dedo saiu — o irmão por varrer que a `148` nomeou (`interface.md`).
- **Se o aparelho vibra, e se a duração se sente**: nada aqui o prova.

## O que se aprendeu

- **O motor do contraste mede o nó invisível**: a linha escondida passou o
  D33 com as duas medidas a «passa»; quem a contou foi o RB5, cujo medidor
  salta o que não está visível (`testes-e-guardas.md`).
- **O botão desligado premido pelo `pressed.emit()` é um estado que nenhum
  toque alcança**: a conferência que só ele provava era a porta do botão
  escrita outra vez (`testes-e-guardas.md`).
- **O rótulo declarado com o dado entre parênteses** repetia-se em quatro
  asserções («§2 e não vibra (…)»): cada pergunta passou a ter o rótulo dela,
  sem depender do dado (`testes-e-guardas.md`).
