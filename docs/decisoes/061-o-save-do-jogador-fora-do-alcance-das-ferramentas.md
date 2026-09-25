# 061 — O save do jogador fora do alcance das ferramentas

**25/09/2026 · pedido do Bruno no briefing pós-merge do PR #86.** Numa captura
da passagem anterior, `capturar_cena.gd` (`clear_save()` + `new_game()`)
substituiu o `user://savegame.json` do desktop Windows por uma partida nova —
turno 1, R$400.000, nomes vazios — e não havia cópia. O pedido: isolar o
`user://` de modo verificável, ou garantir que as ferramentas preservam o save
mesmo quando falham, e explicar a solução e os limites antes de voltar a
fotografar.

## O que a varredura achou: o save era um de três

Tudo o que o jogo guarda vive em `user://`, e no desktop essa pasta é
persistente e partilhada entre o jogo e toda ferramenta que corra com
`--script` sobre o mesmo projeto. Além do save:

- **As gravações de partida.** O `teste_registro.gd` e o `gravar_partidas.gd`
  APAGAM todo arquivo de `user://registros` antes de começar — as gravações de
  playtest do A7. E cada tiro de jogo da bateria arma o `Registro`, cujo
  `_podar()` guarda só as vinte mais novas: 35 tiros empurravam para fora
  todas as partidas reais.
- **O volume.** O `teste_audio.gd` grava o volume a 0,5 e a 0 antes de o
  repor; um erro a meio deixava o jogo do jogador mudo.

## O que se decidiu

1. **Isolar por PROCESSO, num ponto só: `scripts/ArmazemLocal.gd`.** Todo
   processo com `--script` ou `-s` na linha de comando grava em
   `user://ferramentas/`; o jogo aberto normalmente, pelo editor ou exportado,
   continua em `user://`. O `GameState` (save), o `Audio` (volume) e o
   `Registro` (gravações) pedem-lhe o caminho. Medido: o Godot consome
   `--path` e `--headless`, mas deixa `--script` em `OS.get_cmdline_args()`.
2. **A constante `SAVE_PATH` saiu, e não foi por arrumação.** Era por ela que
   as suítes escreviam saves inválidos; com o isolamento a falhar, escreveriam
   no arquivo do Bruno. Hoje é `save_path` (variável, resolvida pelo
   `ArmazemLocal`) e o nome `SAVE_ARQUIVO`; uma referência esquecida ao nome
   velho não compila.
3. **Duas provas, uma de cada lado.** O **F13** do `teste_fumaca` prova a
   CAUSA: que os três caminhos saem do `ArmazemLocal`, que `--script` e `-s`
   contam e o jogo não, que o caminho dado já tem pasta para gravar (sonda numa
   subpasta que ninguém mais cria), e que o código do jogo não escreve
   `user://` por fora dele. O **CI** prova o ARQUIVO:
   `tools/sentinela_do_jogador.py` planta um arquivo conhecido nos três
   lugares do jogador antes das suítes e da bateria e exige-os byte a byte
   depois, sem gravação nova na pasta (`SENTINELA INTACTA`). Ela recusa-se a
   plantar onde já houver um jogador.

## Medido

- Com a sentinela plantada no contêiner: as seis suítes, o `gravar_partidas`
  e a bateria inteira (36 fotos) — **sentinela intacta**, 22 arquivos caídos em
  `user://ferramentas/`.
- **Defeitos injetados**, cada um com a base limpa antes do seguinte:
  - isolamento desligado (`sob_ferramenta()` → `false`): a captura do Sr.
    Ribeiro reescreveu o save do "jogador" com uma partida nova de 979 bytes —
    o incidente de 25/09, reproduzido — e o volume; a sentinela reprovou, e o
    F13 reprovou seis vezes. A fumaça sob o mesmo defeito deixou **12
    gravações** na pasta do jogador;
  - sem criar a pasta: **não reprovou** na primeira versão da guarda, que
    gravava o save — o F1 instancia o `Main`, que arma o `Registro`, que cria
    `ferramentas/registros` e com ela a mãe. Daí a sonda numa subpasta
    própria, e aí reprovou;
  - volume com o caminho literal: reprovou duas vezes (a origem do caminho e
    a varredura de `user://` por fora).

## Limites

- Protege só processos com `--script`/`-s`. Jogar pelo editor usa e reescreve
  o save do jogador, que é o jogo a funcionar.
- Vale nos commits que o trazem: **uma branch anterior a este, ou uma cópia
  velha do projeto, continua a apagar o save.** O `captura.yml` fotografa a
  base do PR por isso DEPOIS de conferir a sentinela.
- A pasta das ferramentas vive dentro da do jogador: apagar a pasta do projeto
  em `app_userdata` leva as duas.
- Não recupera a partida perdida em 25/09.
- A sentinela só corre onde não há jogador (contêiner, CI). No desktop quem
  protege é o isolamento; a prova é a do CI e a do F13.
- Tentou-se primeiro o SO: não há `--user-data-dir` no Godot 4.6 (conferido no
  `--help`), e redirecionar `APPDATA`/`XDG_DATA_HOME` dependeria de quem lança
  lembrar-se, em duas sintaxes de shell. Cópia em memória e reposição no fim
  foi descartada pelo próprio pedido: um processo morto não repõe nada.
