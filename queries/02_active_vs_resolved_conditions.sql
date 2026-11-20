/*
==============================================================
Query 2: Active vs. Resolved Conditions
--------------------------------------------------------------
Question: Which patients need long-term care?
Purpose:  Separates short-term, resolved illnesses from ongoing
          (active) chronic conditions to identify cohorts that
          need continued care.
Tables:   fact_conditions
Result:   02_active_vs_resolved_conditions.csv
==============================================================
*/

SELECT 
    condition,
    clinical_status,
    COUNT(DISTINCT patient_id) AS patient_count
FROM fact_conditions
GROUP BY condition, clinical_status
-- Keeps conditions with at least 5 patients to focus on meaningful cohorts
HAVING COUNT(DISTINCT patient_id) >= 5
ORDER BY patient_count DESC, condition;
