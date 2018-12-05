@echo off

echo "1.Backup" 
echo "2.Restore" 

rem Saves user input in %menuOption variable
set /p menuOption= "Select menu option: 

if %menuOption%==1 (

	
goto :Validation


	:Validation
	set /p dirfile= "Specifiy the directory or file you wish to backup: "
	if NOT EXIST "%dirfile%\" (
	
		echo "Invalid directory"
		goto :Validation
		
	) ELSE (
		echo "it exists!!!!"

		)

)

