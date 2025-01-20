-- a file for cleaning up the resources created
-- not something you would have in your actual deployment
-- but useful for demonstration purposes

DROP WAREHOUSE IF EXISTS WH_{{ ENV }}_DATA_ENG;
DROP DATABASE IF EXISTS {{ ENV }}_RAW;
DROP ROLE IF EXISTS FR_{{ ENV }}_DATA_ENG;
DROP ROLE IF EXISTS AR_{{ ENV }}_READ;

{% if ENV == 'DEV' %}
    DROP PROCEDURE IF EXISTS ADMIN_DB.DEVOPS.COMPARE_SHOW_TO_TABLE(STRING, STRING, STRING);
{% endif %}
SELECT 1;
-- avoid error when file ends with a comment
