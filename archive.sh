#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : archive.sh
#
# Description : save the home directory of a user
#
# Input : user account name
#
# Output : backup file
#
####################

# Check if script runs as sudo
if [[ $EUID = 0 ]]; then
	if [ -d /home/$1 ]
	then
		backupFileName="/backup/Simplon-$(date +'%Y-%m-%dT%H:%M+%S').tar.gz"
		echo "Sauvegarde du dossier '/home/$1' en cours ..."
		echo "Création de la sauvegarde '$backupFileName'"
		tar zcPf $backupFileName /home/$1/*
		if [ $? -eq 0 ]
		then
			echo "Sauvegarde terminée avec succès"
			echo "Transfert de la sauvegarde sur le serveur de sauvegarde ..."
			scp -i ssh_key_id $backupFileName pvuillaume@serveur2:/backup/.
			if [ $? -eq 0 ] 
			then
				echo "Transfert terminé avec succès"
			fi
		fi
	else
		echo "Aucun dossier personnel trouvé."
	fi
else
	echo "Run this script as sudo please. Type 'sudo ./archive.sh'."
fi
# tar cvf /var/archive/test.$(date +"%H:%M:%S %d/%m/%y").tar.gz /home/simplon/*

# $(date +"%H:%M:%S %d/%m/%y")
