SELECT 
  dateentereddistrictstart 
  ,dateentereddistrictend 
  ,expectedfirstday 
  ,notes 
FROM {{ source('raw_demo', 'expected_first_day_after_esd') }}