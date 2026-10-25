class_name VidaDoPorto
extends RefCounted

# Catálogo e condições separados da interface: o save e as lojas consultam
# os mesmos ids. Preços novos são de compras narrativas opcionais (`141`).
const PRODUTOS := {
	"cafe": {"loja": "mercado", "nome": "Kit de café", "preco": 180,
		"efeito": "Desbloqueia a conversa Café no cais. Compra única; sem bônus de operação."},
	"almoco": {"loja": "delivery", "nome": "Almoço para a equipe", "preco": 240,
		"efeito": "Desbloqueia a conversa A mesa do cais. Compra única; sem cobrança recorrente."},
}
const CAPITULOS := {
	"caneca": "A caneca que ficou",
	"chave": "A chave do galpão",
	"recibo": "O nome no recibo",
	"envelope": "O envelope",
	"mesa": "A mesa da esquina",
	"arlindo": "Uma proposta informal",
	"cafe": "Café no cais",
	"almoco": "A mesa do cais",
}


static func vazio() -> Dictionary:
	return {"compras": [], "cenas_lidas": []}


# O prazo é mínimo E o acontecimento precisa ter ocorrido. Antecipar a
# parcela não antecipa a cena; uma obra em andamento não revela o envelope.
static func disponiveis(dia: int, fase: int, dias_por_semana: int,
		estruturas: Array, quitadas: int, compras: Array) -> Array[String]:
	var ids: Array[String] = []
	if dia > dias_por_semana:
		ids.append("caneca")
	if dia > 2 * dias_por_semana:
		ids.append("chave")
	if dia > 4 * dias_por_semana and (quitadas >= 1 or fase > 1):
		ids.append("recibo")
	if dia > 6 * dias_por_semana and estruturas.has("armazem"):
		ids.append("envelope")
	if dia > 8 * dias_por_semana and (quitadas >= 2 or fase > 1):
		ids.append("mesa")
	if dia > 10 * dias_por_semana:
		ids.append("arlindo")
	for produto in PRODUTOS:
		if compras.has(produto):
			ids.append(produto)
	return ids


# Não aceita compra desconhecida nem repetida: uma leitura tolerante aqui
# apagaria o direito a uma conversa e poderia cobrar outra vez na retomada.
static func estado_valido(estado: Variant) -> bool:
	if typeof(estado) != TYPE_DICTIONARY or estado.size() != 2:
		return false
	for chave in ["compras", "cenas_lidas"]:
		if typeof(estado.get(chave)) != TYPE_ARRAY:
			return false
		var vistos := {}
		for id in estado[chave]:
			if typeof(id) != TYPE_STRING or vistos.has(id):
				return false
			if not (PRODUTOS.has(id) if chave == "compras" else CAPITULOS.has(id)):
				return false
			vistos[id] = true
	for id in PRODUTOS:
		if estado["cenas_lidas"].has(id) and not estado["compras"].has(id):
			return false
	return true
