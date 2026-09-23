# 050 — A troca pela cor mora no selo, e a borda fica

**23/09/2026 · opção (b) do briefing `23f`, escolha do Bruno:** que a troca
«livre → escolhido» do cartão do trabalhador também se leia pela COR. A `045`
deixou-a medida — 2,26:1, abaixo do 3:1 da WCAG 1.4.11 — e sem defeito: quem
separava os dois estados era a largura da borda, 2px → 4px.

## O que se decidiu

1. **A borda fica como está** — o âmbar de marca, 4px, 7,37:1 contra a barra.
2. **O rótulo "Escolhido" ganha um SELO:** a variação `SeloEscolhido`, texto
   branco sobre o sub-recurso `selo_escolhido`, preenchido com o âmbar
   escurecido do `RotuloAlerta` (`035`). É o canal da cor da seleção.
3. **O fundo do cartão continua o do livre** — é nele que o retrato vive.
4. **O `Worker.gd` tira o selo em todo `refresh()`** e só o ramo da seleção o
   põe de volta: o rótulo guarda a variação entre chamadas.
5. **A régua do contraste lê o fundo de um `Label`**, e o percurso do D33
   ganhou o estado «HUD (trabalhador escolhido)» — **25 estados, 353 textos**.
6. **O tiro `escolhido` da bateria passou ao turno 2**, onde a doca tem barco à
   espera.

## ⚠️ O que a medição disse antes de se escolher

### Nenhuma cor de borda resolvia isto — é conta

O briefing dizia que *"subir a cor esbarra na `035`"*. O obstáculo é outro, e
anterior: a borda fica ENTRE dois vizinhos — o verde que ela substitui por
fora (luminância 0,145) e o fundo claro por dentro (0,933), que estão a
**5,05:1** um do outro. Um tom só passa 3:1 contra os dois se eles estiverem a
**9:1**; abaixo disso o melhor possível é a raiz da razão, **2,25**. O âmbar
media 2,26 por fora e 2,24 por dentro: **já estava no ótimo.** Subi-lo ganha
de um lado o que perde do outro.

### A troca que o jogador vê é PARADO → ESCOLHIDO

Só se aloca com barco à espera (`doca_aceita_trabalhador()`), e trabalhador
livre com doca à espera é, por definição, `TrabParado`. O cartão LIVRE só é
escolhido quando não há nada a fazer com ele — tocar numa doca dá "Doca
vazia". Nos mesmos pixels, a troca que interessa media:

| canal | livre → escolhido | **parado → escolhido** |
|---|---:|---:|
| anel de fora da borda | 2,26 | **1,33** (laranja → âmbar, 7° de matiz) |
| anel de dentro | 2,24 | 1,82 |
| fundo do cartão | 1,00 | 1,23 |

A `045` comparou com o livre por ser o fundo que a variação VESTE, e para o
cartão está certo; para a TROCA é a pergunta errada. E a foto `escolhido.png`
mostrava justamente a seleção inútil: no turno 1 a doca dizia "aguardando
barco".

### A massa não podia ir para o cartão inteiro

Um fundo escuro o bastante para dar 3:1 a partir do creme do parado engole o
retrato, que tem luminância mediana **0,149**:

| candidato | parado → escolhido | retrato (mediana) | o que se viu |
|---|---:|---:|---|
| hoje | 1,23–1,82 | 4,94 | a troca lê-se por matiz e largura |
| borda em âmbar escuro | 3,86 (anel de dentro) | 4,94 | moldura baça, 3,48 contra a barra |
| cartão navy + texto claro | 9,60 | 2,80 | igual ao cartão da DOCA, logo acima |
| cartão âmbar escuro | 3,86 | **1,33** | o retrato some no cartão que se tocou |
| **selo na linha do estado** | **3,86** | **4,94** | escolhido |

O âmbar escuro mede 0,158 — a mesma luminância do retrato. Na linha do estado
a mudança não passa por ele.

## A medição, depois

| | antes | depois |
|---|---:|---:|
| troca parado → escolhido, no MELHOR canal | 1,82 (anel de dentro) | **3,85** no selo (captura) / 3,86 (tema) |
| troca livre → escolhido, idem | 2,26 (anel de fora) | **4,74** no selo |
| "Escolhido" | navy sobre menta | **branco sobre o selo, 5,06** (5,04 na captura) |
| borda contra a barra | 7,37 | 7,37 |
| retrato | caixa (59, 874)–(76, 915), 540 px | **a mesma**: o toque não o faz saltar |
| D33 | 330 textos, 24 estados | **353, 25**, zero reprovações |

O selo são 1.192 px de tinta chapada, 92 × 17, **1,2× a área de um perímetro
de 2px do cartão** — a medida que a 2.4.13 pede a um indicador de estado.
Branco e âmbar escuro são o MESMO par que o `RotuloAlerta` mede sobre o cartão
branco, invertido. Branco puro, e não o (0,941/0,965/1) do HUD, que daria 4,66
— colado ao corte de 4,5.

## A régua não lia o fundo de um rótulo

O `fundo_de()` subia pelos `Button`, `LineEdit` e painéis, e nenhum `Label` do
jogo tinha fundo próprio. Sem o ramo novo, o branco do selo media-se contra o
menta por trás dele: **1,07:1**, uma reprovação de algo que se lê a 5,06. Só o
`StyleBoxFlat` entra; o `Empty`, que é o de todo rótulo, fica de fora. As 330
linhas de antes saíram **idênticas**.

## As fotos

A bateria (27 tiros, `COBERTURA OK`) contra a da `main`: **26 idênticas pixel
a pixel**; muda a `escolhido.png` — turno 2 e o selo. ⚠️ **E o zero tem
controle positivo:** pintar de vermelho o reset do rótulo mexe **12 das 27**
fotos, logo a bateria vê o rótulo do estado em doze, e nelas o reset não mudou
um pixel.

## Os mutantes

Cada um sozinho, originais por `cp`, base verde entre cada, código de saída
lido sem cano.

| # | defeito | o que reprovou |
|---|---|---|
| N1 | o toque não põe o selo | **só** o D34, pela proveniência. O D33 passa: navy sobre menta mede 11,79 |
| N2 | o `refresh()` sem o reset | 1ª versão: **PASSOU**. Hoje **só** o D34, no segundo toque — ver abaixo |
| N3 | selo claro (âmbar de marca) com texto preto | **só** o D34, a 1,82 e 2,24. O D33 passa (8,8:1) — o corte de 3:1 não está implícito nele |
| N4 | a régua sem o ramo do `Label` | o D33, a 1,07:1: **falha fechada**, reprova o certo e nunca aprova o errado |
| N5 | selo com margem vertical | **só** o D34: o rótulo vai de 17 a 23 px e o retrato saltaria |
| N6 | o toque não seleciona | o D33 pela prova do caso («não vestiu `TrabSelecionado`») e o D34 |
| N6b | o mesmo, sem a prova do caso | o D33 fica **VERDE**, 353 medidos — a publicar o cartão PARADO sob o nome «escolhido». A suíte segura pelo D34; a tabela da régua, só a prova |
| N7 | o texto do selo em navy | **só** o D33, a 2,49 |
| N8 | o estado novo sai do percurso | **só** o piso do D33, agora 25 |

⚠️ **O N2 PASSOU NA PRIMEIRA VERSÃO, e a guarda estava no nó errado.** Ela
perguntava se o rótulo do trabalhador ALOCADO largava o selo — e alocar passa
pelo `_refresh_workers()`, que RECRIA os cartões: o nó novo nunca teve selo,
com reset ou sem ele. O único caminho em que o MESMO cartão sai da seleção é o
segundo toque, para desistir; é lá que a guarda vive, e a da alocação saiu.
**Quem prova que um nó larga um estado prova-o no mesmo nó.**

## O que fica de fora

- **A borda.** Continua a falar pela largura e pelo matiz; a cor da troca é do
  selo.
- **Daltonismo simulado**: a régua é a luminância da WCAG, que é o que separa
  laranja de âmbar para quem não distingue vermelho de verde. Não se simulou
  visão nenhuma.
- **Nenhum telefone foi olhado.** A `escolhido.png` nova vai ao A5.
