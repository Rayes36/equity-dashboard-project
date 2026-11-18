WITH quarterly_fact AS(
  SELECT
    *
  FROM {{ ref('int_revenue_expenses_breakdown__quarterly') }}
),

remove_extras AS(
  SELECT
    * EXCEPT(quarter_rank)
  FROM(
    SELECT
      *,
      DENSE_RANK() OVER(
        PARTITION BY ticker
        ORDER BY year, quarter
      ) AS quarter_rank
    FROM
      quarterly_fact
  )
  WHERE
    quarter_rank > 3
)

SELECT * FROM remove_extras