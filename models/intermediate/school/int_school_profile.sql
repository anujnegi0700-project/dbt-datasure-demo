-- SELECT
--     SCHOOL_ID,
--     SCHOOL_NAME,
--     CITY,
--     STATE,
--     SCHOOL_TYPE,

--     CASE
--         WHEN STATE IN ('Delhi', 'Uttar Pradesh')
--             THEN 'NORTH'
--         ELSE 'OTHER'
--     END AS REGION,

--     CASE
--         WHEN SCHOOL_TYPE = 'GOVERNMENT'
--             THEN 'PUBLIC'
--         WHEN SCHOOL_TYPE = 'PRIVATE'
--             THEN 'PRIVATE'
--         ELSE 'UNKNOWN'
--     END AS OWNERSHIP_CATEGORY

-- FROM {{ ref('int_school_standardized') }}


SELECT
    SCHOOL_ID,

    -- Introduce NULLs in SCHOOL_NAME
    CASE
        WHEN SCHOOL_ID IN ('S003', 'S004')
            THEN NULL
        ELSE SCHOOL_NAME
    END AS SCHOOL_NAME,

    CITY,
    STATE,

    -- Introduce NULLs in SCHOOL_TYPE
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
