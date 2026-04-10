-- ============================================================
-- PROJECT: Credit Default Risk Modeling — German Credit Data
-- FILE:    01_data_cleaning.sql
-- AUTHOR:  Favour Chegwe
-- PURPOSE: Data import, validation, and target variable
--          transformation in preparation for EDA and modeling
-- ============================================================


-- ─── STEP 1: CREATE THE MAIN TABLE ──────────────────────────────────────────
-- Column names are assigned business-readable labels mapped
-- to each of the 20 attributes in the UCI dataset documentation.

CREATE TABLE german_credit (
    checking_account      VARCHAR(10),   -- Status of existing checking account
    duration_months       INT,           -- Loan duration in months
    credit_history        VARCHAR(10),   -- Past repayment behavior
    purpose               VARCHAR(10),   -- Purpose of the loan
    credit_amount         INT,           -- Loan amount (in DM)
    savings_account       VARCHAR(10),   -- Savings account / bonds balance
    employment_since      VARCHAR(10),   -- Present employment duration
    installment_rate      INT,           -- Installment rate as % of disposable income
    personal_status_sex   VARCHAR(10),   -- Personal status and sex
    other_debtors         VARCHAR(10),   -- Other debtors / guarantors
    residence_since       INT,           -- Present residence duration (years)
    property              VARCHAR(10),   -- Borrower property type
    age_years             INT,           -- Age of borrower in years
    other_installments    VARCHAR(10),   -- Other installment plans
    housing               VARCHAR(10),   -- Housing status
    num_existing_credits  INT,           -- Number of existing credits at this bank
    job                   VARCHAR(10),   -- Job type / skill level
    num_dependents        INT,           -- Number of dependents
    telephone             VARCHAR(10),   -- Telephone registered under customer name
    foreign_worker        VARCHAR(10),   -- Foreign worker status
    credit_risk           INT            -- Original target: 1 = Good, 2 = Bad
);


-- ─── STEP 2: PRESERVE A BACKUP OF THE RAW DATA ──────────────────────────────
-- Backup table maintains the original import for reproducibility.
-- All cleaning and transformation is applied to the working table only.

CREATE TABLE german_credit_raw AS
SELECT * FROM german_credit;


-- ─── STEP 3: RECORD COUNT VERIFICATION ──────────────────────────────────────
-- Confirms that all 1,000 records were imported without loss or duplication.

SELECT COUNT(*) AS total_records
FROM german_credit;
-- Expected result: 1000


-- ─── STEP 4: MISSING VALUE CHECK ─────────────────────────────────────────────
-- Checks every column for NULL values across the full dataset.
-- The German Credit Dataset is complete by design — no imputation expected.

SELECT
    COUNT(*) - COUNT(checking_account)     AS checking_account_nulls,
    COUNT(*) - COUNT(duration_months)      AS duration_months_nulls,
    COUNT(*) - COUNT(credit_history)       AS credit_history_nulls,
    COUNT(*) - COUNT(purpose)              AS purpose_nulls,
    COUNT(*) - COUNT(credit_amount)        AS credit_amount_nulls,
    COUNT(*) - COUNT(savings_account)      AS savings_account_nulls,
    COUNT(*) - COUNT(employment_since)     AS employment_since_nulls,
    COUNT(*) - COUNT(installment_rate)     AS installment_rate_nulls,
    COUNT(*) - COUNT(personal_status_sex)  AS personal_status_sex_nulls,
    COUNT(*) - COUNT(other_debtors)        AS other_debtors_nulls,
    COUNT(*) - COUNT(residence_since)      AS residence_since_nulls,
    COUNT(*) - COUNT(property)             AS property_nulls,
    COUNT(*) - COUNT(age_years)            AS age_years_nulls,
    COUNT(*) - COUNT(other_installments)   AS other_installments_nulls,
    COUNT(*) - COUNT(housing)              AS housing_nulls,
    COUNT(*) - COUNT(num_existing_credits) AS num_existing_credits_nulls,
    COUNT(*) - COUNT(job)                  AS job_nulls,
    COUNT(*) - COUNT(num_dependents)       AS num_dependents_nulls,
    COUNT(*) - COUNT(telephone)            AS telephone_nulls,
    COUNT(*) - COUNT(foreign_worker)       AS foreign_worker_nulls,
    COUNT(*) - COUNT(credit_risk)          AS credit_risk_nulls
FROM german_credit;
-- Expected result: 0 across all columns


-- ─── STEP 5: DUPLICATE RECORD CHECK ─────────────────────────────────────────
-- Checks for exact row-level duplicates across all 20 columns.
-- Each record should represent a unique loan applicant.

SELECT
    checking_account, duration_months, credit_history, purpose,
    credit_amount, savings_account, employment_since, installment_rate,
    personal_status_sex, other_debtors, residence_since, property,
    age_years, other_installments, housing, num_existing_credits,
    job, num_dependents, telephone, foreign_worker,
    COUNT(*) AS occurrences
FROM german_credit
GROUP BY
    checking_account, duration_months, credit_history, purpose,
    credit_amount, savings_account, employment_since, installment_rate,
    personal_status_sex, other_debtors, residence_since, property,
    age_years, other_installments, housing, num_existing_credits,
    job, num_dependents, telephone, foreign_worker
HAVING COUNT(*) > 1;
-- Expected result: 0 rows (no duplicates)


-- ─── STEP 6: NUMERIC RANGE VALIDATION ───────────────────────────────────────
-- Validates that continuous variables fall within realistic bounds.
-- Negative or implausible values would indicate import or data quality issues.

SELECT
    MIN(duration_months)  AS min_duration,
    MAX(duration_months)  AS max_duration,
    MIN(credit_amount)    AS min_credit_amount,
    MAX(credit_amount)    AS max_credit_amount,
    MIN(age_years)        AS min_age,
    MAX(age_years)        AS max_age,
    MIN(installment_rate) AS min_installment_rate,
    MAX(installment_rate) AS max_installment_rate
FROM german_credit;


-- ─── STEP 7: TARGET VARIABLE TRANSFORMATION ─────────────────────────────────
-- The original encoding (1 = Good, 2 = Bad) is counterintuitive for
-- standard credit risk modeling. A new binary variable (default_flag)
-- is derived to align with industry convention:
--   0 = Good borrower (no default)
--   1 = Bad borrower (default)
-- This ensures that model outputs represent the probability of default
-- directly, with no ambiguity in encoding direction.

ALTER TABLE german_credit
ADD COLUMN default_flag INT;

UPDATE german_credit
SET default_flag = CASE
    WHEN credit_risk = 1 THEN 0  -- Good borrower → no default
    WHEN credit_risk = 2 THEN 1  -- Bad borrower  → default
END;


-- ─── STEP 8: VERIFY TARGET VARIABLE TRANSFORMATION ──────────────────────────
-- Confirms the transformation produced the expected 700 / 300 split.

SELECT
    default_flag,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM german_credit
GROUP BY default_flag
ORDER BY default_flag;
-- Expected: 0 → 700 (70%), 1 → 300 (30%)
