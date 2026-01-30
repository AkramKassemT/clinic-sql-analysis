-- Q1: List all visits (newest first)
SELECT *
FROM visits
ORDER BY visit_date DESC;

-- Q2: Count visits by visit type
SELECT 
    visit_type,
    COUNT(*) AS visit_count
FROM visits
GROUP BY visit_type
ORDER BY visit_count DESC;

-- Q3: Recent ER visits with patient + doctor names
SELECT
  v.visit_id,
  v.visit_date,
  p.first_name || ' ' || p.last_name AS patient_name,
  d.first_name || ' ' || d.last_name AS doctor_name,
  v.reason
FROM visits v
JOIN patients p ON p.patient_id = v.patient_id
JOIN doctors d  ON d.doctor_id  = v.doctor_id
WHERE v.visit_type = 'ER'
ORDER BY v.visit_date DESC;

-- Q4: Patients created in 2025
SELECT *
FROM patients
WHERE created_at >= '2025-01-01' AND created_at < '2026-01-01'
ORDER BY created_at;

-- Q5: Visits per department
SELECT 
    department, 
    COUNT(*) AS visit_count
FROM visits
GROUP BY department
ORDER BY visit_count DESC;

-- Q6: Unique patients per department
SELECT 
    department,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM visits
GROUP BY department
ORDER BY unique_patients DESC;

-- Q7: Top 5 doctors by number of visits
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.department, COUNT(v.visit_id) AS total_visits
FROM doctors d
JOIN visits v ON v.doctor_id = d.doctor_id
GROUP BY d.doctor_id
ORDER BY total_visits DESC
LIMIT 5;

-- Q8: Patients who visited more than 3 times
SELECT 
    p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
    COUNT(v.visit_id) AS visit_count
FROM patients p
JOIN visits v ON v.patient_id = p.patient_id
GROUP BY p.patient_id
HAVING visit_count > 3
ORDER BY visit_count DESC;

-- Q9: Average length of stay (in days) for inpatient visits
SELECT 
    AVG(JULIANDAY(discharge_date) - JULIANDAY(visit_date)) AS avg_length_of_stay_days
FROM visits
WHERE visit_type = 'Inpatient'
  AND discharge_date IS NOT NULL;

-- Q10: Abnormal lab rate by test
SELECT 
    test_name,
    COUNT(*) AS total_tests, SUM(abnormal_flag) AS abnormal_tests,
    ROUND(1.0 * SUM(abnormal_flag) / COUNT(*), 2) AS abnormal_rate
FROM lab_results
GROUP BY test_name
ORDER BY abnormal_rate DESC;

-- Q11: “High-risk” visits (ER + abnormal labs)
SELECT DISTINCT 
    v.visit_id, 
    v.visit_date,
    v.department,
    v.visit_type
FROM visits v
JOIN lab_results l ON l.visit_id = v.visit_id
WHERE v.visit_type = 'ER'
  AND l.abnormal_flag = 1;

-- Q12: Inpatient average length of stay (days)
SELECT
  ROUND(AVG(JULIANDAY(v.discharge_date) - JULIANDAY(v.visit_date)), 2) AS avg_los_days
FROM visits v
WHERE v.visit_type = 'Inpatient'
  AND v.discharge_date IS NOT NULL;

-- Q13: Top 10 diagnoses overall
SELECT
  d.icd_code,
  d.diagnosis_name,
  COUNT(*) AS diagnosis_count
FROM diagnoses d
GROUP BY d.icd_code, d.diagnosis_name
ORDER BY diagnosis_count DESC
LIMIT 10;

-- Q14: Percent of visits with >1 diagnosis
SELECT
  ROUND(
    100.0 * SUM(CASE WHEN dx_count > 1 THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_visits_multi_dx
FROM (
  SELECT
    visit_id,
    COUNT(*) AS dx_count
  FROM diagnoses
  GROUP BY visit_id
) t;

-- Q15: For each patient, most recent primary diagnosis
SELECT
  p.patient_id,
  p.first_name || ' ' || p.last_name AS patient_name,
  v.visit_date,
  d.icd_code,
  d.diagnosis_name
FROM patients p
JOIN visits v
  ON v.patient_id = p.patient_id
JOIN diagnoses d
  ON d.visit_id = v.visit_id
WHERE d.is_primary = 1
  AND v.visit_date = (
    SELECT MAX(v2.visit_date)
    FROM visits v2
    JOIN diagnoses d2 ON d2.visit_id = v2.visit_id
    WHERE v2.patient_id = p.patient_id
      AND d2.is_primary = 1
  )
ORDER BY v.visit_date DESC;

-- Q16: Most common diagnosis pairs in the same visit
SELECT
  d1.diagnosis_name AS diagnosis_a,
  d2.diagnosis_name AS diagnosis_b,
  COUNT(*) AS pair_count
FROM diagnoses d1
JOIN diagnoses d2
  ON d1.visit_id = d2.visit_id
 AND d1.diagnosis_id < d2.diagnosis_id
GROUP BY diagnosis_a, diagnosis_b
ORDER BY pair_count DESC
LIMIT 10;

-- Q17: Abnormal lab rate by test_name
SELECT
  test_name,
  COUNT(*) AS total_tests,
  SUM(abnormal_flag) AS abnormal_tests,
  ROUND(1.0 * SUM(abnormal_flag) / COUNT(*), 2) AS abnormal_rate
FROM lab_results
GROUP BY test_name
ORDER BY abnormal_rate DESC;

-- Q18: Abnormal rate for Glucose by department
SELECT
  v.department,
  COUNT(*) AS total_glucose_tests,
  SUM(l.abnormal_flag) AS abnormal_glucose_tests,
  ROUND(1.0 * SUM(l.abnormal_flag) / COUNT(*), 2) AS abnormal_rate
FROM visits v
JOIN lab_results l
  ON l.visit_id = v.visit_id
WHERE l.test_name = 'Glucose'
GROUP BY v.department
ORDER BY abnormal_rate DESC;

-- Q19: Patients with >=3 abnormal labs in last 90 days (relative to latest visit date)
WITH max_date AS (
  SELECT MAX(visit_date) AS max_visit_date FROM visits
)
SELECT
  p.patient_id,
  p.first_name || ' ' || p.last_name AS patient_name,
  COUNT(*) AS abnormal_lab_count_90d
FROM patients p
JOIN visits v
  ON v.patient_id = p.patient_id
JOIN lab_results l
  ON l.visit_id = v.visit_id
CROSS JOIN max_date md
WHERE l.abnormal_flag = 1
  AND v.visit_date >= DATE(md.max_visit_date, '-90 day')
GROUP BY p.patient_id
HAVING abnormal_lab_count_90d >= 3
ORDER BY abnormal_lab_count_90d DESC;

-- Q20: Average glucose by diagnosis (only visits that have Glucose tests)
SELECT
  d.icd_code,
  d.diagnosis_name,
  ROUND(AVG(l.result_value), 2) AS avg_glucose
FROM diagnoses d
JOIN lab_results l
  ON l.visit_id = d.visit_id
WHERE l.test_name = 'Glucose'
GROUP BY d.icd_code, d.diagnosis_name
ORDER BY avg_glucose DESC;

-- Q21: ER visits with abnormal labs (show which test was abnormal)
SELECT DISTINCT
  v.visit_id,
  v.visit_date,
  p.first_name || ' ' || p.last_name AS patient_name,
  l.test_name,
  l.result_value,
  l.unit
FROM visits v
JOIN patients p
  ON p.patient_id = v.patient_id
JOIN lab_results l
  ON l.visit_id = v.visit_id
WHERE v.visit_type = 'ER'
  AND l.abnormal_flag = 1
ORDER BY v.visit_date DESC;

-- Q22: High-risk classification (abnormal labs AND inpatient)
SELECT
  v.visit_id,
  v.visit_date,
  v.visit_type,
  CASE
    WHEN v.visit_type = 'Inpatient'
     AND EXISTS (
       SELECT 1
       FROM lab_results l
       WHERE l.visit_id = v.visit_id
         AND l.abnormal_flag = 1
     )
    THEN 1 ELSE 0
  END AS high_risk_flag
FROM visits v
ORDER BY high_risk_flag DESC, v.visit_date DESC;

-- Q23: Most prescribed drugs overall + by department
-- Overall
SELECT
  pr.drug_name,
  COUNT(*) AS times_prescribed
FROM prescriptions pr
GROUP BY pr.drug_name
ORDER BY times_prescribed DESC;

-- By department
SELECT
  v.department,
  pr.drug_name,
  COUNT(*) AS times_prescribed
FROM prescriptions pr
JOIN visits v
  ON v.visit_id = pr.visit_id
GROUP BY v.department, pr.drug_name
ORDER BY v.department, times_prescribed DESC;

-- Q24: Diagnoses most associated with a given drug (example: Metformin)
SELECT
  d.icd_code,
  d.diagnosis_name,
  COUNT(*) AS dx_count_with_drug
FROM prescriptions pr
JOIN diagnoses d
  ON d.visit_id = pr.visit_id
WHERE pr.drug_name = 'Metformin'
  AND d.is_primary = 1
GROUP BY d.icd_code, d.diagnosis_name
ORDER BY dx_count_with_drug DESC;

-- Q25: Patients with multiple prescriptions in a single visit (polypharmacy)
SELECT
  v.visit_id,
  v.visit_date,
  p.first_name || ' ' || p.last_name AS patient_name,
  COUNT(pr.prescription_id) AS pr_count
FROM visits v
JOIN patients p
  ON p.patient_id = v.patient_id
JOIN prescriptions pr
  ON pr.visit_id = v.visit_id
GROUP BY v.visit_id
HAVING pr_count >= 2
ORDER BY pr_count DESC, v.visit_date DESC;
