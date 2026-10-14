-- "latest" = keep only the most recently modified row per student id
with ranked as (
    select
        *,
        row_number() over (partition by id order by modifiedon desc) as _rn
    from {{ source('upstream_samples', 'stg_ioesd__student_v2_latest') }}
)

select
    id,
    suffix,
    lastname,
    firstname,
    middlename,
    nickname,
    cast(idnumber as bigint) as idnumber,  -- bigint so it joins to dim_scholar.ioa_student_id (Redshift won't compare bigint = varchar)
    stateidnumber,
    dateentereddistrict,
    dateofbirth,
    ispreregistered,
    gender,
    hispaniclatino,
    race,
    grade,
    email,
    schedulinggradeid,
    schedulingschoolid,
    dateenteredninthgrade,
    anticipatedenrollmentdate,
    enrollmentdate,
    schoolid,
    householdid,
    advisorid,
    altidnumber,
    cityid,
    createdby,
    createdon,
    modifiedby,
    modifiedon,
    cohortyear,
    household_surname,
    household_phone_no,
    homeroom,
    enrollment_status,
    del_me,
    schoolyr_id,
    schoolyr_short_nm,
    schoolyr_is_current,
    excludefromstateattendancestudent,
    excludefromstatereportingstudent,
    phone_number
from ranked
where _rn = 1