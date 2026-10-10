# 091 — O `CLAUDE.md` enxuto: um núcleo, as regras gerais e uma regra por tema

**10/10/2026.** Main `9961742` (PR #114, o M3, fundido; nenhum PR aberto do
Codex); 091 livre conferida na main antes de escrever. É o **M4** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), com a resposta do Bruno ao **D2**.

## A resposta do Bruno ao D2

A pergunta: reorganizar o `CLAUDE.md` num núcleo curto e regras por tema em
`.claude/rules/`? A recomendação era sim. A resposta foi **«Sim»**, e logo a
seguir: **«Não esqueça de colocar regras gerais.»**

A fila previa nove regras, todas com `paths:`. O pedido acrescentou a décima
categoria, que a fila não tinha: as lições que valem seja qual for o arquivo
aberto — como uma régua mente, como um defeito injetado deixa de provar, como
uma edição apaga um arquivo, como o git e o briefing enganam no arranque.
Presas a um `paths:`, só as veria quem por acaso abrisse um teste.

## O que mudou

O `CLAUDE.md` tinha **3.079 linhas e 223.668 bytes**, e carregava inteiro em
toda sessão; a documentação do Claude Code pede menos de 200 linhas e manda o
que só vale para parte do código para regras com `paths:`. Hoje:

| Arquivo | Carrega | Linhas | Bytes |
|---|---|---|---|
| `CLAUDE.md` (o núcleo) | sempre | 407 | 25.268 |
| `.claude/rules/gerais.md` | **sempre** (sem `paths:`) | 271 | 19.091 |
| `arte.md` | `blender/`, `art_lab/`, `brport_vs/art/`, ferramentas de prop | 517 | 37.437 |
| `interface.md` | cenas, tema, painéis, `Main.gd` | 446 | 32.291 |
| `testes-e-guardas.md` | testes, validações, `tools/conferir_*`, réguas, workflows | 388 | 28.035 |
| `mapa.md` | `gerar_mapa_iso.py`, os mapas | 257 | 18.295 |
| `projecao.md` | os dois geradores, `blender/`, `Main.tscn`, `Dock.tscn` | 245 | 17.153 |
| `captura.md` | ferramentas de captura e folhas | 251 | 17.012 |
| `narrativa.md` | `Narrativa.gd`, `Retratos.gd`, painéis de fala | 226 | 16.170 |
| `economia.md` | `GameState.gd`, simulador, projetor, tabela | 161 | 10.540 |
| `gdscript.md` | qualquer `.gd` | 106 | 7.178 |
| `audio.md` | `Audio.gd`, `gerar_sons.py`, `medir_audio.py` | 74 | 4.518 |
| `plataforma.md` | `project.godot`, export, workflows, hook | 73 | 3.955 |
| `save.md` | `GameState.gd`, `ArmazemLocal.gd`, `teste_fumaca.gd` | 47 | 2.396 |

**O que carrega em toda sessão caiu de 223.668 para 44.359 bytes (−80%).** Uma
sessão de economia soma a de economia, a do save e a do GDScript (~20 KB); só
quem abrisse um arquivo de cada tema voltaria aos ~239 KB de antes.

- **O núcleo** guarda o que a fila nomeou: as quatro camadas, como rodar e a
  proteção do save do jogador, «o CI não corre ao empurrar», o passo de cada
  item do fecho (com a lista das seis suítes que o `conferir_docs.py` exige),
  o que cabe numa sessão e as fases F1–F7, e o essencial do estilo. A seção
  «As regras que já custaram trabalho» virou o **índice**: que regra carrega ao
  abrir o quê, e **onde foi parar cada seção antiga**.
- **As regras gerais** levam do item 7 do fecho as lições que valem para
  qualquer régua (o valor impossível, o `has()` que não conta duplicatas,
  percurso contra arquivo, a régua que precisa de defeito injetado, o tempo
  emparelhado, a receita derivada que não casa nada, o número partido por uma
  quebra de linha, o `$?` do comando certo, a base limpa, a saída como
  contrato); o «varra os irmãos»; do estilo, a edição que trunca e o relatório
  que mente; de «O que cabe numa sessão», o briefing e os três avisos de git;
  e, de «Como rodar», o LF do Windows e a pesquisa pela busca. As de suíte e de
  guarda do Godot ficaram em `testes-e-guardas.md`.
- **Três regras a mais do que as nove da fila, e uma a menos.** A `mapa`
  existe porque o `paths:` que a fila dava à `arte` não tinha o
  `gerar_mapa_iso.py`: as ~50 lições do desenho do mapa — costa, água, vila,
  rua, o raster do D20 — teriam ficado fora de quem mexe só no gerador. A
  `plataforma` leva o `.pck`, a VRAM e as chaves do Godot, que não são de tema
  nenhum dos nove; a `gdscript`, as armadilhas da linguagem, que valem em
  qualquer `.gd`. Uma `geradores` chegou a estar no desenho e não entrou: as
  três lições do byte a byte (`fsum`, a poda do `argmin`, o `zlib`) são do
  raster do mapa, e foram para a `mapa`.

## Movimentação literal, e a prova de que nada se apagou

Cada linha do original foi para **exatamente um** destino, por intervalo de
linhas, palavra por palavra — a lição não se reescreve ao mudar de casa. Fora
disso só os cinco separadores `---` e **cinco linhas reescritas de propósito**:
a 7, a 8 e a 12 (o núcleo deixou de ser «a única que carrega sozinha» e as
regras passam a ser «este arquivo e `.claude/rules/`») e a 31 e a 32 (o
`AGENTS.md` deixou de apontar «só» para este arquivo).

A prova é por dois caminhos, que se conferem um ao outro:

- **multiconjunto:** toda linha não vazia do original aparece, tantas vezes
  quantas lá estava, na soma do núcleo com as regras;
- **contagem:** **280 avisos ⚠️ antes e 280 depois**; **428 títulos de regra
  antes e 430 depois** — os dois a mais são linhas novas do núcleo («6.
  **Captura de painel**…» e o «**Onde foi parar cada seção antiga.**»). A
  revisão falava em 279: era o número de 09/10, e a `090` acrescentou um.

Três defeitos injetados na própria prova reprovaram os três: uma linha apagada
numa regra, um ⚠️ apagado (reprova pelas duas contas) e uma palavra mudada no
núcleo. Para refazer:

```sh
git show 9961742:CLAUDE.md > /tmp/antes.md
python3 - /tmp/antes.md <<'EOF'
import collections, glob, sys
antes = open(sys.argv[1], encoding="utf-8").read().split("\n")
fora = {7, 8, 12, 31, 32}
esperado = collections.Counter(l.strip() for i, l in enumerate(antes, 1)
                               if l.strip() and l.strip() != "---" and i not in fora)
achado = collections.Counter()
for p in ["CLAUDE.md"] + glob.glob(".claude/rules/*.md"):
    achado.update(l.strip() for l in open(p, encoding="utf-8").read().split("\n") if l.strip())
print("faltam", sum((esperado - achado).values()))
EOF
```

## O endereço do triplo do balanceamento

Era o `CLAUDE.md`, e cada PR de economia reescrevia lá a medição — o #109 e o
#110 trocaram a mediana do Mediano duas vezes, num arquivo que todas as
sessões carregavam. A fila pedia que os números voláteis saíssem do núcleo e
ficassem «só na tabela gerada e nos JSON de medição». **Saíram do núcleo, e o
endereço passou a ser `.claude/rules/economia.md`**, que só carrega quando a
sessão abre o `GameState.gd` ou o simulador — as mesmas sessões que os
reescrevem. A tabela gerada não serve: ela sai das constantes, e o triplo é
MEDIDO; o JSON das medições vive em `docs/arquivo/`, que é história. O
`ENDERECO_DO_TRIPLO` do `conferir_docs.py` diz isto ao lado.

## A guarda nova (`tools/conferir_docs.py`)

O mecanismo falha de três maneiras CALADAS, e é isso que ela confere:

1. **Um `paths:` que não casa com arquivo nenhum** é uma regra que nunca
   carrega. Cada glob tem de casar com pelo menos um arquivo do `git ls-files`,
   com a semântica do Claude Code (`**/` casa zero ou mais pastas).
2. **Um frontmatter que não se lê** faz o Claude Code carregar a regra como se
   não tivesse `paths:` — sempre —, e o contexto volta a inchar sem ninguém
   ver. O conferidor aceita UMA forma (`paths:` e itens `  - "glob"`) e reprova
   qualquer outra; uma regra sem `paths:` só passa se estiver em
   `REGRAS_SEMPRE`, que hoje é `gerais.md`.
3. **Uma regra que ninguém lista** não existe para quem não a abre: cada uma
   tem de ter uma **linha de tabela** no núcleo e no `AGENTS.md`. Uma menção
   qualquer não chega — os itens 3 e 4 do fecho já citam a de economia, e a
   primeira versão, que procurava o nome no arquivo, dava a linha do índice por
   presente com ela apagada.

E o que carrega sempre tem teto, o **`TETO_SEMPRE` de 48.000 bytes** (44.359
hoje), pela razão do teto do estado: o modo de falhar medido foi o
crescimento calado.

**Onze mutantes, um de cada vez, com a base verde entre eles; os onze
reprovaram pela guarda certa:** um glob com erro de digitação no `mapa.md`; o
frontmatter do `save.md` sem o `---` de fecho; o do `audio.md` numa forma que o
conferidor não conhece; a linha da narrativa tirada do `AGENTS.md`; a da
economia tirada do índice do núcleo; uma regra nova sem `paths:`; o triplo
copiado para as gerais; o triplo tirado da economia; as gerais acima do teto;
as gerais com `paths:`; e o glob das cenas apontado para uma pasta que não
existe.

## A prova de que as regras carregam

A fila pedia «uma sessão de teste a abrir um arquivo de cada tema». Foi esta:
as regras nasceram a meio dela, e o harness injetou cada uma ao primeiro Read
ou Edit de um arquivo do tema, já sem o frontmatter, como a documentação diz.

| Arquivo aberto | Regras que carregaram |
|---|---|
| `tools/conferir_docs.py` (Edit) | testes-e-guardas |
| `docs/BRP_SPATIAL_CONTRACT.md` | projecao |
| `tools/gerar_mapa_iso.py` | mapa |
| `tools/conferir_lote_de_arte.py` | arte |
| `tools/projetar_parcelas.py` | economia |
| `brport_vs/scripts/ArmazemLocal.gd` | save, gdscript |
| `brport_vs/ui/tema_brport.tres` | interface |
| `brport_vs/scripts/Narrativa.gd` | narrativa |
| `tools/gerar_sons.py` | audio |
| `tools/capturar_evidencia.sh` | captura |
| `brport_vs/project.godot` | plataforma |

## O que fica de fora

- **As gerais a carregar no ARRANQUE não se viram nesta sessão**, que começou
  antes de elas existirem. A documentação diz que regra sem `paths:` carrega
  com a mesma prioridade do `CLAUDE.md`; a próxima sessão confere-o no
  `/context`, e o briefing pede-o.
- **As citações antigas não foram reescritas.** São 258 linhas em 79
  arquivos, na forma «`CLAUDE.md`, Arte» — quatro delas em comentários do
  `GameState.gd`, onde mexer deslocaria as linhas que a tabela dos números
  cita. Reescritas foram só as que MANDAM fazer alguma coisa: as três skills,
  o `AGENTS.md` e o resumo do `balanceamento.yml`. Resolvem pela
  tabela «Onde foi parar cada seção antiga» do núcleo, e cada regra guarda o
  título da seção de onde veio.
- **Um «a regra acima» ou «irmã de» pode hoje apontar para outro arquivo.** A
  lição foi movida inteira e o vizinho dela nem sempre; o `CLAUDE.md` como era
  está no `9961742`.
- **Uma regra de tema só carrega por Read, Edit, Write ou um `cat`/`head` de
  um arquivo só.** Um `grep` pela árvore não a carrega, e uma pergunta sem
  arquivo aberto não a vê: é para isso que as skills `/arte` e `/balancear`
  passaram a mandar abrir a sua regra antes de tudo.
- **O Codex não carrega `.claude/rules/`.** O `AGENTS.md` lista-as numa tabela
  e manda abrir a de cada tema que a tarefa toca; o conferidor reprova regra
  que falte lá.
- **Os planos citam o `CLAUDE.md` como o único que carrega sozinho** em itens
  já fechados (B5). É história, e o M5 desce esses itens para o arquivo.
