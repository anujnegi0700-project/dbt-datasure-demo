SELECT
    student_id 
    ,start_date 
    ,end_date 
    ,learning_code_id
    ,created_on
    ,is_active_code
FROM {{ source('raw_demo', 'student_learning_code') }}