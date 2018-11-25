
#!/bin/bash

echo "1. Backup"
echo "2. Restore"
echo
echo "Select a menu option please: "

# Saves user input in $option variable
read option

if [ $option = 1 ]
then
        echo "Specify the directory or file you wish to backup:"
        read dirfile

        # This while loop checks if the user typed in an existing directory or file
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

        # Tar creates an archive with the specified name
        # compresses it and saves it in the specified location
        # c - creates - p preserve permissions - compress/uncompress
        # f - filename
        sudo tar -cpzf /mnt/$location/backup.tar.gz --absolute-names $dirfile

elif [ $option = 2 ]
then
        echo "Specify the backup you wish to deploy:"
        read recoveryTar

        # This while loop checks if the user typed in an existing directory or file
        while [ ! -r "$recoveryTar" ]
        do
                        echo "Type in a valid file path:"
                        read recoveryTar
        done
        echo "Type in a directory you wish to unpack your backup in:"
        read recoveryDir

        # Tar unpacks and uncompresses the backup
        # x - extract
        sudo tar -xpzf $recoveryTar --absolute-names -C $recoveryDir
else
        echo "You can only type in a number displayed on the menu"
fi
