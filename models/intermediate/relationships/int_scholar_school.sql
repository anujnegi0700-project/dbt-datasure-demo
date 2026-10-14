SELECT
    s.SCHOLAR_ID,
    s.SCHOLAR_NAME,
    s.CLASS,
    s.EDUCATION_LEVEL,
    s.GENDER,
    s.EMAIL,
    s.AGE,
    s.ADMISSION_DATE,

    sc.SCHOOL_ID,
    sc.SCHOOL_NAME,
    sc.CITY,
    sc.STATE,
    sc.REGION,
    sc.SCHOOL_TYPE,
    sc.OWNERSHIP_CATEGORY

FROM {{ ref('int_scholar_classification') }} s

LEFT JOIN (
    SELECT DISTINCT
        SCHOOL_ID,
        SCHOOL_NAME,
        CITY,
        STATE,
        REGION,
        SCHOOL_TYPE,
        OWNERSHIP_CATEGORY
    FROM {{ ref('int_school_profile') }}
) sc
    ON s.SCHOOL_ID = sc.SCHOOL_ID