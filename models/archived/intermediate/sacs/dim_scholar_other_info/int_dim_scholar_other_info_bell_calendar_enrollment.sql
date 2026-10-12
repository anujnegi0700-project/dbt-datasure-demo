WITH bell_calendar AS (
    SELECT
        CAST(master_date AS date) AS master_date
        ,ioe_school_id
        ,master_grade_level_id
        ,schoolyr_id
        ,grade_level_description
    FROM {{ source('raw_demo', 'bell_calendar') }}
)

,expected_first_day_after_esd AS (
    SELECT
        CAST(dateentereddistrictstart AS date) AS dateentereddistrictstart
        ,CAST(dateentereddistrictend AS date) AS dateentereddistrictend
        ,CAST(expectedfirstday AS date) AS expectedfirstday
        ,notes
    FROM {{ ref('stg_reporting__expected_first_day_after_esd') }}
)

,student_v2_latest AS (
    SELECT
        id
        ,idnumber
        ,dateentereddistrict
        ,grade
        ,schoolid
    FROM {{ ref('stg_ioesd__student_v2_latest') }}
)

,school_enrollment_and_grade AS (
    SELECT
        student_id
        ,CAST(exit_reason_id AS integer) AS exit_reason_id
        ,exit_reason_name
        ,grade_level_id
        ,school_id
        ,CAST(school_enrollment_start_date AS date) AS school_enrollment_start_date
        ,CAST(school_enrollment_end_date AS date) AS school_enrollment_end_date
        ,CASE
            WHEN CAST(grade_start_date AS date) < CAST(school_enrollment_start_date AS date)
                 AND school_enrollment_start_date IS NOT NULL
                THEN CAST(school_enrollment_start_date AS date)
            ELSE CAST(grade_start_date AS date)
        END AS school_enrollment_grade_start_date
        ,CASE
            WHEN CAST(grade_end_date AS date) > CAST(school_enrollment_end_date AS date)
                 AND school_enrollment_end_date IS NOT NULL
                THEN CAST(school_enrollment_end_date AS date)
            ELSE CAST(grade_end_date AS date)
        END AS school_enrollment_grade_end_date
    FROM {{ ref('stg_ioesd__collate_enrollment_and_grade') }}
    WHERE student_id != '31393' -- needs to be flagged to SIS. ioesd.school_enrollment has bad end_date data for this scholar
)

,calculate_first_day AS (
    SELECT
        student_id
        ,exit_reason_id
        ,school_enrollment_end_date
        ,exit_reason_name
        ,school_enrollment_grade_start_date
        ,school_enrollment_grade_end_date
        ,school_id
        ,grade_level_id
        ,MIN(school_enrollment_start_date) OVER (PARTITION BY student_id
                                            ORDER BY school_enrollment_start_date ASC
                                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS first_day
    FROM school_enrollment_and_grade AS school_enrollment
    LEFT JOIN student_v2_latest AS sv2
        ON school_enrollment.student_id = sv2.id
)

,join_bell_calendar AS (
    SELECT
        bell_calendar.master_date
        ,student_id
        ,exit_reason_id
        ,school_enrollment_end_date
        ,exit_reason_name
        ,first_day
        ,ioe_school_id
        ,schoolyr_id
        ,grade_level_description
        ,school_enrollment_grade_start_date
    FROM bell_calendar
    INNER JOIN calculate_first_day AS school_enrollment
        ON (bell_calendar.master_date BETWEEN school_enrollment.school_enrollment_grade_start_date
            -- AND COALESCE(school_enrollment.school_enrollment_grade_end_date, getdate()))
        AND bell_calendar.ioe_school_id = school_enrollment.school_id
        AND bell_calendar.master_grade_level_id = school_enrollment.grade_level_id
)

SELECT
    enr.master_date
    ,enr.student_id AS ioe_student_id
    ,enr.exit_reason_id
    ,enr.exit_reason_name
    ,enr.school_enrollment_end_date AS last_sa_day
    ,enr.ioe_school_id
    ,enr.schoolyr_id AS esd_school_year_id
    ,enr.grade_level_description
    ,COALESCE(exp_att.expectedfirstday, enr.first_day) AS first_sa_day
    ,enr.school_enrollment_grade_start_date
    ,CASE
        WHEN enr.master_date < COALESCE(exp_att.expectedfirstday, enr.first_day)
            THEN false
        WHEN enr.exit_reason_id IN (77, 78)
            THEN false
        ELSE true
    END AS actively_enrolled
FROM join_bell_calendar AS enr
LEFT JOIN expected_first_day_after_esd AS exp_att
    ON enr.first_day BETWEEN exp_att.dateentereddistrictstart AND exp_att.dateentereddistrictend