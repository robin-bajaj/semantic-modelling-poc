{{ config(materialized='view') }}

WITH source_data AS (
    SELECT *
    FROM {{ source('banking', 'trade') }}
),

standardized AS (
    SELECT
        TRIM(trade_id) AS trade_id,
        TRIM(agreement_id) AS agreement_id,
        TRIM(product_id) AS product_id,
        trade_date,
        INITCAP(TRIM(trade_status)) AS trade_status,
        CAST(trade_amount AS NUMERIC(18,2)) AS trade_amount,
        UPPER(TRIM(currency)) AS currency
    FROM source_data
),

business_rules AS (
    SELECT
        *,
        CASE
            WHEN trade_status = 'Settled' THEN TRUE
            WHEN trade_status IN ('Open', 'Pending') THEN FALSE
            ELSE NULL
        END AS is_settled,

        CASE
            WHEN trade_amount > 0 THEN TRUE
            WHEN trade_amount <= 0 THEN FALSE
            ELSE NULL
        END AS has_positive_amount,

        EXTRACT(YEAR FROM trade_date)::INTEGER AS trade_year,

        DATE_TRUNC('month', trade_date)::DATE AS trade_month

    FROM standardized
)

SELECT *
FROM business_rules