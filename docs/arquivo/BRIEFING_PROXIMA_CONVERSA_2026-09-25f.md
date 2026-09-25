# BR Port — prompt para a próxima conversa (depois do aceite da frente 3)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para a primeira mensagem, que é uma escolha do Bruno entre
frentes e o desenho da que ele escolher (F1); o que for receita desce para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `25e`. A sessão de 25/09 fechou no **PR #88**
(branch `claude/focused-albattani-nxjl3b`), com duas coisas:

1. **O save do jogador ficou fora do alcance das ferramentas** (`061`): todo
   processo com `--script` grava em `user://ferramentas/` pelo
   `scripts/ArmazemLocal.gd` — o save, as gravações de playtest e o volume.
   F13 no `teste_fumaca`; sentinela no CI (`tools/sentinela_do_jogador.py`).
2. **A primeira família da frente 3 do A5 foi aceite: «ficou bom».** Boletim,
   contra-oferta, cobrança do Sr. Ribeiro e balanço, em cinco passagens
   (`062`–`064`): o custo da recusa antes da aposta, o total no topo de cada
   bloco, a barra da parcela do HUD na cobrança, a chance como barra em cada
   aposta, o balanço em quadros e a tarja no tom do que diz. O F14 confere
   cada promessa da tela contra o que o jogo faz.

---

## 1. Comece pelo estado real

- Confira no GitHub se o **PR #88** foi fundido. Se não foi, a `061` a `064`
  só existem nele, e uma decisão nova numerada a partir da `main` colidiria.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).
- **Antes de fotografar no desktop do Bruno**, a branch tem de trazer a
  `061`: uma anterior ainda apaga o save (`CLAUDE.md`, «Como rodar, aqui
  dentro»).

## 2. O que o Bruno escolhe a seguir

Sem fila ordenada, a ordem é dele (§A5 do plano v3). Pergunte com opções:

- **O resto da frente 3** — diário, menu, mensagens, pausa, docas, caixa,
  reputação, nomes. O vocabulário da família aceite (cabeçalho com selo,
  tarja com linha de apoio e tom, barra do HUD, quadros de número) está no
  tema e serve-lhes (plano v3, «A primeira família da frente 3 fechou»).
- **Frente 4** — mapa, frota e animação, no Blender.
- **Frente 5** — o rumo além do VS: mexe em `GameState`, balanceamento e
  `SAVE_VERSION`; decisão de rumo.
- **Frente 6** — a folha de contato dos props.
- E os gates dele: o galpão V3 (recuperar ou refazer, `art_lab/`), a leitura
  em voz alta do A4 e a escuta do A6 (`docs/PROTOCOLO_DE_ESCUTA.md`).

## 3. Lições desta sessão — onde vivem

- ⚠️ Número que o painel promete confere-se contra o que o jogo faz, e «usa a
  mesma função» não é essa prova (`CLAUDE.md`, seção Interface; `062`).
- ⚠️ Comentário no `.tres` leva `;` em cada linha: um esquecido partiu o tema
  e a fumaça passou verde, até o F1 passar a carregar todo `.tres`
  (`CLAUDE.md`, seção Interface; `064`).
- ⚠️ A soma do boletim só apanha a linha esquecida numa semana com TODAS as
  fontes diferentes de zero, montada das chaves do jogo (`063`, «As
  guardas»; comentário do `_f14_boletim()` no `teste_fumaca.gd`).
- ⚠️ A guarda da pasta passou verde com a criação retirada: o F1 já a criava
  pelo `Registro` armado (`061`, «Medido»; comentário de
  `ArmazemLocal.caminho()`).
- ⚠️ A sentinela no disco partiu a foto da BASE do PR, que lia o save falso:
  depois de conferida ela sai (`061`, «Medido»; docstring de
  `tools/sentinela_do_jogador.py`).
- ⚠️ As páginas de referência de jogos estão bloqueadas pelo proxy; a busca
  funciona (`CLAUDE.md`, «Como rodar, aqui dentro»).
- ⚠️ Na interface o Bruno responde em texto livre: «continue» é mais uma
  passagem na mesma direção, e cada passagem leva UM tema e o antes/depois
  contra a `main` (`.claude/skills/arte/SKILL.md`, «O veredito na conversa»).
