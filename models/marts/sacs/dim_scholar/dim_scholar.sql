
SELECT 
	sds.dwh_scholar_id
    ,sds.first_name
    ,sds.middle_name
    ,sds.last_name
    ,sds.gender
    ,sds.dateofbirth
    ,sds.email
    ,sds.ioa_student_id
    ,sds.ioe_student_id
    ,sds.sms_student_id
    ,sds.ioi_student_key_ids
    ,sds.ioi_student_key_school_years
    ,sds.osis_student_id
    ,sds.chess_student_id
    ,sds.nysis_student_id
    ,sds.otis_student_id
    ,sds.uuid_student_id
    ,sds.ap_student_id
    ,sds.kbd_student_id
    ,sds.esd_altidnumber
    ,sds.sms_studentno
    ,sds.sms_oldstudentno
    ,sds.enrollment_status
    ,CONVERT_TIMEZONE( 'UTC', 'America/New_York', getdate()) as lst_updt_ts
    ,sds.clever_student_id
FROM {{ source('raw_demo', 'dim_scholar') }} sds
