


CREATE OR REPLACE PROCEDURE DATA_WARE_HOUSE.SILVER.DWH_DATA_LOAD_SILVER()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN

    -- CRM CUSTOMER
    INSERT INTO SILVER.CRM_CUST_INFO
    SELECT 
        cst_id,
        cst_key,
        INITCAP(TRIM(cst_firstname)),
        INITCAP(TRIM(cst_lastname)),
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date,
        CURRENT_TIMESTAMP
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_id ASC) AS r_n
        FROM BRONZE.CRM_CUST_INFO
        WHERE cst_id IS NOT NULL
    ) a
    WHERE r_n = 1;


    -- CRM PRODUCT
    INSERT INTO SILVER.CRM_PRD_INFO
    SELECT 
        prd_id,  
        REPLACE(SUBSTR(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line, 
        prd_start_dt,
        DATEADD(
            DAY, -1, 
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
        ) AS prd_end_dt,
        CURRENT_TIMESTAMP
    FROM BRONZE.CRM_PRD_INFO;


    -- CRM SALES DETAILS
    INSERT INTO SILVER.CRM_SALES_DETAILS
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
             ELSE TRY_TO_DATE(TO_VARCHAR(sls_order_dt), 'YYYYMMDD') END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
             ELSE TRY_TO_DATE(TO_VARCHAR(sls_ship_dt), 'YYYYMMDD') END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
             ELSE TRY_TO_DATE(TO_VARCHAR(sls_due_dt), 'YYYYMMDD') END AS sls_due_dt,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price,
        CURRENT_TIMESTAMP
    FROM BRONZE.CRM_SALES_DETAILS;


    -- ERP CUSTOMER
    TRUNCATE TABLE SILVER.ERP_CUST_AZ12;
    INSERT INTO SILVER.ERP_CUST_AZ12 (cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END AS cid,
        CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM BRONZE.ERP_CUST_AZ12;


    -- ERP LOCATION
    TRUNCATE TABLE SILVER.ERP_LOC_A101;
    INSERT INTO SILVER.ERP_LOC_A101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE 
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry
    FROM BRONZE.ERP_LOC_A101;


    -- ERP PRODUCT CATEGORY
    TRUNCATE TABLE SILVER.ERP_PX_CAT_G1V2;
    INSERT INTO SILVER.ERP_PX_CAT_G1V2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
    FROM BRONZE.ERP_PX_CAT_G1V2;

    RETURN 'Success';

END;
$$;
