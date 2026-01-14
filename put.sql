-- SELECT CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME();
snowsql -a faiubgv-cj77375 -u PAVAN

LIST @CRM_ERP_MY_INTERNAL_STAGE;

PUT 'file://C:/Users/DELL 7280/Downloads/Snowflake/project/datasets/*.csv' @DATA_WARE_HOUSE.BRONZE.CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;

PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/cust_info.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;
PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/prd_info.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;
PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/sales_details.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;
PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/LOC_A101.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;
PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/PX_CAT_G1V2.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;
PUT file://C:\Users\DELL 7280\Downloads\Snowflake\project\datasets/CUST_AZ12.csv @CRM_ERP_MY_INTERNAL_STAGE AUTO_COMPRESS=FALSE;