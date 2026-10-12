{{ config(
    tags=['ats', 'raw_ats', 'staging']
) }}

SELECT
  "dbn",
  "last",
  "first",
  "id",
  "status",
  "grade",
  "column6",
  "level",
  "lep",
  "spec_ed",
  "iep_spec_ed",
  "temp_hous",
  "fost_home",
  "ela_elig",
  "ytd_att",
  "inserted",
  "filename"
FROM {{ source('raw_demo', 'ats_fost_home') }}