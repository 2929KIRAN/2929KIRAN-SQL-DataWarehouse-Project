--Creating Silver layer tables (as-is from Bronze layer but adding Metadata columns for more visibility)
use DataWarehouse;

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
	DROP Table silver.crm_cust_info;
Create table silver.crm_cust_info(
	cst_id int,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATETIME,
	dwh_create_date DATETIME2  DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
	 DROP Table silver.crm_prd_info;
Create table silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
	DROP table silver.crm_sales_details;
create table silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.erp_CUST_AZ12', 'U') IS NOT NULL
	DROP table silver.erp_CUST_AZ12;
create table silver.erp_CUST_AZ12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_LOC_A101', 'U') IS NOT NULL
	DROP Table silver.erp_LOC_A101;
create table silver.erp_LOC_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(20),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
	DROP table silver.erp_PX_CAT_G1V2;
create table silver.erp_PX_CAT_G1V2(
	ID NVARCHAR(20),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(30),
	MAINTENANCE NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


