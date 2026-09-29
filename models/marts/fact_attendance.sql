WITH source_data AS (
    SELECT
        ATTENDANCE_ID,
        ATTENDANCE_DATE,
        SCHOLAR_ID,
        SCHOOL_ID,
        ATTENDANCE_STATUS,
        PRESENT_FLAG,
        ABSENT_FLAG,
        LATE_FLAG,
        LATE_CHECKIN_FLAG,
        CHECK_IN_TIME
    FROM {{ ref('int_student_attendance') }}
    WHERE ATTENDANCE_ID IS NOT NULL
),

deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ATTENDANCE_ID 
            ORDER BY ATTENDANCE_DATE DESC, CHECK_IN_TIME DESC
        ) as row_num
    FROM source_data

)

SELECT
    ATTENDANCE_ID,
    ATTENDANCE_DATE,
    SCHOLAR_ID,
    SCHOOL_ID,
    ATTENDANCE_STATUS,
    PRESENT_FLAG,
    ABSENT_FLAG,
    LATE_FLAG,
    LATE_CHECKIN_FLAG,
    CHECK_IN_TIME
FROM deduped
WHERE row_num = 1