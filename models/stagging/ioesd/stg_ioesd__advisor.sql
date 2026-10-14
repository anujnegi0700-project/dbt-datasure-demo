select
    advisor_staff_id,
    student_id,
    idnumber,
    schoolid
from {{ source('upstream_samples', 'stg_ioesd__advisor') }}
