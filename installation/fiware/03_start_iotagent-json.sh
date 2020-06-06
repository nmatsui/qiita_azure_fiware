#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure
source $(cd $(dirname $0);pwd)/../../variables/env.fiware
CWD=$(cd $(dirname $0);pwd)

## start iotagent json
SERVICE_KEY=$(az servicebus namespace authorization-rule keys list --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --name service | jq -r '.primaryKey')
kubectl create secret generic servicebus-credentials --from-literal=primaryKey=$(echo ${SERVICE_KEY})
kubectl apply -f ${CWD}/yaml/iotagent-json-service.yaml
SERVICEBUS=${SERVICEBUS} ENTITIES=${ENTITIES} FIWARE_SERVICE=${FIWARE_SERVICE} FIWARE_SERVICEPATH=${FIWARE_SERVICEPATH} envsubst < ${CWD}/yaml/iotagent-json-deployment.yaml | kubectl apply -f -
