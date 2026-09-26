# 067 — A família das telas de texto: o caderno e a conversa

**26/09/2026 · quarta e última família da frente 3 do A5**: as telas de
texto — o diário, as mensagens e a tela de nomes. O Bruno escolheu-a entre as
frentes que restavam («Resto da frente 3») e respondeu o escopo antes do
desenho. **Vereditos: o caderno aceite na terceira passagem («Aceito, siga
para mensagens»); a conversa com três passagens e «Continue nas
mensagens»** — a quarta fica para a conversa seguinte, com o fecho pedido por
ele (fim deste arquivo).

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A cara do diário (serve também ao app Diário do celular) | **Caderno, letra à mão** |
| As imagens do porto de antigamente | **Gerador, pelo `art_lab/`** — o briefing é `art_lab/diario/BRIEFING.md` |
| As mensagens («O que já foi dito») | **Conversa no celular** |
| A tela de nomes | **Folha de rosto do diário**: ao tocar em «Abrir o porto» a página vira para a primeira entrada |
| A textura do couro e do papel (3.ª passagem) | **Procedural**, por shader no Godot |
| A virada | **A folha que curva** |
| A etiqueta dos nomes | **Etiqueta adesiva** |
| O que mais faria o caderno real | **canto dobrado, tinta com variação, lombada com relevo** (a mesa por trás não) |

## O caderno — três passagens, aceite

**As duas telas passaram a ser UMA peça**: a tela de nomes é a folha de rosto
e o diário a primeira página. O andaime (`PainelNarrativo`) ganhou o caderno
— `montar_caderno()`, `pagina_do_caderno()`, `entrada_do_diario()`,
`campo_a_mao()`, `etiqueta_da_folha()`, `foto_colada()` —, e o desenho vive em
`FolhaDoCaderno.gd`: capa, lombada, pauta, fita, orelha e sombras, com as
cores todas no tema (variações `Caderno*` e `TextoCaderno`).

- **A letra à mão é a Patrick Hand** (OFL, 210 KB, `ui/fontes/`), a **22 px
  com entrelinha 0**: a 24 o diário não cabia na folha com um nome de cais
  comprido. A pauta alinha-se à LINHA DE BASE do texto (passo = altura da
  letra + entrelinha), e a data da entrada vai sublinhada à mão.
- **A sugestão do campo é letra IMPRESSA** («Cais Mirim», «(pode deixar em
  branco)»): na letra à mão, só mais clara, lia-se como já preenchido.
- **A foto do porto antigo é PROVISÓRIA** (`art/diario/foto_provisoria.svg`,
  céu e mar em sépia, sem porto): a verdadeira é do Bruno, no ChatGPT, e
  troca o `const FOTO` do `TelaNomes.gd`. Mede 500 × 354 na folha, colada a
  −2,5° com cantoneiras.
- **A etiqueta** é um autocolante creme com filete azul, cantos redondos e
  −1,2° de giro; o filete duplo da 2.ª passagem lia-se como formulário.
- **Couro, papel e tinta são shaders** (`ui/shaders/`, com o ruído partilhado
  em `ruido.gdshaderinc`): o grão do couro na faixa da capa, a fibra do papel
  (força 0,07, que não mexe no contraste da tinta) e a tinta a variar entre
  0,85 e 1,12 do tom. A tinta **não** vai nos campos: sobre o `LineEdit`
  manchava o fundo do campo.
- **A folha curva**: no toque, a folha de rosto é fotografada da janela e
  desenhada por um shader de cilindro (`folha_virando.gdshader`), com o verso
  a levantar e a sombra na página de baixo — onde a entrada já está escrita.
  Sem imagem (headless) cai na virada plana, que é o que as suítes exercem.

⚠️ **E UM CONTENTOR DESFAZ O GIRO.** A foto e a etiqueta nasceram rodadas
dentro de um `VBoxContainer`, e saíram direitas: o contentor reescreve a
`rotation` e a `scale` de cada filho ao arrumá-lo. As duas vivem num
`Control` simples que o contentor arruma, e é a peça de dentro que roda.

⚠️ **E SHADER SÓ COMPILA ONDE É USADO — as suítes headless nunca o
compilam.** O primeiro `folha_virando` redefinia `PI`, que a linguagem já
tem, e as seis suítes passaram: nenhuma desenha. Quem o apanhou foi a
captura (`SHADER ERROR` com backtrace). A bateria ganhou o tiro
`nomes_virando` — a folha a meio da curva —, que é a única prova de que o
shader compila e desenha.

⚠️ **E O `ColorRect` DO SHADER TEM COR DE ALFA ZERO.** A régua do contraste lê
um `ColorRect` irmão por trás do texto como o fundo dele: com a cor de
omissão (branco) o papel mediria-se como branco e não como creme.

**D37** tranca a página: o vão entre a data e o texto é a entrelinha da letra
(senão a pauta desalinha a partir da segunda linha) e o diário com o nome de
cais mais comprido cabe na folha (pede 750 px, cabe 804).

## A conversa — três passagens

**O histórico da faixa passou a ser uma conversa num celular**
(`PainelMensagens`, irmão do menu): o aparelho saiu do `PainelMenu` para
`PainelCelular.gd` — a mudança, sozinha, deu a foto do menu idêntica byte
a byte —, e a
conversa vai do mais antigo ao mais recente, com o separador de cada dia, as
falas em BALÕES com a cara de quem fala e os avisos do porto em NOTAS ao
centro, com a cor do tom e o ícone do assunto. O app **Mensagens** entrou no
menu, o segundo da grelha.

- **Cada aviso diz o seu assunto.** O sinal passou a
  `message(texto, tom, assunto)`, e os 15 `emit` do `GameState` dizem-no
  (`porto`, `doca`, `trabalhador`, `rival`, `cliente`, `negocio`, `semana`,
  `dinheiro`, `obra`); o `PainelMensagens` tem um ícone por assunto. O ícone
  do negócio fechado passou ao barco: o disco âmbar com «=» lia-se como moeda.
- **As três vozes falam na conversa** (3.ª passagem). O Sr. Ribeiro, o
  Arlindo e o boletim da Dona Cida emitem `falou(personagem, texto, retrato)`,
  o `Main` liga-o no `_abrir_painel()`, e a fila **regista** a fala no
  histórico sem a pôr na faixa — que já tem o painel à frente.
- **A cara é a da fala.** Cada entrada guarda o retrato com que foi dita (a
  Dona Cida contente, a séria, a preocupada), e sem ele a cara de omissão da
  pessoa. O avatar (44 px, 36 no grupo do cabeçalho) é **a cabeça recortada e
  reduzida com Lanczos** (`Retratos.cabeca()`), num disco por shader: o
  retrato de 768 px encolhido à bruta saía serrilhado, e o disco por
  `clip_children` mostrava a cara POR TRÁS dele.
- **O histórico vive na sessão**, em memória, como antes: nada foi para o
  save e o `SAVE_VERSION` não se mexeu.

⚠️ **E A PROVA DAS CARAS NÃO CONHECIA CARA PEQUENA NEM CARA ROLADA.** O
avatar vazio (o quadro de 768 encolhido num disco de 34 px) mudava 38 px ao
ser escondido, e o mínimo era 4.695 px fixos: nenhum desenho de 34 × 34 lá
chega. O corte passou a ser a MESMA fração da caixa (4.695 / 112 × 152), que
deixa as nove caras de painel medidas como eram. E a conversa rola: um balão
lá em cima tem a cara fora da janela, e a prova reprovava-a com razão (0 px).
Hoje só se julga a cara que a janela mostra INTEIRA, e as cortadas contam-se
numa linha à parte (`caras_na_foto.gd`).

**F17 do `teste_fumaca`**: todo `message.emit` do `GameState` diz um assunto
com ícone, e todo ícone tem quem o emita — lido o arquivo inteiro, com a
contagem de chamadas VISTAS igual à de LIDAS (a regra das duas contas); os
três painéis que falam, abertos pela porta do `Main`, deixam a fala no
histórico com a cara dela; e gravar as falas não mexe na faixa. **O D33**
mede a conversa com os quatro tons e as quatro vozes.

**Sete defeitos injetados, sete reprovações pela guarda certa**, com o
original guardado por `cp` e a base verde entre eles: o `Main` sem ligar o
`falou` (F17, três linhas), um assunto sem ícone (F17), o Sr. Ribeiro calado
(F17), um `emit` com um assunto que não existe (F17, nos dois sentidos), a
entrelinha a divergir da pauta (D37, e o nome comprido deixa de caber), o
avatar transparente (a prova das caras, 0 px nos três do cabeçalho) e a prova
sem a janela da rolagem (reprova as duas caras cortadas).

**E uma guarda caiu na própria armadilha dela.** A amostra do D33 não tinha
a chave `retrato`, que o `setup()` lê por acesso direto: ele abortava a meio
com um `SCRIPT ERROR` e a régua publicava o que chegara a montar. A amostra
tem hoje todas as chaves que a fila escreve, e mede as quatro vozes.

## Medido

- Seis suítes verdes, `ESCOPO UI OK`, `COBERTURA OK` (17 painéis, 10 tempos,
  9 caras); contraste **443 textos em 29 estados**, nenhum abaixo do AA.
- A bateria tem 42 fotos, **uma nova** (`nomes_virando`). Contra a `main`,
  em RGB, mudaram **5** — `nomes`, `diario`, `mensagens`, `menu` (o app novo)
  e a folha de ícones — e as outras **36 são iguais pixel a pixel**: o boletim,
  a parcela e a contra-oferta passaram a emitir a fala sem mudar um pixel. O
  mesmo arquivo dos dois lados deu zero exato.

## O que ficou de fora

- **A foto do porto antigo** — do Bruno, pelo `art_lab/diario/BRIEFING.md`.
- **A hora em cada mensagem**: o jogo não tem hora do dia, só o dia, e o
  separador já o diz.
- **Caras no lugar dos ícones** nas notas e **a fala longa do Sr. Ribeiro em
  dois balões** — oferecidas, não escolhidas.
- **A leitura dos textos novos** (A4): «Nome do cais», «Este diário pertence
  a», «(pode deixar em branco)», «O nome do cais não muda depois.», «Dia N».
- **O app Diário** do celular continua fechado: o caderno está pronto para
  ele, com uma entrada por página e uma foto por entrada.

## A quarta passagem da conversa, na próxima conversa

**Veredito do Bruno sobre a terceira: «Continue nas mensagens»**, com dois
reparos marcados — e o fecho da sessão pedido no mesmo campo («Feche a
sessão e continue na próxima»):

- **Balões por pessoa**: cada personagem com o tom do seu balão (o Arlindo,
  o Sr. Ribeiro), além da cara.
- **Telefone maior**: o celular (400 × 680) é apertado para ler a conversa;
  ~460 × 780, **só nas mensagens** — o menu fica como está.
