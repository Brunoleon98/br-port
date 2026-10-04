# 081 — O rodapé escuro, e o Construir das famílias

**04/10/2026 · primeira parte da melhoria de design** (plano v3, §7): o
pedido não dizia o que corrigir, e a conversa abriu com a pergunta do escopo.
Escolha do Bruno: **o HUD e os painéis**, entre o mapa, as telas narrativas e
o design de jogo. **Aceite do Bruno em 04/10, sobre a segunda passagem:
«Aceito»**, sem nenhum dos três ajustes oferecidos (a vaga mais apagada, o
creme da faixa, os botões do Construir em âmbar e contorno).

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A parte do jogo | **HUD e painéis** (a recomendada: o que se lê em todos os turnos, e sem Blender) |
| O que corrigir no rodapé | As quatro: **o desligado mais claro**, **os dois cartões claros**, **os trabalhadores encostados à esquerda**, **a barra da parcela que passa** |
| O que corrigir no Construir | As três: **o cabeçalho das famílias**, **o preço em dobro**, **as construídas no topo** |
| Por onde começar | **O rodapé** (a recomendada) |
| O veredito da primeira passagem | **«Ajustar»**: os cartões dos trabalhadores e as colunas vazias, e no «Outro»: *«Consegue fazer melhorias de design no geral, caso sim, veja pontos de melhoria e faça. Depois irei validar»* |
| O veredito da segunda | **«Aceito»**, e nenhum ajuste marcado |

## O que se mediu antes

A hierarquia do rodapé estava ao contrário. No pixel da captura, contra o
fundo do HUD:

| Superfície | Antes | Depois |
|---|---:|---:|
| «AVANÇAR DIA» (o primário) | 7,38:1 | 7,38:1 |
| Botão desligado («Alocar todos» sem ninguém, «Porto completo») | **12,99** | 1,19 |
| Faixa de mensagem (creme) | **16,98** | 1,19 |
| Cartão da parcela (branco) | **17,60** | 1,18 |
| Cartão do trabalhador livre / parado | **16,50** / **13,43** | 1,19 |

O olho ia primeiro ao que não se podia fazer, e o desligado usava o mesmo
`botao_off` azul-claro que serve aos painéis brancos.

## O que mudou

- **O desligado do rodapé recua** (`botao_off_barra`): o azul da pílula, uma
  linha fina e sem sombra. Variações `BotaoBarra` (Construir, Menu) e
  `BotaoPrimarioBarra` (Avançar); o `BotaoDestaque` só vive no rodapé e mudou
  no lugar. Os painéis continuam com o `botao_off`, que lá está certo.
- **A faixa e o cartão da parcela são escuros.** A faixa guarda a barra âmbar;
  os quatro tons do texto viraram para o claro (três são os da pílula, que já
  viviam neste azul; o vermelho clareou para 5,83:1). O cartão da parcela veste
  o cartão da doca (`CartaoBarra`), com a barra de trilho escuro e o banco em
  traço claro (`parcela_barra.svg`: o `parcela` é navy cheio e mediria 1,18).
- **A linha da parcela diz o valor de HOJE, e aparece onde a porta abre.** Até
  aqui ela comparava com a parcela cheia e escrevia «R$1.045.000 de
  R$530.000». A opção escolhida dizia «quitar os R$530.000», mas quitar antes
  abate juros (`019`) e o botão do painel cobra o valor de hoje: a linha diz
  «Dá para quitar hoje por R$…», o mesmo número da tarja do painel, e o limiar
  passou do cheio para o valor de hoje — entre os dois a porta já abria e o
  cartão dizia «faltam».
- **Os trabalhadores ocupam as colunas das docas**, com a largura derivada da
  barra das docas. A coluna sem trabalhador mostra a **vaga** (`Vaga.tscn`, a
  roupa da doca em obra: «chega com o píer»), numa fila POR TRÁS, para quem
  percorre os filhos do `Trabalhadores` continuar a achar só trabalhadores.
- **O cartão do trabalhador é escuro, em duas colunas** (segunda passagem): o
  retrato numa placa clara à esquerda, a cobrir a altura (o PNG é quadrado e
  o desenho só ocupa 500 de 768 px: o busto foi de ~69 para ~110 px), o número
  e o estado à direita. O estado fala pela borda, pela cor do rótulo e, no
  escolhido, pelo selo — que passou ao âmbar de marca com letra navy, porque o
  escurecido media 2,92:1 contra o cartão escuro.
- **O Construir veste as famílias**: cabeçalho com selo, a tarja com o
  dinheiro e o nível do porto na linha de apoio, uma linha por estrutura com o
  botão compacto à direita (o preço só lá; quem ainda não pode vê o preço no
  lugar do botão), as construídas no fim, e a caixa a medir o conteúdo — ela
  declarava 560 e pedia ~870.
- **E, sem pergunta, como o Bruno pediu:** o «—» saiu das docas sem barco (a
  regra da linha com valor zero).

## As guardas, e os defeitos que as provam

- **D43** (nova): os trabalhadores nas colunas das docas, com UM e com TRÊS; e
  nada do rodapé que não seja o primário — os quatro desligados, a faixa, a
  parcela, os cinco estados do trabalhador e a vaga — passa os 7,37:1 dele.
- **D12** reescrito: o convite diz o valor de hoje, e o limiar é o da porta
  NOS DOIS LADOS (um real abaixo fecha os dois; o valor exato abre os dois).
- **D32**: o defeito que a régua tem de reprovar passou a ser o `RotuloApoio`,
  que o contador vestia sobre o creme (2,71:1 no azul).
- **D41**: o cartão mostra o mesmo dinheiro que a pílula, ou o convite — e
  vira no mesmo passo em que a pílula passa o limiar.
- **D19**: mede cada rótulo contra o fundo DELE pela régua do D33 (o branco
  suposto reprovaria o título no cabeçalho navy), com o controle positivo; e
  nenhum texto de uma linha desenha mais largo do que o sítio dele.

| Defeito injetado | Quem reprovou |
|---|---|
| Sem a largura da coluna | D43, com um e com três |
| Colunas pelo número de trabalhadores | D43, só com UM (com três dá o mesmo) |
| `BotaoBarra` de volta ao `botao_off` | D43 (13,00:1) |
| Limiar de volta à parcela cheia | D12 (o valor exato) e D41 |
| O convite com o valor cheio | D12 e D41 |
| O contador de volta ao `RotuloApoio` | D32 (2,71:1) |
| `CartaoBarra` de volta ao cartão branco | D12, D33 e D43 |
| «Construída» com a quebra automática | D19 (pede 64 px, tem 1) |
| O cartão livre de volta ao menta | D33, D34 e D43 |
| O selo de volta ao âmbar escurecido | D33 e D34 |

## O que se achou pelo caminho

- **Um `Label` com quebra automática ao lado de quem expande fica com largura
  quase zero**, e uma palavra só desenha-se por cima do vizinho. Mordeu duas
  vezes na mesma sessão: o selo «Escolhido» saiu como uma lasca, e o
  «Construída» atravessou a borda do cartão. Ambos passaram as suítes; quem os
  viu foi a captura (`CLAUDE.md`, «Interface»).
- **A folha dos trinta rostos media o primeiro cartão** e punha os outros na
  grelha dele: com o número ao lado do retrato, «#10» a «#30» são mais largos
  e sobrepunham-se, sem erro. Hoje mede o maior.
- ⚠️ **A cobertura do `teste_design` depende do save que a ferramenta
  anterior deixou em `user://ferramentas/`.** O `_main` da suíte herda-o, e o
  D14 conferiu 179 casas contra prédios com o porto completo no disco e 77
  com o porto em ruínas (o D31, 109 contra 94) — verde nas duas. É anterior a
  esta sessão e não se corrigiu aqui: a correção é a suíte montar o estado que
  quer, como o `capturar_tela.gd` faz (`CLAUDE.md`, regra 6).

## O que não se fez

- **A faixa continua sem o creme do balão da Dona Cida**: foi oferecido como
  defeito e o Bruno não o marcou.
- Os painéis das famílias de 25/09 não se reabriram: foram aceites.
- Os três ajustes oferecidos no veredito final, que ele não marcou: a vaga
  mais apagada, o creme da faixa quando fala a Dona Cida, e os botões do
  Construir em âmbar para quem cabe no dinheiro.
