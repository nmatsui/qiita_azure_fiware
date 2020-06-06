#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.fiware
CWD=$(cd $(dirname $0);pwd)

## start orion
kubectl apply -f ${CWD}/yaml/orion-service.yaml
kubectl apply -f ${CWD}/yaml/orion-deployment.yaml
