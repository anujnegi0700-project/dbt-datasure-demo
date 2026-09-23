SELECT
    SCHOLAR_ID,
    SCHOLAR_NAME,
    SCHOOL_ID,
    CLASS,
    DATE_OF_BIRTH,
    GENDER,
    EMAIL,
    ADMISSION_DATE,

    DATEDIFF(
        YEAR,
        DATE_OF_BIRTH,
        CURRENT_DATE()
    ) AS AGE,

    YEAR(ADMISSION_DATE) AS ADMISSION_YEAR

FROM {{ ref('stg_scholar') }}