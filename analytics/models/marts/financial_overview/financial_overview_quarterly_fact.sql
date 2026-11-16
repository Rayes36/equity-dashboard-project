WITH quarterly_fact AS(
  SELECT
    *
  FROM {{ ref('int_financial_overview__quarterly') }}
),

ttm_fact AS(
  SELECT
    *
  FROM {{ ref('int_financial_overview__ttm') }}
),

remove_extras AS(
  SELECT
    qf.*
  FROM
    quarterly_fact AS qf
  INNER JOIN (
    SELECT DISTINCT period
    FROM ttm_fact
  ) AS tf
    ON qf.period = tf.period
)

SELECT * FROM remove_extras