#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.fiware

## register service group
cnt=0
len=$(echo ${ENTITIES} | jq '[.[].type] | unique | length')
for i in $(seq 0 $((${len} - 1))); do
  type=$(echo ${ENTITIES} | jq -r "[.[].type] | unique | .[$i]")
  kubectl run -i --rm --restart=OnFailure --image curlimages/curl curl$((++cnt)) -- \
    -i "http://iotagent-json:4041/iot/services/" \
    -H "Fiware-Service: ${FIWARE_SERVICE}" \
    -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
    -H "Content-Type: application/json" \
    -X POST -d @- <<__EOS__
{
  "services": [
    {
      "apikey": "${type}",
      "cbroker": "http://orion:1026",
      "resource": "/iot/json",
      "entity_type": "${type}"
    }
  ]
}
__EOS__
done

kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://iotagent-json:4041/iot/services/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .
