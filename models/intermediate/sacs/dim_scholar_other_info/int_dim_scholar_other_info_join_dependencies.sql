WITH advisor AS (
    SELECT
        advisor_staff_id
        ,student_id
    FROM (
        SELECT 
            advisor_staff_id
            ,student_id
            ,ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY advisor_staff_id) as rnk
        FROM {{ ref('stg_ioesd__advisor') }}
    ) WHERE rnk = 1
),
student_v2_latest AS (
    SELECT
        idnumber
        ,suffix
        ,nickname
        ,dateentereddistrict
        ,grade
        ,ispreregistered
        ,anticipatedenrollmentdate
        ,enrollmentdate
    FROM {{ ref('stg_ioesd__student_v2_latest') }}
),
dim_scholar AS (
    SELECT
        dwh_scholar_id
        ,ioe_student_id
        ,osis_student_id
        ,ioa_student_id
        ,first_name
        ,last_name
        ,gender
        ,dateofbirth
        ,enrollment_status
        ,middle_name
        ,email
    FROM {{ ref('dim_scholar') }}
),
dim_school AS (
    SELECT 
        ds.dwh_school_id
        ,ds.esd_school_id
        ,ds.dwh_school_year_id
        ,ds.esd_school_abbreviation
        ,ds.school_type_abbrev
        ,dsy.esd_schoolyr_id AS esd_school_year_id
        ,(SELECT DISTINCT esd_startdt FROM {{ ref('dim_school_year') }} WHERE esd_is_current = 'Yes') AS curr_school_year_start_date
    FROM {{ source('upstream_samples', 'dim_school') }} AS ds
    INNER JOIN {{ ref('dim_school_year') }} AS dsy
    ON ds.dwh_school_year_id = dsy.dwh_school_year_id
),
bell_calendar_enrollment AS (
    SELECT
        *
    FROM (
        SELECT
            ioe_student_id
            ,exit_reason_id
            ,exit_reason_name
            ,first_sa_day
            ,last_sa_day
            ,ioe_school_id
            ,esd_school_year_id
            ,ROW_NUMBER() OVER(PARTITION BY ioe_student_id ORDER BY master_date DESC) AS rnk
        FROM {{ ref('int_dim_scholar_other_info_bell_calendar_enrollment') }}
    ) AS bce_ranked
    WHERE rnk = 1
),
ms_hs_enrollment AS (
    SELECT 
        ioe_student_id
        ,MIN(CASE WHEN grade_level_description = '5' THEN school_enrollment_grade_start_date END) AS ms_start_day
        ,MIN(CASE WHEN grade_level_description = '9' THEN school_enrollment_grade_start_date END) AS hs_start_day
    FROM {{ ref('int_dim_scholar_other_info_bell_calendar_enrollment') }}
    WHERE grade_level_description in ('5', '9')
    GROUP BY ioe_student_id
),
meed AS (
    SELECT
        student_id
        ,school_enrollment_end_date AS max_school_enrollment_end_date
    FROM (
        SELECT 
            student_id
            ,school_enrollment_end_date
            ,RANK() OVER(PARTITION BY student_id ORDER BY school_enrollment_end_date DESC) rnk
        FROM {{ source('upstream_samples', 'collate_enrollment_and_grade') }}
            WHERE exit_reason_id in (78,77)
    ) AS meed_ranked
    WHERE rnk = 1
),
latest_exit_reason_fallback AS (
    SELECT 
        student_id
        ,exit_reason_id
        ,exit_reason_name
    FROM (
        SELECT 
            student_id
            ,exit_reason_id
            ,exit_reason_name
            ,ROW_NUMBER() OVER (
                PARTITION BY student_id
                ORDER BY 
                    school_enrollment_end_date DESC NULLS LAST,
                    school_enrollment_start_date DESC NULLS LAST
                ) AS rn
        FROM {{ source('upstream_samples', 'collate_enrollment_and_grade') }}
        WHERE exit_reason_id IS NOT NULL
    ) AS lerf_ranked
    WHERE rn = 1
),
learning_codes AS (
    SELECT
        slc.student_id
        ,slc.start_date 
        ,slc.end_date
        ,slc.learning_code_id
        ,lc.code AS code 
    FROM {{ ref('stg_ioesd__learning_codes') }} AS lc
    INNER JOIN (
        SELECT
            *
        FROM (
            SELECT 
                slc.student_id
                ,slc.start_date
                ,slc.end_date
                ,slc.learning_code_id
                ,ROW_NUMBER() OVER(PARTITION BY slc.student_id ORDER BY slc.start_date DESC) as rnk
            FROM {{ ref('stg_ioesd__student_learning_codes') }} slc
        ) WHERE rnk = 1
    ) slc ON lc.learning_code_id = slc.learning_code_id
)
SELECT
    ds.dwh_scholar_id
    ,s_v2.idnumber
    ,s_v2.suffix
    ,s_v2.nickname
    ,s_v2.dateentereddistrict
    ,s_v2.grade
    ,s_v2.ispreregistered
    ,s_v2.anticipatedenrollmentdate
    ,s_v2.enrollmentdate
    ,adv.advisor_staff_id
    ,bce.exit_reason_id
    ,bce.exit_reason_name
    ,bce.first_sa_day
    ,bce.last_sa_day
    ,bce.ioe_school_id
    ,bce.esd_school_year_id
    ,ms_hs.ms_start_day
    ,ms_hs.hs_start_day
    ,m.max_school_enrollment_end_date
    ,lerf.exit_reason_id AS fallback_exit_reason_id
    ,lerf.exit_reason_name AS fallback_exit_reason_name
    ,lc.code AS learning_code
FROM dim_scholar ds
LEFT JOIN student_v2_latest s_v2 ON ds.ioe_student_id = s_v2.idnumber
LEFT JOIN advisor adv ON ds.ioe_student_id = adv.student_id
LEFT JOIN bell_calendar_enrollment bce ON ds.ioe_student_id = bce.ioe_student_id
LEFT JOIN ms_hs_enrollment ms_hs ON ds.ioe_student_id = ms_hs.ioe_student_id
LEFT JOIN meed m ON ds.ioe_student_id = m.student_id
LEFT JOIN latest_exit_reason_fallback lerf ON ds.ioe_student_id = lerf.student_id
LEFT JOIN learning_codes lc ON ds.ioe_student_id = lc.student_id