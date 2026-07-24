CREATE OR REPLACE VIEW branch_master_cleaned AS
SELECT 
    branch_code,
    branch_name,
    region,
    CAST(branch_opened_year AS INTEGER) AS branch_opened_year,
	(CASE 
	WHEN branch_tier IS NULL THEN 'Unknown Tier'
	ELSE branch_tier
	END) as branch_tier
   
FROM branch_master --- created view to clean branch_master file

