WITH extract_week_start AS(
  SELECT
    pd.ticker,
    pd.date,
    pd.close,
    d.week_start
  FROM
    {{ ref('stg_price__price_daily') }} AS pd
  LEFT JOIN {{ ref('stg_price__date') }} AS d
    ON d.date = pd.date
  ORDER BY
    ticker,
    date
)

SELECT * FROM extract_week_start