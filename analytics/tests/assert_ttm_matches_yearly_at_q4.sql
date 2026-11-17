{{ config(severity='warn') }}

SELECT
  t.ticker, t.label, t.year,
  t.value AS ttm_value,
  y.value AS annual_value
FROM {{ ref('int_financial_overview__ttm') }} t
JOIN {{ ref('int_financial_overview__yearly') }} y
  ON y.ticker = t.ticker AND y.label = t.label AND y.year = t.year
WHERE t.quarter = 4
  AND t.label <> 'Earnings Per Share, Diluted'
  AND NOT (t.ticker = 'AMD' AND t.year IN (2016, 2017))   -- annual is the original filing, quarters are restated
  AND ABS(t.value - y.value) > GREATEST(0.05 * ABS(y.value), 1000000)