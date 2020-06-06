#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure
source $(cd $(dirname $0);pwd)/../../variables/env.fiware

## start service bus
az servicebus namespace create --resource-group ${RESOURCE_GROUP} --name ${SERVICEBUS} --sku Standard
az servicebus namespace authorization-rule create --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --name service --rights Send Listen
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")
  az servicebus queue create --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --name "${type}.${id}.up"
  az servicebus queue authorization-rule create --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --queue-name "${type}.${id}.up" --name device --rights Send
  az servicebus queue create --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --name "${type}.${id}.down"
  az servicebus queue authorization-rule create --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --queue-name "${type}.${id}.down" --name device --rights Listen
done
