SELECT
    osis_id
    ,ats_meal_code
    ,status_count
    ,"first_value"
    ,"last_value"
    ,"ranking"
    ,CONVERT_TIMEZONE( 'UTC', 'America/New_York', getdate()) as lst_updt_ts
FROM  {{ source('raw_demo', 'ats_frpl_comp') }}
