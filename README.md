# Análise de Engajamento e Desempenho de E-mail Marketing

## Visão Geral do Projeto
Este projeto de análise de dados cruza informações de sessões de usuários com interações de campanhas de e-mail para avaliar o engajamento. O objetivo principal é consolidar métricas de funil (envio, abertura e visita) e identificar os países com maior volume de contas e maior número de e-mails disparados, filtrando o Top 10 global para análises mais aprofundadas.

## Ferramentas Utilizadas
* **Linguagem:** SQL.
* **Banco de Dados/Processamento:** Google BigQuery.
* **Visualização de Dados:** Looker Studio.

## Arquitetura dos Dados
A análise extrai e consolida informações das seguintes fontes do banco de dados:
* **Tabelas de Conta e Sessão:** `DA.account`, `DA.account_session`, `DA.session` e `DA.session_params` (trazendo informações de país, verificação de conta, intervalo de envio e status de inscrição).
* **Tabelas de Eventos de E-mail:** `DA.email_sent`, `DA.email_open` e `DA.email_visit` (rastreando a jornada da mensagem).

## Estrutura da Consulta SQL
Para garantir a organização e performance da leitura dos dados, o script foi modularizado utilizando CTEs (Common Table Expressions):

1. **Extrações Isoladas:** As CTEs `account`, `email_sent`, `email_open` e `email_visit` realizam a contagem distinta de IDs (contas e mensagens) agrupadas por data, país e status do usuário. As datas de interação com os e-mails são calculadas dinamicamente usando a função `DATE_ADD`.
2. **Unificação:** A CTE `final` consolida todas as extrações temporárias empilhando os dados via `UNION ALL`.
3. **Agregação e Window Functions:** Na etapa `final_sum`, os dados diários são somados. Além disso, funções de janela (`SUM() OVER(PARTITION BY country)`) são aplicadas para calcular o volume total acumulado de contas e envios por país.
4. **Rankeamento (`final_rank`):** A função `DENSE_RANK()` é utilizada para criar um ranking dos países com base nos totais calculados.
5. **Filtro Final:** A consulta principal retorna apenas os registros onde o país está no Top 10 em volume de contas (`rank_total_country_account_cnt <= 10`) ou no Top 10 em envios de mensagens (`rank_total_country_sent_cnt <= 10`), ordenados cronologicamente e por ranking.

## Dashboard e Resultados

**Principais Insights da Análise:**
* **Concentração de Mercado:** O grande foco das campanhas de e-mail marketing está nos Estados Unidos, região que também concentra o maior volume de contas criadas.
* **Sazonalidade da Campanha:** Identificou-se um padrão temporário de envios concentrado entre os meses de novembro e fevereiro. Esse comportamento sugere uma estratégia sazonal, muito provavelmente voltada para as festas de final de ano e período de férias.

**Visualizações Desenvolvidas:**
Para facilitar o acompanhamento dessas métricas, o dashboard foi estruturado destacando:
* **Ranking Global:** Uma visão dos 10 principais países (Top 10), cruzando o volume de envios com a quantidade de contas criadas.
* **Análise Temporal:** Um gráfico de linha demonstrando a evolução e o volume de e-mails disparados ao longo do tempo.

Os resultados processados pelo BigQuery alimentam um painel interativo no **Looker Studio**, permitindo o acompanhamento dinâmico das métricas. 

* <img width="1689" height="1248" alt="Captura de tela 2026-01-19 104222" src="https://github.com/user-attachments/assets/b5680e2d-a0f8-41e3-aac7-29b579e308fb" />
* <img width="1245" height="1188" alt="Captura de tela 2026-01-19 102314" src="https://github.com/user-attachments/assets/c4e12d82-0ed8-48ad-94d2-e30195bb32d3" />


