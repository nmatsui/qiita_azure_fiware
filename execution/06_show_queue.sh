#!/bin/bash
source $(cd $(dirname $0);pwd)/../variables/env.azure
source $(cd $(dirname $0);pwd)/../variables/env.fiware

## show service bus queue
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")
  az servicebus queue show --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --name "${type}.${id}.down" | jq '{name: .name, count: .countDetails}'
done
