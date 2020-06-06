#!/bin/bash

source $(cd $(dirname $0);pwd)/../variables/env.azure
source $(cd $(dirname $0);pwd)/../variables/env.fiware

PG_HOST=$(az postgres server show --resource-group ${RESOURCE_GROUP} --name ${PG} | jq -r '.fullyQualifiedDomainName')

TBL="dummy"
if [[ ${FIWARE_SERVICEPATH} =~ ^/?(.+)$ ]]; then
  TBL=${BASH_REMATCH[1]////_}
fi

## sql
SQL=$(cat << __EOS__
SELECT * FROM ${FIWARE_SERVICE}.${TBL};
__EOS__
)
echo "SQL=${SQL}"

## show data
kubectl run --rm -i --restart=OnFailure --image postgres:${PG_VERSION} psql-client -- /bin/bash -c \
  "PGPASSWORD=${PG_ADMIN_PASSWORD} psql --host=${PG_HOST} --port=5432 --dbname=${PG_DATABASE} --username=${PG_ADMIN}@${PG} --command '${SQL}'"
