# Description
Creates a storage account with file shares for storing certbot file strucuture and logs
Creates a service principal and assigns reader access to Container Registry
Deploy a container with slightly modified easywildcard to take Azure Files and DNS propagation times into account
Downloads certificates localy and converts to pfx
Uploads PFX to Azure Key Vault
Removes SP and ACI

# Setup
Configure parameters in both `azuredeploy.sh` and `azuredeploy.parameters.json`.

# Convert PEM certificates to PFX
DOMAIN=ref.gigant.io
openssl pkcs12 -export -out $DOMAIN.pfx -in cert1.pem -inkey privkey1.pem