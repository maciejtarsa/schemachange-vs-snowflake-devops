# schemachange
A respository for storing code for resources in Snowflake (access and infrastructure).

It uses schemachange to deploy to Snowflake environment.  
[schemachange GitHub repo](https://github.com/Snowflake-Labs/schemachange)

All schemachange migrations are stored in `migrations` directory.  
There are 3 types of migrations:
- Versioned, e.g. `V1.1__name.sql`
- Repeatable, e.g. `R__name.sql`
- Always, e.g. `A__name.sql`
They will be applied in that order - versioned first, then repeatable and always at the end.

Changes could be deployed automatically using a CI/CD pipeline.

## Target Account setup

Minimum manual one-off setup is required in target Snowflake account and for each environment.  
It creates `<ENV>_SCHEMACHANGE_USER` which will be used for deployment into Snowflake. For best practice, key-pair is used for authentication instead of a password.  
[Snowflake documentation on key-pair authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)

For account level setup, run the following script:
`./initial_snowflake_account_setup/setup_account.sql`
This script will:
- create database and schema for schemachange

or each environment, run the following script:  
`./initial_snowflake_account_setup/setup_environment.sql`  
Replace `<TARGET_ENV>` and `<PUBLIC_KEY>` with the corresponding target environment and public key.
This script will:
- Create a user and role for schemachange
- Create a history table for schemachange

Additionally, scripts for key rotation can be found in:
`./initial_snowflake_account_setup/key_rotation.sql`  
This script can be used for rotating RSA keys for service users.

### Key generation

Generate a new PPK pair for use by the `<ENV>_SCHEMACHANGE_USER` in target Snowflake account.  
Generate the private and public keys:  
```bash
mkdir -p rsa_keys
openssl genrsa 4096 | openssl pkcs8 -topk8 -inform PEM -out rsa_keys/rsa_key.p8 -nocrypt
openssl rsa -in rsa_keys/rsa_key.p8 -pubout -out rsa_keys/rsa_key.pub
openssl base64 -in rsa_keys/rsa_key.p8 | tr -d '\n\r' > rsa_keys/rsa_key.base64private-key
cat rsa_keys/rsa_key.pub | sed 1d | sed '$d' | tr -d '\n\r' > rsa_keys/rsa_key.snowflake-user-public-key
```
The script will generate the keys in 2 different versions - note schemachange requires them with no header/footers and all on a single line.

These keys should never be commited into version control. They are saved locally under `rsa_keys` folder - the folder has been added to `.gitignore`. As a result, none of its contents will be commited into version control. But it is best practice to delete these keys permanently from your local machine when no longer required.  

## Local development
For local development, you will require Python installed on your local machine.  

Create virtual environment (only need to do this once):
```bash
python3 -m venv venv
```
Your local virtual environment will not be commited to version control - `venv` folder is included in `.gitignore`.

To activate the virtual environment:
```bash
source venv/Scripts/activate
```

Then run schemachange using a shell script and passing the required variables
```bash
./run_schemachange.sh <ENV> <SNOFLAKE_ACCOUNT> <PRIVATE_KEY_LOCATION>
```