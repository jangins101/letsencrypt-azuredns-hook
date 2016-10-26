#!/usr/bin/env bash

#
# How to deploy a DNS challenge using Azure
#

# Debug Logging level
DEBUG=4

# Supporting functions
function log {
    if [ $DEBUG -ge $2 ]; then
        echo $1 > /dev/tty
    fi
}
function login_azure {
    # Azure DNS Connection Variables
    # You should create an SPN in Azure first and authorize it to make changes to Azure DNS
    #  REF: https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/
    azure login -u ${SPN_USERNAME} -p ${SPN_PASSWORD} --tenant ${TENANT} --service-principal --quiet > /dev/null
}
function parseSubDomain {
    log "  Parse SubDomain" 3

    local FQDN="$1"
    log "    FQDN: '${FQDN}''" 3

    local DOMAIN=`sed -E 's/(.*)\.(.*\..*$)/\2/' <<< "${FQDN}"`
    log "    DOMAIN: '${DOMAIN}'" 4

    local SUBDOMAIN=`sed -E 's/(.*)\.(.*\..*$)/\1/' <<< "${FQDN}"`
    log "    SUBDOMAIN: '${SUBDOMAIN}'" 3

    echo "${SUBDOMAIN}"
}
function buildDnsKey {
    log "  Build DNS Key" 3

    local FQDN="$1"
    log "    FQDN: '${FQDN}'" 3

    local SUBDOMAIN=$(parseSubDomain ${FQDN})
    log "    SUBDOMAIN: ${SUBDOMAIN}" 3

    local CHALLENGE_KEY="_acme-challenge.${SUBDOMAIN}"
    log "    KEY: '${CHALLENGE_KEY}'" 3

    echo "${CHALLENGE_KEY}"
}

log "Azure Hook Script - LetsEncrypt" 2

# Variables parsed from arguments
# Parameters:
# - PHASE           - Phase being executed
# - DOMAIN          - Domain name (CN or subject alternative name) being validated
# - TOKEN_FILENAME  - HTTP validation filename (/.well-known/acme-challenge/${TOKEN_FILENAME})
# - TOKEN_VALUE     - Validation token value
#                       HTTP - Should be the content of the token file
#                       DNS  - Should be the value of the '_acme-challenge' (_acme-challenge.<HOST>) TXT record
#log "  Arguments: ${1} | ${2} | ${3} | ${4}"
#FQDN="$2"
#SUDB=`sed -E 's/(.*)\.${DNS_ZONE}' <<< ${FQDN}`
#SUBD=`sed -E 's/(.*)\.(.*)\.(.*)/\1/' <<< "${FQDN}"`
#SLD=`sed -E 's/(.*\.)*([^.]+)\..*/\2/' <<< "${FQDN}"`
#TLD=`sed -E 's/.*\.([^.]+)/\1/' <<< "${FQDN}"`
#dChallenge="_acme-challenge.${SUBD}"
#TOKEN_VALUE="$4"
#log "    FQDN: $2" 3
#log "    SUBD: ${SUBD}" 3
#log "    SLD:  ${SLD}" 3
#log "    TLD:  ${TLD}" 3
#log "    Challenge host: ${dChallenge}" 3
#log "    Token: ${TOKEN_VALUE}" 3

# Execute the specified phase
local PHASE="$1"
log "  Phase: '${PHASE}'" 1
#log "  Phase: '$1'" 1
case ${PHASE} in
    'deploy_challenge')
        login_azure

        # Arguments: PHASE; DOMAIN; TOKEN_FILENAME; TOKEN_VALUE
        local FQDN="$2"
        local TOKEN_VALUE="$4"
        local SUBDOMAIN=$(parseSubDomain ${FQDN})
        local CHALLENGE_KEY=$(buildDnsKey ${$FQDN})

        # Commands
        log "" 4
        log "    Running azure cli commands" 4
        #respShow=$(azure network dns record-set show -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n ${CHALLENGE_KEY} --json)
        #log "      Show:   '$respShow'" 4
        respCreate=$(azure network dns record-set create -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n ${CHALLENGE_KEY} --ttl ${TTL} --json)
        log "      Create: '$respCreate'" 4
        respAddRec=$(azure network dns record-set add-record -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n ${CHALLENGE_KEY} --text ${TOKEN_VALUE} --json)
        log "      AddRec: '$respAddRec'" 4
        ;;

    "clean_challenge")
        login_azure

        # Arguments: PHASE; DOMAIN; TOKEN_FILENAME; TOKEN_VALUE
        local FQDN="$2"
        local TOKEN_VALUE="$4"
        local SUBDOMAIN=$(parseSubDomain ${FQDN})
        local CHALLENGE_KEY=$(buildDnsKey ${$FQDN})

        # Commands
        log "" 4
        log "    Running azure cli commands" 4
        respDel=$(azure network dns record-set delete -g ${RESOURCE_GROUP} -z ${DNS_ZONE} --type TXT -n ${CHALLENGE_KEY} -q --json)
        log "      Delete: '$respDel'" 4
        ;;

    "deploy_cert")
        # do nothing for now
        log "  Arguments: ${1} | ${2} | ${3} | ${4} | ${5}" 1
        ;;

    "unchanged_cert")
        # Parameters:
        # - PHASE         - the phase being executed
        # - DOMAIN        - the domain name (CN or subject alternative name) being validated.
        # - KEY_PATH      - the path to the certificate's private key file
        # - CERT_PATH     - the path to the certificate files

        # do nothing for now
        ;;

    *)
        log "Unknown hook '${1}'" 1
        exit 1
        ;;
esac

exit 0
