{{ 
    config( schema='sacs' ) 

}}

SELECT
    SCHOOL_ID,
    SCHOOL_NAME,
    CITY,
    STATE,
    REGION,
    SCHOOL_TYPE,
    OWNERSHIP_CATEGORY

FROM {{ ref('int_school_profile') }}