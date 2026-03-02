# Análise de Engajamento e Desempenho de E-mail Marketing

## 📌 Visão Geral do Projeto
[cite_start]Este projeto de análise de dados cruza informações de sessões de usuários com interações de campanhas de e-mail para avaliar o engajamento. [cite_start]O objetivo principal é consolidar métricas de funil (envio, abertura e visita) e identificar os países com maior volume de contas e maior número de e-mails disparados, filtrando o Top 10 global para análises mais aprofundadas.

## 🛠️ Ferramentas Utilizadas
* [cite_start]**Linguagem:** SQL.
* [cite_start]**Banco de Dados/Processamento:** Google BigQuery.
* [cite_start]**Visualização de Dados:** Looker Studio.

## 🗂️ Arquitetura dos Dados
[cite_start]A análise extrai e consolida informações das seguintes fontes do banco de dados:
* [cite_start]**Tabelas de Conta e Sessão:** `DA.account`, `DA.account_session`, `DA.session` e `DA.session_params` (trazendo informações de país, verificação de conta, intervalo de envio e status de inscrição).
* [cite_start]**Tabelas de Eventos de E-mail:** `DA.email_sent`, `DA.email_open` e `DA.email_visit` (rastreando a jornada da mensagem).

## 🧠 Estrutura da Consulta SQL
[cite_start]Para garantir a organização e performance da leitura dos dados, o script foi modularizado utilizando CTEs (Common Table Expressions):

1. [cite_start]**Extrações Isoladas:** As CTEs `account`, `email_sent`, `email_open` e `email_visit` realizam a contagem distinta de IDs (contas e mensagens) agrupadas por data, país e status do usuário. As datas de interação com os e-mails são calculadas dinamicamente usando a função `DATE_ADD`.
2. [cite_start]**Unificação:** A CTE `final` consolida todas as extrações temporárias empilhando os dados via `UNION ALL`.
3. [cite_start]**Agregação e Window Functions:** Na etapa `final_sum`, os dados diários são somados. Além disso, funções de janela (`SUM() OVER(PARTITION BY country)`) são aplicadas para calcular o volume total acumulado de contas e envios por país.
4. [cite_start]**Rankeamento (`final_rank`):** A função `DENSE_RANK()` é utilizada para criar um ranking dos países com base nos totais calculados.
5. [cite_start]**Filtro Final:** A consulta principal retorna apenas os registros onde o país está no Top 10 em volume de contas (`rank_total_country_account_cnt <= 10`) ou no Top 10 em envios de mensagens (`rank_total_country_sent_cnt <= 10`), ordenados cronologicamente e por ranking.

## 📊 Dashboard e Resultados
*(Adicione aqui um parágrafo resumindo as 2 ou 3 principais conclusões que você obteve ao olhar para os dados)*

[cite_start]Os resultados processados pelo BigQuery alimentam um painel interativo no **Looker Studio**, permitindo o acompanhamento dinâmico das métricas. 

* [Insira aqui a Imagem/Screenshot do Dashboard do Looker Studio]
* [Insira aqui a Imagem/Screenshot dos resultados retornados no BigQuery]
