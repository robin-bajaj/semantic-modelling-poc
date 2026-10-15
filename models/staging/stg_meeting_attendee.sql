{{ config(materialized='view') }}

WITH standardized AS (
    SELECT
        NULLIF(TRIM(attendee_id), '') AS attendee_id,
        NULLIF(TRIM(meeting_id), '') AS meeting_id,
        NULLIF(TRIM(strategist_id), '') AS strategist_id,
        INITCAP(NULLIF(TRIM(attendee_role), ''))
            AS attendee_role
    FROM {{ source('banking', 'meeting_attendee') }}
)

SELECT
    *,
    CASE
        WHEN attendee_role = 'Organizer' THEN TRUE
        WHEN attendee_role IS NULL THEN NULL
        ELSE FALSE
    END AS is_organizer,

    CASE
        WHEN meeting_id IS NOT NULL
         AND strategist_id IS NOT NULL
            THEN meeting_id || ':' || strategist_id
        ELSE NULL
    END AS participation_key

FROM standardized