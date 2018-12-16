#Use "Install-Module -Name 7Zip4Powershell -RequiredVersion 1.8.0" to install the 7zip PowerShell module
#Load pre-built form assembly
Add-Type -AssemblyName System.Windows.Forms
#currentDate = Get-Date -UFormat "%d/%m/%y"
$Global:formatSelection = ""
$GLobal:encryptOption = ""
function backup{
    echo ""
    echo "Select the file or directory you would like to backup using the Folder Browser"

    #'New-Object' used to create the form for the Folder Browser Dialog                           
    $folderBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
    #$folderBrowse.Description = "Select file or directory to backup"        

    #'ShowDialog' is used to invoke the Folder Browser Dialog.
    #The output of the 'ShowDialog' method is assigned to the 'dirSelect' variable
    $dirSelect = $folderBrowse.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True}))       
    
    #'SelectedPath' used to get the directory of the selected folder/file and save it to 'DirSelect' variable 
    echo ""                                     
    echo "Path selected:" $folderBrowse.SelectedPath 
    echo ""

    if ($dirSelect -eq [Windows.Forms.DialogResult]::OK){
        
        echo "Select the location for the backup to be saved using the Folder Browser"
        $folderBrowse2 = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowse2.Description = "Select location for the backup to be saved"
        echo ""
        $dirSave= $folderBrowse2.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True})) 
    
        if ($dirSave -eq [Windows.Forms.DialogResult]::OK){
            echo "Path selected:" $folderBrowse2.SelectedPath 
            echo ""

            $backupName = Read-Host "What would you like the file to be called?"
            format #Calls the format function
            echo ""
            echo "Starting backup process..."
            echo ""

            $backupPath= ($folderBrowse2.SelectedPath + "\" + $backupName)
            $encryptChoice = encryptionOption
 
            if ($Global:encryptOption -eq $true) {
                do{
                $setPassword = Read-Host "Enter Password" -AsSecureString 
                $setPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($setPassword))
                }until($setPassword -ne "")

            }
  
            if ($Global:formatSelection -eq 1) 
            {
                Compress-7Zip -Path $folderBrowse.SelectedPath -ArchiveFileName ($backupPath + ".zip")  -Format zip -Password $setPassword
            }

            elseif ($Global:formatSelection -eq 2) 
            {
                Compress-7Zip -Path $folderBrowse.SelectedPath -ArchiveFileName ($backupPath + ".7z")  -Format SevenZip -Password $setPassword
            }



            if ($encryptChoice -eq "Y" -or $encryptChoice -eq "y")
            {
                encryption
            }

            elseif($encryptChoice -eq "N" -or $encryptChoice -eq "N")
            {
                echo ""
                echo "File will not be encrypted..."
                echo "Backup successful, your backup is now saved in $backupPath"
                menuOptions
            }
        

    }

    else{
        echo "Destination for backup to be saved wasn't selected...Returning to menu"
        menuOptions
    }
            
    }

    else{
        echo "No path was selected for backup...Returning to menu"
        menuOptions

    }
    } #end of backup function


function recovery{
    
    echo ""
    echo "Select the file or directory you would like to restore using the Folder Browser"
    
    #'New-Object' used to create the form for the Folder Browser Dialog                           
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog   

    $fileBrowser.Filter = "Compressed Files | *.zip;*.7z"

    #'ShowDialog' is used to invoke the Folder Browser Dialog.
    #The output of the 'ShowDialog' method is assigned to the 'resSelect' variable
    $recSelect = $fileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True}))       
    
    #'SelectedPath' used to get the directory of the selected folder/file and save it to 'DirSelect' variable 
    echo ""                                     
    echo "Path selected:" $fileBrowser.FileName
    echo ""

    if ($recSelect -eq [Windows.Forms.DialogResult]::OK){
        
        echo "Select the location for the recovery to be saved using the Folder Browser"
        echo "Note: You can enter a name for the restored file, the default is set to the current date"
        echo ""

        $fileSaver = New-Object System.Windows.Forms.SaveFileDialog
        
        $fileSaver.FileName = Get-Date -UFormat "%d-%m-%y"
        $fileSaver.Filter = ""
        $recSave= $fileSaver.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True})) 


        if ($recSave -eq [Windows.Forms.DialogResult]::OK){
  
            echo "Path selected:" $fileSaver.FileName
            echo ""
            echo "Starting recovery process..."

            $encrypted = [System.IO.File]::GetAttributes($fileBrowser.FileName).ToString().Contains("Encrypted")

            if ($encrypted){
                $recoveryPassword = Read-Host "Enter password" -AsSecureString

                $recoveryPassword =[Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($recoveryPassword))
                
            }

            else {
                $recoveryPassword = ""
            }

            $recSave = $fileSaver.FileName

            echo $fileBrowser.FileName
            echo $recSave
            Expand-7Zip -ArchiveFileName $fileBrowser.FileName -TargetPath $recSave -Password $recoveryPassword *>$null
            Out-File -FilePath $recSave\recoveryTest.txt
            
            #The problem with the 7zip4PowerShell module is that there is no test for the password
            #So if the user enters the wrong password the recovery will still take place but the recovered files will be EMPTY
            #To fix this issue the following parameters of the 'Get-ChildItem' command where used to check if the recovered folder is empty.

            $checkSize = (Get-ChildItem $recSave -Recurse -File | Measure-Object -property length -sum).Sum
            echo $checkSize

            while ($checkSize -le 2){
                Remove-Item -Path $recSave -Recurse
                echo "Invalid password entered"
                echo ""
                $recoveryPassword = Read-Host "Enter password" -AsSecureString
                $recoveryPassword =[Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($recoveryPassword))
                
                Expand-7Zip -ArchiveFileName $fileBrowser.FileName -TargetPath $recSave -Password $recoveryPassword *>$null
                $checkSize = (Get-ChildItem $recSave -Recurse -File | Measure-Object -property length -sum).Sum

            }
            echo "Recovery successful, your recovery is now saved in $recSave"
            menuOptions
            }
            
        else{
            echo "Destination for recovery to be saved wasn't selected...Returning to menu"
            menuOptions
            }
            
    }
    else{
        echo "There was no file selected for recovery...Returning to menu"
        menuOptions
        }
}

function encryptionOption{

    $encryptChoice =Read-Host "Would you like to encrypt the file?(Y/y)/(N/n)"

    if ($encryptChoice -eq "Y" -or $encryptChoice -eq "y") 
    {
        $Global:encryptOption = $true
    }

    elseif($encryptChoice -eq "N" -or $encryptChoice -eq "n")
    {
        $Global:encryptOption = $false
        $setPassword = ""
    }
    

    else
    {
        echo "Invalid option selected"
        encryptionOption
    }
    return $encryptChoice


}

function encryption{


        if ($Global:formatSelection -eq 1)
        {
            echo "$backupPath"
            Cipher /e /s:$backupPath.zip *>$null #output stream redirected to null
        }

        elseif($Global:formatSelection -eq 2)
        {
            Cipher /e /s:$backupPath.7z *>$null #output stream redirected to null
        }

        echo ""
        echo "Encrypting File..."
        echo ""
        echo "File has been encrypted..."
        echo ""
        echo "Backup successful, your backup is now saved in $backupPath"
        menuOptions

}

function format{

echo ""
echo "1) .zip"
echo "2) .7zip"
echo ""

$Global:formatSelection = Read-Host "Select the compression format you would like to use"

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

        #Get user input an store in 'option' variable
        $option = Read-Host "Please select a menu Option"
        }until($option -eq 1 -or $option -eq 2 -or $option -eq 3)

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

}
ASCII_Intro
menuOptions




