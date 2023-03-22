#!/bin/bash
#
# Author : P.Vuillaume
#
# Date : 21/03/2023
#
# Script : sort.sh
#
# Description : sort arguments in alphabetical order
#
# Input : 1 to n arguments
#
# Output : display arguments in alphabetical order
#
####################

# echo -n => display argument without EOL
# sort -f => ignore case during sorting
for i in $@; do :; echo  "${i}"; done | sort -f | cat | tr '\n' ' '

# EOF
echo
