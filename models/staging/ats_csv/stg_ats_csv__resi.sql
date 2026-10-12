select 
    id 
    ,inserted 
    ,eth 
    ,hisp 
    ,race 
    ,hisp='Y' or eth='3' or eth='A'AS hispanic 
    ,eth='G' or eth='7'AS multiracial 
    ,race like '%B%' or eth='1'AS race_amin 
    ,race like '%C%' or eth='2'AS race_asian 
    ,race like '%D%'AS race_hawaiian 
    ,race like '%E%' or eth='4'AS race_black 
    ,race like '%F%' or eth='5'AS race_white 
    ,eth='6' or eth IS NULL AS race_unspecified 
from {{ source('raw_demo', 'resi') }}


