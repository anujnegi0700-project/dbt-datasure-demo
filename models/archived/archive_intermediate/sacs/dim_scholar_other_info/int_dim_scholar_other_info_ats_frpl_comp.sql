WITH document_digital AS (
    SELECT
        id
        ,created_on
        ,json_extract_path_text(data::json, 'specific_data', 'elig...') AS famsys_frpl_status
        ,CASE
            WHEN famsys_frpl_status = 'free' OR famsys_frpl_status = 'reduced' THEN 1
            ELSE 0
        END AS famsys_frpl_ever
    FROM {{ source('raw_demo', 'athenaeum_prod_documents_digital__document_digital') }}
    WHERE type ILIKE 'LUNCH%'

),
document_digital_person AS (
    SELECT
        doc_id
        ,person_id
    FROM {{ source('raw_demo', 'athenaeum_prod_documents_digital__document_digital_person') }}

),
dim_scholar AS (
    SELECT
        dwh_scholar_id
        ,osis_student_id
        ,uuid_student_id
    FROM {{ ref('dim_scholar') }}

),
ats_frpl_comp AS (
    SELECT
        osis_id
        ,ats_meal_code
        ,"first_value"
        ,"last_value"
    FROM {{ ref('ats_frpl_comp') }}

),
join_document_digital AS (
    SELECT DISTINCT
        *
    FROM (
        SELECT
            dd.created_on AS start_date
            ,dd.famsys_frpl_status
            ,ds.dwh_scholar_id
            ,ds.osis_student_id
            ,RANK() OVER(PARTITION BY dwh_scholar_id ORDER BY start_date DESC) AS max_start_date
            ,MAX(famsys_frpl_ever) OVER(PARTITION BY dwh_scholar_id) AS famsys_frpl_ever 
        FROM document_digital AS dd
        LEFT JOIN document_digital_person AS ddp
            ON dd.id = ddp.doc_id
        INNER JOIN dim_scholar ds
            ON ds.uuid_student_id = ddp.person_id
    )
    WHERE max_start_date = 1
),
join_ats_frpl_comp AS (
    SELECT DISTINCT
        *
    FROM (
        SELECT
            ats.ats_meal_code
            ,ds.dwh_scholar_id
            ,ds.osis_student_id
            /*
            ,CASE 
                WHEN "last_value" IS NULL or "last_value"::date = current_date or "last_value"::date = current_date - 1
                    THEN '2100-01-01'
                ELSE "last_value"
            END AS enddate
            not needed with using window functions
            */
            ,CASE
                WHEN ats_meal_code = 'A' OR ats_meal_code = '1' OR ats_meal_code = '2' 
                    THEN 1
                ELSE 0
            END AS case_ats_frpl_ever
            ,CASE 
                WHEN ("last_value"::date = current_date) --or "last_value"::date = current_date - 1)
                    THEN NULL
                ELSE "last_value" 
            END AS max_last_value
            ,RANK() OVER(PARTITION BY osis_student_id ORDER BY max_last_value DESC) AS rnk
            ,MAX(case_ats_frpl_ever) OVER(PARTITION BY osis_student_id) AS ats_frpl_ever 
        FROM ats_frpl_comp AS ats
        INNER JOIN dim_scholar AS ds
            ON ats.osis_id=ds.osis_student_id
    )
    WHERE rnk = 1

)

SELECT DISTINCT
    ats.ats_meal_code AS frpl_ats_code
    ,famsys.famsys_frpl_status AS frpl_famsys_code
    ,(ats_frpl_ever = 1 OR famsys_frpl_ever = 1) AS frpl_ever
    ,(ats_meal_code = 'A' OR ats_meal_code = '1' OR ats_meal_code = '2' OR famsys_frpl_status = 'free' OR famsys_frpl_status = 'reduced') AS frpl_syr
    ,CASE
        WHEN famsys.start_date > ats.max_last_value 
            OR (famsys_frpl_status = 'free' AND ats_meal_code NOT IN ('A', '1'))
            OR (famsys_frpl_status = 'reduced') AND ats_meal_code != '2' THEN famsys.start_date
        ELSE ats.max_last_value 
    END AS frpl_last
    ,COALESCE(ats.osis_student_id, famsys.osis_student_id) AS osis_student_id
    ,COALESCE(ats.dwh_scholar_id, famsys.dwh_scholar_id) AS dwh_scholar_id
FROM join_ats_frpl_comp AS ats
FULL JOIN join_document_digital AS famsys
    ON ats.dwh_scholar_id=famsys.dwh_scholar_id
