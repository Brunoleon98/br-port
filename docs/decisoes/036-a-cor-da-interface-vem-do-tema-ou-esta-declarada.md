# 036 — A cor da interface vem do tema, ou está DECLARADA

**21/09/2026 · R7 da §7.1 do plano v3 · origem: revisão externa de 17/09 (§2.4,
segunda metade)**

## O que fez este portão existir, e não foi um defeito de contraste

O R6 fechou em 20/09 com **zero reprovações** em 214 textos e 19 estados
(`035`). O R7 herdou uma linha de governança — *"há 22
`add_theme_color_override` em cinco scripts"* — e o briefing dizia, com um
aviso de que era medição: **ficaram 18**.

Contado no HEAD: **19**. E a diferença tem nome.

No MESMO commit em que migrou três overrides para o tema, o R6 **acrescentou
um quarto** — `UpgradePanel.gd`, o rótulo com o motivo do bloqueio que saiu de
dentro do botão desligado. 21 − 3 + 1 = 19. O briefing fez a subtração de
cabeça e nunca contou; nada no projeto contava.

⚠️ **E UM PORTÃO DE CONTRASTE NÃO PODIA TER APANHADO ISSO.** A cor nova é
0,35/0,42/0,50, que mede 5,46:1 e passa o AA com folga — o D33 estava certo em
deixá-la passar. *"Esta cor é legível?"* e *"de onde veio esta cor?"* são duas
perguntas, e o projeto só tinha a primeira.

## E o inventário em runtime também não podia

O `medir_contraste_ui.gd` sabe responder `override` / nome da variação / `tema`
por texto — é a coluna que o briefing manda rodar antes de escrever scanner
nenhum, e foi por aí que esta sessão começou. Mas **ele só vê o que o percurso
alcança.** Medido em 21/09, dos sítios que pintam cor à mão o percurso de 19
estados não chega a três:

| Cor | Onde | Por que escapa |
|---|---|---|
| `COR_PASSADO` | dia já vivido do calendário | o percurso abre o calendário no **dia 1** |
| `COR_FEITO` | estrutura já construída | o percurso abre o Construir com o porto em **ruínas** |
| `COR_ESPERANDO` no progresso | doca sob oferta do rival | nenhum estado monta essa doca |

⚠️ **O `COR_PASSADO` QUE O BRIEFING ENTREGOU COMO CASO DE TESTE NUNCA ESTEVE
NOS 214 TEXTOS.** Os 5,42:1 dele são uma conta à mão, não uma medição do
percurso. **Percurso responde pelo que se VÊ; arquivo responde pelo que
EXISTE** — e é preciso ter os dois, que é exatamente o *"complementar com
runtime"* da ficha, lido do outro lado.

## A superfície medida, que é o dobro do que se dizia

Contado no que o jogo **exporta** (escopo derivado, abaixo):

| Forma | Onde | Quantos |
|---|---|---|
| `add_theme_color_override` | 4 scripts | 19 |
| `theme_override_colors/*` numa cena | 2 cenas | 10 |
| cor de `StyleBoxFlat` em `sub_resource` | `Main.tscn` | 4 |
| cor de `StyleBox` pintada em código | `Worker.gd` | 1 |
| **total** | | **34** |

As 15 últimas nunca tinham sido contadas por ninguém: todo inventário anterior
procurava a chamada, e cor de interface também chega por CENA e por STYLEBOX.

## A decisão 1 — a granularidade é o TRIO, com contagem

A ficha manda *"exceção exata por propriedade/local, com justificativa; não
liberar arquivo inteiro"*. A chave é **(arquivo, receptor, propriedade)**, e o
valor traz as **cores** e a **contagem de chamadas**.

- **Por ARQUIVO não** — a ficha proíbe, e foi assim que a chamada nova do
  `UpgradePanel.gd` entrou: o arquivo já tinha outras.
- **Por LINHA não.** Número de linha envelhece calado a cada edição acima dele.
  É a regra que este projeto já tem escrita para o caso irmão: *"número em
  pixel escrito à mão envelhece calado quando o que ele descreve muda de
  tamanho"*.
- ⚠️ **A CONTAGEM ENTRA NA CHAVE**, porque o mutante da ficha é *"nova chamada
  no arquivo que já tinha outra exceção"*. Sem ela, uma segunda chamada com a
  mesma forma — mesmo nó, mesma propriedade, mesma cor — passa por declarada.
  É a mesma regra da folha de contato que reprova ao transbordar, e a do
  percurso do D33 que declara quantos estados tem.
- ⚠️ **E A COR RESOLVIDA ENTRA JUNTO COM O NOME.** Declarar `COR_AVISO` e mais
  nada deixaria o VALOR livre: trocar o `Color(...)` da `const` daria verde. O
  registro guarda `NOME = Color(r, g, b)` quando a `const` está no mesmo
  arquivo (M4).

## A decisão 2 — as duas fronteiras derivam, nenhuma é lista à mão

**O escopo sai do `export_presets.cfg`.** O que o jogo não exporta não é
interface do jogo: `tools/*`, `tests/*`, `scripts/validation/*`,
`scenes/proto/*` e `scenes/tests/*` já estão no `exclude_filter`. Escrever a
lista no portão seria a armadilha registada no `CLAUDE.md` — *"se está escrito
que sai de algum lado, faça-o sair de lá"*. E os dois presets têm de
**concordar**, senão reprova: um filtro divergente entre Android e Web daria
escopos diferentes ao mesmo portão.

**A cor tem de entrar no sistema de TEMA.** A ficha manda não acusar cor de
mapa nem de arte procedural, e quem separa não é o arquivo — é a PROPRIEDADE,
que o Godot define. `modulate`, `self_modulate`, `ColorRect.color` e os `draw_*`
são pintura: o piscar da fauna, o realce do píer, o escurecer atrás de um
modal. Nenhum passa pelo tema. O que passa são três formas e só elas:
`add_theme_color_override`, `theme_override_colors/*` e uma propriedade de cor
de `StyleBox` (`bg_color`, `border_color`, `shadow_color` — lista do Godot).

Medido: no escopo exportado há **23 literais `Color(`** em `.gd`. Esta regra
deixa **12 de fora sem citar arquivo nenhum** — os oito da `Fauna.gd`, o realce
do `Dock.gd` e os três escurecimentos de modal — e não precisa de saber que
eles existem.

## A decisão 3 — a classificação, e são duas classes

| Classe | O que é | Quantos |
|---|---|---|
| **ESTADO** | o MESMO nó toma cores diferentes conforme o jogo | 6 locais, 14 chamadas |
| **BASE** | o nó tem UMA cor fixa; é dívida declarada, não exceção de direito | 13 locais |

A ESTADO é a exceção que se concede. O tema ainda governa (troca-se a
`theme_type_variation` em runtime, como o `DocaCartao._estilo()` já faz com o
painel), mas **cada estado pede a sua variação e cada fundo pede a sua cor** —
e é aí que a migração cega quebra o medido:

⚠️ **NENHUM TOM GANHA DOIS FUNDOS, e o `RotuloAlerta` é a prova.** O âmbar do
`_workers_title` mede **5,53:1** sobre a barra escura, calibrado para lá. O
`RotuloAlerta` que o R6 criou é o mesmo âmbar **escurecido para o cartão
branco**, onde mede 5,06:1. Vesti-lo no `_workers_title` seria a migração de
uma linha que o briefing avisa que quebra coisas — e o portão de contraste só
a apanharia depois de feita.

## A decisão 4 — `RotuloApoio`, e por que NÃO se reusou o `RotuloSecao`

Sete sítios migraram hoje. Quatro deles queriam a cor 0,35/0,42/0,50, que o
tema já tem — no `RotuloSecao`. E **o `RotuloSecao` não serve**:

```
RotuloSecao/colors/font_color = Color(0.35, 0.42, 0.5, 1)
RotuloSecao/font_sizes/font_size = 13      ← e é isto
```

Os quatro rótulos medem **12, 13, 15 e 12 px**. Vesti-los de `RotuloSecao`
encolheria três deles e mexeria no leiaute que o D18 e o D22 medem — numa
migração que só devia mexer na COR.

⚠️ **VARIAÇÃO QUE EMPACOTA TAMANHO COM COR NÃO SERVE A QUEM SÓ QUER A COR**, e
o projeto já sabia disto do outro lado: o comentário do `RotuloAlerta`, escrito
pelo R6, diz *"o tamanho NÃO vive aqui: ela é usada a 13, 15 e 17px"*. O
`RotuloApoio` é o irmão dele — **só cor**, nenhum tamanho.

E é por isso que duas variações com o MESMO valor não são a divergência calada
que esta sessão veio acabar: a diferença entre elas é **estrutural** (uma traz
tamanho, a outra não), não cosmética. O `COR_PASSADO` a 0,52 contra os 0,50 do
tema era cosmética, e por isso foi **apagado** em vez de renomeado.

## O que migrou, e o que prova que não mexeu em mais nada

| Sítio | Era | Ficou |
|---|---|---|
| `UpgradePanel.gd` ×3 | `COR_SECUNDARIA` à mão | `RotuloApoio` |
| `PainelCalendario.gd` | `COR_PASSADO` = 0,52 | `RotuloApoio` = 0,50 |
| `Main.tscn` `Pendentes` | `Color(0.35, 0.42, 0.5)` na cena | `RotuloApoio` |
| `DocaCartao.gd` ×2 | `COR_ESPERANDO` nos dois ramos | **apagados** |

⚠️ **OS DOIS DO `DocaCartao` NÃO PINTAVAM NADA.** A cena já dá ao rótulo o
MESMO `COR_ESPERANDO`, e os dois ramos do script repintavam-no com ele —
overrides que não mudavam um pixel e que **calavam a cena**: mexer na cor lá
não teria efeito nenhum, sem erro nenhum. Prova: a linha *"sem trabalhador"*
mede 7,45:1 antes e depois, e a tabela não muda.

**O antes e o depois da tabela dos 214 textos diferem em 13 linhas, e nas 13 a
única coisa que muda é a coluna FONTE** — `override` → `RotuloApoio` — com a
razão e o tamanho idênticos ao caractere. Continua em **0 reprovam o AA**. As
seis suítes ficaram verdes.

Sobram **27** cores declaradas em 19 locais, cada uma com a sua justificativa
em `tools/excecoes_cor_ui.json`.

## O portão: `tools/conferir_escopo_ui.py`, marcador `ESCOPO UI OK`

Python e não Godot, de propósito: aqui uma exceção sai com código ≠ 0 e o
`set -e` apanha, enquanto o Godot encerra com 0 depois de um erro. O passo
corre **antes do download do Godot**, como o `conferir_guardas_ci.py` ao lado:
custa um segundo e responde a uma pergunta sobre os ARQUIVOS.

⚠️ **E ELE CORTA OS COMENTÁRIOS ANTES DE VARRER.** Os comentários deste
repositório CITAM o que a guarda procura, palavra por palavra — este próprio
arquivo tem `add_theme_color_override` escrito cinco vezes. O corte é pelo
INÍCIO da linha e nunca pelo `#` onde quer que esteja: o `DocaCartao.gd`
escreve `var texto := "#%d" % ...`, e um corte por ocorrência partiria a linha
ao meio.

Ele também lê chamada **multilinha** (parênteses equilibrados), recusa as duas
**fugas dinâmicas** (`.set("theme_override_…")` e `.call("add_theme_…color…")`),
e exige que toda `theme_type_variation` usada exista no tema — porque
`theme_type_variation = "RotuloApio"` **não dá erro nenhum**: cai no tipo base
e sai com a cor errada. É a irmã da regra do `project.godot`, *"valor de Godot
3 numa chave de Godot 4 não dá erro, dá outra coisa"*.

## Os mutantes

Oito, cada um sozinho, com a base exigida VERDE entre eles, a cópia guardada
com `cp` e não com `git`, e o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| M1 | override numa CENA sem exceção nenhuma declarada | reprovou, nomeando o nó |
| M2 | chamada nova no arquivo que já tinha exceção, **com a cor já declarada** | reprovou pela CONTAGEM: 5 contra 4 |
| M3 | `theme_type_variation` para variação inexistente | reprovou, com arquivo e linha |
| M4 | o NOME da `const` fica, o VALOR dela muda | reprovou pela cor resolvida |
| M5 | override apagado e a exceção deixada no registro | reprovou: registro que envelhece |
| M6 | fuga dinâmica por `set("theme_override_…")` | reprovou |
| M7 | override dentro de COMENTÁRIO | **passou**, como devia |
| M8 | a MESMA chamada, sem o `#` e partida em duas linhas | reprovou |

⚠️ **O M7 SOZINHO NÃO PROVA NADA, e é por isso que o M8 é no MESMO ARQUIVO.**
Um verde pode querer dizer *"o comentário foi ignorado"* ou *"o scanner nunca
olhou para este arquivo"*. O par separa as duas coisas: a única diferença entre
o M7 e o M8 é o `#`, e um passa e o outro reprova. É a mesma receita de *"o
mesmo arquivo dos dois lados tem de dar zero EXATO, e um par que se sabe
diferente tem de dar muito"*.

## O que fica de fora, dito

- **Os 28 restantes não migraram, e é a ficha que o permite**: *"bloquear novas
  exceções pode anteceder a migração toda"*. Eles estão declarados, com classe
  e justificativa, e o caminho de cada um está escrito: uma leva de variações
  **por fundo**, não uma migração linha a linha.
- **O percurso dos 19 estados não ganhou estados novos.** As três cores que ele
  não alcança continuam por medir — e migrá-las antes de o percurso as montar
  seria trocar uma dívida visível por uma invisível. **O estado vem primeiro, a
  cor depois.**
- **O `Worker.gd` é a única cor de interface que não chega por `font_color`** —
  é a borda do trabalhador selecionado, fora do portão de contraste por não ser
  texto. Fica declarada.
- **As duas decisões de PALAVRA continuam com o Bruno** (o rótulo `"Caixa:"` e
  a fala da semana nova). O R7 não lhes tocou: texto é gate dele.
