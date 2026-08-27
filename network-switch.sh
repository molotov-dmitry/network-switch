#!/bin/bash

readonly CONFIG_FILE='/etc/network-switch/network-switch.conf'

#### Get ethernet interface name ===============================================

#### Check config file -----------------------------------------------------

if [[ -f "${CONFIG_FILE}" ]]
then
    lan_mac=$(grep '^lan=' "${CONFIG_FILE}" | cut -d '=' -f 2)
    if [[ -n "${lan_mac}" ]]
    then
        lan_device="$(ip -o link | grep -i "${lan_mac}" | cut -d ' ' -f 2 | tr -d ':')"
    fi
    
    wan_mac=$(grep '^wan=' "${CONFIG_FILE}" | cut -d '=' -f 2)
    if [[ -n "${wan_mac}" ]]
    then
        wan_device="$(ip -o link | grep -i "${wan_mac}" | cut -d ' ' -f 2 | tr -d ':')"
    fi
fi

#### Get first ethernet device as lan device -----------------------------------

if [[ -z "${lan_device}" ]]
then
    lan_device="$(nmcli -t -f DEVICE,STATE,TYPE device status | grep ':ethernet$' | grep -v ':unavailable:ethernet$' | head -n1 | cut -d ':' -f 1)"
fi

#### Check LAN device found ----------------------------------------------------

if [[ -z "${lan_device}" ]]
then
    notify-send -i network-wired-unavailable 'LAN device not found'
    exit 1
fi

#### Get action ================================================================

case "$1" in

wifi|wi-fi|wan)

    lan_state=connected
    ;;

eth|ethernet|lan|local)
    
    lan_state=disconnected
    ;;

"")

    lan_state="$(nmcli -t -g GENERAL.STATE device show "${lan_device}" | cut -d '(' -f 2 | cut -d ')' -f 1)"
    ;;

*)

    exit 1
    ;;

esac

unset ethernet_info

#### Check wi-fi adapter connected =============================================

if [[ -z "${wan_device}" && "${lan_state}" == 'connected' ]]
then
    if [[ -z "$(LC_ALL=C nmcli device status | grep ' wifi ')" ]]
    then
        notify-send -i network-wireless-disconnected 'Wi-Fi adapter not connected'
        exit 1
    fi
fi

#### Change network ============================================================

case "${lan_state}" in

disconnected)

    if [[ -z "${wan_device}" ]]
    then
        nmcli radio wifi off
    else
        nmcli device disconnect ${wan_device}
    fi
    
    nmcli device connect ${lan_device}
    ;;

connected)

    nmcli device disconnect ${lan_device}
    
    if [[ -z "${wan_device}" ]]
    then
        nmcli radio wifi on
    else
        nmcli device connect ${wan_device}
    fi
    
    ;;
    
*)

    notify-send -i network-wired-available "Unknown LAN device state: '${lan_state}'"
    

esac
