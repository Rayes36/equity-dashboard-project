WITH technical_indicators_daily AS(
  SELECT
    *
  FROM 
    {{ ref('int_price__technical_indicators_daily') }}
)

SELECT
  ticker,
  date,
  close,
  adj_close,
  daily_change_pct,
  high_52w,
  low_52w,
  range_position_52w,
  sma_50,
  sma_100,
  sma_200,
  pct_from_sma_200,
  above_sma_200,
  ema_50,
  ema_100,
  ema_200,
  rsi_14,
  macd,
  macd_signal,
  macd_hist,
  volume,
  avg_vol_50,
  rel_vol
FROM
  technical_indicators_daily