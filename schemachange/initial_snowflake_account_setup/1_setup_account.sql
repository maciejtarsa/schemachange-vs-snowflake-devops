-- Initial manual setup in target Snowflake account
-- Required before the pipeline will work

USE ROLE ACCOUNTADMIN;

-- admin_db database and schemachange schema--
CREATE DATABASE IF NOT EXISTS ADMIN_DB;
CREATE SCHEMA IF NOT EXISTS SCHEMACHANGE;
