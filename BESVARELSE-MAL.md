# Besvarelse - Refleksjon og Analyse

**Student:** [Niyat Tesfaghabr]

**Studentnummer:** [403851]

**Dato:** [Innleveringsdato]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**


1. Kunde 
2. Stasjon
3. Laas
4. Sykkel 
5. Utleie

   

**Attributter for hver entitet:**

1. Kunde: Dette er minimumet som trengs for å identifisere kunden og knytte utleier til riktig person.
- kunde_id
- mobilnummer
- epost
- fornavn
- etternavn

2. Stasjon: Dette trengs for å vite hvor sykler kan hentes/leveres. 
   - stasjon_id
   - navn
   - adresse

3. Laas: Dette trengs fordi innlevering registreres ved å feste sykkelen i en lås.
   - laas_id
   - stasjon_id

5. Sykkel: Hvis sykkelen er utleid vil stasjon_id og lås_id være null. Dette er nødvendig for å kunne vite hvilke sykler som er på hvilke stasjoner, og hvilke som er utleid. 
   - sykkel_id
   - stasjon_id
   - laas_id
     
6. Utleie: De to siste attributtene er ikke nødvendige for transaksjon, men greit å ha en oversikt over. Resten av attributtene er nødvendig for å kunne fakturere kunden for sykkelen. slutt_tid attributten vil være null så lenge sykkelen ikke er levert inn. 
   - utleie_id
   - kunde_id
   - sykkel_id
   - start_tid
   - slutt_tid
   - beløp
   - start_stasjon
   - slutt_stasjon


### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**


1. Kunde
- kunde_id SERIAL: serial gir automatisk økende ID, som gjør hver kunde unik og vil være stabil å referere til fra andre tabeller
- mobilnummer VARCHAR(15): Lengde 15 dekker internasjonale nummer. 
- epost VARCHAR(200): E-post er tekst, og en maks lengde gjør feltet mer kontrollert. 200 vil holde til vanlige eposter. 
- fornavn VARCHAR(50): 50 tegn er mer enn nok for de fleste navn.
- etternavn VARCHAR(50): 50 tegn er mer enn nok for de fleste etternavn.
3. Stasjon
   - stasjon_id SERIAL: Unik identifikasjon for hver stasjon. 
   - navn VARCHAR(100): Stasjonsnavn er tekst og typisk kort.
   - adresse TEXT: Adresse kan variere mye i lengde, så her er det bedre å ikke begrense antall tegn. 
4. Lås
   - laas_id SERIAL: Unik identifikasjon for hver lås. 
   - stasjon_id INT: Dette er en referanse til stasjonen låsen tilhører, derfor blir det int fordi det pekes tilbake på stasjon_id i stasjon.  
5. Sykkel
   - sykkel_id SERIAL: Unik identifikasjon for hver sykkel.
   - stasjon_id INT: Igjen refereres det tilbake til stasjonen, og da hvilken stasjon sykkelen står på. 
   - laas_id INT: Referanse til hvilken lås sykkelen står i, int fordi den referer tilbake til lås_id i lås. 
6. Utleie
   - utleie_id SERIAL: Unik identifikasjon for hver utleie.
   - kunde_id INT: Referanse til hvilken kunde som leier ut, int fordi den referer tilbake til kunde_id i kunde.
   - sykkel_id INT: Referanse til hvilken sykkel kunden leier ut, int fordi den referer tilbake til sykkel_id i sykkel.
   - start_tid TIMESTAMP: Lagrer klokkelsett og dato for når sykkelen ble leid ut (trengs for beregning av beløp).
   - slutt_tid TIMESTAMP: Lagrer klokkeslett og dato for når sykkelen ble levert inn (trengs for beregning av beløp). 
   - beløp NUMERIC(10,2): numeric brukes for nøyaktighet, ved å velge (10,2) gir det rom for store beløp og alltid to desimaler.
   - start_stasjon_id INT: Lagrer hvilken stasjon utleien starter på, int fordi det referer til stasjon_id i stasjon. 
   - slutt_stasjon_id INT: Lagrer hvilken stasjon utleien endte på, int fori det referer til stasjon_id i stasjon]
 
   

**`CHECK`-constraints:**

1. Kunde 
- kunde_id SERIAL
- mobilnummer VARCHAR(15) CHECK (mobilnummer ~ '^\+?[0-9]{8,15}$')
- epost VARCHAR(200)
- fornavn VARCHAR(50) CHECK (length(trim(fornavn)) > 0)
- etternavn VARCHAR(50) CHECK (length(trim(etternavn)) > 0)

Begrunnelse:
mobilnummer: Sikrer at telefonnummeret består av 8-15 sifre (0-9), og eventuelt starte med + for internasjonale nummer. 
fornavn og etternavn: Hindrer at feltet kun består av en tom streng. 


2. Stasjon
- stasjon_id SERIAL 
- navn VARCHAR(100) CHECK (length(trim(navn)) > 0)
- adresse TEXT

Begrunnelse: 
navn: Sikrer at stasjonnavnet ikke er en tom streng.

3. Laas
- laas_id SERIAL
- stasjon_id INT
  
4. Sykkel 
- sykkel_id SERIAL 
- stasjon_id INT
- laas_id  INT
  CHECK (
    (stasjon_id IS NULL AND laas_id IS NULL)
    OR
    (stasjon_id IS NOT NULL AND laas_id IS NOT NULL)
)

Begrunnelse:
Sykkelen skal enten være parkert på en stasjon og være låst (begge felter har en verdi), eller være utleid (begge felter er NULL).

5. Utleie
- utleie_id SERIAL
- kunde_id INT
- sykkel_id INT
- start_tid TIMESTAMP
- slutt_tid TIMESTAMP CHECK (slutt_tid IS NULL OR slutt_tid >= start_tid)
- belop NUMERIC(10,2) CHECK (belop IS NULL OR belop >= 0)
- start_stasjon_id INT
- slutt_stasjon_id INT

Begrunnelse: 

slutt_tid: En utleie kan være aktiv (NULL), men dersom sykkelen er levert inn på tidspuktet være lik eller senere enn start_tid. 
belop: Leiebeløpet kan ikke være negativt, NULL tillates før beløpet er beregnet ved avsluttet leie.


**ER-diagram:**

erDiagram

    KUNDE ||--o{ UTLEIE : har
    SYKKEL ||--o{ UTLEIE : brukes_i
    STASJON ||--o{ LAAS : har
    STASJON ||--o{ SYKKEL : parkerer
    LAAS ||--o| SYKKEL : laaser
    STASJON ||--o{ UTLEIE : start
    STASJON ||--o{ UTLEIE : slutt

    KUNDE {
        SERIAL kunde_id PK
        VARCHAR(15) mobilnummer
        VARCHAR(200) epost
        VARCHAR(50) fornavn
        VARCHAR(50) etternavn
    }

    STASJON {
        SERIAL stasjon_id PK
        VARCHAR(100) navn
        TEXT adresse
    }

    LAAS {
        SERIAL laas_id PK
        INT stasjon_id FK
    }

    SYKKEL {
        SERIAL sykkel_id PK
        INT stasjon_id FK
        INT laas_id FK
    }

    UTLEIE {
        SERIAL utleie_id PK
        INT kunde_id FK
        INT sykkel_id FK
        TIMESTAMP start_tid
        TIMESTAMP slutt_tid
        NUMERIC belop
        INT start_stasjon_id FK
        INT slutt_stasjon_id FK
    }

---

### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**

[Skriv ditt svar her - forklar hvilke primærnøkler du har valgt for hver entitet og hvorfor]

1. Kunde 
- kunde_id SERIAL PK
- mobilnummer VARCHAR(15)
- epost VARCHAR(200)
- fornavn VARCHAR(50) 
- etternavn VARCHAR(50)
  
2. Stasjon
- stasjon_id SERIAL PK
- navn VARCHAR(100)
- adresse TEXT
  
3. Lås
- lås_id SERIAL PK
- stasjon_id INT FK
  
4. Sykkel
- sykkel_id SERIAL PK
- stasjon_id INT FK
- lås_id INT FK
  
5. Utleie
- utleie_id SERIAL PK
- kunde_id INT FK
- sykkel_id INT FK
- start_tid TIMESTAMP
- slutt_tid TIMESTAMP
- beløp NUMERIC(10,2) 
- start_stasjon_id INT FK
- slutt_stasjon_id INT FK

Begrunnelse: 
For hver entitet er det valgt en primærnøkkel:
- kunde_id: brukes som primærnøkkel fordi hver kunde må kunne identifiseres, mobilnummer og e-post kan endres, mens ID er stabil.
- stasjon_id: identifiserer hver stasjon unikt, da stasjon navn kan endres.
- laas_id: identifiserer hver lås.
- sykkel_id: identifiserer hver sykkel unikt i systemet.
- utleie_id: En kunde kan ha mange utleier over tid, derfor må hver utleie ha en egen identifikasjon. 

Fremmednøklene er valgt når det refereres til en primærnøkkel i en annen tabell, som skaper kobling mellom data og sikrer referanseintegritet. 



**Naturlige vs. surrogatnøkler:**
Surrogatnøkler:
- kunde_id
- stasjon_id
- laas_id
- sykkel_id
- utleie_id

Disse er surrogatnøkler fordi de ikke har noen naturlig betydning i den virkelige verden. De genereres automatisk av databasen og brukes kun for å kunne identifisere. De er stabile og endres ikke, noe som gjør dem godt egnet som primærnøkler.

Naturlige nøkler:
En naturlig nøkkel er en attributt som allerede finnes i virkeligheten og som kan identifisere en entitet unikt. Mobilnummer eller e-post er eksempler på attributter som kunne fungert som naturlige nøkler for kunde, siden de ofte er unike. Likevel kan kunder bytte e-post eller mobilnummer, dermed vil surrogatnøkkelen kunde_id vær en mer stabil identifikator. 


**Oppdatert ER-diagram:**

erDiagram

    KUNDE ||--o{ UTLEIE : har
    SYKKEL ||--o{ UTLEIE : brukes_i
    STASJON ||--o{ LAAS : har
    STASJON ||--o{ SYKKEL : parkerer
    LAAS ||--o| SYKKEL : laaser
    STASJON ||--o{ UTLEIE : start
    STASJON ||--o{ UTLEIE : slutt

    KUNDE {
        SERIAL kunde_id PK
        VARCHAR(15) mobilnummer
        VARCHAR(200) epost
        VARCHAR(50) fornavn
        VARCHAR(50) etternavn
    }

    STASJON {
        SERIAL stasjon_id PK
        VARCHAR(100) navn
        TEXT adresse
    }

    LAAS {
        SERIAL laas_id PK
        INT stasjon_id FK
    }

    SYKKEL {
        SERIAL sykkel_id PK
        INT stasjon_id FK
        INT laas_id FK
    }

    UTLEIE {
        SERIAL utleie_id PK
        INT kunde_id FK
        INT sykkel_id FK
        TIMESTAMP start_tid
        TIMESTAMP slutt_tid
        NUMERIC belop
        INT start_stasjon_id FK
        INT slutt_stasjon_id FK
    }


---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**


  KUNDE ||--o{ UTLEIE 
  forhold: En kunde kan ha flere utleier
  kardinalitet:  1:N
  En kunde kan ha null eller mange utleier, mens hver utleie tilhører nøyaktig én kunde (relasjonen er en-til-mange)

  SYKKEL ||--o{ UTLEIE
  forhold: En sykkel kan leies ut flere ganger
  kardinalitet: 1:N
  En sykkel kan være knyttet til null eller mange utleier, mens hver utleie gjelder nøyaktig én sykkel (relasjonen er en-til-mange)

  STASJON ||--|{ LAAS 
  forhold: En stasjon har flere låser
  kardinalitet: 1:N
  Hver lås tilhører en bestemt stasjon (relasjonen er en-til-mange)
  
  STASJON |o--o{ SYKKEL
  forhold: En stasjon kan ha 0 eller flere sykler parkert (0 hvis alle er utleid)
  kardinalitet: 1:N
  En sykkel kan kun være parkert på èn eller null stasjoner (relasjonen er en-til-mange)
  
  LAAS |o--o| SYKKEL
  forhold: Èn lås kan kun holde èn eller null sykler om gangen
  kardinalitet: 0..1 : 0..1
  En sykkel kan være i null eller èn lås (relasjonen er valgfri èn-til-èn)
  
  STASJON ||--o{ UTLEIE : start
  forhold: En stasjon kan være start_stasjon for null eller flere utleier
  kardinalitet: 1:N
  Hver utleie kan kun ha èn start_stasjon (relasjonen er en-til-mange)
  
  STASJON ||--o{ UTLEIE : slutt
  forhold: En stasjon kan være slutt_stasjon for null eller flere utleier
  kardinalitet: 1:N
  Hver utleie kan kun ha èn slutt_stasjon (relasjonen er en-til-mange)

**Fremmednøkler:**

Fremmednøkler (FK) brukes for å koble tabeller sammen og implementere forholdene i ER-modellen. En fremmednøkkel i en tabell må peke til en eksisterende primærnøkkel i en annen tabell.

Fremmednøkler:

LAAS
laas.stasjon_id (FK)→ stasjon.stasjon_id (PK)
Implementerer forholdet stasjon-lås (1:N): En stasjon kan ha mange låser, og hver lås tilhører èn stasjon


SYKKEL
sykkel.stasjon_id (FK) → stasjon.stasjon_id (PK) (kan være null når sykkelen er utleid)
Implementerer forholdet Stasjon–Sykkel (1:N): En stasjon kan ha 0 eller flere sykler, og en sykkel kan være knyttet til 0 eller 1 stasjon.

sykkel.laas_id (FK) → laas.laas_id (PK) (kan være null når sykkelen er utleid)
Implementerer forholdet Lås–Sykkel (0..1 : 0..1): En sykkel kan være låst i 0 eller 1 lås, og en lås kan holde 0 eller 1 sykkel.

UTLEIE

utleie.kunde_id (FK) → kunde.kunde_id (PK)
Implementerer forholdet Kunde–Utleie (1:N): En kunde kan ha 0 eller flere utleier, og hver utleie tilhører nøyaktig én kunde.

utleie.sykkel_id (FK) → sykkel.sykkel_id (PK)
Implementerer forholdet Sykkel–Utleie (1:N): En sykkel kan ha 0 eller mange utleier over tid, og hver utleie gjelder nøyaktig én sykkel.

utleie.start_stasjon_id (FK) → stasjon.stasjon_id (PK)
Implementerer forholdet Stasjon–Utleie (start) (1:N): En stasjon kan være startstasjon for 0 eller flere utleier, og hver utleie har nøyaktig én startstasjon.

utleie.slutt_stasjon_id (FK) → stasjon.stasjon_id (PK)
Implementerer forholdet Stasjon–Utleie (slutt) (1:N): En stasjon kan være sluttstasjon for 0 eller flere utleier, og hver utleie har nøyaktig én sluttstasjon.

**Oppdatert ER-diagram:**

erDiagram

    KUNDE  ||--o{ UTLEIE : har
    SYKKEL ||--o{ UTLEIE : brukes_i
    STASJON ||--|{ LAAS : har
    STASJON |o--o{ SYKKEL : parkerer
    LAAS   |o--o| SYKKEL : laaser
    STASJON ||--o{ UTLEIE : start
    STASJON ||--o{ UTLEIE : slutt

    KUNDE {
        SERIAL kunde_id PK
        VARCHAR mobilnummer
        VARCHAR epost
        VARCHAR fornavn
        VARCHAR etternavn
    }

    STASJON {
        SERIAL stasjon_id PK
        VARCHAR navn
        TEXT adresse
    }

    LAAS {
        SERIAL laas_id PK
        INT stasjon_id FK
    }

    SYKKEL {
        SERIAL sykkel_id PK
        INT stasjon_id FK
        INT laas_id FK
    }

    UTLEIE {
        SERIAL utleie_id PK
        INT kunde_id FK
        INT sykkel_id FK
        TIMESTAMP start_tid
        TIMESTAMP slutt_tid
        NUMERIC belop
        INT start_stasjon_id FK
        INT slutt_stasjon_id FK
    }


---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

Datamodellen tilfredsstiller første normalform (1NF) fordi alle tabellene inneholder atomiske verdier, det vil si at hver kolonne inneholder én enkelt verdi per rad. Det finnes ingen lister, gjentatte grupper eller flere verdier lagret i samme felt. For eksempel lagres hver utleie som en egen rad i tabellen UTLEIE, i stedet for å lagre flere sykkel-IDer i én kolonne hos Kunde. Tilsvarende lagres hver sykkel, lås og stasjon i egne rader i sine egne tabeller. Dermed tilfredsstiller datamodellen første normalform.

**Vurdering av 2. normalform (2NF):**

For at datamodellen skal være i andre normalform (2NF), må alle ikke-nøkkel-attributter i tabellen avhenge av hele primærnøkkelen. I tabeller med sammensatt primærnøkkel betyr dette at ingen kolonner kan avhenge av bare én del av nøkkelen. Alle primærnøklene i datamodellen består kun av èn kolonne, siden modellen ikke bruker sammensatte primærnøkler, kan det ikke oppstå slike avhengigheter. Dermed tilfredstiller datamodellen andre normalform. 

**Vurdering av 3. normalform (3NF):**

For at datamodellen skal være i tredje normalform (3NF), må ingen ikke-nøkkel-attributter være avhengige av andre ikke-nøkkel-attributter. Med andre ord skal attributtene kun være avhengige av primærnøklene. Alle ikke-nøkkel-attributtene i tabellen avhenger kun av primærnøkler. For eksempel vil ikke attributtene adresse avhenge av navn i entiteten STASJON.



**Eventuelle justeringer:**

Modellen er på 3NF

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

SQL-skriptet er lagt i init-scripts/01-init-database.sql og kjøres automatisk ved oppstart av PostgreSQL via docker-compose.

**Antall testdata:**

- Kunder: 5
- Sykler: 100
- Sykkelstasjoner: 5
- Låser: 100
- Utleier: 50



### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

Databasen ble startet med:
docker compose up

Deretter ble det koblet til databasen med:
docker exec -it data1500-postgres psql -U admin -d oblig01

Tabellene og dataene ble verifisert uten feil.

Videre brukte jeg denne: 

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

og fikk dette resultatet:

 table_name 
------------
 kunde
 laas
 stasjon
 sykkel
 utleie
(5 rows)

For å dokumentere at tabellene ble opprettet korrekt, kjørte jeg følgende spørring mot systemkatalogen i PostgreSQL:

SELECT COUNT(*) AS antall_kunder   FROM kunde;
SELECT COUNT(*) AS antall_stasjoner FROM stasjon;
SELECT COUNT(*) AS antall_laas     FROM laas;
SELECT COUNT(*) AS antall_sykler   FROM sykkel;
SELECT COUNT(*) AS antall_utleier  FROM utleie;

og fikk dette resultatet:

SELECT COUNT(*) AS antall_kunder   FROM kunde;
 antall_kunder 
---------------
             5
(1 row)

oblig01=# SELECT COUNT(*) AS antall_stasjoner FROM stasjon;
 antall_stasjoner 
------------------
                5
(1 row)

oblig01=# SELECT COUNT(*) AS antall_laas     FROM laas;
 antall_laas 
-------------
         100
(1 row)

oblig01=# SELECT COUNT(*) AS antall_sykler   FROM sykkel;
 antall_sykler 
---------------
           100
(1 row)

oblig01=# SELECT COUNT(*) AS antall_utleier  FROM utleie;
 antall_utleier 
----------------
             50
(1 row)



## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql

CREATE ROLE kunde;
```

**SQL for å opprette bruker:**

```sql
CREATE USER kunde_1 WITH PASSWORD 'sykkel123';
```

**SQL for å tildele rettigheter:**

```sql
GRANT kunde TO kunde_1;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO kunde;
```

Rollen kunde ble opprettet og gitt SELECT-rettigheter på alle tabeller i public-skjemaet. Brukeren kunde_1 ble opprettet og tildelt rollen kunde, og har dermed kun lesetilgang til databasen.

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
CREATE OR REPLACE VIEW mine_utleier AS
SELECT *
FROM utleie
WHERE kunde_id = current_setting('app.kunde_id', true)::int;

GRANT SELECT ON mine_utleier TO kunde;
REVOKE SELECT ON utleie FROM kunde;

```

**Ulempe med VIEW vs. POLICIES:**

VIEW gir ikke automatisk radnivå-sikkerhet. Hvis brukeren fortsatt har SELECT på utleie kan viewet omgås ved å spørre tabellen direkte. Med POLICY hådheves begrensningen på tabellen uansett hvilke spørringer som kjøres. 

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**
Høysesong: 5 måneder
Mellomsesong: 4 måneder
Lavsesong: 3 måneder

20 000 x 5 = 100 000
5000 x 4 = 20 000
500 x 3 = 1500

100 000 + 20 000 + 1500 = 121 500

Det er totalt 121 500 utleier per år. 


**Estimat for lagringskapasitet:**

For VARCHAR og TEXT har jeg antatt en gjennomsnittlig tekstlengde for å kunne estimere lagringsbehovet.



UTLEIE
5 stk INT (utleie_id, kunde_id, sykkel_id, start_stasjon_id, slutt_stasjon_id): 5 x 4 bytes = 20 B
2  stk TIMESTAMP: 2 x 8 bytes = 16 B
1 stk NUMERIC(10,2): 1 x 16 bytes = 16 B

20 + 16 + 16 = 52 B pr utleie

tabellstørrelse:

121 500 x 52 B = 6 318 000 B = 6.3 MB

SYKKEL (100 rader)
3 stk INT (sykkel_id, laas_id, stasjon_id): 3 x 4 bytes = 12 B 
100 x 12 B = 1200 B = 0.0012 MB

LAAS (100 rader)
2 stk INT (laas_id, stasjon_id): 2 x 4 bytes = 8 bytes
100 x 8 B = 800 B = 0.0008 MB

STASJON (5 rader)
INT stasjon_id: 4 B
VARCHAR navn: 20 B
TEXT adresse: 30 B

4 + 20 + 30 = 54 B
5 x 54 B = 270 B = 0.00027 MB

KUNDE (Antar 10 000 kunder)
INT kunde_id: 4 B
VARCHAR mobilnummer: 15 B
VARCHAR epost: 25 B
VARCHAR fornavn: 10 B
VARCHAR etternavn: 12 B

4 + 15 + 25 + 10 + 12 = 66 B
10 000 x 66 B = 660 000 B = 0.66 MB


**Totalt for første år:**

6.3 MB + 0.0012 MB + 0.0008 MB + 0.00027 MB + 0.66 MB ≈ 7 MB

UTLEIE-tabellen utgjør den klart største delen av lagringsbehovet. De øvrige tabellene bidrar svært lite til total lagringskapasitet første driftsår.

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

[Skriv ditt svar her - gi konkrete eksempler fra CSV-filen som viser redundans]

**Problem 2: Inkonsistens**

[Skriv ditt svar her - forklar hvordan redundans kan føre til inkonsistens med eksempler]

**Problem 3: Oppdateringsanomalier**

[Skriv ditt svar her - diskuter slette-, innsettings- og oppdateringsanomalier]

**Fordeler med en indeks:**

[Skriv ditt svar her - forklar hvorfor en indeks ville gjort spørringen mer effektiv]

**Case 1: Indeks passer i RAM**

[Skriv ditt svar her - forklar hvordan indeksen fungerer når den passer i minnet]

**Case 2: Indeks passer ikke i RAM**

[Skriv ditt svar her - forklar hvordan flettesortering kan brukes]

**Datastrukturer i DBMS:**

[Skriv ditt svar her - diskuter B+-tre og hash-indekser]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

[Skriv ditt svar her - f.eks. heap-fil, LSM-tree, eller annen egnet datastruktur]

**Begrunnelse:**

**Skrive-operasjoner:**

[Skriv ditt svar her - forklar hvorfor datastrukturen er egnet for mange skrive-operasjoner]

**Lese-operasjoner:**

[Skriv ditt svar her - forklar hvordan datastrukturen håndterer sjeldne lese-operasjoner]

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

[Skriv ditt svar her - argumenter for validering i ett eller flere lag]

**Validering i nettleseren:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i applikasjonslaget:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i databasen:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Konklusjon:**

[Skriv ditt svar her - oppsummer hvor validering bør gjøres og hvorfor]

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

[Skriv din refleksjon her - diskuter sentrale konsepter du har lært]

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

[Skriv din refleksjon her - koble oppgaven til læringsmålene i emnet]

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

[Skriv din refleksjon her - diskuter hvilke deler av oppgaven som var mest krevende]

**Hva har du lært om databasedesign:**

[Skriv din refleksjon her - reflekter over prosessen med å designe en database fra bunnen av]

---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

[Bekreft at du har lagt SQL-spørringene i `test-scripts/queries.sql`]


**Eventuelle feil og rettelser:**

[Skriv ditt svar her - hvis noen tester feilet, forklar hva som var feil og hvordan du rettet det]

---

## Del 6: Bonusoppgaver (Valgfri)

### Oppgave 6.1: Trigger for lagerbeholdning

**SQL for trigger:**

```sql
[Skriv din SQL-kode for trigger her, hvis du har løst denne oppgaven]
```

**Forklaring:**

[Skriv ditt svar her - forklar hvordan triggeren fungerer]

**Testing:**

[Skriv ditt svar her - vis hvordan du har testet at triggeren fungerer som forventet]

---

### Oppgave 6.2: Presentasjon

**Lenke til presentasjon:**

[Legg inn lenke til video eller presentasjonsfiler her, hvis du har løst denne oppgaven]

**Hovedpunkter i presentasjonen:**

[Skriv ditt svar her - oppsummer de viktigste punktene du dekket i presentasjonen]

---

**Slutt på besvarelse**
