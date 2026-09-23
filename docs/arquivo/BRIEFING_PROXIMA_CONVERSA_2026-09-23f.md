# BR Port — prompt para a próxima conversa (a moldura saiu da VRAM, e o quadro ficou)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa terceira sessão, fechou a opção (b) do briefing
`23e` — **o quadro dos props** (`049`). Os 60 props de mapa importam pelo
`texture_atlas` do Godot: a moldura transparente sai da VRAM e a margem do
`AtlasTexture` repõe os 768, logo **nenhum nó, âncora, `scale` ou manifest
mudou**, e não foi preciso `bpy`. VRAM de textura em jogo **235,68 → 64,04 MB**;
`.pck` **−17,4%** (≈ −3,3% do APK). Os nove retratos de fala ficam inteiros —
o atlas arredonda a largura a potência de dois e sair-lhes-ia 26% mais caro.

⚠️ **O briefing anterior previa o caminho caro** (`bpy`, os 69 regerados,
âncora por prop) porque lia o quadro como ARQUIVO; a pergunta era o quadro na
VRAM. E o corte achou dois buracos: **um `AtlasTexture` por cima de outro não
compõe** (as folhas de contato gravaram quadros VAZIOS e disseram "Folha salva
em"), e **nenhuma folha perguntava se a peça chegou à foto** — hoje perguntam
escondendo-a. Sete mutantes, cada um pela guarda certa.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~230 bytes de folga**. O teto vive no
`TETO_ESTADO` de `tools/conferir_docs.py`. **Comprima ANTES de escrever**, e
confira rodando o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/upbeat-thompson-dvh0ei`, à frente da
  `main` (`b913697`, o PR #69 fundido), SEM PR aberto** — o PR só se abre a
  pedido. Antes de qualquer checkout, confira no GitHub se ela já foi fundida;
  se não foi, este trabalho só existe na branch, e reiniciá-la da `main`
  apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI não correu sobre este trabalho** — só corre na `main` e em
  `pull_request`. O que o substitui foi um clone limpo do commit com UM
  `--import`: zero erros e a árvore limpa depois dele (o passo das âncoras exige
  `git diff --quiet -- brport_vs/art`). Quando o PR abrir, o `brport-captura`
  vai dizer que **14 fotos mudaram** — ≤ 0,021% dos pixels, máximo 19/255,
  amostragem sub-texel nas bordas dos props. É esperado.
- **São DEZ verdes neste contêiner**: as seis suítes (`TODOS OS TESTES
  PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`, `ASSET OK`) e
  quatro conferidores (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A
  bateria tem **27 tiros** e fecha com `COBERTURA OK`. O `ASSET OK` diz agora
  também quantos props estão em atlas (60).

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **27** fotos. `camioes.png`, `props3.png` e `escolhido.png` foram-lhe enviadas em 23/09 e **não há registo de que as tenha olhado** |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`): entrada, resposta e despedida do Sr. Ribeiro, os seis tons do boletim, a derrota para o Arlindo e a vitória dele |

### (b) O âmbar da seleção — F4

Passa a 1.4.11 pela largura (7,37:1 contra a barra); a troca de estado pela cor
mede 2,26:1. Subir a cor esbarra na `035`. Não há defeito; só vale se o Bruno
quiser que a troca também se leia pela cor.

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (d) O retorno a entrar nos berços — desenho de cruzamento

Os camiões que sobem são só de passagem (`047`). Entrar obrigaria a virar à
esquerda por cima da faixa da ida: pede regra de cedência, trava de berço
ocupado (hoje o camião `i` serve a doca `i`) e guardas novas. Uma sessão
inteira, e o pedido original avisava contra trânsito e bugs.

### (e) A resposta do Sr. Ribeiro não tem foto

O tiro `ribeiro` fotografa a ENTRADA; a resposta (pagou / não pagou) e a
despedida só foram fotografadas à mão. O T13 guarda o texto; nada guarda que ele
caiba no cartão. Pequeno: um tiro a mais, e pede que a cobertura por painel
distinga TEMPOS do mesmo painel, que hoje não distingue.

### (f) NOVO — o que o atlas deixou de fora

- **Os 8 de `art/brp`** estão inteiros (bancada de teste, presos à `001`).
- **Os retratos** estão inteiros: cortá-los pediria `crop_to_region` e mexeria
  no enquadramento de interface. Pesam 20,25 dos 24,4 MB de RGBA8 dos props.
- **A VRAM medida é o monitor do motor em OpenGL, aqui**; nenhum telefone foi
  medido. Nada disto é defeito — é o que a `049` não respondeu.

---

## 3. Armadilhas que 23/09 (terceira sessão) mediu

- ⚠️ **Antes de pagar um contrato novo, pergunte se o motor já separa o que o
  arquivo junta.** O corte "mexia na origem do mundo" enquanto o quadro era o
  ARQUIVO; na VRAM não mexe.
- ⚠️ **O `get_image()` de um prop de mapa é a REGIÃO**, com o canto em (0, 0).
  Pixel de prop lê-se por `PropIso.imagem()`; recorte, por `PropIso.recorte()`.
- ⚠️ **Um `AtlasTexture` por cima de outro não compõe**: o `get_image()` dá o
  desenho, o `draw` desenha a margem. Uma guarda que perguntasse à textura
  passaria com o defeito — quem responde é a FOTO.
- ⚠️ **O monitor de VRAM conta 4/3 de `w×h×4`**, e os retratos já estão
  carregados antes de qualquer base (um autoload chega ao `Retratos.gd`).
  Sonda de UMA textura antes de publicar o número.
- ⚠️ **O importador reescreve a cor da borda de alfa < 20 em QUALQUER
  textura** (`fix_alpha_border`). Comparar textura com arquivo compara alfa em
  tudo e cor acima disso.
- ⚠️ **Prop novo** entra pelo importador por omissão, e o validador reprova-o:
  converter o `.import` para `texture_atlas` faz parte de o acrescentar.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), nem o corte do quadro (`049`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
