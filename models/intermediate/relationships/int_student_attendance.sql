WITH unique_scholar_school AS (
    SELECT 
        *
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY SCHOLAR_ID ORDER BY SCHOOL_ID DESC) as rn
        FROM {{ ref('int_scholar_school_mapping') }}
    ) 
    WHERE rn = 1
)

SELECT 
    a.*,
    s.SCHOOL_ID,
    s.CAMPUS_ID
FROM {{ ref('int_attendance_metrics') }} a
JOIN unique_scholar_school s
    ON a.SCHOLAR_ID = s.SCHOLAR_ID