# Crimes Violentos em Minas Gerais

Dashboard interativo para exploração, visualização e análise espacial/temporal dos registros de criminalidade violenta nos municípios de Minas Gerais (2012 em diante). O projeto integra dados oficiais da Secretaria de Estado de Justiça e Segurança Pública (SEJUSP-MG) e estimativas populacionais do IBGE.

Construído em **R** com **Quarto Dashboards** e backend reativo em **Shiny**, utilizando **Plotly**, **ggplot2**, **bslib** e **geobr**.

---

## 📋 Pré-requisitos

Antes de iniciar, certifique-se de ter instalado em sua máquina:

1. **[R](https://cloud.r-project.org/)** (versão 4.3.0 ou superior recomendada).
2. **[Quarto CLI](https://quarto.org/docs/get-started/)** (versão 1.4 ou superior recomendada).
3. *(Opcional, mas recomendado)* **[RStudio](https://posit.co/download/rstudio-desktop/)** ou **VS Code** com as extensões de R e Quarto.

> **Nota para usuários Linux (Ubuntu/Debian):**
> O pacote geoespacial `geobr` (e sua dependência `sf`) pode requerer bibliotecas de sistema C/C++. Se necessário, instale-as via terminal:
> ```bash
> sudo apt-get update
> sudo apt-get install -y libudunits2-dev libharfbuzz-dev libfribidi-dev libtiff5-dev libproj-dev libgdal-dev libgeos-dev
> ```

---

## 📦 Instalação dos Pacotes R

Abra o terminal ou o console do R no diretório raiz do projeto e instale os pacotes necessários:

```r
# Instalação dos pacotes do CRAN
pacotes <- c(
  "knitr",
  "rmarkdown",
  "shiny",
  "quarto",
  "bslib",
  "ggplot2",
  "plotly",
  "stringr",
  "ragg",
  "tidyr",
  "dplyr",
  "readxl",
  "httr",
  "scales",
  "remotes"
)

install.packages(pacotes)

# Instalação do pacote geobr (mapas do Brasil/IBGE)
install.packages("geobr")
# Caso necessite de uma versão específica testada no pipeline:
# remotes::install_version("geobr", version = "1.9.1")
```

Ou instale todos os pacotes diretamente pelo terminal via `Rscript`:

```bash
Rscript -e 'install.packages(c("knitr", "rmarkdown", "shiny", "quarto", "bslib", "ggplot2", "plotly", "stringr", "ragg", "tidyr", "dplyr", "readxl", "httr", "scales", "remotes", "geobr"), repos="https://cloud.r-project.org")'
```

> **Dica Windows:** Se o comando `Rscript` não for reconhecido diretamente no PowerShell/Prompt, execute usando o caminho completo da sua instalação do R:
> ```powershell
> & "C:\Program Files\R\R-4.6.2\bin\Rscript.exe" -e 'install.packages(c("knitr", "rmarkdown", "shiny", "quarto", "bslib", "ggplot2", "plotly", "stringr", "ragg", "tidyr", "dplyr", "readxl", "httr", "scales", "remotes", "geobr"), repos="https://cloud.r-project.org")'
> ```

---

## 🚀 Como Rodar o Dashboard Localmente

Como os dados pré-processados já estão incluídos na pasta `dados_dash/`, você pode executar o dashboard diretamente sem precisar reprocessar as bases.

### Opção 1: Via Quarto CLI (Terminal / PowerShell / Bash)

No terminal, navegue até a pasta do projeto e execute:

```bash
quarto preview dash.qmd
```

O Quarto iniciará um servidor Shiny local e abrirá automaticamente o dashboard no seu navegador padrão (geralmente em `http://localhost:xxxx`).

Para encerrar o servidor, pressione `Ctrl + C` no terminal.

### Opção 2: Pelo RStudio

1. Abra o arquivo `dash.qmd` no RStudio.
2. Na barra de ferramentas superior do editor de código, clique no botão **Render** (ou use o atalho `Ctrl + Shift + K` no Windows/Linux ou `Cmd + Shift + K` no macOS).
3. O dashboard será executado com o servidor Shiny integrado do RStudio no painel *Viewer* ou em uma janela do navegador.

### Opção 3: Pelo Console do R

Você também pode iniciar o preview diretamente a partir de uma sessão R:

```r
quarto::quarto_preview("dash.qmd")
```

---

## 🔄 Pipeline de Atualização dos Dados (Opcional)

Se você adicionou novos dados brutos em `dados_input/` ou deseja reexecutar o tratamento de ponta a ponta:

1. **(Opcional) Coleta de População via API do IBGE:**
   ```bash
   Rscript 1-raspagem_api_ibge_populacao.R
   ```
   *Gera/atualiza `dados_input/populacao-minas-ibge.csv`.*

2. **Tratamento das Séries Históricas de População:**
   ```bash
   Rscript 2-tratamento_dados_populacao.R
   ```
   *Gera `dados_dash/dados_populacao_completo.csv`.*

3. **Tratamento dos Dados de Criminalidade:**
   ```bash
   Rscript 3-tratamento_dados_criminalidade.R
   ```
   *Lê os arquivos `dados_input/cv-*.csv`, padroniza categorias/naturezas e gera `dados_dash/dados_totais_tratados.csv.gz`.*

Após rodar os scripts acima, execute novamente o dashboard (`quarto preview dash.qmd`).

---

## 📂 Estrutura do Repositório

```text
crimes-violentos-mg/
├── .github/workflows/                 # Workflows do GitHub Actions (ETL e Deploy)
│   ├── deploy.yml
│   └── pipeline.yml
├── dados_dash/                        # Dados tratados consumidos pelo dashboard
│   ├── dados_populacao_completo.csv   # População por município e ano
│   ├── dados_totais_tratados.csv.gz   # Ocorrências de crimes tratadas e comprimidas
│   └── mapa_minas.rds                 # Geometria dos municípios de MG (cache geobr)
├── dados_input/                       # Bases brutas (crimes e população)
│   ├── cv-2012-2018.csv
│   ├── cv-2019-2023.csv
│   ├── cv-2024-2026.csv
│   ├── ibge_populacao_municipio.csv
│   ├── POP2024.xlsx / POP2025.xlsx / POP2026.xlsx
│   └── populacao-minas-ibge.csv
├── 1-raspagem_api_ibge_populacao.R    # Script de coleta via API do IBGE
├── 2-tratamento_dados_populacao.R     # Script de consolidação demográfica
├── 3-tratamento_dados_criminalidade.R # Script de ETL das naturezas criminais
├── dash.qmd                           # Código-fonte Quarto + Shiny do Dashboard
├── dash.html                          # Versão compilada do dashboard
├── deploy.R                           # Script de deploy para ShinyApps.io / Posit Connect
└── README.md                          # Instruções do projeto
```

---

## 🌐 Deploy (ShinyApps.io / Posit Connect)

Para realizar o deploy na plataforma [shinyapps.io](https://www.shinyapps.io/), configure suas credenciais de conta e execute o script `deploy.R`:

```r
# Definir variáveis de ambiente com as credenciais da sua conta shinyapps.io:
Sys.setenv(
  NAME = "seu-usuario",
  TOKEN = "seu-token",
  SECRET = "seu-secret"
)

# Executar publicação
source("deploy.R")
```

---

## 🛠️ Solução de Problemas Comuns

- **Erro `there is no package called 'rmarkdown'` ou `knitr`:** O Quarto requer que os pacotes `rmarkdown` e `knitr` estejam instalados no seu ambiente R para conseguir renderizar documentos com blocos em R. Basta rodar o comando de instalação de pacotes apresentado acima.
- **Comando `quarto` não reconhecido:** Verifique se o Quarto CLI foi instalado e se o seu caminho foi adicionado à variável `PATH` do sistema operacional. Após a instalação, feche e reabra o terminal.
- **Erro de porta ocupada no Shiny:** Caso a porta padrão esteja em uso, o Quarto geralmente seleciona uma porta livre automaticamente. Se necessário, você pode especificar uma porta no terminal com `quarto preview dash.qmd --port 8080`.
- **Atraso no carregamento inicial do mapa:** O projeto utiliza o arquivo pré-armazenado `dados_dash/mapa_minas.rds`. Caso ele seja removido, o script baixará os polígonos automaticamente via `geobr::read_municipality("MG")`, o que necessitará de conexão com a internet na primeira execução.
