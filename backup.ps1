#Use "Install-Module -Name 7Zip4Powershell -RequiredVersion 1.8.0" to install the 7zip PowerShell module

#Load pre-built form assembly
Add-Type -AssemblyName System.Windows.Forms
#Get the current date and time and assign it to the 'currentDate' variable
$currentDate = Get-Date

#Declare 2 global variables which can be read from any function in the script
$Global:formatSelection = ""
$GLobal:encryptOption = ""

function backup{ #Create function called backup

    echo ""
    echo "Select the file or directory you would like to backup using the Folder Browser"

    #'New-Object' used to create the form for the Folder Browser Dialog                          
    $folderBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
    #Set description for the dialog
    $folderBrowse.Description = "Select file or directory to backup"        

    #'ShowDialog' is used to invoke the Folder Browser Dialog.
    #The output of the 'ShowDialog' method is assigned to the 'dirSelect' variable
    #Property of dialog is assigned as 'TopMost' so the dialog will display above any other windows
    $dirSelect = $folderBrowse.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True}))       
    
    #'SelectedPath' method used to get the path of the selected directory
    echo ""                                     
    echo "Path selected:" $folderBrowse.SelectedPath 
    echo ""

    #Code in 'If' statement only runs if user select a directory to backup
    if ($dirSelect -eq [Windows.Forms.DialogResult]::OK){
        
        echo "Select the location for the backup to be saved using the Folder Browser"

        #'New-Object' used to create the form for the Folder Browser Dialog 
        $folderBrowse2 = New-Object System.Windows.Forms.FolderBrowserDialog
        #Set description for the dialog
        $folderBrowse2.Description = "Select location for the backup to be saved"
        echo ""

        #'ShowDialog' is used to invoke the Folder Browser Dialog.
        #The output of the 'ShowDialog' method is assigned to the 'dirSave' variable
        #Property of dialog is assigned as 'TopMost' so the dialog will display above any other windows
        $dirSave= $folderBrowse2.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True})) 
    
        #Code in 'If' statement only runs if user selects a location for the backup to be saved
        if ($dirSave -eq [Windows.Forms.DialogResult]::OK){

            #'SelectedPath' method used to get the path of the selected directory
            echo "Path selected:" $folderBrowse2.SelectedPath 
            echo ""

            #'Read-Host' used to display a message and wait for user input
            #The name input is then assigned to the 'BackupName' variable
            $backupName = Read-Host "What would you like the file to be called?"

            #Calls the format function
            format 

            echo ""
            echo "Starting backup process..."
            echo ""

            #Set the variable 'backupPath' to the path the user selected for the backup to be saved
            #and add the name the user entered to the end
            $backupPath= ($folderBrowse2.SelectedPath + "\" + $backupName)

            #Call 'encryptionOption' function and assign the value returned to 'encryptChoice'
            $encryptChoice = encryptionOption
 
            #Run 'If' statement if global variable 'encryptOption set to true;
            if ($Global:encryptOption -eq $true) {
                
                #Run code in the 'do' statement until the condition is met
                do{

                #Assign password entered to 'setPassword' variable
                # 'AsSecureString' paramter used to mask password
                $setPassword = Read-Host "Enter Password" -AsSecureString 

                #Password converted back from secure string object to a string
                # :: is used to reference static methods 
                $setPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($setPassword))
                
                #Code in do statement looped until user enters a password
                }until($setPassword -ne "")

            }
            
            #If global variable 'formatSelect' is 1 then use the zip format when backing up files
            if ($Global:formatSelection -eq 1) 
            {
                #Compress-7Zip accepts accepts the Path, ArchiveFileName, Format and Password parameters to create the backup 
                #'folderBrowse.SelectedPath' gets the path selected by the user using the folder dialog
                #BackupPath variable holds the full path of the backup location including the name entered by the user
                Compress-7Zip -Path $folderBrowse.SelectedPath -ArchiveFileName ($backupPath + ".zip")  -Format zip -Password $setPassword
            }

            #If global variable 'formatSelect' is 2 then use the 7zip format when backing up files
            elseif ($Global:formatSelection -eq 2) 
            {
                echo ""
                echo "Backing up..."

                #Compress-7Zip accepts accepts the Path, ArchiveFileName, Format and Password parameters to create the backup
                #BackupPath variable holds the full path of the backup location including the name entered by the user
                Compress-7Zip -Path $folderBrowse.SelectedPath -ArchiveFileName ($backupPath + ".7z")  -Format SevenZip -Password $setPassword
            }


            #If user chose to add encryption the encryption function will run
            if ($encryptChoice -eq "Y" -or $encryptChoice -eq "y")
            {
                encryption
            }

            #If user didn't want encryption the echo commands let the user know the file will not be encrypted
            #The user is returned back to the menu using the 'menuOptions' function
            elseif($encryptChoice -eq "N" -or $encryptChoice -eq "N")
            {
                echo ""
                echo "File will not be encrypted..."
                echo ""
                echo "Backup successful, your backup is now saved in $backupPath"
                echo ""
                echo "Returning to menu..."
                menuOptions
            }
        

    } #End of 'If' statement that checks if user selected a directory to save the backup in

    else{
        echo "Destination for backup to be saved wasn't selected...Returning to menu"
        menuOptions
    }
            
    } #End of 'If' statement that checks if user selected a directory to backup

    else{
        echo "No path was selected for backup...Returning to menu"
        menuOptions

    }
    } #end of backup function





function recovery{
    
    echo ""
    echo "Select the file or directory you would like to restore using the Folder Browser"
    
    #'New-Object' used to create the form for the Folder Browser Dialog                           
    $fileBrowse = New-Object System.Windows.Forms.OpenFileDialog   

    #Filter method used to only allow users to select files with .zip and .7z file extensions
    $fileBrowse.Filter = "Compressed Files | *.zip;*.7z"

    #'ShowDialog' is used to invoke the Folder Browser Dialog.
    #The output of the 'ShowDialog' method is assigned to the 'resSelect' variable
    $recSelect = $fileBrowse.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True}))       
    
    #FileName used to get the path of the selected file
    echo ""                                     
    echo "Path selected:" $fileBrowse.FileName
    echo ""

    #Code in 'If' statement only runs if user selects a file to restore
    if ($recSelect -eq [Windows.Forms.DialogResult]::OK){
        
        echo "Select the location for the recovery to be saved using the Folder Browser"
        echo "Note: You can enter a name for the restored file, the default is set to the current date"
        echo ""

        #'New-Object' used to create the form for the Folder Browser Dialog  
        $fileSave = New-Object System.Windows.Forms.SaveFileDialog
        
        #FileName used to get the path of the selected file and set it to the current date
        #-UFormat paramter used to edit date format to display day/month/year
        $fileSave.FileName = Get-Date -UFormat "%d-%m-%y"

         #'ShowDialog' is used to invoke the Save File Dialog
         #The output of the 'ShowDialog' method is assigned to the 'recSave' variable
         #Property of dialog is assigned as 'TopMost' so the dialog will display above any other windows
        $recSave= $fileSave.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True})) 


        #Code in 'If' statement only runs if user selects a location for recovery
        if ($recSave -eq [Windows.Forms.DialogResult]::OK){
  
            echo "Path selected:" $fileSave.FileName
            echo ""
            echo "Starting recovery process..."

            #::GetAttributes - Get static attributes of the file the user selected to backup
            #Convert attributes to string using 'ToString() method so they can be read, and check if
            #an attribute called 'Encrypted' exists. Save boolean output to encrypted variable
            $encrypted = [System.IO.File]::GetAttributes($fileBrowse.FileName).ToString().Contains("Encrypted")

            #If encrypted has a boolean value of true the 'If' statement runs and asks user to enter password
            if ($encrypted){
                
                #Assign password entered to 'setPassword' variable
                # 'AsSecureString' paramter used to mask password
                $recoveryPassword = Read-Host "Enter password" -AsSecureString

                #Password converted back from secure string object to a string
                # :: is used to reference static methods
                $recoveryPassword =[Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($recoveryPassword))
                
            } #end of 'If' statement that runs if file is encrypted

            #If file wasn't encrypted set the variable 'recoveryPassword' to an empty string.
            else {

                $recoveryPassword = ""
            }

            
            #Get full path of recovery save location using '$fileSave.FileName' and assign it to 'recSave' variable
            $recSave = $fileSave.FileName

            #Expand-7Zip accepts accepts the ArchiveFileName, TargetPath and Password parameters to recover the file(s)
            #'FileBrowse.fileName' gets full path of the file to be recovered
            #'recSave' contains full save of the location where the recovery will be saved
            #'recoveryPassword' is the password entered by the user
            # '*>$null' all cmdlet outputs from the Expand-7zip command are redirected to null as we don't want
            #them displayed in the shell
            Expand-7Zip -ArchiveFileName $fileBrowse.FileName -TargetPath $recSave -Password $recoveryPassword *>$null
            
            #The problem with the 7zip4PowerShell module is that there is no test for the password
            #So if the user enters the wrong password the recovery will still take place but the recovered files will be EMPTY
            #To fix this issue the following parameters of the 'Get-ChildItem' command where used to check if the recovered folder is empty

            #Get-ChildItem's parameters are used to get important information which is used to check if the recovered file is empty
            #recSave is the base folder we want to look at
            #Recurseused to get all children (sub-directories) -File lets the object know we are looking at files in this case
            #Pipe to 'Measure-Object' which allows for us to look at the length property and calculate the sum
            #The sum is calculated in bytes and stored in the 'checkSize' variable
            $checkSize = (Get-ChildItem $recSave -Recurse -File | Measure-Object -property length -sum).Sum

            #Code in while statement only runs if the recovered file was originally encrypted and if the 'checkSize' variable is
            #smaller than 500 bytes
            while ($encrypted -and $checkSize -le 500)
            
            {

                echo ""

                #Assign password entered to 'setPassword' variable
                # 'AsSecureString' paramter used to mask password
                $recoveryPassword = Read-Host "Enter password" -AsSecureString

                #Password converted back from secure string object to a string
                # :: is used to reference static methods 
                $recoveryPassword =[Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($recoveryPassword))
                
                #Remove-Item used to remove the recovered folder of the recovered file as it would be empty
                Remove-Item -Path $recSave -Recurse *>$null

                #Reattempt to expand the archive with the new password entered by user
                Expand-7Zip -ArchiveFileName $fileBrowse.FileName -TargetPath $recSave -Password $recoveryPassword *>$null
                
                #check if the recovered folder is still empty, if so the while loop will repeat
                $checkSize = (Get-ChildItem $recSave -Recurse -File | Measure-Object -property length -sum).Sum


            } #end of while loop

            echo ""
            echo "Recovery successful, your recovery is now saved in $recSave"
            echo ""
            echo "Returning to menu..."
            menuOptions
            
            } #end of if statement that runs when the user selects a location for recovery
            
        else{
            echo "Destination for recovery to be saved wasn't selected...Returning to menu"
            menuOptions
            }
            
    } #end of if statement that runs when the user selects a file to recover
    else{
        echo "There was no file selected for recovery...Returning to menu"
        menuOptions
        }
}


function encryptionOption{
    #Display a message and store user input in 'encryptChoice' variable
    $encryptChoice =Read-Host "Would you like to encrypt the file? (Y/y)/(N/n)"

    #if statement runs and sets global variable to true
    if ($encryptChoice -eq "Y" -or $encryptChoice -eq "y") 
    {
        $Global:encryptOption = $true
    }

    #elseif statement runs and sets global variable to false and 'setPassword' to an empty string
    elseif($encryptChoice -eq "N" -or $encryptChoice -eq "n")
    {
        $Global:encryptOption = $false
        $setPassword = ""
    }
    
    #Loop function until valid option selected
    else
    {
        echo "Invalid option selected"
        encryptionOption
    }
    #return the value of 'encryptChoice'
    return $encryptChoice


}

function encryption{

        #The 'If' statements are run depending on the format selected by the user

        if ($Global:formatSelection -eq 1)
        {
            #Cipher used to encrypt files
            #/e encrypts specified files or directories
            #/s perform operation on all sub-directories
            Cipher /e /s:$backupPath.zip *>$null #output stream redirected to null
        }

        elseif($Global:formatSelection -eq 2)
        {
            
            Cipher /e /s:$backupPath.7z *>$null #output stream redirected to null
        }

        echo ""
        echo "Starting encryption process..."
        echo ""
        echo "File has been encrypted..."
        echo ""
        echo "Backup successful, your backup is now saved in $backupPath"
        echo ""
        echo "Returning to menu..."
        menuOptions
        

}

function format{

echo ""
echo "1) .zip"
echo "2) .7zip"
echo ""

#Get user input using 'Read-Host' and save to global variable 'formatSelection'
$Global:formatSelection = Read-Host "Select the compression format you would like to use"

#'fileformat' variable set depending on user input for 'formatSelection'

    if ($Global:formatSelection -eq 1){
        $fileFormat = "Zip"
    }
            
    elseif($Global:formatSelection -eq 2) {
        $fileFormat ="SevenZip"
    }

    else{
        echo ""
        echo "Invalid menu option!"
        format
    }

}


function menuOptions{

    do {
        echo ""
        echo "Menu:"
        echo ""
        echo "1. Backup"
        echo "2. Restore"
        echo "3. Exit"
        echo ""

        #Get user input and store in 'option' variable
        $option = Read-Host "Please select a menu Option"

        #Repeat until a valid option is selected
        }until($option -eq 1 -or $option -eq 2 -or $option -eq 3)

    #Run the following if statements depending on user input for the 'option' variable
    if ($option -eq 1) {
        backup
    }

    elseif ($option -eq 2) {
        recovery
    }
    
    elseif($option -eq 3){
        echo ""
        echo "Exiting script..."
        echo ""
        exit
    }
}

function ASCII_Intro{

echo "  _____                       _____ _          _ _ "
echo " |  __ \                     / ____| |        | | |"
echo " | |__) |____      _____ _ _| (___ | |__   ___| | |"
echo " |  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |"
echo " | |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |"
echo " |_|__ \___/ \_/\_/_\___|_| |_____/|_| |_|\___|_|_|"
echo " |  _ \           | |                  ___         "
echo " | |_) | __ _  ___| | ___   _ _ __    ( _ )        "
echo " |  _ < / _\` |/ __| |/ / | | | '_ \   / _ \/\      "
echo " | |_) | (_| | (__|   <| |_| | |_) | | (_>  <      "
echo " |____/ \__,_|\___|_|\_\\__,_| .__/   \___/\/      "
echo " |  __ \         | |         | |                   "
echo " | |__) |___  ___| |_ ___  _ |_|___                "
echo " |  _  // _ \/ __| __/ _ \| '__/ _ \               "
echo " | | \ \  __/\__ \ || (_) | | |  __/               "
echo " |_|  \_\___||___/\__\___/|_|  \___|               "
echo "                                                   "
echo "                                                   "
echo "*Welcome*"
echo ""
echo "Current Date: ",$currentDate
echo ""
echo "Note: If this is your first time running the script please make sure to install the 7zip module."
echo "Details about the installation process are in the comments of the script"

}
#Run the Introduction echo's and the menuOptions as soon as the script starts
ASCII_Intro
menuOptions
