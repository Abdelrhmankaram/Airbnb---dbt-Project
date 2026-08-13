with raw_hosts as (
    select * from {{ source('airbnb', 'hosts') }}
)

select
    id as host_id,
    name as host_name,
    case
        when is_superhost = 'f' then FALSE
        when is_superhost = 't' then TRUE
    end as is_superhost,
    created_at,
    updated_at
from raw_hosts