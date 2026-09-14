# BR Port — briefing da próxima conversa

> Fechado em 14/09/2026, depois da costa das duas pontas.
> Ponto de entrada curto; o estado canônico é `docs/ESTADO_DO_PROJETO.md` e a
> ordem do projeto, a §7 do plano v3.

## O que acabou de ficar pronto

A branch `claude/continue-recent-pr-4428us` fecha a **primeira fatia do item 8**
do segundo playtest (`docs/decisoes/023`): a linha de água das duas praias
deixou de ser uma escada de traços retos — maior reta de **224 px para 16**,
quinas de **126,9° para 14°** — e o **cais continua reto**, batendo com o de
antes a 1e-15 unidades.

Tudo o que acompanha a costa sai agora de `ponto_costeiro()`, uma família
concêntrica de curvas. O raster da água ganhou índice espacial (182 s → 12 s por
mapa), provado byte a byte igual à força bruta. O **D28** tranca a forma da
linha, com cinco defeitos injetados a reprovar cinco asserções diferentes.

**Não refaça a costa nem mexa em `ONDA_AMP`, nos raios de `QUINAS_DE_PRAIA` ou
na máscara** sem ler a `023` — o cais depender daquela máscara valer zero é o
que mantém âncoras, vias e vila no sítio.

## Próximo recorte recomendado

**A segunda fatia do item 8: as CONSTRUÇÕES.** O pedido do Bruno fala de duas
coisas — *"seja nas construções, como no mapa e seu desenho"* — e só o mapa foi
respondido.

O kit é de caixas, e isto está medido: no `tools/gerar_props_iso.py` são **97
chamadas a `caixa()`** contra 18 a `cone()`, 3 a `prisma()`, 9 a `barra()` e 2 a
`trelica()`; o `blender/brp_porto.py` traz mais 36 caixas. Tudo o que se vê no
pátio, nos píeres e na frota nasce de prismas com um chanfro de 0,020 por cima.

Condições do recorte, e a primeira é a que decide o tamanho dele:

- **DECIDIR O QUE NÃO GANHA CURVA, com número.** Armazém, escritório e cais são
  obra industrial e são quadrados de verdade; o que pede curva é outra coisa
  (telhado, casco, copa, veículo, silo). Uma sessão que arredonde tudo entrega
  um porto de brinquedo. Esta escolha é **Opus**, e é a F1;
- medir o ANTES com uma régua própria de prop — a fração da silhueta que corre
  nas quatro direções do eixo isométrico, por PNG, é o análogo da "maior reta"
  que a costa usou;
- **isto é sessão de Blender**: `pip install "bpy==4.5.0"` (~1 GB, Python 3.11),
  e prop **não é artefato byte-reprodutível** (o denoiser varia ±2/255) — quem
  compara dois renders reduz a 16×16, e quem prova que o prop chegou à tela é a
  folha de contato, não o `cmp`;
- respeitar as armadilhas já escritas no `CLAUDE.md`: corte de quina somado a
  estreitamento dá **geometria degenerada** (a barra preta dos bustos), encolher
  escala-se no GRUPO, e a esta escala **uma silhueta memorável, não cinco**;
- não tocar na projeção, nas âncoras nem na pegada publicada: prop que muda de
  forma muda de pegada, e o D2/D15 medem-na.

Se a medição mostrar que o ganho é pequeno para o custo — é um resultado
legítimo e já aconteceu neste projeto (o contorno de traço, a Etapa 3) —,
**pare, registe a medição e devolva**, em vez de arredondar por arredondar.

## As alternativas, se ele preferir outra coisa

- **a rua a 1,8** — medido e por fazer, mas alargá-la empurra o `RUA_RECUO` e o
  enquadramento inteiro (`012`). Sessão própria;
- **item 24** (desconto por antecipação) — hoje já tem o quarto perfil, o
  Antecipado (`018/019`);
- **18 · 19 · 21** (cidade, lojas, análise) — muito grandes, e o 17 abriu-lhes a
  porta sem responder à pergunta da economia da Fase 2.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md,
docs/design/BR_Port_Plano_v3_Claude_Code.md §7, docs/decisoes/023 e
docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-14.md.

Confirme que o PR da costa das duas pontas foi integrado e NÃO refaça a costa.
Trabalhe na segunda fatia do item 8 do segundo playtest: as CONSTRUÇÕES, que
o kit desenha em caixas (97 chamadas a caixa() contra 18 a cone()).

Comece pela F1, que é de decisão e é sua: meça quanto da silhueta de cada prop
corre nas direções do eixo isométrico, e DECIDA COM NÚMERO quais props ganham
curva e quais são quadrados de verdade por serem obra industrial. Só depois
mexa em geometria.

É sessão de Blender: pip install "bpy==4.5.0". Lembre que prop não é artefato
byte-reprodutível — compare renders reduzidos a 16x16 e prove pela folha de
contato. Não toque na projeção, nas âncoras nem na pegada publicada. Feche com
as cinco suítes, o asset_validator, a captura antes/depois e o fechar-sessao.

Se a medição disser que o ganho não paga o custo, pare e registe a medição em
vez de arredondar por arredondar.
```
