#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 22/03/2023
#
# Script : strong_ssh_config.sh
#
# Description : modify ssh_config file of linux machine againts the (open)ssh ANSSI recommendations
#               https://www.ssi.gouv.fr/uploads/2014/01/NT_OpenSSH.pdf
#
# Input :
#   no argument = the "/etc/ssh/ssh_config" file will be modified
#   relative or absolut path = "ssh_config" file will be modified in this given path
#   full path and file name of ssh_config file = the given file of this given path will be modified
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
defaulPathName="/etc/ssh/"
# default ssh_config file name
defaultFileName="ssh_config"
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
    fullsshFileName="${defaulPathName}${defaultFileName}"
elif [ -d "${1}" ]; then
    fullsshFileName="${1}${defaultFileName}"
else
    fullsshFileName="${1}"
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
fullsshFileName="$(getfullsshFileName "${1}")"
if [ -f "${fullsshFileName}" ]; then
    echo "info : traitement du fichier ${fullsshFileName}..."

    # go through ssh config file
    for line in ${fullsshFileName}; do
        :
    done
else
    echo "Le fichier ${fullsshFileName} n'existe pas."
fi



# restart ssh.service
}
