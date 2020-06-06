#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure

## start postgres
az postgres server create --resource-group ${RESOURCE_GROUP} --name ${PG}  --location ${LOCATION} --admin-user ${PG_ADMIN} --admin-password ${PG_ADMIN_PASSWORD} --sku-name ${PG_SKU} --version ${PG_VERSION}
VNET=$(az network vnet list --resource-group MC_${RESOURCE_GROUP}_${AKS}_${LOCATION} --output json)
VNET_NAME=$(echo ${VNET} | jq -r '.[0].name')
SUBNET_NAME=$(echo ${VNET} | jq -r '.[0].subnets[0].name')
SUBNET_ID=$(echo ${VNET} | jq -r '.[0].subnets[0].id')
az network vnet subnet update --resource-group MC_${RESOURCE_GROUP}_${AKS}_${LOCATION} --name ${SUBNET_NAME} --vnet-name ${VNET_NAME} --service-endpoints Microsoft.SQL
sleep 30
az postgres server vnet-rule create --resource-group ${RESOURCE_GROUP} --server-name ${PG} --name ${PG}_rule --subnet ${SUBNET_ID}
