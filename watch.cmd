@echo OFF

GOTO EndComment
	FileBot Schedule Folder Watch Script v1.4
	Written by CapriciousSage (Ithiel), inspired by Katates
	Requires Windows 7 or higher.
	This file requires Administrative Privileges

	FileBot written by rednoah (Reinhard Pointner)
	FileBot: http://www.filebot.net

	Help Support FileBot!
	Please Donate via PayPal: http://www.filebot.net/donate.html

	No warranty given or implied, use at your own risk.
	Last Updated: 24/02/2014
:EndComment

:ADMIN-CHECK

	:: BatchGotAdmin
	:-------------------------------------
	REM  --> Check for permissions
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

	REM --> If error flag set, we do not have admin.
	if '%errorlevel%' NEQ '0' (
	    echo Requesting administrative privileges...
	    GOTO DirCheck1
	) else ( GOTO gotAdmin )

	:DirCheck1

		copy /Y NUL "%~dp0\.writable" > NUL 2>&1 && set WRITEOK=1
		IF DEFINED WRITEOK ( 
			del "%~dp0\.writable"
			GOTO UACPrompt1
		 ) else (
			echo Checking profile instead...
			GOTO DirCheck2
		)

	:DirCheck2

		copy /Y NUL "%USERPROFILE%\.writable" > NUL 2>&1 && set WRITEOK=1
		IF DEFINED WRITEOK ( 
			del "%USERPROFILE%\.writable"
			GOTO UACPrompt2
		 ) else (
			echo Checking temp instead...
			GOTO DirCheck3
		)

	:DirCheck3

		copy /Y NUL "%tmp%\.writable" > NUL 2>&1 && set WRITEOK=1
		IF DEFINED WRITEOK ( 
			del "%tmp%\.writable"
			GOTO UACPrompt3
		 ) else (
			GOTO UACFailed
		)

	:UACPrompt1

		echo Set UAC = CreateObject^("Shell.Application"^) > "%~dp0\getadmin.vbs"
		set params = %*:"=""
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params% "%1" "%2"", "", "runas", 1 >> "%~dp0\getadmin.vbs"

		"%~dp0\getadmin.vbs"

		if '%errorlevel%' NEQ '0' (
			del "%~dp0\getadmin.vbs"
			GOTO DirCheck2
		) else ( GOTO UACPrompt1Complete )

		:UACPrompt1Complete
			del "%~dp0\getadmin.vbs"
			exit /b
			GOTO gotAdmin

	:UACPrompt2

		echo Set UAC = CreateObject^("Shell.Application"^) > "%USERPROFILE%\getadmin.vbs"
		set params = %*:"=""
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params% "%1" "%2"", "", "runas", 1 >> "%USERPROFILE%\getadmin.vbs"

		"%USERPROFILE%\getadmin.vbs"

		if '%errorlevel%' NEQ '0' (
			del "%USERPROFILE%\getadmin.vbs"
			GOTO DirCheck3
		) else ( GOTO UACPrompt2Complete )

		:UACPrompt2Complete
			del "%USERPROFILE%\getadmin.vbs"
			exit /b
			GOTO gotAdmin

	:UACPrompt3

		echo Set UAC = CreateObject^("Shell.Application"^) > "%tmp%\getadmin.vbs"
		set params = %*:"=""
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params% "%1" "%2"", "", "runas", 1 >> "%tmp%\getadmin.vbs"

		"%tmp%\getadmin.vbs"

		if '%errorlevel%' NEQ '0' (
			del "%tmp%\getadmin.vbs"
			GOTO UACFailed
		) else ( GOTO UACPrompt3Complete )

		:UACPrompt3Complete
			del "%tmp%\getadmin.vbs"
			exit /b
			GOTO gotAdmin

	:UACFailed
		echo Upgrading to admin privliages failed.
		echo Please right click the file and run as administrator.
		echo PAUSE
		GOTO FINISH

	:gotAdmin
		pushd "%CD%"
		CD /D "%~dp0"
	:--------------------------------------

GOTO SETUP

:SETUP

	set logfile="%tmp%\filebot_watch_script_log.txt"
	set watchsettings="C:\Program Files\FileBot\cmdlets\watch_settings.txt"

GOTO DetermineJobType


:DetermineJobType

	:: determine if adding or removing a task

	set var1=%1
	set var1=%var1:"=%

	set var2=%2
	set var2=%var2:"=%

	set var3=%var1:\=-%
	set var3=%var3::=%

	if "%var2%"=="setnonmatch" (
		goto ScheduleNonMatch
	) ELSE ( 
		if "%var2%"=="setmatch" (
			goto ScheduleMatch
		) ELSE (
			GOTO ERR1
			)
		)
	)

GOTO ERR1

:ScheduleNonMatch

	set /p nonmatch=<%watchsettings%
	call set nonmatch=%%nonmatch:PATH_HERE=%var1%%%
	call set nonmatch=%nonmatch:~0,-1%
	ECHO Scanning Folder: %var1% >> %logfile%

	powershell %nonmatch%; exit

	if not errorlevel 0 GOTO ERR1
	ECHO Scan Complete Folder: %var1% >> %logfile%

GOTO ALLOK


:ScheduleMatch

	for /f "tokens=*" %%i in ('findstr MATCH_VIDEO %watchsettings%') do set match=%%i
	call set match=%%match:PATH_HERE=%var1%%%
	call set match=%match:~0,-1%
	ECHO Scanning Folder: %var1% >> %logfile%

	powershell %match%; exit

	if not errorlevel 0 GOTO ERR1
	ECHO Scan Complete Folder: %var1% >> %logfile%

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
:: %logfile%
EXIT /B