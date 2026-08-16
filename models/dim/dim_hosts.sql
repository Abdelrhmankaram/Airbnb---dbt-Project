{{
    config(
        materialized = 'view'
    )
}}

with src_hosts as (
    select * from {{ ref('stg_hosts') }}
)

SELECT
    host_id,
    CASE 
        WHEN host_name is null THEN 'Anonymous' 
        ELSE  host_name
    END as host_name,
    is_superhost,
    created_at,
    updated_at
FROM
    src_hosts