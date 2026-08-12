# Regras de Negócio — App de Segurança Urbana

## RN01 — Escopo geográfico
O aplicativo opera com dados da cidade de **São Paulo** (capital), filtrados da base SSP (`COD IBGE = 3550308` / `NOME_MUNICIPIO = S.PAULO`). Buscas e agregações consideram apenas bairros desse recorte.

## RN02 — Busca por local
1. O usuário informa um termo (nome do bairro ou parte do nome).
2. A busca é **case-insensitive** e aceita correspondência parcial (`contains`) sobre o nome **normalizado**.
3. Resultados vazios devem exibir mensagem clara: *"Nenhum bairro encontrado."*
4. Ao selecionar um resultado, o app navega para o detalhe com mapa.

## RN03 — Indicadores de criminalidade
Cada bairro possui indicadores agregados do período da base adaptada (**jan–jun/2026** na versão atual do XLSX):
- **Furtos** — ocorrências cuja `NATUREZA_APURADA` contém `FURTO`
- **Roubos** — contém `ROUBO` ou `LATROCÍNIO`
- **Homicídios** — `HOMICÍDIO DOLOSO` (e correlatos dolosos definidos no ETL)

A quantidade é o **número de linhas** da base bruta após filtro e classificação (não há coluna `quantidade` na SSP).

Detalhes do mapeamento: [fonte-de-dados.md](fonte-de-dados.md).

## RN04 — Cálculo do nível de risco
O **score de risco** de um bairro é a soma ponderada:

```
score = (furtos × 1) + (roubos × 3) + (homicidios × 10)
```

Faixas (ajustáveis após calibrar com volumes reais da SSP):

| Score        | Nível  | Cor de referência |
|--------------|--------|-------------------|
| 0 – 49       | Baixo  | Verde             |
| 50 – 149     | Médio  | Amarelo           |
| 150 ou mais  | Alto   | Vermelho          |

> Com volumes reais (semestre), as faixas podem precisar de recalibração para o ranking continuar útil.

## RN05 — Exibição no mapa
Após a busca, a tela de mapa deve mostrar:
1. Ponto central do bairro (latitude/longitude médias das ocorrências válidas).
2. Nome do bairro e nível de risco.
3. Resumo dos três indicadores.
4. Lista curta de bairros **vizinhos** (mesma cidade, distintos do selecionado), ordenados por proximidade aproximada (diferença de lat/lng).

## RN06 — Dados gerais
A tela de dados gerais apresenta:
1. Totais agregados da cidade (soma dos indicadores de todos os bairros do recorte).
2. Nível de risco médio da cidade (média dos scores, classificada pelas mesmas faixas da RN04).
3. Ranking dos bairros por score (maior risco primeiro), limitado aos 5 primeiros.

## RN07 — Fonte de dados
1. **Bruta:** [`SPDadosCriminais_2026.xlsx`](../SPDadosCriminais_2026.xlsx) (SSP/SP).
2. **Adaptada:** schema e seeds em `database/` + JSON local no app.
3. Não há autenticação, API externa da SSP nem sincronização em tempo real nesta versão — o app lê o recorte já agregado.

## RN08 — Privacidade e responsabilidade
1. O app não coleta dados pessoais.
2. Endereços sensíveis/vedados na base bruta não devem ser exibidos; o app trabalha só com agregados por bairro.
3. Qualquer tela com indicadores deve informar: *Fonte: SSP/SP (microdados). Agregação acadêmica do projeto — não substitui estatística oficial.*
