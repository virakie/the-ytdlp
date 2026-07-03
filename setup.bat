@echo off
setlocal enabledelayedexpansion
title YTDLP Setup
cd /d "%~dp0"
echo.
echo Downloading yt-dlp...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'yt-dlp.exe'"
echo Done.
echo.
echo Downloading aria2c...
powershell -Command ^
  "$url = 'https://api.github.com/repos/aria2/aria2/releases/latest';" ^
  "$release = Invoke-RestMethod -Uri $url;" ^
  "$asset = $release.assets | Where-Object { $_.name -like '*win-64bit*.zip' } | Select-Object -First 1;" ^
  "Invoke-WebRequest -Uri $asset.browser_download_url -OutFile 'aria2.zip'"
powershell -Command "Expand-Archive -Path 'aria2.zip' -DestinationPath 'aria2_tmp' -Force"
powershell -Command "Get-ChildItem -Path 'aria2_tmp' -Recurse -Filter 'aria2c.exe' | Copy-Item -Destination '.'"
rmdir /s /q aria2_tmp
del aria2.zip
echo Done.
echo.
echo Downloading ffmpeg...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'"
powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_tmp' -Force"
powershell -Command "Get-ChildItem -Path 'ffmpeg_tmp' -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1 | Copy-Item -Destination '.'"
powershell -Command "Get-ChildItem -Path 'ffmpeg_tmp' -Recurse -Filter 'ffprobe.exe' | Select-Object -First 1 | Copy-Item -Destination '.'"
rmdir /s /q ffmpeg_tmp
del ffmpeg.zip
echo Done.
echo.
echo Downloading Deno (required for YouTube JS challenge solving)...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip' -OutFile 'deno.zip'"
powershell -Command "Expand-Archive -Path 'deno.zip' -DestinationPath 'deno_tmp' -Force"
powershell -Command "Get-ChildItem -Path 'deno_tmp' -Recurse -Filter 'deno.exe' | Copy-Item -Destination '.'"
rmdir /s /q deno_tmp
del deno.zip
echo Done.
echo.
color 0B
echo ============================================
echo  ONE MORE THING (optional but recommended)
echo ============================================
echo.
echo  Some videos need you to be "logged in" to download
echo  (like private/age-restricted YouTube videos, or
echo  most Instagram posts).
echo.
echo  To fix this, do this ONE TIME:
echo.
echo  1. In your browser, install the extension called
echo     "Get cookies.txt LOCALLY"
echo.
echo  2. Go to the website (youtube.com, instagram.com, etc)
echo     and make sure you are logged in.
echo.
echo  3. Click the extension icon, then click Export
echo     (it downloads a file called cookies.txt)
echo.
echo  4. Move that cookies.txt file into THIS SAME FOLDER,
echo     right next to ytdlp.bat
echo.
echo  That's it. ytdlp.bat will automatically use it
echo  every time, for any site. No setup needed after that.
echo.
color 0A
echo All done. You can now run ytdlp.bat
color 0F
echo.
pause