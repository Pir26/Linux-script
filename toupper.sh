#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : toupper.sh
#
# Description : 
#
# Input : 1 to n arguments
#
# Output : display arguments 
#
####################

# echo -n => display argument without EOL
for i in $@; do :
	echo  -n "${i^^} "
done
# EOL
echo
