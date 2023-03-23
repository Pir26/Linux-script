#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 22/03/2023
#
# Script : strong_ssh_config.sh
#
# Description : modify sshd_config file of linux server againts the (open) ssh ANSSI recommendations
#               https://www.ssi.gouv.fr/uploads/2014/01/NT_OpenSSH.pdf
#
# Input :
#   no argument = the "/etc/ssh/sshd_config" file will be modified
#   relative or absolut path = "sshd_config" file will be modified in this given path
#   full path and file name of sshd_config file = the given file of this given path will be modified
#
# Output : modification of the ssh_config file with the ANSSI recommendation
#
# 1/ The status of ssh service is checked (to know if it can be restarted once its configuration is improved).
# 2/ The ssh_config is dupplicated in a temporary file modified to improve the ssh configuration. 
# 3/ The original file is then saved (backup) and replaced by the temporary file.
# 4/ The ssh service is then restarted.
# 5/ If any error occurs, the backup file is installed back and the ssh service restarted and checked.
#
####################

# default path name where to get ssh_config file
DEFAULT_PATH_NAME="/etc/ssh/"
# default ssh_config file name
DEFAULT_FILE_NAME="sshd_config"

# suffixe for temporary ssh config file
TEMPORARY_FILE_SUFFIX=".tmp"
# suffixe for backup ssh config file
BACKUP_FILE_SUFFIX=".bak"

# ssh minimal version (for R15 ANSSI recommendation)
SSH_MINIMAL_VERSION="6.3"

####################
# Return the location of ssh_config file given by user. Combined with default location when missed.
# Input : no argument or one argument with one path name only, or one file name only or a full path name
# Output : full path name if file exits, empty string else
####################
getfullsshFileName()
{
# construct full path file name depending on the argument
local fullsshFileName=""
if ! [[ $1 ]]; then
    fullsshFileName="${DEFAULT_PATH_NAME}${DEFAULT_FILE_NAME}"
elif [ -d "$1" ]; then
    fullsshFileName="$1${DEFAULT_FILE_NAME}"
else
    fullsshFileName="$1"
fi
echo "${fullsshFileName}"
}

####################
# Return the ssh version.
# Input : no argument or one argument with one path name only, or one file name only or a full path name
# Output : ssh version
####################
getsshVersion()
{
local sshVersion=""

# get ssh version from service (if started)
sshVersion=$(ssh -V 2>&1 | cut -d '_' -f 2 | grep -Po '^[0-9.]+')

# else get version from package with apt
if ! [[ "${sshVersion}" ]]; then
    apt show ssh | awk ' $1 ~ ".ersion" {print $2}' | cut -d ':' -f 2 | grep -Po '^[0-9.]+'
fi

return "${sshVersion}"
}

main() { 
# check ssh.service status

# search for ssh config file 
fullsshFileName="$(getfullsshFileName "$1")"
if [ -f "${fullsshFileName}" ]; then
    echo "info : traitement du fichier ${fullsshFileName}..."
    # work with temporary file
    if (touch "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}" > /dev/null 2>&1); then
        # go through ssh config file
        for line in ${fullsshFileName}; do
            echo "info : traitement du fichier"
        done
        # backup original ssh config file 
        echo "info : traitement du fichier ${fullsshFileName} terminé."
        echo "info : sauvegarde du fichier original ${fullsshFileName} en '${fullsshFileName}${BACKUP_FILE_SUFFIX}'"
        if (mv "${fullsshFileName}" "${fullsshFileName}${BACKUP_FILE_SUFFIX}" > /dev/null 2>&1); then
            # rename temporary working file
            echo "info : récupération de la configuration traitée."
            if (mv "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}" "${fullsshFileName}" > /dev/null 2>&1); then
                echo "info : redémarage du service"
            else
                echo "ERREUR : le fichier temporaire '${fullsshFileName}${TEMPORARY_FILE_SUFFIX}' n'a pas pu être transféré vers le fichier final ${fullsshFileName}."
                # retourne sur la configuration originale
                if ! (mv "${fullsshFileName}${BACKUP_FILE_SUFFIX}" "${fullsshFileName}" > /dev/null 2>&1); then
                    echo "ERROR : le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' n'a pas pu être récupéré."
                    echo "ERROR : il faut renommer ou copier le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' vers le fichier initial '${fullsshFileName}'"
                fi
            fi
        else
            echo "Le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' n'a pas pu être créé."
        fi
    else
        echo "Le fichier temporaire de travail '${fullsshFileName}${TEMPORARY_FILE_SUFFIX}' n'a pas pu être créé."
    fi
else
    echo "Le fichier ${fullsshFileName} n'existe pas."
fi


# restart ssh.service
}

main "${1}"
