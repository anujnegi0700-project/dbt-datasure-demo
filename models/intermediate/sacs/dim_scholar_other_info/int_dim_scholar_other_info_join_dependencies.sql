WITH advisor AS (
    SELECT
        student_id
        ,MAX(advisor_staff_id) AS advisor_staff_id
    FROM {{ ref('stg_ioesd__advisor') }}
    GROUP BY 1
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
        student_id
        ,code
    FROM (
        SELECT
            slc.student_id
            ,lc.code AS code 
            ,ROW_NUMBER() OVER(PARTITION BY slc.student_id ORDER BY slc.start_date DESC) as rnk
        FROM {{ ref('stg_ioesd__learning_codes') }} AS slc
        INNER JOIN {{ ref('stg_ioesd__learning_codes') }} AS lc ON slc.learning_code_id = lc.learning_code_id
    ) WHERE rnk = 1
)
SELECT 
    ds.dwh_scholar_id
    ,ds.ioe_student_id
    ,ds.osis_student_id
    ,ds.ioa_student_id
    ,ds.first_name
    ,ds.last_name
    ,ds.gender
    ,ds.dateofbirth
    ,ds.enrollment_status
    ,ds.middle_name
    ,ds.email
    ,sv2.suffix
    ,sv2.nickname
    ,sv2.dateentereddistrict
    ,sv2.grade
    ,sv2.ispreregistered
    ,sv2.anticipatedenrollmentdate
    ,sv2.enrollmentdate
    ,adv.advisor_staff_id
    ,bce.exit_reason_id
    ,bce.exit_reason_name
    ,bce.first_sa_day
    ,bce.last_sa_day
    ,bce.ioe_school_id
    ,bce.esd_school_year_id
    ,mhs.ms_start_day
    ,mhs.hs_start_day
    ,meed.max_school_enrollment_end_date
    ,COALESCE(bce.exit_reason_id, lerf.exit_reason_id) AS final_exit_reason_id
    ,COALESCE(bce.exit_reason_name, lerf.exit_reason_name) AS final_exit_reason_name
    ,lc.code AS learning_code
    ,sch.esd_school_id
    ,sch.dwh_school_year_id
    ,sch.esd_school_abbreviation
    ,sch.school_type_abbrev
    ,sch.esd_school_year_id AS school_year_id
    ,sch.curr_school_year_start_date
FROM dim_scholar ds
LEFT JOIN student_v2_latest sv2 ON ds.ioe_student_id = sv2.idnumber
LEFT JOIN advisor adv ON ds.ioe_student_id = adv.student_id
LEFT JOIN bell_calendar_enrollment bce ON ds.ioe_student_id = bce.ioe_student_id
LEFT JOIN ms_hs_enrollment mhs ON ds.ioe_student_id = mhs.ioe_student_id
LEFT JOIN meed ON ds.ioe_student_id = meed.student_id
LEFT JOIN latest_exit_reason_fallback lerf ON ds.ioe_student_id = lerf.student_id
LEFT JOIN learning_codes lc ON ds.ioe_student_id = lc.student_id
LEFT JOIN dim_school sch ON bce.ioe_school_id = sch.dwh_school_id