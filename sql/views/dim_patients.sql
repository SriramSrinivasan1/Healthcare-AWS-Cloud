-- Patients dim table: Standardizes patient demographics, parses readable names from UUID filenames, and computes current age in years.
CREATE OR REPLACE VIEW dim_patients AS
SELECT 
    col0 AS patient_id,
    -- Extracts readable name by stripping the trailing UUID and removing Synthea random digits
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(col0, '_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', ''), '[0-9_]+', ' ')) AS patient_name,
    COALESCE(NULLIF(LOWER(TRIM(col1)), ''), 'unknown') AS gender,
    TRY_CAST(NULLIF(TRIM(col2), '') AS DATE) AS birth_date,
    -- Calculates current age in years for easy cohort segmentation
    DATE_DIFF('year', TRY_CAST(NULLIF(TRIM(col2), '') AS DATE), CURRENT_DATE) AS age_years,
    COALESCE(NULLIF(TRIM(REPLACE(col3, '"', '')), ''), 'Unknown') AS city,
    COALESCE(NULLIF(UPPER(TRIM(REPLACE(col4, '"', ''))), ''), 'Unknown') AS state
FROM patients
WHERE col0 != 'patient_id'
  AND col0 IS NOT NULL;