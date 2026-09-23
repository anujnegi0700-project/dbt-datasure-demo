SELECT
    ATTENDANCE_ID,
    SCHOLAR_ID,
    ATTENDANCE_DATE,
    ATTENDANCE_STATUS,
    CHECK_IN_TIME,

    CASE
        WHEN ATTENDANCE_STATUS = 'PRESENT'
            THEN 1
        ELSE 0
    END AS PRESENT_FLAG,

    CASE
        WHEN ATTENDANCE_STATUS = 'ABSENT'
            THEN 1
        ELSE 0
    END AS ABSENT_FLAG,

    CASE
        WHEN ATTENDANCE_STATUS = 'LATE'
            THEN 1
        ELSE 0
    END AS LATE_FLAG,

    CASE
        WHEN CHECK_IN_TIME IS NOT NULL
             AND CAST(CHECK_IN_TIME AS TIME) > '09:00:00'
            THEN 1
        ELSE 0
    END AS LATE_CHECKIN_FLAG

FROM {{ ref('int_attendance_status') }}