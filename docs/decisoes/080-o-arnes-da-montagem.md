# 080 — O arnês da montagem entra no gerador

**04/10/2026 · ferramenta de arte**: a `079` renderizou os 65 quadros do degrau
3 com um arnês de sessão, que desligava o `view_layer.update()` do `bpy.ops`
nos `primitive_*_add`, e deixou-o fora do repositório: *«adotá-lo é uma
decisão por tomar»*. O briefing pôs-no entre as três tarefas em aberto, sem
recomendação, e o Bruno escolheu-o.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A tarefa da sessão | **Adotar o arnês do gerador**, contra a máquina do contêiner e a frente 5. Sem recomendação: o briefing mandava perguntar e não escolher |
| «Por que isso vale a pena?» | Respondido pelo custo e pelo ganho (abaixo); veio «Tudo bem», e o fecho |
| O que vem a seguir | **A melhoria de design**, à frente do resto da fila (plano v3, §7) |

## O que mudou

- **`primitiva()` em `tools/gerar_props_iso.py`** chama o operador com o gancho
  privado `_BPyOpsSubModOp._view_layer_update` trocado por uma função vazia, e
  repõe-no no `finally`. As quatro primitivas do kit (`caixa`, `cone`, `bola`,
  `anel`) e as nove chamadas diretas de `blender/brp_retratos.py` passam por
  ela. Mais nenhuma chamada de `bpy.ops` mudou: o `transform_apply` da `bola`,
  as luzes, a câmera e o plano da sombra ficam com as atualizações.
- **`BRP_CAMINHO_LENTO=1` devolve o caminho de sempre**, e um `bpy` sem o gancho
  também. O gerador diz numa linha por qual caminho montou, e quanto a
  montagem levou. O arnês só compra tempo: sem ele, o resultado é o mesmo.
- **`--despejar=<arquivo>`** nos dois geradores (`gerar_props_iso.py` e
  `blender/gerar_brp.py`) monta a cena, escreve-a objeto a objeto e sai sem
  render. É a régua.

## A régua, e as duas vezes que ela mentiu

O despejo escreve, por objeto, a matriz em `repr`, a visibilidade, os
materiais, os ajustes de cada modificador (todos, pela RNA) e um hash da
malha ORIGINAL. O render é função disso, e é aí que o arnês pode estragar:
um valor lido velho pelo catálogo acaba escrito na geometria ou na matriz.

- **A primeira régua lia a malha AVALIADA**, e dois despejos do MESMO caminho
  divergiam em 2.570 linhas: o chanfro interpola as UVs com 1 ULP (5,96e-8)
  que muda de caixa para caixa — oito caixas iguais, quatro UVs —, e nas
  esferas devolve as faces noutra ordem a cada corrida, com 1,9e-9 nas
  coordenadas. Como conjunto, as faces são as mesmas.
- **A segunda lia a original, e ainda divergia nas 29 esferas do base**: a
  própria `primitive_uv_sphere_add` não é determinística na ordem das faces
  (seis esferas iguais, quatro ordens). Hoje cada face entra pelo seu ciclo de
  vértices, rodado para o menor índice, e as faces entram ordenadas
  (`_resumo_da_malha()`).

## A prova

| Pergunta | Medido |
|---|---|
| A régua tem ruído próprio? | Não: dois despejos rápidos dão os mesmos bytes, no base (5.492 objetos) e no porto (3.791) |
| Ela vê o defeito que o arnês pode causar? | Sim: uma linha que pousa a soleira da casa pela `dimensions` do corpo, lida depois de outras primitivas, dá z = 0,0100 com o arnês (a medida velha, 1) e 0,00708 sem ele — e a diferença sai na matriz daquela peça. Sem a linha, os dois caminhos voltam a ser iguais |
| Terreno, cidade e fauna | Rápido = lento, byte a byte |
| Porto | **Rápido = lento, byte a byte**, nos 3.791 objetos |
| Base | A correr pelo caminho lento no fecho (04/10); o resultado entra aqui quando ela acabar |
| O tempo da montagem | Com o arnês, sozinho na máquina: porto 110,7 e 112,3 s, base 19,2 e 18,1 s. Sem ele, o porto levou **809,2 s** — 7,3× —, com outra montagem a correr ao lado: é um teto, não um par limpo |

## O que fica de fora

- **A régua não corre no CI**, que não tem `bpy`. Quem mexer no kit ou num
  catálogo repete a prova com os dois comandos do cabeçalho de `primitiva()`.
- **A armadilha nova é para quem escrever props**: com o arnês, a
  `dimensions` e a `matrix_world` de uma peça ficam velhas depois de criada a
  seguinte — a sonda deu (1, 1, 1) onde o caminho lento dá (2, 3, 4). Nenhum
  catálogo de hoje as lê assim: o kit roda pela `matrix_basis`, e os retratos
  pedem o `update()` ou o `evaluated_depsgraph_get()` antes de ler. Quem
  posicionar uma peça pela medida de outra pede o `update()` antes.
- **O render não mudou de caminho**, e numa leva grande é ele que pesa: um
  quadro de 768 com 64 amostras.
