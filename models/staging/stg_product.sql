{{ config(materialized='view') }}

WITH source_data AS (
    SELECT *
    FROM {{ source('banking', 'product') }}
),

standardized AS (
    SELECT
        TRIM(product_id) AS product_id,
        TRIM(product_name) AS product_name,
        INITCAP(TRIM(asset_class)) AS asset_class,
        UPPER(TRIM(risk_category)) AS risk_category
    FROM source_data
),

business_rules AS (
    SELECT
        *,

        CASE risk_category
            WHEN 'LOW' THEN 1
            WHEN 'MEDIUM' THEN 2
            WHEN 'HIGH' THEN 3
            ELSE NULL
        END AS product_risk_score,

        CASE
            WHEN asset_class = 'Derivatives'
              OR asset_class = 'Foreign Exchange'
                THEN TRUE
            WHEN asset_class IN ('Fixed Income', 'Equities')
                THEN FALSE
            ELSE NULL
        END AS requires_specialist_review,

        CASE
            WHEN risk_category = 'HIGH' THEN 'Enhanced Review'
            WHEN risk_category = 'MEDIUM' THEN 'Standard Review'
            WHEN risk_category = 'LOW' THEN 'Simplified Review'
            ELSE 'Unclassified'
        END AS review_category

    FROM standardized
)

SELECT *
FROM business_rules