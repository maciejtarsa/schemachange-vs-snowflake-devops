----------------------------------------------------------------------
-- 31_WAREHOUSES Test correct grants applied to each service warehouse
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE ADMIN_DB.PUBLIC.EXPECTED_RESULTS AS SELECT * FROM
    VALUES
    ('USAGE', 'WH_{{ ENV }}_DATA_ENG', 'FR_{{ ENV }}_DATA_ENG')
    , ('OWNERSHIP' ,'WH_{{ ENV }}_DATA_ENG', 'FR_{{ ENV }}_SCHEMACHANGE')
        AS T (PRIVILEGE, NAME, GRANTEE_NAME);

CALL ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
    'SHOW GRANTS ON WAREHOUSE WH_{{ ENV }}_DATA_ENG'
    , 'ADMIN_DB.PUBLIC.EXPECTED_RESULTS'
);