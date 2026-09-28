# BR Port — prompt para a próxima conversa (depois da frota)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus no começo.** A conversa abre por uma escolha do Bruno (que
família da frente 4, ou que item da fila) e pelo escopo dela. A receita que
vier depois desce para **Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o de 28/09 (sem letra). A sessão de 28/09 trabalhou na
branch `claude/pensive-hypatia-1cdznc`, a partir da `main` com o PR #96
fundido, e **fechou a família frota da frente 4** (`073`):

1. **A baleeira dos 6 cargueiros no convés de embarcações.** A superestrutura
   tem dois níveis; a baleeira fica no teto do de baixo, pelo bordo que se vê,
   com dois turcos inclinados e uma parede cega ao lado. Foi perguntado antes
   de desenhar, e a sexta candidata foi aceite.
2. **A bandeira saiu dos nove navios**, os de pesca incluídos. Com ela saíram
   o `pavilhao()` e o mastro de sinais.
3. **Os nove estão no jogo** (`art/props` e o atlas): seis suítes verdes, D29
   abaixo do teto nos oito medidos, `.pck` +2.608 bytes, bateria de capturas
   com `COBERTURA OK` e a folha da frota refotografada.

O Bruno não pediu PR: o trabalho só existe na branch.

---

## 1. Comece pelo estado real

- Confira no GitHub se a `claude/pensive-hypatia-1cdznc` virou PR e se foi
  fundida; se não foi, a conversa seguinte parte dela (um ref de cada vez no
  `git fetch`, `CLAUDE.md`).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).

## 2. O que vem a seguir é escolha do Bruno

O resto da frente 4 é **ruína e obras** e **animação** (plano v3, §7, item 4
e a secção «A FRENTE 4 ABRIU»). Pergunte qual, com opções e a recomendação
primeiro, e depois o ESCOPO da família antes de desenhar (`/arte`, §8).

## 3. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`); a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Onde uma peça vai pergunta-se ANTES do render, com uma prévia em ASCII de
  cada saída: a baleeira levou seis posições a olho na `072` e uma pergunta
  aqui (`/arte`, §8; `073`).
- ⚠️ A legenda com a pergunta não o fez responder em texto: «E agora?» é o
  mesmo sinal que «Mande pergunta», e a pergunta sozinha voltou (`/arte`, §8).
- ⚠️ Dentro do casco não é «fora»: o conferidor não apanha uma peça enterrada,
  e quem a apanhou foi a foto (`tools/conferir_casco.py`; `073`).
- ⚠️ Um nome reusado por um laço mais abaixo na mesma função pôs a baleeira a
  0,46, dentro do casco, sem erro (`marcas_de_carga()` no
  `tools/gerar_props_iso.py`; `073`).
