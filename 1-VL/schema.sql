CREATE TABLE Anbieter (
    UStID VARCHAR PRIMARY KEY,
    Name VARCHAR NOT NULL,
    Website VARCHAR NOT NULL,
    Organisationsform VARCHAR,
    API_URL VARCHAR UNIQUE,
    Lizenz VARCHAR,
-- Es sollen nur Anbieter abgebildet werden können, die in Deutschland umsatzsteuerpflichtig sind. Beachten Sie hierzu die Regeln zur Formatierung von Umsatzsteuer-Identifikationsnummern. Außerdem ist die Angabe von Name und Website verpflichtend.
    CHECK (regexp_full_match(UStID, 'DE[0-9]{9}')),
--Für Webseiten und API-URLs soll sichergestellt werden, dass diese immer das HTTP-Protokoll (oder die gesicherte Version davon) benutzen. Alle API-URLs müssen unterschiedlich sein.
    CHECK (regexp_full_match(Website, 'https?://.*')),
    CHECK (API_URL IS NULL OR regexp_full_match(API_URL, 'https?://.*'))
);

CREATE TABLE Bundesland (
    Kürzel VARCHAR PRIMARY KEY,
    Name VARCHAR NOT NULL UNIQUE,
    Aufsichtsbehörde VARCHAR,
    
    CHECK (length(Name) > 0),

-- Bundesland-Kürzel sollen nach dem ISO 3166-2 Standard formatiert werden. Außerdem soll sichergestellt werden, dass nur deutsche Bundesländer eingefügt werden können. Beachten Sie, dass alle Bundesländer einen Namen haben müssen.
    CHECK (regexp_full_match(Kürzel, 'DE-[A-Z]{2}')),
    CHECK (Kürzel IN (
        'DE-BB', 'DE-BE', 'DE-BW', 'DE-BY',
        'DE-HB', 'DE-HE', 'DE-HH', 'DE-MV',
        'DE-NI', 'DE-NW', 'DE-RP', 'DE-SH',
        'DE-SL', 'DE-SN', 'DE-ST', 'DE-TH'
    ))
);

CREATE SEQUENCE id_sequence START 1;

CREATE TABLE Koordinate (
    Latitude DOUBLE NOT NULL,
    Longitude DOUBLE NOT NULL,
    GeoHash VARCHAR NOT NULL,
    EPSG_Code INTEGER NOT NULL,
    Kürzel VARCHAR NOT NULL,

    PRIMARY KEY (Latitude, Longitude),
    FOREIGN KEY (Kürzel) REFERENCES Bundesland(Kürzel),

    CHECK (Latitude BETWEEN -90 AND 90),
    CHECK (Longitude BETWEEN -180 AND 180),
    CHECK (EPSG_Code = 4326),
    CHECK (length(GeoHash) <= 12)
);

CREATE TABLE Station (
    ID INTEGER PRIMARY KEY DEFAULT nextval('id_sequence'),
    Höhe SMALLINT NOT NULL,
    Höhe_ft DECIMAL(8,3) GENERATED ALWAYS AS (ROUND(Höhe * 3.28084, 3)),
    UStID VARCHAR NOT NULL,
    Latitude DOUBLE NOT NULL,
    Longitude DOUBLE NOT NULL,

    FOREIGN KEY (UStID) REFERENCES Anbieter(UStID),
    FOREIGN KEY (Latitude, Longitude) REFERENCES Koordinate(Latitude, Longitude),
    
    CHECK (Höhe BETWEEN -11000 AND 9000)
);


CREATE TABLE verbunden_mit (
    StationA_ID INTEGER NOT NULL,
    StationB_ID INTEGER NOT NULL,
    Abstand REAL NOT NULL,

    PRIMARY KEY (StationA_ID, StationB_ID),

    FOREIGN KEY (StationA_ID) REFERENCES Station(ID),
    FOREIGN KEY (StationB_ID) REFERENCES Station(ID),

    CHECK (Abstand > 0),
);

CREATE TABLE arbeitet_in (
    UStID VARCHAR NOT NULL,
    Kürzel VARCHAR NOT NULL,

    PRIMARY KEY (UStID, Kürzel),

    FOREIGN KEY (UStID) REFERENCES Anbieter(UStID),
    FOREIGN KEY (Kürzel) REFERENCES Bundesland(Kürzel)
);

CREATE TABLE Polygon (
    Kürzel VARCHAR NOT NULL,
    Latitude DOUBLE NOT NULL,
    Longitude DOUBLE NOT NULL,

    PRIMARY KEY (Kürzel, Latitude, Longitude),

    FOREIGN KEY (Kürzel) REFERENCES Bundesland(Kürzel),
    FOREIGN KEY (Latitude, Longitude) REFERENCES Koordinate(Latitude, Longitude)
);

CREATE TABLE Messwert (
    ID INTEGER NOT NULL,
    Zeitpunkt TIMESTAMP,
    Messwert STRUCT(Wert DOUBLE, Einheit VARCHAR) NOT NULL,
    Typ VARCHAR NOT NULL,

    Art VARCHAR,
    Richtung SMALLINT,
    hat_schatten BOOLEAN,
    
    PRIMARY KEY(ID, ZEITPUNKT),
    FOREIGN KEY (ID) REFERENCES Station(ID),

    CHECK (Typ IN ('Niederschlag', 'Sonne', 'Temperatur', 'Wind')),

    CHECK (struct_extract("Messwert", 'Einheit') IN ('A', 'cd', 'K', 'kg', 'm', 'mol', 's')),

    CHECK (
        Typ = 'Wind'
        OR (Typ = 'Niederschlag' AND struct_extract("Messwert", 'Einheit') = 'm')
        OR (Typ = 'Sonne' AND struct_extract("Messwert", 'Einheit') = 'cd')
        OR (Typ = 'Temperatur' AND struct_extract("Messwert", 'Einheit') = 'K')
    ),

    CHECK (Richtung IS NULL OR Richtung BETWEEN 0 AND 359),

    CHECK (
        (Typ = 'Niederschlag' AND Art IS NOT NULL AND Richtung IS NULL AND hat_schatten IS NULL)
        OR
        (Typ = 'Wind' AND Richtung IS NOT NULL AND Art IS NULL AND hat_schatten IS NULL)
        OR
        (Typ = 'Sonne' AND hat_schatten IS NOT NULL AND Art IS NULL AND Richtung IS NULL)
        OR
        (Typ = 'Temperatur' AND Art IS NULL AND Richtung IS NULL AND hat_schatten IS NULL)
    )
);
