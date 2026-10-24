# 138 — As treze lacunas graves, fechadas pelo texto e pela ação

**24/10/2026 · escolha do Bruno na `137`, antes de a melhoria gráfica
voltar.** Main `b0ae8ee` (PR #149); a branch parte da da `137`
(`claude/zealous-heisenberg-dtqner`, PR #150), que esta conversa levou a
verde no runner e cujos tempos ficaram registados lá. Nenhum PR do Codex
aberto; 138 livre pelo `tools/conferir_colaboracao.py`. F6 — guarda nova e
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

## As de gravidade média, para o Bruno escolher

A amostra deu 28 sobreviventes de gravidade média (e 43 baixas, 33 delas de
visual fino).
Nenhuma entrou: a escolha do Bruno foi as treze graves. Ficam aqui, com o id
da amostra, pelas três famílias que ele nomeou primeiro:

| Família | Defeito (id da amostra) | O que se veria |
|---|---|---|
| painéis | `DiarioFase2:9:apagar` | some a legenda «Fase 2 concluída» |
| painéis | `PainelDocas:159:apagar` | o painel das docas perde a linha de classe, prazo e trabalhador |
| painéis | `PainelEspacos:52:apagar` | a escolha de espaço para partida nova perde o título |
| painéis | `PainelMeuPorto:26:apagar` | o «Meu porto agora» perde o dia e a semana |
| preferências | `AcomodacaoDeLeitura:88:not` | no texto Maior, o cartão rolável não se acomoda |
| preferências | `DocaCartao:206:apagar` | com «reduzir movimento», o destaque da doca some |
| preferências | `MemoriaDeLeitura:18:logico` | a memória de leitura marca o caractere errado |
| telemetria | `Registro:203:rel` | toda partida nova lida como retomada |
| telemetria | `Registro:295:const` | cada turno começa com uma mensagem ruim contada |
| telemetria | `Registro:316:rel` | as docas ocupadas contadas ao contrário |

E as outras médias, de outras famílias: três de **lógica** —
`GameState:1305:bool` (o calendário deixa de marcar os vencimentos),
`GameState:1344:rel` (alocar na doca de índice igual ao total passa a guarda)
e `GameState:2952:apagar` (os recordes de uma partida vazam para a
carregada) —; uma de **texto**, `Narrativa:705:apagar` (uma linha do fim da
Fase 1 some); uma **fora do headless**, `CopiaDoDiagnostico:28:apagar`; e
treze **visuais** (animação, ordem de desenho, recorte de retrato, espaço do
HUD), que mudam as fotos do «Evidência visual» e pedem alguém a olhar. As
três de lógica são as que este registo poria primeiro, se ele quiser mais.
