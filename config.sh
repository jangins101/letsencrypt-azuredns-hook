########################################################
# This is the main config file for dehydrated          #
#                                                      #
# This file is looked for in the following locations:  #
# $SCRIPTDIR/config (next to this script)              #
# /usr/local/etc/dehydrated/config                     #
# /etc/dehydrated/config                               #
# ${PWD}/config (in current working-directory)         #
#                                                      #
# Default values of this config are in comments        #
########################################################

# Resolve names to addresses of IP version only. (curl)
# supported values: 4, 6
# default: <unset>
#IP_VERSION=

# Path to certificate authority (default: https://acme-v01.api.letsencrypt.org/directory)
#CA="https://acme-v01.api.letsencrypt.org/directory"
CA="https://acme-staging-v02.api.letsencrypt.org/directory"

# Path to license agreement (default: https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf)
#LICENSE="https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf"

# Which challenge should be used? Currently http-01 and dns-01 are supported
#CHALLENGETYPE="http-01"
CHALLENGETYPE="dns-01"

# Path to a directory containing additional config files, allowing to override
# the defaults found in the main configuration file. Additional config files
# in this directory needs to be named with a '.sh' ending.
# default: <unset>
#CONFIG_D=

# Base directory for account key, generated certificates and list of domains (default: $SCRIPTDIR -- uses config directory if undefined)
#BASEDIR=$SCRIPTDIR
BASEDIR=/var/tmp/letsencrypt

# File containing the list of domains to request certificates for (default: $BASEDIR/domains.txt)
#DOMAINS_TXT="${BASEDIR}/domains.txt"

# Output directory for generated certificates
CERTDIR="${BASEDIR}/certs"

# Directory for account keys and registration information
ACCOUNTDIR="${BASEDIR}/accounts"

# Output directory for challenge-tokens to be served by webserver or deployed in HOOK (default: /var/www/dehydrated)
#WELLKNOWN="/var/www/dehydrated"

# Default keysize for private keys (default: 4096)
KEYSIZE="4096"

# Path to openssl config file (default: <unset> - tries to figure out system default)
#OPENSSL_CNF=

# Program or function called in certain situations
#
# After generating the challenge-response, or after failed challenge (in this case altname is empty)
# Given arguments: clean_challenge|deploy_challenge altname token-filename token-content
#
# After successfully signing certificate
# Given arguments: deploy_cert domain path/to/privkey.pem path/to/cert.pem path/to/fullchain.pem
#
# BASEDIR and WELLKNOWN variables are exported and can be used in an external program
# default: <unset>
HOOK="${BASEDIR}/azure.hook.sh"

# Chain clean_challenge|deploy_challenge arguments together into one hook call per certificate (default: no)
#HOOK_CHAIN="no"

# Minimum days before expiration to automatically renew certificate (default: 30)
#RENEW_DAYS="30"

# Regenerate private keys instead of just signing new certificates on renewal (default: yes)
#PRIVATE_KEY_RENEW="yes"

# Create an extra private key for rollover (default: no)
#PRIVATE_KEY_ROLLOVER="no"

# Which public key algorithm should be used? Supported: rsa, prime256v1 and secp384r1
#KEY_ALGO=rsa

# E-mail to use during the registration (default: <unset>)
#CONTACT_EMAIL=

# Lockfile location, to prevent concurrent access (default: $BASEDIR/lock)
#LOCKFILE="${BASEDIR}/lock"

# Option to add CSR-flag indicating OCSP stapling to be mandatory (default: no)
#OCSP_MUST_STAPLE="no"
