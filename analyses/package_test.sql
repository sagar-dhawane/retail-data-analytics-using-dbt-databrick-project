{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2026-01-25' as date)",
    end_date="cast('2026-02-01' as date)"
   )
}}