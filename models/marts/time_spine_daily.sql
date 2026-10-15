{{ config(materialized='table') }}

SELECT
    generate_series(
        DATE '2020-01-01',
        DATE '2030-12-31',
        INTERVAL '1 day'
    )::DATE AS date_day