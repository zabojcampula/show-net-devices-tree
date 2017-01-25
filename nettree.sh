#!/bin/bash

DEFAULT_INDENT="   "
DIRECTION="UP"

function usage()
{
   cat << USAGEEND

The script prints network devices hierarchy as a tree view.
Possible arguments:
   -u     prints tree from bottom to up (default). Physical devices are roots of the tree.
   -d     prints tree from up to bottom. Logica, devices are roots of the tree.

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

while [ ! -z "$1" ]
do
    case "$1" in
        -d) DIRECTION=DOWN
            ;;
        -u) DIRECTION=UP
            ;;
        -h) usage
            exit 0 
            ;;
         *) usage
            exit 1
            ;;
   esac
   shift
done

declare -A devicesup
declare -A devicesdown
while read line
do
   #echo "XX $line"
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
done < <(ip -o link)

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
