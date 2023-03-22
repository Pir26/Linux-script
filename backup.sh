#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 20/03/2023
#
# Script : backup.sh
#
# Description : save each file of the current directory in a backup file named .bak only if backup file doesn't exist.
#	Note : hidden files are not saved
# Input : none
#
# Output : see description
#
####################

# directory to check
directoryToBackup="./"


numberOfSavedFile=0
# for each element in the directory
for entry in "$directoryToBackup"*
do
	# only for file without .bak extension
  	if [ -f "$entry" ] && ! [[ $entry =~ .*.bak$ ]]; then 
		# and only if file with .bak extension doesn't exist for that file  
    		if ! [ -f "$entry.bak" ]; then
			cp $entry $entry.bak
			if [ "$?" -eq 0 ]; then
				numberOfSavedFile=$((numberOfSavedFile+1))
			fi
		fi 
	fi
done
echo "$numberOfSavedFile fichier(s) sauvegardé(s)."
