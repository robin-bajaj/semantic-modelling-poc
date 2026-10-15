{{ config(materialized='view') }}

WITH source_data AS (
    SELECT *
    FROM {{ source('banking', 'counterparty') }}
),

standardized AS (
    SELECT
        TRIM(counterparty_id) AS counterparty_id,
        TRIM(counterparty_name) AS counterparty_name,
        INITCAP(TRIM(region)) AS region,
        UPPER(TRIM(risk_rating)) AS risk_rating,
        INITCAP(TRIM(active_status)) AS active_status
    FROM source_data
)

SELECT
    *,
    CASE
        WHEN active_status = 'Active' THEN TRUE
        WHEN active_status = 'Inactive' THEN FALSE
        ELSE NULL
    END AS is_active,
    CASE risk_rating
        WHEN 'LOW' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'HIGH' THEN 3
        ELSE NULL
    END AS risk_score
FROM standardized