SELECT *
FROM
{{ref('bronze_products')}};

select * from {{ref('bronze_products')}}
where title like 's%';