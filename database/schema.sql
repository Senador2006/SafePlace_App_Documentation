-- Schema próprio — App de Segurança Urbana
-- Destino do ETL a partir de SPDadosCriminais_2026.xlsx (SSP/SP)
-- Ver docs/fonte-de-dados.md

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS cidade (
    id        INTEGER PRIMARY KEY,
    nome      TEXT    NOT NULL,
    uf        TEXT    NOT NULL,
    cod_ibge  INTEGER NOT NULL UNIQUE  -- SSP: COD IBGE (capital = 3550308)
);

CREATE TABLE IF NOT EXISTS bairro (
    id        INTEGER PRIMARY KEY,
    cidade_id INTEGER NOT NULL,
    nome      TEXT    NOT NULL,          -- SSP: BAIRRO (normalizado)
    latitude  REAL    NOT NULL,          -- média de LATITUDE válidas
    longitude REAL    NOT NULL,          -- média de LONGITUDE válidas
    FOREIGN KEY (cidade_id) REFERENCES cidade(id)
);

CREATE TABLE IF NOT EXISTS tipo_crime (
    id     INTEGER PRIMARY KEY,
    codigo TEXT    NOT NULL UNIQUE,      -- furto | roubo | homicidio
    nome   TEXT    NOT NULL
);

-- quantidade = COUNT(*) das linhas SSP filtradas por bairro + natureza + período
CREATE TABLE IF NOT EXISTS indicador_criminalidade (
    id            INTEGER PRIMARY KEY,
    bairro_id     INTEGER NOT NULL,
    tipo_crime_id INTEGER NOT NULL,
    quantidade    INTEGER NOT NULL CHECK (quantidade >= 0),
    periodo_inicio TEXT   NOT NULL,       -- ex.: 2026-01-01
    periodo_fim    TEXT   NOT NULL,       -- ex.: 2026-06-30
    FOREIGN KEY (bairro_id) REFERENCES bairro(id),
    FOREIGN KEY (tipo_crime_id) REFERENCES tipo_crime(id),
    UNIQUE (bairro_id, tipo_crime_id, periodo_inicio, periodo_fim)
);

CREATE INDEX IF NOT EXISTS idx_bairro_cidade ON bairro(cidade_id);
CREATE INDEX IF NOT EXISTS idx_bairro_nome ON bairro(nome);
CREATE INDEX IF NOT EXISTS idx_indicador_bairro ON indicador_criminalidade(bairro_id);
