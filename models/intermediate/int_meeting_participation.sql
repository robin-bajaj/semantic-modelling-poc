{{ config(materialized='view') }}

WITH participation AS (
    SELECT *
    FROM {{ ref('stg_meeting_attendee') }}
),

meetings AS (
    SELECT *
    FROM {{ ref('stg_meeting') }}
),

accounts AS (
    SELECT *
    FROM {{ ref('stg_account') }}
),

strategists AS (
    SELECT *
    FROM {{ ref('stg_strategist') }}
),

counterparties AS (
    SELECT *
    FROM {{ ref('int_counterparty_valid') }}
)

SELECT
    p.attendee_id,
    p.participation_key,
    p.attendee_role,
    p.is_organizer,

    m.meeting_id,
    m.meeting_date,
    m.meeting_type,
    m.meeting_status,
    m.is_completed,

    a.account_id,
    a.account_name,
    a.account_type,
    a.base_currency,

    c.counterparty_id,
    c.counterparty_name,
    c.region AS counterparty_region,

    s.strategist_id,
    s.strategist_name,
    s.team,
    s.region AS strategist_region

FROM participation p
INNER JOIN meetings m
    ON p.meeting_id = m.meeting_id
INNER JOIN accounts a
    ON m.account_id = a.account_id
INNER JOIN counterparties c
    ON a.counterparty_id = c.counterparty_id
INNER JOIN strategists s
    ON p.strategist_id = s.strategist_id