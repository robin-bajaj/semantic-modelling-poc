{{ config(materialized='view') }}

WITH trades AS (
    SELECT *
    FROM {{ ref('stg_trade') }}
),

agreements AS (
    SELECT *
    FROM {{ ref('stg_agreement') }}
),

counterparties AS (
    SELECT *
    FROM {{ ref('int_counterparty_valid') }}
),

products AS (
    SELECT *
    FROM {{ ref('stg_product') }}
)

SELECT
    t.trade_id,
    t.trade_date,
    t.trade_status,
    t.trade_amount,
    t.currency,
    t.is_settled,

    a.agreement_id,
    a.agreement_type,
    a.agreement_status,
    a.is_effectively_active,

    c.counterparty_id,
    c.counterparty_name,
    c.region,
    c.risk_rating AS counterparty_risk_rating,

    p.product_id,
    p.product_name,
    p.asset_class,
    p.risk_category AS product_risk_category,
    p.requires_specialist_review

FROM trades t
INNER JOIN agreements a
    ON t.agreement_id = a.agreement_id
INNER JOIN counterparties c
    ON a.counterparty_id = c.counterparty_id
INNER JOIN products p
    ON t.product_id = p.product_id