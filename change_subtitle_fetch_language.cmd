@echo OFF

GOTO EndComment
	FileBot Context Menu Subtitle Fetch Language Selector v1.1

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
			GOTO UACPrompt1
		 ) else (
			echo Checking profile instead...
			GOTO DirCheck2
		)

	:DirCheck2

		copy /Y NUL "%USERPROFILE%\.writable" > NUL 2>&1 && set WRITEOK=1
		IF DEFINED WRITEOK ( 
			GOTO UACPrompt2
		 ) else (
			echo Checking temp instead...
			GOTO DirCheck3
		)

	:DirCheck3

		copy /Y NUL "%tmp%\.writable" > NUL 2>&1 && set WRITEOK=1
		IF DEFINED WRITEOK ( 
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

GOTO ASKLANG


:ASKLANG

	set logfile="%tmp%\filebot_sub_fetch_lang_change.txt"

	echo --------------------------------------- >> %logfile%
	echo Context Menu Subtitle Language Selector >> %logfile%
	echo Date: %date% >> %logfile%
	echo --------------------------------------- >> %logfile%
	echo. >> %logfile%

	GOTO request-lang

	:request-lang
	call :inputbox "Please enter the preferred subtitle language using the two digit language code" "Subtitle Language Selection" "en"

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

GOTO CHANGELANG


:CHANGELANG

	echo Updating Language Settings >> %logfile%

	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f

	if not errorlevel 0 GOTO ERR1
	
	echo Update Successful. >> %logfile%

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
EXIT /B