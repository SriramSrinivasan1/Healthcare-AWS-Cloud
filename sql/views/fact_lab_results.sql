-- Lab results fact table: Strips bracketed LOINC tags from lab names, cleans UCUM unit braces, rounds numeric results, and casts effective dates.
CREATE OR REPLACE VIEW fact_lab_results AS
SELECT 
    patient_id,
    -- Strips bracketed LOINC tags like [Ratio] or [#/volume] and collapses extra spaces
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(test_name, '"', ''), '\[.*?\]', ''), '\s+', ' ')) AS test_name,
    ROUND(TRY_CAST(value AS DOUBLE), 2) AS value,
    -- Removes curly braces from UCUM units like {score} or {INR}
    COALESCE(NULLIF(TRIM(REPLACE(REPLACE(REPLACE(unit, '{', ''), '}', ''), '"', '')), ''), 'N/A') AS unit,
    TRY_CAST(NULLIF(TRIM(effective_date), '') AS DATE) AS effective_date
FROM lab_results
WHERE patient_id != 'patient_id'
  AND TRY_CAST(value AS DOUBLE) IS NOT NULL;