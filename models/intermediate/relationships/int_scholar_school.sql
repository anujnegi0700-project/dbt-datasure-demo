-- SELECT
--     s.SCHOLAR_ID,
--     s.SCHOLAR_NAME,
--     s.CLASS,
--     s.EDUCATION_LEVEL,
--     s.GENDER,
--     s.EMAIL,
--     s.AGE,
--     s.ADMISSION_DATE,

--     sc.SCHOOL_ID,
--     sc.SCHOOL_NAME,
--     sc.CITY,
--     sc.STATE,
--     sc.REGION,
--     sc.SCHOOL_TYPE,
--     sc.OWNERSHIP_CATEGORY

-- FROM {{ ref('int_scholar_classification') }} s

-- LEFT JOIN {{ ref('int_school_profile') }} sc
--     ON s.SCHOOL_ID = sc.SCHOOL_ID

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

LEFT JOIN {{ ref('int_school_profile') }} sc
    ON s.SCHOOL_ID = sc.SCHOOL_ID

UNION ALL

-- Intentional anomaly: ST001 is additionally assigned to S002
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
JOIN {{ ref('int_school_profile') }} sc
    ON sc.SCHOOL_ID = 'S002'

WHERE s.SCHOLAR_ID = 'ST001'