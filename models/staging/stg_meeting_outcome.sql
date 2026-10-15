{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(outcome_id), '') AS outcome_id,
        NULLIF(TRIM(activity_id), '') AS activity_id,
        INITCAP(NULLIF(TRIM(outcome_type), ''))
            AS outcome_type,
        satisfaction_score,
        follow_up_due_date
    FROM {{ source('banking', 'meeting_outcome') }}
)

SELECT
    *,
    CASE
        WHEN satisfaction_score IS NULL THEN NULL
        WHEN satisfaction_score NOT BETWEEN 1 AND 5
            THEN 'Invalid Score'
        WHEN satisfaction_score >= 4 THEN 'High'
        WHEN satisfaction_score = 3 THEN 'Medium'
        ELSE 'Low'
    END AS satisfaction_category,

    CASE
        WHEN follow_up_due_date IS NULL THEN NULL
        WHEN follow_up_due_date < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS follow_up_date_passed,

    CASE
        WHEN satisfaction_score BETWEEN 1 AND 5
            THEN TRUE
        WHEN satisfaction_score IS NULL THEN NULL
        ELSE FALSE
    END AS is_valid_satisfaction_score

FROM standardized