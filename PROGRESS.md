# Storico del progetto

## 27 settembre 2026: versione 1, `/parla`

- [x] Ricerca: AgentVibes, VoiceMode, claude-code-tts, claude-read-aloud letti nel codice.
      Nessuno fa «riassunto a voce solo a comando»; AgentVibes e il plugin VoiceMode restano sempre accesi.
- [x] Audizione di 4 voci locali (Kokoro, Qwen3-TTS, Chatterbox, Voxtral) sulla stessa frase.
      Scelta Kokoro, voce Sara: la più veloce (6 secondi) e licenza libera.
- [x] Piano rivisto da Codex in tre giri: 12 rilievi, tutti verificati e integrati, poi nessuna obiezione.
- [x] `parla`, skill `/parla`, `install.sh` con versioni fissate (`requirements.txt`).
- [x] 7 prove automatiche passate (`prove.sh`), più una controprova: senza la fila, la prova della fila fallisce.
- [x] Prova completa con una sessione vera di Claude Code: riassunto di 75 parole, fedele, nessuna richiesta di permesso.

### Cose imparate
- mlx-audio esce con «tutto ok» anche quando fallisce: si controlla il file audio, non il codice d'uscita.
- Kokoro in italiano taglia in silenzio le frasi oltre 510 fonemi: `parla` lo intercetta e non legge audio a metà.
- eSpeak (la pronuncia italiana) non trova i suoi dati se il percorso supera 159 caratteri.
- Un comando lanciato in sottofondo da uno script ignora Ctrl+C: nelle prove serve riattivarlo.
- Dopo il comando, Claude aggiunge quasi sempre una riga di conferma: la regola ora la ammette.

### Aperto
- [x] Prova di Gionata in una sua sessione vera: «sembra ok».
- [x] Revisione finale di Codex sul ramo: 4 rilievi, tutti corretti (parola di chiusura del testo più rara,
      lucchetto nella cartella privata dell'utente, controllo delle cartelle prima di installare, prova più severa).
- [x] Merge in main e pubblicazione su GitHub, con OK di Gionata.

## Dopo (se serve)
- `/parliamo`: conversazione a voce, con VoiceMode.
- Pacchetto plugin installabile con un comando.
- Video per LinkedIn e immagine di anteprima della repo.
