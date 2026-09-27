#!/bin/bash
# claude-parla: installazione. Rilanciabile senza danni.
# https://github.com/ilGionny/claude-parla
set -euo pipefail

FIRMA="claude-parla"
QUI="$(cd "$(dirname "$0")" && pwd)"
VENV="$HOME/.local/share/claude-parla/venv"
BIN="$HOME/.local/bin"
SKILL="$HOME/.claude/skills/parla"

ferma() { echo "✗ $*" >&2; exit 1; }
ok() { echo "✓ $*"; }

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] \
  || ferma "serve un Mac con chip Apple (M1 o successivi): mlx-audio gira solo lì"
command -v uv >/dev/null \
  || ferma "manca uv. Installalo con:  curl -LsSf https://astral.sh/uv/install.sh | sh"

# eSpeak, che fa la pronuncia italiana, non trova i suoi dati oltre 159 caratteri di percorso.
dati="$VENV/lib/python3.12/site-packages/espeakng_loader/espeak-ng-data"
[ ${#dati} -lt 160 ] || ferma "percorso troppo lungo per eSpeak (${#dati} caratteri): $dati"

# Non toccare file che non sono nostri.
nostro() { [ ! -e "$1" ] || grep -q "$FIRMA" "$1"; }
nostro "$BIN/parla" || ferma "esiste già $BIN/parla e non è di $FIRMA: non lo tocco"
nostro "$SKILL/SKILL.md" || ferma "esiste già la skill $SKILL e non è di $FIRMA: non la tocco"

echo "Installo il motore voce in $VENV ..."
[ -x "$VENV/bin/python" ] || uv venv -q --python 3.12 "$VENV"
uv pip install -q --python "$VENV/bin/python" -r "$QUI/requirements.txt"
ok "motore voce (mlx-audio + Kokoro), versioni collaudate"

mkdir -p "$BIN" "$SKILL"
install -m 755 "$QUI/parla" "$BIN/parla"
install -m 644 "$QUI/skills/parla/SKILL.md" "$SKILL/SKILL.md"
ok "comando parla in $BIN"
ok "skill /parla in $SKILL"

case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "! $BIN non è nel PATH. Aggiungi questa riga al tuo ~/.zshrc e riapri il terminale:"
     echo "  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo "Prima prova: la prima volta scarica la voce (circa 330 MB), poi parla..."
"$BIN/parla" "Installazione completata. In Claude Code, dopo una risposta, scrivi barra parla."
ok "fatto. Apri una nuova sessione di Claude Code e scrivi /parla dopo una risposta."
