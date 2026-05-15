/*
===================================================================================================
Quality Checks
===================================================================================================
Script Purpose:
    This script performs various quality checks fro data consistency, accuracy, and standardization
    across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===================================================================================================
*/
--=========================================================================
  -- >> Checking data: silver.crm_cust_info
--=========================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expection: No Result
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces
-- Expection: No result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

--=========================================================================
  -- >> Checking data: silver.crm_prd_info
--=========================================================================
-- Duplicates & NULL
-- Expection: No Result
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--=========================================================================
  -- >> Checking data: silver.crm_sales_details
--=========================================================================
-- Check for unwanted spaces
-- Expectation: No Results
SELECT
       sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check prd key
-- Expectation: No Results
SELECT
sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

-- Check cust_id
-- Expectation: No Results
SELECT
sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Check for INVALID Dates  -- An Integer
SELECT
NULLIF(sls_order_dt,0) -- Returns NULL if the condition is met
FROM silver.crm_sales_details
WHERE 
sls_order_dt < = 0 OR
LEN(sls_order_dt) != 8 OR
sls_order_dt < 19000101 OR sls_order_dt > 20500101 -- Check for outliers by validating the bounaries of the date range

SELECT
NULLIF(sls_ship_dt,0) -- Returns NULL if the condition is met
FROM silver.crm_sales_details
WHERE 
sls_ship_dt < = 0 OR
LEN(sls_ship_dt) != 8 OR
sls_ship_dt < 19000101 OR sls_ship_dt > 20500101 -- Check for outliers by validating the bounaries of the date range

SELECT
NULLIF(sls_due_dt,0) -- Returns NULL if the condition is met
FROM silver.crm_sales_details
WHERE 
sls_due_dt < = 0 OR
LEN(sls_due_dt) != 8 OR
sls_due_dt < 19000101 OR sls_due_dt > 20500101 -- Check for outliers by validating the bounaries of the date range

SELECT * 
FROM silver.crm_sales_details
WHERE sls_ship_dt < sls_order_dt -- Checking if order date is later than the shipping date

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sum of Sales = Quantity * Price
-- >> None of the three columns should be -ve, 0 or NULL

SELECT DISTINCT
	   sls_sales AS old_sls_sales
      ,sls_quantity
      ,sls_price AS old_sls_price

	  ,CASE WHEN sls_sales IS NULL OR sls_sales < = 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
		    ELSE sls_sales
	   END AS sls_sales

	   ,CASE WHEN sls_price IS NULL OR sls_price = 0 THEN sls_sales / NULLIF(sls_quantity,0)
			 WHEN sls_price < 0 THEN ABS(sls_price)
		     ELSE sls_price
		END AS sls_price

FROM silver.crm_sales_details 
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales < = 0 OR sls_quantity < 0 OR sls_price < 0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

--=========================================================================
  -- >> Checking data: silver.erp_cust_az12
--=========================================================================

-- Checking on the primary key
SELECT
cid, -- Had 'NAS' for some entries as prefix which is not there in crm_cust_info, need to be removed
bdate,
gen
FROM silver.erp_cust_az12

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4, LEN(TRIM(cid)))
     ELSE cid
	 END AS cid
FROM silver.erp_cust_az12 
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4, LEN(TRIM(cid)))
     ELSE cid
END NOT IN(
SELECT cst_key
FROM silver.crm_cust_info)

-- Identify our-of-range dates

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE  bdate > GETDATE()

-- Data Standardization & Consistency

SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM silver.erp_cust_az12

SELECT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'n/a'
END AS gen,
COUNT(cid)
FROM silver.erp_cust_az12
GROUP BY gen

--=========================================================================
  -- >> Checking data: silver.erp_loc_a101
--=========================================================================
SELECT cid,
REPLACE(cid, '-', '')
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT cid,
REPLACE(cid, '-', '')
FROM silver.erp_loc_a101

SELECT cst_key FROM silver.crm_cust_info

-- Data Standardization and consistance ( Low Cardinality Column)

select distinct cntry,
CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Gernany'
	 WHEN UPPER(TRIM(cntry)) = 'GERMANY' THEN 'Gernany'
	 WHEN UPPER(TRIM(cntry)) IN ('USA', 'US', 'UNITED STATES') THEN 'United States'
	 WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'Australia'
	 WHEN UPPER(TRIM(cntry)) = 'UNITED KINGDOM' THEN 'United Kingdom'
	 WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'Canada'
	 WHEN UPPER(TRIM(cntry)) = 'FRANCE' THEN 'France'
	 ELSE 'n/a'
END AS cntry
FROM silver.erp_loc_a101

--=========================================================================
  -- >> Checking data: silver.erp_px_cat_g1v2
--=========================================================================
-- Checking for unwanted space
SELECT
cat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
select distinct cat, subcat, maintenance
FROM silver.erp_px_cat_g1v2
