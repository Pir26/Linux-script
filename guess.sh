#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : guess.sh
#
# Description : the script select a random integer (called mystery number) up to 1000.
#	Player has 10 attempts to find this mystery number.
#
# Input : none
#
# Output : display if the integer given by player is lower, equal to or higher than the mystery number. Up to 10 attempts.
#
####################

# Max attepmts 
attempNb=10
# Max number range
maxNb=1000

# Display the number of attemps before ending the game
displayAttemps()
{
if [ $1 -ne 0 ]
then
	echo "Il vous reste $1 essais."
else
	echo "Il ne vous reste plus d'essai !"
fi
}

# Select mystery number
mystery=$(($RANDOM%$maxNb+1))

echo "Taper un nombre entre 1 et 1000 pour trouver le nombre mystère."
echo "Vous avez $attempNb essais pour le trouver."

# Check if argument is valid (a single integer)
for (( i=1; i <= $attempNb; ++i ))
do
	read input
	# Check if input exists, is integer, is not null, is not over the range
	if [[ $input ]] && [ $input -eq $input 2>/dev/null ] && [[ $input -ne 0 ]] && [ "$input" -le "$maxNb" ] 
	then 
		if [[ $input -lt $mystery ]]
		then
			echo -n "Le nombre est plus grand."
			displayAttemps $((attempNb-i))
		elif  [[ $input -gt $mystery ]]
		then
			echo  -n "Le nombre est plus petit."
			displayAttemps $((attempNb-i))
		else
			echo "Bravo !!!"
			break
		fi
		if [[ $i -eq $attempNb ]]
		then
			echo "VOus avez perdu"
		fi
	else
	    	echo "Vous devez taper un nombre entre 1 et 1000"
		i=$((i-1))
	fi
done
