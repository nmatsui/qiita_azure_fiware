#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure

## create resource group
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
