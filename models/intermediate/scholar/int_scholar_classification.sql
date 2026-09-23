SELECT
    SCHOLAR_ID,
    SCHOLAR_NAME,
    SCHOOL_ID,
    CLASS,
    DATE_OF_BIRTH,
    GENDER,
    EMAIL,
    ADMISSION_DATE,
    AGE,
    ADMISSION_YEAR,

    CASE
        WHEN CLASS IN ('1', '2', '3', '4', '5')
            THEN 'PRIMARY'

        WHEN CLASS IN ('6', '7', '8')
            THEN 'MIDDLE'

        WHEN CLASS IN ('9', '10')
            THEN 'SECONDARY'

        WHEN CLASS IN ('11', '12')
            THEN 'SENIOR_SECONDARY'

        ELSE 'UNKNOWN'
    END AS EDUCATION_LEVEL

FROM {{ ref('int_scholar_profile') }}