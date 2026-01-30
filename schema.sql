CREATE TABLE patients (
  patient_id INTEGER PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name  TEXT NOT NULL,
  sex        TEXT CHECK (sex IN ('F','M','X')) NOT NULL,
  birth_date DATE NOT NULL,
  city       TEXT,
  created_at DATE NOT NULL
);

CREATE TABLE doctors (
  doctor_id  INTEGER PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name  TEXT NOT NULL,
  specialty  TEXT NOT NULL,
  department TEXT NOT NULL,
  hire_date  DATE NOT NULL
);

CREATE TABLE visits (
  visit_id       INTEGER PRIMARY KEY,
  patient_id     INTEGER NOT NULL,
  doctor_id      INTEGER NOT NULL,
  visit_date     DATE NOT NULL,
  visit_type     TEXT CHECK (visit_type IN ('ER','Outpatient','Inpatient','Telehealth')) NOT NULL,
  department     TEXT NOT NULL,
  reason         TEXT,
  discharge_date DATE,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)
);

CREATE TABLE diagnoses (
  diagnosis_id   INTEGER PRIMARY KEY,
  visit_id       INTEGER NOT NULL,
  icd_code       TEXT NOT NULL,
  diagnosis_name TEXT NOT NULL,
  is_primary     INTEGER CHECK (is_primary IN (0,1)) NOT NULL,
  FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

CREATE TABLE lab_results (
  lab_result_id INTEGER PRIMARY KEY,
  visit_id      INTEGER NOT NULL,
  test_name     TEXT NOT NULL,
  result_value  REAL NOT NULL,
  unit          TEXT,
  normal_low    REAL,
  normal_high   REAL,
  abnormal_flag INTEGER CHECK (abnormal_flag IN (0,1)) NOT NULL,
  result_date   DATE NOT NULL,
  FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

CREATE TABLE prescriptions (
  prescription_id INTEGER PRIMARY KEY,
  visit_id        INTEGER NOT NULL,
  drug_name       TEXT NOT NULL,
  dose            TEXT,
  frequency       TEXT,
  days_supply     INTEGER,
  start_date      DATE NOT NULL,
  FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);
