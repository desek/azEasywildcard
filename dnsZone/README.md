# Description
Creates an Azure DNS zone with CAA record for Let's Encrypt and ACME records for [Easywildcard](https://github.com/Fmstrat/easywildcard)

# Setup
Modify parameters in both `azuredeploy.sh` and `azuredeploy.parameters.json`.
azuredeploy.sh contains parameters for subcription, resource group and location.
azuredeploy.parameters.json contains parameters required for the resource deployments.