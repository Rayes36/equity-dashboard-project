WITH income_statement AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__income_statements_quarterly') }}
),

revenue_labels AS(
  SELECT
    ticker,
    'Revenue' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['revenue_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

cost_of_revenue_labels AS(
  SELECT
    ticker,
    'Cost of Revenue' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['cost_of_revenue_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

gross_profit_labels AS(
  SELECT
    ticker,
    'Gross Profit' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['gross_profit_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

net_income_labels AS(
  SELECT
    ticker,
    'Net Income' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['net_income_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

operating_expenses_labels AS(
  SELECT
    ticker,
    'Operating Expenses' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['operating_expenses_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

sgna_labels AS(
  SELECT
    ticker,
    'SG&A' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['sgna_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

rnd_labels AS(
  SELECT
    ticker,
    'R&D' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['rnd_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

other_labels AS(
  SELECT
    ticker,
    'Other' AS label,
    period,
    quarter,
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM
    income_statement
  WHERE
    label IN(
      {%- for label in var('int__revenue_expenses')['other_labels'] %}
      '{{ label }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  GROUP BY
    ticker,
    period,
    quarter,
    year
),

combined AS(
  SELECT
    *
  FROM
    revenue_labels

  UNION ALL
  SELECT
    *
  FROM cost_of_revenue_labels

  UNION ALL
  SELECT
    *
  FROM gross_profit_labels

  UNION ALL
  SELECT
    *
  FROM net_income_labels

  UNION ALL
  SELECT
    *
  FROM operating_expenses_labels

  UNION ALL
  SELECT
    *
  FROM sgna_labels

  UNION ALL
  SELECT
    *
  FROM rnd_labels

  UNION ALL
  SELECT
    *
  FROM other_labels
)

SELECT * FROM combined