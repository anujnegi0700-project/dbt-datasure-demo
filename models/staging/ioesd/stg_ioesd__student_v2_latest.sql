{{ config(
    tags=["teacherconnect_ambiguous"]
) }}

SELECT 
    id
    ,suffix
    ,lastname
    ,firstname
    ,middlename
    ,nickname
    ,idnumber
    ,stateidnumber
    ,dateentereddistrict
    ,dateofbirth
    ,ispreregistered
    ,gender
    ,hispaniclatino
    ,race
    ,grade
    ,email
    ,schedulinggradeid
    ,schedulingschoolid
    ,dateenteredninthgrade
    ,anticipatedenrollmentdate
    ,enrollmentdate
    ,schoolid
    ,householdid
    ,advisorid
    ,altidnumber
    ,cityid
    ,createdby
    ,createdon
    ,modifiedby
    ,modifiedon
    ,cohortyear
    ,household_surname
    ,household_phone_no
    ,homeroom
    ,enrollment_status
    ,del_me
    ,schoolyr_id
    ,schoolyr_short_nm
    ,schoolyr_is_current
    ,excludefromstateattendancestudent
    ,excludefromstatereportingstudent
    ,phone_number
FROM {{ source('raw_demo', 'student_v2_latest') }}

