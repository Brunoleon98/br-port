# 117 — O defeito injetado fica: o catálogo que o CI reinjeta a cada PR

**15/10/2026.** Main `b142b80` (PR #132, fundido; nenhum PR aberto do Codex).
Escrita como a 111, livre na main nesse dia; em 16/10 o Codex fundiu a SUA
111 (o cancelamento) e abriu o PR #134 com a 113 à 116, e esta passou a 117
pelo `tools/renumerar_decisao.py` — a colisão que a `119` trata. Pedido do
Bruno, com o Codex a trabalhar no jogo: *ver se os testes
aprendem com os bugs encontrados e os põem como defeitos injetados, e se podem
melhorar para não deixar passar bugs antigos e novos.* Asserção nova com
defeito injetado (F6).

## O que havia

**A prática existe, e é forte.** O item 7 do fecho pede um defeito injetado
por guarda nova, e o projeto cumpre-o: **166 menções em 64 das 109
decisões**, e a `testes-e-guardas.md` tem mais de quarenta lições de como um
defeito injetado deixa de provar.

**Mas nenhum deles voltava a correr.** Cada um era aplicado à mão (`cp`,
editar, rodar, restaurar), uma vez, e ficava escrito em prosa — «o `retirar`
esquecido (M2)», «dezasseis defeitos injetados, todos reprovados» (`101`). A
prova valia no dia; no seguinte, nada perguntava se a guarda ainda apanhava o
defeito. As regras contam como isso falha sem ninguém ver — a sonda presa a um
funil que deixou de ser único, a regra que passou a viver em dois sítios, o
bloco que um refactor esvaziou —, e cada caso foi achado por acaso, sessões
depois. A única exceção era a bancada do cancelamento (`110`), com quatro
mutantes num script próprio, fora do CI.

Isto é a resposta à primeira pergunta: **os testes aprendiam com os bugs uma
vez, e esqueciam.**

## A medição

**35 defeitos reconstruídos** de catorze decisões e regras (`059`, `061`,
`083`, `085`, `087`–`090`, `093`, `102`, `104`, `106`, a regra do `maxi` de
06/09, a da derrota de 12/09 e o bug de travamento que abre o `run_tests`),
cada um como troca exata de texto contra o código de hoje, corridos contra a
suíte que os devia ver:

- **os 35 trechos ainda existiam**, uma vez cada;
- **28 reprovaram pela guarda que eu declarei**;
- **6 reprovaram por outra asserção** — que era a guarda verdadeira daquele
  defeito, com um rótulo que eu supus mal. O mais limpo: o `mini` trocado por
  `maxi` no nível do porto reprova exatamente por «com pórtico e sem cais o
  porto FICA no nível 2», que é o estado que a regra de 06/09 manda montar.
  A conferência da guarda declarada apanhou as minhas próprias suposições, que
  é o que ela existe para fazer;
- **1 sobreviveu: tirar a espera mínima do `Audio.gd` passava verde.**

**O A4 não podia ver o defeito que nomeava.** Pedia o mesmo som duas vezes
seguidas e conferia que a marca de tempo não mudava — mas o relógio do Audio
anda ao milissegundo, e dois pedidos no mesmo milissegundo deixam a marca
igual, toque ou não toque. A guarda põe hoje a marca METADE da espera no
passado (com a espera, fica; sem ela, o som toca e a marca vira o agora) e
ganhou o controle que faltava: passada a espera, o mesmo som volta a tocar.
Dois mutantes, cada um com a sua: o som sem espera reprova a primeira; o que
toca uma vez e nunca mais reprova só o controle — sem ele, a marca parada
leria como espera.

## O que mudou

- **`tools/mutantes.toml`** — o catálogo: **37 defeitos**, cada um com a
  decisão de onde veio, a frase do que o jogador veria, o alvo, o `antes`
  (que tem de existir UMA vez), o `depois` e a guarda que o tem de reprovar.
  Os 35 da medição, o gémeo do 089 (o save que aceita a véspera) e o
  controle do A4.
- **`tools/conferir_mutantes.py`** — o executor. Espera `MUTANTES OK`. Faz
  sozinho o que as lições mandavam fazer à mão: lê e valida o catálogo antes
  de tocar em nada; confere que as seis suítes e os marcadores batem com o
  `testes.yml`; corre a base de cada suíte antes (vermelha, aborta) e no fim;
  troca o alvo por temporário com o modo copiado e devolve-o da cópia em
  memória, conferido byte a byte, também sob SIGTERM; e julga cada corrida
  nesta ordem — não compila, não acaba no teto (4× a base medida), passou,
  não nomeou asserção, reprovou por outra guarda. `--explorar` corre um
  mutante contra as suítes e diz quem o apanha: é assim que se escreve o
  `reprova` de um mutante novo, medido e não suposto.
- **O `user://` de cada corrida é a pasta de saída** (`XDG_DATA_HOME` e
  `APPDATA`): um mutante no `ArmazemLocal.gd` mandaria a suíte gravar no save
  do jogador, que é o incidente de 25/09 (`061`).
- **O job «Defeitos já provados»** no `testes.yml`, ao lado da suíte e não
  dentro dela, com a sentinela do jogador plantada e conferida, e os logs em
  `brport-mutantes`.
- **O A4 do `teste_audio.gd`**, acima.
- **A regra**: o item 7 do `CLAUDE.md` (o defeito FICA), uma seção nova na
  `testes-e-guardas.md` (guarda nova, bug corrigido e mutante órfão), o
  `AGENTS.md` (o Codex corre-o no PR) e o `/fechar-sessao`.

**Bug corrigido entra também**, e é a resposta à segunda pergunta: o `antes`
é a linha corrigida e o `depois` a de antes da correção. Sem guarda que o
apanhe o mutante não entra — e é aí que a guarda se escreve.

**Mutante órfão reprova.** Quem reescrever a linha de um defeito vê o
executor recusar antes de injetar qualquer coisa, e reescreve o defeito
contra a forma nova: a lição viaja com o refactor em vez de morrer nele.

## O defeito injetado no executor

| Defeito | O que ele disse |
|---|---|
| troca só num comentário (mutante equivalente) | `SOBREVIVEU` |
| o defeito do atracar com a guarda de outro bloco | reprovou, mas não pela guarda declarada (e lista as que reprovaram) |
| sintaxe partida no `GameState.gd` | não compila — a primeira versão disse «não acabou», porque o autoload que não compila PENDURA a suíte; o julgamento passou a ler a compilação antes do teto |
| laço sem fim no `advance_turn()` | não acabou em 60 s |
| trecho que não existe / que existe 16 vezes / sem `reprova` | três queixas, nada injetado |
| a base do `teste_audio` vermelha | aborta antes do primeiro mutante |
| o `testes.yml` sem o marcador «AUDIO OK» | queixa, nada injetado |
| SIGTERM com o mutante aplicado | código 130 e o `GameState.gd` igual byte a byte |

## O que fica de fora

- **As ferramentas Python e as réguas** (`conferir_docs.py`, as capturas, o
  simulador): o executor conhece as seis suítes do Godot. A bancada do
  cancelamento continua com o script dela.
- **Os outros defeitos das 64 decisões.** Entraram 35, de catorze; os
  restantes entram quando alguém mexer no código deles, ou num item próprio
  da fila. Muitos descrevem-se em prosa sem o código, e reconstruí-los é
  decidir de novo o que eram.
- **Saber que um commit corrigiu um bug.** O CI não tem como; é regra escrita
  e passo do `/fechar-sessao`.
- **O tempo cresce com o catálogo**: os 37 levaram **769 s** neste contêiner,
  com a base no início e no fim. Quando o job passar de uns 20 minutos,
  o passo seguinte é correr no PR só os mutantes cujo alvo ou suíte o diff
  tocou, e o catálogo inteiro uma vez por semana.
- **Mutação gerada ao acaso** (trocar operadores às cegas): não. Cada defeito
  aqui é um que existiu ou que alguém pensou; o acaso produz equivalentes sem
  fim, e cada um pediria uma leitura.
