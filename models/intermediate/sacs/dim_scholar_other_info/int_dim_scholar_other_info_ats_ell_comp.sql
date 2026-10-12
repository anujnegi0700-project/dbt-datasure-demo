WITH ats_ell_comp AS (
    SELECT
        osis_id
        ,CASE 
            WHEN ("last_value" IS NULL or "last_value"::date = current_date or "last_value"::date = current_date - 1) 
                THEN '2100-01-01'
            ELSE "last_value"
        END enddate
    FROM  {{ source('raw_demo', 'ats_frpl_comp') }}
    WHERE ats_ell_code = 'Y'

),
dim_school_year AS (
    SELECT
        dwh_school_year_id
        ,dwh_startdate
        ,dwh_enddate
    FROM {{ ref('dim_school_year') }}
    WHERE current_date BETWEEN dwh_startdate AND dwh_enddate

),
calculate_max_end_date AS (
    SELECT 
        osis_id
        ,MAX(enddate) AS max_end_date 
        ,CASE 
            WHEN max_end_date = '2100-01-01' 
                THEN NULL
            ELSE max_end_date
        END AS ell_last 
    FROM ats_ell_comp
    GROUP BY osis_id
)
SELECT DISTINCT
    ats.osis_id AS osis_student_id
    ,True AS ell_ever
    ,ats.ell_last
    ,ell_last IS NULL OR dwh_school_year_id IS NOT NULL AS ell_syr
FROM calculate_max_end_date AS ats
LEFT JOIN dim_school_year AS currentSY
    ON ats.ell_last between currentSY.dwh_startdate and currentSY.dwh_enddate