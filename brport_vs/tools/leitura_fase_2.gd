extends RefCounted

# Resumo puro para testar denominadores e censura sem jogar milhares de dias.
# Ausência de observação não é zero dias até a meta.
static func quantis(valores: Array) -> Dictionary:
	if valores.is_empty():
		return {"n": 0, "p10": null, "p50": null, "p90": null}
	var v := valores.duplicate()
	v.sort()
	var n := v.size()
	return {"n": n, "p10": v[mini(n - 1, int(n * 0.1))],
		"p50": v[int(n / 2)], "p90": v[mini(n - 1, int(n * 0.9))]}


static func resumir(linhas: Array) -> Dictionary:
	var r := {"partidas": linhas.size(), "entraram": 0, "metas": 0,
		"perdas_fase_1": 0, "quebras_antes_meta": 0, "quebras_apos_meta": 0,
		"censuradas": 0, "travadas": 0, "dias_ate_meta": {}, "caixa_entrada": {},
		"caixa_meta": {}, "menor_caixa": {}, "caixa_final": {}, "margem_operacional": {},
		"dias_abaixo_piso": {}, "suspensoes": {}, "recuperacoes": {}}
	var amostras := {}
	for chave in ["dias_ate_meta", "caixa_entrada", "caixa_meta", "menor_caixa",
			"caixa_final", "margem_operacional", "dias_abaixo_piso", "suspensoes", "recuperacoes"]:
		amostras[chave] = []
	for linha in linhas:
		if linha["travou"]:
			r["travadas"] += 1
			continue
		if linha["entrada"] == null:
			r["perdas_fase_1"] += 1
			continue
		r["entraram"] += 1
		var meta: bool = linha["dias_ate_meta"] != null
		if meta:
			r["metas"] += 1
		if linha["quebrou"]:
			r["quebras_apos_meta" if meta else "quebras_antes_meta"] += 1
		elif not meta:
			r["censuradas"] += 1
		for chave in amostras:
			if linha[chave] != null:
				amostras[chave].append(linha[chave])
	for chave in amostras:
		r[chave] = quantis(amostras[chave])
	return r
