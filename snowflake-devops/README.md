# Snowflake DevOps
A repository for getting started with Snowflake DevOps

## Getting started

### Target Account setup

Minimum manual one-off setup is required in target Snowflake account and for each environment.  
It creates `<ENV>_DEVOPS_USER` which will be used for deployment into Snowflake. For best practice, key-pair is used for authentication instead of a password.  
[Snowflake documentation on key-pair authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)

For account level setup, run the following script:
`./initial_snowflake_account_setup/setup_account.sql`  
This script will:
- create database and schema for devops

For each environment, run the following script:  
`./initial_snowflake_account_setup/setup_environment.sql`  
Replace `<TARGET_ENV>` and `<PUBLIC_KEY>` with the corresponding target environment and public key.  
This script will:
- Create a user and role for devops

Additionally, scripts for key rotation can be found in 
`./initial_snowflake_account_setup/key_rotation.sql`  
This script can be used for rotating RSA keys for service users.

### Key generation

Generate a new PPK pair for use by the `<ENV>_DEVOPS_USER` in target Snowflake account.  
Generate the private and public keys:  
```bash
mkdir -p rsa_keys
openssl genrsa 4096 | openssl pkcs8 -topk8 -inform PEM -out rsa_keys/rsa_key.p8 -nocrypt
openssl rsa -in rsa_keys/rsa_key.p8 -pubout -out rsa_keys/rsa_key.pub
openssl base64 -in rsa_keys/rsa_key.p8 | tr -d '\n\r' > rsa_keys/rsa_key.base64private-key
cat rsa_keys/rsa_key.pub | sed 1d | sed '$d' | tr -d '\n\r' > rsa_keys/rsa_key.snowflake-user-public-key
```
The script will generate the keys in 2 different versions - note Snowflake requires them with no header/footers and all on a single line.

These keys should never be commited into version control. They are saved locally under `rsa_keys` folder - the folder has been added to `.gitignore`. As a result, none of its contents will be commited into version control. But it is best practice to delete these keys permanently from your local machine when no longer required.  

### Snowflake CLI

Snowflake CLI is required for interacting with Snowflake - it can be downloaded from [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation/installation#label-snowcli-install-macos-installer)

A Snowflake configuration file will be required - [instructions](https://docs.snowflake.com/en/developer-guide/snowflake-cli/connecting/configure-cli).  
Sample file located in `.snowflake/config-sample.toml`

To test the connection, run:
```bash
snow connection test
```

To execute all current scripts, first fetch the latest chanegs in your git repo into Snowflake
```bash
snow git fetch ADMIN_DB.DEVOPS.DEVOPS_REPO
```
And to execute all commands
```bash
snow git execute "@ADMIN_DB.DEVOPS.DEVOPS_REPO/branches/main/snowflake-devops/steps/02_*" -D "ENV='DEV'"
```
We can use `-D` notation to provide parameters to be replaced in any Jinja notation within our SQL or Python code.
