"""BRP — roda um estúdio, exporta os PNGs, grava o .blend e junta o manifest.

    python3 blender/gerar_brp.py porto brport_vs/art/props
    python3 blender/gerar_brp.py porto brport_vs/art/props caminhao
    python3 blender/gerar_brp.py todos brport_vs/art/props
    python3 blender/gerar_brp.py porto --despejar=/tmp/porto.txt

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
import time

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
RAIZ = pathlib.Path(__file__).resolve().parent.parent
MANIFEST = str(RAIZ / "brport_vs/data/assets/BRP_EXPORT_MANIFEST.json")


def main() -> int:
    # `--despejar=<arquivo>` monta o estúdio, escreve a cena em texto e sai
    # sem render nem manifest: é a régua do arnês da montagem (`080`).
    despejo = next((a.split("=", 1)[1] for a in sys.argv[1:]
                    if a.startswith("--despejar=")), None)
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if despejo is not None:
        if len(args) != 1 or args[0] not in ESTUDIOS:
            print(__doc__.strip())
            return 2
        from brp_studio import Estudio
        import gerar_props_iso as base
        print(base.caminho_da_montagem())
        inicio = time.monotonic()
        est = Estudio(args[0])
        est.montar(importlib.import_module(ESTUDIOS[args[0]][0]).montar)
        print("montagem: %d objetos em %.1f s"
              % (len(base.bpy.data.objects), time.monotonic() - inicio))
        print("despejo: %d objetos em %s" % (base.despejar_cena(despejo), despejo))
        return 0
    if len(args) < 2:
        print(__doc__.strip())
        return 2
    categoria, saida, pedidos = args[0], args[1], args[2:]
    # `read_factory_settings`, chamado ao montar o estúdio, troca o diretório
    # corrente do Blender para a raiz do disco no Windows. Se a saída continuar
    # relativa, o render tenta escrever em C:\brport_vs e falha só no Blender
    # standalone (o módulo `bpy` preserva o cwd e escondia a armadilha).
    saida_p = pathlib.Path(saida)
    saida = str((saida_p if saida_p.is_absolute() else RAIZ / saida_p).resolve())

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
    import gerar_props_iso as base

    print(base.caminho_da_montagem())
    inicio = time.monotonic()
    est = Estudio(categoria)
    est.montar(importlib.import_module(modulo).montar)
    print("montagem: %d objetos em %.1f s"
          % (len(base.bpy.data.objects), time.monotonic() - inicio))
    fichas = est.exportar(saida, pedidos or None)
    escrever_manifest(MANIFEST, fichas)

    # O .blend é a fonte que o prompt pede entregar. Ele fica em blender/, na
    # raiz — nunca dentro de brport_vs/art/, que é só o que o Godot importa.
    destino = str(RAIZ / "blender" / blend)
    est.salvar_blend(destino)
    print("blend: %s" % destino)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
