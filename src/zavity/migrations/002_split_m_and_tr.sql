-- Metrické a trapézové závity mají oddělené tabulky, aby se při vyhledání
-- načítala pouze datová sada určená prefixem označení.
CREATE TABLE zavit_m (
    id INTEGER PRIMARY KEY,
    klic TEXT NOT NULL UNIQUE,
    d REAL NOT NULL CHECK (d > 0),
    p_norm REAL NOT NULL CHECK (p_norm > 0)
);

CREATE TABLE zavit_m_stoupani (
    zavit_id INTEGER NOT NULL REFERENCES zavit_m(id),
    p REAL NOT NULL CHECK (p > 0),
    PRIMARY KEY (zavit_id, p)
);

CREATE TABLE zavit_tr (
    klic TEXT PRIMARY KEY,
    d REAL NOT NULL CHECK (d > 0),
    p REAL NOT NULL CHECK (p > 0)
);

INSERT INTO zavit_m (id, klic, d, p_norm)
SELECT id, klic, d, p_norm
FROM zavit
WHERE druh = 'M';

INSERT INTO zavit_m_stoupani (zavit_id, p)
SELECT s.zavit_id, s.p
FROM zavit_stoupani AS s
INNER JOIN zavit AS z ON z.id = s.zavit_id
WHERE z.druh = 'M';

INSERT INTO zavit_tr (klic, d, p)
SELECT z.klic, z.d, s.p
FROM zavit AS z
INNER JOIN zavit_stoupani AS s ON s.zavit_id = z.id
WHERE z.druh = 'Tr';

DROP TABLE zavit_stoupani;
DROP TABLE zavit;
