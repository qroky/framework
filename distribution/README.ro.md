# Qroky — instalare de sine stătătoare

## Ce face acest instalator

Un singur script, `install.sh`, duce un calculator curat la un asistent
funcțional în mai puțin de 15 minute. Îți pune exact **opt întrebări**
(listate mai jos), îți pregătește un folder privat pe propriul calculator,
și se termină cu un bloc gata de copiat și lipit pentru prima conversație.
Nu întreabă niciodată nimic în afara acestor opt întrebări — orice altă
linie afișată este fie progres, fie rezultatul unei verificări, fie (la o
problemă reală) o instrucțiune clară de rezolvare, cu pasul exact următor.
Chiar primul ecran este o hartă a întregului drum: 8 întrebări, ~3 minute,
două linii la final.

## Comanda unică

```
bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
```

Asta e toată intrarea — rulează de oriunde, fără descărcare, fără clonă,
fără vreun folder de găsit mai întâi. Comanda își aduce singură copia
kitului în `~/.qroky/kit`, pornește interviul și pune o mică comandă
`qroky` în PATH-ul tău. Din următoarea fereastră de terminal, tot drumul e
un singur cuvânt, din orice folder:

```
qroky update       # actualizează asistentul
qroky uninstall    # elimină tot ce a pus pe acest calculator
```

Nu trebuie să ții minte unde stă nimic. Dacă lipsește
ceva (git, curl, chiar asistentul Claude Code), scriptul se oprește și îți
spune exact ce să instalezi și cum — apoi rulezi din nou aceeași comandă,
și continuă chiar de unde s-a oprit. Nimic nu se repetă, nimic la care ai
răspuns deja nu se întreabă a doua oară.

*Alternativă (mașini fără internet sau fără curl): clonează acest
repository manual și rulează `bash qroky.sh install` — sau
`bash install.sh` din acest folder — același interviu, același rezultat.*

## Primele 5 minute

Instalarea s-a terminat — iată o mână pe umăr pentru chiar prima
conversație.

**Ce faci.** Finalul instalării ți-a dat deja un bloc gata pregătit —
copiază-l:

```
cd <folderul tău de lucru> && claude
```

La **prima** pornire, `claude` îți pune câteva întrebări proprii (tema de
culori, autentificarea) — e normal; răspunde-le și continuă. Apoi spune:
`qroky start`.

**Ce se întâmplă.** Sistemul se uită în jur prin folder (doar citire), te
întreabă despre cele două „de ce"-uri ale muncii tale și propune un plan
pe un singur ecran. Tu răspunzi **„go"** („го") — sau îl corectezi în
cuvinte simple, ca pe un om. Până la un „go" explicit, nu face nimic.

**Cum arată succesul.** După prima conversație, folderul tău de lucru
capătă: `qroky/mission.md` — cele două „de ce"-uri ale tale, înregistrate
cuvânt cu cuvânt; și, lângă munca în desfășurare, `NARRATIVE.md` — o
relatare vie, pe limbă omenească, despre ce se face și de ce. Sarcinile și
stările lor se adună în același folder — totul e text simplu, pe care îl
poți deschide și citi.

O notă sinceră: fraza de pornire funcționează **în orice conversație
Claude Code pe acest calculator** — instalatorul configurează asta singur
(exact două fișiere în `~/.claude`; ecranul final le numește, iar
`qroky uninstall` elimină totul complet).

## Cele opt întrebări

1. **Limba** — English, Română, sau Русский. Tot ce urmează după acest
   punct este afișat în limba aleasă.
2. **Folderul de lucru** — unde ar trebui să stea spațiul tău privat
   Qroky. Este sugerată o cale rezonabilă; apasă Enter pentru a o accepta,
   sau scrie propria cale.
3. **Verificarea Claude Code** — instalatorul verifică dacă asistentul
   Claude Code este deja pe acest calculator. Dacă nu, primești linkul
   exact de instalare și instrucțiunile; rulează instalatorul din nou după
   ce e instalat.
4. **Verificarea abonamentului** — o verificare rapidă, care nu blochează,
   că autentificarea/abonamentul tău Claude Code pare activ. E o
   verificare, nu un flux de cumpărare — dacă nu poate confirma, doar te
   anunță, nu te oprește niciodată.
5. **Telegram (opțional)** — asistentul în buzunarul tău: un rezumat de
   dimineață, noutăți și întrebări pe care ți le poate pune pe telefon. A
   sări peste nu cere niciun efort: apasă doar Enter (conectezi mai târziu
   cu o comandă: `bash install.sh --enable-telegram`). Dacă spui da,
   instalatorul te duce pas cu pas prin crearea propriului tău bot cu
   BotFather, verifică token-ul live, îți cere să apeși **Start** la botul
   tău — iar botul **îți scrie imediat înapoi** („sunt conectat; mâine
   dimineață primești primul rezumat"). Toată legătura pornește chiar
   acolo: verificarea mesajelor la fiecare 30 de secunde și un rezumat
   zilnic la 09:05. Dacă nimeni nu apasă Start la timp, nimic nu se strică:
   token-ul e salvat, instalarea continuă, iar aceeași comandă unică
   termină conectarea mai târziu.
6. **Partajarea sprijinului zilnic (opțional)** — vezi „Ce pleacă de pe
   acest calculator" mai jos, înainte de a fi întrebat. Oprită implicit.
7. **Rezumatul de dimineață (opțional)** — un mesaj scurt zilnic: ce s-a
   făcut, ce te așteaptă. Recomandat: da. Te poți răzgândi oricând (vezi
   „Nu-mi atinge instanța" mai jos).
8. **Copia de siguranță (opțional, recomandat)** — păstrează o copie
   privată de siguranță a folderului tău Qroky în **propriul tău** cont
   GitHub. Nu trebuie să știi ce e GitHub: dacă spui da, instalatorul te
   duce pas cu pas prin conectarea (sau crearea, gratuit) a contului tău,
   la fel de ținut de mână ca la botul Telegram. **Copia de siguranță merge
   în contul TĂU** — o copie privată, vizibilă doar pentru tine, niciodată
   pentru noi sau altcineva. Fișierele tale secrete (cum ar fi token-ul
   Telegram) sunt excluse automat din orice copie de siguranță.
Aici era înainte a noua întrebare — „fraza pe tot calculatorul?" — dar
cerea o înțelegere pe care un utilizator nou nu o poate avea, așa că
instalatorul o face acum pur și simplu singur (exact **două fișiere** în
`~/.claude`: o copie a paginii de reguli la `~/.claude/skills/qroky/SKILL.md`
și un bloc-declanșator marcat în `~/.claude/CLAUDE.md` — nimic altceva,
niciodată). Urma înlocuiește întrebarea: asistentul răspunde la «qroky» în
ORICE sesiune Claude Code pe acest calculator, iar o singură comandă
elimină totul complet: `qroky uninstall`. Aceeași regulă aduce și comanda
`qroky` însăși: un mic lansator la `~/.local/bin/qroky` (plus o linie PATH
marcată în profilul shell-ului — doar dacă `~/.local/bin` nu era deja în
PATH) — numit pe ecranul final, eliminat de același `qroky uninstall`.

## Ce pleacă de pe acest calculator

Dacă activezi partajarea sprijinului zilnic la întrebarea 6, doar acestea —
și nimic altceva — ar pleca vreodată de pe acest calculator (lista
completă; orice nu e pe ea este omis, niciodată citit):

1. **Fișierele de progres ale sarcinilor (`STATUS.md`)** — doar cuvântul de
   stare, data și identificatorul sarcinii; notele libere sunt eliminate.
2. **Rezumatele de cost (`RESULT.md`)** — DOAR cifrele de cost
   (timp/unități); secțiunile de rezumat și conținut, unde ar fi descris
   produsul tău, nu sunt copiate niciodată.
3. **Jurnalele de pași (`run.log`)** — doar marcaje de timp și nume de pași.
4. **Tabloul de stare (`status.yaml`)** — o linie per sarcină; notele
   libere sunt eliminate.
5. **Rezultatele verificărilor independente (`VERDICT.md`)** — doar linia
   de verdict, niciodată textul constatărilor.

Niciodată codul, specificațiile sau conținutul produsului tău — acestea nu
sunt pe listă și nu sunt citite niciodată. De reținut: acest instalator
doar **îți înregistrează alegerea** — nu instalează niciun mecanism de
trimitere, deci nimic nu poate pleca nici după un „da". Înainte ca vreun
script de trimitere să fie adăugat vreodată în spațiul tău de lucru, îți va
fi arătat chiar acel script — bash simplu, lizibil, pe care îl poți
verifica linie cu linie față de lista de mai sus.

## Nu-mi atinge instanța

Instalatorul nu schimbă niciodată nimic ce nu ai cerut, iar orice piesă
opțională pe care o pornește poate fi oprită la fel de ușor:

- **Oprește rezumatul de dimineață:** șterge fișierul din folderul
  `.qroky/launchd/` al spațiului tău de lucru din `~/Library/
  LaunchAgents/`, sau pur și simplu nu răspunde „da" la întrebarea 7 de la
  început — rezumatul e instalat-dar-oprit în acest caz, cu comanda exactă
  de pornire afișată pentru tine.
- **Pornește rezumatul de dimineață mai târziu:**
  `bash install.sh --enable-heartbeat`
- **Pornește copia de siguranță mai târziu** (dacă ai spus nu la
  întrebarea 8): `bash install.sh --enable-backup`
- **Conectează (sau termină de conectat) Telegram mai târziu** (dacă ai
  sărit peste întrebarea 5 sau Start nu a fost apăsat la timp):
  `bash install.sh --enable-telegram`
- **Oprește asistentul Telegram:** șterge cele două fișiere
  `md.qroky.telegram.listener.plist` și `md.qroky.telegram.digest.plist`
  din `~/Library/LaunchAgents/` (fișierele lui de lucru stau în
  `.qroky/telegram/` din spațiul tău de lucru și nu fac nimic singure).
- **Elimină fraza de pornire „pe tot calculatorul"**: șterge exact cele
  două fișiere care au fost scrise —
  fișierul `~/.claude/skills/qroky/SKILL.md` și blocul marcat dintre
  marcajele `qroky-machinewide` din `~/.claude/CLAUDE.md`.
- **Elimină manual comanda `qroky`**: șterge `~/.local/bin/qroky` și blocul
  marcat dintre marcajele `qroky command` din profilul shell-ului. În afară
  de acestea și de `~/.qroky` (copia kitului și un fișier-indicator),
  instalatorul nu a scris nimic altceva în `~` — iar `qroky uninstall` face
  toate acestea pentru tine.
- **Vezi tot ce schimbă o actualizare în așteptare:**
  `qroky details`
- **Aplică o actualizare în așteptare (doar după ce confirmi explicit;
  fără actualizare în așteptare nu schimbă nimic și o spune):**
  `qroky update` — dacă ai făcut propriile modificări în
  folderul vendorizat `framework/`, instalatorul îți ARATĂ exact ce ar fi
  afectat înainte de a atinge ceva; nu suprascrie niciodată pe ascuns
  schimbările tale.

## Sigur de rulat din nou, oricând

Fiecare pas al instalatorului este o pereche „verifică, apoi fă": pe un
spațiu de lucru sănătos, deja configurat, rularea din nou a `install.sh`
este o verificare de sănătate gratuită, care nu schimbă nimic și nu
întreabă nimic din nou. Dacă instalatorul e întrerupt la mijloc (pană de
curent, terminal închis, orice), rularea din nou continuă exact de unde a
rămas — răspunsurile pe care le-ai dat deja sunt păstrate în
`install-state.json` din spațiul tău de lucru, un fișier text simplu, pe
care ești liber să-l citești.

## Copia de siguranță și restaurarea

Dacă ai pornit copia de siguranță (întrebarea 8), o copie privată a
folderului tău Qroky, numită `qroky-backup`, stă în **propriul tău** cont
GitHub — al nimănui altcuiva, și nimeni altcineva nu o poate vedea.
Restaurarea pe orice calculator este o singură comandă:

```
gh repo clone qroky-backup
```

Apoi rulează `bash install.sh` o dată în folderul restaurat — reatașează
regulile fixate și reverifică totul, fără să întrebe nimic la care ai
răspuns deja. Fișierele tale secrete (token-ul Telegram și orice arată a
secret) sunt excluse din orice copie de siguranță printr-un `.gitignore`
scris de instalator pentru tine — nu părăsesc niciodată acest calculator.

## O notă despre responsabilitate

Sistemul produce ciorne și analize; deciziile și semnăturile juridice,
financiare și medicale aparțin întotdeauna unui om. Nu constituie
consultanță profesională.

## Pornire de la zero

O singură comandă șterge tot ce a pus installer-ul pe ACEASTĂ MAȘINĂ —
job-urile programate, fișierele machine-wide ale gestului (doar dacă poartă
marcajul de proveniență al acestui kit), starea `~/.qroky`, răspunsurile
salvate și fișierul cu token-ul botului (anunțat înainte de ștergere;
conținutul nu este citit):

    qroky uninstall

Fiecare pas se tipărește înainte de execuție, iar la final — lista celor
șterse. Dosarul tău de lucru NU este atins — calea lui se tipărește, ca să
îl poți șterge singur dacă vrei zero complet. Pe o mașină fără instalare
comanda este un no-op politicos.

Ce anulează, printre altele: asistentul răspunde la «qroky» în orice
sesiune Claude Code pe acest calculator — această configurare machine-wide
este eliminată complet de această singură comandă — împreună cu comanda
`qroky` însăși (`~/.local/bin/qroky` și linia ei PATH; liniile străine din
profil nu sunt atinse niciodată). Pentru reinstalare — o singură comandă,
de oriunde; datele rămân:

    bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install
