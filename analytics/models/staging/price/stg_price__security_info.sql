WITH source AS(
  SELECT
    *
  FROM {{ source('price', 'raw_dim_security') }}
),

cleaned AS(
  SELECT
    ticker,
    TRIM(company_name) AS company_name,
    exchange,
    type,
    sector,
    industry,
    market,
    currency,
    ingested_at
  FROM source
)

SELECT * FROM cleaned