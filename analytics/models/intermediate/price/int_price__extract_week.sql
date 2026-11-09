WITH price_daily AS(
  SELECT
    *
  FROM
    {{ ref('stg_price__price_daily') }}
),

price_date AS(
  SELECT
    *
  FROM
    {{ ref('stg_price__date') }}
)

SELECT
  pd.ticker,
  pd.date,
  pd.close,
  d.week_start
FROM
  price_daily AS pd
LEFT JOIN price_date AS d
  ON d.date = pd.date
ORDER BY
  ticker,
  date