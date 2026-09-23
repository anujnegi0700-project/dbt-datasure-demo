SELECT
    SCHOOL_ID,
    SCHOOL_NAME,
    CITY,
    STATE,
    SCHOOL_TYPE,

    CASE
        WHEN STATE IN ('Delhi', 'Uttar Pradesh')
            THEN 'NORTH'
        ELSE 'OTHER'
    END AS REGION,

    CASE
        WHEN SCHOOL_TYPE = 'GOVERNMENT'
            THEN 'PUBLIC'
        WHEN SCHOOL_TYPE = 'PRIVATE'
            THEN 'PRIVATE'
        ELSE 'UNKNOWN'
    END AS OWNERSHIP_CATEGORY

FROM {{ ref('int_school_standardized') }}