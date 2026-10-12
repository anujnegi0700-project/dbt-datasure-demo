SELECT 
  "advisor_staff_id", 
  "student_id", 
  "idnumber", 
  "schoolid" 
FROM {{ source('raw_demo', 'advisor') }}