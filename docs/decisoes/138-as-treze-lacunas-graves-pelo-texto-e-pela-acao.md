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

QUEM-REPROVA

## A prova

PROVA

## As de gravidade média, para o Bruno escolher

MEDIAS
