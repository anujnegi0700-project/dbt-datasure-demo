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
    -- CHANGED: was sacs.dim_school (not part of the 14 upstream models) -> now a source in upstream_samples
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
        -- CHANGED: was hard-coded upstream_samples.collate_enrollment_and_grade
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
        -- CHANGED: was source('prod_dwh_ioesd', 'collate_enrollment_and_grade')
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
                ,ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY created_on DESC) rnk
            FROM {{ ref('stg_ioesd__student_learning_code') }} AS slc
            WHERE current_date BETWEEN start_date AND COALESCE(end_date, '9999-01-01')
        ) AS slc_ranked
        WHERE rnk = 1
    ) AS slc
    ON slc.learning_code_id = lc.code_id
),
sped_status AS (
    SELECT
        ioe_student_id
        ,sped_last
        ,sped_ever
    FROM {{ ref('int_dim_scholar_other_info_sped') }}

),
ats_frpl AS (
    SELECT
        frpl_last
        ,frpl_ever
        ,frpl_syr
        ,frpl_famsys_code
        ,frpl_ats_code
        ,dwh_scholar_id
    FROM {{ ref('int_dim_scholar_other_info_ats_frpl_comp') }}

),
ats_ell AS (
    SELECT
        osis_student_id
        ,ell_last
        ,ell_ever
        ,ell_syr
    FROM {{ ref('int_dim_scholar_other_info_ats_ell_comp') }}

),
ats_fost_home AS (
    SELECT
        osis_id
        ,ats_ell_code
        ,fost_home
        ,inserted_date
    FROM {{ ref('ats_fost_home') }}

),
ats_race AS (
    SELECT
        *
    FROM (
        SELECT
            id
            ,multiracial
            ,hispanic
            ,race_amin
            ,race_asian
            ,race_hawaiian
            ,race_black
            ,race_white
            ,race_unspecified
            ,RANK() OVER(PARTITION BY id ORDER BY inserted DESC) rnk
        FROM {{ ref('stg_ats_csv__resi') }}
    ) AS race_ranked
    WHERE rnk = 1
),
scholar_reenroll_likelihood AS (
    SELECT
        sa_scholar_id
        ,re_enroll_likelihood
    FROM {{ ref('int_dim_scholar_other_info_new_or_retrurning') }}
),

lookup_reenroll_likelihood AS (
    SELECT 
    sa_scholar_id AS sa_scholar_id_lookup,
    "re-enroll_likelihood" AS re_enroll_likelihood_lookup
    FROM {{ ref('stg_raw_sy_26_27_re_enroll') }}
)

SELECT DISTINCT
    dslr.dwh_scholar_id
    ,dslr.ioa_student_id AS sa_scholar_id

    ,dslr.first_name
    ,dslr.last_name
    ,dslr.middle_name
    ,dslr.gender
    ,dslr.email
    ,dslr.dateofbirth
    ,dslr.enrollment_status

    ,COALESCE(ioe_student.dateentereddistrict, bce.first_sa_day)  AS date_entered_district
    ,ioe_student.suffix
    ,ioe_student.grade
    ,ioe_student.ispreregistered
    ,ioe_student.enrollmentdate AS enrollment_date

    ,ell.ell_last
    ,ell.ell_ever
    ,ell.ell_syr

    ,fh.fost_home AS fost_home_status

    ,frpl.frpl_last
    ,frpl.frpl_ever
    ,frpl.frpl_syr
    ,frpl.frpl_famsys_code
    ,frpl.frpl_ats_code

    ,CASE 
        WHEN dslr.enrollment_status = 'active' THEN NULL
        ELSE COALESCE(bce.exit_reason_id, lerf.exit_reason_id)
     END AS exit_reason_id
    ,CASE 
        WHEN dslr.enrollment_status = 'active' THEN NULL
        ELSE COALESCE(bce.exit_reason_name, lerf.exit_reason_name)
     END AS exit_reason_txt
    ,bce.first_sa_day
    ,CASE 
        WHEN dslr.ioe_student_id IS NULL
            THEN '2018-07-01'::date
        WHEN dslr.enrollment_status IS NOT NULL AND dslr.enrollment_status != 'active'
            THEN COALESCE(bce.last_sa_day, meed.max_school_enrollment_end_date)
        ELSE bce.last_sa_day
    END AS last_sa_day

    ,sped.sped_last
    ,sped.sped_ever

    ,race.hispanic
    ,race.multiracial
    ,race.race_amin
    ,race.race_asian
    ,race.race_hawaiian
    ,race.race_black
    ,race.race_white
    ,race.race_unspecified

    ,ad.advisor_staff_id AS advisor_esd_staff_id

    ,lc.learning_code_id
    ,lc.code AS learning_code_code
    ,lc.start_date AS learning_code_start
    ,lc.end_date AS learning_code_end

    ,ds.dwh_school_id
    ,ds.esd_school_abbreviation
    ,ds.school_type_abbrev

    ,ms_hs.ms_start_day
    ,ms_hs.hs_start_day

    ,CASE 
        WHEN dateentereddistrict > (curr_school_year_start_date - INTERVAL '30 days') THEN 'New'
        ELSE 'Returning'
    END AS new_or_returning

    ,CASE
        WHEN srl.sa_scholar_id IS NULL THEN 'New'
        WHEN srl."re_enroll_likelihood" = 'Likely Not Re-Enroll' THEN 'New'
        WHEN srl."re_enroll_likelihood" = 'Likely Re-Enroll' THEN 'Returning'
        ELSE NULL
    END AS new_or_returning_v2

    ,CASE
        WHEN lrl.sa_scholar_id_lookup IS NULL THEN 'New'
        WHEN lrl."re_enroll_likelihood_lookup" = 'Likely Not Re-Enroll' THEN 'New'
        WHEN lrl."re_enroll_likelihood_lookup" = 'Likely Re-Enroll' THEN 'Returning'
        ELSE NULL
    END AS new_or_returning_lookup

FROM dim_scholar AS dslr
LEFT JOIN student_v2_latest AS ioe_student
    ON dslr.ioa_student_id=ioe_student.idnumber
LEFT JOIN ats_ell AS ell
    ON ell.osis_student_id=dslr.osis_student_id
LEFT JOIN ats_fost_home AS fh
    ON ell.osis_student_id = fh.osis_id
    AND ell.ell_last = fh.inserted_date
LEFT JOIN ats_frpl AS frpl
    ON dslr.dwh_scholar_id=frpl.dwh_scholar_id
LEFT JOIN bell_calendar_enrollment AS bce
    ON bce.ioe_student_id=dslr.ioe_student_id
LEFT JOIN latest_exit_reason_fallback AS lerf
    ON lerf.student_id=dslr.ioe_student_id
LEFT JOIN dim_school AS ds
    ON ds.esd_school_id = bce.ioe_school_id
    AND ds.esd_school_year_id = bce.esd_school_year_id
LEFT JOIN sped_status AS sped
    ON sped.ioe_student_id=dslr.ioe_student_id
LEFT JOIN ats_race AS race
    ON dslr.osis_student_id=race.id
LEFT JOIN advisor AS ad
    ON dslr.ioe_student_id=ad.student_id
LEFT JOIN learning_codes AS lc
    ON dslr.ioe_student_id = lc.student_id
LEFT JOIN ms_hs_enrollment AS ms_hs
    ON ms_hs.ioe_student_id = dslr.ioe_student_id
LEFT JOIN meed
    ON meed.student_id = dslr.ioe_student_id
LEFT JOIN scholar_reenroll_likelihood AS srl
    ON dslr.ioa_student_id = srl.sa_scholar_id  
LEFT JOIN lookup_reenroll_likelihood AS lrl
    ON dslr.ioa_student_id = lrl.sa_scholar_id_lookup

-- select 
-- --FanOut Example
--     *    
-- --Multiple Row Example: looks like the grades from esd dont match the cohort doc.
-- --    distinct  *
-- from
--     sacs.dim_school
-- where
--     -- Standard dim_school restrictions
--     dwh_school_year_id in (67)
--     and
--     active is true
--     and esd_school_name not ilike ('%train%') 
--     and esd_school_name not ilike ('%summer%')
--     and esd_school_name not ilike ('%rtls%')
--     and esd_school_name not ilike ('%test%')
--     -- Test restriction to isolate issue
--     and esd_school_name ilike ('%Ridgewood%')
-- order by
--     esd_school_name