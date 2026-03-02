WITH account AS(
  SELECT
      s.date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      COUNT(DISTINCT ac.id) AS account_cnt,
      0 AS sent_msg,
      0 AS open_msg,
      0 AS visit_msg
  FROM `DA.account` ac
  JOIN `DA.account_session` acs
  ON ac.id = acs.account_id
  JOIN `DA.session` s
  ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
  ON acs.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),
email_sent AS(
  SELECT
      DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      0 AS account_cnt,
      COUNT(DISTINCT es.id_message) AS sent_msg,
      0 AS open_msg,
      0 AS visit_msg
  FROM `DA.account` ac
  JOIN `DA.account_session` acs
  ON ac.id = acs.account_id
  JOIN `DA.email_sent` es
  ON ac.id = es.id_account
  JOIN `DA.session` s
  ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
  ON acs.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),
email_open AS(
  SELECT
      DATE_ADD(s.date, INTERVAL eo.open_date DAY) AS date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      0 AS account_cnt,
      0 AS sent_msg,
      COUNT(DISTINCT eo.id_message) AS open_msg,
      0 AS visit_msg
  FROM `DA.account` ac
  JOIN `DA.account_session` acs
  ON ac.id = acs.account_id
  JOIN `DA.email_open` eo
  ON ac.id = eo.id_account
  JOIN `DA.session` s
  ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
  ON acs.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),
email_visit AS (
  SELECT
      DATE_ADD(s.date, INTERVAL ev.visit_date DAY) AS date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      0 AS account_cnt,
      0 AS sent_msg,
      0 AS open_msg,
      COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM `DA.account` ac
  JOIN `DA.account_session` acs
  ON ac.id = acs.account_id
  JOIN `DA.email_visit` ev
  ON ac.id = ev.id_account
  JOIN `DA.session` s
  ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
  ON acs.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),
final AS(
  SELECT *
  FROM account
  UNION ALL
  SELECT *
  FROM email_sent
  UNION ALL
  SELECT *
  FROM email_open
  UNION ALL
  SELECT *
  FROM email_visit
),
final_sum AS(
  SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      SUM(account_cnt) AS account_cnt,
      SUM(sent_msg) AS sent_msg,
      SUM(open_msg) AS open_msg,
      SUM(visit_msg) AS visit_msg,
      SUM(SUM(account_cnt)) OVER(PARTITION BY country) AS total_country_account_cnt,
      SUM(SUM(sent_msg)) OVER(PARTITION BY country) AS total_country_sent_cnt
  FROM final
  GROUP BY 1, 2, 3, 4, 5
),
final_rank AS(
  SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      account_cnt,
      sent_msg,
      open_msg,
      visit_msg,
      total_country_account_cnt,
      total_country_sent_cnt,
      DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
      DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM final_sum
)
SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    rank_total_country_account_cnt,
    rank_total_country_sent_cnt
FROM final_rank
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10
ORDER BY 1, 12, 13
