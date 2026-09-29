WITH unique_scholar_school AS (
    SELECT 
        * 
    FROM ( 
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY SCHOLAR_ID ORDER BY SCHOOL_ID DESC) as rn
    a.LATE_CHECKIN_FLAG,
    a.CHECK_IN_TIME
FROM {{ ref('int_attendance_metrics') }} a
JOIN unique_scholar_school s
    ON a.SCHOLAR_ID = s.SCHOLAR_ID
