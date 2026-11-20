WITH data AS(
  SELECT
    *
  FROM
    {{ ref('int_balance_sheet_decomposition__merging') }}
),

latest AS(
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    value,
    data_updated_at,
    MAX(year * 4 + quarter) OVER(PARTITION BY ticker) AS latest_period_key
  FROM
    data
)

SELECT
  ticker,
  label,
  period,
  quarter,
  year,
  value,
  data_updated_at
FROM
  latest
WHERE
  year * 4 + quarter = latest_period_key