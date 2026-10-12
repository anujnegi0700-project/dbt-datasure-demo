WITH student_prgm_dsab AS (
    SELECT
        student_id
        ,disability_id
        ,esd_school_year_id
        ,enddate
        ,startdate
    FROM {{ ref('stg_ioesd__student_prgm_dsab') }}

),
program_dsab AS (
    SELECT
        disability_id
        ,disability_cd
    FROM {{ ref('stg_ioesd__program_dsab') }}

),
dim_school_year AS (
    SELECT
        dwh_startdate
        ,dwh_enddate
        ,esd_schoolyr_id
    FROM {{ ref('dim_school_year') }}

),
fetch_most_recent_start_date AS (
    SELECT
        *
    FROM (
        SELECT
            sped.student_id
            ,sped.startdate
            ,sped.enddate
            ,syr.dwh_startdate
            ,syr.dwh_enddate
            ,syr.esd_schoolyr_id
            ,RANK() OVER (PARTITION BY student_id ORDER BY esd_schoolyr_id DESC, startdate DESC, enddate DESC) AS rnk 
        FROM program_dsab AS dsab
        INNER JOIN student_prgm_dsab AS sped
            ON dsab.disability_id=sped.disability_id
            AND dsab.disability_cd='SPR35'
        INNER JOIN dim_school_year AS syr
            ON cast(syr.esd_schoolyr_id as varchar) = sped.esd_school_year_id
    )
    WHERE rnk = 1
)
SELECT DISTINCT
    student_id AS ioe_student_id
    ,dwh_startdate
    ,dwh_enddate
    
    ,true AS sped_ever
    ,max_max_end_date between dwh_startdate AND dwh_enddate AS sped_syr
    ,CASE 
        WHEN max_max_end_date=getdate()::date 
            THEN NULL
        ELSE max_max_end_date
    END AS sped_last
FROM fetch_most_recent_start_date