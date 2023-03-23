#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : archive.sh
#
# Description : save the home directory of a user. Excluding trash and .cache content.
#
# Input : user account name
#
# Output : backup file
#
# Update : 23/03/2023 - P.Vuillaume - ISO 8601 for date&time and improvment during compression
#
####################

# backup directory
BACKUP_DIR="/backup/"

####################
# Check presence of backup directory. Create it if not present.
####################
createBackupDir()
{
	if ! [[ -d "$BACKUP_DIR" ]]; then
		mkdir "$BACKUP_DIR" 
	fi
	if [[ -d "$BACKUP_DIR" ]]; then
		return 0
	else
		return 1
	fi
}

main()
{
	# Check if argument for user is present
	if [ "$#" -ne 1 ]; then
		# Create backup dir if doesn't exist
		if (createBackupDir "${BACKUP_DIR}"); then
			# Check if the script is running as sudo
			if [[ $EUID = 0 ]]; then
				if [ -d "/home/$1" ]; then
					backupFileName="/backup/$1-$(date +'%Y-%m-%dT%H:%M:%S%:z').tar.gz"
					echo "Sauvegarde du dossier '/home/$1' en cours ..."
					echo "Création de la sauvegarde '$backupFileName'"
					# Move to backup folder
					currentPath="$(pwd)"
					if (cd "$BACKUP_DIR"); then
						if (tar --exclude=/home/*/.cache --exclude=/home/*/.local/share/Trash -zcPf "$backupFileName" "/home/$1/*.*"); then
							echo "Sauvegarde terminée avec succès"
							cd "${currentPath}" || exit
							echo "Transfert de la sauvegarde sur le serveur de sauvegarde ..."
							# if (cp "$backupFileName" /backup/test.tar.gz > /dev/null 2>&1); then # JUST FOR TESTING PURPOSE
							if (scp -i ssh_key_id "$backupFileName" pvuillaume@serveur2:/backup/. > /dev/null 2>&1); then
								echo "Transfert terminé avec succès"
							else
								echo "Erreur lors du transfert de la sauvegarde vers le serveur distant."
							fi
						fi
					else
						echo "Impossible de créer une sauvegarde dans le répertoire ${BACKUP_DIR}."
					fi
				else
					echo "Aucun dossier personnel trouvé."
				fi
			else
				echo "Relancer ce script avec les droits 'sudo'. Tapez 'sudo ./archive.sh nom_utilisateur'."
			fi
		else
			echo "Le dossier nommé '${BACKUP_DIR}' n'existe pas. Créer le dossier avant de relance ce script."
		fi
	else
		echo "Veuillez indiquer un utilisateur. Tapez 'sudo ./archive.sh nom_utilisateur'."
	fi
		# tar cvf /var/archive/test.$(date +"%H:%M:%S %d/%m/%y").tar.gz /home/simplon/*

		# $(date +"%H:%M:%S %d/%m/%y")
}

main "${1}"