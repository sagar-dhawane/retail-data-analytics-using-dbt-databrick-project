SELECT
id,
date(date_format(created_at,'yyyy-MM-dd')) as order_date,
user_id,
product_id,
round(unit_price,2) as unit_price,
quantity,
{{multiply_two_columns_and_round('quantity','unit_price',3)}} as order_amount
FROM
{{ref('bronze_orders')}}