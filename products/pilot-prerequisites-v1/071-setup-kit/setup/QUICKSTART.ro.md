# Primii pași cu Qroky (sub 15 minute)

Acest ghid te duce din momentul în care ai spus „da” până la prima ta
conversație cu asistentul. Nu ai nevoie de cunoștințe tehnice — la fiecare
pas, dacă lipsește ceva, ești anunțat clar ce să faci.

## Înainte de a începe

- Un calculator (Mac, Windows sau Linux) cu conexiune la internet.
- Programul „Claude Code" instalat. Dacă nu-l ai încă, scriptul de mai jos
  îți spune exact de unde să-l descarci și cum să-l instalezi — nu trebuie
  să știi nimic dinainte.

## Pașii

**0. De unde vine acest kit:** ai primit (prin email sau printr-un link) un
folder care conține acest ghid, scriptul `bootstrap.sh` și câteva alte
fișiere mici. Descarcă/dezarhivează acel folder undeva pe calculatorul tău
— pasul 1 de mai jos se face **în acel folder**, nu în oricare altul.

**1. Deschide un terminal** (o fereastră unde se tastează comenzi) **chiar
în folderul primit la pasul 0**. *(~1 minut)*
*Pe Windows: deschide „Git Bash", nu „Command Prompt" sau „PowerShell" —
programul de instalare de la pasul următor îl adaugă automat în meniu.*

**2. Rulează o singură comandă:**
```
bash bootstrap.sh
```
Vezi mesaje de progres, pas cu pas — scriptul îți spune exact ce face, în 6
etape scurte: verifică ce ai deja pe calculator, îți creează un spațiu de
lucru privat, adaugă o copie fixă a regulilor pe care le urmează asistentul,
conectează asistentul la spațiul tău de lucru, pregătește (oprit, implicit)
sprijinul zilnic, și termină. *(~2–5 minute, în funcție de viteza
internetului pentru partea care descarcă regulile asistentului — restul
pașilor durează sub un minut din timpul calculatorului)*

Dacă lipsește ceva (de exemplu programul „git" sau „Claude Code"), scriptul
se oprește și îți arată exact comanda de instalat — copiezi acea comandă,
o rulezi, apoi rulezi din nou `bash bootstrap.sh`. Poți rula scriptul de
oricâte ori — nu strică nimic dacă unii pași sunt deja făcuți.

**3. Când vezi mesajul „Setup finished... Nothing failed.”**, spațiul tău
de lucru e gata. *(~30 secunde de citit)*

**4. Pornește prima conversație:** scrie `claude` și apasă Enter, apoi
scrie „salut”. De aici începe conversația ta cu asistentul. *(~1 minut)*

## Ce ai obținut

Un folder propriu, privat, pe calculatorul tău — al tău, nu al nostru — cu
o copie fixă (care nu se schimbă pe ascuns) a regulilor pe care asistentul
le urmează, și asistentul conectat, gata de discuție. Sprijinul zilnic
(telemetria) este deja instalat, dar **oprit** — rămâne oprit până semnezi
documentul separat de consimțământ.

## Ce NU se întâmplă automat

Nimic din spațiul tău de lucru nu este trimis nicăieri fără acordul tău
explicit. Acordul pentru ce anume se trimite (și ce nu se trimite niciodată)
este un document separat, pe care îl semnezi tu, când ești gata.

## La ce să te aștepți de la sprijinul zilnic, odată semnat

Ne angajăm ca acest pilot să fie ocupația noastră principală zilnică pe
durata lui — de aceea promitem o reacție în cel mult o zi lucrătoare la
orice blocare a ta. Dacă totuși întârziem de două ori din cinci zile
lucrătoare la rând, oprim automat și te anunțăm, în loc să lăsăm promisiunea
nespusă să se rupă tăcut. Detaliile complete sunt în documentul de
consimțământ.

---
*Timp total măsurat pentru pașii 1–4 de mai sus, pe o mașină curată: sub un
minut pentru partea scriptată (repository, reguli, conectare) — adaugă timpul
propriei tale conexiuni pentru descărcarea regulilor asistentului, de obicei
câteva minute. Cu mult sub bugetul de 15 minute per total. Această măsurătoare
a fost făcută pe o mașină de test, fără conexiune la internet, cu o copie
locală a regulilor — partea care variază cu adevărat (descărcarea reală) nu a
fost încă măsurată pe o conexiune reală.*
