# BR Port — prompt para a próxima conversa (depois da terceira passagem)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para ler o veredito do Bruno e decidir a próxima iteração
(F3/F4); aplicar e remedir desce para **Sonnet** (`CLAUDE.md`, «Qual MODELO faz
o quê»).

**Situação:** a sessão de 25/09 fez duas coisas, na branch
`claude/focused-albattani-nxjl3b` e no PR aberto dela:

1. **O save do jogador ficou fora do alcance das ferramentas** (`061`): todo
   processo com `--script` grava em `user://ferramentas/` pelo
   `scripts/ArmazemLocal.gd`. O save era um de três — as suítes também
   apagavam as gravações de playtest e gravavam o volume a zero. F13 no
   `teste_fumaca`, sentinela no CI.
2. **A terceira passagem da frente 3 do A5** (`062`): a tarja com a conta por
   baixo do número, a contra-oferta a dizer o que custa a recusa antes da
   aposta, o balanço a contar disputas ganhas e perdidas. O F14 confere cada
   número prometido contra o que o jogo faz.

---

## 1. Comece pelo estado real

- Confira no GitHub se o PR da `claude/focused-albattani-nxjl3b` foi fundido.
  Se não foi, a `061` e a `062` só existem nele, e uma decisão nova numerada a
  partir da `main` colidiria com elas.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- O PR #87 do Codex (briefing pós-merge) mexe no `docs/arquivo/README.md`,
  como este; o conflito é de uma linha no índice.

## 2. O que espera o Bruno

- **O veredito visual da terceira passagem.** As oito fotos que mudaram estão
  no artefato `brport-captura` do PR; o antes/depois recortado foi mostrado na
  conversa. Se ele pedir mais uma volta, a iteração continua pequena: nada de
  economia, `# TUNING:` ou sistema novo (`062`, «O que se decidiu»).
- **Antes de fotografar no desktop dele**, a branch tem de trazer a `061`: uma
  branch anterior ainda apaga o save (`CLAUDE.md`, «Como rodar, aqui dentro»).
  A partida perdida em 25/09 não volta.

## 3. Lições desta sessão — onde vivem

- ⚠️ Número que o painel promete confere-se contra o que o jogo faz, e «usa a
  mesma função» não é essa prova (`CLAUDE.md`, seção Interface; `062`).
- ⚠️ A guarda da pasta passou verde com a criação retirada: o F1 já a criava
  pelo `Registro` armado — daí a sonda numa subpasta própria (`061`,
  «Medido»; comentário de `ArmazemLocal.caminho()`).
- ⚠️ A chance medida com 800 apostas desviou 4,4 pontos num corte de 7, e com
  20.000 bateu a ±0,2: era a sequência da semente, partilhada entre as duas
  reputações (`062`, «A guarda»; comentário do F14 no `teste_fumaca.gd`).
