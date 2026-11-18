{% macro label_bucket(source, labels, out_label, mode='sum', has_quarter=true) %}
{%- set quarter_col = 'quarter,' if has_quarter else '' -%}
{%- set group_cols = 'ticker, period, quarter, year' if has_quarter else 'ticker, period, year' -%}
{%- if mode == 'priority' %}
  SELECT
    ticker,
    '{{ out_label }}' AS label,
    period,
    {{ quarter_col }}
    year,
    CAST(value AS BIGINT) AS value,
    data_updated_at
  FROM(
    SELECT
      *,
      ROW_NUMBER() OVER(
        PARTITION BY {{ group_cols }}
        ORDER BY CASE label
          {%- for l in labels %}
          WHEN '{{ l }}' THEN {{ loop.index }}
          {%- endfor %}
        END
      ) AS rn
    FROM {{ source }}
    WHERE label IN(
      {%- for l in labels %}
      '{{ l }}'{% if not loop.last %},{% endif %}
      {%- endfor %}
    )
  )
  WHERE rn = 1
{%- else %}
  SELECT
    ticker,
    '{{ out_label }}' AS label,
    period,
    {{ quarter_col }}
    year,
    SUM(CAST(value AS BIGINT)) AS value,
    MAX(data_updated_at) AS data_updated_at
  FROM {{ source }}
  WHERE label IN(
    {%- for l in labels %}
    '{{ l }}'{% if not loop.last %},{% endif %}
    {%- endfor %}
  )
  GROUP BY {{ group_cols }}
{%- endif %}
{% endmacro %}