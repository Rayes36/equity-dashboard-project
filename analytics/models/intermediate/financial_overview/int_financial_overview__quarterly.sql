WITH income_statement AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__income_statements_quarterly') }}
),

cash_flow AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__cash_flows_quarterly') }}
),

whole_num_inst AS(
  SELECT
    ticker,
    label,
    depth,
    is_total,
    section,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__financial_overview')['whole_number_is'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
),

decimal_num_inst AS(
  SELECT
    ticker,
    label,
    depth,
    is_total,
    section,
    period,
    quarter,
    year,
    CAST(value AS DOUBLE) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      '{{ var('int__financial_overview')['decimal_number_is'] }}'
    )
),

operating_cf AS(
  SELECT
    ticker,
    label,
    depth,
    is_total,
    section,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    cash_flow
  WHERE
    label IN(
      '{{ var('int__financial_overview')['ocf'] }}'
    )
),

ppe AS(
  SELECT
    ticker,
    'ppe' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__financial_overview')['ppe'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

-- fcf Calculation --------------------------------------------------------------
free_cash_flow AS(
  SELECT
      ocf.ticker,
      'Free Cash Flow' AS label,
      ocf.depth,
      ocf.is_total,
      ocf.section,
      ocf.period,
      ocf.quarter,
      ocf.year,
      ocf.value - ppe.value AS value,
      GREATEST(ocf.data_updated_at, ppe.data_updated_at) AS data_updated_at
    FROM
      operating_cf AS ocf
    INNER JOIN ppe
      ON ppe.ticker = ocf.ticker
    AND ppe.period = ocf.period
),

combined AS(
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    value,
    data_updated_at
  FROM
    whole_num_inst
    
  UNION ALL
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    ROUND(value, 2) AS value,
    data_updated_at
  FROM
    decimal_num_inst

  UNION ALL
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    value,
    data_updated_at
  FROM
    operating_cf

  UNION ALL
  SELECT
    ticker,
    label,
    period,
    quarter,
    year,
    value,
    data_updated_at
  FROM
    free_cash_flow
)

SELECT * FROM combined