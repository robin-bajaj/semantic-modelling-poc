{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(strategist_id), '') AS strategist_id,
        NULLIF(TRIM(strategist_name), '') AS strategist_name,
        INITCAP(NULLIF(TRIM(region), '')) AS region,
        INITCAP(NULLIF(TRIM(team), '')) AS team,
        INITCAP(NULLIF(TRIM(active_status), '')) AS active_status
    FROM {{ source('banking', 'strategist') }}
)

SELECT
    *,
    CASE
        WHEN active_status = 'Active' THEN TRUE
        WHEN active_status = 'Inactive' THEN FALSE
        ELSE NULL
    END AS is_active

FROM standardized