WITH data AS(
  SELECT
    *
  FROM
    {{ ref('int_balance_sheet_decomposition__clean') }}
)

SELECT * FROM data