@echo off
SETLOCAL

:: Log file
SET ORIGIN=%cd%
call :joinpath "%ORIGIN%" "zlib_install.log"
SET LOG_FILE=%Result%

:: Configuration
set VERSION=1.2.11
set FILE=zlib-%VERSION%.zip
set DIR=zlib-%VERSION%
set URL=https://zlib.net/zlib%VERSION:.=%.zip
:: set CMAKE_GENERATOR_PLATFORM=x64

echo [0/5] Library(zlib==%VERSION%)

:: Cleaning up previous mess
del /Q %FILE% ! >nul 2>&1
rd /S /Q %DIR% >nul 2>&1
del /Q %LOG_FILE% ! >nul 2>&1
copy /y nul %LOG_FILE% >nul 2>&1

echo|set /p="[1/5] Downloading... "
echo Fetching %URL% >>%LOG_FILE% 2>&1
call :winget "%URL%" >>%LOG_FILE% 2>&1
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1) else (echo done.)

echo|set /p="[2/5] Extracting... "
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%FILE%', '.'); }" >>%LOG_FILE% 2>&1
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1) else (echo done.)

cd %DIR%

echo|set /p="[3/5] Fixing CMakeLists.txt... "
set OLDSTR=RUNTIME DESTINATION ""\${INSTALL_BIN_DIR}\""
set NEWSTR=RUNTIME DESTINATION ""bin\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1)

set OLDSTR=ARCHIVE DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=ARCHIVE DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1)

set OLDSTR=LIBRARY DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=LIBRARY DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1)

set OLDSTR=DESTINATION ""\${INSTALL_INC_DIR}\""
set NEWSTR=DESTINATION ""include\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1) else (echo done.)

rd /S /Q build >nul 2>&1
mkdir build && cd build

echo|set /p="[4/5] Configuring... "
cmake .. -T"host=x64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%programfiles%\zlib" >>%LOG_FILE% 2>&1
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1) else (echo done.)

echo|set /p="[5/5] Compiling and installing... "
cmake --build . --config Release --target install >>%LOG_FILE% 2>&1
type %LOG_FILE%
if %ERRORLEVEL% NEQ 0 (echo FAILED. && type %LOG_FILE% && exit /B 1) else (echo done.)

cd %ORIGIN% >nul 2>&1
del /Q %FILE% >nul 2>&1
rd /S /Q %DIR% >nul 2>&1

echo Details can be found at %LOG_FILE%.

@echo on
@goto :eof

:joinpath
set Path1=%~1
set Path2=%~2
if {%Path1:~-1,1%}=={\} (set Result=%Path1%%Path2%) else (set Result=%Path1%\%Path2%)
goto :eof

:search_replace
set OLDSTR=%~1
set NEWSTR=%~2
set CMD="(gc CMakeLists.txt) -replace '%OLDSTR%', '%NEWSTR%' | Out-File -encoding ASCII CMakeLists.txt"
powershell -Command %CMD%  >>%LOG_FILE% 2>&1
goto :eof

:winget    - download file given url
set URL=%~1
for %%F in (%URL%) do set FILE=%%~nxF

setlocal EnableDelayedExpansion
set multiLine=$security_protcols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::SystemDefault^

if ([Net.SecurityProtocolType].GetMember('Tls11').Count -gt 0) {^

 $security_protcols = $security_protcols -bor [Net.SecurityProtocolType]::Tls11^

}^

if ([Net.SecurityProtocolType].GetMember('Tls12').Count -gt 0) {^

$security_protcols = $security_protcols -bor [Net.SecurityProtocolType]::Tls12^

}^

[Net.ServicePointManager]::SecurityProtocol = $security_protcols^

Write-Host 'Downloading %URL%... ' -NoNewLine^

(New-Object Net.WebClient).DownloadFile('%URL%', '%FILE%')^

Write-Host 'done.'

powershell -Command !multiLine!
goto:eof
