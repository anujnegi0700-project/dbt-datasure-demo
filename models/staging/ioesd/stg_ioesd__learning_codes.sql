SELECT
    "code",
    "description",
    "code_id"
FROM {{ source('raw_demo', 'learning_codes') }}