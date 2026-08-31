# BRP — notas de implementação

**FASE 13 do prompt mestre do pacote de arte.** O que foi feito, onde, por quê,
e — com o mesmo cuidado — **o que não foi feito**.

---

## 1. A decisão que governa tudo o que está aqui

O pacote trouxe arte e design no mesmo envelope. Só a arte foi aceita: o GDD 7
continua valendo, e cidade, fauna e progressão de três estágios continuam na
lista `VS — OUT`. O registro está em
`docs/decisoes/001-pacote-de-arte-externo-e-o-gdd-7.md`.

Consequência prática: **este pipeline foi implementado por inteiro; o conteúdo
que ele produz foi limitado de propósito.** Terreno, cidade e fauna existem
para a cena de teste, não para o jogo — e a separação está no sistema de
arquivos (`art/brp/`), não só num documento, porque um documento não impede
ninguém de arrastar um PNG.

## 2. O que foi criado

| Caminho | O que é | Fase |
|---|---|---|
| `docs/BRP_SPATIAL_CONTRACT.md` | O contrato espacial — escrito a partir do que o código já fazia | 1 |
| `blender/brp_studio.py` | O estúdio compartilhado | 2 |
| `blender/brp_terreno.py` · `brp_porto.py` · `brp_cidade.py` · `brp_fauna.py` | Os quatro catálogos | 3–6 |
| `blender/gerar_brp.py` | Roda um estúdio, exporta, grava o `.blend`, junta o manifest | 8 |
| `blender/validate_brp_assets.py` | Validação do lado do Blender | 12 |
| `brport_vs/data/assets/BRP_EXPORT_MANIFEST.json` | O manifest | 8 |
| `docs/BRP_ASSET_INVENTORY.json` | Inventário, separando referência de produção | 0 |
| `brport_vs/art/props/` (6 novos) | Props do porto — candidatos ao jogo | 4 |
| `brport_vs/art/brp/` (9) | Terreno, cidade e fauna — fora do VS | 3, 5, 6 |
| `brport_vs/scenes/tests/AssetPlacementTest.tscn` + `.gd` | Cena de encaixe | 11 |
| `brport_vs/tools/capturar_cena.gd` | Captura de uma cena qualquer | — |
| `brport_vs/scripts/validation/asset_validator.gd` | Validação do lado do Godot | 12 |
| `brport_vs/tests/teste_design.gd` | **Ampliado**, não substituído: caso D8 | 12 |
| `.github/workflows/testes.yml` | Passo novo: valida os assets a cada push | 12 |

## 3. Onde eu me afastei do prompt, e por quê

O prompt pede para adaptar ao projeto real e justificar. Quatro desvios:

**1. Não criei uma quinta arquitetura de estúdio.** `tools/gerar_props_iso.py`
já era o `BRP_PortAssetsStudio` — câmera no contrato, rig de três pontos,
paleta, kit de detalhe, sombra de contato e autoverificação da projeção.
`brp_studio.py` **importa** de lá. Uma segunda câmera "quase igual" era o risco
nº 1 da auditoria do pacote, e a divergência só apareceria quando um prop novo
caísse 40px fora do chão.

**2. Não adotei a célula de 128×128 ortogonal.** O projeto tem grade, é
isométrica 2:1, e o próprio prompt prevê a exceção. O que faltava ao guia do
pacote era **um número**: ele fixa a câmera em `Z = 45°` e não fixa o X. Com
`ROT_X = 60°` o pipeline dele cai no mapa sem ajuste — está no §1 do contrato
espacial.

**3. Não migrei o terreno para `TileMapLayer`.** O chão do jogo é um SVG com
costa em degraus, enrocamento, malha viária e números em estêncil, e o teste de
design verifica-o. Os tiles que produzi servem à cena de teste. O guia de mapa
da Parte 04 pede exatamente as peças que esse SVG já desenha — foi escrito
contra um estado anterior do projeto.

**4. Os `.blend` NÃO entram no Git.** Contraria a FASE 13. São 3,7 MB de
binário que ninguém consome — o Godot carrega PNG — e saem em segundos de
`gerar_brp.py`. Versioná-los ao lado do Python que os monta criaria duas fontes
para a mesma coisa, e uma envelheceria em silêncio. A justificativa está em
`blender/.gitignore`. **Se preferir que entrem, é uma linha.**

## 4. O que NÃO foi feito

Não está pronto, e não vou dizer que está:

| Fase | O que falta | Por quê |
|---|---|---|
| 7 — animações | Nenhum ciclo produzido. `wind_idle`, `bob`, `fly`, `rotate_lift` estão declarados no manifest e não existem | Precisa de folha de frames com célula e origem constantes; é trabalho de uma sessão inteira, e nenhum asset animado entra no VS |
| 8 — GLB | Só PNG | O jogo é 2D e não carrega GLB. Exportá-los seria produzir arquivo que nada abre |
| 10 — `CityView.tscn` | Não existe | A cidade panorâmica é conteúdo `VS — OUT`. Fazer a janela sem a cidade seria moldura sem quadro |
| 3 — atlas de terreno | Tiles avulsos, sem atlas | Atlas serve `TileMapLayer`, que não foi adotado |
| 4/5 — catálogo completo | 15 assets, não os ~60 que o prompt lista | Cada um é meia hora de kit. O que precisava ser provado era o PIPELINE e os quatro tipos de âncora; o resto é o mesmo laço |

## 5. Como rodar tudo

```sh
pip install "bpy==4.5.13"                          # precisa de Python 3.11
python3 blender/gerar_brp.py todos brport_vs/art/props
python3 blender/validate_brp_assets.py

G=/tmp/godot/Godot_v4.6.1-stable_linux.x86_64
$G --headless --path brport_vs --import
$G --headless --path brport_vs --script res://scripts/validation/asset_validator.gd
$G --headless --path brport_vs --script res://tests/teste_design.gd

xvfb-run -a $G --path brport_vs --resolution 720x1280 --rendering-driver opengl3 \
  --script res://tools/capturar_cena.gd -- \
  res://scenes/tests/AssetPlacementTest.tscn encaixe.png
```

⚠️ `gerar_brp.py todos` escreve por cima dos PNGs em `art/props/`. Os seis
props do porto são a saída dele; os props ANTIGOS (píer, guindaste, barcos,
prédios) continuam sendo de `tools/gerar_props_iso.py` e não são tocados.

## 6. O que a próxima sessão deve saber

1. **A projeção agora tem quatro participantes.** O caso D8 do teste de design
   guarda isso a cada push.
2. **O conferidor de lote só opina quando as duas arestas do apoio concordam.**
   Um casco de barco dá 42° e está certo. Ver `tools/conferir_lote_de_arte.py`.
3. **A gaivota é o teto do método**, não uma peça mal-acabada. Quem a for
   refazer, comece por textura num plano.
4. **Isto não muda a fila do plano v3.** A1 — a build no telefone — continua
   sendo o próximo item, e continua sendo o gate mais adiado do projeto.
