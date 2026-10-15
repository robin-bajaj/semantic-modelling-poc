{{ config(materialized='view') }}

WITH agreements AS (

    SELECT
        agreement_id,
        counterparty_id,
        agreement_type,
        agreement_status,
        agreement_limit,
        is_effectively_active
    FROM {{ ref('stg_agreement') }}

),

trade_aggregates AS (

    SELECT
        agreement_id,
        COUNT(*) AS trade_count,
        COUNT(*) FILTER (
            WHERE trade_status = 'Settled'
        ) AS settled_trade_count,

        SUM(trade_amount) FILTER (
            WHERE currency = 'USD'
        ) AS usd_trade_amount,

        SUM(trade_amount) FILTER (
            WHERE currency = 'CAD'
        ) AS cad_trade_amount,

        SUM(trade_amount) FILTER (
            WHERE currency = 'EUR'
        ) AS eur_trade_amount

    FROM {{ ref('stg_trade') }}
    GROUP BY agreement_id

)

SELECT
    a.agreement_id,
    a.counterparty_id,
    a.agreement_type,
    a.agreement_status,
    a.agreement_limit,
    a.is_effectively_active,

    COALESCE(t.trade_count, 0) AS trade_count,
    COALESCE(t.settled_trade_count, 0) AS settled_trade_count,

    COALESCE(t.usd_trade_amount, 0) AS usd_trade_amount,
    COALESCE(t.cad_trade_amount, 0) AS cad_trade_amount,
    COALESCE(t.eur_trade_amount, 0) AS eur_trade_amount,

    CASE
        WHEN t.agreement_id IS NULL THEN TRUE
        ELSE FALSE
    END AS has_no_trades

FROM agreements a
LEFT JOIN trade_aggregates t
    ON a.agreement_id = t.agreement_id