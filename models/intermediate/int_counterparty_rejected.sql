
{{ config(materialized='view') }}

SELECT
    *,
    CASE
        WHEN counterparty_id IS NULL
            THEN 'Missing Counterparty ID'
        WHEN counterparty_name IS NULL
            THEN 'Missing Counterparty Name'
        WHEN risk_score IS NULL
            THEN 'Missing or Invalid Risk Rating'
        WHEN is_active IS NULL
            THEN 'Missing or Invalid Active Status'
    END AS rejection_reason
FROM {{ ref('stg_counterparty') }}
WHERE counterparty_id IS NULL
   OR counterparty_name IS NULL
   OR risk_score IS NULL
   OR is_active IS NULL