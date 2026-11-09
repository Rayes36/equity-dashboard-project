import pandas as pd

def model(dbt, session):
    dbt.config(materialized="table", submission_method="serverless_cluster")

    import_df = dbt.ref("int_price__rolling_indicators").toPandas()

    indicator_df = import_df.sort_values(['ticker', 'date']).reset_index(drop=True)
    indicator_close = indicator_df.groupby('ticker')['close']

    # ema
    for n in(50, 100, 200):
        indicator_df[f'ema_{n}'] = indicator_close.transform(lambda s: s.ewm(span=n, adjust=False).mean())

    # rsi
    delta = indicator_df.groupby("ticker")["close"].diff()
    gain = delta.clip(lower=0)
    loss = -delta.clip(upper=0)

    avg_gain = gain.groupby(indicator_df["ticker"]).transform(
        lambda s: s.ewm(alpha=1/14, adjust=False, min_periods=14).mean()
    )
    avg_loss = loss.groupby(indicator_df["ticker"]).transform(
        lambda s: s.ewm(alpha=1/14, adjust=False, min_periods=14).mean()
    )

    indicator_df["rsi_14"] = 100 - 100 / (1 + avg_gain / avg_loss)

    # macd
    indicator_df["macd"] = (
        indicator_close.transform(lambda s: s.ewm(span=12, adjust=False).mean())
        - indicator_close.transform(lambda s: s.ewm(span=26, adjust=False).mean())
    )

    indicator_df["macd_signal"] = indicator_df.groupby("ticker")["macd"].transform(
        lambda s: s.ewm(span=9, adjust=False).mean()
    )

    indicator_df["macd_hist"] = indicator_df["macd"] - indicator_df["macd_signal"]
    
    # cut off the excess 1 year for smoothing
    cutoff_date = indicator_df["date"].max() - pd.DateOffset(years=10)
    int_price__technical_indicators_daily = indicator_df[indicator_df["date"] >= cutoff_date].reset_index(drop=True)
    
    return int_price__technical_indicators_daily