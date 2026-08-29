# Regras e fluxos — SafePlace

## Como o app se comporta

1. **Buscar** — o usuário digita o bairro (ou parte do nome); a lista filtra na hora. Sem resultado: *Nenhum bairro encontrado.*
2. **Ver no mapa** — ao selecionar, o mapa centra no ponto, calcula o risco e mostra furtos, roubos e homicídios.
3. **Dados gerais** (MVP, ainda não na home) — totais da cidade, risco médio e ranking dos 5 bairros de maior score.

Ator único: pessoa que consulta indicadores. Sem login.

---

## RN01 — Escopo

Só a capital **São Paulo** (`COD IBGE = 3550308` / `NOME_MUNICIPIO = S.PAULO`).

## RN02 — Busca

Case-insensitive, correspondência parcial (`contains`) no nome **normalizado**. Selecionar um resultado foca o mapa naquele bairro.

## RN03 — Indicadores

Período da base atual: **jan–jun/2026**. Quantidade = `COUNT(*)` das linhas SSP, classificadas por `NATUREZA_APURADA`:

- **Furtos** — contém `FURTO`
- **Roubos** — contém `ROUBO` ou `LATROCÍNIO`
- **Homicídios** — `HOMICÍDIO DOLOSO` (MVP)

## RN04 — Nível de risco

```
score = (furtos × 1) + (roubos × 3) + (homicidios × 10)
```

| Score | Nível | Cor |
|-------|-------|-----|
| 0 – 49 | Baixo | Verde |
| 50 – 149 | Médio | Amarelo |
| 150 ou mais | Alto | Vermelho |

Faixas ajustáveis depois de calibrar com volumes reais da SSP.

## RN05 — Mapa

Após a seleção: ponto (lat/lng médios), nome, risco, os três indicadores. Vizinhos (mesma cidade, por proximidade de lat/lng) entram quando o detalhe for expandido.

## RN06 — Dados gerais

Totais da cidade (soma dos bairros), risco médio (média dos scores, mesmas faixas da RN04), ranking dos 5 maiores scores.

## RN07 — Fonte

Bruta: `SPDadosCriminais_2026.xlsx` (SSP/SP). Adaptada: `database/` + `assets/data/bairros.json`. Sem API externa nem sync em tempo real. Detalhe: [dados.md](dados.md).

## RN08 — Privacidade

Não coleta dados pessoais. Só agregados por bairro (sem endereço sensível). Em tela com indicador: *Fonte: SSP/SP (microdados). Agregação acadêmica do projeto — não substitui estatística oficial.*
