-- ============================================================
-- PROJECT: Credit Default Risk Modeling — German Credit Data
-- FILE:    03_eda_multi_variable.sql
-- AUTHOR:  Favour Chegwe
-- PURPOSE: Multi-variable cross-analysis to identify compound
--          risk profiles — the borrower combinations that
--          single-variable analysis leaves invisible.
--
-- Core principle: Risk compounds multiplicatively, not additively.
-- A borrower with two weak signals is a fundamentally different
-- underwriting problem from a borrower with one.
-- ============================================================


-- ─── ANALYSIS 1: CREDIT HISTORY × SAVINGS ACCOUNT ───────────────────────────
-- Tests whether weak credit history compounded by low financial reserves
-- produces default rates significantly above either factor alone.
--
-- Key finding: Thin-file borrowers with very low savings (A31×A61, A30×A61)
-- default at 72% and 70% respectively — more than double the 30% baseline.
-- Risk-reducing combination: A34×A64 defaults at just 5.0%.

SELECT
    credit_history,
    savings_account,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY credit_history, savings_account
ORDER BY default_rate DESC;


-- ─── ANALYSIS 2: EMPLOYMENT STABILITY × LOAN DURATION ───────────────────────
-- Evaluates whether loan tenor amplifies the risk associated with
-- unstable or recent employment — and whether stability can offset tenor risk.
--
-- Key finding: Borrowers employed >=7 years (most stable) still default at
-- 55.6% on long-term loans. Loan tenor is an independent risk amplifier
-- that cannot be offset by employment history alone.

SELECT
    employment_since,
    CASE
        WHEN duration_months <= 12 THEN 'Short'
        WHEN duration_months <= 36 THEN 'Medium'
        ELSE 'Long'
    END AS duration_group,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY employment_since, duration_group
ORDER BY default_rate DESC;


-- ─── ANALYSIS 3: SAVINGS ACCOUNT × LOAN AMOUNT ──────────────────────────────
-- Examines whether borrowers taking large loans without adequate savings
-- represent the portfolio's highest affordability risk.
--
-- Key finding: Very low savings + high loan amount (A61×High) defaults at 51.4%.
-- Strong savings + high loan amount (A64×High) defaults at just 20.0%.
-- A 31-percentage-point spread driven entirely by financial buffer capacity.

SELECT
    savings_account,
    CASE
        WHEN credit_amount < 2000 THEN 'Low'
        WHEN credit_amount < 5000 THEN 'Medium'
        ELSE 'High'
    END AS amount_grouped,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY savings_account, amount_grouped
ORDER BY default_rate DESC;


-- ─── ANALYSIS 4: CREDIT HISTORY × LOAN DURATION ─────────────────────────────
-- Tests whether thin-file borrowers become significantly more dangerous
-- when paired with longer loan tenors — and whether good credit history
-- provides protection against duration risk.
--
-- Key finding: Thin-file borrowers (A30, A31) carry high default rates
-- across ALL duration bands — risk is not mitigated by shorter tenors.
-- A34×Short is the lowest-risk combination in the portfolio at 8.7%.

SELECT
    credit_history,
    CASE
        WHEN duration_months <= 12 THEN 'Short'
        WHEN duration_months <= 36 THEN 'Medium'
        ELSE 'Long'
    END AS duration_group,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY credit_history, duration_group
ORDER BY default_rate DESC;


-- ─── CONSOLIDATED: HIGH-RISK PROFILE SUMMARY ─────────────────────────────────
-- Surfaces the five highest-default combinations across all four analyses
-- for quick reference in reporting and portfolio review contexts.

SELECT
    'Credit History x Savings' AS analysis,
    'A31 (Bank credits paid duly) x A61 (Very low savings)' AS combination,
    72.00 AS default_rate_pct
UNION ALL
SELECT
    'Credit History x Savings',
    'A30 (No prior credit) x A61 (Very low savings)',
    70.00
UNION ALL
SELECT
    'Employment x Loan Duration',
    'A72 (Employed <1 year) x Long (>36 months)',
    66.67
UNION ALL
SELECT
    'Credit History x Loan Duration',
    'A30 (No prior credit) x Medium (13-36 months)',
    65.00
UNION ALL
SELECT
    'Employment x Loan Duration',
    'A73 (Employed 1-3 years) x Long (>36 months)',
    61.54
ORDER BY default_rate_pct DESC;
