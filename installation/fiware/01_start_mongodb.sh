#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.fiware
CWD=$(cd $(dirname $0);pwd)

## start mongodb
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm install stable/mongodb-replicaset --name-template mongodb -f ${CWD}/yaml/mongodb-replicaset-values-aks.yaml
