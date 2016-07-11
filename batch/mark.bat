@ECHO OFF
SETLOCAL
SET _option=%1
::Remove Quotes from a string use ~
SET _desc=%2
SET _bold=%3
SET mark_dir=MarkMe
SET inner_dir_name=inner
SET marked_file_name=marked
SET inner_path=%USERPROFILE%\Documents\%mark_dir%\%inner_dir_name%
REM
SET marked_file=%USERPROFILE%\Documents\%mark_dir%\%marked_file_name%.md
SET marked_file_backup=%inner_path%\%marked_file_name%.back
::This file will be removed after execution
SET content_temp_file=%inner_path%\marked_content.tmp
IF NOT EXIST %USERPROFILE%\Documents\%mark_dir% (
	MD %USERPROFILE%\Documents\%mark_dir%
)
IF NOT EXIST %inner_path% (
	MD %inner_path%
)
IF /I "%_option%" == "-s" (
	TYPE %marked_file%
) ELSE IF /I "%_option%" == "-o" (
	ECHO Opening file...
	%SystemRoot%\explorer.exe %marked_file%
) ELSE IF /I "%_option%" == "-m" (
	IF [%_desc%] == [] (
		ECHO Error:no url description
		GOTO End
	)
	REM Format showing style here
	SET format_date=###
	SET format_title=##Marked Contents
	REM Query newest date and save to local variable
	SETLOCAL ENABLEDELAYEDEXPANSION 
	IF EXIST %marked_file% (
		FOR /F  "tokens=1 delims=¦" %%i IN (%marked_file%) DO (
			SET _line=%%i
			IF [!got_date!] == [1] (
				::Create content file dynamicly
				IF NOT EXIST %content_temp_file% (
					TYPE nul> %content_temp_file%
				) 
				ECHO !_line!>> %content_temp_file%
			)
			IF [!got_date!] == [] (
				REM ###20==###20 Bug
				IF "!_line:~0,5!" == "!format_date!20" (
					SET newest_date=!_line:~3!
				    SET /A got_date=1
				) 
			)
		)	
	) ELSE (
		GOTO Next
	)
	:Next
	REM backup marked file
	IF EXIST %marked_file% (
		TYPE %marked_file%> %marked_file_backup%
	)
	ECHO !format_title!> %marked_file%
	REM Do not modify here
	ECHO !format_date!%DATE%>> %marked_file%
	REM Use temp file to save clipboard content
	TYPE nul > temp.txt
	GetClip /txt >> temp.txt
	FOR /F "tokens=1 delims=¦" %%i IN (temp.txt) DO (
		SET clip_line=%%i
		GOTO AddContent
	)
	:AddContent
	REM Add new content
	REM Format content showing style here
	REM
	REM
	REM
	IF [%_bold%] ==[] (
		ECHO *%_desc:~1,-1%:*>> %marked_file%
	) ELSE (
		ECHO ######*%_desc:~1,-1%:*>> %marked_file%
		REM Tricks
		SET _quto=">"
		ECHO !_quto:~1,-1!>> %marked_file%
	)
	TYPE temp.txt>> %marked_file%
	IF /I "%_bold%" =="-b" (
		ECHO.>> %marked_file%
	)
	REM
	REM
	REM
	ECHO.>> %marked_file%
	SET current_date=%DATE%
	IF [!newest_date!] NEQ [] (
		IF "!newest_date!" NEQ "!current_date!" (
			REM Copy date to mark file
			ECHO !format_date!!newest_date!>> %marked_file%
		)
		::ECHO "Merge"
		REM Merge content to marked_file
		TYPE %content_temp_file%>> %marked_file%
	) ELSE (
		REM do nothing
	)
	IF EXIST %content_temp_file% (
		DEL %content_temp_file%
	)
	IF %ERRORLEVEL% == 0  (
		@ECHO Marked:!clip_line!
		@ECHO In %marked_file%
	)
	GOTO End
) ELSE IF /I "%_option%" == "-d" (
	ECHO Delete backup files...
	IF EXIST %marked_file_backup% (
		DEL %marked_file_backup%
	)
	GOTO End
) ELSE IF /I "%_option%" == "-r" (
	ECHO Reset content...
	IF EXIST %marked_file_backup% (
		TYPE %marked_file_backup%> %marked_file%
	) ELSE (
		ECHO Reset failed,backup file is not exist.
	)
	GOTO End
)
:End
