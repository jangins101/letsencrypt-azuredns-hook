#!/usr/bin/env bash

#
# How to deploy a DNS challenge using Azure
#

# Debug Logging level
DEBUG=3

# Azure Tenant specific configuration settings
#   You should create an SPN in Azure first and authorize it to make changes to Azure DNS
#       REF: https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/
TENANT="<tenant name>.onmicrosoft.com"      # Your tenant name - the onmicrosoft.com value
SPN_USERNAME="<spn uri id or guid>"         # This is one of the SPN values (the identifier-uri or guid value)
SPN_PASSWORD="<password>"                   # This is the password associated with the SPN account
RESOURCE_GROUP="<resource group name>"      # This is the resource group containing your Azure DNS instance
DNS_ZONE="<dns zone name>"                  # This is the DNS zone you want the SPN to manage (Contributor access)


# Supporting functions
function log {
    if [ $DEBUG -ge $2 ]; then
        echo "$1" > /dev/tty
    fi
}
function login_azure {
    # Azure DNS Connection Variables
    # You should create an SPN in Azure first and authorize it to make changes to Azure DNS
    #  REF: https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/
    az login -u ${SPN_USERNAME} -p ${SPN_PASSWORD} --tenant ${TENANT} --service-principal > /dev/null
}
function parseSubDomain {
    log "  Parse SubDomain" 4

    FQDN="$1"
    log "    FQDN: '${FQDN}''" 4

    DOMAIN=`sed -E 's/(.*)\.(.*\..*$)/\2/' <<< "${FQDN}"`
    log "    DOMAIN: '${DOMAIN}'" 4

    SUBDOMAIN=`sed -E 's/(.*)\.(.*\..*$)/\1/' <<< "${FQDN}"`
    log "    SUBDOMAIN: '${SUBDOMAIN}'" 4

    echo "${SUBDOMAIN}"
}
function buildDnsKey {
    log "  Build DNS Key" 4

    FQDN="$1"
    log "    FQDN: '${FQDN}'" 4

    SUBDOMAIN=$(parseSubDomain ${FQDN})
    log "    SUBDOMAIN: ${SUBDOMAIN}" 4

    CHALLENGE_KEY="_acme-challenge.${SUBDOMAIN}"
    log "    KEY: '${CHALLENGE_KEY}'" 4

    echo "${CHALLENGE_KEY}"
}


# Logging the header
log "Azure Hook Script - LetsEncrypt" 4


# Execute the specified phase
PHASE="$1"
log "" 1
log "  Phase: '${PHASE}'" 1
#log "    Arguments: ${1} | ${2} | ${3} | ${4} | ${5} | ${6} | ${7} | ${8} | ${9} | ${10}" 1
case ${PHASE} in
    'deploy_challenge')
        login_azure

        # Arguments: PHASE; DOMAIN; TOKEN_FILENAME; TOKEN_VALUE
        FQDN="$2"
        TOKEN_VALUE="$4"
        SUBDOMAIN=$(parseSubDomain ${FQDN})
        CHALLENGE_KEY=$(buildDnsKey ${FQDN})

        # Commands
        log "" 4
        log "    Running azure cli commands" 4
        respCreate=$(az network dns record-set txt create -g ${RESOURCE_GROUP} -z ${DNS_ZONE} -n ${CHALLENGE_KEY} --output json)
        log "      Create: '$respCreate'" 4
        respAddRec=$(az network dns record-set txt add-record -g ${RESOURCE_GROUP} -z ${DNS_ZONE} -n ${CHALLENGE_KEY} -v ${TOKEN_VALUE} --output json)
        log "      AddRec: '$respAddRec'" 4
        ;;

    "clean_challenge")
        login_azure

        # Arguments: PHASE; DOMAIN; TOKEN_FILENAME; TOKEN_VALUE
        FQDN="$2"
        TOKEN_VALUE="$4"
        SUBDOMAIN=$(parseSubDomain ${FQDN})
        CHALLENGE_KEY=$(buildDnsKey ${FQDN})

        # Commands
        log "" 4
        log "    Running azure cli commands" 4
        respDel=$(az network dns record-set txt delete -g ${RESOURCE_GROUP} -z ${DNS_ZONE} -n ${CHALLENGE_KEY} -y --output json)
        log "      Delete: '$respDel'" 4
        ;;

    "deploy_cert")
        # Parameters:
        # - PHASE           - the phase being executed
        # - DOMAIN          - the domain name (CN or subject alternative name) being validated.
        # - KEY_PATH        - the path to the certificate's private key file
        # - CERT_PATH       - the path to the certificate file
        # - FULL_CHAIN_PATH - the path to the full chain file
        # - CHAIN_PATH      - the path to the chain file
        # - TIMESTAMP       - the timestamp of the deployment

        # do nothing for now
        ;;

    "unchanged_cert")
        # Parameters:
        # - PHASE           - the phase being executed
        # - DOMAIN          - the domain name (CN or subject alternative name) being validated.
        # - KEY_PATH        - the path to the certificate's private key file
        # - CERT_PATH       - the path to the certificate file
        # - FULL_CHAIN_PATH - the path to the full chain file
        # - CHAIN_PATH      - the path to the chain file

        # do nothing for now
        ;;

    *)
        #log "Unknown hook '${PHASE}'" 1
        exit 0
        ;;
esac

exit 0
