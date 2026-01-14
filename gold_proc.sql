CREATE OR REPLACE PROCEDURE DATA_WARE_HOUSE.GOLD.DWH_LOAD_TODAYS_DATA()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN

    ------------------------------------------------------
    -- 1️⃣ Load Today's Customers
    ------------------------------------------------------
    INSERT INTO GOLD.DIM_CUSTOMERS
    SELECT
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        la.cntry AS country,
        ci.cst_marital_status,
        CASE 
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
            ELSE COALESCE(ca.gen, 'n/a')
        END AS gender,
        ca.bdate AS birthdate,
        ci.cst_create_date AS create_date
    FROM SILVER.CRM_CUST_INFO ci
    LEFT JOIN SILVER.ERP_CUST_AZ12 ca ON ci.cst_key = ca.cid
    LEFT JOIN SILVER.ERP_LOC_A101 la ON ci.cst_key = la.cid
    WHERE ci.cst_create_date = CURRENT_DATE;  -- ✅ Only today's data


    ------------------------------------------------------
    -- 2️⃣ Load Today's Products
    ------------------------------------------------------
    INSERT INTO GOLD.DIM_PRODUCTS
    SELECT
        ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
        pn.prd_id,
        pn.prd_key,
        pn.prd_nm,
        pn.cat_id,
        pc.cat,
        pc.subcat,
        pc.maintenance,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt
    FROM SILVER.CRM_PRD_INFO pn
    LEFT JOIN SILVER.ERP_PX_CAT_G1V2 pc ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL
      AND DATE(pn.prd_start_dt) = CURRENT_DATE;  -- ✅ Only today's products


    ------------------------------------------------------
    -- 3️⃣ Load Today's Sales
    ------------------------------------------------------
    INSERT INTO GOLD.FACT_SALES
    SELECT
        sd.sls_ord_num,
        pr.product_key,
        cu.customer_key,
        sd.sls_order_dt,
        sd.sls_ship_dt,
        sd.sls_due_dt,
        sd.sls_sales,
        sd.sls_quantity,
        sd.sls_price
    FROM SILVER.CRM_SALES_DETAILS sd
    LEFT JOIN GOLD.DIM_PRODUCTS pr ON sd.sls_prd_key = pr.product_number
    LEFT JOIN GOLD.DIM_CUSTOMERS cu ON sd.sls_cust_id = cu.customer_id
    WHERE DATE(sd.sls_order_dt) = CURRENT_DATE;  -- ✅ Only today's sales

    RETURN '✅ Gold layer loaded successfully for today: ' || TO_VARCHAR(CURRENT_DATE);

END;
$$;
