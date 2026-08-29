# SafePlace

**Informação que protege. Dados que transformam.**

Consulta o nível de criminalidade de um bairro em São Paulo — busca, mapa e indicadores — a partir de microdados da SSP/SP.

**Repositório:** [github.com/Senador2006/SafePlace_App_Documentation](https://github.com/Senador2006/SafePlace_App_Documentation)

---

## Integrantes

FIAP — 2º ano · Cross Platform Application Development


| Nome                       | RM     | GitHub                                        |
| -------------------------- | ------ | --------------------------------------------- |
| Thiago Ono Sakai           | 563448 | [Senador2006](https://github.com/Senador2006) |
| Pedro Mitsu                | 561710 | [Mitsuo100](https://github.com/Mitsuo100)     |
| Gabriel Nacarelli          | 565298 | [GabrielNaca](https://github.com/GabrielNaca) |
| Luiz Claro                 | 563014 | [LuizC777](https://github.com/LuizC777)       |
| Andre Gouveia              | 564219 | [andreglim4](https://github.com/andreglim4)   |
| Lucas Eiki Tanaka Gushikem | 561607 |                                               |


---



## Documentação


| Arquivo                                        | Conteúdo                                          |
| ---------------------------------------------- | ------------------------------------------------- |
| [docs/produto.md](docs/produto.md)             | Problema, público, MVP, marca, tom de voz e pitch |
| [docs/regras.md](docs/regras.md)               | Regras de negócio e fluxos                        |
| [docs/dados.md](docs/dados.md)                 | Fonte SSP, modelo e arquitetura Flutter           |
| [brand/identidade.html](brand/identidade.html) | Logo, paleta, tipografia e ícones                 |


---



## App Flutter

```bash
cd safeplace
flutter pub get
flutter run -d chrome
```

Windows (com Visual Studio): `flutter run -d windows`.

A home já une **busca de bairro** e **mapa**.

---



## Estrutura

```
├── README.md
├── docs/                 produto, regras, dados
├── brand/                logo e guia visual
├── database/             schema e seed (destino do ETL)
├── safeplace/            app Flutter
└── SPDadosCriminais_2026.xlsx   fonte bruta SSP (não entra no app)
```

