# BR Port — prompt para a próxima conversa (depois da quarta passagem)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler o veredito do Bruno e decidir a próxima iteração
(F3/F4); aplicar e remedir desce para **Sonnet** (`CLAUDE.md`, «Qual MODELO faz
o quê»).

**Situação:** substitui o `25c`. A sessão de 25/09 fez duas coisas, na branch
`claude/focused-albattani-nxjl3b` e no PR #88:

1. **O save do jogador ficou fora do alcance das ferramentas** (`061`): todo
   processo com `--script` grava em `user://ferramentas/` pelo
   `scripts/ArmazemLocal.gd`. O save era um de três — as suítes também
   apagavam as gravações de playtest e gravavam o volume a zero. F13 no
   `teste_fumaca`, sentinela no CI.
2. **A terceira e a quarta passagem da frente 3 do A5** (`062`, `063`): o
   custo da recusa antes da aposta, o total no topo de cada bloco do boletim,
   a barra da parcela do HUD na cobrança, a chance como barra em cada botão do
   Arlindo e o balanço em quadros — com referências de *Two Point Hospital*,
   *Papers, Please*, *Reigns* e *Moonlighter*. O F14 confere cada número e
   cada barra prometidos contra o que o jogo faz (11 mutantes).

---

## 1. Comece pelo estado real

- Confira no GitHub se o PR #88 foi fundido. Se não foi, a `061`, a `062` e a
  `063` só existem nele, e uma decisão nova numerada a partir da `main`
  colidiria com elas.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- O PR #87 do Codex (briefing pós-merge) mexe no `docs/arquivo/README.md`,
  como este; o conflito é de uma linha no índice.

## 2. O que espera o Bruno

- **O veredito visual da quarta passagem.** As fotos estão no artefato
  `brport-captura` do PR; o antes/depois recortado (a `main` contra a quarta)
  foi mostrado na conversa. Se ele pedir mais uma volta: nada de economia,
  `# TUNING:`, sistema novo ou dashboard (`063`, «O que se decidiu»). Ícone
  por linha no boletim pede arte, e a técnica é escolha dele (`063`, «Ficaram
  de fora»).
- **Antes de fotografar no desktop dele**, a branch tem de trazer a `061`: uma
  branch anterior ainda apaga o save (`CLAUDE.md`, «Como rodar, aqui dentro»).
  A partida perdida em 25/09 não volta.

## 3. Lições desta sessão — onde vivem

- ⚠️ Número que o painel promete confere-se contra o que o jogo faz, e «usa a
  mesma função» não é essa prova (`CLAUDE.md`, seção Interface; `062`).
- ⚠️ A guarda da pasta passou verde com a criação retirada: o F1 já a criava
  pelo `Registro` armado — daí a sonda numa subpasta própria (`061`,
  «Medido»; comentário de `ArmazemLocal.caminho()`).
- ⚠️ A soma do boletim só apanha a linha esquecida numa semana com TODAS as
  fontes diferentes de zero, montada das chaves do jogo (`063`, «As guardas»;
  comentário do `_f14_boletim()` no `teste_fumaca.gd`).
- ⚠️ As páginas de referência de jogos estão bloqueadas pelo proxy; a busca
  funciona (`CLAUDE.md`, «Como rodar, aqui dentro»).
- ⚠️ A chance medida com 800 apostas desviou 4,4 pontos num corte de 7, e com
  20.000 bateu a ±0,2: era a sequência da semente, partilhada entre as duas
  reputações (`062`, «A guarda»; comentário do F14 no `teste_fumaca.gd`).
