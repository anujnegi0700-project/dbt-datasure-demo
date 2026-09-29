WITH unique_scholar_school AS (
    SELECT 
        *
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY SCHOLAR_ID ORDER BY SCHOOL_ID DESC) as rn
        FROM {{ ref('int_scholar_school') }}
    )
    WHERE rn = 1
)

SELECT
    a.ATTENDANCE_ID,
    a.ATTENDANCE_DATE,
    a.SCHOLAR_ID,
    s.SCHOLAR_NAME,
    s.CLASS,
    s.EDUCATION_LEVEL,
    s.GENDER,
    s.SCHOOL_ID,
    s.SCHOOL_NAME,
    s.CITY,
    s.STATE,
    s.REGION,
    a.ATTENDANCE_STATUS,
    a.PRESENT_FLAG,
    a.ABSENT_FLAG,
    a.LATE_FLAG,
    a.LATE_CHECKIN_FLAG,
    a.CHECK_IN_TIME
FROM {{ ref('int_attendance_metrics') }} a
INNER JOIN unique_scholar_school s
    ON a.SCHOLAR_ID = s.SCHOLAR_ID
QUALIFY ROW_NUMBER() OVER (PARTITION BY a.ATTENDANCE_ID ORDER BY s.SCHOOL_ID DESC) = 1