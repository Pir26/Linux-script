#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : max.sh
#
# Description : display largest integer among 2
#
# Input : 2 integers
#
# Output : display the largest integer
#
####################


# Check if arguments are valid (2 integers)
if [ "$#" -ne 2 ]; then
	echo "Veuillez entrer en argument deux entiers compris entre 1 et n"
elif ( ! [[ $1 =~ ^[0-9]+$ ]] || ! [[ $2 =~ ^[0-9]+$ ]] ); then
	echo "Veuillez entrer en argument deux entiers compris entre 1 et n" 
# loop from 1 to the input integer
else
	printf "%s\n" "$@" | sort -n | tail -1
fi
