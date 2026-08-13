{{
    config(
        materialized = 'incremental',
        on_schema_change = 'fail'
    )
}}

with src_reviews as (
    select * from {{ ref('stg_reviews') }}
)

SELECT
    *
FROM src_reviews
where review_text is not NULL
{% if is_incremental() %}
    AND review_date > (select max(review_date) from {{ this }} )
{% endif %}