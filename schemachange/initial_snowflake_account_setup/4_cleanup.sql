-- cleanup of resources created manually for deployment purposes
USE ROLE ACCOUNTADMIN;

-- should be repeated for each environment
USE ROLE FR_DEV_SCHEMACHANGE;
DROP WAREHOUSE IF EXISTS WH_DEV_DATA_ENG;
DROP DATABASE IF EXISTS DEV_RAW;
DROP ROLE IF EXISTS FR_DEV_DATA_ENG;
DROP ROLE IF EXISTS AR_DEV_READ;
DROP PROCEDURE IF EXISTS ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(STRING, STRING, STRING);

-- cleanup of resources created manually for deployment purposes
USE ROLE ACCOUNTADMIN;
DROP WAREHOUSE IF EXISTS WH_DEV_SCHEMACHANGE;

DROP ROLE IF EXISTS FR_DEV_SCHEMACHANGE;
DROP USER IF EXISTS DEV_SCHEMACHANGE_USER;

-- and account level settings

DROP SCHEMA IF EXISTS ADMIN_DB.SCHEMACHANGE;
DROP DATABASE IF EXISTS ADMIN_DB;
