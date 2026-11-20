/*
==============================================================
Query 4: Cardiometabolic Screening Coverage
--------------------------------------------------------------
Question: How many patients have key heart and diabetes tests
          on record, and what are the typical values?
Purpose:  Summarizes screening volume, average and maximum values
          for HbA1c, cholesterol, triglycerides, glucose and BMI.
Tables:   fact_lab_results
Result:   04_cardiometabolic_screening.csv
==============================================================
*/

SELECT 
    test_name,
    COUNT(DISTINCT patient_id) AS tested_patients,
    ROUND(AVG(value), 2) AS avg_value,
    ROUND(MAX(value), 2) AS max_value,
    unit
FROM fact_lab_results
-- Filters out routine vitals and CBC sub-metrics to focus on cardiometabolic risk markers
WHERE LOWER(test_name) LIKE '%hemoglobin a1c%'
   OR LOWER(test_name) LIKE '%cholesterol%'
   OR LOWER(test_name) LIKE '%triglyceride%'
   OR LOWER(test_name) LIKE '%glucose in blood%'
   OR LOWER(test_name) LIKE '%body mass index%'
-- Grouping by unit prevents averaging incompatible lab measurement scales together
GROUP BY test_name, unit
ORDER BY tested_patients DESC;
