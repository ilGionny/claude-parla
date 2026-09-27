#!/bin/bash
# claude-parla: prove del comando `parla`. Suonano davvero: volume basso.
# Uso: ./prove.sh   (prova il parla installato; PARLA=./parla ./prove.sh per quello della cartella)
set -u
P="${PARLA:-$HOME/.local/bin/parla}"
falliti=0

prova() { # prova "nome" funzione
  if "$2"; then echo "✓ $1"; else echo "✗ $1"; falliti=$((falliti + 1)); fi
}
voci_di() { pgrep -P "$1" -x afplay | wc -l | tr -d ' '; }   # afplay figli di quel parla
aspetta_voce() { for _ in $(seq 100); do [ "$(voci_di "$1")" -gt 0 ] && return 0; sleep 0.1; done; return 1; }
nessuna_voce() { ! pgrep -x afplay >/dev/null; }

t_testo_difficile() {
  "$P" <<'FINE'
Prova uno. L'email di "Mario" costa $5, e `niente` si rompe.
FINE
}

t_voce_sbagliata() {
  local out
  out=$(PARLA_VOCE=if_nessuna "$P" "ciao" 2>&1) && return 1
  [[ "$out" == *"non è stata generata"* ]]
}

t_frase_troppo_lunga() {
  local lunga out
  lunga="Questa frase $(printf 'continua ancora e ancora senza fermarsi mai, %.0s' {1..15})ma alla fine c'è un se decisivo."
  out=$("$P" "$lunga" 2>&1) && return 1
  [[ "$out" == *"frase troppo lunga"* ]] && nessuna_voce
}

t_due_tab_in_fila() {
  local a b n max=0
  "$P" "Prova due. Prima voce." & a=$!
  "$P" "Seconda voce. Arrivo dopo." & b=$!
  while kill -0 "$a" 2>/dev/null || kill -0 "$b" 2>/dev/null; do
    n=$(( $(voci_di "$a") + $(voci_di "$b") ))
    [ "$n" -gt "$max" ] && max=$n
    sleep 0.1
  done
  wait "$a" && wait "$b" && [ "$max" -eq 1 ]
}

t_stop_durante_generazione() {
  local a rc
  "$P" "Questa frase non deve mai essere pronunciata." & a=$!
  sleep 1; kill -TERM "$a"; wait "$a"; rc=$?
  sleep 6   # il tempo in cui avrebbe parlato
  [ "$rc" -eq 130 ] && nessuna_voce
}

t_stop_durante_attesa_turno() {
  local a b rc
  "$P" "Prova tre. Io parlo fino alla fine, anche se l'altra richiesta viene fermata mentre aspetta." & a=$!
  aspetta_voce "$a" || return 1
  "$P" "Questa frase non deve mai essere pronunciata." & b=$!
  local in_attesa=0
  for _ in $(seq 150); do pgrep -P "$b" -x lockf >/dev/null && { in_attesa=1; break; }; sleep 0.1; done
  if [ "$in_attesa" -eq 0 ]; then   # non ha mai raggiunto l'attesa del turno: la prova non vale
    kill -TERM "$b" 2>/dev/null; wait "$b"; wait "$a"; return 1
  fi
  kill -TERM "$b"; wait "$b"; rc=$?
  [ "$rc" -eq 130 ] && [ "$(voci_di "$a")" -eq 1 ] && wait "$a" && nessuna_voce
}

t_stop_durante_voce() {
  local a rc
  # Un comando lanciato con & da uno script ignora Ctrl+C (INT) e non può riattivarlo:
  # perl lo riattiva, come quando parla gira in primo piano nell'uso vero.
  perl -e '$SIG{INT}="DEFAULT"; exec @ARGV' "$P" \
    "Prova quattro. Questa frase viene interrotta a metà, e poi il turno torna libero." & a=$!
  aspetta_voce "$a" || return 1
  sleep 1; kill -INT "$a"; wait "$a"; rc=$?
  sleep 0.5
  [ "$rc" -eq 130 ] && nessuna_voce && "$P" "Turno libero."
}

nessuna_voce || { echo "C'è già un audio in riproduzione: aspetta che finisca e rilancia."; exit 1; }
if [ $# -gt 0 ]; then prova "$1" "$1"; exit "$falliti"; fi   # ./prove.sh t_nome: una prova sola
prova "testo con apostrofi, virgolette, dollaro e backtick" t_testo_difficile
prova "voce inesistente: errore chiaro, nessun audio" t_voce_sbagliata
prova "frase troppo lunga: errore, nessun audio a metà" t_frase_troppo_lunga
prova "due tab insieme: mai due voci contemporanee" t_due_tab_in_fila
prova "fermata durante la generazione: non parla più tardi" t_stop_durante_generazione
prova "fermata in attesa del turno: l'altra continua" t_stop_durante_attesa_turno
prova "fermata mentre parla: voce spenta, turno libero" t_stop_durante_voce
if [ "$falliti" -eq 0 ]; then echo "Tutte le prove passate."; else echo "Prove fallite: $falliti"; exit 1; fi
