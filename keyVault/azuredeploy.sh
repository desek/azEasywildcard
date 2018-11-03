#!/bin/bash

SUBSCRIPTIONID=93f66d58-xxxx-xxxx-xxxx-911a88e6074c
RESOURCEGROUP=rg-xxxx-kv
LOCATION=westeurope

az account set -s $SUBSCRIPTIONID
if [ $(az group exists --name $RESOURCEGROUP) == "false" ]; then
    az group create --name $RESOURCEGROUP --location $LOCATION --verbose
fi

az group deployment create -g $RESOURCEGROUP --template-file azuredeploy.json --parameters @azuredeploy.parameters.json --verbose