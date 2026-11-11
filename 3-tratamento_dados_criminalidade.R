if(!require('dplyr'))install.packages("dplyr");library(dplyr)
if(!require('readxl'))install.packages("readxl");library(readxl)

# listing files in the directory
lf <- list.files("dados_input")

# start with cv string
cv_files <- lf[grep("cv", lf)]

# Dados

dados_totais_tratados <- data.frame()

# for each file, read and treat the data

for(file in cv_files) {
  dados <- read.csv(paste0("dados_input/", file), sep = ";", check.names = FALSE, fileEncoding = "utf-8")
  dados_totais_tratados <- bind_rows(dados_totais_tratados, dados)
}
rm(dados)

# Funções
## Seleciona apenas as colunas necessárias
remove_colunas <- function(df) {
  df <- df |>
    rename(registros = Registros, natureza = Natureza, municipio = Município, cod_municipio = `Cód. IBGE`, mes = Mês, ano = `Ano Fato`) |>
    select(registros, natureza, municipio, cod_municipio, mes, ano)
  
  df
}

dados_totais_tratados <- remove_colunas(dados_totais_tratados)

# Valores originais
originais <- c(
  "ESTUPRO CONSUMADO",
  "ESTUPRO DE VULNERAVEL CONSUMADO",
  "ESTUPRO DE VULNERAVEL TENTADO",
  "ESTUPRO TENTADO",
  "EXTORSAO CONSUMADO",
  "EXTORSAO MEDIANTE SEQUESTRO CONSUMADO",
  "EXTORSAO TENTADO",
  "FEMINICIDIO TENTADO",
  "HOMICIDIO TENTADO",
  "ROUBO CONSUMADO",
  "ROUBO TENTADO",
  "SEQUESTRO E CARCERE PRIVADO CONSUMADO",
  "SEQUESTRO E CARCERE PRIVADO TENTADO",
  "FEMINICIDIO CONSUMADO (REGISTROS)",
  "HOMICIDIO CONSUMADO (REGISTROS)",
  "HOMICIDIO CONSUMADO (Registros)",
  "FEMINICIDIO CONSUMADO"
)

# Valores corrigidos
corrigidos <- c(
  "Estupro Consumado",
  "Estupro de Vulnerável Consumado",
  "Estupro de Vulnerável Tentado",
  "Estupro Tentado",
  "Extorsão Consumado",
  "Extorsão Mediante Sequestro Consumado",
  "Extorsão Tentado",
  "Feminicídio Tentado",
  "Homicídio Tentado",
  "Roubo Consumado",
  "Roubo Tentado",
  "Sequestro e Cárcere Privado Consumado",
  "Sequestro e Cárcere Privado Tentado",
  "Feminicídio Consumado (Registros)",
  "Homicídio Consumado (Registros)",
  "Homicídio Consumado (Registros)",
  "Feminicídio Consumado"
)

# Cria dicionário
dicionario <- setNames(corrigidos, originais)

# Aplica a substituição
dados_totais_tratados$natureza <- dicionario[dados_totais_tratados$natureza]


## Cria uma coluna com as 5 grandes categorias "Estupro", "Sequestro", "Extorsão", "Roubo", "Homicídio" e "Feminicídio"

cria_categorias <- function(df) {
  df$categoria <- ""
  categorias_crimes <- c("Estupro", "Sequestro", "Extorsão", "Roubo", "Homicídio", "Feminicídio") 
  
  # Existe a natureza 'Extorsão Mediante Sequestro Consumado'. 
  # Como Extorsão está depois de Sequestro no vetor acima, não haverá problema.
  
  for(cat in categorias_crimes) {
    df$categoria <- ifelse(grepl(cat, df$natureza), yes = cat, no = df$categoria)
  }
  
  df
}

dados_totais_tratados <- cria_categorias(dados_totais_tratados)


## Cria uma coluna com o tipo "Consumado" ou "Tentado"
cria_tipo <- function(df) {
  df$tipo <- ""
  tipos <- c("Consumado", "Tentado")
  
  for(tp in tipos) {
    df$tipo <- ifelse(grepl(tp, df$natureza), yes = tp, no = df$tipo)
  }
  
  df
}

dados_totais_tratados <- cria_tipo(dados_totais_tratados)


## Substitui os nomes dos municípios (em caixa alta e sem acento na base da Sejusp)
## pela grafia oficial do IBGE com iniciais maiúsculas e acentuação correta.
padroniza_municipios <- function(df, caminho_ibge = "dados_input/POP2026.xlsx", sheet_ibge = "MG-2026") {
  municipios_ibge <- read_excel(caminho_ibge, sheet = sheet_ibge) |>
    mutate(cod_municipio = as.integer(substr(paste0("31", `COD. MUNIC`), start = 1, stop = 6))) |>
    select(cod_municipio, municipio_ibge = `NOME DO MUNICÍPIO`) |>
    distinct(cod_municipio, .keep_all = TRUE)

  df |>
    left_join(municipios_ibge, by = "cod_municipio") |>
    mutate(municipio = coalesce(municipio_ibge, municipio)) |>
    select(-municipio_ibge)
}

dados_totais_tratados <- padroniza_municipios(dados_totais_tratados)


write.csv(dados_totais_tratados, 
          gzfile("dados_dash/dados_totais_tratados.csv.gz", encoding = "UTF-8"), 
          row.names = FALSE)
