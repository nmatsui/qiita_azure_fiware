#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.fiware

## register devices
cnt=0
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")

  kubectl run -i --rm --restart=OnFailure --image curlimages/curl curl$((++cnt)) -- \
    -i "http://iotagent-json:4041/iot/devices/" \
    -H "Fiware-Service: ${FIWARE_SERVICE}" \
    -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
    -H "Content-Type: application/json" \
    -X POST -d @- <<__EOS__
{
  "devices": [
    {
      "device_id": "${id}",
      "entity_name": "${id}",
      "entity_type": "${type}",
      "timezone": "Asia/Tokyo",
      "protocol": "json",
      "attributes": [
        {
          "name": "temperature",
          "type": "number"
        },
        {
          "name": "humidity",
          "type": "number"
        }
      ],
      "commands": [
        {
          "name": "open",
          "type": "command"
        }
      ],
      "transport": "HTTP",
      "endpoint": "http://localhost:3000/amqp10/cmd/${type}/${id}"
    }
  ]
}
__EOS__
done

kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://iotagent-json:4041/iot/devices/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .

kubectl run -i --rm --restart=OnFailure --quiet=true --image curlimages/curl curl$((++cnt)) -- \
  -sS "http://orion:1026/v2/entities/" \
  -H "Fiware-Service: ${FIWARE_SERVICE}" \
  -H "Fiware-ServicePath: ${FIWARE_SERVICEPATH}" \
| jq .
