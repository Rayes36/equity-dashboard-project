WITH ttm_fact AS(
  SELECT
    *
  FROM {{ ref('int_financial_overview__ttm') }}
)

SELECT * FROM ttm_fact