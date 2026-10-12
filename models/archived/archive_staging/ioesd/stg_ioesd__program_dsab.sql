SELECT 
    disability_id
    ,disability_cd
    ,description
    ,createdby
    ,createdon
    ,modifiedby
    ,modifiedon
FROM {{ source('raw_demo', 'program_dsab') }}