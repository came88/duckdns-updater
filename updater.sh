#!/bin/sh

if [ -z "$DEBUG" ] || [ "$DEBUG" -eq "0" ]
then
    log_debug() {
        true;
    }
else
    log_debug() {
        echo $(date) "$@"
    }
fi
log_info() {
    echo $(date) "$@"
}

if [ -z "$DOMAIN" ]
then
    echo "ERROR: DOMAIN variable is empty"
    exit 1;
fi

if [ -z "$TOKEN" ]
then
    echo "ERROR: TOKEN variable is empty"
    exit 1;
fi

log_debug "Ensuring domain is a FQDN"
echo $DOMAIN | egrep -qi "\.duckdns\.org$" || DOMAIN="${DOMAIN}.duckdns.org"
log_debug "DOMAIN: $DOMAIN"

trap_sigterm() {
    log_info "Terminating..."
    exit 0;
}

trap "trap_sigterm" TERM

get_ip_opendns() {
    log_debug "Get current external IP from opendns"
    DEVICE_IP=$(dig +short @resolver1.opendns.com ANY myip.opendns.com 2>/dev/null | grep -v ';' )
    log_debug "DEVICE_IP: $DEVICE_IP"
    test -n "$DEVICE_IP";
    return $?;
}
get_ip_akamai() {
    log_debug "Get current external IP from akamai"
    DEVICE_IP=$(dig +short @ns1-1.akamaitech.net ANY whoami.akamai.net 2>/dev/null | grep -v ';' )
    log_debug "DEVICE_IP: $DEVICE_IP"
    test -n "$DEVICE_IP";
    return $?;
}
get_ip_google() {
    log_debug "Get current external IP from google DNS"
    DEVICE_IP=$(dig +short @ns1.google.com TXT o-o.myaddr.l.google.com 2>/dev/null | grep -v ';' | tr -d '"' )
    log_debug "DEVICE_IP: $DEVICE_IP"
    test -n "$DEVICE_IP";
    return $?;
}

do_sleep() {
    log_debug "Sleeping for $@ seconds"
    # interrupt on external signal
    sleep "$@" &
    wait $!
}

while true
do
    get_ip_opendns || get_ip_akamai || get_ip_google || log_info "Unable to get current IP address."

    DNS_IP=$(dig +short $DOMAIN A 2>/dev/null | grep -v ';' )
    log_debug "DNS_IP: $DNS_IP"

    if [ -z "$DEVICE_IP" ] || [ "$DEVICE_IP" != "$DNS_IP" ]
    then
        log_info "Updating IP..."
        RESULT=$(curl -s -q -f "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$DEVICE_IP" )
        STATUS=$?
        log_debug "Curl exit code: $STATUS"
        log_debug "Curl output: $RESULT"
        if [ $STATUS -eq 0 ]
        then
            log_info "Updated!"
            do_sleep $TIME_UPDATE
        else
            log_info "Error updating IP"
            do_sleep $TIME_CHECK
        fi
    else
        log_debug "No need to update"
        do_sleep $TIME_CHECK
    fi
done