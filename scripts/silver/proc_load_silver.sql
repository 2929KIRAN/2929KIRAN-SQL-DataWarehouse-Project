/*
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===
Script Purpose:
==
===
This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
Truncates Silver tables.
I
Inserts transformed and cleansed data from Bronze into Silver tables.
Parameters:
None.
This stored procedure does not accept any parameters or return any values.
Usage Example:
EXEC Silver.load_silver;
*/

-- Cleaning and pushing bronze layer tables data into silver layer tables
use DataWarehouse;
EXEC silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	Declare @start_time Datetime, @end_time DATETIME , @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time= GETDATE();
	PRINT '------Loading Silver Layer--------';

	PRINT '----------------------------------';
	PRINT '---Loading CRM tables-------------';
	PRINT '----------------------------------';

	SET @start_time=GETDATE();
	PRINT '>>Truncating Table silver.crm_cust_info';
	TRUNCATE Table silver.crm_cust_info;
	PRINT ' Inserting data into : silver.crm_cust_info';
	insert into silver.crm_cust_info (
		 cst_id,
		 cst_key,
		 cst_firstname,
		 cst_lastname,
		 cst_marital_status,
		 cst_gndr,
		 cst_create_date
		 )
	select cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			case when UPPER(Trim(cst_marital_status))='S' then 'Single'
				 when UPPER(TRIM(cst_marital_status))='M' then 'Married'
				 else 'N/A'
			END cst_marital_status,
			case when upper(Trim(cst_gndr))= 'M' then 'Male'
				 when upper(Trim(cst_gndr))='F' then 'Female'
				 else 'N/A'
			END cst_gndr,
			cst_create_date
	from (
			select *,
				ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
				from bronze.crm_cust_info
				where cst_id is not null) t
				where flag_last=1;
	SET @end_time= GETDATE();
	PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) as varchar) + 'seconds' ;
	PRINT '-----------------'

	SET @start_time= GETDATE();
	PRINT '>>Truncating Table silver.crm_prd_info';
	TRUNCATE Table silver.crm_prd_info;
	PRINT ' Inserting data into : silver.crm_prd_info';
	Insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)

	select prd_id,
		   replace(SUBSTRING(prd_key,1,5), '-', '_') as cat_id,
		   SUBSTRING(prd_key, 7, len(prd_key)) as prd_key,
		   prd_nm,
		   ISNULL(prd_cost, 0) as prd_cost,
		   case upper(trim(prd_line)) 
				when 'R' Then 'Road'
				when 'M' Then 'Middle Mile'
				when 'S' Then 'Sea'
				when 'T' Then 'Train'
				else 'N/A'
			End as prd_line,
		  cast(prd_start_dt as DATE) as prd_start_dt,
		  cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) as DATE ) as prd_end_dt
	from bronze.crm_prd_info;
	Set @end_time=GETDATE();
	PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @end_time, @start_time) as Nvarchar) + 'seconds' ;


	SET @start_time= GETDATE();
	PRINT '>>Truncating Table silver.crm_sales_details';
	TRUNCATE Table silver.crm_sales_details;
	PRINT ' Inserting data into : silver.crm_sales_details';
	insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
	)
	select sls_order_dt,
		   sls_prd_key,
		   sls_cust_id,
		   case when sls_order_dt < 0 OR len(sls_order_dt) < 8 then NULL
				else cast(cast(sls_order_dt as varchar) as date)
			END as sls_order_dt,
		   case when sls_ship_dt<0 OR LEN(sls_ship_dt) <8 then NULL
				else cast(cast(sls_ship_dt as varchar) as date) 
			END as sls_ship_dt,
			case when sls_due_dt <0 OR LEN(sls_due_dt)<8 then NULL
				 else CAST(cast(sls_due_dt as Varchar) as date)
			END as sls_due_dt,
			case when sls_sales Is null OR sls_sales<=0 OR sls_sales != sls_quantity * ABS(sls_price)
					then sls_quantity* ABS(sls_price)
				else sls_sales
			END as sls_sales,
			sls_quantity,
			case when sls_price IS NULL OR sls_price <=0 
				then sls_sales / ISNULL(sls_quantity,0) 
				else sls_price
			END as sls_price
	from bronze.crm_sales_details;
	SET @end_time= GETDATE();
	PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) as nvarchar ) + 'seconds';

	PRINT '-----------------------------------';
	PRINT '-----Laoding ERP tables------------';
	SET @start_time= GETDATE();
	PRINT '>>Truncating Table silver.erp_CUST_AZ12';
	TRUNCATE Table silver.erp_CUST_AZ12;
	PRINT ' Inserting data into : silver.erp_CUST_AZ12';
	insert into silver.erp_CUST_AZ12 (
				CID,
				BDATE,
				GEN
	)
	select 
		 case when CID like 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
			  ELSE CID
		END as CID,
		case when BDATE > GETDATE() THEN NULL
			 ELSE BDATE
		END as BDATE,
		case when UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
			 when UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
			 ELSE 'N/A'
		END as GEN
	from bronze.erp_CUST_AZ12;
	SET @end_time=GETDATE();
	PRINT 'Loading Time: ' + CAST(DATEDIFF( second, @start_time, @end_time) as Nvarchar) + 'second';

	
	SET @start_time=GETDATE();
	PRINT '>>Truncating Table silver.erp_LOC_A101';
	TRUNCATE Table silver.erp_LOC_A101;
	PRINT ' Inserting data into : silver.erp_LOC_A101';
	insert into silver.erp_LOC_A101 (
				CID,
				CNTRY
		)

	select 
			REPLACE(CID, '-', '') as CID,
			case when TRIM(CNTRY) = 'DE' THEN 'Germany'
				 when TRIM(CNTRY) IN ('US', 'USA') then 'United States'
				 when TRIM(CNTRY)= '' OR TRIM(CNTRY) IS NULL then 'N/A'
				 else TRIM(CNTRY)
			END as CNTRY
	from bronze.erp_LOC_A101;
	SET @end_time= GETDATE();
	PRINT 'Loading Time:' + CAST(DATEDIFF(second, @start_time, @end_time) as Nvarchar ) + 'seconds';

	SET @start_time = GETDATE();
	PRINT '>>Truncating Table silver.erp_PX_CAT_G1V2';
	TRUNCATE Table silver.erp_PX_CAT_G1V2;
	PRINT ' Inserting data into : silver.erp_PX_CAT_G1V2';
	insert into silver.erp_PX_CAT_G1V2(
				ID,
				CAT,
				SUBCAT,
				MAINTENANCE
		)
		select ID,
			   CAT,
			   SUBCAT,
			   MAINTENANCE
		from  bronze.erp_PX_CAT_G1V2;
	SET @end_time= GETDATE();
	PRINT 'Loading Time: '+ CAST(DATEDIFF(second, @start_time, @end_time) as Nvarchar) + 'seconds';
	PRINT '>> -------------'

	SET @batch_end_time= GETDATE();
	PRINT '=======================';
	PRINT 'Loading Silver layer is completed';
	PRINT 'Total duration is: ' + CAST(DATEDIFF(second, @batch_start_time,  @batch_end_time ) as Nvarchar ) + 'seconds';
	PRINT '=======================';
	END TRY
	BEGIN CATCH
		PRINT'=======================================';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + cast(ERROR_NUMBER() as NVARCHAR);
		PRINT'=======================================';
	END CATCH
END
