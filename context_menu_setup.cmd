@echo OFF

GOTO EndComment
	FileBot Advanced Context Menu v1.8
	Written by CapriciousSage (Ithiel) with assistance from rednoah (Reinhard Pointner)
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
	set WatchSetting="C:\Program Files\FileBot\cmdlets\watch_settings.txt"
	set "watchlist=C:\Progra~1\FileBot\cmdlets\watch_list.txt"
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

	echo %strOutputAnime%> %outputfile%
	echo %strOutputTVShow%>> %outputfile%
	echo %strOutputMovie%>> %outputfile%
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

	bitsadmin.exe /transfer "Download_Auto_Updater" /priority foreground "https://github.com/CapriciousSage/cmdlets/raw/master/filebot_auto_jar_updater.cmd" "C:\Program Files\FileBot\cmdlets\filebot_auto_jar_updater.cmd"

	echo Finished Creating FileBot Jar Updater >> %logfile%

	echo Creating Subtitle Fetch Language Changer >> %logfile%

	bitsadmin.exe /transfer "Download_Sub_Lang_Changer" /priority foreground "https://github.com/CapriciousSage/cmdlets/raw/master/change_subtitle_fetch_language.cmd" "C:\Program Files\FileBot\cmdlets\change_subtitle_fetch_language.cmd"

	echo Finished Subtitle Fetch Language Changer >> %logfile%

	echo Creating Folder Watch Scheduler Script  >> %logfile%

	bitsadmin.exe /transfer "Download_Folder_Watch_Scheduler" /priority foreground "https://github.com/CapriciousSage/cmdlets/raw/master/filebot_schedule_folder_watch.cmd" "C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd"

	echo Finished Folder Watch Scheduler Script >> %logfile%

	echo Creating Folder Watch Script  >> %logfile%

	bitsadmin.exe /transfer "Download_Folder_Watch_Scheduler" /priority foreground "https://github.com/CapriciousSage/cmdlets/raw/master/watch.cmd" "C:\Program Files\FileBot\cmdlets\watch.cmd"

	echo Finished Folder Watch Script >> %logfile%

	if not errorlevel 0 GOTO ERR1

GOTO INSTALL-STEP3


:INSTALL-STEP3

	echo set WshShell = WScript.CreateObject("WScript.Shell") > %~dp0\tmp.vbs
	echo WScript.Quit (WshShell.Popup( "Would you like to use our self-updating (cloud managed) naming scheme?" ,,"Advanced Context Menu Setup", 3+32)) >> %~dp0\tmp.vbs
	cscript /nologo %~dp0\tmp.vbs

	if %errorlevel%==6 (
		echo Proceeding With Cloud Integration for Naming Scheme >> %logfile%
		del %~dp0\tmp.vbs
		GOTO SET-REMOTE
	) else if %errorlevel%== 7 (
		echo Proceeding With Locally Managed Naming Scheme >> %logfile%
		del %~dp0\tmp.vbs
  		GOTO SET-LOCAL
	) else (
		echo Now Exiting... >> %logfile%
		GOTO ALLOK
	)

	if not errorlevel 0 GOTO ERR1

GOTO ALLOK


:SET-REMOTE

	echo Settings Cloud Groovy Path
	set groovyPath=https://raw.github.com/CapriciousSage/scripts/master/

	if not errorlevel 0 GOTO ERR1

	echo Cloud Managed Install Complete >> %logfile%

GOTO PROCESS-REG


:SET-LOCAL

	echo Downloading Latest Rename Schemes for Local Management >> %logfile%

	bitsadmin.exe /transfer "Download_Anime_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/schemes/master/anime.txt" "C:\Program Files\FileBot\cmdlets\anime.txt"
	bitsadmin.exe /transfer "Download_TV_Shows_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/schemes/master/tv_shows.txt" "C:\Program Files\FileBot\cmdlets\tv_shows.txt"
	bitsadmin.exe /transfer "Download_Movies_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/schemes/master/movies.txt" "C:\Program Files\FileBot\cmdlets\movies.txt"

	echo Downloading Latest Groovy Files for Local Management >> %logfile%

	bitsadmin.exe /transfer "Download_Anime_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/scripts/master/anime_local.groovy" "C:\Program Files\FileBot\cmdlets\anime.groovy"
	bitsadmin.exe /transfer "Download_TV_Shows_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/scripts/master/tv_shows_local.groovy" "C:\Program Files\FileBot\cmdlets\tv_shows.groovy"
	bitsadmin.exe /transfer "Download_Movies_Scheme" /priority foreground "https://raw.github.com/CapriciousSage/scripts/master/movies_local.groovy" "C:\Program Files\FileBot\cmdlets\movies.groovy"

	echo Settings Local Groovy Path
	set groovyPath=C:\\Program Files\\FileBot\\cmdlets\\

	if not errorlevel 0 GOTO ERR1

	echo Locally Managed Install Complete >> %logfile%

GOTO PROCESS-REG


:PROCESS-REG

	echo Installing First Round of Registry Entries

	:: Parent Directory
		reg add "HKEY_CLASSES_ROOT\FileBot" /v "MUIVerb" /t REG_SZ /d "FileBot" /f

	:: File Menu
		:: Rename
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename" /v "MUIVerb" /t REG_SZ /d "Rename" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\File_Menu\\shell\\001Rename" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\001Anime" /v "MUIVerb" /t REG_SZ /d "Anime (AniDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\001Anime\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%anime.groovy\" \"%%1\" --db AniDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\002theTVDB" /v "MUIVerb" /t REG_SZ /d "TV Show (theTVDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\002theTVDB\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%tv_shows.groovy\" \"%%1\" --db TheTVDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\003TVRage" /v "MUIVerb" /t REG_SZ /d "TV Show (TVRage)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\003TVRage\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%tv_shows.groovy\" \"%%1\" --db TVRage -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\004IMDb" /v "MUIVerb" /t REG_SZ /d "Movie (IMDb)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\004IMDb\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db IMDb -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\005TheMovieDB" /v MUIVerb"" /t REG_SZ /d "Movie (TheMovieDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\005TheMovieDB\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db TheMovieDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\006OpenSubtitles" /v "MUIVerb" /t REG_SZ /d "Movie (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\001Rename\shell\006OpenSubtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db OpenSubtitles -non-strict --log-file context.log" /f

		:: Fetch
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch" /v "MUIVerb" /t REG_SZ /d "Fetch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\File_Menu\\shell\\002Fetch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\001TVArtworkTV" /v "MUIVerb" /t REG_SZ /d "Artwork for TV Shows (theTVDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\001TVArtworkTV\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:artwork.tvdb \"%%w\" --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\002ArtworkMovies" /v "MUIVerb" /t REG_SZ /d "Artwork for Movies (theMovieDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\002ArtworkMovies\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:artwork.tmdb \"%%w\" --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles" /v "MUIVerb" /t REG_SZ /d "Subtitles with Language Tag (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles" /v "MUIVerb" /t REG_SZ /d "Subtitles without Language Tag (OpenSubtitles)" /f

	:: Folder Menu
		:: Rename
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename" /v "MUIVerb" /t REG_SZ /d "Rename" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\Folder_Menu\\shell\\001Rename" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\001Anime" /v "MUIVerb" /t REG_SZ /d "Anime (AniDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\001Anime\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%anime.groovy\" \"%%1\" --db AniDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\002theTVDB" /v "MUIVerb" /t REG_SZ /d "TV Show (theTVDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\002theTVDB\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%tv_shows.groovy\" \"%%1\" --db TheTVDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\003TVRage" /v "MUIVerb" /t REG_SZ /d "TV Show (TVRage)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\003TVRage\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%tv_shows.groovy\" \"%%1\" --db TVRage -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\004IMDb" /v "MUIVerb" /t REG_SZ /d "Movie (IMDb)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\004IMDb\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db IMDb -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\005TheMovieDB" /v MUIVerb"" /t REG_SZ /d "Movie (TheMovieDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\005TheMovieDB\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db TheMovieDB -non-strict --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\006OpenSubtitles" /v "MUIVerb" /t REG_SZ /d "Movie (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\001Rename\shell\006OpenSubtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script \"%groovyPath%movies.groovy\" \"%%1\" --db OpenSubtitles -non-strict --log-file context.log" /f

		:: Fetch
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch" /v "MUIVerb" /t REG_SZ /d "Fetch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\Folder_Menu\\shell\\002Fetch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\001TVArtworkTV" /v "MUIVerb" /t REG_SZ /d "Artwork for TV Shows (theTVDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\001TVArtworkTV\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:artwork.tvdb \"%%1\" --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\002ArtworkMovies" /v "MUIVerb" /t REG_SZ /d "Artwork for Movies (theMovieDB)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\002ArtworkMovies\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:artwork.tmdb \"%%1\" --log-file context.log" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles" /v "MUIVerb" /t REG_SZ /d "Subtitles with Language Tag (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles" /v "MUIVerb" /t REG_SZ /d "Subtitles without Language Tag (OpenSubtitles)" /f

		:: Watch
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch" /v "MUIVerb" /t REG_SZ /d "Watch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\Folder_Menu\\shell\\003Watch" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\003Subtitles" /v "MUIVerb" /t REG_SZ /d "Schedule Watch for Subtitles with Language Tag (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c call \"C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd\" \"%%1\" \"setnonmatch\"" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\004Subtitles" /v "MUIVerb" /t REG_SZ /d "Schedule Watch for Subtitles without Language Tag (OpenSubtitles)" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c call \"C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd\" \"%%1\" \"setmatch\"" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\005Subtitles" /v "MUIVerb" /t REG_SZ /d "Remove Scheduled Subtitle Fetch Task for this Folder" /f
			reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\003Watch\shell\005Subtitles\command" /v "" /t REG_SZ /d "cmd /c call \"C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd\" \"%%1\" \"removetask\"" /f

	:: Menu Call
		:: File Menu
			reg add "HKEY_CLASSES_ROOT\*\shell\filebot_anchor" /v "MUIVerb" /t REG_SZ /d "FileBot" /f
			reg add "HKEY_CLASSES_ROOT\*\shell\filebot_anchor" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\File_Menu" /f
			reg add "HKEY_CLASSES_ROOT\*\shell\filebot_anchor" /v "Icon" /t REG_SZ /d "\"C:\\Program Files\\FileBot\\filebot.exe\",0" /f

		:: Folder Menu
			reg add "HKEY_CLASSES_ROOT\Folder\shell\filebot_anchor" /v "MUIVerb" /t REG_SZ /d "FileBot" /f
			reg add "HKEY_CLASSES_ROOT\Folder\shell\filebot_anchor" /v "ExtendedSubCommandsKey" /t REG_SZ /d "FileBot\\Folder_Menu" /f
			reg add "HKEY_CLASSES_ROOT\Folder\shell\filebot_anchor" /v "Icon" /t REG_SZ /d "\"C:\\Program Files\\FileBot\\filebot.exe\",0" /f

	if not errorlevel 0 GOTO ERR1

	echo First Round of Registry Entries Complete >> %logfile%

GOTO ASKCOUNT


:ASKCOUNT

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
			GOTO LANG-PROCESS
		)

		:LANG-PROCESS

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
	echo Configuring Subtitle Fetch Language Settings (%newlang%) >> %logfile%

	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\File_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -get-subtitles \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\003Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log" /f
	reg add "HKEY_CLASSES_ROOT\FileBot\Folder_Menu\shell\002Fetch\shell\004Subtitles\command" /v "" /t REG_SZ /d "cmd /c filebot -script fn:suball \"%%1\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO" /f

	set WatchSettingLine1=cmd /c filebot -script fn:suball \"PATH_HERE\" -non-strict --lang %newlang% --log-file context.log
	set WatchSettingLine2=cmd /c filebot -script fn:suball \"PATH_HERE\" -non-strict --lang %newlang% --log-file context.log --format MATCH_VIDEO

	echo "%WatchSettingLine1%" > %WatchSetting%
	echo "%WatchSettingLine2%" >> %WatchSetting%

	echo filebot -script fn:replace --filter "[.](srt|sub|ass)$" --def "e=^(.+)([.]\w+)([.]\w+)$" "r=$1$3" %%* >> %remlangtag%

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

	:: remove tasks BEFORE watch list is removed
	for /f "delims=" %%a in (%watchlist%) do schtasks /delete /tn "%%a" /f >> %logfile%

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

	IF EXIST %WatchSetting% (
		echo Deleting %WatchSetting% >> %logfile%
		del %WatchSetting%
	) ELSE (
		echo No Watch Folder Settings File to Delete >> %logfile%
	)

	IF EXIST "%watchlist%" (
		echo Deleting %watchlist% >> %logfile%
		del "%watchlist%"
	) ELSE (
		echo No Watch List File to Delete >> %logfile%
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

	IF EXIST "C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\filebot_schedule_folder_watch.cmd"
	) ELSE (
		echo No Folder Watch Scheduler Script to Delete >> %logfile%
	)

	IF EXIST "C:\Program Files\FileBot\cmdlets\watch.cmd" (
		echo Deleting "C:\Program Files\FileBot\cmdlets\watch.cmd" >> %logfile%
		del "C:\Program Files\FileBot\cmdlets\watch.cmd"
	) ELSE (
		echo No Folder Watch Script to Delete >> %logfile%
	)

	:: remove any scheduled folder watch tasks
	schtasks /delete /TN "FileBot-Watch *" /f

	echo File Removal Complete. Proceeding to Registry Uninstall.

GOTO UNINSTALL-REGONLY


:UNINSTALL-REGONLY

	echo Uninstalling Registry Entries >> %logfile%

	reg delete "HKEY_CLASSES_ROOT\FileBot" /f

	reg delete "HKEY_CLASSES_ROOT\*\shell\filebot_anchor" /f

	reg delete "HKEY_CLASSES_ROOT\Folder\shell\filebot_anchor" /f

	if not errorlevel 0 GOTO ERR1

	echo Registry Entry Uninstall Complete >> %logfile%

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