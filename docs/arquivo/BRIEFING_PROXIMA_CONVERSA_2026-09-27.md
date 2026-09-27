# BR Port — prompt para a próxima conversa (depois da frente 3)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** — a conversa abre com uma escolha de rumo e o escopo de uma
família nova (F1); o que vier depois de decidido desce para **Sonnet**
(`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `26b`. A sessão de 27/09 trabalhou na branch
`claude/bold-gauss-p11nrc`, a partir da `main` com o PR #91 fundido, na
**quarta passagem da conversa do celular** (`067`), e o Bruno respondeu
**«Aceito»**: fecha a família das telas de texto e, com ela, a **frente 3 do
A5** inteira.

1. **Cada voz tem o seu balão**, no tom da roupa do retrato: a Dona Cida
   verde, o Arlindo petróleo claro e o Sr. Ribeiro quase branco, «o papel do
   banco». O **D38** tranca-o (matiz lido do PNG do retrato, ΔE entre os
   três, bico e tom único) e o telefone que cabe.
2. **O telefone da conversa é maior** (460 × 782, a proporção do menu), e o
   menu saiu igual pixel a pixel.
3. **O avatar mostra a cabeça inteira** — o recorte mede a cabeça e não os
   ombros —, que foi o único reparo do veredito.
4. A bateria tem **43 fotos, uma nova** (`mensagens_vozes`), e contra a `main`
   mudou só a `mensagens`.

A branch virou o **PR #92**, por fundir quando este briefing foi escrito.

---

## 1. Comece pelo estado real

- Confira no GitHub se o PR #92 (`claude/bold-gauss-p11nrc`) foi fundido.
  **Se não foi, o trabalho desta sessão só existe nela**: a branch da conversa
  seguinte parte dela (`git fetch origin claude/bold-gauss-p11nrc`, um ref de
  cada vez), e nunca de uma `main` sem ela.
- Um ref de cada vez no `git fetch`, com o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).
- O CI só corre em PR e na `main` (`CLAUDE.md`, «Como rodar, aqui dentro»).

## 2. O que vem — a escolha é do Bruno

A frente 3 fechou, e **a ordem das frentes 4 a 6 é dele**
(`docs/design/BR_Port_Plano_v3_Claude_Code.md`, a lista das seis frentes do
A5). Pergunte com opções, antes de desenhar:

- **4 — Mapa, frota e animação** (Blender, grande): pesca mais realista,
  cascos e camiões com variações, ruína com mais desgaste, o trabalhador
  animado, transição entre turnos.
- **5 — O rumo além do VS** (várias sessões): as três parcelas da Fase 1,
  desbloqueios, tutorial, empréstimo, obras que levam turnos. Mexe no
  `GameState`, no balanceamento e no `SAVE_VERSION` — passa pela `/balancear`.
- **6 — A folha de contato dos props** (pequeno a médio): só ferramenta, e
  barateia a 4.
- Pendente de antes: o **galpão V3** que ele aprovou só existe no `art_lab`
  (`art/f01-galpao`) — recuperar ou refazer (`docs/ESTADO_DO_PROJETO.md`, A5).

Família nova de arte pergunta o **escopo** antes de desenhar (`/arte`, «O
veredito na conversa»).

## 3. O que está com o Bruno

- **A foto do porto antigo**, no ChatGPT, pelo `art_lab/diario/BRIEFING.md`
  (entrega 1200 × 850); a integração troca o `const FOTO` do `TelaNomes.gd`.
- **O fundo e o logotipo da tela inicial**, pelo
  `art_lab/tela_inicial/BRIEFING.md`.
- **A leitura dos textos novos** (A4): «Nome do cais», «Este diário pertence
  a», «(pode deixar em branco)», «O nome do cais não muda depois.», «Dia N».
- **Ouvir os sons** (A6), pelo `docs/PROTOCOLO_DE_ESCUTA.md`.

## 4. Lições desta sessão — onde vivem

- ⚠️ Cor escura clareada com branco perde o matiz: os três balões saíram a
  ΔE 2,4 a 8,5; escolhe-se o matiz e a croma em OKLCH e mede-se o ΔE entre os
  irmãos (`CLAUDE.md`, «Interface»; `067`).
- ⚠️ A prancha num bloco e a pergunta no seguinte falharam 2 de 2 — o turno
  acaba no envio; a pergunta sozinha depois do aviso voltou sempre (`/arte`,
  «O veredito na conversa»).
- ⚠️ Uma subclasse não redefine a `const` do pai: o tamanho do aparelho é
  argumento do `montar_celular()` (`brport_vs/scripts/PainelCelular.gd`).
- ⚠️ O avatar mede-se pela cabeça, do topo ao pescoço, e não pelos ombros
  (`brport_vs/scripts/Retratos.gd`).
- ⚠️ Arte que a partida da bateria não mostra leva um tiro próprio: os balões
  do Sr. Ribeiro e do Arlindo vêm da amostra do D33 pelo `#historico`
  (`tools/capturar_evidencia.sh`; `brport_vs/tools/capturar_cena.gd`).
