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

JOIN {{ ref('int_scholar_school') }} s
    ON a.SCHOLAR_ID = s.SCHOLAR_ID