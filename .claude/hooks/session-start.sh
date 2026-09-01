#!/usr/bin/env bash
#
# Arranque de sessão do BR Port (item B1 da fila do Plano v3).
#
# A dor que isto resolve está escrita no CLAUDE.md: DUAS rodadas inteiras de
# trabalho visual foram feitas às cegas porque ninguém sabia que o Godot rodava
# dentro do contêiner. A receita estava no CLAUDE.md e mesmo assim foi
# esquecida — documentar não bastou, então agora a máquina executa.
#
# O que fica de fora, de propósito:
#
#   bpy (Blender como biblioteca) — ~1 GB e minutos de instalação, e só faz
#   falta em sessão de ARTE. Pagar isso em toda sessão para o usar numa em
#   cada dez é o oposto de arranque rápido. Fica sob demanda:
#       pip install "bpy==4.5.0"
#
#   xvfb — só a captura de tela precisa de contexto gráfico, e o xvfb-run já
#   vem no contêiner. Teste e import rodam sem tela.
#
# NUNCA falha a sessão. Se a rede cair no meio do download, o hook avisa e
# devolve a receita manual em vez de deixar a sessão morrer no arranque: uma
# sessão sem Godot ainda serve para ler código e escrever documento.
set -uo pipefail

RAIZ="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# Só no contêiner das sessões remotas. Na máquina do Bruno (Windows, com o
# editor aberto) baixar um binário Linux não ajudaria nada.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# A versão vive num arquivo só, lido também pelo CI (.github/workflows/testes.yml).
# Antes deste arquivo existir, o CLAUDE.md mandava baixar a 4.6.1 e o CI rodava
# a 4.6.3 — a sessão testava numa versão e o PR era barrado noutra.
VERSAO=""
[ -r "$RAIZ/.godot-version" ] && VERSAO="$(tr -d '[:space:]' < "$RAIZ/.godot-version")"
if [ -z "$VERSAO" ]; then
  echo "BR Port: .godot-version ausente ou ilegível — o Godot não foi preparado."
  exit 0
fi

DESTINO="$HOME/godot-bin"                       # mesmo caminho que o CI usa
BIN="$DESTINO/Godot_v${VERSAO}-stable_linux.x86_64"

receita_manual() {
  echo "BR Port: o Godot NÃO está pronto — $1."
  echo "  Para preparar à mão (a receita completa está no CLAUDE.md):"
  echo "    curl -fsSL --retry 3 -o /tmp/godot.zip https://github.com/godotengine/godot/releases/download/${VERSAO}-stable/Godot_v${VERSAO}-stable_linux.x86_64.zip"
  echo "    mkdir -p $DESTINO && unzip -q -o /tmp/godot.zip -d $DESTINO && chmod +x '$BIN'"
  echo "    '$BIN' --headless --path brport_vs --import"
}

# Idempotente: o contêiner guarda o estado depois do hook, então na segunda
# sessão isto não baixa nada.
if [ ! -x "$BIN" ]; then
  mkdir -p "$DESTINO"
  # O -f não é enfeite: sem ele o curl grava a página de erro 404 do GitHub
  # em /tmp/godot.zip, sai com 0, e quem descobre o problema é o unzip lá
  # embaixo — com uma parede de texto que vai parar no contexto da sessão.
  if ! curl -fsSL --retry 3 -o /tmp/godot.zip \
       "https://github.com/godotengine/godot/releases/download/${VERSAO}-stable/Godot_v${VERSAO}-stable_linux.x86_64.zip"; then
    receita_manual "o download falhou (versão ${VERSAO} inexistente, ou a rede)"
    exit 0
  fi
  # stderr calado: a mensagem útil é a nossa, não a do unzip.
  if ! unzip -q -o /tmp/godot.zip -d "$DESTINO" 2>/dev/null; then
    receita_manual "o zip veio corrompido"
    exit 0
  fi
  rm -f /tmp/godot.zip
  chmod +x "$BIN" 2>/dev/null || true
fi

if [ ! -x "$BIN" ]; then
  receita_manual "o binário não apareceu onde devia"
  exit 0
fi

# --import NÃO é opcional. Num clone novo não existe brport_vs/.godot (é
# ignorado pelo Git), e sem ela a suíte falha com uma pilha de
# "referenced non-existent resource" que não tem nada a ver com o que se está
# testando. Já mandou gente depurar o teste errado.
IMPORT_OK=1
if ! "$BIN" --headless --path "$RAIZ/brport_vs" --import >/tmp/brport_import.txt 2>&1; then
  IMPORT_OK=0
fi

# Deixa o $G pronto para as receitas do CLAUDE.md, que são todas escritas com ele.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export GODOT=\"$BIN\""
    echo "export G=\"$BIN\""
  } >> "$CLAUDE_ENV_FILE"
fi

if [ "$IMPORT_OK" -eq 1 ]; then
  echo "BR Port pronto: Godot ${VERSAO} em \$G ($BIN), projeto importado — a suíte roda já nesta primeira mensagem."
else
  echo "BR Port: Godot ${VERSAO} em \$G ($BIN), mas o --import falhou (veja /tmp/brport_import.txt). Rode-o antes de qualquer teste."
fi
echo "  Suítes: \$G --headless --path brport_vs --script res://tests/{run_tests,teste_design,teste_audio,teste_fumaca}.gd e res://scripts/validation/asset_validator.gd"
echo "  Blender (bpy, ~1 GB) fica SOB DEMANDA, fora do arranque: pip install \"bpy==4.5.0\" — só faz falta em sessão de arte."
