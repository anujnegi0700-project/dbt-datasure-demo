SELECT 
    "tardytime", 
    "attendancereasonid", 
    "studentid", 
    "excusedstatus", 
    "virtualstatus", 
    "date",
    "attendancestatus"
FROM {{ source('raw_demo', 'daily_attendance') }}