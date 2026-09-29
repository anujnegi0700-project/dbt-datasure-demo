SELECT
    ATTENDANCE_ID,
    ATTENDANCE_DATE,
    LATE_FLAG,
    LATE_CHECKIN_FLAG,
    CHECK_IN_TIME

FROM {{ ref('int_student_attendance') }}