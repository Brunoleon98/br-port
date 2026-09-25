class_name ArmazemLocal
extends RefCounted

# ============================================================
# ONDE O JOGO GUARDA O QUE É DO JOGADOR — um lugar só (`docs/decisoes/061`)
# ============================================================
#
# O save, as gravações de partida e o volume vivem em `user://`, e no desktop
# essa pasta é PERSISTENTE e partilhada entre o jogo e toda ferramenta que se
# corra com `--script` sobre o mesmo projeto. Em 25/09 uma captura
# (`capturar_cena.gd`, que faz `clear_save()` + `new_game()`) substituiu a
# partida real do Bruno no Windows por uma nova no turno 1, e não havia cópia.
#
# ⚠️ E O SAVE ERA SÓ O PRIMEIRO DE TRÊS. Varrido o que uma ferramenta toca:
#  - o `teste_registro.gd` e o `gravar_partidas.gd` APAGAM todo arquivo da
#    pasta de registros antes de começar — as gravações de playtest do A7;
#  - cada tiro de jogo da bateria arma o `Registro`, que PODA a pasta aos
#    vinte mais novos: 35 tiros empurravam para fora toda partida real;
#  - o `teste_audio.gd` grava o volume a 0,5 e a 0 antes de o repor, e um
#    erro a meio deixava o jogo do Bruno MUDO sem explicação nenhuma.
#
# A saída é isolar por PROCESSO, e não por ferramenta: tudo o que corre com
# `--script` (ou `-s`) — as seis suítes, a bateria de captura, o simulador,
# as réguas — escreve em `user://ferramentas/`, e o jogo aberto normalmente,
# pelo editor ou exportado, continua em `user://`. Não depende de a
# ferramenta se lembrar de nada, nem de acabar bem: o arquivo do jogador nunca
# chega a ser aberto para escrita, e um processo morto a meio não o deixa
# pior do que estava.
#
# Tentou-se primeiro a saída do SO — não há `--user-data-dir` no Godot 4.6
# (conferido no `--help`), e redirecionar o `APPDATA`/`XDG_DATA_HOME` depende
# de quem lança o processo lembrar-se de o fazer, em duas sintaxes de shell.
# Cópia em memória e reposição no fim foi descartada pelo próprio briefing:
# um processo que morre não repõe nada.
#
# ⚠️ LIMITES, escritos para não se prometer mais do que isto faz:
#  - protege só os processos com `--script`/`-s`. Jogar pelo editor usa e
#    reescreve o save do jogador, que é o jogo a funcionar;
#  - vale nos commits que o trazem: uma branch anterior a ele, ou uma cópia
#    velha do projeto, continua a apagar o save;
#  - a pasta das ferramentas vive DENTRO da do jogador — apagar a pasta do
#    projeto em `app_userdata` leva as duas;
#  - não recupera a partida perdida em 25/09.
#
# O `teste_fumaca.gd` (F13) prova que os três caminhos saem daqui e que o
# código do jogo não escreve `user://` por fora; o CI planta uma sentinela no
# lugar do jogador e exige-a intacta depois das suítes e da bateria
# (`tools/sentinela_do_jogador.py`).

const RAIZ_DO_JOGADOR := "user://"
const RAIZ_DAS_FERRAMENTAS := "user://ferramentas/"


# `args` só se passa para o teste provar os dois lados; o jogo pergunta ao SO.
static func sob_ferramenta(args: PackedStringArray = OS.get_cmdline_args()) -> bool:
	# O Godot consome `--path` e `--headless`, mas deixa `--script` na lista —
	# medido. A forma curta `-s` é a mesma opção, e é a que um atalho escreve.
	return args.has("--script") or args.has("-s")


# O caminho de `nome` para ESTE processo. Cria a pasta onde ele vai viver,
# porque o `FileAccess.open(..., WRITE)` do save não cria pasta nenhuma e
# falharia calado — o autosave sairia sem erro e sem arquivo.
#
# ⚠️ NA FUMAÇA, QUEM CRIAVA A PASTA ERA OUTRO. O F1 instancia o `Main`, que
# arma o `Registro`, que cria `ferramentas/registros` — e com ela a pasta-mãe:
# tirar a linha abaixo não reprovava nada. Daí a pasta ser a do PRÓPRIO
# arquivo, e o F13 prová-lo com uma sonda numa subpasta que ninguém mais cria.
static func caminho(nome: String, args: PackedStringArray = OS.get_cmdline_args()) -> String:
	if sob_ferramenta(args):
		var destino := RAIZ_DAS_FERRAMENTAS + nome
		DirAccess.make_dir_recursive_absolute(destino.get_base_dir())
		return destino
	return RAIZ_DO_JOGADOR + nome
