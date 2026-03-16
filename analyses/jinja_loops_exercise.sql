{%- set superheroes = [
  "Superman",
  "Batman",
  "Wonder Woman",
  "Spider-Man",
  "Iron Man",
  "Hulk",
  "Thor",
  "Black Panther",
  "Captain America",
  "Flash",
  "Aquaman"
] 
-%}

{# Using For Loop in select statement#}
SELECT
{%- for hero in superheroes %}
    {{hero}}
    {%- if not loop.last -%}
    ,
    {%- endif -%}

{%- endfor %}
FROM 
table
