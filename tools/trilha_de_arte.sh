#!/usr/bin/env bash
# BR Port — a bateria de capturas em CADA ponto da história que tocou em arte.
#
# POR QUE ISTO EXISTE. O gate A5 do plano v3 divide-se em duas metades: a
# máquina captura, o Bruno olha. O workflow da captura já dá o antes/depois de
# UM PR contra a sua base; o que faltava era a trilha inteira num sítio só —
# "olhar cada antes/depois" das seis etapas de arte, da frota, do gradiente, da
# costa e do resto, sem caçar artefato a artefato por trinta corridas de CI.
#
# ⚠️ O `.godot` É APAGADO ENTRE PONTOS, e não é zelo. O Godot desenha o `.ctex`
# de `.godot/imported/`, e um import reaproveitado mostra a arte do ponto
# ANTERIOR sem erro nenhum — é a regra que o CLAUDE.md já carrega para a
# captura, e aqui ela decidiria a trilha inteira em vez de uma foto.
#
# ⚠️ E O SCRIPT DE CADA PONTO É O DAQUELE PONTO (`/tmp/<wt>/tools/...`), nunca o
# de hoje: a bateria cresceu de 5 fotos para 14 pelo caminho, e o script de hoje
# apontado a um projeto antigo morre a pedir uma folha de contato que lá não
# existe. É a mesma lição que o `captura.yml` tem escrita ao lado do worktree.
#
# A trilha começa em 21e428d (02/09), que é o primeiro commit em que a captura
# passou a ser reprodutível — antes dele não há `--semente=` nem `--fixed-fps`,
# e cada corrida daria outro porto e outra fase das animações.
#
# Uso:  tools/trilha_de_arte.sh <pasta-de-saida> [godot]
# Depois: python3 tools/trilha_de_arte.py <pasta-de-saida>
set -u

SAIDA="${1:?uso: tools/trilha_de_arte.sh <pasta-de-saida> [godot]}"
V=$(tr -d '[:space:]' < "$(dirname "$0")/../.godot-version")
G="${2:-$HOME/godot-bin/Godot_v${V}-stable_linux.x86_64}"
RAIZ=$(cd "$(dirname "$0")/.." && pwd)
PRIMEIRO=21e428d
WT=/tmp/trilha_wt

cd "$RAIZ" || exit 1

# ⚠️ O CLONE DE UMA SESSÃO REMOTA CHEGA RASO — medido em 23/09: 184 commits,
# até 03/09 —, e sem o PRIMEIRO o `git log` abaixo morre com "unknown
# revision" e deixa um `pontos.txt` VAZIO, que o `-s` a seguir não refaz.
if ! git rev-parse --verify -q "${PRIMEIRO}^{commit}" >/dev/null; then
  echo "o commit $PRIMEIRO não está neste clone (raso?):" \
       "git fetch --unshallow origin main" >&2
  exit 1
fi
mkdir -p "$SAIDA"

# Os pontos: todo commit da linha principal, do PRIMEIRO para cá, que tenha
# tocado em algo que o render vê. Sai do git, não de uma lista à mão — uma
# lista à mão envelhece calada a cada merge.
# ⚠️ E ELA SÓ SE CALCULA NUMA PASTA NOVA: é o que deixa retomar uma corrida a
# meio. Uma pasta de ontem guarda os pontos de ontem — para a trilha de hoje,
# pasta nova (ou apague o `pontos.txt`).
if [ ! -s "$SAIDA/pontos.txt" ]; then
  git log --first-parent --format="%h|%ad|%s" --date=short "$PRIMEIRO..HEAD" \
    | tac | while IFS='|' read -r h d s; do
      n=$(git diff --name-only "${h}^" "$h" -- brport_vs/art brport_vs/scenes \
            brport_vs/ui brport_vs/scripts tools/gerar_mapa_iso.py \
            tools/gerar_props_iso.py blender 2>/dev/null | wc -l)
      [ "$n" -gt 0 ] && echo "$h|$d|$s"
    done > "$SAIDA/pontos.txt"
  # o ponto de partida entra à cabeça: é o "antes" de tudo o resto
  sed -i "1i $PRIMEIRO|$(git log -1 --format=%ad --date=short $PRIMEIRO)|Ponto de partida: a primeira captura determinística" \
    "$SAIDA/pontos.txt"
fi
total=$(wc -l < "$SAIDA/pontos.txt")

i=0
while IFS='|' read -r h d s; do
  i=$((i + 1))
  [ -f "$SAIDA/$h/.pronto" ] && { echo "[$i/$total] $h já feito"; continue; }
  ini=$(date +%s)
  rm -rf "$WT"
  git worktree prune
  git worktree add --detach "$WT" "$h" >/dev/null 2>&1 \
    || { echo "[$i/$total] $h WORKTREE FALHOU"; continue; }
  rm -rf "$WT/brport_vs/.godot"
  "$G" --headless --path "$WT/brport_vs" --import >/dev/null 2>&1
  rc_i=$?
  mkdir -p "$SAIDA/$h"
  "$WT/tools/capturar_evidencia.sh" "$WT/brport_vs" "$SAIDA/$h" "$G" \
    > "$SAIDA/$h/captura.log" 2>&1
  rc_c=$?
  n=$(ls "$SAIDA/$h"/*.png 2>/dev/null | wc -l)
  echo "[$i/$total] $h $d  import=$rc_i captura=$rc_c  ${n} png  $(( $(date +%s) - ini ))s"
  [ "$rc_c" -eq 0 ] && [ "$n" -gt 0 ] && touch "$SAIDA/$h/.pronto"
done < "$SAIDA/pontos.txt"

rm -rf "$WT"; git worktree prune
echo "=== TRILHA CAPTURADA ==="
