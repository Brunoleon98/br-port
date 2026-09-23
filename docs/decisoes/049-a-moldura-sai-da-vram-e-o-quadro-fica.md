# 049 — A moldura sai da VRAM, e o quadro fica

**23/09/2026 · opção (b) do briefing `23e`, escolha do Bruno:** cortar o
quadro dos props. A `029` mediu que **89,6% do quadro de 768 é moldura vazia**
e deixou o corte como item próprio, porque ele mexeria no contrato *"o centro
do quadro é a origem do mundo"*.

## O que se decidiu

1. **Os 60 props de mapa de `art/props` importam como `texture_atlas`**, um
   atlas por prop em `art/props/_atlas/`. O importador do Godot apara a borda
   transparente e devolve um `AtlasTexture` cuja **margem repõe o quadro**: a
   textura continua a reportar 768×768 e desenha-se no mesmo sítio.
2. **O contrato não se mexe.** Nenhum `offset` de cena, nenhuma âncora, nenhum
   `expand_mode`, nenhuma `scale` do `Fauna.gd`, nenhuma entrada do manifest e
   nenhum PNG em disco. Sem `bpy`, sem regerar os 69.
3. **Os nove retratos de fala ficam de fora**, e não por lista: o empacotador
   arredonda a LARGURA do atlas a potência de dois, e um retrato de 510 px
   sai num atlas de **1024×724 — 26% pior** do que o quadro que devia poupar.
4. **Quem lê pixel de um prop lê pelo `PropIso`.** O `get_image()` de um
   `AtlasTexture` devolve a REGIÃO, com o canto em (0, 0); `PropIso.imagem()`
   cola-a de volta no quadro, e é por ela que passam as sete réguas do teste de
   design, o validador e as duas folhas.

⚠️ **O briefing previa o caminho caro** — `bpy`, os 69 regerados, âncora
publicada por prop, os 31 nós, o manifest — porque lia o quadro como ARQUIVO.
A pergunta era o quadro na VRAM, e essa o importador responde sem tocar no
arquivo.

## A medição, emparelhada neste contêiner

| | antes | depois |
|---|---|---|
| **VRAM de textura em jogo** (monitor do motor, `Main` aberto, 2 corridas) | **235,68 MB** | **64,04 MB** |
| só os 60 props, pelo monitor | 180,00 MB | 5,56 MB |
| só os 60 props, RGBA8 `w×h×4` | 135,00 MB | 4,17 MB |
| `.pck` do export Android | 6.334.508 B | 5.234.788 B (**−1.099.720, −17,4%**) |
| contra o APK da `main` (33.520.280 B) | | **≈ −3,3%** |

Os 69 props a 768 passam a ocupar **24,4 MB** de RGBA8 (4,17 dos 60 em atlas e
20,25 dos nove retratos) — menos do que os **63,96 MB** que os 61 de então
ocupavam a 512 sem corte (`029`). O preço da alavanca B ficou abaixo do que
era antes dela.

A régua é `tools/medir_vram.gd` (`VRAM MEDIDA`, com `xvfb-run`): reproduz os
235,68 na `main` de antes e os 64,04 depois, igual em duas corridas, e em
`--headless` recusa-se em vez de dar zero.

⚠️ **O MONITOR CONTA 4/3 DE `w×h×4`**, e isto custou uma volta: a primeira
leitura dava 180 MB para 155 de conta e 5,6 para 28, e os dois lados não
fechavam. Uma sonda de UMA textura, onde a resposta se sabe de cor (768²×4 =
2,25 MB), deu **3,00** — a razão é a mesma dos dois lados, e os retratos davam
delta zero porque um autoload já os tinha carregado antes da base. Com isso a
conta fecha: (155,25 − 20,25) × 4/3 = 180,00.

## O desenho não mudou

A bateria (27 tiros, `COBERTURA OK`) contra a de antes do atlas:

- **13 fotos idênticas**, as cinco folhas de contato incluídas;
- as outras 14 diferem em **≤ 0,021% dos pixels, máximo 19/255**, em colunas
  de borda de prop: amostragem sub-texel de uma região do atlas contra a do
  quadro inteiro. A 8× não se distingue.

## Os achados

⚠️ **UM `AtlasTexture` POR CIMA DE OUTRO NÃO COMPÕE.** As duas folhas
recortavam o prop com `atlas = <textura do prop>`; com o prop já em atlas, o
`get_image()` do conjunto devolvia o desenho inteiro e o `draw` desenhava a
margem vazia. A folha da frota saiu com os doze quadros em branco e **imprimiu
"Folha salva em"**. O recorte passou a apontar para o atlas de BAIXO
(`PropIso.recorte`).

⚠️ **E A FOLHA NÃO PERGUNTAVA SE A PEÇA CHEGOU À FOTO.** Uma guarda que lesse o
`get_image()` passaria com o defeito posto, porque é exatamente ele que mente.
Hoje cada folha fotografa duas vezes — com a arte e sem ela — e conta, por
peça, os pixels que mudam (`PropIso.desenho_na_foto`). Não compara com a cor do
chão: o chão pode ser listrado e o filtro mistura as listras. O defeito dá
**zero exato**; o corte fica a meio da banda medida (38 px o `poste_luz` a
1:1 → 19; 2.946 o `caminhao_pescado_mx` a ZOOM 2 → 1.473).

⚠️ **O IMPORTADOR REESCREVE A COR DA BORDA QUASE TRANSPARENTE, EM QUALQUER
TEXTURA.** A primeira comparação quadro-contra-arquivo deu **0 de 69 iguais**,
os retratos incluídos, que nem estão em atlas. Medido: alfa idêntico em todo
pixel, cor idêntica onde o alfa passa de 20, e só difere o RGB de alfa ≤ 16 —
é o `fix_alpha_border`. A guarda compara o que é desenho.

⚠️ **O `arte_orfa.py` passou a contar os atlas como arte** — "10 de 175" em vez
de "9 de 115" —, com 59 a casar pelo NOME DO PROP e o do `doca_concreto` como
órfão pela segunda vez. Atlas é produto do importador; ficou fora da conta.

## As guardas, e o que cada mutante mostrou

O `asset_validator` percorre a PASTA — o manifest tem 44 entradas e os props
são 69 — e pergunta: atlas mais caro do que o quadro reprova; prop com menos de
30% de desenho fora do atlas reprova (props de mapa até 16,3%, retratos desde
55,5%, meio geométrico com folga 1,8x); o quadro reconstruído tem de ser o
desenho do arquivo.

| mutante | o que reprovou |
|---|---|
| M1 `galpao` volta ao importador de textura | **só** o validador — 5,4% fora do atlas. O prop desenha igual; nada mais o vê |
| M2 um retrato em atlas | **só** o validador — atlas 1024×724 |
| M3 `crop_to_region=true` | **só** o validador — quadro 185×171. ⚠️ O teste de design não o vê: o `galpao` só entra em cena com o armazém construído, e no jogo sairia esticado a 512 |
| M4 `PropIso.imagem` sem a margem | o validador nos 60 (nomeia a causa) e 17 réguas do teste de design (o sintoma) |
| M5 margem do recurso deslocada 10 px | **só** o validador. A primeira versão encolheu também o quadro, e isso era OUTRO defeito — refeito com deslocamento puro |
| M6 recorte por cima do atlas | as duas folhas: 0 px em cada peça, código 1, sem "Folha salva em" |
| M7 a folha não esconde a arte | 0 px em tudo: a régua falha FECHADA, nunca aberta |

Base verde entre cada um; originais por `cp`.

## E o CI

Clone limpo do commit, **um** `--import`: zero erros, e a árvore fica LIMPA —
o passo das âncoras exige `git diff --quiet -- brport_vs/art` depois do import,
e um atlas reescrito com outros bytes pô-lo-ia vermelho. Os 60 atlas e os
`.import` deles vão commitados: sem eles, o primeiro import dá 119 erros
(scripts que fazem `preload` antes de o atlas existir) e só o segundo sai
limpo. O importador é determinístico nesta versão do Godot.

## O que fica de fora

- **Os 8 de `art/brp`** continuam inteiros: servem a bancada de teste e estão
  presos à `001`.
- **Os retratos** continuam a 768: o atlas custa-lhes mais do que poupa. Um
  corte deles pediria `crop_to_region` e mexeria no enquadramento de interface.
- **Um prop novo** entra pelo importador por omissão e o validador reprova-o —
  converter-lhe o `.import` faz parte de o acrescentar.
- A VRAM medida é a do monitor do motor em OpenGL, neste contêiner; nenhum
  telefone foi medido.
