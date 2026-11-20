/*
==============================================================
Query 1: Disease Prevalence by Gender
--------------------------------------------------------------
Question: Which conditions are most common, and in whom?
Purpose:  Ranks the most common diagnoses across the patient
          population, split by gender.
Tables:   dim_patients, fact_conditions
Result:   01_disease_prevalence_by_gender.csv
==============================================================
*/

SELECT 
    c.condition, 
    p.gender, 
    -- COUNT(DISTINCT) prevents duplicate counts when a patient has multiple visits for the same condition
    COUNT(DISTINCT p.patient_id) AS unique_patients
FROM dim_patients p
JOIN fact_conditions c ON p.patient_id = c.patient_id
GROUP BY c.condition, p.gender
-- Keeps conditions with at least 5 patients to focus on meaningful cohorts
HAVING COUNT(DISTINCT p.patient_id) >= 5
ORDER BY unique_patients DESC;
