WITH source_counts AS (
    SELECT COUNT(*) AS trade_count
    FROM {{ ref('stg_trade') }}
),

exposure_counts AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT trade_id) AS distinct_trade_count
    FROM {{ ref('int_trade_exposure') }}
),

agreement_counts AS (
    SELECT SUM(trade_count) AS trade_count
    FROM {{ ref('int_agreement_trade_summary') }}
)

SELECT
    s.trade_count AS source_trades,
    e.row_count AS exposure_rows,
    e.distinct_trade_count AS exposure_distinct_trades,
    a.trade_count AS agreement_summary_trades
FROM source_counts s
CROSS JOIN exposure_counts e
CROSS JOIN agreement_counts a
WHERE s.trade_count <> e.row_count
   OR s.trade_count <> e.distinct_trade_count
   OR s.trade_count <> a.trade_count