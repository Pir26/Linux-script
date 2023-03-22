#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : status.sh
#
# Description : display the status of the service given as argument
#
# Input : service name
#
# Output : service status
#
# Note : there is no control against the input service name. 
#
####################

systemctl list-units --type=service | grep $1 | awk '{ if($1) print "Service "$1" is "$3" and "$4".";}'

if ! systemctl list-units --type=service | grep $1 > /dev/null 2>&1 
then
	echo "Service $1 is not present."
fi
