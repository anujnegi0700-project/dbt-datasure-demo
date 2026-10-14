select
    ioe_student_id,
    sa_scholar_id,
    has_photo,
    attendance,
    has_attendance,
    has_30_plus_days_attendance,
    regulated_withdrawal,
    exit_reason_description,
    exit_reason_description_ioesd,
    re_enroll_likelihood
from {{ source('upstream_samples', 'int_dim_scholar_other_info_new_or_retrurning') }}
