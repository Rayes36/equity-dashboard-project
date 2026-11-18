WITH income_statement AS(
  SELECT
    *
  FROM
    {{ ref('stg_financial__income_statements_quarterly') }}
),

-- For buckets built with mode='priority', the order of labels is the priority: the first label found wins.
revenue_labels AS(
  {{ label_bucket('income_statement', var('int__revenue_expenses')['revenue_labels'], 'Revenue', mode='priority') }}
),

-- parts that are summed are left as full CTE's for readability
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
  {{ label_bucket('income_statement', var('int__revenue_expenses')['gross_profit_labels'], 'Gross Profit', mode='priority') }}
),

net_income_labels AS(
  {{ label_bucket('income_statement', var('int__revenue_expenses')['net_income_labels'], 'Net Income', mode='priority') }}
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
  {{ label_bucket('income_statement', var('int__revenue_expenses')['sgna_labels'], 'SG&A', mode='priority') }}
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