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

CREATE TABLE Vyvojar (
  rodne_cislo VARCHAR2(11) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '^[0-9]{6}/[0-9]{3,4}$')),
  PRIMARY KEY(rodne_cislo),
  FOREIGN KEY (rodne_cislo) REFERENCES Fyzicka_osoba(rodne_cislo) ON DELETE CASCADE
);

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

INSERT INTO Pracoval_na (rodne_cislo, verze_kod, datum_od, datum_do)
VALUES ('012345/1234', 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-12-31', 'YYYY-MM-DD'));

INSERT INTO Zastupuje (organizace_id, pracovnik_id, datum_od, datum_do)
VALUES ('12345678', '012345/1235', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'));

INSERT INTO Nakupuje (organizace_id, smlouva_cislo)
VALUES ('12345678', 1);