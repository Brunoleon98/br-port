class_name AvisoDeReputacao
extends RefCounted

# O alerta acompanha os patamares existentes: abaixo de Confiável. Não cria
# outro corte econômico nem depende do arredondamento do número no HUD (`147`).
static func baixa(valor: float) -> bool:
	var gs: Node = Engine.get_main_loop().root.get_node("GameState")
	return gs.rotulo_da_reputacao(valor) in ["Questionável", "Desconhecido"]


static func atualizar(rotulo: Label, valor: float) -> void:
	rotulo.theme_type_variation = &"TextoPilulaAlerta" if baixa(valor) else &"TextoPilulaDestaque"
