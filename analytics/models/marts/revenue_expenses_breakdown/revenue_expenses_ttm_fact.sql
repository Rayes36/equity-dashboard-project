WITH ttm_fact AS(
  SELECT
    *
  FROM {{ ref('int_revenue_expenses_breakdown__ttm') }}
)

SELECT * FROM ttm_fact