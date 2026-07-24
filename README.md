# Brindlecore Financial Bank — Credit Risk & Fraud Reconciliation Project
**Status: In Progress — SQL Cleaning Phase**
**Last updated:** July 2026

---

## 1. Business Problem

Brindlecore Financial Bank acquired a smaller community bank about 18 months ago. Since then, Risk's numbers, Fraud's numbers, and Finance's numbers haven't been matching up for the same customers. IT says the systems are integrated, but nobody has actually checked. Before anything goes to the board, leadership wants to know: can we trust our current reporting, and once we can, where is the bank's real risk actually sitting?

---

## 2. Underlying Questions (20)

### Part 1 — Can we trust the data?
1. How many loans point to customers that don't exist in the customer records, and how much loan money is tied up in those records?
2. How many customers are duplicated in the system, and how much does that distort our customer-level counts?
3. Do transaction dates match between the core banking system and the fraud monitoring system, and if not, when does the mismatch tend to happen?
4. Are there customers in the transaction system with no matching loan record — who are they?
5. If we compare the risk numbers before and after fixing these issues, how different is the picture leadership would actually see?

### Part 2 — Where is the real credit risk?
6. Does loan grade actually predict how overdue a loan becomes?
7. Which employment type has the highest rate of bad loans, and how much worse is it than the safest group?
8. Does credit bureau score actually predict loan default?
9. Which loan purpose carries the most risk?
10. Do some loan officers have consistently worse-performing portfolios than others, even after accounting for the type of customers they serve?
11. Which regions or branches carry the highest concentration of bad loans?
12. Out of all currently overdue/bad loans, how much total money is actually at risk right now?

### Part 3 — Where is the real fraud risk?
13. Is fraud more common in large transactions?
14. Is fraud more common at night?
15. Do customers with incomplete KYC show higher fraud rates?
16. Are there customers making multiple transactions in a suspiciously short window of time?
17. Do customers who are already high credit-risk also show higher fraud activity, or are the two unrelated?

### Part 4 — Bringing it together for leadership
18. Which regions or branches have the worst combined credit risk AND fraud exposure together?
19. Has the fraud rate been getting better or worse recently?
20. Combining everything — bad loans, confirmed fraud, and the data-trust issues — what's the bank's realistic total exposure right now, and what should leadership be told?

---

## 3. Dataset Overview

Synthetic data, custom-built for this project (not sourced from Kaggle or any public dataset — see Data Sourcing Note below). Designed to mirror how a real bank's systems are actually split, with deliberate cross-system inconsistencies simulating a post-merger data fragmentation scenario.

| Table | Rows | Purpose |
|---|---|---|
| `customer_master` | 142,940 | Onboarding/KYC system — customer demographics, income, credit score |
| `loan_servicing` | 190,000 | Loan system — grade, amount, DPD, status, officer, branch |
| `transaction_log` | 1,050,000 | Fraud monitoring system — transactions, channel, fraud flag |
| `branch_master` | 85 | Branch reference table |
| `officer_master` | 340 | Loan officer reference table |

**Key linkage:** `customer_id` connects `customer_master` ↔ `loan_servicing` ↔ `transaction_log`. `branch_code` and `officer_id` connect `loan_servicing` ↔ `branch_master` ↔ `officer_master`.

**Confirmed data quality issues (verified against the actual files):**
- 2,080 orphan loan records (customer_id not in customer_master) — 1.09% of loans
- 2,940 duplicate customer_id entries in customer_master
- 30,748 transactions (2.93%) with a date mismatch between `core_ledger_date` and `fraud_monitoring_system_date`, concentrated almost entirely in the 11 PM–1 AM window
- Branch code schema drift: pre-2023 branches use `BR####` format, post-2023 branches use `BX[N/S/E/W]###` format

**Data Sourcing Note:** Real, customer-level BFSI data cannot legally be obtained from any public source (GLBA in the US, DPDP Act in India, GDPR in the EU all restrict this). This dataset was generated to realistically simulate a post-merger data fragmentation scenario — a documented, real pattern in bank M&A — using Python (Faker + custom logic), with deliberately injected messiness (mixed date/number formats, nulls, duplicates, orphan keys) rather than a pre-cleaned public dataset.

---

## 4. Tools Used

- **PostgreSQL / pgAdmin** — data loading, profiling, cleaning, analysis
- **Excel** — validation of SQL results (planned)
- **Power BI** — final dashboard (planned)

---

## 5. Progress So Far

### Completed
- [x] Business problem and 20 underlying questions locked and verified against the dataset
- [x] All 5 raw CSVs loaded into PostgreSQL (`brindlecore` database) as TEXT-typed staging tables
- [x] Diagnostic queries run — orphan loans, duplicate customers, and date mismatches all confirmed and quantified (Q1, Q2, Q3 effectively answered)
- [x] `branch_master_cleaned` view built — type conversion (`branch_opened_year` to INTEGER) and null handling on `branch_tier`
- [x] `customer_master_cleaned` view built — full cleaning across all messy columns:
  - `gender`, `marital_status`, `education`, `employment_type` — casing/spelling standardized, explicit NULL handling
  - `date_of_birth`, `onboarding_date` — multi-format date parsing (4 formats: YYYY-MM-DD, DD/MM/YYYY, MM-DD-YYYY, DD-Mon-YYYY) using regex pattern matching + `TO_DATE`
  - `annual_income` — currency symbols/commas stripped, garbage values (negative, zero, absurd outliers) filtered
  - `credit_bureau_score` — garbage values filtered
  - `email`, `phone` — nulls/placeholders standardized to explicit labels, kept as TEXT (not used in numeric analysis)

### In Progress / Not Started
- [ ] `loan_servicing_cleaned` view
- [ ] `transaction_log_cleaned` view
- [ ] `officer_master_cleaned` view
- [ ] Shared logic views (e.g. "bad loan" flag definition used across multiple questions)
- [ ] SQL answers for Q4–Q20 (using clean views)
- [ ] Excel validation of 2–3 key SQL results
- [ ] Power BI data model (star schema) and dashboard
- [ ] Final findings, recommendations, and expected-impact write-up

---

## 6. Key Data Quality Decisions Made So Far

- **Raw tables are never modified.** All cleaning happens in views sitting on top of untouched raw data — this preserves an audit trail and matches how real read-only analyst access typically works.
- **NULL handling is per-column, not a blanket rule.** Columns used in core risk analysis (e.g. `employment_type`, `kyc_status`) keep NULLs as an explicit, visible category rather than being guessed/imputed — since 20.1% of `employment_type` is missing and it's central to Q7, imputing would fabricate a false pattern in the project's most important finding.
- **Regex-based multi-format date parsing** was used instead of assuming one format, since the raw data intentionally mixes 4 different date formats per column.
- **`customer_master_cleaned` built as a standard view (not yet materialized)** — being considered for conversion to a materialized view given `transaction_log`'s size (1M+ rows), to avoid re-running cleaning logic on every query during the Power BI/Excel phase.

---

## 7. Known Limitations

- This is a synthetic dataset, deliberately designed to simulate realistic bank data-quality issues — not real customer data (real BFSI customer-level data cannot legally be public).
- `employment_type` is missing for ~20% of customers; any finding based on this field is scoped to the subset where it's recorded, not the full customer base.
- Date-format assumptions (e.g. treating all `\d{2}-\d{2}-\d{4}` shaped dates as MM-DD-YYYY) rely on knowing the data generation rule — in a genuinely real dataset, this same shape could be ambiguous and would need verification against the source system before trusting a blanket parsing rule.

---

*This README will be updated as the SQL, Excel, and Power BI phases progress. Final version will include actual findings, screenshots, and recommendations.*
