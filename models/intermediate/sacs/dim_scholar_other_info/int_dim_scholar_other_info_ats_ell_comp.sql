select
    osis_student_id,
    ell_ever,
    ell_last,
    ell_syr
from {{ source('upstream_samples', 'int_dim_scholar_other_info_ats_ell_comp') }}
