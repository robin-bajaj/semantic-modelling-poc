{{ config(materialized='view') }}

WITH accounts AS (
    SELECT
        account_id,
        account_name,
        account_type,
        counterparty_id,
        base_currency,
        account_status
    FROM {{ ref('stg_account') }}
),

meetings AS (
    SELECT
        meeting_id,
        account_id,
        is_completed
    FROM {{ ref('stg_meeting') }}
),

activity_summary AS (
    SELECT *
    FROM {{ ref('int_meeting_activity_summary') }}
),

outcome_summary AS (
    SELECT *
    FROM {{ ref('int_meeting_outcome_summary') }}
),

attendance_summary AS (
    SELECT *
    FROM {{ ref('int_meeting_attendance_summary') }}
),

meeting_metrics AS (
    SELECT
        m.meeting_id,
        m.account_id,
        m.is_completed,

        act.activity_count,
        act.completed_activity_count,
        act.total_duration_minutes,

        o.outcome_count,
        o.high_satisfaction_count,
        o.follow_up_count,
        o.past_due_date_count,

        att.attendee_count

    FROM meetings m

    LEFT JOIN activity_summary act
        ON m.meeting_id = act.meeting_id

    LEFT JOIN outcome_summary o
        ON m.meeting_id = o.meeting_id

    LEFT JOIN attendance_summary att
        ON m.meeting_id = att.meeting_id
),

account_aggregates AS (
    SELECT
        account_id,

        COUNT(*) AS meeting_count,

        COUNT(*) FILTER (
            WHERE is_completed = TRUE
        ) AS completed_meeting_count,

        SUM(COALESCE(activity_count, 0))
            AS activity_count,

        SUM(COALESCE(completed_activity_count, 0))
            AS completed_activity_count,

        SUM(COALESCE(total_duration_minutes, 0))
            AS total_duration_minutes,

        SUM(COALESCE(outcome_count, 0))
            AS outcome_count,

        SUM(COALESCE(high_satisfaction_count, 0))
            AS high_satisfaction_count,

        SUM(COALESCE(follow_up_count, 0))
            AS follow_up_count,

        SUM(COALESCE(past_due_date_count, 0))
            AS past_due_date_count,

        SUM(COALESCE(attendee_count, 0))
            AS total_participations

    FROM meeting_metrics
    GROUP BY account_id
)

SELECT
    a.*,

    COALESCE(x.meeting_count, 0)
        AS meeting_count,

    COALESCE(x.completed_meeting_count, 0)
        AS completed_meeting_count,

    COALESCE(x.activity_count, 0)
        AS activity_count,

    COALESCE(x.completed_activity_count, 0)
        AS completed_activity_count,

    COALESCE(x.total_duration_minutes, 0)
        AS total_duration_minutes,

    COALESCE(x.outcome_count, 0)
        AS outcome_count,

    COALESCE(x.high_satisfaction_count, 0)
        AS high_satisfaction_count,

    COALESCE(x.follow_up_count, 0)
        AS follow_up_count,

    COALESCE(x.past_due_date_count, 0)
        AS past_due_date_count,

    COALESCE(x.total_participations, 0)
        AS total_participations,

    CASE
        WHEN COALESCE(x.meeting_count, 0) = 0
            THEN TRUE
        ELSE FALSE
    END AS has_no_meetings

FROM accounts a
LEFT JOIN account_aggregates x
    ON a.account_id = x.account_id