with listings as (
    SELECT
        *
    FROM
        {{ ref('dim_listings') }}
),
hosts as (
    SELECT
        *
    FROM
        {{ ref('dim_hosts') }}
)

SELECT
    l.listing_id,
    l.listing_name,
    l.room_type,
    l.minimum_nights,
    l.price,
    l.host_id,
    h.host_name,
    h.is_superhost as host_is_superhost,
    l.created_at,
    greatest(l.updated_at, h.updated_at) as updated_at

FROM
    listings l left join hosts h
    on
        (h.host_id = l.host_id)