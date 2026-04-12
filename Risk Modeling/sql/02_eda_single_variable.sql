-- ============================================================
-- PROJECT: Credit Default Risk Modeling — German Credit Data
-- FILE:    02_eda_single_variable.sql
-- AUTHOR:  Favour Chegwe
-- PURPOSE: Single-variable default rate analysis across six
--          key borrower and loan characteristics.
--          Primary metric: default_rate (%) per segment.
-- ============================================================
-- Variable Reference (from UCI dataset documentation):
--
-- credit_history:   A30 = no prior credit / all paid back duly
--                   A31 = all bank credits paid duly
--                   A32 = existing credits paid duly
--                   A33 = past repayment delays
--                   A34 = critical account / credits at other banks
--
-- savings_account:  A61 = <100 DM (very low)
--                   A62 = 100–499 DM (low)
--                   A63 = 500–999 DM (moderate)
--                   A64 = >=1,000 DM (strong)
--                   A65 = unknown / no savings account
--
-- employment_since: A71 = unemployed
--                   A72 = <1 year
--                   A73 = 1–3 years
--                   A74 = 4–6 years
--                   A75 = >=7 years
-- ============================================================


-- ─── ANALYSIS 1: PORTFOLIO DEFAULT DISTRIBUTION ──────────────────────────────
-- Establishes the 30% baseline default rate used as the benchmark
-- for all subsequent segment-level comparisons.

SELECT
    default_flag,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM german_credit
GROUP BY default_flag
ORDER BY default_flag;


-- ─── ANALYSIS 2: CREDIT HISTORY ──────────────────────────────────────────────
-- Assesses whether past repayment behavior predicts future default risk.
-- Key finding: thin-file borrowers (A30, A31) carry the highest default rates,
-- exceeding even borrowers with past payment delays (A33).

SELECT
    credit_history,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY credit_history
ORDER BY default_rate DESC;


-- ─── ANALYSIS 3: SAVINGS ACCOUNT ─────────────────────────────────────────────
-- Evaluates savings balance as a proxy for financial buffer capacity.
-- Tests whether low savings correlates with higher default probability.

SELECT
    savings_account,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY savings_account
ORDER BY default_rate DESC;


-- ─── ANALYSIS 4: EMPLOYMENT STABILITY ────────────────────────────────────────
-- Assesses income stability and its relationship to repayment capacity.
-- Key finding: newly employed borrowers (<1 year) default at higher rates
-- than unemployed borrowers — recent employment is not a safety signal.

SELECT
    employment_since,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY employment_since
ORDER BY default_rate DESC;


-- ─── ANALYSIS 5: LOAN DURATION ───────────────────────────────────────────────
-- Groups loan duration into three bands to assess the relationship
-- between repayment horizon and default risk.
-- Key finding: long-term loans (>36 months) carry a 51.7% default rate —
-- nearly 22 percentage points above the portfolio baseline.

SELECT
    CASE
        WHEN duration_months <= 12 THEN 'Short (<=12)'
        WHEN duration_months <= 36 THEN 'Medium (13-36)'
        ELSE 'Long (>36)'
    END AS duration_group,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY duration_group
ORDER BY default_rate DESC;


-- ─── ANALYSIS 6: LOAN AMOUNT ─────────────────────────────────────────────────
-- Segments credit amounts into Low / Medium / High bands to evaluate
-- whether larger loan exposures carry proportionally higher default risk.
-- Key finding: high-value loans (>=5,000 DM) default at 41.5% vs
-- 28% and 26.6% for low and medium bands respectively.

SELECT
    CASE
        WHEN credit_amount < 2000 THEN 'Low'
        WHEN credit_amount < 5000 THEN 'Medium'
        ELSE 'High'
    END AS amount_grouped,
    COUNT(*) AS total,
    SUM(default_flag) AS defaults,
    ROUND(SUM(default_flag) * 100.0 / COUNT(*), 2) AS default_rate
FROM german_credit
GROUP BY amount_grouped
ORDER BY default_rate DESC;


-- ─── SUMMARY: TOP DEFAULT RATE BY SEGMENT ────────────────────────────────────
-- Consolidated view of the highest-risk segment per variable,
-- ranked against the 30% portfolio baseline.

SELECT
    'Credit History'   AS risk_factor,
    'A30 — No prior credit (thin file)' AS high_risk_segment,
    62.50 AS default_rate_pct,
    30.00 AS portfolio_baseline_pct
UNION ALL
SELECT
    'Loan Duration',
    'Long-term > 36 months',
    51.72, 30.00
UNION ALL
SELECT
    'Loan Amount',
    'High value >= 5,000 DM',
    41.49, 30.00
UNION ALL
SELECT
    'Employment Stability',
    'Employed < 1 year (A72)',
    40.70, 30.00
UNION ALL
SELECT
    'Savings Account',
    'Very low savings < 100 DM (A61)',
    35.99, 30.00
ORDER BY default_rate_pct DESC;
