#!/bin/bash

DEFAULT_INDENT="   "
DIRECTION="UP"
FILE=""

function usage()
{
   cat << USAGEEND

The script prints network devices hierarchy as a tree view.
Possible arguments:
   -u        prints tree from bottom to up (default). Physical devices are roots of the tree.
   -d        prints tree from up to bottom. Logica, devices are roots of the tree.
   -f <file> use this file as an input file instead of parsing localy "ip -o link" command.

USAGEEND
}

function printdown()
{
   local indent="$1"
   devs="$2"
   for indev in $devs
   do
      echo "$indent" "$indev"
      printdown "$DEFAULT_INDENT$indent" "${devicesdown[$indev]}"
   done
}

function printup()
{
   local indent="$1"
   devs="$2"
   for indev in $devs
   do
      echo "$indent" "$indev"
      printup "$DEFAULT_INDENT$indent" "${devicesup[$indev]}"
   done
}

while getopts "duhf:" option; do
    case "$option" in
        d) DIRECTION=DOWN
            ;;
        u) DIRECTION=UP
            ;;
        f) fileflag=1 ;
           FILE=${OPTARG} 
            ;;
        h) usage
            exit 0 
            ;;
        *) usage
           exit 1
           ;;
   esac
done

declare -A devicesup
declare -A devicesdown
while read line
do
   dev=${line#*: }
   dev=${dev%%:*}
   devicesup[$dev]=""
   if [ -z "${devicesdown[$dev]}" ]
   then
      devicesdown[$dev]=""
   fi
   if [[ "$line" == *" master "* ]]
   then
      master=${line#* master *}
      master=${master%% *}
      devicesup[$dev]="${devicesup[$dev]} $master"
      devicesdown[$master]="${devicesdown[$master]} $dev"

   fi
done < <( if [ $fileflag ] ; then cat $FILE |grep BROADCAST ; else ip -o link ; fi )

if [ "$DIRECTION" == "UP" ]
then

   for dev in ${!devicesup[@]}
   do
     if [ -z "${devicesdown[$dev]}" ]
     then
        echo $dev
        printup "$DEFAULT_INDENT" "${devicesup[$dev]}"
      fi
   done

else

   for dev in "${!devicesdown[@]}"
   do
     if [ -z "${devicesup[$dev]}" ]
     then
        echo $dev
        printdown "$DEFAULT_INDENT" "${devicesdown[$dev]}"
      fi
   done

fi
