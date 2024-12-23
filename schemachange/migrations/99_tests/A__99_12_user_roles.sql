------------------------------------------------------------------------
-- 12_USER_ROLES Test functional roles are granted correct access roles
-- and access to correct warehouse
-----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE ADMIN_DB.PUBLIC.EXPECTED_RESULTS AS SELECT * FROM
    VALUES
    ('AR_{{ ENV }}_READ', 'ROLE', 'USAGE', 'FR_{{ ENV }}_DATA_ENG')
    , ('WH_{{ ENV }}_DATA_ENG', 'WAREHOUSE', 'USAGE', 'FR_{{ ENV }}_DATA_ENG')
        AS T (NAME, GRANTED_ON, PRIVILEGE, GRANTEE_NAME);
CALL ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
    'SHOW GRANTS TO ROLE FR_{{ ENV }}_DATA_ENG'
    , 'ADMIN_DB.PUBLIC.EXPECTED_RESULTS'
    , 'PRIVILEGE!=OWNERSHIP' -- filter USAGE only as DBT will have ownership of tables and schemas
);

