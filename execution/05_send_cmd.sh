#!/bin/bash
source $(cd $(dirname $0);pwd)/../variables/env.fiware

## send command
cnt=0
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")

  kubectl run -i --rm --restart=OnFailure --image curlimages/curl curl$((++cnt)) -- \
    -i "http://orion:1026/v2/entities/${id}/attrs?type=${type}" \
    -H "Fiware-Service: ${FIWARE_SERVICE}" \
    -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
    -H "Content-Type: application/json" \
    -X PATCH -d @- <<__EOS__
{
  "open": {
    "value": "window1"
  }
}
__EOS__
done

kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://orion:1026/v2/entities/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .
