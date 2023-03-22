#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : params.sh
#
# Description : display the name of the script, the path of the script and each parameter given as input 
#
# Input : 0 to n parameters
#
# Output : see description
#
####################

# Display the script name and script path
echo "Nom :" $(basename $0)
echo "Chemin :"  $(dirname $0)

# Display input parameters
i=1
for var in "$@"
do
    	echo "Argument "$i ": "$var
	i=$((i+1))
done
