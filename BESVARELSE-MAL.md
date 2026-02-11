# Besvarelse - Refleksjon og Analyse

**Student:** [Niyat Tesfaghabr]

**Studentnummer:** [403851]

**Dato:** [Innleveringsdato]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**

[
1. Kunde 
2. Stasjon
3. Lås
4. Sykkel 
5. Utleie
]
   

**Attributter for hver entitet:**

[1. Kunde: Dette er minimumet som trengs for å identifisere kunden og knytte utleier til riktig person.
- kunde_id
- mobilnummer
- epost
- fornavn
- etternavn

2. Stasjon: Dette trengs for å vite hvor sykler kan hentes/leveres. 
   - stasjon_id
   - navn
   - adresse

3. Lås: Dette trengs fordi innlevering registreres ved å feste sykkelen i en lås.
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
   - slutt_stasjon]


### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

[
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

[1. Kunde 
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

3. Lås
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

[erDiagram

    KUNDE ||--o{ UTLEIE : har
    SYKKEL ||--o{ UTLEIE : brukes_i
    STASJON ||--o{ LAAS : har
    STASJON ||--o{ SYKKEL : parkerer
    LAAS ||--o| SYKKEL : laaser
    STASJON ||--o{ UTLEIE : start
    STASJON ||--o{ UTLEIE : slutt

    KUNDE {
        SERIAL kunde_id
        VARCHAR(15) mobilnummer
        VARCHAR(200) epost
        VARCHAR(50) fornavn
        VARCHAR(50) etternavn
    }

    STASJON {
        SERIAL stasjon_id
        VARCHAR(100) navn
        TEXT adresse
    }

    LAAS {
        SERIAL laas_id
        INT stasjon_id
    }

    SYKKEL {
        SERIAL sykkel_id
        INT stasjon_id
        INT laas_id
    }

    UTLEIE {
        SERIAL utleie_id
        INT kunde_id
        INT sykkel_id
        TIMESTAMP start_tid
        TIMESTAMP slutt_tid
        NUMERIC belop
        INT start_stasjon_id
        INT slutt_stasjon_id
    }]

---

### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**

[Skriv ditt svar her - forklar hvilke primærnøkler du har valgt for hver entitet og hvorfor]

[1. Kunde 
- kunde_id SERIAL
- mobilnummer VARCHAR(15)
- epost VARCHAR(200)
- fornavn VARCHAR(50) 
- etternavn VARCHAR(50)
  
2. Stasjon
- stasjon_id SERIAL 
- navn VARCHAR(100)
- adresse TEXT
  
3. Lås
- lås_id SERIAL
- stasjon_id INT
  
4. Sykkel
- sykkel_id SERIAL
- stasjon_id INT
- lås_id INT
  
5. Utleie
- utleie_id SERIAL
- kunde_id INT
- sykkel_id INT
- start_tid TIMESTANP
- slutt_tid TIMESTAMP
- beløp NUMERIC(10,2) 
- start_stasjon_id INT 
- slutt_stasjon_id INT]

**Naturlige vs. surrogatnøkler:**

[Skriv ditt svar her - diskuter om du har brukt naturlige eller surrogatnøkler og hvorfor]

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

[Skriv ditt svar her - list opp alle forholdene mellom entitetene og angi kardinalitet]

**Fremmednøkler:**

[Skriv ditt svar her - list opp alle fremmednøklene og forklar hvordan de implementerer forholdene]

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

[Skriv ditt svar her - forklar om datamodellen din tilfredsstiller 1NF og hvorfor]

**Vurdering av 2. normalform (2NF):**

[Skriv ditt svar her - forklar om datamodellen din tilfredsstiller 2NF og hvorfor]

**Vurdering av 3. normalform (3NF):**

[Skriv ditt svar her - forklar om datamodellen din tilfredsstiller 3NF og hvorfor]

**Eventuelle justeringer:**

[Skriv ditt svar her - hvis modellen ikke var på 3NF, forklar hvilke justeringer du har gjort]

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

[Bekreft at du har lagt SQL-skriptet i `init-scripts/01-init-database.sql`]

**Antall testdata:**

- Kunder: [antall]
- Sykler: [antall]
- Sykkelstasjoner: [antall]
- Låser: [antall]
- Utleier: [antall]

---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

[Skriv ditt svar her - f.eks. skjermbilder eller output fra terminalen som viser at databasen ble opprettet uten feil]

**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

```
[Skriv resultatet av spørringen her - list opp alle tabellene som ble opprettet]
```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
[Skriv din SQL-kode for å opprette rollen 'kunde' her]
```

**SQL for å opprette bruker:**

```sql
[Skriv din SQL-kode for å opprette brukeren 'kunde_1' her]
```

**SQL for å tildele rettigheter:**

```sql
[Skriv din SQL-kode for å tildele rettigheter til rollen her]
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
[Skriv din SQL-kode for VIEW her]
```

**Ulempe med VIEW vs. POLICIES:**

[Skriv ditt svar her - diskuter minst én ulempe med å bruke VIEW for autorisasjon sammenlignet med POLICIES]

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

[Skriv din utregning her]

**Estimat for lagringskapasitet:**

[Skriv din utregning her - vis hvordan du har beregnet lagringskapasiteten for hver tabell]

**Totalt for første år:**

[Skriv ditt estimat her]

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
