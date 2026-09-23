SELECT
    ATTENDANCE_ID,
    SCHOLAR_ID,
    ATTENDANCE_DATE,
    CHECK_IN_TIME,

    CASE
        WHEN STATUS IN ('P', 'PRESENT')
            THEN 'PRESENT'

        WHEN STATUS IN ('A', 'ABSENT')
            THEN 'ABSENT'

        WHEN STATUS IN ('L', 'LATE')
            THEN 'LATE'

        ELSE 'UNKNOWN'
    END AS ATTENDANCE_STATUS

FROM {{ ref('stg_attendance') }}