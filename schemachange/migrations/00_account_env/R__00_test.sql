-- only execute this in STG
{% if ENV == 'DEV' %}

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE PROCEDURE ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
    sql_stmts STRING
    , expected_table_name STRING
    , predicates STRING DEFAULT ''
)
-- Execute a SQL statement and compare the result to the expected table
-- This procedure is primary intended for testing the matching rows of SHOW statements
-- The rows returned by the statement are compared with expected table:
--   - PASS is returned if result == expected_table
--   - a ValueError is returned otherwise
-- Usage:
--   - sql_stmts - the SQL statements to execute, e.g. 'SHOW SCHEMAS IN DATABASE SANDBOX'
--         either a single statement or multiple statamenets separated by ' && ', e.g.
--         'SHOW SCHEMAS IN DATABASE SANDBOX && SHOW SCHEMAS IN DATABASE ADMIN_DB'
--         if using multiple statamenets, they MUST return the same columns
--   - expected_table_name - The name of the table containing the expected results
--   - predicates - optional predicates to filter the result
--          currently only equality or non equality with a single value predicates are supported, e.g.:
--          PRIVILEGE=USAGE
--          PRIVILEGE=USAGE && GRANTED_ON!=ROLE
--
-- Example:
--  CREATE OR REPLACE TEMPORARY TABLE ADMIN_DB.PUBLIC.EXPECTED_RESULTS as SELECT * FROM
--      VALUES 
--      ('INFORMATION_SCHEMA', 'ADMIN_DB')
--      , ('SCHEMACHANGE', 'ADMIN_DB')
--      , ('PUBLIC', 'ADMIN_DB') 
--          AS T (NAME, DATABASE_NAME);
--  
--  CALL ADMIN_DB.SCHEMACHANGE.COMPARE_SHOW_TO_TABLE(
--      'SHOW SCHEMAS IN DATABASE ADMIN_DB && SHOW SCHEMAS IN DATABASE SANDBOX'
--      , 'ADMIN_DB.PUBLIC.EXPECTED_RESULTS'
--  );
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11 -- noqa: PRS
PACKAGES = ('snowflake-snowpark-python')
HANDLER='compare_show_to_table'
-- These test scripts are potentially powerful and could be subject to SQL injection due to statement construction.
-- Therefore restrict access based on callers permission set only.
EXECUTE AS CALLER
AS
$$
#Create a manually formatted JSON-like string for the differences
def format_dict_as_table(list_of_dicts):
    if list_of_dicts:
        all_keys = list_of_dicts[0].keys()

        # calculate the maximum width for each column
        col_widths = {}
        for key in all_keys:
            max_width = len(key) #start with header length
            for item in list_of_dicts:
                value = str(item.get(key, "N\A"))
                max_width = max(max_width, len(value))
            col_widths[key] = max_width + 2
        
        header = ""
        for key in all_keys:
            header += f"{key:<{col_widths[key]}}"
        header += "\n"
        separator = "-" * sum(col_widths[key] for key in all_keys) + "\n"

        rows = ""
        # Build rows from list of dict
        for item in list_of_dicts:
            for key in all_keys:
                value = item.get(key, "N\A")
                rows += f"{str(value):<{col_widths[key]}}"
            rows += "\n"
        return header + separator + rows
                    
    else:
        return ""
    
def compare_show_to_table(session, sql_stmts, expected_table_name, predicates):
    expected_result_df = session.sql(f'SELECT * FROM {expected_table_name}')

    
    sql_stmts_list = sql_stmts.split('&&')
    actual_result_df = session.sql(sql_stmts_list[0])
    for statament in sql_stmts_list[1:]:
        next_result_df = session.sql(statament)
        actual_result_df = actual_result_df.union(next_result_df)
        
    if predicates:
        predicates_list = predicates.split(' && ')
        for predicate_item in predicates_list:
            if '!=' in predicate_item:
                predcate_value = predicate_item.split('!=')
                actual_result_df = actual_result_df.where(actual_result_df.col(f'"{predcate_value[0].lower()}"') != predcate_value[1])
            else:
                predcate_value = predicate_item.split('=')
                actual_result_df = actual_result_df.where(actual_result_df.col(f'"{predcate_value[0].lower()}"') == predcate_value[1])

    actual_result_df_columns = [item.replace('"','').upper() for item in actual_result_df.columns]
    if not set(expected_result_df.columns).issubset(set(actual_result_df_columns)):
        raise ValueError(f"""
            Expected columns do not match actual columns.
            Expected columns: {expected_result_df.columns}
            Actual columns found: {actual_result_df_columns}
        """)
    columns_to_use = list(set(actual_result_df_columns).intersection(set(expected_result_df.columns))) 

    expected_result = expected_result_df.sort(columns_to_use).collect()
    actual_result_df_filtered = actual_result_df.to_df(actual_result_df_columns).select(sorted(columns_to_use))
    actual_result = actual_result_df_filtered.sort(columns_to_use).collect()

    expected_result_ordered = [dict(sorted(item.as_dict().items())) for item in expected_result]
    actual_result_ordered = [dict(sorted(item.as_dict().items())) for item in actual_result]

    diff = {}
    
    # Results in expected but not in actual
    in_expected_but_not_actual = [item for item in expected_result_ordered if item not in actual_result_ordered]
    if in_expected_but_not_actual:
        diff["In expected but not in actual"]= in_expected_but_not_actual
    # Results in actual but not in expected
    in_actual_but_not_expected = [item for item in actual_result_ordered if item not in expected_result_ordered]
    if in_actual_but_not_expected:
        diff["In actual but not in expected"] = in_actual_but_not_expected

    
    if not diff:
        return 'PASS'
    raise ValueError(f"""
Error in SQL statement:
{sql_stmts}
        
In expected result but not in actual result:
{format_dict_as_table(diff.get("In expected but not in actual", ""))}

In actual result but not in expected result:
{format_dict_as_table(diff.get("In actual but not in expected",""))}

    """)
$$;

{% endif %}

-- avoid schemachange error when file ends with a comment
SELECT 1;
