# 138 — As treze lacunas graves, fechadas pelo texto e pela ação

**24/10/2026 · escolha do Bruno na `137`, antes de a melhoria gráfica
voltar.** Main `b0ae8ee` (PR #149) ao abrir; a branch partiu da da `137`
(`claude/zealous-heisenberg-dtqner`, PR #150), que esta conversa levou a
verde no runner, com os tempos registados lá, e que o Bruno fundiu a meio
dela (`10b9d7c`). Nenhum PR do Codex aberto; 138 livre pelo
`tools/conferir_colaboracao.py`. F6 — guarda nova e
defeito injetado —, Opus.

## O antes

A amostra da `137` sorteou 205 defeitos plausíveis nas funções que as seis
suítes executam; 99 passaram verdes, e treze eram graves. **Antes de
escrever uma guarda, cada um voltou a correr** contra as seis suítes, na
árvore desta conversa (`b88027b`), com o mesmo `ferramentas/amostra.py` da
medição: os treze **sobreviveram** — o código não tinha mudado debaixo de
nenhum.

## A leitura (F3): dois dos treze não são o que a tabela dizia

- **«Confirmar duas vezes cancela duas vezes» não acontece.** O
  `GameState.cancelar_servico()` recusa a repetição (o T24 «repetição não
  cobra»), e o painel confirmado vai-se no mesmo frame. O que a bandeira
  `_respondido` segura é outra coisa: depois de uma RECUSA — o caixa mudou,
  o painel pede para fechar e reabrir —, uma segunda confirmação com o
  número de volta ao que o orçamento leu cancelaria com a conta velha. Pela
  tela o botão já fica desligado, então é uma segunda proteção, e o que ela
  defende são os que chamam a ação por fora (a captura da Fase 2, a suíte).
- **A meta «antes da Fase 2» não abre pela porta do jogador.** O `Main` só
  abre o `PainelMeta` na Fase 2; o ramo sem botão é de quem o abrir por
  outra porta.

As duas guardas escreveram-se na mesma — a escolha do Bruno foi fechar as
treze —, e o comentário de cada uma diz o que ela defende de verdade.

## As guardas

| Defeito (id no catálogo) | Onde | A pergunta |
|---|---|---|
| `servir-sem-reputacao` | T31 | servir um barco sobe a reputação em `REPUTATION_GAIN_SERVED`, com a fila vazia (a desistência também mexe nela) |
| `arranque-troca-o-save` | T31 | um `GameState` novo posto na árvore abre a partida gravada; e o controlo: sem save, abre partida nova |
| `caixa-entrou-ao-contrario` | T31 | depois de um dia que serviu um barco, os blocos «Entrou» do caixa, aberto pela pílula, têm o total de cada dia que rendeu |
| `parcela-falta-sem-fechar` | T31 | a parcela aberta pelo cartão, sem dinheiro, diz quanto falta e o «Fechar» fecha-a |
| `meta-cedo-sem-fechar` | T31 | a meta da Fase 2 volta ao porto; antes dela, diz quando abre e deixa fechar |
| `doca-sem-valor` | T31 | o barco atracado pelo toque mostra o valor no cartão da doca, e o acordado quando há acordo |
| `fila-cascos-a-zero` | T31 | os três portes do pesqueiro ao largo têm casco entre 20 e 70 px (33, 52 e 64) |
| `cancelar-sem-botao` | T24 | a confirmação mostra o botão «Cancelar serviço», e é ele que se prime |
| `cancelar-recusa-esquecida` | T24 | depois da recusa, com o caixa de volta, confirmar outra vez não cancela |
| `ajustes-rotulos-trocados` | RB5 | o botão que DIZ «Maior (+25%)» aplica o maior, e o que diz «Padrão» volta |
| `rolo-ignora-o-dedo` | RB5 | o arrasto com um dedo (`ScreenTouch` + `ScreenDrag`) rola a operação sem jogar |
| `volume-nao-grava` | A6 | o 0,5 escolhido está no arquivo de volume, e não só no bus |
| `ambiente-sem-relogio` | A7 | o `timeout` de cada relógio do `AmbienteCosteiro` pede o som dele e volta a armá-lo no intervalo |

O T31 é bloco novo (`tests/casos_mostra_e_faz.gd`, no `run_tests`); as
outras seis vivem ao lado das irmãs. Nada corre contra o relógio de parede:
o mar dispara-se pelo `timeout` à mão, o arranque é um nó posto na árvore,
e o T31 semeia a partida.

## Os defeitos injetados

Os treze entraram numa secção própria do catálogo (*«as treze lacunas graves
da amostra»*), com o `antes`/`depois` da amostra e o id dela ao lado. O
`--explorar` pô-los contra as seis suítes, em quatro cópias: **cada um
reprovou pela guarda nova e só na suíte dela**, e nas outras cinco ficou
verde (a saída está em `docs/arquivo/MEDICOES_VELOCIDADE_TESTES_2026-10-24/`).
Dois levam vizinhos em cascata, e não são guardas a mais: a recusa esquecida
cancela de verdade, e a contagem do «confirmação real cobra uma vez» a seguir
sai a dois; o arranque trocado também reprova o controlo, porque sem save o
`_ready()` defeituoso não abre partida nenhuma. Com ele, as outras suítes
passam nos dois arranques errados — o que troca o save e o que não abre nada
—, porque todo bloco chama o seu `new_game()`. Declaradas as guardas,
`--so` dos treze: *«MUTANTES OK — 13 defeito(s) reinjetado(s) em 4 cópia(s)»*.

**E o toque do dedo foi a única guarda com uma afirmação por provar**: o
comentário diz que o `push_input` entrega o `ScreenTouch` cru, sem o rato
emulado do `Input`. Se o rato viesse junto, o gesto do rato rolaria com o
ramo do dedo partido e o mutante passaria; reprovou, e só na guarda do dedo.

## A prova

PROVA

## As de gravidade média: treze, escolha do Bruno

A amostra deu 28 sobreviventes de gravidade média (e 43 baixas, 33 delas de
visual fino). Fechadas as graves, a pergunta foi *«se entrarem, o que
ocorre?»*; a resposta — uma sessão como esta, ~1,5 min a mais no CI, e as
treze visuais caras e frágeis — trouxe *«pode fazer elas»*. **Entraram as
treze que não são visuais nem fora do headless**: lógica, telemetria,
painéis e preferências.

| Defeito (id no catálogo) | Amostra | Onde | A pergunta |
|---|---|---|---|
| — (equivalente) | `GameState:1305:bool` | — | o `calendario()` pergunta `vencimentos.has(t)`, e o `false` deixa a chave: o calendário marca na mesma |
| `alocar-fora-do-array` | `GameState:1344:rel` | T31 | a doca de índice igual ao total é recusada **sem erro do motor** |
| `recordes-vazam-no-load` | `GameState:2952:apagar` | T31 | o recorde malformado no save carrega a zero, e não com o da partida viva |
| `registro-partida-nova-retomada` | `Registro:203:rel` | R9 | a partida do dia 1 grava-se nova; a que arma a meio, retomada |
| `registro-turno-nasce-com-aviso` | `Registro:295:const` | R9 | o turno sem aviso vermelho conta zero, e com um conta um |
| `registro-docas-ao-contrario` | `Registro:316:rel` | R9 | duas docas com trabalhador contam duas |
| `diario-fase-2-sem-legenda` | `DiarioFase2:9:apagar` | T31 | a página relida pela meta conquistada diz «Fase 2 concluída» |
| `docas-sem-quem-opera` | `PainelDocas:159:apagar` | T31 | o painel das docas diz a classe, quando paga e o número de quem opera |
| `espacos-nova-sem-titulo` | `PainelEspacos:52:apagar` | T27 | «Nova partida» com espaços ocupados abre a escolha com o título dela |
| `meu-porto-sem-dia` | `PainelMeuPorto:26:apagar` | T27 | o resumo escreve o dia e a semana |
| `leitura-maior-nao-acomoda` | `AcomodacaoDeLeitura:88:not` | RB5 | o Construir no Maior cabe numa tela de 720×1000 e rola por dentro |
| `doca-realce-some-reduzido` | `DocaCartao:206:apagar` | T29 | com o movimento reduzido, o cartão da doca à espera acende fixo |
| `memoria-marca-inicio` | `MemoriaDeLeitura:18:logico` | RB5 | com o topo a cortar um parágrafo, a marca é o primeiro caractere à vista |

**Quatro leituras que só abrir cada uma deu**, como as duas das graves:

- **O calendário é equivalente**, e não entra no catálogo — um defeito que
  nenhuma suíte pode ver não prova guarda nenhuma.
- **A alocação fora do array só se via pelo erro.** O jogo já não chama o
  `assign_worker()` (atracar leva o trabalhador), as suítes chamam; e uma
  função tipada que rebenta devolve o `false` da recusa. Desde o 4.5 o motor
  tem `Logger` (`OS.add_logger`), e uma sonda mediu-o no 4.6.3: apanha o
  `SCRIPT ERROR` de dentro da suíte, com a função a devolver `false`. É a
  primeira guarda deste projeto que pergunta «houve erro?» como asserção, e
  não pelo passo do CI que varre a saída.
- **A acomodação do Maior só muda à vista no cartão alto.** Uma sonda abriu
  o percurso do contraste no Maior a 1280, 1152 e 1000 px, com e sem o
  defeito: a geometria é a mesma em quase todo painel, porque os que cabem
  cabem nos dois. O Construir não cabe — sem a acomodação, a 1000 px ele
  começava em −37, com o título fora da tela.
- E duas defendem estados que o jogo não monta: o cartão da doca com barco
  e sem trabalhador (atracar leva-o sempre), e o save com um recorde de
  outro tipo (todo save que o jogo grava os traz certos). As guardas defendem a leitura escrita ao
  lado do código, e o comentário de cada uma o diz.

**E a prova é a mesma das graves.** Os treze voltaram a correr na árvore
de antes destas guardas, com o `amostra.py`: todos **sobreviveram**. Os doze
que não são equivalentes entraram numa secção própria do catálogo (*«as
lacunas médias que o Bruno escolheu»*), e o `--explorar` em quatro cópias
deu onze reprovados pela guarda nova, numa suíte só cada um. **O décimo
segundo — os recordes — sobreviveu à guarda que eu escrevi**: ela montava o
save sem a chave `recordes`, e o `.get(nome, {})` do `load_game()` devolve um
dicionário vazio e reescreve cada campo a zero na mesma, com ou sem o
reset. O reset só separa quando um recorde vem com OUTRO TIPO, que o laço
salta; a guarda passou a plantar isso, e o defeito reprovou. `--so` dos doze:
*«MUTANTES OK — 12 defeito(s) reinjetado(s) em 4 cópia(s)»*.

As que ficaram de fora: as treze **visuais** (animação, ordem de desenho,
recorte de retrato, espaço do HUD), que mudam as fotos do «Evidência
visual» e pedem alguém a olhar; a de **texto**, `Narrativa:705:apagar`; e a
de fora do headless, `CopiaDoDiagnostico:28:apagar`.
