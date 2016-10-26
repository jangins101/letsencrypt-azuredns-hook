# AzureDNS hook for `dehydrated` 

This is a hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/lukas2511/dehydrated) (previously known as `letsencrypt.sh`) that allows you to use [AzureDNS](https://azure.microsoft.com/en-us/services/dns/) DNS records to respond to `dns-01` challenges. Requires Bash and an existing SPN set up in Azure to authorize the DNS changes (instructions [here](https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/) or in the included [createSpn.sh](createSpn.sh) script).


## Installation

```
$ cd ~
$ git clone https://github.com/lukas2511/dehydrated
$ cd dehydrated
$ mkdir hooks
$ git clone https://github.com/jangins101/letsencrypt-azuredns-hook.git
```

## Configuration

In order for this hook script to work, you will need an existing service principal in the Azure ARM portal that has at least *Contributor* access to the DNS instance being used (see the [createSpn.sh](createSpn.sh) script for help creating this)

Make sure that you either export the necessary variables before running the hook script. Here are the values in use by the hook script (you can also find them in the [exportsTemplate.sh](exportsTemplate.sh) script):

```
export TENANT="<tenant name>.onmicrosoft.com"      # Your tenant name - the onmicrosoft.com value
export SPN_USERNAME="<spn uri id or guid>"         # This is one of the SPN values (the identifier-uri or guid value)
export SPN_PASSWORD="<password>"                   # This is the password associated with the SPN account 
export RESOURCE_GROUP="<resource group name>"      # This is the resource group containing your Azure DNS instance
export DNS_ZONE="<dns zone name>"                  # This is the DNS zone you want the SPN to manage (Contributor access)
export TTL="<time in seconds>"                     # This is the TTL for the dnz record-set
```

Alternatively, you could add these statements into the `dehydrated/config.sh` script, which should be automatically executed when `dehydrated` when is run. You can also add the variables (without the *export* modifier) into the hook script itself.


## Usage

```
$ ./dehydrated -c --config ./config.sh -d "www.example.com alt.example.com" -k ./azure.hook.sh
```