# Tela inicial — briefing da ilustração

**Peças:** duas, da mesma leva (escolha do Bruno em 26/09, na segunda
passagem):

1. **o fundo** da tela inicial, que é também o papel de parede do celular do
   jogo (a mesma imagem nos dois usos);
2. **o logotipo** «BR Port», que substitui o nome escrito em texto.

**Técnica:** gerador de imagem, escolha do Bruno (`docs/decisoes/066`). É arte
de PAINEL e não prop no mapa, que é a linha que o `CLAUDE.md` traça para o
gerador.
**Quem produz:** o Bruno, com o ChatGPT. **Quem integra:** o Claude Code, pela
§3 do `art_lab/README.md`.
**Base:** a `main` com o PR da `066` fundido.

---

## O fundo: o que a imagem é

**Um navio chegando a um porto, com uma paisagem brasileira de fundo** — o
pedido do Bruno na segunda passagem. O navio (um cargueiro pequeno, casco
escuro e superestrutura clara) entra pelo mar em direção ao cais; o porto é
pequeno: cais de concreto, um guindaste de pórtico, alguns contêineres, a
vila de casas coloniais atrás; e por trás de tudo a **paisagem**: morros
verdes de mata atlântica, coqueiros na orla, a praia de areia clara. Luz de
**entardecer**, com a água em primeiro plano. É a abertura de um jogo de gestão
tranquilo (`docs/decisoes/005`): a sensação é de **um porto pequeno para
levantar**, e não de um terminal gigante nem de uma ruína.

O jogo é **isométrico e de cores chapadas com volume suave** (ver qualquer
foto da bateria, ex. `porto.png`), e a ilustração pode ser mais pictórica do
que ele — é uma pintura de abertura, e não uma captura. O que ela não pode é
**contradizer** o mundo do jogo:

- litoral **brasileiro** (Porto Mirim é a cidade, Cais Mirim o nome-padrão do
  porto); areia clara, água turquesa perto da costa e azul-escura ao largo;
- telhados de **telha de barro** (vermelho-alaranjado), paredes claras, rua de
  asfalto;
- guindaste **laranja** (a cor de acento do jogo) sobre um cais de concreto;
- a paleta da interface é **navy** (`#0d1a26`, `#1c3454`) e **âmbar**
  (`#e09a10`, `#f5b93a`) — o céu do entardecer pode viver nela.

## As medidas, e de onde saem

A tela do jogo tem **720 × 1280** de coordenadas (9:16), e o jogo desenha na
resolução nativa do aparelho — num telefone de 1080 de largura, cada unidade
são 1,5 pixel. Logo:

- **Entrega: 1080 × 1920 px (9:16), PNG, sem transparência.** Maior serve
  (1440 × 2560), desde que seja 9:16.
- A imagem **não é cortada** nos lados: o projeto tem `stretch/aspect="keep"`,
  e num telefone mais alto sobram faixas navy em cima e em baixo, fora da
  imagem.

Por cima dela o jogo põe duas coisas, medidas na foto da tela montada
(`inicial.png`, coordenadas de 720 × 1280; na entrega, × 1,5):

| Faixa (y em 720 × 1280) | O que o jogo põe lá | O que a imagem deve ter |
|---|---|---|
| 0 – 280 | nada | céu; pode ser só degradê |
| **280 – 420** | o nome **«BR Port»**, branco com contorno navy, centrado | **céu calmo, sem detalhe forte** — o nome tem de ler |
| 420 – 860 | nada | **o assunto**: horizonte, cais, guindaste, navio, vila |
| **860 – 1190** | o **cartão branco** dos botões (560 de largura, centrado) | pode ser água/primeiro plano: fica tapado |
| 1190 – 1280 | nada | água |

E o segundo uso: no **celular** do jogo a imagem vai de papel de parede, num
visor de ~350 × 560 (a proporção é outra, ~1:1,6). O corte vai ser o **miolo**
da imagem — o assunto entre y 420 e 860 tem de sobreviver a ser recortado a
meio da largura.

## O que NÃO pôr no fundo

- **Texto nenhum** — nem o nome do jogo, nem placas, nem letreiros. O nome é
  a segunda peça, à parte (abaixo), e é o jogo que o põe por cima.
- Interface nenhuma (botões, molduras, logótipos).
- Pessoas em destaque: o jogo tem retratos próprios, feitos no Blender, e uma
  cara pintada aqui seria uma quarta linguagem de personagem.

## O logotipo

- **«BR Port»**, e mais nada — confira as letras antes de entregar: gerador de
  imagem erra letra, e um logotipo com uma letra trocada é refazer.
- **PNG com transparência** (fundo transparente de verdade, sem o xadrez
  pintado nos pixels — dois lotes de arte já chegaram assim, e o
  `tools/conferir_lote_de_arte.py` mede o alfa).
- Largura de **~900 px** e altura livre (proporção horizontal): no jogo ocupa
  a faixa **280 – 420** da tela (× 1,5 na entrega), centrado, até ~600 de
  largura.
- Tem de ler sobre o CÉU do fundo: contorno ou sombra escura à volta das
  letras, como o nome em texto de hoje (branco com contorno navy).
- Cabe um desenho do mundo do porto junto das letras — âncora, guindaste,
  onda —, na linguagem da ilustração.

## Os pedidos, prontos para colar

**Fundo:**

> Ilustração vertical 9:16 (1080 × 1920 px), para a tela de abertura de um
> jogo de celular de gestão de porto no litoral brasileiro. Um cargueiro
> pequeno, de casco escuro, chega pelo mar a um porto pequeno: cais de
> concreto, um guindaste de pórtico laranja, alguns contêineres, casas
> coloniais de telhado de barro atrás. Ao fundo, morros verdes de mata
> atlântica, coqueiros e uma praia de areia clara. Entardecer, céu do azul
> escuro ao dourado no horizonte, água turquesa perto da costa. Estilo de
> pintura limpa, cores quentes, clima tranquilo. O terço de cima é só céu
> calmo (vai ter um logotipo por cima); o assunto fica no meio da imagem; o
> terço de baixo pode ser só mar (fica tapado por botões). Sem texto, sem
> letreiros, sem pessoas em destaque, sem interface.

**Logotipo:**

> Logotipo do jogo «BR Port», em PNG com fundo transparente, horizontal,
> ~900 px de largura. Letras brancas grossas com contorno azul-marinho
> escuro, legíveis sobre um céu de entardecer, com um detalhe do mundo do
> porto (uma âncora, um guindaste ou uma onda) integrado às letras. Só o
> texto «BR Port», escrito exatamente assim.

## Como entregar, e o que acontece depois

1. Pôr os dois PNG (e a conversa ou o prompt que os produziu, se der) numa
   pasta `art_lab/tela_inicial/v1/` — pelo GitHub web numa branch, ou num zip
   que o Claude Code põe lá, com um `README.md` a dizer de onde vieram.
2. O Claude Code troca o `const FUNDO` em `brport_vs/scripts/TelaInicial.gd`
   e põe o logotipo no lugar do nome em texto (o D33 já declara o nome sobre
   a ilustração como coisa que se confere no pixel da foto, e não pela régua
   de contraste), importa, e fotografa a tela
   inicial e os seus painéis (`tools/capturar_evidencia.sh`), com a de hoje
   ao lado.
3. O Bruno aceita **na foto do jogo**, não na imagem solta.
4. Com o aceite, o papel de parede do celular passa a usá-la (terceira
   passagem da família do sistema).

Até lá o jogo mostra `brport_vs/art/tela_inicial/fundo_provisorio.svg`: céu,
horizonte e mar em degradê, sem desenho nenhum — um fundo que não finge ser a
arte.
