SELECT
    SCHOOL_ID,

    SCHOOL_NAME,

    CITY,
    STATE,

    CASE
        WHEN SCHOOL_ID IN ('S005', 'S006')
            THEN NULL
        ELSE SCHOOL_TYPE
    END AS SCHOOL_TYPE,

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