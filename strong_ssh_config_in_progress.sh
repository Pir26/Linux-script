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

# expected configuration in string format
EXPECTED_CONFIGURATION_STR="
Protocol 2 					# R1 : Seule la version 2 du protocole SSH doit être autorisée.
StrictHostKeyChecking ask 	# R6 : assurer de la légitimité du serveur contacté.
StrictModes yes 			# R14 : l’AES-128 mode CBC doit être utilisé.
Ciphers aes256-ctr,aes192-ctr,aes128-ctr	# R15 : l’algorithme de chiffrement et l’intégrité sont imposés.
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com #
# MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1
UsePrivilegeSeparation yesandbox # R16 : séparation de privilèges. Si "sandbox" n’est pas utilisable, mettre "yes" en remplacement
PermitEmptyPasswords no # R18 : moindre privilèges
MaxAuthTries 3 				# Restriction des tentatives de connexion
LoginGraceTime 30 			# Temporisation des tentatives de connexion
PermitRootLogin no 			# R21 : chaque utilisateur doit disposer de son propre compte, unique, incessible.
PrintLastLog yes            # R21
PermitUserEnvironment no 	# R23 : l’altération de l’environnement par un utilisateur doit être bloquée par défaut.
AllowTcpForwarding no 		# R27 : sauf besoin dûment justifié, toute fonctionnalité de redirections de flux doit être désactivée.
X11Forwarding no 			# R28 : La redirection X11 doit être désactivée sur le serveur.
ForwardX11Trusted no 		# R28 : La redirection X11 doit être désactivée sur le serveur.
"
# EXPECTED_CONFIGURATION_STR will be returned in array format
# each line of the array will be an array of 4 data : [instruction] [data] [# comment] [implemented in the configuration]
EXPECTED_CONFIGURATION_ARRAY=()


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

####################
# Create an array from string.
# Input : no argument or one argument with one path name only, or one file name only or a full path name
# Output : array
####################
extractArray()
{
    #local instructionArray=()
    #IFS=$"\n"

    # regex to extract each line of the data given as an input
    regex="(^[[:alnum:]]+)[[:blank:]]+([0-9a-zA-Z\_\:\\,\@\.\-]+).*(#.*)?"

    # read each line 
    dataToRead=("$@")
    readarray  -t arr <<< "${dataToRead}"
    i=0
    for line in "${arr[@]}";
        do
            if [[ "${line}" =~ $regex ]]; then
                capturedInstruction="${BASH_REMATCH[1]}"
                capturedData="${BASH_REMATCH[2]}"
                echo "${capturedInstruction} ${capturedData}"
                EXPECTED_CONFIGURATION_ARRAY[$((i))]="${BASH_REMATCH[1]};${BASH_REMATCH[2]};${BASH_REMATCH[3]};NOT IMPLEMENTED"
                i=$((i+1))
            fi
        done
}

main() { 
# prepare an array with the expected configuration
extractArray "${EXPECTED_CONFIGURATION_STR[@]}"

# check ssh.service status

# search for ssh config file 
fullsshFileName="$(getfullsshFileName "$1")"
if [ -f "${fullsshFileName}" ]; then
    echo "info : traitement du fichier ${fullsshFileName}..."
    # work with temporary file
    if (rm -R "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"; touch "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"); then
        # keep safe a list of expected instruction found
        listOfExpectedInstrictionFound=";"
        # browse ssh config file and write temporary file
        while IFS= read -r line; do
            # keep safe if an expected instruction is found for this line
            expectedInstructionFound=False
            # split read line in the config file in order to check if an instruction is present 
            regex="^(#?) ?([[:alnum:]]+)[[:blank:]]+([0-9a-zA-Z\_\:\\,\@\.\-]+)[[:blank:]]*$"
            if [[ "${line}" =~ $regex ]]; then
                #echo $line
                capturedComment="${BASH_REMATCH[1]}"
                capturedInstruction="${BASH_REMATCH[2]}"
                capturedData="${BASH_REMATCH[3]}"
                # if an instruction is present, check captured expression against the array of expected instructions
                for loop in "${EXPECTED_CONFIGURATION_ARRAY[@]}"; do
                    expectedRegex="^([[:alnum:]]+);([0-9a-zA-Z\_\:\\,\@\.\-]+);(.*);(.*)$"
                    if [[ "${loop}" =~ $expectedRegex ]]; then
                        expectedInstruction="${BASH_REMATCH[1]}"
                        expectedData="${BASH_REMATCH[2]}"
                        # expectedComment="${BASH_REMATCH[3]}"
                        # expectedStatus="${BASH_REMATCH[4]}"
                        # keep safe if instruction is expected or not
                        if [[ "${capturedInstruction}" == "${expectedInstruction}" ]]; then
                            expectedInstructionFound=True
                            listOfExpectedInstrictionFound="${listOfExpectedInstrictionFound};${capturedInstruction}"
                            # captured instruction in configuration file is same as the expected one's
                            if [[ "${capturedData}" == "${expectedData}" ]]; then
                                # captured data is same as the expected one's
                                if [ ${capturedComment} ]; then
                                    # Uncomment the instruction
                                    echo "# ###uncommented by script###" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                                    echo "${capturedInstruction} ${capturedData}" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                                fi
                            else
                                # captured data is not the same as the expected one's
                                if ! [ ${capturedComment} ]; then
                                    # captured instruction is not commented - begining with '#'' character )
                                    # comment the original instruction and add the new one
                                    echo "# ###commented and modified by script###" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                                    echo "#${capturedInstruction} ${capturedData}" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                                else
                                    echo "# ###modified by script###" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                                fi
                                # add the expected instruction
                                echo "${expectedInstruction} ${expectedData}" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
                            fi
                        fi
                    fi
                done
            fi
            if [ ${expectedInstructionFound} == "False" ]; then
                # not an expected instruction - just copy the line
                echo "${line}" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}"
            fi
        done < "$fullsshFileName"

        # at the end of the file, check if some configuration remains expected but not found in the original file
        echo "# ###modified by script###" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}" 
        for loop in "${EXPECTED_CONFIGURATION_ARRAY[@]}"; do
            expectedRegex="^([[:alnum:]]+);([0-9a-zA-Z\_\:\\,\@\.\-]+);(.*);(.*)$"
            if [[ "${loop}" =~ $expectedRegex ]]; then
                expectedInstruction="${BASH_REMATCH[1]}"
                expectedData="${BASH_REMATCH[2]}"
                if ! ( echo "${listOfExpectedInstrictionFound}" | grep ";${expectedInstruction};" > /dev/null 2>&1 ) ; then
                    # add expected instruction
                    echo "Added ${expectedInstruction} ${expectedData}"
                    echo "${expectedInstruction} ${expectedData}" >> "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}" 
                fi
            fi
        done

        # backup original ssh config file 
        echo "info : traitement du fichier ${fullsshFileName} terminé."
        echo "info : sauvegarde du fichier original ${fullsshFileName} en '${fullsshFileName}${BACKUP_FILE_SUFFIX}'"
        if (mv "${fullsshFileName}" "${fullsshFileName}${BACKUP_FILE_SUFFIX}"); then
            # rename temporary working file

            # NE PAS OUBLIER DE REMETTRE LES DROITS
            echo "info : récupération de la configuration traitée."
            if (mv "${fullsshFileName}${TEMPORARY_FILE_SUFFIX}" "${fullsshFileName}"); then
                echo "info : redémarage du service"
            else
                echo "ERREUR : le fichier temporaire '${fullsshFileName}${TEMPORARY_FILE_SUFFIX}' n'a pas pu être transféré vers le fichier final ${fullsshFileName}."
                # come back with original version
                if ! (mv "${fullsshFileName}${BACKUP_FILE_SUFFIX}" "${fullsshFileName}"); then
                    echo "ERREUR : le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' n'a pas pu être récupéré."
                    echo "ERREUR : il faut renommer ou copier le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' vers le fichier initial '${fullsshFileName}'"
                fi
            fi
        else
            echo "ERREUR : le fichier de sauvegarde '${fullsshFileName}${BACKUP_FILE_SUFFIX}' n'a pas pu être créé."
        fi
    else
        echo "ERREUR : le fichier temporaire de travail '${fullsshFileName}${TEMPORARY_FILE_SUFFIX}' n'a pas pu être créé."
    fi
else
    echo "ERREUR : le fichier ${fullsshFileName} n'existe pas."
fi


# restart ssh.service
}

main "${1}"
