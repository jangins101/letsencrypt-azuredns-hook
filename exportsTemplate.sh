# Be sure you export the following values (or include them in the hook script)

# User specified values
export TENANT="<tenant name>.onmicrosoft.com"      # Your tenant name - the onmicrosoft.com value
export SPN_USERNAME="<spn uri id or guid>"         # This is one of the SPN values (the identifier-uri or guid value)
export SPN_PASSWORD="<password>"                   # This is the password associated with the SPN account
export RESOURCE_GROUP="<resource group name>"      # This is the resource group containing your Azure DNS instance
export DNS_ZONE="<dns zone name>"                  # This is the DNS zone you want the SPN to manage (Contributor access)
export TTL="<time in seconds>"                     # This is the TTL for the dnz record-set
