#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : type.sh
#
# Description : read a string and return if there are any vowel, consonant or/and number
#
# Input : string
#
# Output : Voyelle ou/et Consonne ou/et Chiffre 
#
####################

# Convert input string into lowercase characters without accent for easy check  
string=$(echo ${1,,} | sed 'y/áÁâÂàÀåÅãÃäÄçÇéÉêÊèÈëËíÍîÎìÌïÏñÑóÓôÔòÒøØõÕöÖšŠúÚûÛùÙüÜýÝÿŸ/aaaaaaaaaaaacceeeeeeeeiiiiiiiinnoooooooooooossuuuuuuuuyyyy/')

# Check if argument is valid (a single integer)
if [ "$#" -ne 1 ]; then
	echo "Veuillez entrer en argument une chaine de caractères"
else 
	if [[ $string =~ .*[aeiouy]+.* ]]; then
		echo "Voyelle"
	fi
        if [[ $string =~ .*[b-df-hj-np-tv-xz]+.* ]]; then
                echo "Consonne" 
        fi
        if [[ $string =~ .*[0-9]+.* ]]; then
                echo "Chiffre" 
        fi
fi
