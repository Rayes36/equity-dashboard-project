WITH latest AS(
  SELECT
    *
  FROM
    {{ ref('int_balance_sheet_decomposition__get_latest') }}
),

-- Current assets -------------------------------------------------------------------------------------------
current_assets_labels__assets_parent AS(
  SELECT
    ticker,
    'Current Assets' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_assets')['current_assets_labels__assets_parent'] }}'
    )
),

cash_short_term_investments_labels__assets AS(
  SELECT
    ticker,
    'Cash and Short Term Investments' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    latest
  WHERE
    label IN(
      {%- for label in var('int_balance_sheet_decomposition_assets')['cash_short_term_investments_labels__assets'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

receivables_labels__assets AS(
  {{ label_bucket('latest', var('int_balance_sheet_decomposition_assets')['receivables_labels__assets'], 'Receivables', mode='priority') }}
),

other_current_assets_labels__assets AS(
  SELECT
    ticker,
    'Other Current Assets' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    latest
  WHERE
    label IN(
      {%- for label in var('int_balance_sheet_decomposition_assets')['other_current_assets_labels__assets'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

-- Non-current assets -----------------------------------------------------------------------------------------
total_assets AS(
  SELECT
    ticker,
    'Assets' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      'Assets'
    )
),

non_current_assets_labels__assets_parent AS(
  SELECT
    ta.ticker,
    'Non-Current Assets' AS label,
    ta.period,
    ta.quarter,
    ta.year,
    CAST(ta.value - ca.value AS BIGINT) AS value,
    ta.data_updated_at
  FROM
    total_assets AS ta
  INNER JOIN current_assets_labels__assets_parent AS ca
    ON ta.ticker = ca.ticker
    AND ta.year = ca.year
    AND ta.quarter = ca.quarter
),

ppe_labels__assets AS(
  SELECT
    ticker,
    'PP&E' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_assets')['ppe_labels__assets'] }}'
    )
),

intangibles_labels__assets AS(
  SELECT
    ticker,
    'Intangibles' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    latest
  WHERE
    label IN(
      {%- for label in var('int_balance_sheet_decomposition_assets')['intangibles_labels__assets'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

other_non_current_assets_labels__assets AS(
  SELECT
    ticker,
    'Other Non-Current Assets' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_assets')['other_non_current_assets_labels__assets'] }}'
    )
),

-- Current liabilities -----------------------------------------------------------------------------------------
total_current_liabilities_labels__liabilities_parent AS(
  SELECT
    ticker,
    'Current Liabilities' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_liabilities')['total_current_liabilities_labels__liabilities_parent'] }}'
    )
),

accounts_payable_labels__liabilities AS(
  SELECT
    ticker,
    'Accounts Payable' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_liabilities')['accounts_payable_labels__liabilities'] }}'
    )
),

accrued_liabilities_labels__liabilities AS(
  SELECT
    ticker,
    'Accrued liabilities' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_liabilities')['accrued_liabilities_labels__liabilities'] }}'
    )
),

other_current_liabilities_labels__liabilities AS(
  {{ label_bucket('latest', var('int_balance_sheet_decomposition_liabilities')['other_current_liabilities_labels__liabilities'], 'Other Current Liabilities', mode='hybrid') }}
),

-- Non-current liabilities -----------------------------------------------------------------------------------------
total_liabilities AS(
  SELECT
    ticker,
    'Liabilities' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      'Liabilities'
    )
),

total_non_current_liabilities_labels__liabilities_parent AS(
  SELECT
    tl.ticker,
    'Non-Current Liabilities' AS label,
    tl.period,
    tl.quarter,
    tl.year,
    CAST(tl.value - cl.value AS BIGINT) AS value,
    tl.data_updated_at
  FROM
    total_liabilities AS tl
  INNER JOIN total_current_liabilities_labels__liabilities_parent AS cl
    ON tl.ticker = cl.ticker
    AND tl.year = cl.year
    AND tl.quarter = cl.quarter
),

long_term_debt_labels__liabilities AS(
  {{ label_bucket('latest', var('int_balance_sheet_decomposition_liabilities')['long_term_debt_labels__liabilities'], 'Long Term Debt', mode='priority') }}
),

long_term_operating_lease_liabilities_labels__liabilities AS(
  SELECT
    ticker,
    'Long Term Operating Lease Liabilities' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_liabilities')['long_term_operating_lease_liabilities_labels__liabilities'] }}'
    )
),

other_long_term_liabilities_labels__liabilities AS(
  SELECT
    ticker,
    'Other Long Term Liabilities' AS label,
    period,
    quarter,
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM
    latest
  WHERE
    label IN(
      '{{ var('int_balance_sheet_decomposition_liabilities')['other_long_term_liabilities_labels__liabilities'] }}'
    )
),

deferred_tax_liabilities_labels__liabilities AS(
  {{ label_bucket('latest', var('int_balance_sheet_decomposition_liabilities')['deferred_tax_liabilities_labels__liabilities'], 'Deferred Tax Liabilities', mode='priority') }}
),

combined AS(
  SELECT
    *
  FROM
    current_assets_labels__assets_parent
  
  UNION ALL
  SELECT
    *
  FROM
    cash_short_term_investments_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    receivables_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    other_current_assets_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    non_current_assets_labels__assets_parent
  
  UNION ALL
  SELECT
    *
  FROM
    ppe_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    intangibles_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    other_non_current_assets_labels__assets
  
  UNION ALL
  SELECT
    *
  FROM
    total_current_liabilities_labels__liabilities_parent
  
  UNION ALL
  SELECT
    *
  FROM
    accounts_payable_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    accrued_liabilities_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    other_current_liabilities_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    total_non_current_liabilities_labels__liabilities_parent
  
  UNION ALL
  SELECT
    *
  FROM
    long_term_debt_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    long_term_operating_lease_liabilities_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    other_long_term_liabilities_labels__liabilities
  
  UNION ALL
  SELECT
    *
  FROM
    deferred_tax_liabilities_labels__liabilities
)

SELECT * FROM combined