WITH seg_reason_exit_details AS (

    SELECT * FROM {{ source('raw_demo', 'school_enrollment_grade_reason_exit_details') }}
)

SELECT * FROM seg_reason_exit_details