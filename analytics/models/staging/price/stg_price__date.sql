WITH source AS(
  SELECT
    *
  FROM {{ source('price', 'raw_dim_date') }}
),

cleaned AS(
  SELECT
    TRY_CAST(date AS DATE) AS date,
    year,
    quarter,
    month,
    TRY_CAST(week_start AS DATE) AS week_start
  FROM source
)

SELECT * FROM cleaned