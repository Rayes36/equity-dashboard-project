WITH security_info AS(
  SELECT
    *
  FROM
    {{ ref('stg_price__security_info') }}
),

security_snapshot AS(
  SELECT
    *
  FROM
    {{ ref('stg_price__security_snapshot') }}
)

SELECT
  si.ticker,
  si.company_name,
  si.exchange,
  si.type,
  si.sector,
  si.industry,
  si.market,
  si.currency,
  ss.market_cap,
  ss.avg_volume,
  ss.shares_outstanding,
  ss.dividend_yield,
  ss.beta,
  ss.pe,
  ss.forward_pe,
  ss.eps,
  ss.forward_eps,
  ss.peg_ratio,
  si.ingested_at AS data_updated_at
FROM
  security_info AS si
LEFT JOIN security_snapshot AS ss
  ON ss.ticker = si.ticker