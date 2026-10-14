select
    ioe_student_id,
    dwh_startdate,
    dwh_enddate,
    max_max_end_date,
    sped_ever,
    sped_syr,
    sped_last
from {{ source('upstream_samples', 'int_dim_scholar_other_info_sped') }}
