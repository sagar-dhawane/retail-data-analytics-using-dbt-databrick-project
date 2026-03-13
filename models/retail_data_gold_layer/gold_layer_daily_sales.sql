select
o.order_date,
p.product_name,
p.category,
p.vendor,
u.city,
u.state,
u.source_channel as sales_channel,
sum(o.order_amount) as Total_Revenue
from 
{{ref('silver_order')}} o
left join {{ref('silver_users')}} u
on o.user_id = u.id
left join {{ref('silver_product')}} p
on o.product_id = p.id
group by all
order by total_revenue