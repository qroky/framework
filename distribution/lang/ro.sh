#!/usr/bin/env bash
# lang/ro.sh — Romanian strings for distribution/install.sh
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Substance-identical to lang/en.sh — same 7 steps, same information, same
# order. No method jargon (atom, verify, FEV, DoD, gate). Plain words only.

L_SETUP_TITLE() { printf '== Instalare Qroky ==\n'; }

L_STEP_HEADER() { printf 'Pasul %s din 7 — %s\n' "$1" "$2"; }
L_STEP_ALREADY_DONE() { printf '  deja configurat — nimic de făcut (verificare de sănătate)\n'; }

L_STEP_LANGUAGE_NAME() { printf 'alege limba'; }
L_STEP_WORKDIR_NAME() { printf 'alege folderul de lucru'; }
L_STEP_CLAUDE_NAME() { printf 'verifică asistentul Claude Code'; }
L_STEP_SUBSCRIPTION_NAME() { printf 'verifică abonamentul'; }
L_STEP_TELEGRAM_NAME() { printf 'conectează Telegram (opțional)'; }
L_STEP_TELEMETRY_NAME() { printf 'partajarea sprijinului zilnic (opțional)'; }
L_STEP_HEARTBEAT_NAME() { printf 'rezumatul de dimineață (opțional)'; }

L_ASK_LANGUAGE() {
  printf 'Ce limbă dorești să folosești?\n'
  printf '  1) English (en)\n  2) Română (ro)\n  3) Русский (ru)\n'
  printf 'Scrie 1, 2, 3, sau codul (en/ro/ru): '
}
L_LANGUAGE_SET() { printf '  limbă setată: %s\n' "$1"; }

L_ASK_WORKDIR() {
  printf 'Unde ar trebui să stea folderul tău privat Qroky?\n'
  printf 'Apasă Enter pentru folderul sugerat, sau scrie o altă cale.\n'
  printf 'Sugerat: %s\n' "$1"
  printf '> '
}
L_WORKDIR_SET() { printf '  folder de lucru: %s\n' "$1"; }
L_WORKDIR_ALREADY() { printf '  acest folder este deja spațiul tău Qroky — îl refolosim\n'; }

L_CLAUDE_FOUND() { printf '  Claude Code — găsit (%s)\n' "$1"; }
L_CLAUDE_MISSING() {
  printf 'Asistentul Claude Code nu este instalat pe acest calculator.\n'
  printf 'Instalează-l, apoi rulează din nou acest instalator — continuă chiar de aici.\n'
  printf '  Instrucțiuni: https://claude.com/claude-code\n'
}

L_SUBSCRIPTION_OK() { printf '  abonament/conectare — pare activ\n'; }
L_SUBSCRIPTION_SOFT_NOTICE() {
  printf 'NOTĂ: nu am putut confirma automat un abonament/conectare activă.\n'
  printf 'E doar o atenționare, nu o oprire — dacă "claude" deja funcționează,\n'
  printf 'poți ignora. Dacă nu: rulează "claude" o dată și urmează pașii lui de\n'
  printf 'conectare, apoi continuă.\n'
}

L_TELEGRAM_ASK_OPTIN() {
  printf 'Vrei un rezumat de dimineață și actualizări prin Telegram?\n'
  printf 'Acest pas este opțional — poți sări peste el și îl adaugi mai târziu.\n'
  printf 'Da/nu (y/n), implicit n: '
}
L_TELEGRAM_SKIPPED() { printf '  Telegram — omis, îl poți adăuga mai târziu rulând din nou acest instalator\n'; }
L_TELEGRAM_WALKTHROUGH() {
  cat <<'EOF'
  Hai să creăm propriul tău bot de Telegram — durează aproximativ 2 minute:
    1. Deschide aplicația Telegram.
    2. În bara de căutare, scrie: BotFather (are un check albastru).
    3. Deschide conversația cu BotFather și trimite: /newbot
    4. Îți va cere un nume — scrie orice îți place (ex: "My Qroky").
    5. Îți va cere un username — trebuie să se termine în "bot" (ex: "my_qroky_bot").
    6. BotFather răspunde cu un mesaj ce conține un cod lung — acesta este
       TOKEN-ul botului tău. Arată așa: 123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ
    7. Copiază tot codul.
EOF
}
L_TELEGRAM_ASK_TOKEN() { printf 'Lipește token-ul aici (sau scrie "skip" pentru a sări peste): '; }
L_TELEGRAM_VALIDATING() { printf '  verific token-ul cu Telegram...\n'; }
L_TELEGRAM_TOKEN_OK() { printf '  token-ul funcționează — conectat la botul: %s\n' "$1"; }
L_TELEGRAM_TOKEN_BAD() {
  printf '  acel token nu a funcționat. Cauze frecvente:\n'
  printf '    - s-a copiat un spațiu sau o linie nouă odată cu el — copiază din nou, atent\n'
  printf '    - a fost deja resetat — deschide BotFather, trimite /token, folosește noul token\n'
  printf '  Încearcă din nou, sau scrie "skip" pentru a sări peste acest pas.\n'
}
L_TELEGRAM_STORED() { printf '  token salvat doar pe acest calculator (nu e trimis nicăieri altundeva): %s\n' "$1"; }

L_TELEMETRY_ASK_OPTIN() {
  cat <<'EOF'
Partajarea sprijinului zilnic — înainte de a întreba, iată EXACT ce ar pleca
de pe acest calculator, în cuvinte simple: jurnale scurte de progres și
rezumate de cost despre CUM a mers munca (niciodată CE construiești — fără
cod, fără specificații, fără conținutul produsului). Poți citi lista exactă
și scriptul care le trimite oricând la: distribution/README.<lang>.md,
secțiunea "Ce pleacă de pe acest calculator".
EOF
  printf 'Activezi partajarea sprijinului zilnic? Da/nu (y/n), implicit n: '
}
L_TELEMETRY_ON() { printf '  partajarea sprijinului zilnic — PORNITĂ\n'; }
L_TELEMETRY_OFF() { printf '  partajarea sprijinului zilnic — OPRITĂ (nimic nu se trimite cât timp rămâne oprită)\n'; }

L_HEARTBEAT_ASK_OPTIN() {
  cat <<'EOF'
Rezumatul de dimineață — un mesaj scurt zilnic: ce s-a făcut, ce te așteaptă.
Da/nu acum, te poți răzgândi mai târziu. O linie sinceră despre cum
funcționează: doar CITEȘTE spațiul tău de lucru pentru a construi rezumatul —
nu ia niciodată acțiuni singur și nu trimite nimic nicăieri, în afară de
acest rezumat, către tine. Recomandat: da.
EOF
  printf 'Activezi rezumatul de dimineață? Da/nu (y/n), implicit y: '
}
L_HEARTBEAT_ON() { printf '  rezumatul de dimineață — instalat și PORNIT\n'; }
L_HEARTBEAT_OFF() { printf '  rezumatul de dimineață — instalat dar OPRIT. Îl pornești oricând cu:\n      bash install.sh --enable-heartbeat\n'; }
L_HEARTBEAT_NO_LAUNCHD() {
  printf 'NOTĂ: acest calculator nu are "launchctl" (frecvent în afara macOS), deci\n'
  printf 'rezumatul de dimineață nu poate fi programat automat. Nimic altceva nu a\n'
  printf 'eșuat — rulează-l manual oricând cu: bash %s/.qroky/heartbeat.sh\n' "$1"
}

L_FINALE() {
  cat <<EOF

== Instalare terminată. Nimic nu a eșuat. ==

Asistentul tău e gata. Ca să începi:
  1. Deschide un terminal în: $1
  2. Scrie: claude
  3. Spune: qroky start

Această singură frază — "qroky start" — este tot ce ai nevoie; funcționează
în orice limbă o scrii.
EOF
}

L_FAIL_HEADER() { printf '\nINSTALARE OPRITĂ.\n'; }
L_FAIL_FOOTER() {
  printf '\nNimic nu s-a schimbat pe ascuns — mesajul de mai sus e toată povestea.\n'
  printf 'Repară acel lucru, apoi rulează din nou acest instalator; continuă chiar de aici.\n'
}
L_RETRYING() { printf '  nu a mers — încerc din nou automat (încercarea %s din 2)...\n' "$1"; }

L_UPDATE_AVAILABLE() {
  local from="$1" to="$2" changelog="$3"
  cat <<EOF
O versiune nouă a regulilor pe care le urmează asistentul tău este disponibilă: $from -> $to
Ce se îmbunătățește pentru tine:
$changelog
Ca să accepți acum:  bash install.sh --apply-update
Ca să vezi mai mult:  bash install.sh --show-update-details
Ca să decizi mai târziu: nu face nimic — vei vedea din nou acest mesaj data viitoare
EOF
}
L_UPDATE_NONE() { printf '  nicio actualizare disponibilă — ești pe ultima versiune\n'; }
L_UPDATE_CONFLICT() {
  printf '\nCopia ta are schimbări locale pe care actualizarea le-ar atinge. Nimic nu a\n'
  printf 'fost suprascris. Iată exact ce diferă:\n'
}
L_UPDATE_ASK_CONFIRM() { printf 'Aplici această actualizare acum? Scrie "da" pentru confirmare, orice altceva anulează: '; }
L_UPDATE_APPLIED() { printf '  actualizare aplicată: %s -> %s. O înregistrare a fost scrisă la: %s\n' "$1" "$2" "$3"; }
L_UPDATE_CANCELLED() { printf '  actualizare anulată — nimic nu s-a schimbat\n'; }
