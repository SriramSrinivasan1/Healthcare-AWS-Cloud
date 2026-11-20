/*
==============================================================
Query 3: Diagnosis to Treatment
--------------------------------------------------------------
Question: Which medications were patients with hypertension or
          diabetes prescribed after their diagnosis?
Purpose:  Links chronic-disease diagnoses to medications
          prescribed on or after the diagnosis date.
Tables:   dim_patients, fact_conditions, fact_medications
Result:   03_diagnosis_to_treatment.csv
==============================================================
*/

SELECT 
    c.condition, 
    m.medication_clean AS medication, 
    COUNT(DISTINCT p.patient_id) AS prescribed_patients
FROM dim_patients p
JOIN fact_conditions c ON p.patient_id = c.patient_id
JOIN fact_medications m ON p.patient_id = m.patient_id
WHERE (LOWER(c.condition) LIKE '%hypertension%' OR LOWER(c.condition) LIKE '%diabetes%')
  -- Ensures only medications prescribed on or after the diagnosis onset date are linked
  AND m.authored_date >= c.onset_date
  -- Excludes routine OTC painkillers and unrelated acute antibiotics to isolate chronic therapies
  AND m.medication_clean NOT IN ('acetaminophen', 'ibuprofen', 'naproxen sodium', 'amoxicillin', 'penicillin v potassium')
GROUP BY c.condition, m.medication_clean
HAVING COUNT(DISTINCT p.patient_id) >= 2
ORDER BY c.condition, prescribed_patients DESC;
