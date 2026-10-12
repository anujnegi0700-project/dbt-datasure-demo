{{ config(
    materialized='table'
) }}

/*
Making this a mart for the sake of consistency. Should probably be a staging table in the future.
*/
SELECT
    "dbn" AS "dbn",
    "id" AS "osis_id",
    "first" AS "first_name",
    "last" AS "last_name",
    "status" AS "status",
    "grade" AS "grade",
    -- "class" AS "class", -- ats removed it in ats migration on 2026-05-18
    "level" AS "level",
    "lep" AS "ats_ell_code",
    CASE 
        WHEN fost_home = '1.0' THEN '1'
        WHEN fost_home = '2.0' THEN '2'
        WHEN fost_home = '3.0' THEN '3'
        WHEN fost_home = '' THEN NULL
        ELSE fost_home
    END AS "fost_home",
    "inserted" AS "inserted_date",
    "filename" AS "filename"
FROM {{ ref('stg_raw_ats__raw_rchk') }}



