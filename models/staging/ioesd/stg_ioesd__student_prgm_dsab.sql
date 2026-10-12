SELECT 
    student_id 
    ,startdate 
    ,enddate
    ,disability_id
    ,id
    ,esd_school_year_id
FROM {{ source('raw_demo', 'student_prgm_dsab') }}