echo "1. Backup"
echo "2. Restore"
echo ""

#Get user input an store in 'option' variable
$option = Read-Host "Please select a menu Option" 

#Load pre-built form assembly
Add-Type -AssemblyName System.Windows.Forms  

if($option -eq 1){ #Backup Option
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
            echo ""
            echo "Starting backup process..."

 
            $tmpDirSave = $folderBrowse2.SelectedPath
            Compress-Archive -Path $folderBrowse.SelectedPath -DestinationPath $tmpDirSave\$backupName -Force
            echo "Backup successful, your backup is now saved in $tmpDirSave\$backupName"
            }
            
        else{
            echo "Destination for backup to be saved wasn't selected...Exiting script"
            }
            
    }

    else{
        echo "No path was selected for backup...Exiting script"
    }

    }#end of option1


    

elseif($option -eq 2){ #Recovery Option
    
    echo ""
    echo "Select the file or directory you would like to restore using the Folder Browser"
    
    #'New-Object' used to create the form for the Folder Browser Dialog                           
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog   

    #'ShowDialog' is used to invoke the Folder Browser Dialog.
    #The output of the 'ShowDialog' method is assigned to the 'resSelect' variable
    $recSelect = $fileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True}))       
    
    #'SelectedPath' used to get the directory of the selected folder/file and save it to 'DirSelect' variable 
    echo ""                                     
    echo "Path selected:" $fileBrowser.FileName
    echo ""

    if ($recSelect -eq [Windows.Forms.DialogResult]::OK){
        
        echo "Select the location for the recovery to be saved using the Folder Browser"
        echo "Note: You must enter a name for the recovery"
        $fileSaver = New-Object System.Windows.Forms.SaveFileDialog
        #$fileSaver.Filter
        echo ""
        $recSave= $fileSaver.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $True})) 

        if ($recSave -eq [Windows.Forms.DialogResult]::OK){
            echo "Path selected:" $fileSaver.FileName
            echo ""
            echo "Starting recovery process..."

 
            $tmpRecSave = $fileSaver.FileName
            Expand-Archive -Path $fileBrowser.FileName -DestinationPath $tmpRecSave\$recoveryName
            echo "Recovery successful, your recovery is now saved in $tmpRecSave\$recoveryName"
            }
            
        else{
            echo "Destination for recovery to be saved wasn't selected...Exiting script"
            }
            
    }

    else{
        echo "No path was selected for recovery...Exiting script"
    }
}
else{
    echo "You can only type in a number displayed on the menu"
}
