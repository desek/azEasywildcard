#!/bin/bash

SUBSCRIPTIONID=93f66d58-xxxx-xxxx-xxxx-911a88e6074c
RESOURCEGROUP=rg-xxxx-acme
LOCATION=westeurope
DOMAIN=yyyy.xxxx.yyy
ACRNAME=crxxxxref
KV=kv-xxxx-ref

# Variables
SANAME=sacme${DOMAIN//./}
ACMESHARE=${DOMAIN//./-}
DOCKERIMAGE=$ACRNAME.azurecr.io/$DOMAIN/easywildcard
ACINAME=easywildcard
SP=aci-$ACMESHARE

az account set -s $SUBSCRIPTIONID
if [ $(az group exists --name $RESOURCEGROUP) == "false" ]; then
    az group create --name $RESOURCEGROUP --location $LOCATION --verbose
fi

if [ $(az storage account check-name -n $SANAME --query 'nameAvailable') == "true" ]; then
    az storage account create -g $RESOURCEGROUP -n $SANAME --sku Standard_LRS --https-only true --kind StorageV2 --https-only true --location $LOCATION --verbose
fi

SAKEY=$(az storage account keys list -g $RESOURCEGROUP -n $SANAME --query "[0].value" | tr -d '"')
if [ $(az storage share exists -n logs --account-name $SANAME --account-key $SAKEY --query 'exists') == "false" ]; then
    az storage share create -n logs --account-name $SANAME --account-key $SAKEY
fi
if [ $(az storage share exists -n $ACMESHARE --account-name $SANAME --account-key $SAKEY --query 'exists') == "false" ]; then
    az storage share create -n $ACMESHARE --account-name $SANAME --account-key $SAKEY
fi

###
# User Assigned Managed Service Identity (Not yet supported for ACI to use identity for Container Registry pulls)
#
# MSI=easywildcard
# if [ ! $(az identity show -n $MSI -g $RESOURCEGROUP --query name) ] ; then
#    az identity create -n $MSI -g $RESOURCEGROUP -l $LOCATION
# fi
# az role assignment create --role Reader --assignee-object-id $(az identity show -n $MSI -g $RESOURCEGROUP --query principalId -o tsv) --scope $(az acr show -n $ACRNAME --query id -o tsv)
###

# Create Service Principal and store password
SPPWD=$(az ad sp create-for-rbac -n $SP --skip-assignment --query password -o tsv)
echo $SPPWD
# Get Service Principal Application ID (GUID)
echo "Sleeping 30 seconds for Azure AD to replicate"
sleep 30
SPID=$(az ad sp list --display-name $SP --query [0].appId -o tsv)
# Assign Reader role to Service Principal on Container Registry
az role assignment create --role Reader --assignee $SPID --scope $(az acr show -n $ACRNAME --query id -o tsv)
# Build Docker image into Container Registry
az acr build -r $ACRNAME --image $DOCKERIMAGE ./easywildcard
# Deploy ACI
az group deployment create -g $RESOURCEGROUP --template-file azuredeploy.json --parameters @azuredeploy.parameters.json --parameters spId=$SPID spPwd=$SPPWD --verbose

echo "Sleeping 180 seconds for Easywildcard to run."
sleep 180

# Create folders and download certificates
if [[ ! -e ./certs/$DOMAIN ]]; then
    mkdir -p ./certs/$DOMAIN
fi
ACMESHAREFQDN=https://$SANAME.file.core.windows.net/$ACMESHARE
az storage file download-batch --source $ACMESHAREFQDN --destination ./certs/$DOMAIN --account-name $SANAME --account-key $SAKEY

# Convert pem certificates to pfc
openssl pkcs12 -export -out ./certs/$DOMAIN.pfx -in ./certs/$DOMAIN/archive/$DOMAIN/cert1.pem -inkey ./certs/$DOMAIN/archive/$DOMAIN/privkey1.pem -passout pass:

KVID=$(az keyvault show -n $KV --query id -o tsv)
TENANTID=$(az account show -s $SUBSCRIPTIONID --query tenantId -o tsv)
echo "Deep link to Azure Key Vault:"
echo "https://portal.azure.com/#@${TENANTID}/resource${KVID}/secrets"
az keyvault certificate import -n $ACMESHARE --vault-name $KV -f ./certs/$DOMAIN.pfx

# Delete Service Principal
echo "Deleting Service Principal"
az ad sp delete --id $SPID --verbose

# Delete ACI
echo "Deleting ACI"
az container delete -n $ACINAME -g $RESOURCEGROUP -y --verbose