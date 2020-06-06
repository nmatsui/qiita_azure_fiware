#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure
source $(cd $(dirname $0);pwd)/../../variables/env.fiware
CWD=$(cd $(dirname $0);pwd)

## start cygnus
kubectl create secret generic postgresql-credential --from-literal=password=${PG_ADMIN_PASSWORD}
PG_HOST=$(az postgres server show --resource-group ${RESOURCE_GROUP} --name ${PG} | jq -r '.fullyQualifiedDomainName')
kubectl apply -f ${CWD}/yaml/cygnus-postgresql-service.yaml
PG_HOST=${PG_HOST} PG_ADMIN=${PG_ADMIN} PG=${PG} PG_DATABASE=${PG_DATABASE} envsubst < ${CWD}/yaml/cygnus-postgresql-deployment.yaml | kubectl apply -f -
