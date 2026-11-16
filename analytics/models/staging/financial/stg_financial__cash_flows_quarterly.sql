WITH source AS(
  SELECT
    *
  FROM {{ source('financial', 'raw_cash_flows_quarterly') }}
),

cleaned AS(
  SELECT
    ticker,
    label,
    concept,
    depth,
    is_total,
    CASE
      WHEN section IS NULL THEN 'Main'
      ELSE 'Additional'
    END AS section,
    period,
    CAST(regexp_extract(period, 'Q(\\d)') AS INT) AS quarter,
    CAST(regexp_extract(period, '(\\d{4})') AS INT) AS year,
    value,
    ingested_at AS data_updated_at
  FROM
    source
  WHERE
    is_abstract = false
    AND value IS NOT NULL
)

SELECT * FROM cleaned