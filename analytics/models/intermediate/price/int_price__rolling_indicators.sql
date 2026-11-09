WITH calculation AS(
  SELECT
    ticker,
    date,
    close,
    adj_close,
    volume,

    -- daily_change_pct
    (close - LAG(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
    )) / LAG(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
    ) * 100 AS daily_change_pct,

    -- SMA
    AVG(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS sma_50,
    AVG(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 99 PRECEDING AND CURRENT ROW
    ) AS sma_100,
    AVG(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 199 PRECEDING AND CURRENT ROW
    ) AS sma_200,

    -- Volume
    AVG(volume) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS avg_vol_50,

    -- high/lows/range
    MAX(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 251 PRECEDING AND CURRENT ROW
    ) AS high_52w,
    MIN(close) OVER(
      PARTITION BY ticker
      ORDER BY date ASC
      ROWS BETWEEN 251 PRECEDING AND CURRENT ROW
    ) AS low_52w
  FROM
    {{ ref('stg_price__price_daily') }}
),

cleaned AS(
  SELECT
    ticker,
    date,
    close,
    adj_close,
    volume,
    daily_change_pct,
    sma_50,
    sma_100,
    sma_200,
    {{ dbt_utils.safe_divide('close - sma_200', 'sma_200') }} * 100 AS pct_from_sma_200,
    CASE
      WHEN close >= sma_200 THEN TRUE
      ELSE FALSE
    END AS above_sma_200,
    avg_vol_50,
    {{ dbt_utils.safe_divide('volume', 'avg_vol_50') }} AS rel_vol,
    high_52w,
    low_52w,
    {{ dbt_utils.safe_divide('close - low_52w', 'high_52w - low_52w') }} AS range_position_52w
  FROM
    calculation
  ORDER BY
    ticker,
    date DESC
)

SELECT * FROM cleaned