#!/usr/bin/env bash
# lang/ro.sh — Romanian strings for distribution/install.sh
#
# Author: pilot-toolsmith (ATOM-101, Distribution Kit v1) · Date: 2026-07-10
# Substance-identical to lang/en.sh — same 7 steps, same information, same
# order. No method jargon (atom, verify, FEV, DoD, gate). Plain words only.

L_SETUP_TITLE() { printf '== Instalare Qroky ==\n'; }

L_STEP_HEADER() { printf 'Pasul %s din 8 — %s\n' "$1" "$2"; }
L_STEP_ALREADY_DONE() { printf '  deja configurat — nimic de făcut (verificare de sănătate)\n'; }

# v0.2 (GATE-027): tot drumul într-un singur paragraf, de la început.
L_JOURNEY_MAP() {
  cat <<'EOF'
Iată tot drumul: 8 întrebări, aproximativ 3 minute de instalare, iar la
final primești două linii gata de copiat și lipit pentru prima conversație.
Fiecare întrebare spune a câta este; cele opționale se sar cu un singur
Enter. Nimic nu se instalează pe la spatele tău.
EOF
}

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

L_FRAMEWORK_VENDORING() { printf '  descarc regulamentul pe care îl urmează asistentul (fixat la o versiune anume, ca să nu se schimbe niciodată fără să te întrebe)...\n'; }
L_FRAMEWORK_ALREADY() { printf '  regulamentul este deja la locul lui — nimic de făcut (verificare de sănătate)\n'; }

# --- v0.1.2 (conectarea frazei de pornire — automat, nu o întrebare) ---
L_GESTURE_WIRING() { printf '  învăț acest folder fraza de pornire ("qroky start")...\n'; }
L_GESTURE_DONE() { printf '  fraza de pornire e conectată — o conversație deschisă ÎN ACEST FOLDER va înțelege "qroky start"\n'; }
L_GESTURE_ALREADY() { printf '  fraza de pornire este deja la locul ei — nimic de făcut (verificare de sănătate)\n'; }

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
  printf 'Enter = sari peste, conectezi mai târziu (o comandă: bash install.sh --enable-telegram).\n'
  printf 'Sau: vrei asistentul pe Telegram — un rezumat de dimineață, noutăți și\n'
  printf 'întrebări pe care ți le poate pune direct pe telefon? Scrie y ca să conectezi acum: '
}
L_TELEGRAM_SKIPPED() { printf '  Telegram — omis. Conectezi oricând cu o singură comandă:\n      bash install.sh --enable-telegram\n'; }
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

# --- v0.2 (GATE-027 «am dat cheia — botul a răspuns»): bucla se închide în întrebarea 5 ---
L_TELEGRAM_PRESS_START() {
  printf '  Acum deschide botul tău în Telegram — @%s — și apasă Start\n' "$1"
  printf '  (sau trimite-i orice mesaj). Îl aștept aici, până la %s secunde...\n' "$2"
}
L_TELEGRAM_BOUND() { printf '  te-am prins — Telegram-ul tău este acum legat de acest asistent (doar chat-ul TĂU va fi servit)\n'; }
L_TG_HELLO_TEXT() { printf 'Sunt conectat. Mâine dimineață îți trimit primul rezumat. Important: doar conversațiile NOI văd ce tocmai s-a instalat — deschide o conversație Claude Code nouă în %s și spune «qroky start». — Qroky' "$1"; }
L_TELEGRAM_HELLO_SENT() { printf '  botul tocmai ți-a scris înapoi — uită-te pe telefon\n'; }
L_TELEGRAM_HELLO_FAILED() {
  printf '  legătura e stabilită, dar salutul nu a putut fi trimis chiar acum (adesea o\n'
  printf '  problemă de rețea) — botul te va găsi la următorul mesaj programat.\n'
}
L_TELEGRAM_NO_START() {
  printf '  nimeni nu a apăsat Start în timpul așteptării — e în regulă, nimic nu s-a stricat.\n'
  printf '  Token-ul tău e salvat; botul se conectează mai târziu cu o singură comandă:\n'
  printf '      bash install.sh --enable-telegram\n'
  printf '  Instalarea continuă.\n'
}
L_TELEGRAM_HEAD_MISSING() {
  printf '  fișierele asistentului Telegram nu sunt în regulamentul descărcat (versiunea\n'
  printf '  lui e mai veche decât acest instalator). Token-ul și legătura sunt salvate. Încearcă:\n'
  printf '      qroky update   apoi: bash install.sh --enable-telegram\n'
  printf '  Instalarea continuă.\n'
}
L_TELEGRAM_DEPLOYING() { printf '  conectez botul la acest calculator (verificare la fiecare 30 de secunde; rezumat zilnic la 09:05)...\n'; }
L_TELEGRAM_DEPLOYED() { printf '  asistentul Telegram — PORNIT (ascultător la fiecare 30 s, rezumat zilnic la 09:05; fișierele lui stau în .qroky/telegram/ din spațiul tău de lucru)\n'; }
L_TELEGRAM_LISTENER_OK() { printf '  prima trecere a ascultătorului — sănătoasă\n'; }
L_TELEGRAM_LISTENER_WARN() {
  printf '  NOTĂ: prima trecere a ascultătorului a raportat o problemă (detaliile sunt\n'
  printf '  salvate în jurnalul de instalare). Sarcinile programate rămân instalate și vor încerca în continuare.\n'
}
L_TELEGRAM_SCHEDULE_FAILED() {
  printf '  NOTĂ: sarcinile Telegram nu au putut fi programate automat acum.\n'
  printf '  Tot restul e în regulă — legătura cu botul e salvată. Încearcă mai târziu:\n'
  printf '      bash install.sh --enable-telegram\n'
}
L_TELEGRAM_NO_LAUNCHD() {
  printf 'NOTĂ: acest calculator nu are "launchctl" (frecvent în afara macOS), deci\n'
  printf 'sarcinile Telegram nu pot fi programate automat. Legătura e stabilită — rulează\n'
  printf '%s/run-listener.sh la fiecare 30 s și %s/run-digest.sh zilnic cu propriul tău planificator.\n' "$1" "$1"
}

L_TELEMETRY_ASK_OPTIN() {
  cat <<'EOF'
Partajarea sprijinului zilnic — înainte de a întreba, iată EXACT ce ar pleca
de pe acest calculator dacă spui da. Lista completă — nimic altceva nu este
citit vreodată:
  1. fișierele de progres ale sarcinilor (STATUS.md) — doar cuvântul de
     stare, data și identificatorul sarcinii
  2. rezumatele de cost (RESULT.md)   — DOAR cifrele de cost (timp/unități);
     secțiunile de rezumat și conținut, unde ar fi descris produsul tău, nu
     sunt copiate niciodată
  3. jurnalele de pași (run.log)      — doar marcaje de timp și nume de pași
  4. tabloul de stare (status.yaml)   — o linie per sarcină, notele libere
     sunt eliminate
  5. rezultatele verificărilor independente (VERDICT.md) — doar linia de
     verdict, niciodată textul constatărilor
Propozițiile libere sunt eliminate din fiecare dintre acestea înainte de
copiere. Codul, specificațiile și conținutul produsului tău nu sunt pe
această listă și nu sunt citite niciodată. Notă: un „da" astăzi doar îți
înregistrează alegerea — acest instalator nu instalează niciun mecanism de
trimitere, deci nimic nu poate pleca încă; scriptul de trimitere îți va fi
arătat, linie cu linie, înainte de a fi adăugat vreodată.
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
L_HEARTBEAT_SCHEDULE_FAILED() {
  printf 'NOTĂ: rezumatul de dimineață nu a putut fi programat automat acum.\n'
  printf 'Tot restul s-a terminat cu bine — rezumatul este instalat, dar oprit.\n'
  printf 'Încearcă din nou mai târziu cu:\n      bash install.sh --enable-heartbeat\n'
}

L_FINALE() {
  cat <<EOF

== Instalare terminată. Nimic nu a eșuat. ==

Copiază și lipește asta în terminal:

    cd $1 && claude

apoi spune:

    qroky start

(În VS Code: File → Open Folder → $1 → o conversație nouă — aceeași frază.)

O notă sinceră: la PRIMA pornire, claude îți pune câteva întrebări proprii
(tema de culori, autentificarea) — e normal; răspunde-le și continuă.
Primele tale 5 minute sunt descrise în README-ul de lângă acest instalator
(secțiunea „Primele 5 minute").
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
Ca să accepți acum:  qroky update
Ca să vezi mai mult:  qroky details
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

# --- amendament v0.1.1 (ATOM-102, INFO-030 p.3/p.4): backup + disclaimer ---
L_STEP_BACKUP_NAME() { printf 'copie de rezervă în GitHub-ul tău (opțional)'; }
L_BACKUP_ASK_OPTIN() {
  cat <<'EOF'
Copia de rezervă — păstrează o copie privată, în afara calculatorului, a
spațiului tău de lucru: un calculator pierdut sau stricat nu mai înseamnă
muncă pierdută. O linie sinceră despre unde merge: copia se păstrează în
PROPRIUL TĂU cont privat de GitHub — al nimănui altcuiva; doar tu o poți
vedea. Recomandat: da.
EOF
  printf 'Activezi copia de rezervă? Da/nu (y/n), implicit y: '
}
L_BACKUP_GH_MISSING() {
  printf '  micul program ajutător "gh" (unealta oficială GitHub pentru terminal) nu\n'
  printf '  este pe acest calculator, deci copia de rezervă nu poate fi pregătită acum.\n'
  printf '  Nimic altceva nu este afectat — instalarea continuă fără copia de rezervă.\n'
  printf '  Ca să o adaugi mai târziu:\n'
  printf '    1. Instalează gh: Mac: brew install gh   |   altfel: https://cli.github.com\n'
  printf '    2. Rulează: bash install.sh --enable-backup\n'
}
L_BACKUP_AUTH_WALKTHROUGH() {
  cat <<'EOF'
  Hai să conectăm propriul tău cont GitHub — aproximativ 2 minute, fără
  cunoștințe prealabile (GitHub e un serviciu gratuit pentru păstrarea
  copiilor private ale folderelor; copia ta va fi vizibilă doar ție):
    1. Un asistent de conectare pornește chiar acum, în această fereastră.
    2. Dacă nu ai încă un cont GitHub, îți va oferi să creezi unul —
       gratuit, e nevoie doar de o adresă de email.
    3. Alege "Login with a web browser" când ești întrebat.
    4. Îți arată un cod scurt de unică folosință — copiază-l.
    5. Browserul se deschide; lipește codul acolo și aprobă.
    6. Revino în această fereastră — instalarea continuă singură.
EOF
}
L_BACKUP_AUTH_FAILED() {
  printf '  contul GitHub nu a putut fi conectat de data aceasta. Nimic altceva nu\n'
  printf '  este afectat — instalarea continuă fără copia de rezervă.\n'
  printf '  Ca să încerci din nou mai târziu: bash install.sh --enable-backup\n'
}
L_BACKUP_CREATING() { printf '  creez copia ta privată de rezervă și trimit primul instantaneu...\n'; }
L_BACKUP_DONE() {
  printf '  copia de rezervă e PORNITĂ — o copie privată numită "%s" există acum în contul TĂU GitHub.\n' "$1"
  printf '  Ca să restaurezi pe orice calculator (o singură comandă): gh repo clone %s\n' "$1"
  printf '  (fișierele tale secrete — precum token-ul Telegram — nu sunt niciodată incluse în copie)\n'
}
L_BACKUP_FAILED() {
  printf '  prima copie de rezervă nu a putut fi finalizată (adesea o problemă de rețea).\n'
  printf '  Nimic altceva nu este afectat — instalarea continuă fără copia de rezervă.\n'
  printf '  Ca să încerci din nou mai târziu: bash install.sh --enable-backup\n'
}
L_BACKUP_SKIPPED() {
  printf '  copia de rezervă — oprită, cum ai ales. O pornești oricând cu:\n'
  printf '      bash install.sh --enable-backup\n'
}
L_DISCLAIMER() {
  printf 'O notă despre responsabilitate: sistemul produce ciorne și analize;\n'
  printf 'deciziile și semnăturile juridice, financiare și medicale aparțin\n'
  printf 'întotdeauna omului. Nu constituie consultanță profesională.\n'
}

# --- v0.2 (ATOM-104, GATE-028): întrebarea 9 — fraza de pornire pe tot calculatorul ---
# INFO-042 (2026-07-11): întrebarea 9 eliminată — fraza pe tot calculatorul
# se instalează la fiecare instalare, cu o urmă în loc de întrebare.
L_MACHINEWIDE_WIRING() { printf '  învăț tot acest calculator fraza de pornire (exact două fișiere în ~/.claude; ecranul final le numește împreună cu comanda de eliminare)...\n'; }
L_MACHINEWIDE_ALREADY() { printf '  fraza de pornire pe tot calculatorul este deja la locul ei — nimic de făcut (verificare de sănătate)\n'; }
L_MACHINEWIDE_DONE() {
  printf '  gata — "qroky start" funcționează acum în orice conversație pe acest calculator.\n'
  printf '  Au fost scrise exact două fișiere (ca să le elimini, șterge-le):\n'
  printf '    ~/.claude/skills/qroky/SKILL.md\n'
  printf '    blocul marcat din ~/.claude/CLAUDE.md (între marcajele qroky-machinewide)\n'
}
L_MACHINEWIDE_FAILED() {
  printf '  NOTĂ: configurarea pe tot calculatorul nu a reușit (cel mai adesea: versiunea\n'
  printf '  regulamentului e mai veche decât acest instalator, sau ~/.claude nu poate fi\n'
  printf '  scrisă). Nimic altceva nu e afectat — fraza funcționează în continuare în\n'
  printf '  folderul de lucru; rulează din nou instalatorul oricând ca să încerci iar.\n'
}

# ATOM-111 (router de proiecte): al doilea proiect se alătură botului comun; coada actualizării.
L_TELEGRAM_ALREADY_CONNECTED() {
  printf '  botul tău de Telegram e deja conectat pe acest computer (proiectul principal: %s).\n' "$1"
  printf '  Acest proiect doar S-A ALĂTURAT — același chat, fără al doilea bot, fără întrebări noi.\n'
  printf '  Mesajele de aici vor sosi marcate cu numele acestui proiect.\n'
}
L_TELEGRAM_UPDATE_FINISH_HINT() {
  printf '  actualizarea a adus asistentul Telegram, iar token-ul tău e deja salvat —\n'
  printf '  o singură comandă termină conectarea (așteaptă apăsarea ta pe Start):\n'
  printf '      bash install.sh --enable-telegram\n'
}

# ATOM-105 (pregătire pentru testul curat): șiruri fost EN-hardcode și noi.
L_NO_RELEASE_TAGS() { printf '(încă nu există tag-uri de release — nu avem cu ce compara)\n'; }
L_TOTAL_ELAPSED() { printf '(timp total: %s)\n' "$1"; }
L_UNINSTALL_TITLE() {
  printf 'Foaie curată — șterg tot ce a pus installer-ul pe ACEASTĂ MAȘINĂ.\n'
  printf 'Dosarul tău de lucru nu este atins. Fiecare pas se tipărește înainte de execuție.\n\n'
}
L_UNINSTALL_STEP() { printf '  șterg: %s\n' "$1"; }
L_UNINSTALL_FOREIGN_SKILL() {
  printf '  las %s pe loc — nu poartă marcajul de proveniență al acestui kit,\n' "$1"
  printf '  deci nu e al nostru să-l ștergem.\n'
}
L_UNINSTALL_TOKEN_WARN() {
  printf '  urmează să ȘTERG fișierul cu token-ul botului: %s\n' "$1"
  printf '  (conținutul lui nu este citit sau afișat; botul rămâne viu la\n'
  printf '  @BotFather — revocă token-ul acolo dacă vrei să-l stingi).\n'
}
L_UNINSTALL_SUMMARY() { printf '\nGata. Șters:\n'; }
L_UNINSTALL_KEEP_WORKDIR() {
  printf '\nDatele tale au rămas aici: %s\n' "$1"
  printf 'Șterge tu acel dosar dacă vrei zero complet.\n'
}
L_UNINSTALL_NOOP() { printf 'Nimic de șters — pe această mașină nu există o instalare Qroky. Deja curat.\n'; }

# --- calea de reinstalare (ATOM-106, INFO-040) ------------------------------
L_REINSTALL_FOUND() {
  printf 'Acest dosar poartă deja o instalare Qroky: framework/ plus datele tale alături.\n'
  printf '  %s\n' "$1"
}
L_REINSTALL_ASK() {
  printf 'Reinstalare: datele tale rămân neatinse, framework/ este recreat de la zero.\n'
  printf 'Ce facem? [1 reinstalare / 2 actualizare / 3 anulare] (Enter = anulare): '
}
L_REINSTALL_START() { printf 'Recreez framework/ — datele tale nu sunt atinse.\n'; }
L_REINSTALL_UPDATE_ROUTE() { printf 'Redirecționez către calea de actualizare...\n'; }
L_REINSTALL_UPDATE_NEEDS_STATE() {
  printf 'Nu există o înregistrare a instalării aici — nu e nimic de actualizat. Alege reinstalare sau anulare.\n'
}
L_REINSTALL_CANCELLED() { printf 'Anulat. Nimic nu a fost schimbat.\n'; }
L_ORPHAN_FOUND() {
  printf 'Acest dosar ține o copie framework/ fără date alături — pare o clonă orfană:\n'
  printf '  %s\n' "$1"
}
L_ORPHAN_ASK() { printf 'O recreez și instalez curat? [da/nu] (Enter = nu): '; }
L_ORPHAN_DECLINED() { printf 'Bine — las totul așa cum este.\n'; }
L_UNINSTALL_REINSTALL_HINT() {
  printf 'Pentru reinstalare — o singură comandă, de oriunde; datele rămân:\n'
  printf '    %s\n' 'bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install'
}

# --- vizibilitatea gestului proaspăt (ATOM-106 DoD 6, INFO-041) --------------
L_FINALE_NEW_SESSION_NOTE() {
  printf 'Important: doar conversațiile NOI Claude Code văd ce tocmai s-a instalat — o\n'
  printf 'fereastră deschisă ÎNAINTE de această instalare nu știe încă fraza. Deschide o conversație nouă.\n'
}
L_MARKER_SESSION_NOTE() {
  printf 'Notă pentru asistent: mediul citește contextul la PORNIREA sesiunii. Dacă\n'
  printf 'qroky/«кроки» este menționat dar fișierul skill de mai sus nu este accesibil,\n'
  printf 'probabil a fost instalat DUPĂ pornirea acestei sesiuni — sugerează deschiderea\n'
  printf 'unei conversații NOI în loc de un simplu „not found".\n'
}

# --- urmă în loc de întrebare pentru machine-wide (INFO-042) -----------------
L_FINALE_MACHINEWIDE_TRACE() {
  printf 'Configurat fără întrebare (ca să funcționeze pur și simplu): asistentul\n'
  printf 'răspunde la «qroky» în ORICE sesiune Claude Code pe acest calculator — exact\n'
  printf 'două fișiere în ~/.claude. Se elimină complet cu o comandă: qroky uninstall\n'
}

# --- comanda qroky pe PATH (ATOM-131, INFO-044) --------------------------------
# $1 = fișierul de profil în care s-a adăugat linia PATH ("" = nu a fost nevoie).
L_FINALE_QROKY_COMMAND() {
  printf 'De acum, în orice fereastră NOUĂ de terminal, un singur cuvânt merge de oriunde:\n'
  printf '    qroky update       — actualizează asistentul\n'
  printf '    qroky uninstall    — elimină tot ce a pus pe acest calculator\n'
  printf '(ce a fost configurat: micul fișier de comandă ~/.local/bin/qroky'
  if [[ -n "${1:-}" ]]; then
    printf ',\n plus o linie PATH în %s — ambele eliminate de qroky uninstall)\n' "$1"
  else
    printf ' —\n eliminat de qroky uninstall)\n'
  fi
}
