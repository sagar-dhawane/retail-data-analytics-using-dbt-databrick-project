{# 2 Ways to set Variables #}
{# 1st Way - Inline #}
{#
{%- set var1 = "hello data engineer" -%}

select '{{ var1 }}' as message

#}

{# 2nd Way #}
{% set var2%}
    'I am agentic engineer'
{% endset %}
select {{var2}} as message