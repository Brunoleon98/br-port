---
paths:
  - "**/*.gd"
---

# Regras — GDScript

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

As do «Estilo de código» do `CLAUDE.md` que são do GDScript. O essencial
— o `GS` destipado — ficou no núcleo; as de suíte estão em
`testes-e-guardas.md`.

- **⚠️ FUNÇÃO NOVA NUMA CLASSE BASE PODE TER O NOME DE UMA DAS FILHAS**, e a
  filha deixa de compilar — «The function signature doesn't match the
  parent». Em 04/10 o `_vestir_balao()` estático do `PainelNarrativo` colidiu
  com o do `PainelMensagens`, e o `run_tests` imprimiu `TODOS OS TESTES
  PASSARAM` com o `SCRIPT ERROR` na saída. Antes de acrescentar uma função ao
  andaime, procure o nome nas classes que herdam dele (`082`).
- **⚠️ `ResourceLoader.exists()` SÓ DIZ QUE O ARQUIVO ESTÁ LÁ.** Com um
  `SubResource` órfão o `load()` devolve `null`, o `.instantiate()` num `null`
  ABORTA a função — e quem chamou recebe o mesmo `null` que já significava "não
  montei, e já me queixei". Medido em 21/09: a régua do contraste encerrou com
  `CONTRASTE MEDIDO` e código **0**, com 46 textos a menos, e o D33 publicou
  `PASS em 147 medidos` com 90 em falta. Separe o `load()` do `instantiate()` e
  queixe-se do `null`. É a regra da amostra vazia um andar acima: ali a cena
  montava e não produzia texto, **e havia guarda**; aqui ela nunca chegou a
  montar, e não havia nenhuma.
- **⚠️ E `await process_frame` RETOMA ANTES DO FLUSH DA FILA ADIADA.** Ele
  volta no INÍCIO do frame seguinte, e o que foi posto em `call_deferred`
  naquele frame ainda não correu. Medido em 18/09: com um `await` só, o rótulo
  que a fala escreve por `call_deferred` ainda tinha a mensagem do sistema, e a
  asserção reprovava o código CERTO; com dois, a fala já lá está. **São dois, e
  escreva ao lado que foi medido.**
  ⚠️ **E A RÉGUA CAIU NO MESMO BURACO ANTES DA GUARDA** — a primeira medição
  depois da correção deu **zero em todas as falas**, o que se lê como "não
  acontece nada" e não como "li cedo demais". É a irmã de "receita derivada que
  não casa nada dá um verde de graça", com FRAMES no lugar do `grep`: **quando
  uma régua nova devolve zero em TUDO, a primeira pergunta é se ela consegue
  devolver outra coisa.**
- **⚠️ E `_process` DE UM `SceneTree` QUE DEVOLVE `true` MATA A ÁRVORE NO FIM
  DO FRAME.** Enquanto nenhum bloco espera, isso não se nota — quem encerra é o
  `quit()` explícito e o `true` chega depois. No dia em que um bloco passou a
  usar `await`, o `await` nunca voltou: a suíte imprimiu o marcador com o bloco
  inteiro por correr, verde e sem ter testado nada. Num `--script` que precise
  de esperar frames, `_process` devolve `false` e quem encerra é só o `quit()`.
- **⚠️ DECISÃO QUE PERGUNTA NUM PASSO E AGE NO SEGUINTE TEM UMA CORRIDA.** O
  arranque dos camiões perguntava se a ponta estava livre e deixava o tween
  teleportar no passo seguinte: dois que perguntassem no mesmo passo saíam
  juntos, em cima um do outro para a volta inteira. Nenhuma agenda o provocava
  — foi um mutante de OUTRA regra, que só mexia no tempo, que o expôs. Quem
  pergunta ocupa o sítio no mesmo instante (`052`).
- **⚠️ E `preload` DE UM SCRIPT QUE FALA DO AUTOLOAD, A PARTIR DE UM
  `--script`, DÁ UM GDScript VAZIO.** A terceira cara da regra abaixo, e a que
  menos se parece com ela: `const D := preload("res://scripts/Dock.gd")` numa
  ferramenta de `--script` compila o `Dock.gd` ANTES de os autoloads existirem,
  e o que sai não é erro de compilação — é um `GDScript` sem funções, que só se
  denuncia como *"Nonexistent function 'arte_do_barco' in base 'GDScript'"* na
  hora de o usar. Num `--script`, carregue-o com `load()` dentro do `_process`,
  quando a árvore já está de pé.
- **O autoload não resolve pelo nome dentro de um `class_name`.**
  `GameState.x` funciona num script de cena, que o Godot compila com os
  autoloads já registrados; NÃO funciona dentro de uma classe alcançada a
  partir de um script de `--script`, que é compilada antes disso. O erro sai
  como *"Compile Error: Identifier not found: GameState"* e derruba a suíte
  inteira, não só a linha culpada. Busque pela árvore —
  `Engine.get_main_loop().root.get_node("GameState")` — e escreva o tipo à mão
  no que vier de lá. É a irmã da regra acima, e tem a mesma origem: a suíte
  roda o jogo POR FORA.
- **Autoload novo nasce DESLIGADO, e quem o liga é o JOGO.** Um autoload
  carrega também em `--script` — é por isso que a suíte pega o `GameState` por
  `root.get_node()`. Logo, tudo o que ele faça por omissão acontece TAMBÉM
  durante as 600 partidas por perfil do simulador e durante as cinco suítes. O
  `Registro.gd` só grava depois de `armar()`, e a única linha do projeto que
  arma é o `Main._ready()`. É a irmã da regra "tela nova é overlay, nunca fase
  do `GameState`": ambas são coisas que funcionam no jogo e envenenam calado
  quem mede.
- **`destino[chave] += x` num Dictionary CRIA a chave em silêncio.** É a irmã
  do `.get(chave, omissão)` acima, do outro lado: ali um erro de digitação vira
  número plausível na LEITURA, aqui vira dinheiro escrito numa chave que a soma
  da receita não lê — e some sem erro nenhum. Aconteceria em 06/09 se um motivo
  novo se prendesse a uma estrutura sem linha na contabilidade; a linha chama-se
  como a estrutura de propósito, e o bloco T5l tranca que toda estrutura que
  paga tenha a sua.
- **⚠️ ADIAR UM LANÇAMENTO PARA DEPOIS DE UMA DECISÃO ABRE UMA SAÍDA POR
  RESPOSTA, e a que não se escreveu fica órfã.** A revisão externa de 12/09
  achou um defeito verdadeiro — o boletim da semana 4 fechava ANTES de o Sr.
  Ribeiro receber, e escondia a maior despesa da semana —, e o conserto adiou
  o fecho para o `pay_debt()`. Só que a fase `debt_payment` tem DUAS portas:
  quem paga e quem não pode pagar. Pelo lado da derrota o fecho nunca
  acontecia — `semana_atual` chegava ao fim da partida com meia semana dentro,
  `historico_semanas` ficava com TRÊS entradas em vez de quatro e o boletim
  não abria —, e **as cinco suítes passavam**, porque a asserção que veio com
  o conserto provava o adiamento só pelo lado de quem PAGA. Ao mover trabalho
  para depois de uma decisão, conte as RESPOSTAS e feche em todas; e a guarda
  que fecha é a própria FASE que adiou, nunca uma aproximação dela — assim ela
  também torna o fecho idempotente de graça.
- **⚠️ `is_inside_tree()` NÃO PROVA QUE O NÓ NÃO FOI MANDADO EMBORA.** O
  `queue_free()` marca o nó e só o tira da árvore no fim do frame, então um
  painel já condenado responde "estou cá" a quem perguntar assim. Uma asserção
  nova de 13/09 usava isto para provar que a tela ficava aberta e PASSOU com o
  defeito posto — quem reprovava era a asserção do texto ao lado, e sem ela o
  defeito passava inteiro. A pergunta que distingue é a da FILA:
  `is_queued_for_deletion()`.
- **⚠️ `get`, `set`, `in` E `has_method` DE UM NOME QUE NÃO EXISTE SÃO
  CALADOS; só o `call` grita.** Medido numa sonda em 10/10: os quatro devolvem
  `null`/`false` e seguem, e o `call` imprime `SCRIPT ERROR` e aborta a função.
  O teste que lê um privado por string recebe o `null` e rebenta longe da
  causa: renomeando doze membros que as suítes leem assim, cinco deixaram o
  marcador verde, e nenhum erro disse o nome. Quem lê por string um privado do
  `Main`, do `Dock` ou de um painel declara o receptor em
  `brport_vs/tests/nomes_lidos_por_string.json`, e o F19 do `teste_fumaca`
  exige o nome no alvo (`093`).
- **⚠️ ERRO NUMA FUNÇÃO TIPADA DEVOLVE O ZERO DO TIPO A QUEM CHAMOU, e a
  cadeia segue com um valor plausível.** Medido na `104`: com o mutante que
  tirava o `tem_cobranca()` do `caixa_curto()`, o erro nascia no
  `valor_da_parcela()` (`-> int`), que devolveu 0; o `principal_da_parcela()`
  somou, o `caixa_curto()` respondeu `false` — a resposta CERTA para a Fase
  2 —, e a asserção do T20 passou. Nenhuma pergunta pelo valor o distingue,
  nem pelo tipo: o único rasto é o `SCRIPT ERROR` na saída, e é por isso que
  o passo do CI que o reprova não é redundante com as asserções. «Rebentar»
  aqui quer dizer *escrever na saída*, não *parar o bloco*.
- **⚠️ E O LAMBDA CAPTURA A VARIÁVEL LOCAL POR VALOR.** `var n := 0` e um
  `func(): n += 1` ligado a um sinal contam numa CÓPIA: o T20 nasceu a provar
  «zero cobranças na Fase 2» com um contador assim, e o zero era de graça. Num
  lambda, conta-se num `Array` (`append`), que é referência — como o T14 já
  fazia.
- **⚠️ UM LAMBDA LIGADO A UM SINAL SEGURA VIVO O `RefCounted` ONDE NASCEU.**
  Medido numa sonda em 11/10: largado o objeto, ele continuava vivo e a ouvir
  o sinal; ligado por MÉTODO, morria com a última referência e a ligação com
  ele. Num `Node` o lambda morre com o nó, e por isso o `Main` podia usá-lo.
  Num objeto do `Main` ligado ao `GameState`, que vive o jogo inteiro, cada
  `Main` solto deixaria o objeto a ouvir para sempre — sem erro e sem nada na
  tela. Objeto `RefCounted` liga-se ao autoload por método; o F8h do
  `teste_fumaca` prova-o na narradora (`096`).
