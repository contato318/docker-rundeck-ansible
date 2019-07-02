#!/usr/bin/env bash
set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}


#############################################
# WORKAROUND - unknown authority (registry) #
#############################################
#Explicit is better than implicit.
file_env 'REGISTRY_ADDRESS'
file_env 'REGISTRY_PORT' 443
if [ -n "$REGISTRY_ADDRESS" ]; then
      #copy ca
      #echo "REGISTRY_ADDRESS $REGISTRY_ADDRESS"
      #echo "REGISTRY_PORT $REGISTRY_PORT"
      true|openssl s_client -connect $REGISTRY_ADDRESS:$REGISTRY_PORT 2>/dev/null|openssl x509 > /usr/local/share/ca-certificates/$REGISTRY_ADDRESS.crt
      update-ca-certificates --fresh >/dev/null
fi

#############################################
# WORKAROUND - unknown authority (gitlab) #
#############################################
#Explicit is better than implicit.
file_env 'GITLAB_ADDRESS'
file_env 'GITLAB_PORT' 443
if [ -n "$GITLAB_ADDRESS" ]; then
      #copy ca
      true|openssl s_client -connect $GITLAB_ADDRESS:$GITLAB_PORT 2>/dev/null|openssl x509 > /usr/local/share/ca-certificates/$GITLAB_ADDRESS.crt
      update-ca-certificates --fresh >/dev/null
fi


#CONFIGURE KUBE_CONFIG
file_env 'KUBE_CONFIG'
if [ -n "$KUBE_CONFIG" ]; then
      mkdir -p $HOME/.kube
      echo -n $KUBE_CONFIG | base64 -d > $HOME/.kube/config
fi
