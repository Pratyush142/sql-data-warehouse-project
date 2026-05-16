/*
======================================================================
Quality Checks
======================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
======================================================================
*/

--=====================================================================
--Checking 'gold.dim_customers'
--=====================================================================
-- Uniqueness
SELECT DISTINCT gender FROM gold.dim_customers

SELECT cst_id, COUNT(*) FROM
(SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid 
)t GROUP BY cst_id
HAVING COUNT(*) > 1

-- Data Intigration for Gender as it is comming from two sources
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
ORDER BY 1, 2 -- NULLs often come from joined tables! NULL will appear if SQL finds no match

/*
Since there are discrepency b/w two gender columns 
we need to check with business person, which is the master for these values?
The Master source of Customer Data is CRM! (for e.g.) and we prefer this data over erp data
*/

-- Data Ingegration, Implement the Business logic
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
ORDER BY 1, 2 

--=======================================================================
--Checking 'gold.dim_products'
--=======================================================================
-- Checking the Uniqueness of prd_key
SELECT prd_key, COUNT(*) FROM 
(SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON		  pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL 
)t GROUP BY prd_key
HAVING COUNT(*) > 1

-- Uniqueness
SELECT * FROM gold.dim_products

--=======================================================================
--Checking 'gold.fact_sales'
--=======================================================================
SELECT * FROM gold.fact_sales

-- Foreign Key Integrity ( Dimensions )
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL


