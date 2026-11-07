WITH source AS(
  SELECT
    *
  FROM {{ source('price', 'raw_fact_price_targets') }}
),

cleaned AS(
  SELECT
    ticker,
    TRY_CAST(snapshot_date AS DATE) AS snapshot_date,
    current_price,
    target_high,
    target_low,
    target_mean,
    target_median,
    recommendation_mean AS analyst_rating_mean,
    REPLACE(recommendation_key, '_', ' ') AS analyst_rating,
    analyst_count,
    ingested_at
  FROM source
)

SELECT * FROM cleaned