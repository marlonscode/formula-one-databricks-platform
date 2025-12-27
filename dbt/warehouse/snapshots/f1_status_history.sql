{% snapshot f1_status_history %}

    {{
        config(
            target_schema='staging',
            strategy='check',
            unique_key=['statusid'],
            check_cols=['status'],
        )
    }}

    select
        status_id,
        status
    from {{ source('formula_one', 'status') }}

{% endsnapshot %}