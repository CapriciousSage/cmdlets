@echo OFF

GOTO EndComment
	FileBot Automatic jar file Updater v1.2

	Written by CapriciousSage (Ithiel)
	Modified by Akkifokkusu
	Requires Filebot to be installed in C:\Program Files\FileBot\
	This file requires Administrative Privileges
	Note: The only file that this tool updates is FileBot.jar

	FileBot written by rednoah (Reinhard Pointner)
	FileBot: http://www.filebot.net

	Help Support FileBot!
	Please Donate via PayPal to reinhard.pointner@gmail.com

	No warranty given or implied, use at your own risk.
	Last Updated: 04/01/2014
:EndComment

:ADMIN-CHECK

	:: BatchGotAdmin
	:-------------------------------------
	REM  --> Check for permissions
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

	REM --> If error flag set, we do not have admin.
	if '%errorlevel%' NEQ '0' (
	    echo Requesting administrative privileges...
	    goto UACPrompt
	) else ( goto gotAdmin )

	:UACPrompt
	    echo Set UAC = CreateObject^("Shell.Application"^) > "%~dp0\getadmin.vbs"
	    set params = %*:"=""
	    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%~dp0\getadmin.vbs"

	    "%~dp0\getadmin.vbs"
	    del "%~dp0\getadmin.vbs"
	    exit /B

	:gotAdmin
	    pushd "%CD%"
	    CD /D "%~dp0"
	:--------------------------------------

GOTO DOWNLOAD


:DOWNLOAD

	set logfile="%tmp%\filebot_automatic_updater.txt"
	set downloadURL="http://sourceforge.net/projects/filebot/files/filebot/HEAD/FileBot.jar"

	echo Downloading Latest Filebot.jar from %downloadURL% >> %logfile%
	bitsadmin.exe /transfer "Download_FileBot" %downloadURL% "%temp%\FileBot.jar"

	if not errorlevel 0 GOTO ERR1
	
	echo Download successful. >> %logfile%

	IF EXIST "C:\Program Files\FileBot\FileBot_old.jar" (
		echo Deleting "C:\Program Files\FileBot\FileBot_old.jar" >> %logfile%
		del "C:\Program Files\FileBot\FileBot_old.jar"
	) ELSE (
		echo No FileBot_old.jar file to Delete >> %logfile%
	)

	echo Renaming current FileBot.jar to FileBot_old.jar >> %logfile%
	ren "C:\Program Files\FileBot\FileBot.jar" FileBot_old.jar

	echo Installing new Filebot.jar >> %logfile%
	move "%temp%\FileBot.jar" "C:\Program Files\FileBot\FileBot.jar"
	
	echo FileBot Update Complete >> %logfile%

GOTO ALLOK


:ERR1
	echo **** Warning: Something Didn't Work. Please Confirm Settings **** >> %logfile%
	echo. >> %logfile%
	echo Press any key to terminate install ...
	pause>nul
GOTO FINISH


:ALLOK
	echo ****** Job completed successfully ***** >> %logfile%
	echo. >> %logfile%
GOTO FINISH


:FINISH
ECHO EXIT /B