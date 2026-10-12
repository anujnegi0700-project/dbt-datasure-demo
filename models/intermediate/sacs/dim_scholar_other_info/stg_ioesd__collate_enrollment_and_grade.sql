SELECT 
    school_enrollment_id
    ,school_enrollment_grade_id
    ,student_id
    ,school_name
    ,location_override
    ,beds_override
    ,school_enrollment_start_date
    ,school_enrollment_end_date
    ,grade_start_date
    ,grade_end_date
    ,is_currentenrollment
    ,is_created_by
    ,created_on
    ,modified_by
    ,modified_on
    ,ts
    ,file_date
    ,refresh_id
    ,school_id
    ,grade_level_id
    ,entry_reason_id
    ,exit_reason_id
    ,exit_reason_name
FROM {{ source('raw_demo', 'collate_enrollment_and_grade') }}

