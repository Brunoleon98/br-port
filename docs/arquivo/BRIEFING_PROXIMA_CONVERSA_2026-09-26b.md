# BR Port — prompt para a próxima conversa (a quarta passagem das mensagens)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** — a passagem tem uma escolha de cor por personagem e uma
guarda nova a desenhar (F4 e F6); o fecho desce para **Sonnet** (`CLAUDE.md`,
«Qual MODELO faz o quê»).

**Situação:** substitui o `26`. A sessão de 26/09 trabalhou na branch
`claude/jolly-archimedes-7y0a54`, a partir da `main` com o PR #90 fundido, na
**quarta família da frente 3 do A5 — as telas de texto** (`067`):

1. **O caderno foi aceite** na terceira passagem: a tela de nomes é a folha de
   rosto e o diário a primeira página, com letra à mão (Patrick Hand), couro e
   papel por shader, a folha que curva ao «Abrir o porto», a etiqueta adesiva,
   a orelha e a foto do porto antigo PROVISÓRIA. O **D37** tranca a página.
2. **As mensagens são uma conversa no celular**, com três passagens: notas do
   porto ao centro com o tom e o ícone do assunto (`message` ganhou um
   `assunto`), as três vozes em balões com a cara da fala (o sinal `falou` dos
   painéis), o app Mensagens no menu. O **F17** tranca a conversa.
3. O veredito da terceira foi **«Continue nas mensagens»**, com o fecho da
   sessão pedido no mesmo campo. **A quarta passagem é esta conversa.**

A branch tem **dois commits por fundir** (o caderno e o fecho) e **nenhum PR
aberto** — o Bruno não o pediu.

---

## 1. Comece pelo estado real

- Confira no GitHub se a `claude/jolly-archimedes-7y0a54` virou PR e se foi
  fundida. **Se não foi, o trabalho da `067` só existe nela**: a branch desta
  conversa parte dela (`git fetch origin claude/jolly-archimedes-7y0a54`, um
  ref de cada vez), e nunca de uma `main` sem ela.
- Um ref de cada vez no `git fetch`, com o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`) — aqui, o tema e o `PainelNarrativo.gd`.
- O CI só corre em PR e na `main` (`CLAUDE.md`, «Como rodar, aqui dentro»).

## 2. A quarta passagem das mensagens — o que o Bruno marcou

- **Balões por pessoa.** Cada personagem com o tom do seu balão — a Dona
  Cida, o Sr. Ribeiro, o Arlindo —, além da cara. Hoje os três vestem
  `BalaoConversa` / `BalaoConversaSeguido`. A variação de cada um é um
  **literal por ramo** (`theme_type_variation = &"..."`, nunca um dicionário),
  senão o `conferir_escopo_ui.py` não a vê (`CLAUDE.md`, «Interface»). As
  cores são uma escolha: derive-as do retrato de cada um, meça o texto contra
  cada balão pelo D33 — a amostra `historico` de `contraste_ui.gd` já traz as
  quatro vozes — e mostre a foto antes de a dar por boa.
- **Telefone maior, só nas mensagens.** O aparelho é `PainelCelular.gd`, com
  `LARGURA` 400 e `ALTURA` 680 em `const`, que uma subclasse não pode
  redeclarar; o pedido é ~460 × 780 na conversa com o **menu intocado**. O
  controle é a foto do `menu` igual em RGB à de hoje, e o «Guardar o
  telefone», por baixo do aparelho, tem de continuar dentro dos 1280.
- **O veredito** vem como de costume (`/arte`, «O veredito na conversa»):
  aceite fecha a família — e com ela a frente 3.

## 3. O que está com o Bruno

- **A foto do porto antigo**, no ChatGPT, pelo `art_lab/diario/BRIEFING.md`
  (entrega 1200 × 850); a integração troca o `const FOTO` do `TelaNomes.gd`.
- **O fundo e o logotipo da tela inicial**, pelo
  `art_lab/tela_inicial/BRIEFING.md`.
- **A leitura dos textos novos** (A4): «Nome do cais», «Este diário pertence
  a», «(pode deixar em branco)», «O nome do cais não muda depois.», «Dia N».

## 4. Lições desta sessão — onde vivem

- ⚠️ Prancha e pergunta no MESMO bloco voltaram 2 de 8 vezes; a pergunta
  sozinha, 9 de 9 — mande-a sozinha assim que ele avisar (`/arte`, «O
  veredito na conversa»).
- ⚠️ Um `Container` desfaz a rotação e a escala do filho: peça rodada vive
  num `Control` simples (`CLAUDE.md`, «Interface»).
- ⚠️ Shader só compila onde é desenhado, e as suítes headless não desenham:
  shader novo leva um tiro na bateria que o desenhe (`CLAUDE.md`,
  «Interface»; `tools/capturar_evidencia.sh`).
- ⚠️ O `ColorRect` de um shader tem cor de alfa zero, senão a régua do
  contraste lê a cor dele como fundo (`CLAUDE.md`, «Interface»;
  `brport_vs/scripts/PainelNarrativo.gd`).
- ⚠️ A prova das caras mede uma fração da caixa, e numa janela que rola só
  julga a cara que se vê inteira (`brport_vs/tools/caras_na_foto.gd`).
- ⚠️ Amostra à mão de um dicionário que a fila escreve leva TODAS as chaves:
  a do D33 sem `retrato` abortava o `setup()` a meio
  (`brport_vs/scripts/validation/contraste_ui.gd`; `067`).
