 #!/bin/bash

echo "1. Backup (One time backup)"
echo "2. Restore"
echo "3. Schedule a Backup"
echo
echo "Select a menu option: "

# Saves user input in $option variable
read option

#!/bin/bash

echo "This Backup script allows you to backup a directory or a single file."
echo "In case you have files in a directory you don't wish to backup,"
echo "Create a seperate directory containing only the files you want to backup."
echo
echo "1. Backup (One time backup)"
echo "2. Restore"
echo
echo "Select a menu option: "

# Saves user input in $option variable
read option

# If statements used to validate user input
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
        echo "Please select one of the above devices to save your backup"
		echo "Note that you don't have to type in the entire path !"
		echo "You don't need to start by typing in '/mnt/', only to type in the name of the device listed above."
        read savelocation
        echo "What would  you like the backup file to be called? (The extension '.tar.gz' or '.tar.bz2' is added automatically)"
        read backupName
        echo "Would you like to create a bzip or a gzip file ? (b = bzip, g = gzip)"
        read zip
        if [ $zip = "g" ]
        then
                # Tar creates an archive with the specified name
                # compresses it and saves it in the specified location
                # c - creates an archive
                # p - preserves permissions
                # z - tells tar to write files through gzip
                # f - specify the file name of archive
                sudo tar -cpzf /mnt/$savelocation/$backupName.tar.gz $dirfile
                echo "Your files have been successfully backed up !"
        else
                # j - compresses the file in bzip2 format
                sudo tar -cpjf /mnt/$savelocation/$backupName.tar.bz2 $dirfile
                echo "Your files have been successfully backed up !"
        fi
elif [ $option = 2 ]
then
        echo "Currently mounted Devices:"
        tree -L 1 /mnt/
        echo "Please specify the device containing your backup."
		echo "Note that you don't have to type in the entire path !"
		echo "You don't need to start by typing in '/mnt/', only type in the name of the device listed above."
        read devChoice
        devChoice=/mnt/$devChoice
        echo
        echo "The selected device contains the following"
        echo
        tree -P '*.tar.*' $devChoice
        echo
        echo "Select a backup file listed above:"
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
        if [ $recoverThis = "*.tar.gz" ]
        then
                # Tar unpacks and uncompresses the backup
                # x - extract files from archive
                # p - perserves permissions
                # z - tells tar to uncrompress the gzip file
                # f - specify file name of file
                sudo tar -xpzf $recoverThis -C/$recoveryDestination
                ls $recoveryDestination
        else
                sudo tar -xpjf $recoverThis -C/$recoveryDestination
                echo
                echo "Your backup has been successfully restored!"
                ls $recoveryDestination
        fi
else
		echo
        echo "You can only type in a number displayed on the menu !"
fi
