# Regras e fluxos — SafePlace

## Como o app se comporta

1. **Entrar** — login ou cadastro (nome, e-mail, senha de pelo menos 6 caracteres). Sem sessão, a home não abre.
2. **Buscar** — a pessoa digita o bairro; a lista filtra na hora. Sem resultado: *Nenhum bairro encontrado.*
3. **Ver no mapa** — ao selecionar, o mapa mostra o ponto, o risco e furtos, roubos e homicídios. Com a chave da LocationIQ, desenha o contorno do bairro.
4. **Relatório** — o card traz o percentual, os dois crimes mais comuns com seta de tendência e o botão “Ver relatório detalhado” (selo PRO).
5. **Planos** — a home abre Gratuito e Pro. “Assinar Pro” não cobra.
6. **Sair** — encerra a sessão e volta ao login. O plano da conta permanece.

---

## RN01 — Escopo

Só a capital **São Paulo** (`COD IBGE = 3550308` / `NOME_MUNICIPIO = S.PAULO`).

## RN02 — Busca

Case-insensitive, correspondência parcial (`contains`) no nome. Selecionar um resultado foca o mapa naquele bairro.

## RN03 — Indicadores

Período da base atual: **jan–jun/2026**. Quantidade = `COUNT(*)` das linhas SSP, classificadas por `NATUREZA_APURADA`:

- **Furtos** — contém `FURTO`
- **Roubos** — contém `ROUBO` ou `LATROCÍNIO`
- **Homicídios** — `HOMICÍDIO DOLOSO`

Os números no app ainda são placeholder até a agregação real da planilha.

## RN04 — Nível de risco

```
score = (furtos × 1) + (roubos × 3) + (homicidios × 10)
```

| Score | Nível | Cor |
| --- | --- | --- |
| 0 – 49 | Baixo | Verde |
| 50 – 149 | Médio | Amarelo |
| 150 ou mais | Alto | Vermelho |

## RN05 — Criminalidade e tendência

O percentual do card é a quantidade de ocorrências do bairro dividida pela maior quantidade entre os bairros carregados.

A base não traz mês a mês. A série do relatório reparte o total do semestre de forma estável (jan–mar contra abr–jun). A soma dos meses é o total do bairro. Não é a estatística mensal da SSP. Seta vermelha para cima, verde para baixo.

## RN06 — Mapa

Ponto (lat/lng do bairro), nome, risco e os três indicadores. O contorno vem da LocationIQ (`polygon_geojson`) quando há token em `safeplace/lib/config/locationiq_chave.dart`. Sem token, o mapa usa o tile do OpenStreetMap e avisa na tela.

## RN07 — Planos

Dois planos, gravados na tabela `plano` da conta:

| Flag | Padrão | Efeito |
| --- | --- | --- |
| `eh_pro` | falso | Pro: sem anúncio e relatórios ilimitados |
| `ja_usou_relatorio_gratis` | falso | Gratuito: um relatório detalhado |

Ao tocar em “Ver relatório detalhado”:

- Pro abre o relatório.
- Gratuito que ainda não usou abre, marca a flag e avisa que aquele foi o relatório gratuito.
- Gratuito que já usou vai para a tela de planos.

O card da região, com percentual e os dois crimes, vale para os dois planos.

## RN08 — Anúncios

Card reutilizável com “Patrocinado”, ícone, título, texto e link externo. A lista é fixa no app (alarmes, câmeras, fechaduras, seguros, rastreador). Um anúncio na home. Um ou dois em “Ofertas de parceiros”, no fim do relatório. Nenhum anúncio para Pro. Texto informativo, sem alarmismo.

## RN09 — Fonte

Bruta: `SPDadosCriminais_2026.xlsx` (SSP/SP), fora do repositório. No app, logado, a leitura vem do Supabase. Se a consulta voltar vazia, entra `assets/data/bairros.json`. Detalhe: [dados.md](dados.md) e [supabase.md](supabase.md).

Em tela com indicador: *Fonte: SSP/SP (microdados). Agregação acadêmica do projeto — não substitui estatística oficial.*

## RN10 — Conta

O Supabase Auth guarda e-mail e senha. O nome vai no metadado do usuário. O app não guarda a senha. Duas contas não compartilham plano. Os bairros são os mesmos para todo mundo.
