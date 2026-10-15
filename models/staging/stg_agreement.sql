{{ config(materialized='view') }}

WITH source_data AS (

    SELECT *
    FROM {{ source('banking', 'agreement') }}

),

standardized AS (

    SELECT
        TRIM(agreement_id) AS agreement_id,
        TRIM(counterparty_id) AS counterparty_id,
        INITCAP(TRIM(agreement_type)) AS agreement_type,
        INITCAP(TRIM(agreement_status)) AS agreement_status,
        effective_date,
        expiry_date,
        CAST(agreement_limit AS NUMERIC(18,2)) AS agreement_limit

    FROM source_data

),

business_rules AS (

    SELECT
        *,

        CASE
            WHEN effective_date IS NULL OR expiry_date IS NULL
                THEN NULL
            WHEN expiry_date < effective_date
                THEN 'Invalid Date Range'
            WHEN expiry_date < CURRENT_DATE
                THEN 'Expired'
            WHEN effective_date > CURRENT_DATE
                THEN 'Not Yet Effective'
            ELSE 'Within Effective Period'
        END AS temporal_status,

        CASE
            WHEN expiry_date IS NOT NULL
                THEN expiry_date - CURRENT_DATE
            ELSE NULL
        END AS days_until_expiry,

        CASE
            WHEN effective_date IS NULL OR expiry_date IS NULL
                THEN NULL
            WHEN expiry_date < effective_date
                THEN NULL
            WHEN agreement_status <> 'Active'
                THEN FALSE
            WHEN CURRENT_DATE BETWEEN effective_date AND expiry_date
                THEN TRUE
            ELSE FALSE
        END AS is_effectively_active,

        CASE
            WHEN expiry_date >= CURRENT_DATE
             AND expiry_date <= CURRENT_DATE + 90
                THEN TRUE
            WHEN expiry_date IS NULL
                THEN NULL
            ELSE FALSE
        END AS is_expiring_soon

    FROM standardized

)

SELECT *
FROM business_rules