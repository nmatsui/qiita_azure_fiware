#!/bin/bash

source $(cd $(dirname $0);pwd)/../../variables/env.azure
source $(cd $(dirname $0);pwd)/../../variables/env.fiware

PG_HOST=$(az postgres server show --resource-group ${RESOURCE_GROUP} --name ${PG} | jq -r '.fullyQualifiedDomainName')

TBL="dummy"
if [[ ${FIWARE_SERVICEPATH} =~ ^/?(.+)$ ]]; then
  TBL=${BASH_REMATCH[1]////_}
fi

## sql
SQL=$(cat << __EOS__
CREATE SCHEMA IF NOT EXISTS ${FIWARE_SERVICE};
DROP TABLE IF EXISTS ${FIWARE_SERVICE}.${TBL};
CREATE TABLE IF NOT EXISTS ${FIWARE_SERVICE}.${TBL} (
  id SERIAL NOT NULL,
  recvTime TIMESTAMP WITH TIME ZONE NOT NULL,
  fiwareServicePath TEXT NOT NULL,
  entityId TEXT NOT NULL,
  entityType TEXT NOT NULL,
  temperature NUMERIC,
  temperature_md JSON,
  humidity NUMERIC,
  humidity_md JSON,
  open_info TEXT,
  open_info_md JSON,
  open_status TEXT,
  open_status_md JSON,
  PRIMARY KEY (id)
);
DROP INDEX IF EXISTS ${TBL}_entityId_idx;
CREATE INDEX IF NOT EXISTS ${TBL}_entityId_idx ON ${FIWARE_SERVICE}.${TBL} (entityId);
DROP INDEX IF EXISTS ${TBL}_recvTime_idx;
CREATE INDEX IF NOT EXISTS ${TBL}_recvTime_idx ON ${FIWARE_SERVICE}.${TBL} (recvTime);
__EOS__
)
echo "SQL=${SQL}"

## create schema and table
kubectl run --rm -i --restart=OnFailure --image postgres:${PG_VERSION} psql-client -- /bin/bash -c \
  "PGPASSWORD=${PG_ADMIN_PASSWORD} psql --host=${PG_HOST} --port=5432 --dbname=${PG_DATABASE} --username=${PG_ADMIN}@${PG} --command '${SQL}'"
