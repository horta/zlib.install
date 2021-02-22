@echo off
setlocal EnableDelayedExpansion

:: Log file
set ORIGIN=%cd%
set LOGFILE=%ORIGIN%\zlib_install.log

:: Configuration
set VERSION=1.2.11
set FILE=zlib-%VERSION%.zip
set DIR=zlib-%VERSION%
set URL=https://zlib.net/zlib%VERSION:.=%.zip
set CMAKE_VS_PLATFORM_NAME=x64
set SRC_DIR=%ORIGIN%/%DIR%
set BUILD_DIR=%SRC_DIR%/build

echo %SRC_DIR%
echo %BUILD_DIR%

echo [0/6] Library(zlib==%VERSION%)

call :cleanup
call :cleanup_log
call :log_sysinfo

echo|set /p="[1/6] Checking cmake... "
call :setup_cmake_path >>%LOGFILE% 2>&1
if not defined CMAKE (
    call :failed
    echo[
    echo Please, install CMAKE: https://cmake.org/download/
    exit /B 1
) else (echo done.)

echo|set /p="[2/6] Downloading... "
echo Fetching %URL% >>%LOGFILE% 2>&1
call :winget "%URL%" >>%LOGFILE% 2>&1
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

echo|set /p="[3/6] Extracting... "
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%FILE%', '.'); }" >>%LOGFILE% 2>&1
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

cd %SRC_DIR%

echo|set /p="[4/6] Fixing CMakeLists.txt... "
set OLDSTR=RUNTIME DESTINATION ""\${INSTALL_BIN_DIR}\""
set NEWSTR=RUNTIME DESTINATION ""bin\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=ARCHIVE DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=ARCHIVE DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=LIBRARY DESTINATION ""\${INSTALL_LIB_DIR}\""
set NEWSTR=LIBRARY DESTINATION ""lib\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1)

set OLDSTR=DESTINATION ""\${INSTALL_INC_DIR}\""
set NEWSTR=DESTINATION ""include\""
call :search_replace "%OLDSTR%" "%NEWSTR%"
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

rd /S /Q build >nul 2>&1
mkdir build && cd build

echo|set /p="[5/6] Configuring... "
"%CMAKE%" .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%PROGRAMFILES%\zlib" >>%LOGFILE% 2>&1
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

echo|set /p="[6/6] Compiling and installing... "
"%CMAKE%" --build . --config Release --target install >>%LOGFILE% 2>&1
type %LOGFILE%
if %ERRORLEVEL% NEQ 0 (call :failed && exit /B 1) else (echo done.)

call :cleanup

echo Details can be found at %LOGFILE%.

@echo on
@goto :eof

:setup_cmake_path
cmake.exe /? 2> NUL 1> NUL
if not %ERRORLEVEL%==9009 (echo cmake.exe is accessible by default. && set CMAKE=cmake.exe)
if not defined CMAKE (echo cmake.exe is not accessible by default. Looking into common installation dirs.)
if not defined CMAKE (call :setup_cmake_path_for "%PROGRAMFILES%\CMake\bin")
if not defined CMAKE (call :setup_cmake_path_for "C:\Program Files\CMake\bin")
if not defined CMAKE (call :setup_cmake_path_for "C:\Program Files (x86)\CMake\bin")
@goto :eof

:setup_cmake_path_for
set DIR_PATH=%~1
echo|set /p="Checking !DIR_PATH! ... "
if exist !DIR_PATH!\cmake.exe (
    echo found.
    set CMAKE=!DIR_PATH!\cmake.exe
) else (
    echo not found.
)
@goto :eof

:cleanup
cd %ORIGIN% >nul 2>&1
del /Q %FILE% ! >nul 2>&1
rd /S /Q %DIR% >nul 2>&1
@goto :eof

:cleanup_log
cd %ORIGIN% >nul 2>&1
del /Q %LOGFILE% ! >nul 2>&1
copy /y nul %LOGFILE% >nul 2>&1
@goto :eof

:log_sysinfo
echo -- Environment variables >>%LOGFILE% 2>&1
set >>%LOGFILE% 2>&1
echo[ >>%LOGFILE% 2>&1

echo -- System info >>%LOGFILE% 2>&1
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >>%LOGFILE% 2>&1
echo[ >>%LOGFILE% 2>&1
@goto :eof

:failed
echo FAILED.
echo[
echo ---------------------------------------- log begin ----------------------------------------
type %LOGFILE%
echo ----------------------------------------  log end  ----------------------------------------
echo LOG: %LOGFILE%
call :cleanup
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
powershell -Command %CMD%  >>%LOGFILE% 2>&1
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
