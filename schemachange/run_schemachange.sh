#!/bin/bash

set -euo pipefail
 
ENV="$1"
SNOWFLAKE_ACCOUNT="$2"

# Schemachagne requires the private key to be in a file.  Using tempfile and trap to reduce risk of credential exposure by deleting the tempfile when this script exits.
tempKeyFile=$(mktemp)
echo "$3" | base64 -d > "${tempKeyFile}" || { echo "Failed to decode base64 input"; exit 1; }

export SNOWFLAKE_PRIVATE_KEY_PATH="${tempKeyFile}"
export SNOWFLAKE_ACCOUNT=${SNOWFLAKE_ACCOUNT}
export ENV=${ENV}

trap 'rm -f "${tempKeyFile}"' EXIT

echo "Deploying schemachange to environment ${ENV} in account ${SNOWFLAKE_ACCOUNT} ... "

schemachange deploy -c ADMIN_DB.SCHEMACHANGE.${ENV}_CHANGE_HISTORY \
    --vars "{\"ENV\":\"$ENV\"}"
