-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller
CREATE TABLE kunde (
    kunde_id SERIAL PRIMARY KEY,
    mobilnummer VARCHAR(15),
    epost VARCHAR(200),
    fornavn VARCHAR(50),
    etternavn VARCHAR(50)
);

CREATE TABLE stasjon (
    stasjon_id SERIAL PRIMARY KEY,
    navn VARCHAR(100),
    adresse TEXT
);

CREATE TABLE laas (
    laas_id SERIAL PRIMARY KEY,
    stasjon_id INT REFERENCES stasjon(stasjon_id)
);

CREATE TABLE sykkel (
    sykkel_id SERIAL PRIMARY KEY,
    stasjon_id INT REFERENCES stasjon(stasjon_id),
    laas_id INT REFERENCES laas(laas_id)
);

CREATE TABLE utleie (
    utleie_id SERIAL PRIMARY KEY,
    kunde_id INT REFERENCES kunde(kunde_id),
    sykkel_id INT REFERENCES sykkel(sykkel_id),
    start_tid TIMESTAMP,
    slutt_tid TIMESTAMP,
    belop NUMERIC(10,2),
    start_stasjon_id INT REFERENCES stasjon(stasjon_id),
    slutt_stasjon_id INT REFERENCES stasjon(stasjon_id)
);


-- Sett inn testdata
INSERT INTO kunde (mobilnummer, epost, fornavn, etternavn) VALUES
('41234567', 'ola@test.no', 'Ola', 'Nordmann'),
('42345678', 'kari@test.no', 'Kari', 'Hansen'),
('43456789', 'per@test.no', 'Per', 'Johansen'),
('44567890', 'mina@test.no', 'Mina', 'Olsen'),
('45678901', 'sara@test.no', 'Sara', 'Berg');

INSERT INTO stasjon (navn, adresse) VALUES
('Sentrum', 'Gate 1'),
('Majorstuen', 'Gate 2'),
('Grunerlokka', 'Gate 3'),
('Aker Brygge', 'Gate 4'),
('Blindern', 'Gate 5');

INSERT INTO laas (stasjon_id)
SELECT s.stasjon_id
FROM stasjon s, generate_series(1,20);

INSERT INTO sykkel (stasjon_id, laas_id)
SELECT stasjon_id, laas_id
FROM laas
LIMIT 100;

INSERT INTO utleie (kunde_id, sykkel_id, start_tid, start_stasjon_id)
SELECT
    1,
    sykkel_id,
    NOW(),
    1
FROM sykkel
LIMIT 50;




-- DBA setninger (rolle: kunde, bruker: kunde_1)
-- DBA-innstillinger: Ikke nødvendig i denne oppgaven (bruker standard bruker fra docker-compose).



-- Eventuelt: Opprett indekser for ytelse

CREATE INDEX IF NOT EXISTS idx_laas_stasjon_id ON laas(stasjon_id);
CREATE INDEX IF NOT EXISTS idx_sykkel_stasjon_id ON sykkel(stasjon_id);
CREATE INDEX IF NOT EXISTS idx_sykkel_laas_id ON sykkel(laas_id);

CREATE INDEX IF NOT EXISTS idx_utleie_kunde_id ON utleie(kunde_id);
CREATE INDEX IF NOT EXISTS idx_utleie_sykkel_id ON utleie(sykkel_id);
CREATE INDEX IF NOT EXISTS idx_utleie_start_stasjon_id ON utleie(start_stasjon_id);
CREATE INDEX IF NOT EXISTS idx_utleie_slutt_stasjon_id ON utleie(slutt_stasjon_id);



-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
