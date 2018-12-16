#!/bin/bash

echo "This Backup script allows you to backup a directory or a single file."
echo "In case you have files in a directory you don't wish to backup,"
echo "Create a seperate directory containing only the files you want to backup."
echo "Software Dependencies:"
echo "- Tree command (sudo apt-get install tree)"
echo "- GPG command (sudo apt-get install gpg) only necessary if you want your backups encrypted"
echo "- Bzip2 (sudo apt-get bzip2) Bzip is optional if you don't want to use it"
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
	# Executes pwd command in a subshell. Output is the current directory
	currentDir=$(pwd)
	echo "Current Directory:"
	# Shows a treeview of the current directory
  tree
  echo "Please select one of the above mentioned files or folders to backup:"
	echo "(You can only choose files from your current directory: $currentDir)"
  read dirfile
	checkDirfile=$currentDir/$dirfile
  #While loop used to validate directory entered by the user
  while [ ! -r "$checkDirfile" ]
  do
      #If an invalid directory is entered and error message is displayed
      echo "Invalid directory"
      echo "Type in a valid directory or file path:"
      read checkDirfile
  done
  echo "Mounted storage devices:"
  echo
	# Shows a treeview of the directory '/mnt'
  tree -L 1 /mnt
  echo "Please select one of the above devices to save your backup"
	echo
	echo "Note that you don't have to type in the entire path !"
	echo "You don't need to type in the name of the directory '/mnt/', only to type in the name of the device listed above."
  read savelocation
	echo "What would  you like the backup file to be called? (The extension '.tar.gz' or '.tar.bz2' is added automatically)"
  read backupName
  echo "Would you like to create a bzip or a gzip file ? (b = bzip, g = gzip)"
  read zip
	# Checks wether the user typed in a valid character
	while [[ $zip != "g" && $zip != "b" ]]
	do
		echo "It seems you typed in an invalid character, please be aware you can only choose between the following options."
		echo "(b = bzip, g = gzip) case sensitive !!!"
		read zip
	done
	# Checks if a Backups folder aleady exists, if not it creates one within the chosen storage device
	if [ ! -r "/mnt/$savelocation/Backups" ]
	then
		mkdir /mnt/$savelocation/Backups
	fi
	# If statement asking the user which compression format to use
  if [[ $zip = g ]]
  then
		# Tar creates an archive with the specified name
		# compresses it and saves it in the specified location
		# c - creates an archive
		# p - preserves permissions
		# z - Compresses files with gzip
		# P - Normally when creating an archive, `tar' strips an initial `/' from
		# member names.  This option disables that behavior.
		# f - specify the file name of archive
		sudo tar -cpzPf /mnt/$savelocation/Backups/$backupName.tar.gz $dirfile
		echo "Your files have been successfully backed up !"
		echo
		echo "Would you like to encrypt your file ? (y = yes) case sensitive"
		read answer
		if [ $answer = "y" ]
		then
			# Encrypting gunzip archive with aes cipher
			gpg -c --cipher aes /mnt/$savelocation/Backups/$backupName.tar.gz
			# Deleting the unencrypted copy
			sudo rm -r /mnt/$savelocation/Backups/$backupName.tar.gz
			echo
			echo "encrypted backup has been successfully created !"
	fi
  else
		# j - compresses the file in bzip2 format
		sudo tar -cpjPf /mnt/$savelocation/Backups/$backupName.tar.bz2 $dirfile
		echo "Your files have been successfully backed up !"
		echo "Would you like to encrypt your file ? (y = yes) case sensitive"
		read answer
		if [ $answer = "y" ]
		then
			# Encrypting bunzip archive with aes cipher
			gpg -c --cipher aes /mnt/$savelocation/Backups/$backupName.tar.bz2
			# Deleting the unencrypted copy
			sudo rm -r /mnt/$savelocation/Backups/$backupName.tar.bz2
			echo
			echo "encrypted backup has been successfully created !"
		fi
	fi
elif [ $option = 2 ]
then
  echo "Currently mounted Devices:"
  tree -L 1 /mnt/
  echo "Please specify the device containing your backup."
	echo
	echo "Note that you don't have to type in the entire path !"
	echo "You should ommit the name of the directory '/mnt/...', only type in the name of the device listed above."
  read devChoice
  devChoice=/mnt/$devChoice
  echo
  echo "The selected device contains the following"
  echo
  tree -P '*.tar.*' $devChoice/Backups
  echo
	echo "Only type in the name of the file !"
  echo "Select a backup file listed above:"
  read recoverThis
	# Variable contains path to backup
  recoverThis=$devChoice/Backups/$recoverThis
  #This while loop checks if the user typed in an existing directory or file
  while [ ! -r $recoverThis ]
  do
    echo "Type in a valid file path:"
		tree -P '*.tar.*' $devChoice/Backups
		echo "Only type in the name of the file !"
    read recoverThis
  done
  echo "Type in a directory you wish to unpack your backup in:"
  read recoveryDestination
  if  [[ $recoverThis =~ \.gpg$ ]]
  then
		# This variable executes a piped command in a subshell in
		# In the cut command is a delimiter defined '.' and an index '3'
		# The purpose is to identify if the given file is a gzip or a bizip2 file
		getExt=$(echo $recoverThis | cut -d'.' -f 3)
		# Extracting the original given name from the substring
		getName=$(echo $recoverThis | cut -d'.' -f 1)

		if [[ $getExt =~ gz ]]
		then
			# Decrypting the file
			gpg -d $recoverThis > $getName.tar.gz
			# Tar unpacks and uncompresses the backup
			# x - extract files from archive
			# p - perserves permissions
			# z - tells tar to uncrompress the gzip file
			# f - specify file name of file
			sudo tar -xpzf $getName.tar.gz -C/$recoveryDestination
			echo
			echo "Your backup has been successfully restored!"
			echo
			# List the content in the recovery directory to check if all files have been recoverd
			ls $recoveryDestination
		else
			# Decrypting the file which was encrypted with the cipher aes-256-cbc
			gpg -d $recoverThis > $getName.tar.bz2
			# Tar unpacks and uncompresses the backup
			# x - extract files from archive
			# p - perserves permissions
			# j - tells tar to uncrompress the bzip file
			# f - specify file name of file
			sudo tar -xpjf $getName.tar.bz2 -C/$recoveryDestination
			echo
			echo "Your backup has been successfully restored!"
			echo
			# List the content in the recovery directory to check if all files have been recoverd
			ls $recoveryDestination
		fi
  else
			if  [[ $recoverThis =~ \.gz$ ]]
			then
				sudo tar -xpzf $recoverThis -C/$recoveryDestination
				echo
				echo "Your backup has been successfully restored!"
				echo
				# List the content in the recovery directory to check if all files have been recoverd
				ls $recoveryDestination
			else
				sudo tar -xpjf $recoverThis -C/$recoveryDestination
				echo
				echo "Your backup has been successfully restored!"
				echo
				# List the content in the recovery directory to check if all files have been recoverd
				ls $recoveryDestination
			fi
    fi
else
	echo
        echo "You can only type in a number displayed on the menu !"
fi
