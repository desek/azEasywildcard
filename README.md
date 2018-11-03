Easymode for [Let's Encrypt](https://letsencrypt.org/) wildcard certificates by using Azure and [easywildcard](https://github.com/Fmstrat/easywildcard).
The process should take less than 10 minutes end-to-end.

# Lack of functionality
* Renew certificates
* Use of existing Service Principals

# Usage
Modify parameters in `azuredeploy.parameters.json` and `azuredeploy.sh` in each directory. It will get repetitive. :)
Run `azuredeploy.sh` from the root directory.

# Wishlist
* Better support for User Assigned Managed Service Identity (reaplce Service Principal)
* Manage Azure DNS from Container Instance (replace BIND)
* Upload Certificates to Key Vault directly from ACI