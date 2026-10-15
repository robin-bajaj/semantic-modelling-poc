{{ config(materialized='table') }}

SELECT
    product_id,
    product_name,
    asset_class,
    risk_category,
    product_risk_score
FROM {{ ref('stg_product') }}