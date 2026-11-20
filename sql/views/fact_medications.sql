-- Medications fact table: Standardizes medication names by stripping verbose dosage forms and normalizing casing
CREATE OR REPLACE VIEW fact_medications AS
SELECT 
    col0 AS patient_id,
    -- Extracts clean drug name before dosage numbers (e.g., 'lisinopril 10 MG Oral Tablet' -> 'Lisinopril')
    TRIM(REGEXP_REPLACE(LOWER(REPLACE(col1, '"', '')), '\s+[0-9]+.*$', '')) AS medication_clean,
    TRIM(REGEXP_REPLACE(REPLACE(col1, '"', ''), '\s+', ' ')) AS medication_full,
    TRY_CAST(NULLIF(TRIM(col2), '') AS DATE) AS authored_date,
    COALESCE(NULLIF(LOWER(TRIM(col3)), ''), 'unknown') AS status
FROM medications
WHERE col0 != 'patient_id'
  AND NULLIF(TRIM(col1), '') IS NOT NULL;