extends PainelNarrativo

# O encerramento é uma página do mesmo caderno, por cima do porto vivo.
# Reabrir pelo painel da meta permite reler após retomar uma partida.
func setup(_sem_argumentos: Variant = null) -> void:
	montar_caderno(ESCURO_LEITURA)
	pagina_do_caderno(true, true)
	entrada_do_diario("O cais cresceu", Narrativa.fim_da_fase_2())
	legenda_acima_do_caderno("Fase 2 concluída", "O porto continua em jogo livre.", Icones.VITORIA)
	botao_abaixo_do_caderno("Seguir em jogo livre", queue_free)
