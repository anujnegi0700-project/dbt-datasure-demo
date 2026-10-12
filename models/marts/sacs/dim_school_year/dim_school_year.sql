{{ config(
    materialized='incremental',
    schema='sacs',
    alias='dim_school_year',
    unique_key=['esd_schoolyr_id','esd_med_name'],
    on_schema_change='fail'
) }}

SELECT
    dwh_school_year_id
    ,esd_schoolyr_id::bigint
    ,sms_schoolyr_id
    ,esd_long_name
    ,esd_med_name
    ,esd_short_nm
    ,sms_description::varchar(24)
    ,esd_is_current
    ,esd_is_next
    ,dwh_startdate
    ,dwh_enddate
    ,esd_startdt
    ,esd_enddt
    ,sms_startdate
    ,sms_enddate
    ,bedsdate
    ,tschoolstartdate
    ,CONVERT_TIMEZONE( 'UTC', 'America/New_York', getdate()) as lst_updt_ts
    ,is_previous
FROM {{ source('raw_demo', 'dim_school_year') }}