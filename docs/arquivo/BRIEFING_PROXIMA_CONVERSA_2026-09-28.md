# BR Port — prompt para a próxima conversa (a frota: fechar os cargueiros)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus no começo** — a conversa abre por uma decisão de desenho (onde
vai a baleeira) e por uma pergunta ao Bruno; tirar as bandeiras e pôr os
navios no jogo é receita e desce para **Sonnet** (`CLAUDE.md`, «Qual MODELO
faz o quê»).

**Situação:** substitui o `27d`. A sessão de 27–28/09 trabalhou na branch
`claude/affectionate-gates-lyhx2m`, a partir da `main` com o PR #95 fundido,
na **frente 4, família frota** (`071`, `072`):

1. **Os 3 barcos de pesca detalhados e NO JOGO** (`071`, commit `623e584`):
   pneus em anel, nome na proa, bandeira num pau na popa, escorrido na faixa;
   a traineira com janelas, rede cinzenta em malha, cortiças e balsa; o
   arrasteiro com portas de arrasto, a rede no tambor e o saco de losangos
   pendurado do pórtico. Aceites na quinta candidata.
2. **Os 6 cargueiros EM CURSO** (`072`): cinco candidatas, a quinta está no
   `gerar_props_iso.py` e **nenhuma no jogo** — os PNGs de
   `art/props/barco_{medio,grande}_*` são os de antes. O convés deixou de
   passar da borda (tampas e baias pela `meia_carga`, contêineres de 20 pés no
   longo curso, paus-de-carga do pé do mastro).
3. **`tools/conferir_casco.py`** (novo, com `bpy`): mede cada peça contra a
   meia-boca do casco. Na quinta candidata os seis dão «tudo dentro».

O Bruno não pediu PR: o trabalho só existe na branch.

---

## 1. Comece pelo estado real

- Confira no GitHub se a `claude/affectionate-gates-lyhx2m` virou PR e se foi
  fundida; se não foi, a conversa seguinte parte dela (um ref de cada vez no
  `git fetch`, `CLAUDE.md`).
- Veja os PRs abertos do Codex antes de mexer no `gerar_props_iso.py`
  (`AGENTS.md`).
- O Blender não vem instalado: `bpy==4.5.0` num Python 3.11, com o
  `pip download` primeiro (`CLAUDE.md`, «Como rodar, aqui dentro»).

## 2. As duas ordens do Bruno ao fechar

1. **A baleeira vai para um lugar mais realista.** Hoje está no teto da
   cabine, num berço (`marcas_de_carga`), e ele recusou-o. Pendurada na parede
   ficava sempre sobre janelas. As saídas que se veem estão na `072` —
   superestrutura em dois níveis com a baleeira no convés de embarcações, ou
   queda livre numa rampa na popa (atrás da superestrutura nesta câmera). **É
   escolha dele: pergunte com opções antes de desenhar.**
2. **A bandeira do Brasil sai de TODOS os navios**, os três de pesca aceites
   incluídos. Nos de pesca é `bandeira=` no `marcas_de_casco`; nos cargueiros,
   o `pavilhao()` no mastro de sinais (e o mastro sai com ela). Os três de
   pesca voltam a `art/props` com o `--import` duas vezes (o atlas), e a
   folha `frota` refotografa-se.

Depois disso, o veredito dos 6 e a passagem para o jogo: renderizar em
`art/props`, o atlas, as seis suítes, o D29, o `.pck`, a bateria de capturas,
e fechar a `072`.

## 3. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`); a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`). O
resto da frente 4 — ruína e obras, animação — é escolha dele.

## 4. Lições desta sessão — onde vivem

- ⚠️ Peça de barco mede-se contra o casco, não a olho: três voltas de «partes
  fora do casco» até à medição (`CLAUDE.md`, Arte; `tools/conferir_casco.py`;
  `072`).
- ⚠️ A coordenada `Object` de um material lê a malha antes do `scale`: a malha
  do saco saiu seis vezes mais fina numa esfera esticada (`CLAUDE.md`, Arte;
  o `bola()` do `gerar_props_iso.py`; `071`).
- ⚠️ Malha irregular num volume redondo lê como pedra; rede cheia é regular
  (`material_malha_losango` no `gerar_props_iso.py`; `071`).
- ⚠️ O costado de carga é inclinado: peça rente pede o `y` à sua própria
  altura (`no_casco` e `rente` no `gerar_props_iso.py`; `072`).
- ⚠️ A baleeira na parede cai sempre sobre janelas, e no teto não é o sítio
  dela (`072`).
- ⚠️ O quadro num bloco e a pergunta no seguinte voltou 4 de 9 nesta frente; a
  pergunta sozinha, 6 de 6 (`/arte`, §8).
