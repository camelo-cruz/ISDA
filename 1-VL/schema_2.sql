CREATE TABLE Ort (
    OrtID UUID PRIMARY KEY,
    Straße VARCHAR NOT NULL,
    Hausnummer VARCHAR NOT NULL,
    PLZ VARCHAR NOT NULL CHECK (regexp_full_match(PLZ, '[0-9]{5}')),
    Stadt VARCHAR NOT NULL
);

INSERT INTO Ort
SELECT uuid(), Straße, Hausnummer, PLZ, Stadt
FROM (
    VALUES
    ('Albrechtstraße', '5', '10117', 'Berlin'),
    ('Müllerstraße', '13', '78266', 'Büsingen am Hochrhein'),
    ('Bjoernsonstraße', '10', '10439', 'Berlin'),
    ('Willy-Brandt-Platz', '3b', '81829', 'München'),
    ('Albrechtstraße', '13', '80636', 'München')
) AS t(Straße, Hausnummer, PLZ, Stadt);

ALTER TABLE Hotel ADD COLUMN OrtID UUID;

UPDATE Hotel SET OrtID = (
    SELECT OrtID FROM Ort
    WHERE Straße = 'Albrechtstraße'
      AND Hausnummer = '5'
      AND PLZ = '10117'
      AND Stadt = 'Berlin'
)
WHERE HotelID = 1001;

UPDATE Hotel SET OrtID = (
    SELECT OrtID FROM Ort
    WHERE Straße = 'Müllerstraße'
      AND Hausnummer = '13'
      AND PLZ = '78266'
      AND Stadt = 'Büsingen am Hochrhein'
)
WHERE HotelID IN (1002, 1003);

UPDATE Hotel SET OrtID = (
    SELECT OrtID FROM Ort
    WHERE Straße = 'Bjoernsonstraße'
      AND Hausnummer = '10'
      AND PLZ = '10439'
      AND Stadt = 'Berlin'
)
WHERE HotelID = 1004;

UPDATE Hotel SET OrtID = (
    SELECT OrtID FROM Ort
    WHERE Straße = 'Willy-Brandt-Platz'
      AND Hausnummer = '3b'
      AND PLZ = '81829'
      AND Stadt = 'München'
)
WHERE HotelID = 1005;

UPDATE Hotel SET OrtID = (
    SELECT OrtID FROM Ort
    WHERE Straße = 'Albrechtstraße'
      AND Hausnummer = '13'
      AND PLZ = '80636'
      AND Stadt = 'München'
)
WHERE HotelID = 1006;


ALTER TABLE Hotel DROP COLUMN Adresse;
ALTER TABLE Hotel
RENAME COLUMN Column_6 TO Anz_Apartments;

ALTER TABLE MitarbeiterIn
ALTER COLUMN Angestellt_am TYPE DATE
USING strptime(Angestellt_am, '%m-%d-%Y');

CREATE TABLE ManagerIn (
    PersID VARCHAR PRIMARY KEY,
    Letzte_Fortbildung DATE,
    Nächste_Fortbildung DATE NOT NULL,
    Bonus DECIMAL(9,2) NOT NULL CHECK (Bonus >= 0),
    FOREIGN KEY (PersID) REFERENCES MitarbeiterIn(PersID),
    CHECK (
        Letzte_Fortbildung IS NULL
        OR Letzte_Fortbildung < Nächste_Fortbildung
    )
);

INSERT INTO ManagerIN
SELECT PersID, DATE '2023-10-21', DATE '2024-06-12', 936.50
FROM MitarbeiterIn
WHERE Nachname = 'Seiler' AND Vorname = 'Marena';

INSERT INTO ManagerIn
SELECT PersID, DATE '2024-01-13', DATE '2024-09-02', 0.00
FROM MitarbeiterIn
WHERE Nachname = 'Meddings' AND Vorname = 'Otis';

INSERT INTO ManagerIn
SELECT PersID, DATE '2023-11-14', DATE '2024-06-12', 1500.00
FROM MitarbeiterIn
WHERE Nachname = 'Van den Dael' AND Vorname = 'Cam';

INSERT INTO ManagerIn
SELECT PersID, DATE '2024-01-13', DATE '2024-09-02', 355.78
FROM MitarbeiterIn
WHERE Nachname = 'Trazzi' AND Vorname = 'Sofie';

INSERT INTO ManagerIn
SELECT PersID, DATE '2023-11-14', DATE '2024-07-27', 0.01
FROM MitarbeiterIn
WHERE Nachname = 'Dermot' AND Vorname = 'Colline';

INSERT INTO ManagerIn
SELECT PersID, DATE '2024-01-13', DATE '2024-07-27', 0.00
FROM MitarbeiterIn
WHERE Nachname = 'Lingner' AND Vorname = 'Bing';

ALTER TABLE MitarbeiterIn
ADD COLUMN Gehalt UINTEGER;

UPDATE MitarbeiterIn
SET Gehalt =
    CASE Abteilung
        WHEN 'Sicherheit' THEN 2100
        WHEN 'Reinigung' THEN 2300
        WHEN 'Rezeption' THEN 2800
        WHEN 'Management' THEN 5000
    END;

DELETE FROM MitarbeiterIn WHERE Vorname LIKE 'N%' AND Nachname LIKE 'S%';