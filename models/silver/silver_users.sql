select
id,
created_at,
city,
state,
year(birth_date) birth_year, 
source as source_channel
from
{{ref('bronze_users')}}