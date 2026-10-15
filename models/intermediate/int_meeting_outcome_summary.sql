{{ config(materialized='view') }}

WITH meetings AS (
    SELECT meeting_id
    FROM {{ ref('stg_meeting') }}
),

activities AS (
    SELECT activity_id, meeting_id
    FROM {{ ref('stg_meeting_activity') }}
),

outcomes AS (
    SELECT
        outcome_id,
        activity_id,
        outcome_type,
        satisfaction_score,
        follow_up_due_date
    FROM {{ ref('stg_meeting_outcome') }}
),

outcome_aggregates AS (
    SELECT
        a.meeting_id,

        COUNT(o.outcome_id) AS outcome_count,

        COUNT(DISTINCT a.activity_id)
            AS activities_with_outcomes,

        ROUND(
            AVG(o.satisfaction_score) FILTER (
                WHERE o.satisfaction_score BETWEEN 1 AND 5
            ), 2
        ) AS avg_satisfaction_score,

        COUNT(o.outcome_id) FILTER (
            WHERE o.satisfaction_score >= 4
              AND o.satisfaction_score <= 5
        ) AS high_satisfaction_count,

        COUNT(o.outcome_id) FILTER (
            WHERE o.follow_up_due_date IS NOT NULL
        ) AS follow_up_count,

        COUNT(o.outcome_id) FILTER (
            WHERE o.follow_up_due_date < CURRENT_DATE
        ) AS past_due_date_count

    FROM activities a
    INNER JOIN outcomes o
        ON a.activity_id = o.activity_id

    GROUP BY a.meeting_id
)

SELECT
    m.meeting_id,

    COALESCE(o.outcome_count, 0) AS outcome_count,

    COALESCE(o.activities_with_outcomes, 0)
        AS activities_with_outcomes,

    o.avg_satisfaction_score,

    COALESCE(o.high_satisfaction_count, 0)
        AS high_satisfaction_count,

    COALESCE(o.follow_up_count, 0)
        AS follow_up_count,

    COALESCE(o.past_due_date_count, 0)
        AS past_due_date_count,

    CASE
        WHEN COALESCE(o.outcome_count, 0) = 0 THEN TRUE
        ELSE FALSE
    END AS has_no_outcomes

FROM meetings m
LEFT JOIN outcome_aggregates o
    ON m.meeting_id = o.meeting_id