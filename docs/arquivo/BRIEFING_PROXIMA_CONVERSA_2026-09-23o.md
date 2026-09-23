# BR Port — prompt para a próxima conversa (a Dona Cida redonda: o veredito e o passo seguinte)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler o veredito do Bruno e decidir o que muda no desenho
(`CLAUDE.md`, «Qual MODELO faz o quê»: gramática de uma peça é decisão). Se ele
aprovar sem pedir mudança, a integração no estúdio e o rasto de prosa descem
para **Sonnet**.

**Situação:** a frente 2 do A5 (retratos de fala) está no Blender. Em 23/09 uma
sessão pesquisou boas práticas (§7 do `docs/design/BR_Port_Plano_Arte_Blender.md`,
com fontes e medições) e o Bruno escolheu ver **um retrato novo completo**. A
candidata é **`art_lab/retratos/cida_seria/v1/`**: a Dona Cida séria de cabeça
REDONDA, pelo mesmo estúdio dos retratos de hoje (câmera, rig, paleta e o AgX
de hoje), com metaball, olhos em esfera com brilho e pálpebra, sobrancelhas e
boca em curva, mechas para o coque, óculos redondos, lápis e gola. Fotografada
no jogo numa cópia: **muda 1 foto em 31** (o `boletim`) e só dentro da caixa do
retrato. **Nada disto está em `brport_vs/`**: o retrato do jogo continua o de
`blender/brp_porto.py`.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/peaceful-dijkstra-aosw6d`, à frente da
  `main` (`dfa8319`, o #78 fundido), e o PR dela é o **#79**. Antes de qualquer
  checkout, confira no GitHub se ele foi fundido; se não foi, a candidata e a
  pesquisa só existem na branch.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Pede o veredito do Bruno sobre a candidata, se ele ainda não o deu, e age
conforme ele.** Leia antes o `README.md` da candidata (o que aplica, as seis
tentativas, as limitações) e o §7.5 do plano de arte.

- **Se ele pedir mudanças:** refaça em `art_lab/retratos/cida_seria/v2/`, pelo
  script da v1 (`PREVIA=1` para iterar a forma: 384 px e 16 amostras), e prove
  outra vez no jogo pela mesma receita (§4).
- **Se aprovar a direção:** a pergunta seguinte é dele, e há que a fazer
  antes de modelar mais nada — **a oficina**. O `Retratos.gd` diz que os
  retratos têm de combinar com o `trabalhador_retrato` do rodapé, que é de
  caixas; o Sr. Ribeiro e o Arlindo também. Trocar só a Dona Cida deixa duas
  oficinas no mesmo painel (a foto do boletim já o mostra). Opções: os três
  personagens e o trabalhador redondos, ou só os três de fala. Depois, as
  outras duas expressões dela (preocupada, contente), com a pose da tabela
  `_CARAS`.
- **Só com o aceite na foto do jogo** a peça passa para o estúdio
  (`blender/brp_porto.py`, o código sai do script da candidata) e para
  `brport_vs/`, com a decisão escrita em `docs/decisoes/` — a próxima livre é a
  **`055`** (`art_lab/README.md` §3).

## 3. O que ficou pendente do Bruno

- **O veredito da candidata**, e a pergunta da oficina (§2).
- **AgX ou Standard** (plano de arte §7.1): o pipeline renderiza pelo AgX sem o
  declarar, e nenhum prop passa de ~190 no p99; em Standard, 231–236 sem
  estourar. Nos retratos o AgX também lava a pele clara (Sr. Ribeiro: saturação
  0,34 contra 0,44). Contorno por casco invertido (P5) também espera por ele.
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que esta sessão mediu

- ⚠️ **Nesta câmera o que avança da cara desce na imagem.** Um nariz saliente
  tapa a boca, e a distância nariz–queixo encurta: a boca leu-se como bigode
  até o queixo crescer.
- ⚠️ **A superfície do metaball sai menor do que os raios escritos** (raio
  0,95 → ±0,54). Toda feição pousa por `ray_cast` em FRAÇÃO da caixa medida, e
  o `ray_cast` é no objeto ORIGINAL com `depsgraph=`; o raio de cima passa ao
  lado da testa — recua para o meio e para trás.
- ⚠️ **`Shrinkwrap` numa curva Bézier desloca só os pontos de controlo**; e a
  receita de casco invertido dos tutoriais (`Solidify` + «Flip Normals») pinta
  a cara inteira — a que funciona está no §7.2 (P5).
- ⚠️ **Subdivision em cima do kit de caixas não arredonda** (o chanfro de
  0,020 segura a quina) e, antes do chanfro, desmancha o busto (−28,6%).
- ⚠️ **O brilho no olho pelo AgX pede força 4** (211 com força 1; mediu 234 na
  candidata). Os aros dos óculos não projetam sombra: a da chave desenhava um
  segundo aro.
- **A prova no jogo:** cópia por `git archive HEAD`, só o PNG trocado,
  `--import`, `tools/capturar_evidencia.sh` nas duas árvores, comparação em
  **RGB** (no RGBA o `getbbox()` só vê o alfa). A Dona Cida séria só aparece no
  tiro `boletim`.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11 (~1 GB,
  minutos); o hook não o instala. O EEVEE só renderiza sob `xvfb-run`.

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
