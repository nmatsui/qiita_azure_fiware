#!/bin/bash
source $(cd $(dirname $0);pwd)/../../variables/env.azure

## login azure
az login --tenant ${TENANT}
