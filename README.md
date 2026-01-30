# Clinical Database Analysis (SQL)

## Project Overview
This project analyzes a clinic/hospital-style relational database to answer
operational and clinical questions using SQL.

The goal is to demonstrate strong SQL skills including:
- multi-table JOINs
- aggregations and filtering
- subqueries and CTEs
- date-based analysis
- real-world healthcare-style data modeling

## Database Schema
The database contains the following tables:
- patients
- doctors
- visits
- diagnoses
- lab_results
- prescriptions

Relationships are enforced using foreign keys.

## Key Questions Answered
- What departments handle the most visits?
- Which doctors see the most patients?
- What diagnoses are most common overall and by department?
- What is the abnormal lab rate by test?
- Which ER visits are considered high-risk?
- Which patients have frequent abnormal lab results?
- What drugs are most commonly prescribed?
- Which visits involve polypharmacy?

## Tools Used
- SQLite
- SQL

## Files
- schema.sql: database schema definition
- seed.sql: manually created, realistic clinical data
- analysis_queries.sql: analytical SQL queries and results

## Data Disclaimer
- All data in this project is **synthetic and manually created for educational purposes**.
- It does not represent real patients, clinicians, or medical records.
- No real-world or protected health information (PHI) was used.

## Notes
- This project intentionally focuses on SQL-based analysis.



