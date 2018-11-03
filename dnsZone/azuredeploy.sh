#!/bin/bash

SUBSCRIPTIONID=93f66d58-xxxx-xxxx-xxxx-911a88e6074c
RESOURCEGROUP=rg-xxxx-dns
LOCATION=westeurope
DOMAIN=yyyy.xxxx.yyy

az account set -s $SUBSCRIPTIONID
if [ $(az group exists --name $RESOURCEGROUP) == "false" ]; then
    az group create --name $RESOURCEGROUP --location $LOCATION
fi

az group deployment create -g $RESOURCEGROUP --template-file azuredeploy.json --parameters @azuredeploy.parameters.json

echo "Confgure the domain $DOMAIN with the following NS records:"
az network dns record-set ns list -g $RESOURCEGROUP -z $DOMAIN --query "[?name == '@'].nsRecords" -o yaml