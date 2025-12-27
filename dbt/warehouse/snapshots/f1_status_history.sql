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
        statusid,
        status
    from {{ source('f1', 'f1_status') }}

{% endsnapshot %}