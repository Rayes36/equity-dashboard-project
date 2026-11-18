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

revenue_labels AS(
  SELECT
    ticker,
    'Revenue' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      '{{ var('int__financial_overview')['revenue_labels'] }}'
    )
),

operating_income_labels AS(
  SELECT
    ticker,
    'Operating Income' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      '{{ var('int__financial_overview')['operating_income_labels'] }}'
    )
),

net_income_labels AS(
  SELECT
    ticker,
    'Net Income' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      '{{ var('int__financial_overview')['net_income_labels'] }}'
    )
),

eps_labels AS(
  SELECT
    ticker,
    'EPS' AS label,
    period,
    quarter,
    year,
    ROUND(CAST(value AS DOUBLE), 2) AS value,
    data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      '{{ var('int__financial_overview')['eps_labels'] }}'
    )
),

operating_cash_flow_labels AS(
  SELECT
    ticker,
    'Operating Cash Flow' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    cash_flow
  WHERE
    label IN(
      '{{ var('int__financial_overview')['operating_cash_flow_labels'] }}'
    )
),

property_plant_equipment_labels AS(
  {{ label_bucket('cash_flow', var('int__financial_overview')['property_plant_equipment_labels'], 'Property Plant and Equipment', mode='priority') }}
),

-- fcf Calculation --------------------------------------------------------------
free_cash_flow_labels AS(
  SELECT
      ocf.ticker,
      'Free Cash Flow' AS label,
      ocf.period,
      ocf.quarter,
      ocf.year,
      ocf.value - ppe.value AS value,
      GREATEST(ocf.data_updated_at, ppe.data_updated_at) AS data_updated_at
    FROM
      operating_cash_flow_labels AS ocf
    INNER JOIN property_plant_equipment_labels AS ppe
      ON ppe.ticker = ocf.ticker
    AND ppe.period = ocf.period
),

combined AS(
  SELECT
    *
  FROM
    revenue_labels

  UNION ALL
  SELECT
    *
  FROM
    operating_income_labels

  UNION ALL
  SELECT
    *
  FROM
    net_income_labels
  
  UNION ALL
  SELECT
    *
  FROM
    eps_labels
  
  UNION ALL
  SELECT
    *
  FROM
    operating_cash_flow_labels
  
  UNION ALL
  SELECT
    *
  FROM
    free_cash_flow_labels
)

SELECT * FROM combined