WITH quarterly_fact AS(
  SELECT
    *
  FROM {{ ref('int_financial_overview__quarterly') }}
)

SELECT * FROM quarterly_fact