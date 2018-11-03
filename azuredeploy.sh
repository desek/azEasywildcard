#!/bin/bash

echo "Deploying Azure DNS"
cd dnsZone/
./azuredeploy.sh
read -rsp $'Configure DNS and press any key continue...\n' -n1 key
cd ..

echo "Deploying Container Registry"
cd containerRegistry/
./azuredeploy.sh
cd ..

echo "Deploying Key Vault"
cd containerRegistry/
./azuredeploy.sh
cd ..

echo "Deploying Easywildcard on Container Instances"
cd aci-easywildcard/
./azuredeploy.sh
cd ..