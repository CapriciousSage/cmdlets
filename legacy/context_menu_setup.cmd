@echo OFF

GOTO EndComment
	FileBot Advanced Context Menu v1.3
	Written by CapriciousSage (Ithiel) with assistance from rednoah (Reinhard Pointner)
	Requires Windows 7 or higher.
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

GOTO SETUP


:SETUP

	set logfile="%tmp%\filebot_context_menu_setup_log.txt"
	set outputfile="C:\Program Files\FileBot\cmdlets\output.txt"
	set oslogin="C:\Program Files\FileBot\cmdlets\opensubtitles_login.cmd"
	set remlangtag="C:\Program Files\FileBot\cmdlets\remove-language-tag.cmd"
	:: set newline=^& echo.
	mkdir "C:\Program Files\FileBot\cmdlets"

	echo --------------------------- >> %logfile%
	echo Advanced Context Menu Setup >> %logfile%
	echo Date: %date% >> %logfile%
	echo --------------------------- >> %logfile%
	echo. >> %logfile%

	echo set WshShell = WScript.CreateObject("WScript.Shell") > %~dp0\tmp.vbs
	echo WScript.Quit (WshShell.Popup( "How would you like to proceed?" + vbCRLF + "   - Select Yes to install" + vbCRLF + "   - Select No to uninstall" + vbCRLF + "   - Select Cancel to exit without making changes" ,,"Advanced Context Menu Setup", 3+32)) >> %~dp0\tmp.vbs
	cscript /nologo %~dp0\tmp.vbs
	if %errorlevel%==6 (
		echo Proceeding With Install >> %logfile%
		del %~dp0\tmp.vbs
		GOTO INSTALL-STEP1
	) else if %errorlevel%== 7 (
		echo Proceeding With Uninstall >> %logfile%
		del %~dp0\tmp.vbs
  		GOTO UNINSTALL-STEP1
	) else (
		echo Now Exiting... >> %logfile%
		GOTO ALLOK
	)

	if not errorlevel 0 GOTO ERR1

:INSTALL-STEP1

	GOTO anime-output

	:anime-output
	call :inputbox "Please enter output folder where you want to store your Anime. No quotes or escapes required, but please include trailing slash. UNC paths are supported" "Anime Output Folder" "%USERPROFILE%\Videos\"

		if NOT "%Input%"=="" (
			GOTO anime-fixed
		) ELSE (
			GOTO anime-default
		)

		:anime-fixed
			set "strOutputAnime=%Input%"
			echo Anime Output Path: %strOutputAnime% >> %logfile%
		GOTO tvshow-output

		:anime-default	
			set "strOutputAnime=%USERPROFILE%\Videos\"
			echo No Path Detected. Defaulting to %strOutputAnime% >> %logfile%
		GOTO tvshow-output
			
	:tvshow-output
	call :inputbox "Please enter output folder where you want to store your TV Shows. No quotes or escapes required, but please include trailing slash. UNC paths are supported" "TV Shows Output Folder" "%USERPROFILE%\Videos\"

		if NOT "%Input%"=="" (
			GOTO tv-fixed
		) ELSE (
			GOTO tv-default
		)

		:tv-fixed
			set "strOutputTVShow=%Input%"
			echo Anime Output Path: %strOutputTVShow% >> %logfile%
		GOTO movie-output

		:tv-default	
			set "strOutputTVShow=%USERPROFILE%\Videos\"
			echo No Path Detected. Defaulting to %strOutputTVShow% >> %logfile%
		GOTO movie-output

	:movie-output
	call :inputbox "Please enter output folder where you want to store your Movies. No quotes or escapes required, but please include trailing slash. UNC paths are supported" "Movies Output Folder" "%USERPROFILE%\Videos\"

		if NOT "%Input%"=="" (
			GOTO movie-fixed
		) ELSE (
			GOTO movie-default
		)

		:movie-fixed
			set "strOutputMovie=%Input%"
			echo Movie Output Path: %strOutputMovie% >> %logfile%
		GOTO finished-output

		:movie-default	
			set "strOutputMovie=%USERPROFILE%\Videos\"
			echo No Path Detected. Defaulting to %strOutputMovie% >> %logfile%
		GOTO finished-output

		:finished-output

	if not errorlevel 0 GOTO ERR1

GOTO INSTALL-STEP2


:INSTALL-STEP2

	echo Writing Output File %outputfile% >> %logfile%

	echo %strOutputAnime% > %outputfile%
	echo %strOutputTVShow% >> %outputfile%
	echo %strOutputMovie% >> %outputfile%
	echo. >> %outputfile%

	echo ----------------------- >> %outputfile%
	echo Instructions: >> %outputfile%
	echo  - The first 3 lines must be the File Output Locations. >> %outputfile%
	echo  - Don't put anything else on those lines. >> %outputfile%
	echo  - Remember your trailing slashes. >> %outputfile%
	echo  - Line 1 is for Anime. >> %outputfile%
	echo  - Line 2 is for TV Shows. >> %outputfile%
	echo  - Line 3 is for Movies. >> %outputfile%
	echo  - UNC and local paths supported. >> %outputfile%

	echo Writing Output File Complete >> %logfile%

	echo Writing OpenSubtitles.org Login Script >> %logfile%

	echo :: FileBot CLI login to OpenSubtitles.org (requires opensubtitles.org account) > %oslogin%
	echo :: It is recommend you create/log into an OpenSubtitles.org account before >> %oslogin%
	echo :: downloading large amounts of subtitles as it increases the anti-leech limit. >> %oslogin%
	echo. >> %oslogin%
	echo filebot -script fn:osdb.login >> %oslogin%

	echo Writing OpenSubtitles.org Login Script Complete >> %logfile%

	echo Writing Subtitle Language Tag Removal Script >> %logfile%

	echo :: To remove the language tag from subtitles (so .eng.srt becomes .srt)  > %remlangtag%
	echo :: simply drag and drop the subtitle files onto this script in explorer >> %remlangtag%
	echo. >> %remlangtag%
	echo filebot -script fn:replace --filter "[.](srt|sub|ass)$" --def "e=^(.+)([.]\w+)([.]\w+)$" "r=$1$3" %%* >> %remlangtag%

	echo Writing Subtitle Language Tag Removal Script Complete >> %logfile%

	echo Creating FileBot Jar Updater >> %logfile%

	bitsadmin.exe /transfer "Download_Auto_Updater" "https://github.com/CapriciousSage/cmdlets/raw/master/filebot_auto_jar_updater.cmd" "C:\Program Files\FileBot\cmdlets\filebot_auto_jar_updater.cmd"

	echo Finished Creating FileBot Jar Updater >> %logfile%

	echo Creating Subtitle Fetch Language Changer >> %logfile%

	bitsadmin.exe /transfer "Download_Sub_Lang_Changer" "https://github.com/CapriciousSage/cmdlets/raw/master/change_subtitle_fetch_language.cmd" "C:\Program Files\FileBot\cmdlets\change_subtitle_fetch_language.cmd"

	echo Finished Subtitle Fetch Language Changer >> %logfile%


	if not errorlevel 0 GOTO ERR1

GOTO INSTALL-STEP3


:INSTALL-STEP3

	echo set WshShell = WScript.CreateObject("WScript.Shell") > %~dp0\tmp.vbs
	echo WScript.Quit (WshShell.Popup( "Would you like to use our self-updating (cloud managed) naming scheme?" ,,"Advanced Context Menu Setup", 3+32)) >> %~dp0\tmp.vbs
	cscript /nologo %~dp0\tmp.vbs

	if %errorlevel%==6 (
		echo Proceeding With Cloud Integration for Naming Scheme >> %logfile%
		del %~dp0\tmp.vbs
		GOTO INSTALL-REMOTE
	) else if %errorlevel%== 7 (
		echo Proceeding With Locally Managed Naming Scheme >> %logfile%
		del %~dp0\tmp.vbs
  		GOTO INSTALL-LOCAL
	) else (
		echo Now Exiting... >> %logfile%
		GOTO ALLOK
	)

	if not errorlevel 0 GOTO ERR1

GOTO ALLOK


:INSTALL-REMOTE

	echo Downloading Latest Install Registry Script >> %logfile%

	bitsadmin.exe /transfer "Download_Install" "https://raw.github.com/CapriciousSage/cmdlets/master/context_menu_install.reg" "%~dp0\context_menu_install.reg"

	echo Installing Registry Entries >> %logfile%
	regedit.exe /S "%~dp0\context_menu_install.reg"

	echo Deleting Temporary Install File >> %logfile%
	del "%~dp0\context_menu_install.reg"

	if not errorlevel 0 GOTO ERR1

	echo Cloud Managed Install Complete >> %logfile%

GOTO ALLOK


:INSTALL-LOCAL

	echo Downloading Latest Rename Schemes for Local Management >> %logfile%

	bitsadmin.exe /transfer "Download_Anime_Scheme" "https://raw.github.com/CapriciousSage/schemes/master/anime.txt" "C:\Program Files\FileBot\cmdlets\anime.txt"
	bitsadmin.exe /transfer "Download_TV_Shows_Scheme" "https://raw.github.com/CapriciousSage/schemes/master/tv_shows.txt" "C:\Program Files\FileBot\cmdlets\tv_shows.txt"
	bitsadmin.exe /transfer "Download_Movies_Scheme" "https://raw.github.com/CapriciousSage/schemes/master/movies.txt" "C:\Program Files\FileBot\cmdlets\movies.txt"

	echo Downloading Latest Groovy Files for Local Management >> %logfile%

	bitsadmin.exe /transfer "Download_Anime_Scheme" "https://raw.github.com/CapriciousSage/scripts/master/anime_local.groovy" "C:\Program Files\FileBot\cmdlets\anime.groovy"
	bitsadmin.exe /transfer "Download_TV_Shows_Scheme" "https://raw.github.com/CapriciousSage/scripts/master/tv_shows_local.groovy" "C:\Program Files\FileBot\cmdlets\tv_shows.groovy"
	bitsadmin.exe /transfer "Download_Movies_Scheme" "https://raw.github.com/CapriciousSage/scripts/master/movies_local.groovy" "C:\Program Files\FileBot\cmdlets\movies.groovy"

	echo Downloading Latest Install Registry Script >> %logfile%

	bitsadmin.exe /transfer "Download_Install" "https://raw.github.com/CapriciousSage/cmdlets/master/context_menu_install_local.reg" "%~dp0\context_menu_install_local.reg"

	echo Installing Registry Entries >> %logfile%
	regedit.exe /S "%~dp0\context_menu_install_local.reg"

	echo Deleting Temporary Install File >> %logfile%
	del "%~dp0\context_menu_install_local.reg"

	if not errorlevel 0 GOTO ERR1

	echo Locally Managed Install Complete >> %logfile%

GOTO ALLOK


:UNINSTALL-STEP1

	echo set WshShell = WScript.CreateObject("WScript.Shell") > %~dp0\tmp.vbs
	echo WScript.Quit (WshShell.Popup( "Would you like to remove cmdlets as well?'." ,,"Advanced Context Menu Setup", 3+32)) >> %~dp0\tmp.vbs
	cscript /nologo %~dp0\tmp.vbs

	if %errorlevel%==6 (
		echo Removing registry entries and cmdlets >> %logfile%
		del %~dp0\tmp.vbs
		GOTO UNINSTALL-FULL
	) else if %errorlevel%== 7 (
		echo Removing registry entries only >> %logfile%
		del %~dp0\tmp.vbs
  		GOTO UNINSTALL-REGONLY
	) else (
		echo Now Exiting... >> %logfile%
		GOTO ALLOK
	)

	if not errorlevel 0 GOTO ERR1

GOTO ALLOK


:UNINSTALL-FULL

	IF EXIST %outputfile% (
		echo Deleting %outputfile% >> %logfile%
		del %outputfile%
	) ELSE (
		echo No Output File to Delete >> %logfile%
	)

	IF EXIST %oslogin% (
		echo Deleting %oslogin% >> %logfile%
		del %oslogin%
	) ELSE (
		echo No OpenSubtitles Login Script to Delete >> %logfile%
	)

	IF EXIST %remlangtag% (
		echo Deleting %remlangtag% >> %logfile%
		del %remlangtag%
	) ELSE (
		echo No Subtitle Language Tag Removal Script to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\anime.txt" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\anime.txt" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\anime.txt"
	) ELSE (
		echo No anime.txt File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\tv_shows.txt" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\tv_shows.txt" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\tv_shows.txt"
	) ELSE (
		echo No tv_shows.txt File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\movies.txt" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\movies.txt" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\movies.txt"
	) ELSE (
		echo No movies.txt File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\anime.groovy" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\anime.groovy" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\anime.groovy"
	) ELSE (
		echo No anime.groovy File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\tv_shows.groovy" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\tv_shows.groovy" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\tv_shows.groovy"
	) ELSE (
		echo No tv_shows.groovy File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\movies.groovy" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\movies.groovy" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\movies.groovy"
	) ELSE (
		echo No movies.groovy File to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\filebot_auto_jar_updater.cmd" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\filebot_auto_jar_updater.cmd" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\filebot_auto_jar_updater.cmd"
	) ELSE (
		echo No Jar Auto Updater to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\change_subtitle_fetch_language.cmd" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\change_subtitle_fetch_language.cmd" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\change_subtitle_fetch_language.cmd"
	) ELSE (
		echo No Jar Auto Updater to Delete >> %logfile%
	)

	echo File Removal Complete. Proceeding to reg file uninstall.

GOTO UNINSTALL-REGONLY


:UNINSTALL-REGONLY

	echo Downloading Latest Uninstall Registry Script >> %logfile%

	bitsadmin.exe /transfer "Download_Uninstall" "https://raw.github.com/CapriciousSage/cmdlets/master/context_menu_uninstall.reg" "%~dp0\context_menu_uninstall.reg"

	echo Uninstalling Registry Entries >> %logfile%
	regedit.exe /S "%~dp0\context_menu_uninstall.reg"

	echo Deleting Temporary Uninstall File >> %logfile%
	del "%~dp0\context_menu_uninstall.reg"

	if not errorlevel 0 GOTO ERR1

	echo Reg Only Uninstall Complete >> %logfile%

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
%logfile%
EXIT /B