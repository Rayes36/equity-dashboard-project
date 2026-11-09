WITH tagging_latest AS(
  SELECT
    ticker,
    date,
    close,
    LAG(close) OVER (PARTITION BY ticker ORDER BY date ASC) AS prev_close,
    daily_change_pct AS change_pct,
    high_52w,
    low_52w,
    range_position_52w,
    sma_50,
    sma_200,
    ema_50,
    ema_200,
    pct_from_sma_200,
    rsi_14,
    rel_vol,
    avg_vol_50,
    macd_hist,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY date DESC) AS rn
  FROM
    {{ ref('int_price__technical_indicators_daily') }}
),

extract_latest AS(
  SELECT
    ticker,
    date,
    close,
    prev_close,
    close - prev_close AS change,
    change_pct,
    high_52w,
    low_52w,
    range_position_52w,
    sma_50,
    sma_200,
    ema_50,
    ema_200,
    pct_from_sma_200,
    rsi_14,
    rel_vol,
    avg_vol_50,
    macd_hist
  FROM
    tagging_latest
  WHERE
    rn = 1
)

SELECT * FROM extract_latest