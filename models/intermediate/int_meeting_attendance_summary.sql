{{ config(materialized='view') }}

WITH meetings AS (
    SELECT meeting_id
    FROM {{ ref('stg_meeting') }}
),

attendance_aggregates AS (
    SELECT
        meeting_id,

        COUNT(*) AS attendee_count,

        COUNT(DISTINCT strategist_id)
            AS unique_strategist_count,

        COUNT(*) FILTER (
            WHERE is_organizer = TRUE
        ) AS organizer_count

    FROM {{ ref('stg_meeting_attendee') }}
    GROUP BY meeting_id
)

SELECT
    m.meeting_id,

    COALESCE(a.attendee_count, 0)
        AS attendee_count,

    COALESCE(a.unique_strategist_count, 0)
        AS unique_strategist_count,

    COALESCE(a.organizer_count, 0)
        AS organizer_count,

    CASE
        WHEN COALESCE(a.attendee_count, 0) = 0
            THEN TRUE
        ELSE FALSE
    END AS has_no_attendees

FROM meetings m
LEFT JOIN attendance_aggregates a
    ON m.meeting_id = a.meeting_id