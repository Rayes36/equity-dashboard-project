{{ config(materialized='ephemeral') }}
WITH quarterly AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__balance_sheets_quarterly') }}
),

yearly AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__balance_sheets_yearly') }}
),

get_q4 AS(
  SELECT
    ticker,
    label,
    CONCAT('Q4 ', year) AS period,
    4 AS quarter,
    year,
    value,
    data_updated_at
  FROM
    yearly
),

combined AS(
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    quarterly

  UNION ALL
    SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    get_q4
)

SELECT * FROM combined