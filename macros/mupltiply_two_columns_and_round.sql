{# Macros to  multiply 2 columns and round it 2#}
{% macro multiply_two_columns_and_round(col1,col2,decimal_place=2) -%}
    round({{col1}} * {{col2}},{{decimal_place}})
{%endmacro%}