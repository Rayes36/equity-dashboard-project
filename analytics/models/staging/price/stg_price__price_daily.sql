WITH source AS(
  SELECT
    *
  FROM {{ source('price', 'raw_fact_price_daily') }}
),

cleaned AS(
  SELECT
    ticker,
    TRY_CAST(date AS DATE) AS date,
    open,
    high,
    low,
    close,
    adj_close,
    CAST(volume AS BIGINT) AS volume,
    dividends,
    stock_splits,
    ingested_at
  FROM source
  WHERE
    NOT (close IS NULL 
      AND date >= date_sub(current_date(), 3))
)

SELECT * FROM cleaned