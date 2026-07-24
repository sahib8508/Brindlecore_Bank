CREATE OR REPLACE VIEW customer_master_cleaned AS

SELECT 
customer_id,
INITCAP(full_name) AS full_name,
	(CASE 
	WHEN UPPER(TRIM(gender)) IN ('M','MALE') THEN 'Male'
	WHEN UPPER(TRIM(gender)) IN ('F','FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gender)) IN ('OTHER','O') THEN 'Other'
	ELSE NULL
	END
) AS gender,
	(CASE 
	WHEN date_of_birth ~ '^\d{2}-[A-Za-z]{3}-\d{4}$' THEN TO_DATE(date_of_birth, 'DD-Mon-YYYY')
	WHEN date_of_birth ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(date_of_birth ,'MM-DD-YYYY')
	WHEN date_of_birth ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(date_of_birth ,'DD/MM/YYYY')
	WHEN date_of_birth ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(date_of_birth ,'YYYY-MM-DD')
	ELSE NULL
	END
) AS date_of_birth,
	(CASE 
	WHEN UPPER(TRIM(marital_status)) IN ('MARRIED') THEN 'Married'
	WHEN UPPER(TRIM(marital_status)) IN ('SINGLE') THEN 'Single'
	WHEN UPPER(TRIM(marital_status)) IN ('DIVORCED') THEN 'Divorced'
	WHEN UPPER(TRIM(marital_status)) IN ('WIDOWED') THEN 'Widowed'
	ELSE NULL
	END
) AS marital_status,
	(CASE 
	WHEN UPPER(TRIM(education)) IN ('GRADUATE') THEN 'Graduate'
	WHEN UPPER(TRIM(education)) IN ('UNDERGRADUATE') THEN 'Under Graduate'
	WHEN UPPER(TRIM(education)) IN ('DOCTORATE') THEN 'Doctorate'
	WHEN UPPER(TRIM(education)) IN ('HIGH SCHOOL') THEN 'High School'
	WHEN UPPER(TRIM(education)) IN ('POST GRADUATE') THEN 'Post Graduate'
	WHEN UPPER(TRIM(education)) IN ('SOME COLLEGE','UNKNOWN') THEN 'Others'
	ELSE NULL
	END
) AS education,
	(CASE 
	WHEN UPPER(TRIM(employment_type)) IN ('UNEMPLOYED') THEN 'Unemployed'
	WHEN UPPER(TRIM(employment_type)) IN ('SELF EMPLOYED','SELF-EMPLOYED') THEN 'Self-Employed'
	WHEN UPPER(TRIM(employment_type)) IN ('SALARIED') THEN 'Salaried'
	WHEN UPPER(TRIM(employment_type)) IN ('RETIRED') THEN 'Retired'
	WHEN UPPER(TRIM(employment_type)) IN ('BUSINESS OWNER') THEN 'Business Owner'
	WHEN UPPER(TRIM(employment_type)) IN ('N/A') THEN NULL
	ELSE NULL
	END
) AS employment_type,
	(CASE 
	WHEN CAST(REGEXP_REPLACE(annual_income, '[$,]', '', 'g') AS NUMERIC(20,2)) > 0 
	AND CAST(REGEXP_REPLACE(annual_income, '[$,]', '', 'g') AS NUMERIC(20,2)) < 10000000
	THEN CAST(REGEXP_REPLACE(annual_income, '[$,]', '', 'g') AS NUMERIC(20,2))
	ELSE NULL
	END
	) AS annual_income,
	
onboarding_branch_code,

	TRIM(INITCAP(city)) AS city,
	(CASE 
	WHEN kyc_status IS NULL THEN 'Not Recorded'
	ELSE TRIM(INITCAP(kyc_status))
	END
) AS kyc_status,
	(CASE 
	WHEN email IS NOT NULL THEN TRIM(lower(email))
	WHEN email IS NULL THEN 'No email entered'
	END
) AS email,
	(CASE 
	WHEN phone IS NULL OR TRIM(phone) = 'N/A' THEN 'No phone entered'
	WHEN phone IS NOT NULL AND regexp_replace()
	END
) AS phone,
	(CASE 
	WHEN onboarding_date ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(onboarding_date ,'MM-DD-YYYY')
	WHEN onboarding_date ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(onboarding_date ,'DD/MM/YYYY')
	WHEN onboarding_date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(onboarding_date ,'YYYY-MM-DD')
	ELSE NULL
	END
) AS onboarding_date,
	(CASE 
	WHEN ROUND(CAST(credit_bureau_score AS numeric),0) IS NOT NULL AND ROUND(CAST(credit_bureau_score AS numeric),0) > 0 THEN ROUND(CAST(credit_bureau_score AS numeric),0)
	ELSE NULL
	END 
) AS credit_bureau_score


FROM customer_master











