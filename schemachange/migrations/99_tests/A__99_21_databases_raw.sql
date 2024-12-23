----------------------------------------------------------------------------
-- 21_DATABASE_RAW Test Databases ENV_RAW exists and has the expected grants
----------------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE ADMIN_DB.PUBLIC.EXPECTED_RESULTS AS SELECT * FROM
    VALUES
    ('{{ ENV }}_RAW.TESTING', 'USAGE', 'ROLE', 'AR_{{ ENV }}_READ')
    , ('{{ ENV }}_RAW.TESTING', 'OWNERSHIP', 'ROLE', 'FR_{{ ENV }}_SCHEMACHANGE')
        AS T (NAME, PRIVILEGE, GRANTED_TO, GRANTEE_NAME);
CALL ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
    'SHOW GRANTS ON SCHEMA {{ ENV }}_RAW.TESTING'
    , 'ADMIN_DB.PUBLIC.EXPECTED_RESULTS'
);

CREATE OR REPLACE TEMPORARY TABLE ADMIN_DB.PUBLIC.EXPECTED_RESULTS AS SELECT * FROM
    VALUES
    ('{{ ENV }}_RAW.TESTING.<TABLE>', 'SELECT', 'TABLE', 'ROLE', 'AR_{{ ENV }}_READ')
        AS T (NAME, PRIVILEGE, GRANT_ON, GRANT_TO, GRANTEE_NAME);
CALL ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
    'SHOW FUTURE GRANTS IN SCHEMA {{ ENV }}_RAW.TESTING'
    , 'ADMIN_DB.PUBLIC.EXPECTED_RESULTS'
);
