-- Seed — São Paulo (destino do ETL da SSP)
-- Fonte bruta: SPDadosCriminais_2026.xlsx (SSP/SP), aba JAN-JUN_2026
-- Pipeline: docs/dados.md
--
-- Os números abaixo são PLACEHOLDER até rodar a agregação real
-- (filtrar capital + COUNT por BAIRRO e NATUREZA_APURADA).
-- Período alvo do XLSX atual: 2026-01-01 a 2026-06-30.

INSERT INTO cidade (id, nome, uf, cod_ibge) OVERRIDING SYSTEM VALUE VALUES (1, 'São Paulo', 'SP', 3550308);

INSERT INTO tipo_crime (id, codigo, nome) OVERRIDING SYSTEM VALUE VALUES
    (1, 'furto', 'Furto'),
    (2, 'roubo', 'Roubo'),
    (3, 'homicidio', 'Homicídio');

INSERT INTO bairro (id, cidade_id, nome, latitude, longitude) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 'Pinheiros',       -23.5615, -46.6917),
    (2, 1, 'Moema',           -23.6010, -46.6630),
    (3, 1, 'Liberdade',       -23.5580, -46.6340),
    (4, 1, 'Santana',         -23.5030, -46.6260),
    (5, 1, 'Itaquera',        -23.5400, -46.4560),
    (6, 1, 'Capão Redondo',   -23.6680, -46.7800),
    (7, 1, 'Vila Mariana',    -23.5890, -46.6345),
    (8, 1, 'Sé',              -23.5505, -46.6333);

-- Período alinhado ao XLSX atual (JAN-JUN_2026)
-- PLACEHOLDER: substituir quantidades pelo COUNT real do ETL
INSERT INTO indicador_criminalidade (id, bairro_id, tipo_crime_id, quantidade, periodo_inicio, periodo_fim) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 1, 40, '2026-01-01', '2026-06-30'),
    (2, 1, 2, 12, '2026-01-01', '2026-06-30'),
    (3, 1, 3, 0,  '2026-01-01', '2026-06-30'),
    (4, 2, 1, 28, '2026-01-01', '2026-06-30'),
    (5, 2, 2, 8,  '2026-01-01', '2026-06-30'),
    (6, 2, 3, 0,  '2026-01-01', '2026-06-30'),
    (7, 3, 1, 55, '2026-01-01', '2026-06-30'),
    (8, 3, 2, 22, '2026-01-01', '2026-06-30'),
    (9, 3, 3, 1,  '2026-01-01', '2026-06-30'),
    (10, 4, 1, 48, '2026-01-01', '2026-06-30'),
    (11, 4, 2, 18, '2026-01-01', '2026-06-30'),
    (12, 4, 3, 1,  '2026-01-01', '2026-06-30'),
    (13, 5, 1, 70, '2026-01-01', '2026-06-30'),
    (14, 5, 2, 35, '2026-01-01', '2026-06-30'),
    (15, 5, 3, 3,  '2026-01-01', '2026-06-30'),
    (16, 6, 1, 85, '2026-01-01', '2026-06-30'),
    (17, 6, 2, 42, '2026-01-01', '2026-06-30'),
    (18, 6, 3, 4,  '2026-01-01', '2026-06-30'),
    (19, 7, 1, 32, '2026-01-01', '2026-06-30'),
    (20, 7, 2, 10, '2026-01-01', '2026-06-30'),
    (21, 7, 3, 0,  '2026-01-01', '2026-06-30'),
    (22, 8, 1, 95, '2026-01-01', '2026-06-30'),
    (23, 8, 2, 50, '2026-01-01', '2026-06-30'),
    (24, 8, 3, 2,  '2026-01-01', '2026-06-30');
