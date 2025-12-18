{% snapshot f1_status_history %}
    {{
        config(
            unique_key='statusid',
            strategy='check',
            check_cols='all'
        )
    }}

    select
        statusid,
        status
    from {{ source('f1', 'f1_status') }}
{% endsnapshot %}