extends "res://tools/estado_cancelamento_experimental.gd"

# Adaptador só da medição: a ação é a do produto; o JSON preserva o contrato
# da bancada 110 para comparar todos os eventos e percursos, sem reescrevê-la.
func cancelar_no_experimento(doca: int, uid: int) -> bool:
	var evento := custos_do_cancelamento(doca, uid)
	if evento.is_empty():
		return false
	var orcamento := evento.duplicate(true)
	evento["missao_antes"] = primeiro_cargueiro
	evento["meta_antes"] = meta_concluida
	if not cancelar_servico(doca, uid, orcamento):
		return false
	cancelamentos.append(evento)
	return true
