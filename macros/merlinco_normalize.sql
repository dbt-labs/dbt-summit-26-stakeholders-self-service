{% macro merlinco_copper_to_gold(column_name) -%}
    (try_to_number({{ column_name }}) / 100.0)
{%- endmacro %}

{% macro merlinco_normalize_boolean(column_name) -%}
    case
        when lower(trim({{ column_name }})) in ('y', 'yes', 'true', 't', '1') then true
        when lower(trim({{ column_name }})) in ('n', 'no', 'false', 'f', '0') then false
        else null
    end
{%- endmacro %}

{% macro merlinco_normalize_region(column_name) -%}
    case lower(trim({{ column_name }}))
        when 'nr' then 'Northern Reaches'
        when 'northern reaches' then 'Northern Reaches'
        when 'ec' then 'Ember Coast'
        when 'ember coast' then 'Ember Coast'
        when 'sw' then 'Silverwood'
        when 'silverwood' then 'Silverwood'
        when 'ml' then 'The Marshlands'
        when 'the marshlands' then 'The Marshlands'
        when 'cv' then 'Crystal Vale'
        when 'crystal vale' then 'Crystal Vale'
        else nullif(trim({{ column_name }}), '')
    end
{%- endmacro %}
