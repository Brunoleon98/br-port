# 036 — O galpão F1 preserva dois estados e o gerador atual

**22/09/2026.** O refinamento V3 do galpão F1 foi aprovado nos estados
`ruin` e `recovered`. A entrega melhora leitura industrial, profundidade e
identidade brasileira sem criar estado sem mecânica, novo consumidor ou novo
pipeline.

## Decisão

- `galpao_velho.png` continua sendo `ruin` e `galpao.png`, `recovered`;
- não existe imagem `construction`: a compra do armazém continua instantânea;
- os dois PNGs continuam gerados deterministicamente pelo bloco do galpão em
  `tools/gerar_props_iso.py`;
- `Main.tscn` e `Main.gd` continuam sendo consumidor e controlador;
- quadro 768×768 RGBA, âncora `base` e pegada 3,1104 × 1,9872 não mudam.

## Leitura aprovada

O recuperado usa portão de enrolar entreaberto, interior escuro, baia lateral
recuada, marquise com espessura e braços, chapa nervurada, calha, descida e
tambor azul. Ferrugem e remendos aparecem como desgaste localizado.

A ruína usa menos edifício: baia aberta, pórtico e contravento expostos, lona,
tijolo aparente, umidade, telhado incompleto e calha quebrada. A estrutura que
resta mantém a leitura de galpão e evita a aparência de entulho genérico.

## Evidência e custo

Os renders canônicos reproduziram exatamente, pixel a pixel, a candidata V3
aprovada. As caixas alfa acima de 8 são (313, 302)–(477, 457) na ruína e
(313, 298)–(498, 469) no recuperado; as caixas sólidas acima de 128 não mudaram
em relação à prancha aprovada. O PCK Android passou de 6.347.944 para
6.349.944 bytes, diferença de +2.000 bytes.

A composição foi aprovada em prancha estática. O ambiente desta rodada não
oferece servidor X para uma captura real do runtime; não se repete a tentativa
inócua de capturar `root.get_texture()` em headless. O gate físico no Samsung
A23 3 GB permanece aberto.
