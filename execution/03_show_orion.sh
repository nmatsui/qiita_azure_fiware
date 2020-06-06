#!/bin/bash
source $(cd $(dirname $0);pwd)/../variables/env.fiware

## show entities
cnt=0
kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://orion:1026/v2/entities/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .
