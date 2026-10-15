{{ config(materialized='table') }}

SELECT
    trade_id,
    trade_date,
    agreement_id,
    counterparty_id,
    product_id,
    trade_amount,
    currency,
    trade_status,
    is_settled,

    CASE
    WHEN is_settled = TRUE THEN 1
    ELSE 0
    
END AS settled_trade_indicator
FROM {{ ref('int_trade_exposure') }}