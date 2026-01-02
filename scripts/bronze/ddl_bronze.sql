/*
DDL Script: Create Bronze Tables
===========================================================
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
===========================================================
*/

--Creating Bronze layer tables (as-is from Source table)
use DataWarehouse;

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP Table bronze.crm_cust_info;
Create table bronze.crm_cust_info(
	cst_id int,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATETIME
);

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	 DROP Table bronze.crm_prd_info;
Create table bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP table bronze.crm_sales_details;
create table bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_keyn NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT

);

IF OBJECT_ID('bronze.erp_CUST_AZ12', 'U') IS NOT NULL
	DROP table bronze.erp_CUST_AZ12;
create table bronze.erp_CUST_AZ12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(10)
);

IF OBJECT_ID('bronze.erp_LOC_A101', 'U') IS NOT NULL
	DROP Table bronze.erp_LOC_A101;
create table bronze.erp_LOC_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(20)
);

IF OBJECT_ID('bronze.erp_PX_CAT_G1V2', 'U') IS NOT NULL
	DROP table bronze.erp_PX_CAT_G1V2;
create table bronze.erp_PX_CAT_G1V2(
	ID NVARCHAR(20),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(30),
	MAINTENANCE NVARCHAR(10)
);

