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

**1. Deschide un terminal** (o fereastră unde se tastează comenzi) în
folderul unde vrei să lucrezi. *(~1 minut)*

**2. Rulează o singură comandă:**
```
bash bootstrap.sh
```
Vezi mesaje de progres, pas cu pas — scriptul îți spune exact ce face, în 5
etape scurte: verifică ce ai deja pe calculator, îți creează un spațiu de
lucru privat, adaugă o copie fixă a regulilor pe care le urmează asistentul,
conectează asistentul la spațiul tău de lucru, și termină. *(~2–5 minute,
în funcție de viteza internetului)*

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
le urmează, și asistentul conectat, gata de discuție.

## Ce NU se întâmplă automat

Nimic din spațiul tău de lucru nu este trimis nicăieri fără acordul tău
explicit. Acordul pentru ce anume se trimite (și ce nu se trimite niciodată)
este un document separat, pe care îl semnezi tu, când ești gata.

---
*Timp total măsurat pentru toți pașii de mai sus, pe o mașină curată: sub un
minut pentru partea tehnică (excludem timpul de citit și de instalat
programe care lipsesc, dacă a fost cazul) — cu mult sub bugetul de 15
minute. Dovada: `dry-run-transcript.txt`, în acest același folder.*
