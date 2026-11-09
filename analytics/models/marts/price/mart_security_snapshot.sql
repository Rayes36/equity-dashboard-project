WITH security_snapshot AS(
  SELECT
    *
  FROM
    {{ ref('int_price__extract_security_snapshot') }}
),

technical_indicator_snapshot AS(
  SELECT
    *
  FROM
    {{ ref('int_price__technical_indicator_snapshot') }}
),

price_target AS(
  SELECT
    *
  FROM
    {{ ref('stg_price__price_targets') }}
)

SELECT
  s.ticker,
  s.company_name,
  s.exchange,
  s.type,
  s.sector,
  s.industry,
  s.market,
  s.currency,
  s.market_cap,
  s.shares_outstanding,
  s.dividend_yield,
  s.beta,
  s.pe,
  s.forward_pe,
  s.eps,
  s.forward_eps,
  s.peg_ratio,
  ti.as_of_date,
  ti.close,
  ti.prev_close,
  ti.change,
  ti.change_pct,
  ti.high_52w,
  ti.low_52w,
  ti.range_position_52w,
  ti.sma_50,
  ti.sma_100,
  ti.sma_200,
  ti.pct_from_sma_200,
  ti.sma_200w,
  ti.pct_from_sma_200w,
  ti.ema_50,
  ti.ema_100,
  ti.ema_200,
  ti.ema_200w,
  ti.rsi_14,
  ti.avg_vol_50,
  ti.rel_vol,
  ti.macd_hist,
  ti.data_updated_at,
  pt.target_high,
  pt.target_low,
  pt.target_mean,
  pt.target_median,
  pt.analyst_rating,
  pt.analyst_rating_mean,
  pt.analyst_count
FROM
  security_snapshot AS s
LEFT JOIN technical_indicator_snapshot AS ti
  ON s.ticker = ti.ticker
LEFT JOIN price_target AS pt
  ON s.ticker = pt.ticker