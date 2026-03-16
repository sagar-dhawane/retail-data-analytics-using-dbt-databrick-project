{% set temperature = var('temperature', -30) %}

{% if temperature > 30 %}
select 'HOT' as message

{% elif temperature <10%}
select 'FREEZING TEMPERATURE' as message

{% else %}
select 'NOT HOT' as message

{% endif %}