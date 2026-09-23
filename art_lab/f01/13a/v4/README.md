# Pacote BR Port 13A V4 — laboratório isolado

Abra primeiro `13a_v4_comparacao.jpg`, `13a_v4_tres_posicoes.jpg` e `RELATORIO_13A_V4.md`. Esta é uma **candidata**: `ready_for_release=false`.

Reproduzir a partir do checkout **exato** `cc36166` com as três alterações locais V3 auditadas e com `Main.tscn` correspondente:

```bash
python3 build.py /caminho/para/br-port
python3 qa_v4.py
python3 previews.py
```

Requer Python 3.10+, Pillow e Inkscape. `build.py` gera SVGs, não o PNG: para atualizar a rasterização, use `inkscape porto_mapa_iso_v4.svg --export-type=png --export-filename=mapa_v4.png --export-width=720 --export-height=720`, repetindo para o pátio, e exporte `13a_v4_instancia_1.svg` como PNG. Os SVGs V3 e suas rasterizações precisam ser extraídos do checkout de base para atualizar `mapa_v3.png` e `mapa_patio_v3.png`. `qa_v4.py` lê os rasters presentes no pacote; confira que correspondem às fontes antes de executá-lo em outra base.

`13a_v4_proposta.patch` é o handoff de código; os dois SVGs de mapas são **prévias de laboratório** e nunca devem sobrescrever os mapas do repositório sem adaptação ao estado atual e validação do jogo. O snapshot `Main.tscn` está em `../brport_vs/scenes/` no pacote para a cópia isolada do gerador encontrar as mesmas relações do checkout auditado.
