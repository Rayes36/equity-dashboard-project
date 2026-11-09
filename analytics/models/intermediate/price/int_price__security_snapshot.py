import pandas as pd

def model(dbt, session):
  dbt.config(materialized="table", submission_method="serverless_cluster")
  
  # extract from the 3 sources
  part1_df = dbt.ref("int_price__extract_latest_technical_indicator").toPandas()
  part2_df = dbt.ref("int_price__extract_week").toPandas()
  part3_df = dbt.ref("int_price__extract_security_snapshot").toPandas()
  
  part2_df = part2_df.sort_values(["ticker", "date"])
  snapshot_week = (part2_df.groupby(["ticker", "week_start"], as_index=False)["close"].last())

  g = snapshot_week.groupby("ticker")["close"]
  snapshot_week["sma_200w"] = g.transform(lambda s: s.rolling(200).mean())
  snapshot_week["ema_200w"] = g.transform(lambda s: s.ewm(span=200, adjust=False).mean())

  snapshot_week_latest = snapshot_week.groupby("ticker").tail(1)[["ticker", "sma_200w", "ema_200w"]]
  snapshot_final_calc = part1_df.merge(snapshot_week_latest, on="ticker", how="left")
  snapshot_final_calc["pct_from_sma_200w"] = (snapshot_final_calc["close"] - snapshot_final_calc["sma_200w"]) / snapshot_final_calc["sma_200w"] * 100
  
  snapshot = snapshot_final_calc.merge(part3_df, on="ticker", how="left")
  snapshot["as_of_date"] = snapshot["date"]

  snapshot = snapshot[
    [
      "ticker",
      "as_of_date",
      "company_name",
      "exchange",
      "type",
      "sector",
      "industry",
      "market",
      "currency",
      "close",
      "prev_close",
      "change",
      "change_pct",
      "high_52w",
      "low_52w",
      "range_position_52w",
      "sma_50",
      "sma_200",
      "ema_50",
      "ema_200",
      "pct_from_sma_200",
      "sma_200w",
      "ema_200w",
      "pct_from_sma_200w",
      "rsi_14",
      "rel_vol",
      "avg_vol_50",
      "macd_hist",
      "market_cap",
      "avg_volume",
      "shares_outstanding",
      "dividend_yield",
      "beta",
      "pe",
      "forward_pe",
      "eps",
      "forward_eps",
      "peg_ratio",
      "data_updated_at"
    ]
  ]
  
  return snapshot