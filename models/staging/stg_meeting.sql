{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(meeting_id), '') AS meeting_id,
        NULLIF(TRIM(account_id), '') AS account_id,
        NULLIF(TRIM(organizer_strategist_id), '')
            AS organizer_strategist_id,
        meeting_date,
        INITCAP(NULLIF(TRIM(meeting_type), ''))
            AS meeting_type,
        INITCAP(NULLIF(TRIM(meeting_status), ''))
            AS meeting_status
    FROM {{ source('banking', 'meeting') }}
)

SELECT
    *,
    EXTRACT(YEAR FROM meeting_date)::INTEGER
        AS meeting_year,

    DATE_TRUNC('month', meeting_date)::DATE
        AS meeting_month,

    CASE
        WHEN meeting_date IS NULL THEN NULL
        ELSE CURRENT_DATE - meeting_date
    END AS days_since_meeting,

    CASE
        WHEN meeting_status = 'Completed' THEN TRUE
        WHEN meeting_status IN (
            'Scheduled', 'Cancelled', 'Pending'
        ) THEN FALSE
        ELSE NULL
    END AS is_completed

FROM standardized