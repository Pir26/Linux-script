#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : init.sh
#
# Description : this script create a folder named with the given argument. Then create 2 files inside : README.md and change.log 
#		Then the script display the content of the new folder
#
# Input : name of the folder to create 
#
# Output : see description
#
####################

# Display the script name and script path
echo "Nom :" $(basename $0)
echo "Chemin :"  $(dirname $0)

# Check if folder exists
if [ -d $1 ]; then
	echo "Le répertoire existe déjà. Choisissez-en un autre."
elif mkdir $1; then
	if [ -d $1 ]; then
		touch ./${1}/README.md 
		if [ "$?" -ne 0 ]; then 
			echo "Erreur lors de la création du fichier ./"$1"/README.md"
		fi
		touch ./${1}/change.log
                if [ "$?" -ne 0 ]; then 
                        echo "Erreur lors de la création du fichier ./"$1"/change.log"
                fi
		ls -la $1
	fi
	#$result=${?}
	#echo $result
else
	echo "Erreur lors de la création du répertoire ./"$1
fi

#        if [[ $input ]] && [ $input -eq $input 2>/dev/null ] && [[ $input -ne 0 ]] 
