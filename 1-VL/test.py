import duckdb

con = duckdb.connect(":memory:")

with open("schema.sql", "r", encoding="utf-8") as f:
    con.execute(f.read())

con.execute("""
INSERT INTO Bundesland VALUES
('DE-BE', 'Berlin', NULL);
""")

con.execute("""
INSERT INTO Anbieter VALUES
('DE123456789', 'Testanbieter', 'https://test.de', NULL, NULL, NULL);
""")

con.execute("""
INSERT INTO Koordinate
(Latitude, Longitude, GeoHash, EPSG_Code, Kürzel)
VALUES
(52.5, 13.4, 'u33dc1v0abcd', 4326, 'DE-BE');
""")

con.execute("""
INSERT INTO Station
(ID, Höhe, UStID, Latitude, Longitude)
VALUES
(1, 50, 'DE123456789', 52.5, 13.4);
""")

con.execute("""
INSERT INTO Messwert
(ID, Zeitpunkt, Messwert, Typ, Art)
VALUES
(1, '2025-01-01 00:00:00', ('41', 'm'), 'Niederschlag', 'Nieselregen');
""")

print(con.execute("SELECT * FROM Messwert").fetchall())