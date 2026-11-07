WITH source AS(
  SELECT
    *
  FROM {{ source('price', 'raw_fact_security_snapshot') }}
),

cleaned AS(
  SELECT
    ticker,
    TRY_CAST(snapshot_date AS DATE) AS snapshot_date,
    CAST(market_cap AS BIGINT) AS market_cap,
    dividend_yield,
    CAST(volume AS BIGINT) AS volume,
    CAST(avg_volume AS BIGINT) AS avg_volume,
    beta,
    pe,
    forward_pe,
    eps,
    forward_eps,
    peg_ratio,
    CAST(shares_outstanding AS BIGINT) AS shares_outstanding,
    ingested_at
  FROM source
)

SELECT * FROM cleaned