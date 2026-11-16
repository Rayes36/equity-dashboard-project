WITH quarterly AS(
  SELECT
    *
  FROM
    {{ ref('int_financial_overview__quarterly') }}
),

extract_quarter_and_year AS(
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    value,
    data_updated_at
  FROM
    quarterly
),

calculation AS(
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    SUM(value) OVER(
      PARTITION BY ticker, label
      ORDER BY year, quarter
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS value,
    data_updated_at
  FROM
    extract_quarter_and_year
)

SELECT * FROM calculation