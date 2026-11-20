-- Conditions fact table: Cleans clinical diagnosis labels by stripping '(disorder)' tags, casts dates, and flags null abatement dates as 'Ongoing'.
CREATE OR REPLACE VIEW fact_conditions AS
SELECT 
    col0 AS patient_id,
    -- Removes '(disorder)' suffix, stray quotes, and extra spaces for clean chart labels
    TRIM(REGEXP_REPLACE(REPLACE(REPLACE(col1, '(disorder)', ''), '"', ''), '\s+', ' ')) AS condition,
    TRY_CAST(NULLIF(TRIM(col2), '') AS DATE) AS onset_date,
    TRY_CAST(NULLIF(TRIM(col3), '') AS DATE) AS abatement_date,
    -- Provides a readable status label when abatement_date is null
    CASE 
        WHEN NULLIF(TRIM(col3), '') IS NULL THEN 'Ongoing'
        ELSE TRIM(col3)
    END AS resolution_status,
    COALESCE(NULLIF(LOWER(TRIM(col4)), ''), 'unknown') AS clinical_status
FROM conditions
WHERE col0 != 'patient_id'
  AND NULLIF(TRIM(col1), '') IS NOT NULL;