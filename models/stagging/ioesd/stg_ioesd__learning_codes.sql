select
    code,
    description,
    code_id
from {{ source('upstream_samples', 'stg_ioesd__learning_codes') }}
