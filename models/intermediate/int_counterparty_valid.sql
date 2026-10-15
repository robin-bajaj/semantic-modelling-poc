{{ config(materialized='view') }}

SELECT *
FROM {{ ref('stg_counterparty') }}
WHERE counterparty_id IS NOT NULL
  AND counterparty_name IS NOT NULL
  AND risk_score IS NOT NULL
  AND is_active IS NOT NULL