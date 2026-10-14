select
    dbn,
    osis_id,
    first_name,
    last_name,
    status,
    grade,
    level,
    ats_ell_code,
    fost_home,
    inserted_date,
    filename
from {{ source('upstream_samples', 'ats_fost_home') }}
