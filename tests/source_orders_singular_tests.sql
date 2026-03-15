{{
    config(severity ='warn',
            store_failures ='true',
            limit = 100
             )
}}

SELECT
 *
FROM
{{source('retail_source','orders')}}

where quantity<=0 or unit_price <=0
