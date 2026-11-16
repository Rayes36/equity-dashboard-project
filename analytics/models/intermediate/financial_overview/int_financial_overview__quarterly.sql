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
      'Total Revenue',
      'Operating Income (Loss)',
      'Net Income (Loss) Attributable to Parent'
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
      'Earnings Per Share, Diluted'
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
      'Net Cash Provided by (Used in) Operating Activities'
    )
),

ppe AS(
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
      'Payments to Acquire Property, Plant, and Equipment'
    )
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