WITH student AS (
    SELECT
        id,
        idnumber
    FROM {{ ref('stg_ioesd__student_v2_latest') }}
),

student_photo AS (
    SELECT
        idnumber,
        photoid
    FROM 
    {{ ref('stg_ioesd__student') }}
),
 
daily_attendance AS (
    SELECT
        studentid,
        attendancestatus
    FROM {{ ref('stg_ioesd__daily_attendance') }}
),

attendance AS (
    SELECT
        studentid,
        SUM(CASE WHEN attendancestatus IN ('P', 'T') THEN 1 ELSE 0 END) AS attendance,
        CASE
            WHEN SUM(CASE WHEN attendancestatus IN ('P', 'T') THEN 1 ELSE 0 END) >= 30 THEN TRUE
            ELSE FALSE
        END AS has_30_plus_days_attendance
    FROM daily_attendance
    GROUP BY studentid
),
 
latest_exit_reason AS (
    SELECT
        studentid,
        enrollmentexitreason_id,
        enrollmentexitreason_name,
        ROW_NUMBER() OVER (
            PARTITION BY studentid
            ORDER BY
                CASE WHEN NULLIF(enddate, '') IS NULL THEN 1 ELSE 0 END DESC,
                TO_DATE(NULLIF(enddate, ''), 'MM-DD-YYYY') DESC,
                TO_DATE(NULLIF(startdate, ''), 'MM-DD-YYYY') DESC,
                id DESC
        ) AS row_num
    FROM {{ ref('stg_ioesd__school_enrollment_grade_reason_exit_details') }}
),
 
dim_reason AS (
    SELECT
        src_reason_id,
        src_reason_description
    FROM sacs.dim_reason
),
 
final AS (
    SELECT
        s.id AS ioe_student_id,
        s.idnumber AS sa_scholar_id,
        CASE WHEN sp.photoid IS NOT NULL THEN TRUE ELSE FALSE END AS has_photo,
        COALESCE(a.attendance, 0) AS attendance,
        CASE WHEN attendance > 0 THEN TRUE ELSE FALSE END AS has_attendance,
        COALESCE(a.has_30_plus_days_attendance, FALSE) AS has_30_plus_days_attendance,
        CASE
            WHEN UPPER(COALESCE(dr.src_reason_description, ler.enrollmentexitreason_name, '')) = 'WITHDRAWAL: REGULATED WITHDRAWAL' THEN TRUE
            ELSE FALSE
        END AS regulated_withdrawal,
        dr.src_reason_description AS exit_reason_description,
        ler.enrollmentexitreason_name AS exit_reason_description_ioesd,
                CASE
            WHEN regulated_withdrawal = FALSE
                AND (has_attendance = 'Yes' OR has_30_plus_days_attendance = TRUE OR has_photo = TRUE)
                THEN 'Likely Re-Enroll'
            WHEN has_attendance = 'Yes' AND has_30_plus_days_attendance = TRUE
                THEN 'Likely Re-Enroll'
            ELSE 'Likely Not Re-Enroll'
        END AS re_enroll_likelihood
    FROM student AS s
    LEFT JOIN student_photo AS sp 
        ON s.idnumber = sp.idnumber
    LEFT JOIN attendance AS a
        ON s.id = a.studentid
    LEFT JOIN latest_exit_reason AS ler
        ON s.id = ler.studentid
       AND ler.row_num = 1
    LEFT JOIN dim_reason AS dr
        ON NULLIF(ler.enrollmentexitreason_id, '')::INT = dr.src_reason_id
)
 
SELECT 
    *
FROM final