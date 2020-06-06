#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.fiware

## register subscription
cnt=0
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")

  kubectl run -i --rm --restart=OnFailure --image curlimages/curl curl$((++cnt)) -- \
    -i "http://orion:1026/v2/subscriptions/" \
    -H "Fiware-Service: ${FIWARE_SERVICE}" \
    -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
    -H "Content-Type: application/json" \
    -X POST -d @- <<__EOS__
{
  "subject": {
    "entities": [{
      "id": "${id}",
      "type": "${type}"
    }],
    "condition": {
      "attrs": ["temperature", "humidity", "open_status", "open_info"]
    }
  },
  "notification": {
    "http": {
      "url": "http://cygnus-postgresql:5055/notify"
    },
    "attrs": ["temperature", "humidity", "open_status", "open_info"],
    "attrsFormat": "legacy"
  }
}
__EOS__
  echo ""
done

kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://orion:1026/v2/subscriptions/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .
