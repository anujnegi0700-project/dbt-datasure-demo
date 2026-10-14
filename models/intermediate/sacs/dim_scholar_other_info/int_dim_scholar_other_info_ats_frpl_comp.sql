select
    frpl_ats_code,
    frpl_famsys_code,
    frpl_ever,
    frpl_syr,
    frpl_last,
    osis_student_id,
    dwh_scholar_id
from {{ source('upstream_samples', 'int_dim_scholar_other_info_ats_frpl_comp') }}
