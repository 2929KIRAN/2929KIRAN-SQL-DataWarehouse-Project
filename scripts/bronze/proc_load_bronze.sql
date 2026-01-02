/*
======================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=====================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
    -Truncates the bronze tables before loading data.
    -Uses the BULK INSERT command to load data from csv Files to bronze tables.
Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.
Usage Example:
  EXEC bronze.load_bronze;
=====================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	Declare @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time=GETDATE();
		PRINT '=======================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=======================================';

		PRINT'----------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'----------------------------------------';

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		Truncate table bronze.crm_cust_info; -- Emptying the table first and then bulk load
		PRINT '>> Inserting Data into:crm_cust_info';
		Bulk Insert bronze.crm_cust_info
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ 'seconds' ;
		PRINT'>> -----------'

		-- select * from bronze.crm_cust_info;
		SET @start_time= GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		Truncate table bronze.crm_prd_info; -- Emptying the table first and then bulk load
		PRINT '>> Inserting Data into:crm_prd_info';
		Bulk Insert bronze.crm_prd_info
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time= GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ 'seconds' ;
		PRINT'>> -----------'

		--select * from bronze.crm_prd_info;
		SET @start_time= GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		Truncate table bronze.crm_sales_details; -- Emptying the table first and then bulk load
		PRINT '>> Inserting Data into:crm_sales_details';
		Bulk Insert bronze.crm_sales_details
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ 'seconds' ;
		PRINT'>> -----------'
		-- select * from bronze.crm_sales_details;

		PRINT'----------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'----------------------------------------';

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: bronze.erp_CUST_AZ12';
		Truncate table bronze.erp_CUST_AZ12; -- Emptying the table first and then bulk load

		PRINT '>> Inserting Data into:erp_CUST_AZ12';
		Bulk Insert bronze.erp_CUST_AZ12
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ 'seconds' ;
		PRINT'>> -----------'

		-- select * from bronze.erp_CUST_AZ12;
		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: bronze.erp_LOC_A101';
		Truncate table bronze.erp_LOC_A101; -- Emptying the table first and then bulk load
		PRINT '>> Inserting Data into:erp_LOC_A101';
		Bulk Insert bronze.erp_LOC_A101
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ 'seconds' ;
		PRINT'>> -----------'
		-- select * from bronze.erp_LOC_A101;

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table: bronze.erp_PX_CAT_G1V2';
		Truncate table bronze.erp_PX_CAT_G1V2; -- Emptying the table first and then bulk load

		PRINT '>> Inserting Data into:erp_PX_CAT_G1V2';
		Bulk Insert bronze.erp_PX_CAT_G1V2
		from 'C:\Users\Quince\Desktop\JK\Sql\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR)+ ' seconds' ;
		PRINT'>> -----------'
		-- select * from bronze.erp_PX_CAT_G1V2;
		SET @batch_end_time=GETDATE();
		PRINT'==================';
		PRINT'Loading Bronze layer is completed';
		PRINT ' Total Duration: '+ CAST(DATEDIFF(second, @batch_start_time,@batch_end_time)as NVARCHAR)+ 'seconds';
		PRINT '=================';
	END TRY
	BEGIN CATCH
		PRINT'=======================================';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + cast(ERROR_NUMBER() as NVARCHAR);

		PRINT'=======================================';
	END CATCH
END
