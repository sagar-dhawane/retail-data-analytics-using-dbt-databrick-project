SELECT
id,
date_format(created_at,'yyyy-MM-dd') as order_date,
user_id,
product_id,
round(unit_price,2) as unit_price,
quantity,
round(unit_price * quantity,2) as order_amount
FROM
{{ref('bronze_orders')}}