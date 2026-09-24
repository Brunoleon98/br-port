# BR Port — prompt para a próxima conversa (a Dona Cida v2: o veredito e o passo seguinte)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler o veredito do Bruno e decidir o que muda no desenho
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). Se ele
aprovar sem pedir mudança, a integração no estúdio e o rasto de prosa descem
para **Sonnet**.

**Situação:** a frente 2 do A5 (retratos de fala) está no Blender. O Bruno
**rejeitou a v1** da Dona Cida séria de cabeça redonda, marcou os quatro
defeitos que a leitura apontava — nariz e boca (bigode), tronco (balão), gola
(dois discos), cabelo (capacete com espetos) e lápis (a flutuar) — e pediu
para **«melhorar o modelo como um todo»**. A candidata é agora a **v2**, em
**`art_lab/retratos/cida_seria/v2/`**: o mesmo estúdio, a mesma câmera, a
mesma paleta e o mesmo AgX, com a geometria refeita — nariz à parte sem
sombra, boca fina, tronco por anéis com ombro, gola de pontas com pé e
botões, cabelo em casca colada ao crânio com sulcos até ao coque, lápis por
cima da orelha, óculos com hastes. Fotografada no jogo numa cópia: **muda 1
foto em 31** (o `boletim`) e só dentro da caixa do retrato. **Nada disto está
em `brport_vs/`**: o retrato do jogo continua o de `blender/brp_porto.py`.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/elegant-rubin-qx6ygf`, à frente da `main`
  (`d9ab39e`, o #79 fundido). Nenhum PR foi aberto. Antes de qualquer
  checkout, confira no GitHub se ela foi fundida; se não foi, a v2 só existe
  nela.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Pede o veredito do Bruno sobre a v2, se ele ainda não o deu, e age conforme
ele.** Leia antes o `README.md` da v2 (o que muda contra a v1, as oito
tentativas, as limitações) e o fim do §7.5 do plano de arte. Mostre-lhe a
`prancha_hoje_v1_v2.png` e a `jogo_boletim_hoje_vs_v2.png`.

⚠️ **Pergunte com opções, e confira a resposta antes de agir.** Na conversa
da v2 a primeira resposta dele veio contraditória (rejeitar a cabeça redonda,
mas marcar os defeitos e deixar a oficina «para depois da v2»); a pergunta
seguinte, sobre a técnica, voltou com texto livre — «melhore o modelo como um
todo». Leu-se como refazer a redonda, e isso foi dito antes de modelar.

- **Se ele pedir mudanças:** refaça em `art_lab/retratos/cida_seria/v3/`,
  pelo script da v2 (`PREVIA=1` para iterar a forma: 384 px e 16 amostras), e
  prove outra vez no jogo pela mesma receita (§4).
- **Se aprovar a direção:** a pergunta seguinte é a da **oficina**, que ele
  deixou para depois da v2, e há que a fazer antes de modelar mais nada. O
  `Retratos.gd` diz que os retratos têm de combinar com o
  `trabalhador_retrato` do rodapé, que é de caixas; o Sr. Ribeiro e o Arlindo
  também. Opções: os três de fala e o trabalhador redondos, ou só os três de
  fala. Depois, as outras duas expressões dela (preocupada, contente), com a
  pose da tabela `_CARAS`.
- **Só com o aceite na foto do jogo** a peça passa para o estúdio
  (`blender/brp_porto.py`, o código sai do script da candidata) e para
  `brport_vs/`, com a decisão escrita em `docs/decisoes/` — a próxima livre é a
  **`055`** (`art_lab/README.md` §3).

## 3. O que ficou pendente do Bruno

- **O veredito da v2**, e a pergunta da oficina (§2).
- **AgX ou Standard** (plano de arte §7.1): o pipeline renderiza pelo AgX sem o
  declarar. Na v2 a gola sai **acinzentada** por isso (`#eef2f5` → ~191), e o
  AgX lava a pele clara (Sr. Ribeiro: saturação 0,34 contra 0,44). Contorno
  por casco invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

As da v1 continuam a valer (o que avança da cara desce na imagem; a superfície
do metaball sai menor do que os raios; `ray_cast` no objeto ORIGINAL com
`depsgraph=`; o brilho no olho pede força 4 pelo AgX). As novas:

- ⚠️ **Casca cortada apagando vértices sai SERRILHADA.** A linha do cabelo
  faz-se com a casca a ENTRAR na pele numa faixa estreita.
- ⚠️ **Peça que sombreia outra sai da malha e deixa de projetar sombra** — o
  nariz, como os aros dos óculos.
- ⚠️ **Tronco com ombro sai de anéis de superelipse**, não de elipsoides
  fundidos; e retalho pousado por raio estica-se onde a superfície fica a
  pique (a gola que subia pelo pescoço).
- ⚠️ **Pousar pela tangente só serve num casco convexo** (o lápis atravessou
  a orelha), e **posição de feição mede-se na IMAGEM** (a sobrancelha «reta»
  saiu zangada; a boca a 0,42 saiu a dois terços do caminho).
- ⚠️ **O enquadramento mede a cabeça COM o coque**: coque no alto encolhe a
  cara na caixa.
- **A prova no jogo:** DUAS cópias por `git archive HEAD`, só o PNG trocado
  numa, `--import` nas duas, `tools/capturar_evidencia.sh` nas duas,
  comparação em **RGB**. ⚠️ Correndo as duas baterias em paralelo num
  `a && b && (x) & (y) & wait`, as variáveis do `&&` não chegam ao `(y)`: a
  segunda bateria saiu para `/` e falhou. Uma linha por bateria.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11 (~1 GB, uns
  minutos); o hook não o instala. As pranchas pedem `pillow` no Python do
  sistema.

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `054`, o R1–R9 nem as levas de cor.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O veredito do Bruno e o que se fez com ele. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O CI não roda
ao empurrar a branch; o PR só se abre a pedido.
