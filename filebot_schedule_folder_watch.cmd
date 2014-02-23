@echo OFF

GOTO EndComment
	FileBot Schedule Folder Watch Scheduler Script v1.4
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
	set "watchlist=C:\Progra~1\FileBot\cmdlets\watch_list.txt"
	set "watchlist2=%tmp%\watch_list_temp.txt"
	:: set watchsettings="C:\Program Files\FileBot\cmdlets\watch_settings.txt"
	set watchfile="C:\Progra~1\FileBot\cmdlets\watch.cmd"

GOTO DetermineJobType


:DetermineJobType

	:: determine if adding or removing a task

	set var1=%1
	set var1=%var1:^=^^%
	set var1=%var1:"=%

	set var2=%2
	set var2=%var2:"=%

	set var3=%var1:\\=%
	set var3=%var3:_=%
	set var3=%var3:\=_%
	set var3=%var3::=%
	set var3=%var3: =%
	set var3=%var3:(=%
	set var3=%var3:)=%
	set var3=%var3:;=%
	set var3=%var3:'=%
	set var3=%var3:.=%
	set var3=%var3:,=%
	set var3=%var3:-=%
	set var3=%var3:+=%
	set var3=%var3:{=%
	set var3=%var3:}=%
	set var3=%var3:[=%
	set var3=%var3:]=%
	set var3=%var3:!=%
	set var3=%var3:@=%
	set var3=%var3:#=%
	set var3=%var3:$=%
	set var3=%var3:^=%
	set var3=%var3:&=%


	if "%var2%"=="setnonmatch" (
		goto AskDetails
	) ELSE ( 
		if "%var2%"=="setmatch" (
			goto AskDetails
		) ELSE (
			if "%var2%"=="removetask" (
				goto RemoveTask
			) ELSE (
				GOTO ERR1
			)
		)
	)

GOTO ERR1


:AskDetails

	GOTO ask-metric

	:ask-metric

		call :inputbox "Please enter 1 to schedule in minutes, 2 to schedule in hours, 3 to schedule in days, 4 to schedule in weeks, or 5 to schedule in months" "What Are We Counting In?" "2"

		if NOT "%Input%"=="" (
			GOTO metric-check
		) ELSE (
			GOTO metric-default
		)

		:metric-check
		SET /A TestVal="%Input%"*1

		if "%TestVal%"=="%Input%" (
			GOTO metric-fixed
		) ELSE (
			:: input was not a number
			GOTO metric-default
		)

		:metric-fixed
			set "scanmetric=%Input%"
			IF %scanmetric% LEQ 0 (
				goto metric-default
			) ELSE IF %scanmetric% EQU 1 (
				set "scanmetric=minute"
				set "metricterm=minutes"
				set "termlimits=Limit: 1 - 1439 %metricterm%"
			) ELSE IF %scanmetric% EQU 2 (
				set "scanmetric=hourly"
				set "metricterm=hours"
				set "termlimits=Limit: 1 - 23 %metricterm%"
			) ELSE IF %scanmetric% EQU 3 (
				set "scanmetric=daily"
				set "metricterm=days"
				set "termlimits=Limit: 1 - 365 %metricterm%"
			) ELSE IF %scanmetric% EQU 4 (
				set "scanmetric=weekly"
				set "metricterm=weeks"
				set "termlimits=Limit: 1 - 52 %metricterm%"
			) ELSE IF %scanmetric% EQU 5 (
				set "scanmetric=monthly"
				set "metricterm=months"
				set "termlimits=Limit: 1 - 12 %metricterm%"
			) ELSE (
				goto metric-default
			)
			echo New Scheduling Metric: %scanmetric% >> %logfile%
		GOTO ask-units

		:metric-default	
			set "scanmetric=daily"
			set "metricterm=days"
			set "termlimits=Limit: 1 - 365 %metricterm%"
			echo No Valid Scheduling Metric Detected. Defaulting to %scanmetric% >> %logfile%
		GOTO ask-units

	:ask-units

		call :inputbox "Schedule scan every how many %metricterm%? (%termlimits%)" "How many %metricterm%?" "1"

		if NOT "%Input%"=="" (
			GOTO units-check
		) ELSE (
			GOTO units-default
		)

		:units-check
		SET /A TestVal="%Input%"*1

		if "%TestVal%"=="%Input%" (
			GOTO units-fixed
		) ELSE (
			:: input was not a number
			GOTO units-default
		)

		:units-fixed

			set "scanunits=%Input%"

			if "%scanmetric%"=="minute" (
				:: check against minute limits between 1 - 1439
				IF %scanunits% LEQ 0 (goto units-default)
				IF %scanunits% GEQ 1440 (goto units-default)
			)

			if "%scanmetric%"=="hourly" (
				:: check against hourly limits between 1 - 23
				IF %scanunits% LEQ 0 (goto units-default)
				IF %scanunits% GEQ 24 (goto units-default)
			)

			if "%scanmetric%"=="daily" (
				:: check against daily limits between 1 - 365
				IF %scanunits% LEQ 0 (goto units-default)
				IF %scanunits% GEQ 366 (goto units-default)
			)

			if "%scanmetric%"=="weekly" (
				:: check against weekly limits between 1 - 52
				IF %scanunits% LEQ 0 (goto units-default)
				IF %scanunits% GEQ 53 (goto units-default)
			)

			if "%scanmetric%"=="monthly" (
				:: check against monthly limits between 1 - 12
				IF %scanunits% LEQ 0 (goto units-default)
				IF %scanunits% GEQ 13 (goto units-default)
				)
			)

			echo Number of %metricterm%: %scanunits% >> %logfile%

		GOTO CreateTask

		:units-default
			set "scanunits=1"
			echo No Valid Metric Detected. Defaulting to %scanunits% >> %logfile%
		GOTO CreateTask

	if not errorlevel 0 GOTO ERR1

GOTO CreateTask


:CreateTask

	ECHO Creating Folder Watch Task for %var1% >> %logfile%
	schtasks /create /sc %scanmetric% /mo %scanunits% /tn "FileBot-Watch %var3%" /tr "cmd /c call %watchfile% \"%var1%\" \"%var2%\"" /F >> %logfile%
	echo FileBot-Watch %var3%>> "%watchlist%"
	if not errorlevel 0 GOTO ERR1
	ECHO Task Created >> %logfile%

GOTO ALLOK


:RemoveTask

	ECHO Deleting Folder Watch for %var1% >> %logfile%
	:: remove task for this folder and remove it from the watch list
	schtasks /delete /TN "FileBot-Watch %var3%" /f >> %logfile%
	findstr /v /i "%var3%" "%watchlist%" > "%watchlist2%"
	type "%watchlist2%" > "%watchlist%"
	del "%watchlist2%"
	ECHO Task Deleted >> %logfile%

	if not errorlevel 0 GOTO ERR1

GOTO ALLOK


:InputBox
	set input=
	set default=%~3
	set heading=%~2
	set message=%~1
	echo wscript.echo inputbox(WScript.Arguments(0),WScript.Arguments(1),WScript.Arguments(2)) >"%~dp0\input.vbs"
	for /f "tokens=* delims=" %%a in ('cscript //nologo "%~dp0\input.vbs" "%message%" "%heading%" "%default%"') do set input=%%a
	del %~dp0\input.vbs
exit /b


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