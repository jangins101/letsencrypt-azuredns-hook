# This script will automate creating the SPN necessary for scripted login into Azure.
#   Please update the variables as necessary prior to running the script
#   REF: https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/

# User specified values
TENANT="<tenant name>.onmicrosoft.com"      # Your tenant name - the onmicrosoft.com value
APP_NAME="letsencrypt-admin-spn"            # This is what you want the application connected to the SPN to be called
PASSWORD="<password>"                       # This will be the password for the SPN account
SPN="<identifier-uri>"                      # This will be the URI identifier for the SPN (e.g. https://letsencrypt-admin-spn.local)
RESOURCE_GROUP="<resource group name>"      # This is the resource group containing your Azure DNS instance
DNS_ZONE="<dns zone name>"                  # This is the DNS zone you want the SPN to manage (Contributor access)

# Login to Azure using credentials that have Owner access to the subscription
azure login

# Create the application and service principal in a single command
azure ad sp create -n ${APP_NAME} -p ${PASSWORD} --home-page ${SPN} --identifier-uris ${SPN} --json

# Get the new app information
azure ad app show --identifierUri ${SPN} --json

# Get the new spn information
azure ad sp show --spn ${SPN} --json

# Grant the spn permissions to the subscription
azure role assignment create --spn ${SPN} -o Contributor -g ${RESOURCE_GROUP} -r "Microsoft.Network/dnszones" --json

# Test the login
azure login -u ${SPN} -p ${PASSWORD} --tenant ${TENANT} --service-principal --json

# Test CRUD access to the zone and record-sets
azure network dns zone list -g ${RESOURCE_GROUP} --json
azure network dns record-set list -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --json
azure network dns record-set create -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n TESTING --ttl 3600 --json
azure network dns record-set add-record -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n TESTING --text TEST --json
azure network dns record-set delete -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n TESTING --json

# Logout
azure logout
