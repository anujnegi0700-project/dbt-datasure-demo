SELECT
    SCHOOL_ID,
    SCHOOL_NAME,
    CITY,
    STATE,

    CASE
        WHEN SCHOOL_TYPE IN ('GOVT', 'GOVERNMENT')
            THEN 'GOVERNMENT'

        WHEN SCHOOL_TYPE IN ('PVT', 'PRIVATE')
            THEN 'PRIVATE'

        ELSE 'UNKNOWN'
    END AS SCHOOL_TYPE,

    CREATED_AT

FROM {{ ref('stg_school') }}