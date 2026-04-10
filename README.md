# Credit Default Risk Modeling Using German Credit Data

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Scikit-Learn](https://img.shields.io/badge/scikit--learn-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-2ea44f?style=for-the-badge)

---

## Business Problem

Credit default is one of the most financially consequential risks a lending institution faces. Every loan approved for a borrower who ultimately defaults represents not just a missed repayment — it represents provisioning costs, recovery efforts, capital erosion, and a deteriorating portfolio that attracts regulatory scrutiny.

This project builds a structured, data-driven credit risk framework using the German Credit Dataset — analyzing 1,000 loan applicants across 20 borrower and loan characteristics to identify the key drivers of default, profile the highest-risk borrower segments, and develop a cost-sensitive predictive model that supports better lending decisions.

> **Portfolio Baseline:** 30% of borrowers in this dataset defaulted.  
> **Project Goal:** Identify who they are — before the loan is approved.

---

## Project Objectives

- Quantify default risk across key borrower segments using SQL-based exploratory analysis
- Identify which individual and combined borrower characteristics most strongly predict default
- Build a Logistic Regression classifier to estimate the probability of default per borrower
- Apply a cost-sensitive evaluation framework that reflects the true financial asymmetry of lending errors
- Translate all analytical findings into actionable credit policy recommendations

---

## Dataset Overview

| Attribute | Detail |
|---|---|
| **Source** | UCI Machine Learning Repository |
| **Original Compiler** | Prof. Hans Hofmann, University of Hamburg |
| **Records** | 1,000 loan applicants |
| **Features** | 20 (13 categorical, 7 numerical) |
| **Target Variable** | Credit risk — Good (0) / Default (1) |
| **Baseline Default Rate** | 30% |
| **Tools Used** | PostgreSQL, Python, Scikit-learn, Pandas |

### Risk Dimensions Covered

| Risk Dimension | Variables |
|---|---|
| **Credit Behavior** | Credit history, existing loans |
| **Financial Strength** | Savings account balance, checking account status, property ownership |
| **Employment & Stability** | Employment duration, job classification |
| **Loan Characteristics** | Loan amount, loan duration, purpose, installment rate |
| **Borrower Profile** | Age, personal status, housing, foreign worker status |

---

## Analytical Workflow

```
Phase 1 → Data Cleaning & Preparation     (PostgreSQL)
Phase 2 → Exploratory Data Analysis       (PostgreSQL)
Phase 3 → Multi-Variable Risk Analysis    (PostgreSQL)
Phase 4 → Predictive Modeling             (Python / Scikit-learn)
```

### Phase 1 — Data Cleaning & Preparation

The raw dataset was imported into PostgreSQL and validated across four dimensions:

- **Record count** — confirmed 1,000 records, zero loss on import
- **Missing values** — none identified across all 20 columns
- **Duplicates** — none found; every record represents a unique applicant
- **Numeric ranges** — loan duration, credit amount, and age all validated within realistic bounds

A new binary target variable `default_flag` was derived (0 = Good, 1 = Default) to align with standard credit risk modeling convention. A backup table (`german_credit_raw`) was preserved for reproducibility.

---

### Phase 2 — Exploratory Data Analysis

SQL-based default rate analysis was conducted across six borrower and loan characteristics. All encoded categorical variables are translated into their business meaning throughout this project.

#### Portfolio Default Distribution

| Class | Count | Percentage |
|---|---|---|
| Good Borrower (0) | 700 | 70% |
| Defaulter (1) | 300 | 30% |

#### Credit History Analysis

> *Variable mapping: A30 = no prior credit; A31 = all bank credits paid duly; A32 = existing credits paid duly; A33 = past repayment delays; A34 = critical account / credits at other institutions*

| Credit History | Total | Defaults | Default Rate |
|---|---|---|---|
| A30 — No prior credit | 40 | 25 | **62.50%** |
| A31 — All bank credits paid duly | 49 | 28 | **57.14%** |
| A32 — Existing credits paid duly | 530 | 169 | 31.89% |
| A33 — Past repayment delays | 88 | 28 | 31.82% |
| A34 — Critical account / external credits | 293 | 50 | 17.06% |

**Key Insight:** Thin-file borrowers — those with no prior credit or credits only at a single institution — default at more than double the portfolio average. The apparent "clean" history reflects insufficient data, not demonstrated repayment discipline. This is a classic manifestation of the **thin-file problem** in credit risk.

---

#### Savings Account Analysis

> *Variable mapping: A61 = <100 DM (very low); A62 = 100–499 DM (low); A63 = 500–999 DM (moderate); A64 = ≥1,000 DM (strong); A65 = unknown / no account*

| Savings Account | Total | Defaults | Default Rate |
|---|---|---|---|
| A61 — Very low savings (<100 DM) | 603 | 217 | **35.99%** |
| A62 — Low savings (100–499 DM) | 103 | 34 | 33.01% |
| A65 — No savings account / unknown | 183 | 32 | 17.49% |
| A63 — Moderate savings (500–999 DM) | 63 | 11 | 17.46% |
| A64 — Strong savings (≥1,000 DM) | 48 | 6 | **12.50%** |

---

#### Employment Stability Analysis

> *Variable mapping: A71 = unemployed; A72 = <1 year; A73 = 1–3 years; A74 = 4–6 years; A75 = ≥7 years*

| Employment Status | Total | Defaults | Default Rate |
|---|---|---|---|
| A72 — Employed < 1 year | 172 | 70 | **40.70%** |
| A71 — Unemployed | 62 | 23 | 37.10% |
| A73 — Employed 1–3 years | 339 | 104 | 30.68% |
| A75 — Employed ≥ 7 years | 253 | 64 | 25.30% |
| A74 — Employed 4–6 years | 174 | 39 | **22.41%** |

**Key Insight:** Newly employed borrowers (< 1 year) default at a higher rate than even unemployed borrowers — recent employment does not equate to income security.

---

#### Loan Duration Analysis

| Loan Duration | Total | Defaults | Default Rate |
|---|---|---|---|
| Long (> 36 months) | 87 | 45 | **51.72%** |
| Medium (13–36 months) | 554 | 179 | 32.31% |
| Short (≤ 12 months) | 359 | 76 | **21.17%** |

---

#### Loan Amount Analysis

| Loan Amount | Total | Defaults | Default Rate |
|---|---|---|---|
| High (≥ 5,000 DM) | 188 | 78 | **41.49%** |
| Low (< 2,000 DM) | 432 | 121 | 28.01% |
| Medium (2,000–4,999 DM) | 380 | 101 | 26.58% |

---

### Phase 3 — Multi-Variable Risk Analysis

Four cross-variable analyses were conducted to surface compound risk profiles invisible to single-variable analysis.

#### Credit History × Savings Account

| Credit History | Savings Account | Total | Defaults | Default Rate |
|---|---|---|---|---|
| A31 — Bank credits paid duly | A61 — Very low savings | 25 | 18 | **72.00%** |
| A30 — No prior credit | A61 — Very low savings | 30 | 21 | **70.00%** |
| A31 — Bank credits paid duly | A62 — Low savings | 8 | 5 | 62.50% |
| A30 — No prior credit | A62 — Low savings | 5 | 3 | 60.00% |
| A32 — Existing credits paid duly | A61 — Very low savings | 318 | 118 | 37.11% |
| A32 — Existing credits paid duly | A64 — Strong savings | 21 | 2 | 9.52% |
| A34 — Critical account | A64 — Strong savings | 20 | 1 | **5.00%** |

**Key Insight:** Thin-file borrowers with very low savings default at **70–72%** — more than double the portfolio baseline. Risk compounds multiplicatively, not additively.

---

#### Employment Stability × Loan Duration

| Employment Status | Loan Duration | Total | Defaults | Default Rate |
|---|---|---|---|---|
| A72 — Employed < 1 year | Long (> 36 months) | 9 | 6 | **66.67%** |
| A73 — Employed 1–3 years | Long (> 36 months) | 26 | 16 | 61.54% |
| A75 — Employed ≥ 7 years | Long (> 36 months) | 18 | 10 | **55.56%** |
| A71 — Unemployed | Medium (13–36 months) | 35 | 17 | 48.57% |
| A74 — Employed 4–6 years | Short (≤ 12 months) | 57 | 9 | **15.79%** |

**Key Insight:** Even the most stable employment segment (≥7 years) defaults at **55.6%** on long-term loans. Loan tenor is a risk amplifier that cannot be offset by employment stability alone.

---

#### Savings Account × Loan Amount

| Savings Account | Loan Amount | Total | Defaults | Default Rate |
|---|---|---|---|---|
| A61 — Very low savings | High (≥ 5,000 DM) | 105 | 54 | **51.43%** |
| A62 — Low savings | High (≥ 5,000 DM) | 20 | 9 | 45.00% |
| A61 — Very low savings | Medium (2,000–4,999 DM) | 229 | 79 | 34.50% |
| A64 — Strong savings | High (≥ 5,000 DM) | 5 | 1 | 20.00% |
| A64 — Strong savings | Medium (2,000–4,999 DM) | 15 | 1 | **6.67%** |

---

#### Credit History × Loan Duration

| Credit History | Loan Duration | Total | Defaults | Default Rate |
|---|---|---|---|---|
| A30 — No prior credit | Medium (13–36 months) | 20 | 13 | **65.00%** |
| A32 — Existing credits paid duly | Long (> 36 months) | 38 | 24 | 63.16% |
| A31 — Bank credits paid duly | Short (≤ 12 months) | 15 | 9 | 60.00% |
| A34 — Critical account | Medium (13–36 months) | 158 | 32 | 20.25% |
| A34 — Critical account | Short (≤ 12 months) | 115 | 10 | **8.70%** |

---

#### Consolidated High-Risk Borrower Profile

| Risk Dimension | High-Risk Profile |
|---|---|
| **Credit History** | No prior credit or credits only at one institution (A30, A31) |
| **Savings Capacity** | Very low savings below 100 DM (A61) |
| **Employment Status** | Newly employed, less than one year in current role (A72) |
| **Loan Duration** | Long-term commitment exceeding 36 months |
| **Loan Amount** | High-value loan at or above 5,000 DM |

---

### Phase 4 — Predictive Modeling

#### Model Selection

A **Logistic Regression** model was selected for its interpretability and direct alignment with the concept of **Probability of Default (PD)** — the foundational metric in credit risk assessment. Every coefficient carries a clear directional meaning, making the model explainable to both business stakeholders and regulators.

#### Data Preparation Steps

1. One-hot encoding of all categorical variables
2. Target variable (`default_flag`) separated from feature set
3. **Data leakage removed** — the original `credit_risk` encoding variable was identified and excluded
4. Train/test split: 80% training (800 records) / 20% test (200 records)
5. Feature scaling applied using `StandardScaler`

#### Initial Model Performance (Threshold = 0.5)

```
Confusion Matrix:
[[95  43]
 [20  42]]

Overall Accuracy: 68.5%
True Positives (Defaulters correctly caught): 42
False Negatives (Defaulters missed):          20  ← most costly error
False Positives (Good borrowers rejected):    43
```

#### Threshold Optimization — Cost-Based Evaluation

The dataset specifies an asymmetric cost structure:  
**Missed default (FN) = 5× the cost of a wrongly rejected good borrower (FP)**

> **Cost Formula: (FN × 5) + (FP × 1)**

| Threshold | False Negatives | False Positives | Total Cost |
|---|---|---|---|
| 0.5 | 20 | 43 | 143 |
| 0.4 | 18 | 50 | 140 |
| 0.3 | 17 | 59 | 144 |
| 0.2 | 15 | 72 | 147 |
| **0.1** | **9** | **84** | **129 ✓ Optimal** |

**At threshold 0.1:** Missed defaults reduced by **55%** (20 → 9), at a total cost of **129 vs 143** at the standard threshold.

#### Key Risk Drivers — Model Coefficients

**Top Risk-Increasing Features (Positive Coefficients)**

| Feature | Coefficient | Business Meaning |
|---|---|---|
| property_A124 | +0.748 | No property / unknown assets — no collateral buffer |
| other_debtors_A102 | +0.643 | Co-applicant — often signals underlying borrower weakness |
| num_existing_credits | +0.415 | Higher number of existing credits at this bank |
| num_dependents | +0.399 | More dependents — higher household financial obligations |
| credit_history_A31 | +0.383 | Credits only at this bank — thin external credit file |
| installment_rate | +0.343 | High repayment burden relative to disposable income |

**Top Risk-Reducing Features (Negative Coefficients)**

| Feature | Coefficient | Business Meaning |
|---|---|---|
| checking_account_A14 | -1.616 | No checking account at this bank |
| credit_history_A34 | -1.161 | Critical account / credits at other institutions |
| purpose_A41 | -1.125 | Loan for used car purchase |
| other_debtors_A103 | -0.998 | Loan backed by a guarantor — genuine credit enhancement |
| savings_account_A64 | -0.797 | Strong savings balance ≥ 1,000 DM |

**Notable finding:** Installment rate (+0.343) is the strongest numerical predictor of default — outperforming raw credit amount (+0.000086). Repayment burden relative to income is a more powerful default signal than loan size alone.

---

## Key Findings Summary

| Risk Factor | High-Risk Segment | Default Rate | Portfolio Baseline |
|---|---|---|---|
| Credit History | No prior credit — thin file (A30) | 62.50% | 30% |
| Loan Duration | Long-term > 36 months | 51.72% | 30% |
| Loan Amount | High value ≥ 5,000 DM | 41.49% | 30% |
| Employment | Employed < 1 year (A72) | 40.70% | 30% |
| Savings | Very low savings < 100 DM (A61) | 35.99% | 30% |
| **Compound: Thin-file + Low Savings** | **A31 × A61** | **72.00%** | **30%** |

---

## Business Recommendations

**1. Replace the Standard Threshold With a Cost-Calibrated Decision Boundary**  
Adopt a classification threshold between 0.1 and 0.4 based on the institution's risk appetite. At 0.1, missed defaults are reduced by 55%. The threshold is a business policy decision — not a technical default.

**2. Implement a Three-Tier Credit Decision Framework**  
- **Low Risk (PD < 20%)** → Streamlined approval, competitive pricing
- **Medium Risk (PD 20–50%)** → Conditional approval with mitigants (shorter tenor, guarantor, reduced amount)
- **High Risk (PD > 50%)** → Decline or full collateral + guarantor mandatory

**3. Apply Mandatory Compensating Factors for Thin-File Applicants**  
A30 and A31 borrowers require at least two compensating factors: verified savings above a defined minimum, a guarantor with credit history, collateral coverage ≥ 100% of loan value, or a maximum tenor of 12 months.

**4. Introduce Tenor-Based Risk Controls**  
Long-term loans (> 36 months) carry a 51.7% default rate — regardless of employment stability. Maximum tenor limits should be enforced by risk tier. All facilities exceeding 24 months should carry a tenor risk premium.

**5. Embed Installment Rate Ceilings Into Loan Sizing**  
Establish a maximum installment rate of 30–35% of verified disposable income as a hard underwriting constraint. Loan sizing should be determined by working backward from this ceiling, not by fitting repayments around a requested amount.

**6. Introduce Risk-Based Loan Pricing**  
Align interest rates and terms with predicted default probability. Higher-risk borrowers (particularly those with no collateral, confirmed by property_A124 coefficient of +0.748) should carry higher margins to offset expected losses.

**7. Establish Ongoing Model Monitoring**  
Track monthly: default rate among approved borrowers, false negative rate, and AUC/Gini coefficient. Trigger a formal model review if any metric deteriorates by more than 5 percentage points over a rolling 90-day window. Full recalibration annually.

---

## Repository Structure

```
credit-default-risk-german-data/
│
├── README.md                          ← Full project case study (this file)
│
├── data/
│   └── german.data                    ← Raw dataset (UCI ML Repository)
│
├── sql/
│   ├── 01_data_cleaning.sql           ← Import, validation, target variable transformation
│   ├── 02_eda_single_variable.sql     ← Default rate analysis across 6 variables
│   └── 03_eda_multi_variable.sql      ← Cross-variable compound risk analysis
│
├── notebooks/
│   └── credit_risk_modeling.ipynb     ← Python modeling: encoding, training, evaluation, threshold optimization
│
└── assets/
    └── images/                        ← SQL query result screenshots
```

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **PostgreSQL** | Data import, validation, cleaning, EDA, multi-variable analysis |
| **Python** | Feature engineering, model training, evaluation |
| **Pandas** | Data manipulation and preparation |
| **Scikit-learn** | Logistic Regression, train/test split, StandardScaler |
| **Matplotlib / Seaborn** | Visualization |
| **Jupyter Notebook** | Modeling workflow and documentation |

---

## About This Project

This project was built as part of a professional credit risk analytics portfolio, demonstrating an end-to-end analytical workflow from raw data to actionable business recommendations — using tools and frameworks aligned with real-world lending practice.

The analysis follows a structured methodology: data validation in PostgreSQL, SQL-driven exploratory analysis, multi-variable risk profiling, cost-sensitive predictive modeling in Python, and translation of findings into credit policy language.

---

## Author

**Favour Chegwe**  
Credit Risk & Financial Data Analyst  
Benin City, Nigeria

[![Portfolio](https://img.shields.io/badge/Portfolio-favouritefavil.github.io-1F3864?style=for-the-badge)](https://favouritefavil.github.io)
[![GitHub](https://img.shields.io/badge/GitHub-favouritefavil-181717?style=for-the-badge&logo=github)](https://github.com/favouritefavil)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/favouritefavil)

---

*Dataset Source: German Credit Dataset — UCI Machine Learning Repository. Original compiler: Prof. Hans Hofmann, University of Hamburg.*
