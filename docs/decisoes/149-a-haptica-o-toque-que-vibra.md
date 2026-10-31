# 149 — A háptica: o toque que vibra, e só ele

**31/10/2026 · o terceiro item do tema animação e toque, pela ordem do Bruno
(A1′ → A1 → T1 → A3, `144`): a T1, a háptica.** Branch
`claude/hopeful-ride-f61g1m`, que arranca da cabeça da `148`
(`claude/sharp-lamport-kf55gf`, `0e39079`): o PR #160 dela estava aberto, com
o CI a correr, e é acompanhado noutra conversa. Main `d11311b` no arranque.
O pré-PR deu a 149 por livre. PR #161.

## O que se mediu antes

- **Nenhuma chamada de vibração no jogo e nenhuma permissão `VIBRATE`**,
  como a `144` dizia: o `grep` por `vibrat` nos scripts, cenas e configuração
  só acha o `permissions/custom_permissions=PackedStringArray()` vazio do
  preset Android.
- **No Linux o `Input.vibrate_handheld()` não faz nada e não se queixa**:
  sondado em `--headless` e sob `xvfb-run`, com e sem amplitude, sem uma
  linha na saída. Por isso o ponto único chama-o sempre, sem perguntar a
  plataforma, e nem as suítes nem a bateria de capturas ganham ruído.
- **A chave do preset** sai de `permissions/` + o nome da permissão em
  minúsculas: o binário do Godot 4.6.3 traz `permissions/` e `VIBRATE`.
- **Um `RefCounted` estático agenda pulsos**: um lambda dentro da função
  estática, ligado a um `create_timer` da árvore, chegou pela ordem
  (sondado antes da segunda passagem).

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

| Momento | Quem pede | Padrão `[ms, força]` |
|---|---|---|
| atracar | o cartão «Ao largo» ao soltar, se o `atracar()` aceitar (`BarcoFila`) | um toque: `[15, 0,4]` |
| obra pronta | o `_ao_concluir_obra()` do `Main`, só com a virada armada pelo «Avançar dia» | dois a subir: `[18, 0,5]`, `[28, 0,8]` |
| parcela paga | o «Pagar» do Sr. Ribeiro, junto da resposta «pagou» (`DebtPaymentPanel`), e o «Quitar agora», se o `pagar_parcela_adiantado()` aceitar (`PainelParcela`) | dois a subir, mais fortes: `[22, 0,6]`, `[36, 1,0]` |

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

## As boas práticas (a segunda passagem)

O primeiro veredito foi «Ajustar», e a pergunta do quê voltou com o pedido:
*«pesquise as melhores práticas usadas para isso, e aplique no jogo de
acordo com o que tem nele, sem exagerar, usando como um complemento para
deixar a gameplay melhor»*. A pesquisa passou pela busca — as páginas não se
leram, pistas de padrão (`063`):
[Android, princípios de háptica](https://developer.android.com/develop/ui/views/haptics/haptics-principles),
[Android, UX do framework háptico](https://source.android.com/docs/core/interaction/haptics/haptics-ux-foundation),
[Android, `CONFIRM` e `REJECT`](https://developer.android.com/reference/android/view/HapticFeedbackConstants),
[Apple, HIG «Playing haptics»](https://developer.apple.com/design/human-interface-guidelines/playing-haptics),
[Godot, `vibrate_handheld(ms, amplitude)`](https://docs.godotengine.org/en/4.3/classes/class_input.html).

| Prática | A primeira passagem | O que mudou |
|---|---|---|
| **Claro, não zumbido**: pulsos curtos; a vibração longa de um tiro só deixa o motor a ressoar | 20 e 40 ms à força do aparelho | Nenhum pulso passa de 40 ms; a força vai na amplitude (0–1, o Android converte para 1–255) |
| **A força segue a importância**: leve no gesto frequente, forte no marco | a obra e a parcela iguais | o atracar é o mais leve (0,4); a parcela, o marco da fase, a mais forte (1,0) |
| **O sucesso tem forma**: o `CONFIRM` do Android; dois toques a subir | um pulso por momento | a obra pronta e a parcela paga são dois toques a subir, a 80 ms um do outro |
| **Pouco, e junto do som e da imagem** | três momentos, com o som de sucesso e o assentar | mantido: nenhum momento novo. A recusa do atracar (o `REJECT`) ficou de fora: a faixa já avisa, com o som de aviso, e seria o quarto momento |
| **Opcional** | «Vibração» nos Ajustes | mantido, com a explicação nova |

**No Web e no telefone sem controlo de amplitude** a força é ignorada e o
pulso sai inteiro: curto, continua a ler como um toque, e o padrão de dois
continua a distinguir o sucesso. No iOS o Godot não diz o que faz à
amplitude; o jogo não sai para lá.

## A T1, como está no jogo

- **`scripts/Haptica.gd`**: `PADROES` (momento → pulsos `[ms, força]`) e
  `INTERVALO_SEG` (0,08). `pedir(momento)` lê a preferência, conta o pedido,
  manda o primeiro pulso e agenda os outros no relógio da árvore (que corre
  com o jogo em pausa: o painel que abre a seguir não corta o segundo
  toque). `pulsos` regista o que chegou ao aparelho. Um momento fora da
  tabela rebenta em vez de vibrar nada.
- **«Vibração» nos Ajustes**, ao lado do som (a secção passou a «SOM E
  VIBRAÇÃO», como nos Ajustes do telefone), com uma linha de apoio que diz o
  que se sente: *«Um toque leve ao atracar; dois toques quando uma obra fica
  pronta, mais fortes quando a parcela é paga.»* **Ligada por omissão**,
  guardada na `PreferenciasDeApresentacao` (`apresentacao.cfg`, fora do
  save), lida com a mesma recusa de tipo do RB6.
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
  padrão — todo pulso curto e com força entre 0 e 1, o atracar um toque só
  e o mais leve, o sucesso dois toques a subir, a parcela mais forte.
- **F5** lê a permissão como item da secção de opções do preset Android;
  **F24** confere que o aparelho é chamado uma vez, no `Haptica.gd`, que cada
  momento da tabela é pedido no jogo e que ninguém pede um fora dela (as
  chamadas contadas por dois caminhos, `037`) — e, esperando os quadros, que
  o segundo toque chega depois do intervalo e não antes.
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

Vinte e cinco defeitos no catálogo (`tools/mutantes.toml`, secção da
`149`), e três da `148` reescritos contra o código novo:

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
| O atracar tão forte quanto as conquistas; o marco num pulso longo; o sucesso num toque só; a parcela igual à obra | D54 §6 (quatro, da segunda passagem) |
| O ponto único sem o aparelho; um momento renomeado | F24 (dois) |
| O segundo toque perdido; os dois toques colados | F24, o relógio (dois, da segunda passagem) |
| A linha escondida | RB5, as alternâncias contadas |
| A linha abaixo do alvo de toque | T29 |
| O `hover_pressed` vazio | T30 |
| A explicação ilegível | D33, a linha contada |

## O custo

Nenhum asset, nenhuma chamada de desenho no mapa, nenhum tween: um
`RefCounted` estático, um temporizador da árvore por toque de sucesso, e
dois nós nos Ajustes (o interruptor e a linha de apoio): o cartão cresceu
111 px (676 → 787, medido nas duas fotos a 1280), e cabe a 1152, 1280 e
1600 (T29). No telefone, um toque leve ao atracar e dois curtos por
conquista.

## O gate, passagem a passagem

O telefone, que só o Bruno tem: o APK sai do CI do PR (`brport-apk`; o da
segunda passagem é o da corrida de `bff02c2`, e o log do export mostra
`android.permission.VIBRATE` no manifesto). **Aceite à segunda passagem.**

| Passagem | Resposta |
|---|---|
| 1 (um pulso: 20 ms ao atracar, 40 ms nas conquistas) | «Ajustar», e o quê: *pesquisar as melhores práticas e aplicá-las ao que o jogo tem, sem exagerar, como complemento* |
| 2 (os padrões acima) | **«Aceito»** |

## O que fica de fora

- **O casco que rola (A3)**, a conversa seguinte, com o desenho na `144`;
  depois a esteira, a fumaça e o fundeadouro (a ordem entre os três a
  perguntar). E as duas melhorias da `148` que o Bruno não pediu.
- **A recusa que vibra** (o `REJECT` do Android no cartão com o berço cheio):
  medida a favor e deixada de fora pelo «sem exagerar».
- **O `hover` dos interruptores dos Ajustes depois do toque**: desligada, a
  «Vibração» fica no tom claro do `hover`, porque o rato emulado fica onde o
  dedo saiu — o irmão por varrer que a `148` nomeou (`interface.md`).
- **Se o aparelho vibra, e se o padrão se sente**: nada aqui o prova.

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
- **A guarda que conta uma frase copiada reprova a frase nova**: o D33
  procurava a explicação pelo começo dela, e a segunda passagem mudou-a — a
  suíte ficou vermelha com o painel certo. A frase passou a constante do
  painel (`EXPLICACAO_VIBRACAO`), e o D33 lê-a de lá: é «o formato também não
  se copia» (`interface.md`) com uma frase no lugar do formato.
- **Vibração longa é zumbido, e força é amplitude**: a primeira passagem
  escolheu duração para dizer importância; a orientação do Android diz o
  contrário (`plataforma.md`).
