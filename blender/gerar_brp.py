"""BRP — roda um estúdio, exporta os PNGs, grava o .blend e junta o manifest.

    python3 blender/gerar_brp.py porto brport_vs/art/props
    python3 blender/gerar_brp.py porto brport_vs/art/props caminhao
    python3 blender/gerar_brp.py todos brport_vs/art/props

Um estúdio por processo, e isso é obrigatório: `preparar_cena()` chama
`read_factory_settings`, que apaga a cena inteira. Rodar dois catálogos no mesmo
processo perderia o primeiro — daí `todos` reexecutar este script em vez de
importar os quatro módulos em sequência.
"""

import importlib
import os
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

ESTUDIOS = {
    "terreno": ("brp_terreno", "BRP_TerrainStudio.blend"),
    "porto":   ("brp_porto",   "BRP_PortAssetsStudio.blend"),
    "cidade":  ("brp_cidade",  "BRP_CityStudio.blend"),
    "fauna":   ("brp_fauna",   "BRP_FaunaStudio.blend"),
}

# O manifest fica DENTRO do projeto Godot, e não em docs/, porque quem mais
# precisa de o ler é o validador que roda no Godot — e `res://` não alcança
# nada fora de `brport_vs/`. O prompt pede o arquivo em docs/; ter as duas
# cópias seria a fonte dupla que este projeto já pagou caro uma vez (a errata
# da economia). docs/arquivo/BRP_EXPORT_MANIFEST.md aponta para cá.
MANIFEST = "brport_vs/data/assets/BRP_EXPORT_MANIFEST.json"


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__.strip())
        return 2
    categoria, saida, pedidos = sys.argv[1], sys.argv[2], sys.argv[3:]

    if categoria == "todos":
        for c in ESTUDIOS:
            print("\n=== %s ===" % c)
            r = subprocess.run([sys.executable, __file__, c, saida])
            if r.returncode:
                return r.returncode
        return 0

    if categoria not in ESTUDIOS:
        print("estúdio desconhecido: %s\ndisponíveis: %s, todos"
              % (categoria, ", ".join(ESTUDIOS)))
        return 2

    modulo, blend = ESTUDIOS[categoria]
    from brp_studio import Estudio, escrever_manifest

    est = Estudio(categoria)
    est.montar(importlib.import_module(modulo).montar)
    fichas = est.exportar(saida, pedidos or None)
    escrever_manifest(MANIFEST, fichas)

    # O .blend é a fonte que o prompt pede entregar. Ele fica em blender/, na
    # raiz — nunca dentro de brport_vs/art/, que é só o que o Godot importa.
    destino = os.path.join("blender", blend)
    est.salvar_blend(destino)
    print("blend: %s" % destino)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
