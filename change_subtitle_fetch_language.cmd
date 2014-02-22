@echo OFF

GOTO EndComment
	FileBot Context Menu Subtitle Fetch Language Selector v1.2

	Written by CapriciousSage (Ithiel)
	Requires Filebot to be installed in C:\Program Files\FileBot\
	Requires advanced context menu v1.2 or higher
	This file requires Administrative Privileges

	FileBot written by rednoah (Reinhard Pointner)
	FileBot: http://www.filebot.net

	Help Support FileBot!
	Please Donate via PayPal to reinhard.pointner@gmail.com

	No warranty given or implied, use at your own risk.
	Last Updated: 14/01/2014
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
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%~dp0\getadmin.vbs"

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
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%USERPROFILE%\getadmin.vbs"

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
		echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%tmp%\getadmin.vbs"

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

GOTO ASKCOUNT

:ASKCOUNT

	set logfile="%tmp%\filebot_sub_fetch_lang_change.txt"
	set WatchSetting="C:\Program Files\FileBot\cmdlets\watch_settings.txt"

	echo --------------------------------------- >> %logfile%
	echo Context Menu Subtitle Language Selector >> %logfile%
	echo Date: %date% >> %logfile%
	echo --------------------------------------- >> %logfile%
	echo. >> %logfile%

	GOTO request-lang-count

	:request-lang-count
	call :inputbox "How many subtitle languages do you want to fetch?" "Number of Subtitle Language" "1"

		if NOT "%Input%"=="" (
			GOTO count-check
		) ELSE (
			GOTO count-default
		)

		:count-check
		SET /A TestVal="%Input%"*1

		if "%TestVal%"=="%Input%" (
			GOTO check-min
		) ELSE (
			:: input was not a number
			GOTO count-default
		)

		:check-min
		if %Input% GEQ 1 (
			:: one or more
			GOTO count-fixed
		) ELSE (
			:: less than one
			GOTO count-default
		)

		:count-fixed
			set "langcount=%Input%"
			echo Subtitle Languages Required: %langcount% >> %logfile%
		GOTO finished-count-output

		:count-default	
			set "langcount=1"
			echo Invalid Input Detected. Defaulting to %langcount% >> %logfile%
		GOTO finished-count-output

		:finished-count-output

	if not errorlevel 0 GOTO ERR1

GOTO StartLoop
	
	
:StartLoop

	SET COUNT=0

	:CountLoop
	
		if %COUNT% GEQ %langcount% (
			:: done checking for subtitles
			GOTO ALLOK
		) ELSE (
			:: input was not a number
			GOTO MAIN-PROCESS
		)

		:MAIN-PROCESS

			call :ASKLANG

			if "%COUNT%"=="0" (
				call :CHANGELANG
			) ELSE (
				call :CHANGELANGMULTI
			)

		SET /A COUNT+=1
		
	if not errorlevel 0 GOTO ERR1

GOTO CountLoop


:ASKLANG
	set /a subCount=%COUNT%+1

	set subCountChk1=%subCount:~-2,2%

	IF %subCountChk1% EQU 11 ( 
		GOTO set-th
	) ELSE ( 
		IF %subCountChk1% EQU 12 ( 
			GOTO set-th
		) ELSE ( 
			IF %subCountChk1% EQU 13 ( 
				GOTO set-th 
			) ELSE ( 
				GOTO set-other
			)
		)
	)

	:set-th
		set "subCount=%subCount%th"
	GOTO lang-output

	:set-other
		set subCountChk2=%subCount:~-1,1%
		IF %subCountChk2% EQU 0 (set "subCount=%subCount%th")
		IF %subCountChk2% EQU 1 (set "subCount=%subCount%st")
		IF %subCountChk2% EQU 2 (set "subCount=%subCount%nd")
		IF %subCountChk2% EQU 3 (set "subCount=%subCount%rd")
		IF %subCountChk2% GEQ 4 (set "subCount=%subCount%th")
	GOTO lang-output

	:lang-output
		call :inputbox "Please enter the %subCount% of %langcount% preferred subtitle language(s) using the two digit language code" "Subtitle Language Selection" "en"

		if NOT "%Input%"=="" (
			GOTO lang-fixed
		) ELSE (
			GOTO lang-default
		)

		:lang-fixed
			set "newlang=%Input%"
			echo New Subtitle Language: %newlang% >> %logfile%
		GOTO finished-output

		:lang-default	
			set "newlang=en"
			echo No Language Detected. Defaulting to %newlang% >> %logfile%
		GOTO finished-output

	:finished-output

	if not errorlevel 0 GOTO ERR1
exit /b


:CHANGELANG
	echo Updating Language Settings (%newlang%) >> %logfile%

	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f

	set WatchSettingLine1=cmd /c filebot -script fn:suball \"PATH_HERE\" -non-strict --lang %newlang% --log-file context.log
	set WatchSettingLine2=cmd /c filebot -script fn:suball \"PATH_HERE\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO

	echo "%WatchSettingLine1%" > %WatchSetting%
	echo "%WatchSettingLine2%" >> %WatchSetting%

	if not errorlevel 0 GOTO ERR1
	
	echo Update Successful (%newlang%). >> %logfile%
exit /b


:CHANGELANGMULTI
	echo Updating Language Settings (%newlang%) >> %logfile%

	set "File0203add=cmd /c filebot -get-subtitles "%%1" -non-strict --lang %newlang% --log-file context.log"
	set "File0204add=cmd /c filebot -get-subtitles "%%1" -non-strict --lang %newlang% --log-file context.log"
	set "Folder0203add=cmd /c filebot -script fn:suball "%%1" -non-strict --lang %newlang% --log-file context.log"
	set "Folder0204add=cmd /c filebot -script fn:suball "%%1" -non-strict --lang %newlang% --log-file context.log"
	set WatchSettingAdd=cmd /c filebot -script fn:suball \"PATH_HERE\" -non-strict --lang %newlang% --log-file context.log

	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles\command" /ve`) DO (
	    set File0203current=%%A %%B
	    )
	set "File0203current=%File0203current% ^&^& %File0203add%"
	set "File0203current=%File0203current:"=^\"%"
	set "File0203current=%File0203current:^=%"

	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles\command" /ve`) DO (
	    set File0204current=%%A %%B
	    )
	set "File0204current=%File0204current% ^&^& %File0204add%"
	set "File0204current=%File0204current:"=^\"%"
	set "File0204current=%File0204current:^=%"

	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles\command" /ve`) DO (
	    set Folder0203current=%%A %%B
	    )
	set "Folder0203current=%Folder0203current% ^&^& %Folder0203add%"
	set "Folder0203current=%Folder0203current:"=^\"%"
	set "Folder0203current=%Folder0203current:^=%"

	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles\command" /ve`) DO (
	    set Folder0204current=%%A %%B
	    )
	set "Folder0204current=%Folder0204current% ^&^& %Folder0204add%"
	set "Folder0204current=%Folder0204current:"=^\"%"
	set "Folder0204current=%Folder0204current:^=%"

	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "%File0203current%" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "%File0204current%" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "%Folder0203current%" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "%Folder0204current%" /f

	set "WatchSettingLine1=%WatchSettingLine1%; %WatchSettingAdd%"
	set "WatchSettingLine2=%WatchSettingLine2%; %WatchSettingAdd%"

	echo "%WatchSettingLine1%" > %WatchSetting%
	echo "%WatchSettingLine2%" >> %WatchSetting%

	if not errorlevel 0 GOTO ERR1
	
	echo Update Successful (%newlang%). >> %logfile%
exit /b


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
EXIT /B