# App de Segurança Urbana

**Objetivo:** ajudar o usuário a consultar o nível de criminalidade de um bairro ou área em São Paulo, de forma simples e visual.

**Tecnologia prevista:** Flutter (app multiplataforma).

**Fonte de dados:** microdados da SSP/SP em [`SPDadosCriminais_2026.xlsx`](SPDadosCriminais_2026.xlsx), **adaptados** ao modelo próprio do projeto (ver [docs/fonte-de-dados.md](docs/fonte-de-dados.md)).

> Os indicadores do app são agregações acadêmicas a partir da base oficial. **Não substituem** a estatística publicada pela SSP/SP.

---

## Escopo

### Funcionalidades
- **Busca** por nome de bairro (correspondência parcial).
- **Mapa + detalhe** após a busca: local pesquisado, indicadores do bairro e criminalidade nos arredores.
- **Dados gerais** da cidade: totais agregados e ranking simples dos bairros por risco.

### Indicadores por bairro
Derivados de `NATUREZA_APURADA` na base SSP:
- **Furtos**
- **Roubos**
- **Homicídios**

### Nível de risco
Calculado por soma ponderada e classificado em **Baixo / Médio / Alto** (ver [regras de negócio](docs/regras-de-negocio.md)).

---

## Dados: bruto → modelo do app

```
SPDadosCriminais_2026.xlsx  (SSP, jan–jun/2026)
        ↓ filtrar capital + limpar bairro + agregar
database/schema.sql + seed_sp.sql
        ↓ espelho para o app
assets/data/bairros.json  (previsto no Flutter)
```

Detalhes do mapeamento de colunas e regras de ETL: [docs/fonte-de-dados.md](docs/fonte-de-dados.md).

---

## O que este repositório contém

| Pasta / arquivo | Conteúdo |
|-----------------|----------|
| [SPDadosCriminais_2026.xlsx](SPDadosCriminais_2026.xlsx) | Base bruta SSP (estado; app usa só a capital) |
| [docs/fonte-de-dados.md](docs/fonte-de-dados.md) | Adaptação SSP → schema do projeto |
| [docs/regras-de-negocio.md](docs/regras-de-negocio.md) | Regras do produto |
| [docs/casos-de-uso.md](docs/casos-de-uso.md) | Casos de uso |
| [docs/modelo-de-dados.md](docs/modelo-de-dados.md) | Modelo próprio (SQL/JSON) |
| [docs/arquitetura-flutter.md](docs/arquitetura-flutter.md) | Proposta de arquitetura Flutter |
| [database/schema.sql](database/schema.sql) | Schema SQL do app |
| [database/seed_sp.sql](database/seed_sp.sql) | Seed agregado (destino do ETL) |

**Ainda não há código do app Flutter neste repositório** — ideia, regras e modelagem de dados para implementação futura.

---

## Fora de escopo (de propósito)

Login, denúncias em tempo real, API oficial da SSP (inexistente para este uso), push notifications e painel admin.
