{{
    config(
        materialized = 'view'
    )
}}

with src_listings as (
    select * from {{ ref('stg_listings') }}
)

SELECT
    listing_id,
    listing_name,
    room_type,
    CASE 
        WHEN minimum_nights = 0 THEN 1
        ELSE minimum_nights
    END as minimum_nights,
    host_id,
    Replace(
        price_str,
        '$',
        ''
    ) :: NUMBER(
        10,
        2
    ) as price,
    created_at,
    updated_at
FROM
    src_listings