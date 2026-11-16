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
    CASE
      WHEN COUNT(*) OVER(
        PARTITION BY ticker, label
        ORDER BY year, quarter
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
      ) = 4
      AND (year * 4 + quarter) - MIN(year * 4 + quarter) OVER(
        PARTITION BY ticker, label
        ORDER BY year, quarter
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
      ) = 3
      THEN SUM(value) OVER(
        PARTITION BY ticker, label
        ORDER BY year, quarter
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
    END AS value,
    data_updated_at
  FROM
    extract_quarter_and_year
)

SELECT * FROM calculation WHERE value IS NOT NULL