# BR Port — os testes mais rápidos (`137`); a próxima conversa fecha as lacunas graves

**24/10/2026.** Branch `claude/zealous-heisenberg-dtqner`, da main `bf2eafe`
e avançada para a `b0ae8ee` quando o Bruno fundiu o **PR #149** (as estradas,
`136`), levado a verde nesta conversa: os 166 mutantes em 100,4 min. O PR
desta branch abriu no fecho, a pedido dele.

**Decisão `137` — os testes mais rápidos sem tirar prova.** Medido: um
mutante custa a suíte que o reprova (34 s no CI), e os núcleos estavam
parados. Escolha do Bruno: o executor de mutantes em quatro cópias do
repositório (`--trabalhadores`), o CI em três fatias que um job junta
(`--fatia`, `--juntar`), as seis suítes a `--fixed-fps 60` (118,1 → 96,6 s,
os 158 pelas mesmas guardas) e as fotos quatro a quatro (107 iguais ao byte).
Os 166 provados aqui como o CI os corre: três fatias e o `--juntar`, `MUTANTES
OK`. A seleção por diff, o Godot vivo e o cache do `.godot/` ficaram de fora,
com o número de cada um na decisão.

⚠️ As suítes correm com `--fixed-fps 60`, e o executor recusa um
`testes.yml` com outro relógio (o comentário de `MOTOR` em
`tools/conferir_mutantes.py`).

⚠️ Em paralelo, o marcador de um trabalhador não é o do job: o CI procura-o
no início da linha (`.claude/rules/testes-e-guardas.md`).

⚠️ Não edite a árvore enquanto o executor paralelo copia: a cópia é
recusada, e é isso que se quer (o comentário de `em_paralelo` em
`tools/conferir_mutantes.py`).

⚠️ O trap de limpeza com `kill` sem processos derrubava a bateria verde com
código 2 (o comentário do trap em `tools/capturar_evidencia.sh`).

⚠️ Painel que abre e cabe não prova o que mostra nem o que o botão faz
(`.claude/rules/testes-e-guardas.md`, «O que as suítes executam e não
conferem»).

⚠️ Trabalho em fundo descreve-se pelo que prova e quanto falta
(`.claude/rules/gerais.md`, «Ambiente»).

**As lacunas, medidas:** as seis suítes executam 741 das 757 funções do
jogo, e de 205 defeitos plausíveis sorteados nelas 99 passam verdes (15
equivalentes). A tabela das treze graves, a classificação das 99 e o
antes/depois de cada defeito estão em
`docs/arquivo/MEDICOES_VELOCIDADE_TESTES_2026-10-24/`, com as ferramentas
que as mediram.

**Pendente:** o CI do PR desta branch — a primeira corrida da matriz e da
captura em paralelo no runner do GitHub (a base do PR ainda fotografa em
série, com o script dela). E, sem pressa, as seis suítes em paralelo para
os agentes (118 → 56 s): o Bruno disse «não agora».

**A próxima conversa, escolha do Bruno em 24/10:** fechar as treze lacunas
graves antes de a melhoria gráfica voltar.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3,
a decisão 137 (os testes mais rápidos e as lacunas) e o README de
docs/arquivo/MEDICOES_VELOCIDADE_TESTES_2026-10-24/. Confira a main remota,
os PRs abertos e o CI do último merge, e rode python3
tools/conferir_colaboracao.py com o trabalho commitado (ele lê o HEAD). Se o
PR da 137 (branch claude/zealous-heisenberg-dtqner) ainda não estiver na
main, pergunte ao Bruno por ele e conduza-o até verde antes de começar: é o
primeiro a correr a matriz de três fatias e a captura em paralelo no runner
do GitHub — leia o tempo de cada job e registe-o na 137.

O item desta conversa, escolha do Bruno em 24/10: FECHAR AS TREZE LACUNAS
GRAVES que a 137 mediu, antes de a melhoria gráfica voltar. Cada uma é um
defeito plausível que passa hoje nas seis suítes. A tabela está no README
das medições, e o antes/depois exato de cada defeito em
amostra_mutacao.json, no formato do tools/mutantes.toml. É F6 — guarda nova
e defeito injetado —, e é Opus.

As treze:
- GameState.gd: atender um barco deixa de subir a reputação; no arranque, o
  save que carrega é trocado por partida nova.
- PainelCaixa: o bloco «Entrou» só aparece com receita zero.
  PainelCancelarServico: o botão de confirmar some; confirmar duas vezes
  cancela duas vezes. PainelMeta e PainelParcela: abrem sem botão de fechar.
  DocaCartao: o cartão não mostra o valor do barco. PainelAjustes: os
  rótulos Padrão e Maior trocam de lugar.
- Audio: o volume não grava. AmbienteCosteiro: mar e gaivota nunca tocam.
  RolagemDaOperacao: o arrasto com um dedo não rola. BarcoFila: a escala dos
  cascos fica 0 e os barcos ao largo somem.

Para cada uma: confira primeiro que o defeito ainda passa verde (o código
pode ter mudado desde 24/10); escreva a guarda que o apanha — painel pela
porta do jogador, perguntando pelo TEXTO e pela AÇÃO, não só pelo encaixe
(.claude/rules/testes-e-guardas.md, «O que as suítes executam e não
conferem»); ponha o defeito em tools/mutantes.toml numa secção própria, rode
--explorar e declare a guarda verdadeira; --so <id> espera MUTANTES OK.
Nenhuma guarda nova pode deixar uma suíte instável: semente fixa, e nada de
relógio de parede.

Ao fim, corra o catálogo inteiro (python3 tools/conferir_mutantes.py --godot
"$G" --trabalhadores 4, ~25 min), e volte a correr os mesmos 205 defeitos da
amostra (ferramentas/amostra.py rodar, sobre amostra_mutacao.json) para
dizer quanto a detecção subiu. As de gravidade média — painéis, preferências,
telemetria — ficam listadas para o Bruno escolher se entram.

Depois desta conversa, a melhoria gráfica volta: o item 3 da fila da 126, os
sprites de detalhes (o que a 136 anotou nas fotos está no briefing
2026-10-23c). Não comece outra funcionalidade por conta própria. Ao
encerrar, aplique /fechar-sessao e entregue o prompt completo da próxima
conversa em bloco copiável — a dos sprites de detalhes.
```
