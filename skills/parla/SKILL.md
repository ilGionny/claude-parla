---
name: parla
description: Riassume a voce la tua ultima risposta, con una voce locale sul Mac. Solo quando l'utente scrive /parla.
argument-hint: "[indicazioni facoltative, es. più corto]"
disable-model-invocation: true
allowed-tools: Bash(parla *)
metadata:
  source: https://github.com/ilGionny/claude-parla
---

L'utente vuole ascoltare, non leggere. Scrivi un riassunto parlato della tua **ultima risposta sostanziale**
(se l'ultima era già un riassunto di /parla, usa quella prima) e fallo leggere al comando `parla`.

Indicazioni dell'utente per questo riassunto (se vuote, ignora): $ARGUMENTS

Come scrivere il riassunto:
- Da 3 a 5 frasi, al massimo 80 parole in tutto.
- Frasi corte: al massimo 25 parole ciascuna.
- Apri con il tema o il progetto in 2 o 3 parole, seguite da un punto: chi ascolta può avere più sessioni aperte.
- Completo e fedele: l'esito, i numeri che contano, cosa serve dall'utente. Tieni esatti i valori decisivi, i "non", i "se" e i dubbi. Arrotonda un numero solo se non cambia la decisione.
- Scritto per l'orecchio: niente elenchi, markdown, simboli, emoji, link, percorsi di file o codice.
- Sigle e parole inglesi scritte come si pronunciano in italiano (per esempio "mèpa", "dac dac gou").
- Usa la lingua in cui stai parlando con l'utente.

Poi esegui, con il riassunto al posto dei puntini:

```bash
parla <<'FINE'
...
FINE
```

Dopo il comando, al massimo una riga brevissima: il riassunto l'utente l'ha già sentito.
Se `parla` risponde "frase troppo lunga", riscrivi il riassunto con frasi più corte e riprova una sola volta.
Per ogni altro errore, scrivi all'utente una sola riga con il messaggio.
