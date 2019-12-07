#!/bin/bash

set -e

###############################################################################
## Constants
###############################################################################

readonly EC2_NAME='private-vpn'

###############################################################################
## Constants
###############################################################################

main() {
    while getopts ":h" o; do
        case "${o}" in
            h)
                usage "$@"
                return 0
                ;;
            *)
                usage "$@"
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ "${1}" = "help" ] || [ "${1}" = "--help" ]; then
        usage
        return 0
    fi

    if [ "${1}" = "start" ]; then
        start_vpn
        return 0
    fi
    if [ "${1}" = "stop" ]; then
        stop_vpn
        return 0
    fi
    if [ "${1}" = "status" ]; then
        echo "$(instance_state)"
        return 0
    fi

    usage
    return 1
}

###############################################################################
## Functions
###############################################################################

usage() {
    echo "Usage: $0 [-h|--help] [start | stop | status]" 1>&2
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo ""
    echo "    Actions:"
    echo "        start"
    echo "            Starts the private VPN EC2 server."
    echo "        stop"
    echo "            Stops the private VPN EC2 server."
    echo "        status"
    echo "            Prints the status of the VPN EC2 server."
    exit 1
}

instance_state() {
    aws ec2 describe-instances \
        --profile personal \
        --region us-east-1 \
        --output text \
        --filters 'Name=tag:Name,Values=private-vpn' \
        --query 'Reservations[0].Instances[0].State.Name'
}

instance_id() {
    aws ec2 describe-instances \
        --profile personal \
        --region us-east-1 \
        --output text \
        --filters 'Name=tag:Name,Values=private-vpn' \
        --query 'Reservations[0].Instances[0].InstanceId'
}

start_vpn() {
    aws ec2 start-instances \
        --region us-east-1 \
        --profile personal \
        --instance-ids "$(instance_id)" > /dev/null
}

stop_vpn() {
    aws ec2 stop-instances \
        --region us-east-1 \
        --profile personal \
        --instance-ids "$(instance_id)" > /dev/null
}

###############################################################################
## Entry Point
###############################################################################

main "${@}"
