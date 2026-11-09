import pandas as pd

def model(dbt, session):
  dbt.config(materialized="table", submission_method="serverless_cluster")
  
  part1_df = dbt.ref("int_price__extract_latest_technical_indicator").toPandas()
  part2_df = dbt.ref("int_price__extract_week").toPandas()
  
  part2_df = part2_df.sort_values(["ticker", "date"])
  snapshot_week = (part2_df.groupby(["ticker", "week_start"], as_index=False)["close"].last())

  g = snapshot_week.groupby("ticker")["close"]
  snapshot_week["sma_200w"] = g.transform(lambda s: s.rolling(200).mean())
  snapshot_week["ema_200w"] = g.transform(lambda s: s.ewm(span=200, adjust=False).mean())

  snapshot_week_latest = snapshot_week.groupby("ticker").tail(1)[["ticker", "sma_200w", "ema_200w"]]
  snapshot_final_calc = part1_df.merge(snapshot_week_latest, on="ticker", how="left")
  snapshot_final_calc["pct_from_sma_200w"] = (snapshot_final_calc["close"] - snapshot_final_calc["sma_200w"]) / snapshot_final_calc["sma_200w"] * 100
  
  snapshot_final_calc["as_of_date"] = snapshot_final_calc["date"]

  return snapshot_final_calc