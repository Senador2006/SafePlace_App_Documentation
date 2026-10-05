# SafePlace — Produto, marca e pitch

**Tagline:** Informação que protege. Dados que transformam.

Consulta o nível de criminalidade de um bairro em São Paulo, com mapa e indicadores, a partir de microdados da SSP/SP. Agregação acadêmica: **não substitui** a estatística oficial.

---

## Problema

A SSP já publica ocorrências, mas em planilhas grandes, com bairro em texto livre e pouca leitura visual. No dia a dia a pessoa recorre a notícia isolada ou WhatsApp — o que gera alarmismo ou falsa segurança.

O SafePlace traduz essa base em uma resposta por bairro: furtos, roubos, homicídios e risco baixo / médio / alto.

## Público-alvo

| Perfil | Necessidade |
| --- | --- |
| Moradores da capital | Entender o próprio bairro e os arredores |
| Estudantes e recém-chegados | Rota, moradia e circulação com contexto |
| Quem busca imóvel | Comparar regiões antes de visitar |
| Interessados em dados públicos | Ver indicadores sem abrir o Excel da SSP |

Fora desta versão: órgãos, redações e imobiliárias (visão B2B).

## O que o app faz

1. **Conta** — cadastro e login. O plano fica na pessoa, não no aparelho.
2. **Busca** por nome de bairro.
3. **Mapa** — ponto do bairro e, com a chave da LocationIQ, o contorno.
4. **Card da região** — percentual de criminalidade, dois crimes mais comuns com tendência e o botão do relatório.
5. **Relatório detalhado** — série do semestre, ranking, comparação com a média das outras regiões e texto automático.
6. **Planos** — Gratuito (anúncios e um relatório) e Pro (sem anúncio, relatórios ilimitados). Assinar o Pro não cobra: só grava a flag.

**Fora desta versão:** denúncias em tempo real, API da SSP, push, painel admin e totais gerais da cidade.

Regras: [regras.md](regras.md). Fonte e modelo: [dados.md](dados.md). Banco: [supabase.md](supabase.md).

---

## Marca

**SafePlace** — *camel case* visual (`Safe` + `Place`); pasta/pacote `safeplace`.

| Parte | Significado |
| --- | --- |
| **Safe** | proteção, confiança — informação a serviço da segurança cotidiana |
| **Place** | bairro, território — o *onde*, não o crime em abstrato |

Leitura *a safe place*: lugar em que a pessoa se orienta, não garantia de risco zero. O logo fecha o mesmo raciocínio: escudo (proteção) + pino (local) + barras (dado).

### Tom de voz

Analista acessível, não sirene.

| Faz | Não faz |
| --- | --- |
| Cita fonte, período e limite do dado | Inventa precisão |
| Frases curtas, números visíveis | Jargão policial sem tradução |
| “Nível alto” + contexto | “Perigoso”, “não vá”, clickbait |
| Ajuda a decidir | Moraliza o usuário |

Sim: *Pinheiros — risco médio no 1º semestre de 2026. Fonte: microdados SSP/SP.*  
Não: *Pinheiros está perigoso. Evite a região.*

Os anúncios seguem o mesmo tom: informativos, sem medo. Guia visual: [brand/identidade.html](../brand/identidade.html).

| Nome | Hex | Uso |
| --- | --- | --- |
| Azul Noite | `#0D1321` | Fundo |
| Azul Índigo | `#1E2A78` | Superfícies |
| Azul Seguro | `#4A6CFF` | Primária, CTAs |
| Roxo Alerta | `#8B5CF6` | Gradiente |
| Verde Seguro | `#22C55E` | Risco baixo e queda |
| Cinza Claro / Médio | `#E5E7EB` / `#6B7280` | Texto |
| Vermelho (funcional) | `#EF4444` | Risco alto e alta |

Títulos: **Montserrat**. Corpo: **Inter**.

---

## Pitch

O dado oficial existe; falta uma interface cidadã. O SafePlace agrega microdados da SSP por bairro e mostra mapa + risco em segundos.

**Por que agora:** base estadual acessível (sem API por bairro), Flutter multiplataforma, demanda por dado na escolha de moradia e deslocamento.

### Modelo no app

| Plano | O que inclui |
| --- | --- |
| Gratuito | Todos os bairros, um anúncio na home, um relatório detalhado |
| Pro | Sem anúncio e relatórios ilimitados |

Não há cobrança. “Assinar Pro” grava `eh_pro` na conta. Não vendemos o XLSX da SSP.

### Diferencial

| Alternativa | Limitação | SafePlace |
| --- | --- | --- |
| Portal / Excel da SSP | Para analista | Indicador por bairro + mapa |
| Notícia e grupos | Anedota | Microdados + faixas explícitas |
| Mapas gerais | Sem camada de crime oficial no BR | Risco RN04 (furto, roubo, homicídio) |
| Apps de denúncia | Distorem com volume de usuário | Fonte institucional, conta só para o plano |

*Se a cidade já mede o crime, o cidadão deveria conseguir ler o bairro.*
