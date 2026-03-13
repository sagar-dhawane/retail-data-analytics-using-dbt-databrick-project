{{
    config(tags=['contains_pii'])
}}

SELECT *
FROM {{source('retail_source','users')}}