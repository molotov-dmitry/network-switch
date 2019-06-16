#!/bin/bash

#### Get ethernet interface name ===============================================

ethernet_info=$(LC_ALL=C nmcli device status | grep ' ethernet ' | head -n1 | tr -s '[:space:]' | cut -d ' ' -f 1,3)

ethernet_name=${ethernet_info%\ *}

#### Get action ================================================================

case "$1" in

wifi|wi-fi|wan)

    ethernet_state=connected
    ;;

eth|ethernet|lan|local)
    
	ethernet_state=disconnected
    ;;

"")

    ethernet_state=${ethernet_info#*\ }
    ;;

*)

    exit 1
    ;;

esac

unset ethernet_info

#### Change network ============================================================

case "$ethernet_state" in

disconnected)

	nmcli radio wifi off
    nmcli device connect ${ethernet_name}
	;;

connected)

	nmcli device disconnect ${ethernet_name}
	nmcli radio wifi on
	;;

esac

