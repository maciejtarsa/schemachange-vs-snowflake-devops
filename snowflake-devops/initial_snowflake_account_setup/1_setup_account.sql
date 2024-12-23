-- Initial manual setup in target Snowflake account
-- Required before the deployment will work

USE ROLE ACCOUNTADMIN;

-- admin_db database and devops schema--
CREATE DATABASE IF NOT EXISTS ADMIN_DB;
CREATE SCHEMA IF NOT EXISTS DEVOPS;

-- API integration is needed for GitHub integration
CREATE OR REPLACE API INTEGRATION GIT_API_INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/<insert GitHub username>') -- INSERT YOUR GITHUB USERNAME HERE
  ENABLED = TRUE;

-- Git repository object is similar to external stage
-- Note this works with public repository only
-- For private repository, you need to use Snowflake secrets
CREATE OR REPLACE GIT REPOSITORY ADMIN_DB.DEVOPS.GIT_API_INTEGRATION
  API_INTEGRATION = git_api_integration
  ORIGIN = '<insert URL of forked GitHub repo>'; -- INSERT URL OF FORKED REPO HERE
