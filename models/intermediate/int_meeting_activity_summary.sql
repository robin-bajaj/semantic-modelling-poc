{{ config(materialized='view') }}

WITH meetings AS (
    SELECT
        meeting_id,
        account_id,
        meeting_date,
        meeting_status,
        is_completed
    FROM {{ ref('stg_meeting') }}
),

activity_aggregates AS (
    SELECT
        meeting_id,

        COUNT(*) AS activity_count,

        COUNT(*) FILTER (
            WHERE is_completed = TRUE
        ) AS completed_activity_count,

        COUNT(*) FILTER (
            WHERE is_completed = FALSE
        ) AS incomplete_activity_count,

        SUM(duration_minutes) FILTER (
            WHERE duration_minutes >= 0
        ) AS total_duration_minutes,

        COUNT(DISTINCT strategist_id)
            AS activity_strategist_count

    FROM {{ ref('stg_meeting_activity') }}
    GROUP BY meeting_id
)

SELECT
    m.meeting_id,
    m.account_id,
    m.meeting_date,
    m.meeting_status,
    m.is_completed,

    COALESCE(a.activity_count, 0) AS activity_count,
    COALESCE(a.completed_activity_count, 0)
        AS completed_activity_count,
    COALESCE(a.incomplete_activity_count, 0)
        AS incomplete_activity_count,

    COALESCE(a.total_duration_minutes, 0)
        AS total_duration_minutes,

    ROUND(
        COALESCE(a.total_duration_minutes, 0)::NUMERIC / 60,
        2
    ) AS total_duration_hours,

    COALESCE(a.activity_strategist_count, 0)
        AS activity_strategist_count,

    CASE
        WHEN a.meeting_id IS NULL THEN TRUE
        ELSE FALSE
    END AS has_no_activities

FROM meetings m
LEFT JOIN activity_aggregates a
    ON m.meeting_id = a.meeting_id