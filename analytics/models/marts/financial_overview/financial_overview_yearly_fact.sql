WITH yearly_fact AS(
  SELECT
    *
  FROM {{ ref('int_financial_overview__yearly') }}
)

SELECT * FROM yearly_fact