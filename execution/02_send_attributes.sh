#!/bin/bash

source $(cd $(dirname $0);pwd)/../variables/env.azure
source $(cd $(dirname $0);pwd)/../variables/env.fiware

## send attributes
HOST="${SERVICEBUS}.servicebus.windows.net"
PORT="5671"
len=$(echo ${ENTITIES} | jq '. | length')
for i in $( seq 0 $((${len} - 1)) ); do
  type=$(echo ${ENTITIES} | jq -r ".[$i].type")
  id=$(echo ${ENTITIES} | jq -r ".[$i].id")
  SEND_QUEUE="${type}.${id}.up"
  SENDER_USERNAME="device"
  SENDER_PASSWORD=$(az servicebus queue authorization-rule keys list --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --queue-name ${SEND_QUEUE} --name ${SENDER_USERNAME} | jq -r '.primaryKey')
  RECEIVE_QUEUE="${type}.${id}.down"
  RECEIVER_USERNAME="device"
  RECEIVER_PASSWORD=$(az servicebus queue authorization-rule keys list --resource-group ${RESOURCE_GROUP} --namespace-name ${SERVICEBUS} --queue-name ${RECEIVE_QUEUE} --name ${RECEIVER_USERNAME} | jq -r '.primaryKey')

  docker run -e AMQP_HOST=${HOST} -e AMQP_PORT=${PORT} \
    -e AMQP_SEND_QUEUE=${SEND_QUEUE} -e AMQP_SENDER_USERNAME=${SENDER_USERNAME} -e AMQP_SENDER_PASSWORD=${SENDER_PASSWORD} \
    -e AMQP_RECEIVE_QUEUE=${RECEIVE_QUEUE} -e AMQP_RECEIVER_USERNAME=${RECEIVER_USERNAME} -e AMQP_RECEIVER_PASSWORD=${RECEIVER_PASSWORD} \
    my/dummy_client:0.0.1 attrs
done
