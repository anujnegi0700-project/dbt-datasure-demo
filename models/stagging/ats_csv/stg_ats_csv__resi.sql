select
    id,
    inserted,
    eth,
    hisp,
    race,
    hispanic,
    multiracial,
    race_amin,
    race_asian,
    race_hawaiian,
    race_black,
    race_white,
    race_unspecified
from {{ source('upstream_samples', 'stg_ats_csv__resi') }}
