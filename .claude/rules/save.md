---
paths:
  - "brport_vs/autoload/GameState.gd"
  - "brport_vs/scripts/ArmazemLocal.gd"
  - "brport_vs/scripts/PainelEspacos.gd"
  - "brport_vs/tests/teste_fumaca.gd"
  - "tools/sentinela_do_jogador.py"
---

# Regras — o save

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Save

`SAVE_VERSION` sobe **sempre** que a forma ou a interpretação do estado muda.
A fila ocupou a versão 10 (`083`); a reescala monetária subiu para 11 (`084`).
As três cobranças, o calendário e os recibos subiram para 12 (`085`):
o booleano antigo só representava a primeira quitação. A madeira durante toda
a Fase 1 subiu para **13** (`086`), com autorização explícita do Bruno:
a 12 podia guardar cargueiros após dois reparos, incompatíveis com essa máquina.
A obra em andamento ocupa a **14** (`087`), autorizada explicitamente pelo
Bruno junto dos prazos. Saves 13 e anteriores são recusados sem migração:
partidas antigas recomeçam. Consulta preserva o arquivo; carregamento
descarta o incompatível antes de aplicar campos, inclusive a obra viva.
Save de outra
versão é descartado, não adaptado. Já custou um porto com 4 docas num mapa que
desenha 3.

**E recusar é recusar sem ter tocado em nada.** O `load_game()` escrevia os
campos um a um e só conferia a sanidade do roster no fim: um save recusado
deixava o `turn` e o `cash` do arquivo no estado vivo, com zero docas. Passava
despercebido porque o `new_game()` que vem a seguir por acaso reescreve todos
os campos — uma segurança que dependia de duas funções distantes continuarem a
concordar sobre a lista de campos, e que um campo novo teria quebrado calada.
**Tudo o que recusa vem antes de tudo o que escreve**, e o `teste_fumaca.gd`
tranca isso.

**São três espaços, e o 1 é o arquivo de sempre** (`docs/decisoes/066`): o
`savegame.json` que o jogador já tinha aparece no espaço 1 sem migração, e o
`SAVE_VERSION` não subiu. **Ler um espaço não é carregá-lo**: o
`resumo_do_espaco()` usa as MESMAS recusas do `load_game()` (`_save_aceite`)
e não apaga nada; quem apaga é a partida nova que o ocupa. O «jogado por
último» é a hora do ARQUIVO — um carimbo no JSON mudaria a forma. O F16 tranca
as três coisas.
