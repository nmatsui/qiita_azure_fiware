#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure

## start aks
az aks create --resource-group ${RESOURCE_GROUP} --name ${AKS} --node-count ${NODE_COUNT} --node-vm-size ${NODE_VM_SIZE} --generate-ssh-keys --kubernetes-version ${AKS_VERSION}
sleep 30
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS} --overwrite-existing
