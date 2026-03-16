{# To Get Current DateTime#}
{% set now = modules.datetime.datetime.now() %}
{{now}}

{# To get columns name for the of any model#}
{% set columns = adapter.get_columns_in_relation(ref('bronze_orders'))%}
{{columns}}

{# For Loop on columns#}
{% for i in columns %}
{{ i.name ~ " & "~ i.dtype}}
{%endfor%}
