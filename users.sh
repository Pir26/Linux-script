#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : users.sh
#
# Description : display users (in alphabetical order) who have at least current opened session 
#
# Input : none
#
# Output : see description
#
####################

# echo -n => display argument without EOL
# sort -f => ignore case during sorting
# ps -u => list all users
# awk ... (NR != 1) => skip the first line
# awk ... {print $1} => print first column
# uniq => skip unic occurence only
# sort => sort the result
ps -u | awk '{if(NR != 1){ print $1}}' | uniq | sort

