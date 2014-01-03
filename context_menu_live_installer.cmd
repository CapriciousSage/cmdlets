@echo OFF

GOTO EndComment
	FileBot Advanced Context Menu v1.1a (Live Installer)
	Written by CapriciousSage (Ithiel) with assistance from rednoah (Reinhard Pointner)
	Requires Windows 7 or higher.
	This file requires Administrative Privileges

	FileBot written by rednoah (Reinhard Pointner)
	FileBot: http://www.filebot.net

	Help Support FileBot!
	Please Donate via PayPal to reinhard.pointner@gmail.com

	No warranty given or implied, use at your own risk.
	Last Updated: 03/01/2014
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
	    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	    set params = %*:"=""
	    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

	    "%temp%\getadmin.vbs"
	    del "%temp%\getadmin.vbs"
	    exit /B

	:gotAdmin
	    pushd "%CD%"
	    CD /D "%~dp0"
	:--------------------------------------

GOTO CALL-SETUP

:CALL-SETUP

	set logfile="%tmp%\filebot_context_menu_setup_log.txt"
	
	echo Downloading Latest Setup File >> %logfile%

	bitsadmin.exe /transfer "Download_Install" "https://github.com/CapriciousSage/cmdlets/raw/master/context_menu_setup.cmd" "%tmp%\context_menu_setup.cmd"

	echo Running Setup File >> %logfile%
	call "%tmp%\context_menu_setup.cmd"

	echo Deleting Temporary Setup File >> %logfile%
	del "%tmp%\context_menu_setup.cmd"

	if not errorlevel 0 GOTO ERR1

	echo Cloud Managed Install Complete >> %logfile%

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