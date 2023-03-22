#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : count.sh
#
# Description : count from 1 to the integer given in parameter and display the result
#
# Input : one integer
#
# Output : count from 1 to the integer given in parameter and display the result
#
####################


# Check if argument is valid (a single integer)
if [ "$#" -ne 1 ]; then
	echo "Veuillez entrer en argument un entier compris entre 1 et n"
elif ! [[ $1 =~ ^[0-9]+$ ]]; then
	echo "Veuillez entrer en argument un entier compris entre 1 et n" 
elif [[ $1 -eq 0 ]]; then
        echo "Veuillez entrer en argument un entier compris entre 1 et n" 
# and loop from 1 to the integer and display the result
else
	for (( i=1; i <= $1; ++i ))
	do
		echo "$i"
	done
fi

