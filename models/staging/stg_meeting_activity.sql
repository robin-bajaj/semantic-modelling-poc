{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(activity_id), '') AS activity_id,
        NULLIF(TRIM(meeting_id), '') AS meeting_id,
        NULLIF(TRIM(strategist_id), '') AS strategist_id,
        INITCAP(NULLIF(TRIM(activity_type), ''))
            AS activity_type,
        INITCAP(NULLIF(TRIM(activity_status), ''))
            AS activity_status,
        duration_minutes
    FROM {{ source('banking', 'meeting_activity') }}
)

SELECT
    *,
    CASE
        WHEN duration_minutes IS NULL THEN NULL
        WHEN duration_minutes < 0 THEN 'Invalid Duration'
        WHEN duration_minutes < 30 THEN 'Short'
        WHEN duration_minutes <= 60 THEN 'Medium'
        ELSE 'Long'
    END AS duration_category,

    CASE
        WHEN activity_status = 'Completed' THEN TRUE
        WHEN activity_status IN (
            'Pending', 'In Progress', 'Cancelled'
        ) THEN FALSE
        ELSE NULL
    END AS is_completed,

    CASE
        WHEN duration_minutes >= 0
            THEN ROUND(duration_minutes::NUMERIC / 60, 2)
        ELSE NULL
    END AS duration_hours

FROM standardized