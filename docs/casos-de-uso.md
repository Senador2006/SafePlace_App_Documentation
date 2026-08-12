# Casos de Uso — App de Segurança Urbana

## Atores
- **Usuário**: pessoa que consulta indicadores de segurança por bairro.

## Dados de apoio
Indicadores locais já adaptados da base SSP (`SPDadosCriminais_2026.xlsx`) conforme [fonte-de-dados.md](fonte-de-dados.md).

---

## UC01 — Buscar bairro

| Item | Descrição |
|------|-----------|
| **Ator** | Usuário |
| **Pré-condição** | App aberto na tela de busca; recorte agregado SSP carregado |
| **Fluxo principal** | 1. Usuário digita termo no campo de busca<br>2. Sistema filtra bairros (RN02)<br>3. Sistema exibe lista de resultados |
| **Fluxo alternativo** | 3a. Sem resultados → mensagem *"Nenhum bairro encontrado."* |
| **Pós-condição** | Lista de bairros correspondente ao termo |

---

## UC02 — Ver detalhe e mapa do bairro

| Item | Descrição |
|------|-----------|
| **Ator** | Usuário |
| **Pré-condição** | Usuário selecionou um bairro na lista (UC01) |
| **Fluxo principal** | 1. Sistema calcula nível de risco (RN04)<br>2. Sistema abre mapa centrado no bairro<br>3. Sistema exibe indicadores e bairros vizinhos (RN05) |
| **Pós-condição** | Detalhe do bairro visível com mapa e risco |

---

## UC03 — Consultar dados gerais da cidade

| Item | Descrição |
|------|-----------|
| **Ator** | Usuário |
| **Pré-condição** | App aberto; dados locais carregados |
| **Fluxo principal** | 1. Usuário acessa a aba/tela "Dados gerais"<br>2. Sistema agrega totais e ranking (RN06)<br>3. Sistema exibe painel da cidade |
| **Pós-condição** | Visão consolidada de São Paulo |

---

## UC04 — Navegar entre telas

| Item | Descrição |
|------|-----------|
| **Ator** | Usuário |
| **Fluxo principal** | Usuário alterna entre Busca, Mapa/Detalhe (via seleção) e Dados gerais pela navegação inferior |
| **Pós-condição** | Tela correspondente exibida |
