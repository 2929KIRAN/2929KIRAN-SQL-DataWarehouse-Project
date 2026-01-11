/* 
========================================================================
DDL Script: Create Gold Views
========================================================================
Script Purpose:
This script creates views for the Gold layer in the data warehouse.
The Gold layer represents the final dimension and fact tables (Star Schema)
Each view performs transformations and combines data from the Silver layer to produce a clean, enriched, and business-ready dataset.
Usage:
These views can be queried directly for analytics and reporting.
========================================================================
*/

-- ======================================================
-- Create Dimension: gold.dim_customers
-- ======================================================

IF OBJECT_ID('gold.dim_customers', 'V') is NOT NULL
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
 select 
		ROW_NUMBER() over (order by cst_id) AS customer_key,-- Manually/ system generated Surrogate key to uniquely identifiy the table 
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.CNTRY AS country,
		ci.cst_marital_status AS marital_status,
		case when ci.cst_gndr !='n/a' then ci.cst_gndr
		     else coalesce(ca.GEN, 'n/a')
		END AS gender,
		ca.BDATE AS birthdate,
		ci.cst_create_date AS create_date
from silver.crm_cust_info ci
left join silver.erp_CUST_AZ12 ca
on ci.cst_key = ca.CID
left join silver.erp_LOC_A101 la
on ci.cst_key= la.CID;

-- ======================================================
-- Create Dimension: gold.dim_product
-- ======================================================
IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
	DROP VIEW gold.dim_product;
GO
CREATE ViEW gold.dim_product AS
select 
		ROW_NUMBER() over (order by pn.prd_start_dt, pn.prd_key) AS product_key, --Surrogate key
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.cat_id AS category_id,
		pc.CAT as category,
		pc.SUBCAT as subcategory,
		pc.MAINTENANCE AS maintainance,
		pn.prd_line AS product_line,
		pn.prd_cost AS product_cost,
		pn.prd_start_dt AS product_start_date
from silver.crm_prd_info pn
left join silver.erp_PX_CAT_G1V2 pc
on pn.cat_id=pc.ID
where pn.prd_end_dt is NULL;

-- ======================================================
-- Create Dimension: gold.fact_sales
-- ======================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
Create view gold.fact_sales AS
select 
	sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price price
from silver.crm_sales_details sd
left join gold.dim_product pr
on sd.sls_prd_key= pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id= cu.customer_id;
