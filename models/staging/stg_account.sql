{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(account_id), '') AS account_id,
        NULLIF(TRIM(counterparty_id), '') AS counterparty_id,
        NULLIF(TRIM(account_name), '') AS account_name,
        INITCAP(NULLIF(TRIM(account_type), '')) AS account_type,
        UPPER(NULLIF(TRIM(base_currency), '')) AS base_currency,
        INITCAP(NULLIF(TRIM(account_status), '')) AS account_status
    FROM {{ source('banking', 'account') }}
)

SELECT
    *,
    CASE
        WHEN account_status = 'Active' THEN TRUE
        WHEN account_status IN ('Inactive', 'Closed') THEN FALSE
        ELSE NULL
    END AS is_active,

    CASE
        WHEN base_currency IN ('USD', 'CAD', 'EUR')
            THEN TRUE
        WHEN base_currency IS NULL THEN NULL
        ELSE FALSE
    END AS is_supported_currency

FROM standardized