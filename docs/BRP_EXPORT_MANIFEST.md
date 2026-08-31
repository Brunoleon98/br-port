# BRP — manifest de exportação

O manifest que a FASE 8 do prompt mestre pede está em
**`brport_vs/data/assets/BRP_EXPORT_MANIFEST.json`**, e não aqui.

A razão é operacional: quem mais o lê é `scripts/validation/asset_validator.gd`,
que roda dentro do Godot, e `res://` não alcança nada fora de `brport_vs/`.
Manter uma cópia em `docs/` daria duas fontes para o mesmo dado — que é
exatamente o erro que produziu a errata da economia do GDD.

Ele é gerado por `blender/gerar_brp.py` e traz, por asset: `id`, `category`,
`stage`, `file`, `format`, `frame_size`, `origin`, `base_cells`, `selectable`,
`habitat`, `animations` e `godot_scene`, mais o bloco `contrato` com a projeção
que produziu os PNGs.
