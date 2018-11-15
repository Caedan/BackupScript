#!/bin/bash

echo "1. Backup"
echo "2. Restore"
echo
echo "Select a menu option please:"
read option
if [ $option = 1 ]
then
        echo "Specify the directory or file you wish to backup:"
        read dirfile
        while [ ! -r "$dirfile" ]
        do
                        echo "Type in a valid directory or file path:"
                        read dirfile
        done
        echo "Currently mounted storage devices:"
        echo
        ls /mnt
        echo "Specify the location where you want to save your backup: "
        read location

fi

test
