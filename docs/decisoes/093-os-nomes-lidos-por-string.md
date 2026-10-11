# 093 — Os nomes lidos por string: todo nome que as suítes pedem ao alvo existe nele

**10/10/2026.** Main `b09f052` (PR #116, o M5, fundido; nenhum PR aberto do
Codex); 093 livre conferida na main antes de escrever. É o **M6** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), sem decisão pendente: asserção nova
com defeito injetado (F6).

## O que mudou

- **O bloco F19 do `tests/teste_fumaca.gd`** lê o texto das suítes e das
  ferramentas (`tests/`, `tools/`, `scripts/validation/`, `scenes/tests/`),
  acha cada membro privado pedido por string — `get`, `set`, `in`, `call`,
  `callv`, `has_method` — e exige que ele exista NO ALVO, com o tipo que a
  leitura pede: variável para os três primeiros, método para os outros.
  Quem responde é a **reflexão** do script da raiz da cena
  (`get_script_property_list`, `get_script_method_list`, herança incluída).
- **`brport_vs/tests/nomes_lidos_por_string.json`** diz o que o texto não diz:
  que variável é que alvo, em cada arquivo, e os literais que não são leitura
  direta. Nenhum nome se lista lá para ser conferido.
- No `teste_design`, os dois laços do D41 que liam `d.get("_barco_base")`
  passaram a chamar a variável `doca`, como o resto do arquivo: no
  `teste_design` o `d` é também um `Vector2`, um `int` e um `float`.

## A medição antes de escrever

**O motor, numa sonda:** `get`, `set`, `in` e `has_method` de um nome que não
existe devolvem `null`/`false` **calados**; o `call` imprime `SCRIPT ERROR` e
aborta a função (e, num `_process` antes do `quit()`, a sonda não acabou —
a quarta forma de falhar da `testes-e-guardas.md`).

**As suítes, renomeando doze membros lidos por string, um a um** (o alvo
renomeado por inteiro, para o jogo continuar a compilar):

| Renomeado | `teste_design` | `teste_fumaca` |
|---|---|---|
| `Dock._tw_trabalho` | 18 falhas | verde |
| `Main._ocupante_do_berco` | 1 falha | verde |
| `Main._fila` | 1 falha | 3 falhas |
| `Dock._camiao` | 4 falhas | verde |
| `Main._saindo_do_berco` | 9 falhas | verde |
| `Main._visita_do_berco` | 7 falhas | verde |
| `Main._empresa_na_estrada` | 7 falhas | verde |
| `PainelBoletim._resumo` | verde | **verde, 57 `SCRIPT ERROR`** |
| `Main._base_do_caminhao` | **verde, 4 `SCRIPT ERROR`** | verde |
| `Dock._destino_n3` | **verde, 3 `SCRIPT ERROR`** | verde |
| `Dock._leva_n3` | **verde, 1 `SCRIPT ERROR`** | verde |
| `Dock._trecho_ida` | **verde, 1 `SCRIPT ERROR`** | verde |

Sete reprovam por uma asserção qualquer; **cinco deixam o marcador verde** e
só a varredura de `SCRIPT ERROR` do CI os apanha; **nenhum dos doze diz que
nome mudou**. O erro aponta para a linha do teste que usou o `null`
(«Nonexistent 'Vector2' constructor», «Invalid cast») ou rebenta em cascata
dentro do `Dock.gd`. A revisão dizia «calado»; medido, é **longe da causa** —
e, numa corrida local que lê o marcador, calado em cinco de doze. Das
ferramentas que leem assim, a da captura só corre na bateria, e o
`medir_transito` e o `medir_fila_mensagens` não correm em CI nenhum.

## A forma, e porquê

**Por alvo, e não «existe em algum script».** O M8 vai tirar o tráfego dos
camiões do `Main`: o nome continua a existir no projeto, no script novo, e a
suíte continua a pedi-lo ao `Main`. Uma conta pela união de todos os scripts
daria esse caso por bom — é o mutante M2 abaixo.

**O alvo é a cena, não o caminho do script.** A suíte instancia `Main.tscn`;
o F19 pergunta ao script que está na raiz dela. Uma PASTA (`scenes/panels/`)
quer dizer «um dos painéis de lá», que é a pergunta do `has_method("_fechar")`
do medidor da fila.

**O receptor declara-se; o tipo não se infere.** Ler do texto que `tela` é o
`Main` pedia seguir atribuições, parâmetros de função e laços — medido, os
`tela` com leitura privada nascem de `load(CENA).instantiate()`, do `_main` e
de parâmetros de três funções diferentes. A declaração diz, por arquivo,
que variável é que alvo. O que isto não vê está abaixo.

**Dois caminhos, como o F9 (`037`).** A expressão lê as leituras; à parte,
conta-se cada literal com cara de privado (`"_x"`) no arquivo. O literal que
nenhuma leitura explica reprova — é o que faz uma forma nova
(`(tela as Control).get(...)`, um `call_deferred`, um receptor que é cauda de
`self.x`) reprovar em vez de escapar. A leitura sem o nome na chamada
(`tela.call(par[1]`) só passa declarada, com os nomes que lhe chegam e o alvo
deles; e o nome procurado no **código-fonte** do alvo — o `"_cida"` do F4,
que acha no `Main.gd` as linhas que fazem a Dona Cida falar — é um indireto
sem chamada.

**A isenção pergunta-se a si própria.** O literal declarado como «não é
membro» (um sufixo de PNG, uma chave de dicionário) nunca seria perguntado
ao alvo: é onde o defeito cabe inteiro (`079`). O F19 reprova a isenção cujo
nome É membro de um alvo. ⚠️ **Apanhou-me na estreia:** eu tinha declarado o
`"_cida"` como pedaço de nome, e o `Main` tem um método `_cida`.

**Toda declaração tem de estar viva:** receptor sem leitura, chamada indireta
que sumiu, literal declarado que já não aparece. E a expressão prova-se antes
de varrer, num fixture com cada forma que caça e as que tem de deixar sem
dono. ⚠️ **A primeira corrida reprovou o próprio fixture:** a lista dos
nomes esperados escrevia-os entre aspas, e este arquivo também é varrido. O
fixture monta as aspas por `%s` e compara os nomes sem o sublinhado.

## Os números

**52 nomes** — 38 do `Main` (oito deles indiretos: os dois da rota do D35, as
cinco portas da tabela `PAINEIS` da captura e o `_cida`), 12 do `Dock`, um do
`PainelBoletim` e o `_fechar` de «um painel». A revisão contava 38 (29, 7 e
2), sem os indiretos; a varredura acha mais um no `Main` e cinco no `Dock`, e
um `grep` de linha acha os mesmos — a diferença não é a quebra de linha. O
piso da asserção é 30, abaixo da medida de propósito: o M8 vai tirar leituras.

## A prova

Catorze mutantes, cada um num sítio só, o original guardado por cópia e a
base verde exigida entre todos. Cada um reprova pela asserção que o caça:

| # | Defeito | Reprova |
|---|---|---|
| M1 | `Dock._tw_trabalho` renomeado | existe no alvo |
| M2 | `Main._base_do_caminhao` renomeado e o mesmo nome posto no `Dock` — o nome que muda de dono | existe no alvo, só as leituras do `Main` |
| M3 | `Main._fila` passa a método | existe no alvo, com o tipo (`get` e `in`) |
| M4 | `Main._entrar_no_mapa` renomeado — indireto | existe no alvo |
| M5 | `(_main as Node).get(...)` numa ferramenta | literal sem dono |
| M6 | `outro.get(...)`, receptor não declarado | existe no alvo («a declaração não diz que alvo é») |
| M7 | `_main.get(campo)` novo | literal sem dono (leitura sem nome não declarada) |
| M8 | literal declarado que não aparece | declaração morta |
| M9 | a expressão cega (`gett`) | a prova da expressão, o literal sem dono, as mortas e o piso |
| M10 | `tools/` fora da varredura | a varredura, o arquivo da declaração e as mortas |
| M11 | a expressão sem atravessar a quebra de linha | **só** a prova da expressão |
| M12 | `_subir`, lido de verdade, declarado como não-membro | a isenção |
| M13 | `Main._pode_sair` passa a variável | existe no alvo, com o tipo (`call`) |
| M14 | `Main._cida` renomeado | existe no alvo (procurado no código-fonte) |

Três coisas medidas de passagem:

- **O M11 só reprova pelo fixture:** hoje nenhuma leitura real parte a
  chamada numa linha e o nome na seguinte. É o fixture que segura essa forma
  para o dia em que aparecer.
- **O M14 passa no F4:** o `contains("_cida")` acha as linhas de `_cida_x(`
  na mesma. Só o F19 vê o renome.
- **A primeira versão do M13 não isolou nada:** renomear só a `func` deixava
  uma chamada interna a apontar para a variável, o `Main` não compilava e o
  F19 reprovou por «todo alvo tem um script com membros», com as cinquenta
  leituras atrás. Refeito com o renome inteiro, reprova só a leitura do
  método.

## O que ele não vê

- O nome **público** lido por string (`tela.call("trechos_de")`,
  `corte_da_curva`, `s_na_rota`, `silhueta_do_trecho`, `arte_do_barco`): é
  API do script, e o `call` grita. O M8 vai mexer nestes — o `SCRIPT ERROR`
  apanha-os em corrida.
- O membro privado lido **direto** num nó destipado (`main._refresh_hud()`,
  `doca._tw_realce`): medido, 17 ocorrências, 11 nomes em 13 pares (arquivo,
  nome). Também grita, mas só quando a linha corre.
- O **caminho de nó** do `get_node`, e as leituras do `GameState`.
- A **variável com o nome de um alvo apontada a outra classe**: pediria o
  nome ao alvo errado, e passaria se os dois tivessem o mesmo nome. A
  declaração pede que o nome tenha um sentido só em cada arquivo, e é o que
  se cumpre hoje; a guarda não o confere.
- As ferramentas em **Python** que leem o texto do `Main.gd`
  (`conferir_cobertura_paineis.py` procura o `_abrir_painel(`) — essas
  reprovam pelo vazio, que já guardam.
- A isenção escrita **depois** de o nome mudar: aí ela já não se distingue de
  um sufixo, e quem segura é a revisão do JSON.

## Para o M8

Partir o `Main` vai reprovar o F19 com a lista exata das leituras que
mudaram de dono. O caminho é o da suíte ler o membro no script novo — um alvo
novo na declaração, com a cena ou o nó que o carrega — e nunca afrouxar o
F19 para o `Main` «ou qualquer um».
