select
    student_id,
    start_date,
    end_date,
    learning_code_id,
    created_on,
    is_active_code
from {{ source('upstream_samples', 'stg_ioesd__student_learning_code') }}
