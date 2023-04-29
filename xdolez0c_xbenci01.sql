-- odstrani tabulky, pokud existuji
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE Softwarova_aplikace CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Verze CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Fyzicka_osoba CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Organizace CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Vyvojar CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Pracovnik_organizace CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Licencni_smlouva CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Pracoval_na CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Zastupuje CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Nakupuje CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Obsahuje CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;

CREATE TABLE Softwarova_aplikace (
  id NUMBER GENERATED AS IDENTITY,
  nazev VARCHAR2(255) NOT NULL,
  popis VARCHAR2(1000),
  webova_stranka VARCHAR2(255),
  PRIMARY KEY (id)
);

CREATE TABLE Verze (
  kod NUMBER GENERATED AS IDENTITY,
  nazev VARCHAR2(255) NOT NULL,
  popis VARCHAR2(1000),
  platforma VARCHAR2(255) NOT NULL,
  datum_vydani DATE NOT NULL,
  aplikace_id NUMBER NOT NULL,
  PRIMARY KEY (kod),
  FOREIGN KEY (aplikace_id) REFERENCES Softwarova_aplikace(id) ON DELETE CASCADE
);

-- generelizace/specializace je implementovana pomoci "hlavni tabulky" fyzicka osoba, na kterou mají referenci tabulky vyvojar a pracovnik organizace pomoci foreign key"
CREATE TABLE Fyzicka_osoba (
  rodne_cislo VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$')),
  jmeno VARCHAR2(255) NOT NULL,
  prijmeni VARCHAR2(255) NOT NULL,
  telefon VARCHAR2(20),
  email VARCHAR2(255) NOT NULL,
  PRIMARY KEY (rodne_cislo)
);

CREATE TABLE Organizace (
  ico VARCHAR2(8) NOT NULL CHECK (REGEXP_LIKE(ico, '^[0-9]{8}$')),
  obchodni_nazev VARCHAR2(255) NOT NULL,
  pravni_forma VARCHAR2(255) NOT NULL,
  predmet_podnikani VARCHAR2(20) NOT NULL,
  bankovni_ucet VARCHAR2(255) NOT NULL,
  sidlo VARCHAR2(255) NOT NULL,
  PRIMARY KEY (ico)
);

-- dedi vlastnosti fyzicka_osoba
CREATE TABLE Vyvojar (
  rodne_cislo VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$')),
  PRIMARY KEY(rodne_cislo),
  FOREIGN KEY (rodne_cislo) REFERENCES Fyzicka_osoba(rodne_cislo) ON DELETE CASCADE
);

-- dedi vlastnosti fyzicka_osoba
CREATE TABLE Pracovnik_organizace (
  rodne_cislo VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$')),
  PRIMARY KEY(rodne_cislo),
  FOREIGN KEY (rodne_cislo) REFERENCES Fyzicka_osoba(rodne_cislo) ON DELETE CASCADE
);

CREATE TABLE Licencni_smlouva (
  cislo NUMBER GENERATED AS IDENTITY,
  datum_uzavreni DATE NOT NULL,
  ucinnost_od DATE NOT NULL,
  ucinnost_do DATE NOT NULL,
  pracovnik_id VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(pracovnik_id, '^[0-9]{6}/[0-9]{3,4}$')),
  vyvojar_id VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(vyvojar_id, '^[0-9]{6}/[0-9]{3,4}$')),
  celkova_cena DECIMAL(10, 2) CHECK (celkova_cena >= 0),
  CONSTRAINT rozsah_ucinnosti CHECK (ucinnost_od < ucinnost_do),
  PRIMARY KEY (cislo),
  FOREIGN KEY (pracovnik_id) REFERENCES Pracovnik_organizace(rodne_cislo) ON DELETE CASCADE,
  FOREIGN KEY (vyvojar_id) REFERENCES Vyvojar(rodne_cislo) ON DELETE CASCADE
);

CREATE TABLE Pracoval_na (
  rodne_cislo VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$')),
  verze_kod NUMBER NOT NULL,
  datum_od DATE NOT NULL,
  datum_do DATE NOT NULL,
  PRIMARY KEY (rodne_cislo, verze_kod),
  FOREIGN KEY (rodne_cislo) REFERENCES Vyvojar(rodne_cislo) ON DELETE CASCADE,
  FOREIGN KEY (verze_kod) REFERENCES Verze(kod) ON DELETE CASCADE,
  CONSTRAINT rozsah_datumu CHECK (datum_od < datum_do)
);

CREATE TABLE Zastupuje (
  organizace_id VARCHAR2(8) NOT NULL,
  pracovnik_id VARCHAR2(11) NOT NULL,
  datum_od DATE NOT NULL,
  datum_do DATE NOT NULL,
  PRIMARY KEY (organizace_id, pracovnik_id),
  FOREIGN KEY (organizace_id) REFERENCES Organizace(ico) ON DELETE CASCADE,
  FOREIGN KEY (pracovnik_id) REFERENCES Pracovnik_organizace(rodne_cislo) ON DELETE CASCADE,
  CONSTRAINT rozsah_zastupovani CHECK (datum_od < datum_do)
);

CREATE TABLE Nakupuje (
  organizace_id VARCHAR2(8) NOT NULL,
  smlouva_cislo NUMBER NOT NULL,
  PRIMARY KEY (organizace_id, smlouva_cislo),
  FOREIGN KEY (organizace_id) REFERENCES Organizace(ico) ON DELETE CASCADE,
  FOREIGN KEY (smlouva_cislo) REFERENCES Licencni_smlouva(cislo) ON DELETE CASCADE
);

CREATE TABLE Obsahuje (
  smlouva_cislo NUMBER NOT NULL,
  verze_kod NUMBER NOT NULL,
  pocet_instalaci INT NOT NULL,
  PRIMARY KEY (smlouva_cislo, verze_kod),
  FOREIGN KEY (smlouva_cislo) REFERENCES Licencni_smlouva(cislo) ON DELETE CASCADE,
  FOREIGN KEY (verze_kod) REFERENCES Verze(kod) ON DELETE CASCADE
);

INSERT INTO Softwarova_aplikace (nazev, popis, webova_stranka)
VALUES ('Word', 'Text editor', 'https://www.office.com/word');

INSERT INTO Softwarova_aplikace (nazev, popis, webova_stranka)
VALUES ('Excel', 'Spreadsheet program', 'https://www.office.com/excel');

INSERT INTO Verze (nazev, popis, platforma, datum_vydani, aplikace_id)
VALUES ('Word 2022', 'Latest version of Word', 'Windows', TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1);

INSERT INTO Verze (nazev, popis, platforma, datum_vydani, aplikace_id)
VALUES ('Excel 2022', 'Latest version of Excel', 'Windows', TO_DATE('2022-01-01', 'YYYY-MM-DD'), 2);

INSERT INTO Fyzicka_osoba (rodne_cislo, jmeno, prijmeni, telefon, email)
VALUES ('012345/1234', 'John', 'Doe', '123456789', 'john.doe@example.com');

INSERT INTO Fyzicka_osoba (rodne_cislo, jmeno, prijmeni, telefon, email)
VALUES ('012345/1235', 'Peter', 'Parker', '123456789', 'peter.parker@example.com');

INSERT INTO Organizace (ico, obchodni_nazev, pravni_forma, predmet_podnikani, bankovni_ucet, sidlo)
VALUES ('12345678', 'Example Ltd.', 's.r.o.', 'Software development', '123456789/0100', '123 Main Street, Anytown');

INSERT INTO Vyvojar (rodne_cislo)
VALUES ('012345/1234');

INSERT INTO Pracovnik_organizace (rodne_cislo)
VALUES ('012345/1235');

INSERT INTO Licencni_smlouva (datum_uzavreni, ucinnost_od, ucinnost_do, pracovnik_id, vyvojar_id, celkova_cena)
VALUES (TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), '012345/1235', '012345/1234', 1000);

INSERT INTO Licencni_smlouva (datum_uzavreni, ucinnost_od, ucinnost_do, pracovnik_id, vyvojar_id, celkova_cena)
VALUES (TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), '012345/1235', '012345/1234', 1000);

INSERT INTO Pracoval_na (rodne_cislo, verze_kod, datum_od, datum_do)
VALUES ('012345/1234', 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-12-31', 'YYYY-MM-DD'));

INSERT INTO Zastupuje (organizace_id, pracovnik_id, datum_od, datum_do)
VALUES ('12345678', '012345/1235', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'));

INSERT INTO Nakupuje (organizace_id, smlouva_cislo)
VALUES ('12345678', 1);

INSERT INTO Obsahuje (smlouva_cislo, verze_kod, pocet_instalaci)
VALUES (1,1,3);

INSERT INTO Obsahuje (smlouva_cislo, verze_kod, pocet_instalaci)
VALUES (2,2,10);

-- Ziskat vsetky verzie softwarovej aplikacie (DOUBLE JOIN)
-- USECASE: Po kliknuti na detail se zobrazi vsechny verze dane aplikace
SELECT *
FROM Verze JOIN Softwarova_aplikace
  ON Verze.aplikace_id = Softwarova_aplikace.id;

-- Ziskat pocty instalacii pre dane verzie (DOUBLE JOIN)
-- USECASE: zobrazeni poctu instalaci dane verze pri zobrazeni detailu verze
SELECT Verze.nazev, Verze.kod, Obsahuje.pocet_instalaci
FROM Obsahuje JOIN Verze
  ON Obsahuje.verze_kod = Verze.kod;

-- Rodne cisla pracovnikov pre jednotlive organizacie (TRIPLE JOIN)
-- USECASE: Zobrazenie pracovnikov danej organizacie pri kliknuti na detail organizace
SELECT Pracovnik_organizace.rodne_cislo, Zastupuje.datum_od, Zastupuje.datum_do, Organizace.obchodni_nazev, Organizace.ico
FROM Pracovnik_organizace
JOIN Zastupuje
  ON Pracovnik_organizace.rodne_cislo = Zastupuje.pracovnik_id
JOIN Organizace
  ON Zastupuje.organizace_id = Organizace.ico;

-- Ziskat pocet licencnich smluv pro danou organizaci (JOIN + COUNT + GROUP BY)
-- USECASE: zobrazeni poctu licencnich smluv pro danou organizaci pro kliknuti na detail organizace
SELECT Organizace.obchodni_nazev, COUNT(Nakupuje.smlouva_cislo)
FROM Organizace JOIN Nakupuje
  ON Organizace.ico = Nakupuje.organizace_id
GROUP BY Organizace.obchodni_nazev;

-- Ziskat celkovou cenu licencnich smluv za roky dane organizace (JOIN + SUM + GROUP BY)
-- USECASE: vykresleni grafu s celkovou cenou licencnich smluv za roky v pro statistiku
SELECT TO_CHAR(datum_uzavreni, 'YYYY') AS rok, SUM(celkova_cena)
FROM Licencni_smlouva
GROUP BY TO_CHAR(datum_uzavreni, 'YYYY');

-- Ziskat vsechny licencni smlouvy verze mladsi nez minuly rok (JOIN + WHERE + IN)
-- USECASE: filtr pri zobrazovani licencnich smluv
SELECT *
FROM Licencni_smlouva
JOIN Obsahuje
  ON Licencni_smlouva.cislo = Obsahuje.smlouva_cislo
WHERE Obsahuje.verze_kod
IN (SELECT kod FROM Verze WHERE datum_vydani > TO_DATE('2020-01-01', 'YYYY-MM-DD'));

-- select pomoci IN (SELECT + IN + JOIN + WHERE)
-- USECASE: zobrazeni licencnich smluv pro vybrane verze, filtr podle verzi
SELECT *
FROM Licencni_smlouva
JOIN Obsahuje
  ON Licencni_smlouva.cislo = Obsahuje.smlouva_cislo
WHERE Obsahuje.verze_kod
IN (SELECT kod FROM Verze WHERE nazev = 'Word 2022' OR nazev = 'Excel 2022');

-- select pomoci (WITH + CASE)
-- USECASE: zobrazeni aktivnich licencnich pro vybrane fyzicke osoby
WITH aktivni_licencni_smlouvy AS (
    SELECT *
    FROM Licencni_smlouva
    WHERE ucinnost_do >= SYSDATE OR ucinnost_do IS NULL
)
SELECT CASE
    WHEN pracovnik_id IS NOT NULL THEN pracovnik_id
    ELSE vyvojar_id
END AS vyvojar_id
FROM aktivni_licencni_smlouvy
GROUP BY CASE
    WHEN pracovnik_id IS NOT NULL THEN pracovnik_id
    ELSE vyvojar_id
END

------------------------------------------------------------
-- TRIGGERS
------------------------------------------------------------
-- Tento trigger sleduje max. pocet aktivnych licencii pre vyvojara
CREATE OR REPLACE TRIGGER dev_version_limit
BEFORE INSERT OR UPDATE ON Pracoval_na
FOR EACH ROW
DECLARE
  v_version_count NUMBER;
BEGIN
  -- pocet verzii na ktorych pracuje vyvojar
  SELECT COUNT(*)
  INTO v_version_count
  FROM Pracoval_na p
  JOIN Verze v ON p.verze_kod = v.kod
  WHERE p.rodne_cislo = :new.rodne_cislo AND v.datum_do >= SYSDATE;

  -- ak je pocet verzii vacsi ako 3, vyhodi sa chyba pred insertom alebo updatom
  IF v_version_count >= 3 THEN
    RAISE_APPLICATION_ERROR(-20001, 'The developer is already working on 5 or more active versions.');
  END IF;
END;

-- Pri vlozeni novej aplikacie sa automaticky vygeneruje webova stranka ak nie je zadana
CREATE OR REPLACE TRIGGER generuj_webova_stranka
BEFORE INSERT ON Softwarova_aplikace
FOR EACH ROW
BEGIN
  IF :new.webova_stranka IS NULL THEN
  :new.webova_stranka := 'https://www.' || REPLACE(LOWER(:new.nazev), ' ', '-') || '.com';
  END IF;
END;

-- Showcase triggers
-- 1. Vytvori novu verziu a otestuje trigger na maximalny pocet aktivnych verzii pre vyvojara
INSERT INTO Verze (nazev, popis, platforma, datum_vydani, aplikace_id)
VALUES ('Excel 2023', 'Latest version of Excel', 'Windows', TO_DATE('2022-01-01', 'YYYY-MM-DD'), 2);
INSERT INTO Pracoval_na (rodne_cislo, verze_kod, datum_od, datum_do)
VALUES ('012345/1234', 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
INSERT INTO Pracoval_na (rodne_cislo, verze_kod, datum_od, datum_do)
VALUES ('012345/1234', 2, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
INSERT INTO Pracoval_na (rodne_cislo, verze_kod, datum_od, datum_do)
VALUES ('012345/1234', 3, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));

-- 2. Skontroluje generaciu webovej stranky
SELECT * FROM Softwarova_aplikace;
INSERT INTO Softwarova_aplikace (nazev, popis, webova_stranka, datum_vydani)
VALUES ('Skvela aplikacia', 'Test na generaciu web adresy', NULL, TO_DATE('2020-01-01', 'YYYY-MM-DD'));
SELECT * FROM Softwarova_aplikace;

-- TODO
-- definice pristupovych prav k databazovym objektum pro druheho clena tymu
-- vytvoreni alespon jednoho materialozvaneho pohledu patrici druhemu clenu a pouzivajici tabulky definovane prvnim clenem

-- DONE
-- showcase the triggers - insert/select
-- explicitni vytvoreni alespon jednoho indexu, aby pomohl optimalizovat zpracovani dotazu, uveden dotaz, na ktery ma index vliv, popsat v docs (lze zkombinovat s EXPLAIN PLAN)
-- pouzit alespon jeden EXPLAIN PLAN pro ziskani informaci o pranu provedeni databazoveho dotazu se spojnemo alespon dvou tabulek, agregacni funkci a klauzuli group by
-- 2x triggers non trivial DONE
-- vytvoreni alespon dvou netrivialnich ulozenych procedur, ve kterych musi byt dohromady - stored procedure DONE
    -- jeden kurzor
    -- osetreni vyjimek
    -- pouziti promenne s datovym typem odkazujicim se na radek tabulky (table_name.column_name%TYPE nebo table_name%ROWTYPE)
-- vyvtvoreni komplexniho prikazu select s WITH a operator CASE. v poznamce co dotaz ziskava DONE

------------------------------------------------------------
-- Procedures
------------------------------------------------------------
-- Ziska najnovsie verzie aplikacii zoradene abecedne podla nazvu aplikacie
-- offset a limit sluzia na strankovanie vysledkov - pagination
-- o_result je vystupny kurzor, ktory sa pouzije na ziskanie vysledkov
CREATE OR REPLACE PROCEDURE get_latest_versions(
  p_offset NUMBER,
  p_limit NUMBER,
  o_result OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN o_result FOR
    SELECT a.nazev, a.popis, a.webova_stranka, v.nazev AS verze_nazev, v.popis AS verze_popis, v.platforma, v.datum_vydani
    FROM softwarova_aplikace a
    JOIN verze v ON v.aplikace_id = a.id
    WHERE v.datum_vydani = (
      SELECT MAX(datum_vydani)
      FROM verze
      WHERE aplikace_id = v.aplikace_id
    )
    ORDER BY a.nazev
    OFFSET p_offset ROWS FETCH NEXT p_limit ROWS ONLY;
END;

-- Procedura, ktora ziska vsetky licencne smluvy pre vybranu aplikaciu na zaklade jej nazvu
-- offset a limit sluzia na strankovanie vysledkov - pagination
-- o_result je vystupny kurzor, ktory sa pouzije na ziskanie vysledkov
CREATE OR REPLACE PROCEDURE get_licenses_for_app(
  p_app_name softwarova_aplikace.nazev%TYPE,
  p_offset NUMBER,
  p_limit NUMBER,
  o_result OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN o_result FOR
    SELECT ls.cislo, ls.celkova_cena, ls.ucinnost_od, ls.ucinnost_do, ls.pracovnik_id, ls.vyvojar_id
    FROM licencni_smlouva ls
    JOIN obsahuje o ON o.smlouva_cislo = ls.cislo
    JOIN verze v ON v.kod = o.verze_kod
    JOIN softwarova_aplikace a ON a.id = v.aplikace_id
    WHERE a.nazev = p_app_name;
END;

------------------------------------------------------------
-- INDEX + EXPLAIN PLAN
------------------------------------------------------------
-- Vytvori index na stlpec id tabulky Softwarova_aplikace
-- pre zrychlenie joinu s tabulkou Verze
-- SELECT zrata pocet verzi aplikacie a zoradi ich podla nazvu aplikacie
CREATE INDEX idx_softwarova_aplikace_verze ON Softwarova_aplikace (id)
INVISIBLE;

EXPLAIN PLAN FOR
SELECT Softwarova_aplikace.nazev, COUNT(Verze.kod)
FROM Softwarova_aplikace
JOIN Verze ON Softwarova_aplikace.id = Verze.aplikace_id
GROUP BY Softwarova_aplikace.nazev;

-- TODO: Come back to this 
-- define access rights for all tables only for the first member of the team
GRANT ALL ON Verze TO xbenci01;
GRANT ALL ON Licencni_smlouva TO xbenci01;
GRANT ALL ON Obsahuje TO xbenci01;
GRANT ALL ON Pracoval_na TO xbenci01;
GRANT ALL ON Pracovnik_organizace TO xbenci01;

-- materialized view pro ziskani vsetkych licenci dle jmena aplikace
CREATE MATERIALIZED VIEW xbenci01.licence_for_app AS
SELECT a.nazev AS aplikace_nazev, ls.cislo, ls.celkova_cena, ls.ucinnost_od, ls.ucinnost_do, ls.pracovnik_id, ls.vyvojar_id
FROM xbenci01.licencni_smlouva ls
JOIN xbenci01.obsahuje o ON o.smlouva_cislo = ls.cislo
JOIN xbenci01.verze v ON v.kod = o.verze_kod
JOIN xbenci01.softwarova_aplikace a ON a.id = v.aplikace_id
GROUP BY v.aplikace_id;
