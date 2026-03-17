{{
    config(
        materialized ='incremental',
        unique_key ='id'
    )
}}

SELECT *
FROM {{source('retail_source','orders')}}

{% if is_incremental()%}
where created_at >(select max(created_at) from {{this}})
{% endif%}