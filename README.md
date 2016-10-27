# AzureDNS hook for `dehydrated` 

This is a hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/lukas2511/dehydrated) (previously known as `letsencrypt.sh`) that allows you to use [AzureDNS](https://azure.microsoft.com/en-us/services/dns/) DNS records to respond to `dns-01` challenges. Requires Bash and an existing SPN set up in Azure to authorize the DNS changes (instructions [here](https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/) or in the included [createSpn.sh](createSpn.sh) script).


## Installation

```
$ cd ~
$ git clone https://github.com/lukas2511/dehydrated
$ git clone https://github.com/jangins101/letsencrypt-azuredns-hook.git
$ cd dehydrated
```

## Configuration

In order for this hook script to work, you will need an existing service principal in the Azure ARM portal that has at least *Contributor* access to the DNS instance being used (see the [createSpn.sh](createSpn.sh) script for help creating this)

Make sure that you update the *tenant specific configuration variables* in the [azure.hook.sh](azure.hook.sh) script. These are the configuration settings that need to be changed in that file:

```
TENANT="<tenant name>.onmicrosoft.com"      # Your tenant name - the onmicrosoft.com value
SPN_USERNAME="<spn uri id or guid>"         # This is one of the SPN values (the identifier-uri or guid value)
SPN_PASSWORD="<password>"                   # This is the password associated with the SPN account 
RESOURCE_GROUP="<resource group name>"      # This is the resource group containing your Azure DNS instance
DNS_ZONE="<dns zone name>"                  # This is the DNS zone you want the SPN to manage (Contributor access)
TTL="<time in seconds>"                     # This is the TTL for the dnz record-set
```

## Usage

```
$ ./dehydrated -c -d "www.example.com alt.example.com" --config ../letsencrypt-azuredns-hook/config.sh -k ../letsencrypt-azuredns-hook/azure.hook.sh

```