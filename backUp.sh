 #!/bin/bash

echo "1. Backup (One time backup)"
echo "2. Restore"
echo "3. Schedule a Backup"
echo
echo "Select a menu option: "

# Saves user input in $option variable
read option

#If statements used to validate user input
if [ $option = 1 ]
then
        echo "Current Directory:"
        tree
        echo "Please select one of the above mentioned files or folders to backup:"
        read dirfile

        #While loop used to validate directory entered by the user
        while [ ! -r "$dirfile" ]
        do
                #If an invalid directory is entered and error message is displayed
                echo "Invalid directory"
                echo "Type in a valid directory or file path:"
                read dirfile
        done

        echo "Mounted storage devices:"
        echo
        tree -L 1 /mnt
        echo "Please select one of the above devices to save your backup: "
        read savelocation
        echo "What would  you like the backup file to be called?"
        read backupName
        # Tar creates an archive with the specified name
        # compresses it and saves it in the specified location
        # c - creates an archive
        # p - preserves permissions
        # z - tells tar to write files through gzip
        # f - specify the file name of archive

        sudo tar -cpzf /mnt/$savelocation/$backupName.tar.gz $dirfile

        echo "Your files have been successfully backed up !"
elif [ $option = 2 ]
then
        echo "Currently mounted Devices:"
        tree -L 1 /mnt/
        echo "Please specify the device containing your backup you wish to deploy"
        read devChoice
        devChoice=/mnt/$devChoice
        echo "Select the backup you wish to deploy"
        tree -P '*.tar.gz' $devChoice
        read recoverThis
        recoverThis=$devChoice/$recoverThis
        #This while loop checks if the user typed in an existing directory or file
        while [ ! -r $recoverThis ]
         do
                echo "Type in a valid file path:"
                read recoverThis
        done
        echo "Type in a directory you wish to unpack your backup in:"
        read recoveryDestination

        # Tar unpacks and uncompresses the backup
        # x - extract files from archive
        # p - perserves permissions
        # z - tells tar to uncrompress the gzip file
        # f - specify file name of file
        sudo tar -xpzf $recoverThis -C/$recoveryDestination
        echo
        echo "Your backup has been successfully restored!"
        ls $recoveryDestination
elif [ $option = 3 ]
then
        echo "Current Directory:"
        tree
        echo "Please select one of the above mentioned files or folders to backup:"
        read dirfile

        #While loop used to validate directory entered by the user
        while [ ! -r "$dirfile" ]
        do
                #If an invalid directory is entered and error message is displayed
                echo "Invalid directory"
                echo "Type in a valid directory or file path:"
                read dirfile
        done

        echo "Mounted storage devices:"
        echo
        tree -L 1 /mnt
        echo "Please select one of the above devices to save your backup: "
        read savelocation
        echo "What would  you like the backup file to be called?"
        read backupName

        echo "* * * * *"
        echo "- - - - -"
        echo "| | | | |"
        echo "| | | | ----- Day of week (0 - 7) (Sunday=0 or 7) "
        echo "| | | ------- Month (1 - 12)"
        echo "| | --------- Day of month (1 - 31)"
        echo "| ----------- Hour (0 - 23)"
        echo "------------- Minute (0 - 59)"
        echo "Worth mentioning that the (*) sign on its own means every minute/hour/month/..."
        echo
        echo "Please indicate when you want to backup your file or folder:"
        read scheduleSyntax
else
        echo "You can only type in a number displayed on the menu"
fi
