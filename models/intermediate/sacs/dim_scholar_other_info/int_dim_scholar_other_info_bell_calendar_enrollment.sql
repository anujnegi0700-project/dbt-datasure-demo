select
    master_date,
    ioe_student_id,
    exit_reason_id,
    exit_reason_name,
    last_sa_day,
    ioe_school_id,
    esd_school_year_id,
    grade_level_description,
    first_sa_day,
    school_enrollment_grade_start_date,
    actively_enrolled
from {{ source('upstream_samples', 'int_dim_scholar_other_info_bell_calendar_enrollment') }}
