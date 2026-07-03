@echo off
setlocal enabledelayedexpansion
title YTDLP
:: Portable paths (everything sits next to this script)
set "YTDLP=%~dp0yt-dlp.exe"
set "ARIA2=%~dp0aria2c.exe"
set "DENO=%~dp0deno.exe"
:: JS runtime for YouTube's signature/PO-token challenges (SABR); deno.exe next to yt-dlp.exe is auto-detected, but pointing explicitly is a safe fallback
set "JSRUNTIME="
if exist "%DENO%" set "JSRUNTIME=--js-runtimes "deno:%DENO%" --remote-components ejs:github"
:: Script directory without trailing backslash (avoids Windows arg-parsing bug where \" is read as an escaped quote)
set "SCRIPTDIR=%~dp0"
set "SCRIPTDIR=%SCRIPTDIR:~0,-1%"
:: Cookies file (export from Zen/Firefox via "Get cookies.txt LOCALLY" extension, place next to this script)
set "COOKIEFILE=%~dp0cookies.txt"
set "COOKIES="
if exist "%COOKIEFILE%" set "COOKIES=--cookies "%COOKIEFILE%""
:: Output path (single flat folder)
set "OUTDIR=%~dp0_ytdlp"
set "VIDDIR=%OUTDIR%"
set "AUDIODIR=%OUTDIR%"
set "MUSICDIR=%OUTDIR%"
:: Create folder if missing
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
:START
color 0F
cls
echo.
echo [u] - Update yt-dlp
echo.
set /p "URLS=> "
if /i "%URLS%"=="u" goto UPDATE
if "%URLS%"=="" goto START
:FORMAT
color 0E
cls
echo.
echo v  Video
echo a  Audio (MP3)
echo m  Music (FLAC)
echo.
set /p "choice=> "
if /i "%choice%"=="v" goto VIDEO
if /i "%choice%"=="a" goto AUDIO
if /i "%choice%"=="m" goto MUSIC
goto FORMAT
:FETCHTITLE
color 0F
cls
echo.
echo Fetching titles...
echo.
for %%U in (%URLS%) do (
    for /f "delims=" %%T in ('"%YTDLP%" --print title --no-playlist --no-warnings %COOKIES% %JSRUNTIME% -- "%%U" 2^>nul') do (
        color 0A
        echo %%T
        color 0F
    )
)
echo.
goto %FETCHRETURN%
:VIDEO
set "FETCHRETURN=VIDEODOWN"
goto FETCHTITLE
:VIDEODOWN
color 0E
cls
echo.
echo 1  1080p
echo 2  720p
echo 3  480p
echo .  Best
echo.
set /p "quality=> "
if "%quality%"=="1" set "VFORMAT=-f bestvideo[height<=1080]+bestaudio/best"
if "%quality%"=="2" set "VFORMAT=-f bestvideo[height<=720]+bestaudio/best"
if "%quality%"=="3" set "VFORMAT=-f bestvideo[height<=480]+bestaudio/best"
if "%quality%"=="." set "VFORMAT=-f bestvideo+bestaudio/best"
if "%quality%"=="" set "VFORMAT=-f bestvideo+bestaudio/best"
cls
color 0E
echo.
echo Downloading...
color 0F
echo.
"%YTDLP%" %VFORMAT% --no-playlist --ffmpeg-location "%SCRIPTDIR%" --recode-video mp4 --postprocessor-args "VideoConvertor:-c:v h264_nvenc -preset p1 -cq 18" %COOKIES% %JSRUNTIME% -o "%VIDDIR%\%%(title)s.%%(ext)s" --no-keep-video --no-warnings --quiet --progress --console-title --retries 10 --fragment-retries 10 --retry-sleep 3 --socket-timeout 30 -- %URLS%
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo Failed.
    echo.
    pause
    goto START
)
color 0E
echo.
echo Converting to MP4...
color 0F
timeout /t 1 /nobreak >nul
set "lastdir=%VIDDIR%"
goto END
:AUDIO
set "FETCHRETURN=AUDIODOWN"
goto FETCHTITLE
:AUDIODOWN
cls
color 0E
echo.
echo Downloading...
color 0F
echo.
"%YTDLP%" -x --no-playlist --audio-format mp3 --ffmpeg-location "%SCRIPTDIR%" %COOKIES% %JSRUNTIME% -o "%AUDIODIR%\%%(title)s.%%(ext)s" --no-warnings --quiet --progress --console-title --retries 10 --fragment-retries 10 --retry-sleep 3 -- %URLS%
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo Failed.
    echo.
    pause
    goto START
)
color 0E
echo.
echo Converting to MP3...
color 0F
timeout /t 1 /nobreak >nul
set "lastdir=%AUDIODIR%"
goto END
:MUSIC
set "FETCHRETURN=MUSICDOWN"
goto FETCHTITLE
:MUSICDOWN
cls
color 0E
echo.
echo Downloading...
color 0F
echo.
"%YTDLP%" -x --no-playlist --audio-format flac --ffmpeg-location "%SCRIPTDIR%" %COOKIES% %JSRUNTIME% -o "%MUSICDIR%\%%(title)s.%%(ext)s" --no-warnings --quiet --progress --console-title --retries 10 --fragment-retries 10 --retry-sleep 3 -- %URLS%
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo Failed.
    echo.
    pause
    goto START
)
color 0E
echo.
echo Converting to FLAC...
color 0F
timeout /t 1 /nobreak >nul
set "lastdir=%MUSICDIR%"
goto END
:UPDATE
cls
echo Updating yt-dlp...
echo.
"%YTDLP%" -U
echo.
echo Updating Deno...
echo.
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip' -OutFile '%SCRIPTDIR%\deno.zip'"
powershell -Command "Expand-Archive -Path '%SCRIPTDIR%\deno.zip' -DestinationPath '%SCRIPTDIR%\deno_tmp' -Force"
powershell -Command "Get-ChildItem -Path '%SCRIPTDIR%\deno_tmp' -Recurse -Filter 'deno.exe' | Copy-Item -Destination '%SCRIPTDIR%' -Force"
rmdir /s /q "%SCRIPTDIR%\deno_tmp"
del "%SCRIPTDIR%\deno.zip"
echo Done.
echo.
echo Updating ffmpeg...
echo.
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile '%SCRIPTDIR%\ffmpeg.zip'"
powershell -Command "Expand-Archive -Path '%SCRIPTDIR%\ffmpeg.zip' -DestinationPath '%SCRIPTDIR%\ffmpeg_tmp' -Force"
powershell -Command "Get-ChildItem -Path '%SCRIPTDIR%\ffmpeg_tmp' -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1 | Copy-Item -Destination '%SCRIPTDIR%' -Force"
powershell -Command "Get-ChildItem -Path '%SCRIPTDIR%\ffmpeg_tmp' -Recurse -Filter 'ffprobe.exe' | Select-Object -First 1 | Copy-Item -Destination '%SCRIPTDIR%' -Force"
rmdir /s /q "%SCRIPTDIR%\ffmpeg_tmp"
del "%SCRIPTDIR%\ffmpeg.zip"
echo Done.
echo.
color 0A
echo All tools updated.
color 0F
echo.
pause
goto START
:END
color 0A
echo Done.
color 0F
echo.
echo a  Again
echo f  Find folder
echo q  Quit
echo.
choice /c afq /n /m ">"
if errorlevel 3 exit
if errorlevel 2 (
    explorer "%lastdir%"
    goto START
)
if errorlevel 1 goto START