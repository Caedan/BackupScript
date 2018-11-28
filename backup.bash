
#!/bin/bash


echo "1. Backup"
echo "2. Restore"
echo
echo "Select a menu option: "

# Saves user input in $option variable
read option

#If statements used to validate user input
if [ $option = 1 ]
then
        echo "Specify the directory or file you wish to backup:"
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
        ls /mnt
        echo "Specify the location where you want to save your backup: "
        read savelocation
		echo "What would  you like the backup file to be called?"
		read backupName
        # Tar creates an archive with the specified name
        # compresses it and saves it in the specified location
        # c - creates an archieve
		# z - tells tar to write files through gzip
        # f - specify the file name of archieve

        sudo tar -czf $savelocation/$backupName.tar.gz $dirfile

elif [ $option = 2 ]
then
        echo "Specify the backup you wish to deploy:"
        read recoveryLocation
		mrecoveryLocation="$recoveryLocation.tar.gz"

        #This while loop checks if the user typed in an existing directory or file
        while [ ! -r "$mrecoveryLocation" ]
        do
			echo "Type in a valid file path:"
            read recoveryLocation
		done
        echo "Type in a directory you wish to unpack your backup in:"
        read recoveryDestination

        # Tar unpacks and uncompresses the backup
        # x - extract files from archieve
		# z - tells tar to uncrompress the gzip file
		# f - specify file name of file
		
        sudo tar -xzf $recoveryLocation.tar.gz -C/$recoveryDestination
else
        echo "You can only type in a number displayed on the menu"
fi
