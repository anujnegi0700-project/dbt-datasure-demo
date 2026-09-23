SELECT
    SCHOLAR_ID,
    SCHOLAR_NAME,
    SCHOOL_ID,
    SCHOOL_NAME,
    CLASS,
    EDUCATION_LEVEL,
    GENDER,
    AGE,
    EMAIL,
    ADMISSION_DATE

FROM {{ ref('int_scholar_school') }}