@echo off
REM AnyDesk Reset & Reinstall Script
REM Version: 1.0
REM Language: Portuguese/English
REM Author: dSave.ru - Modified for Crypto-jc
REM Description: Safely reset and reinstall AnyDesk while preserving contacts

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM Color configuration
color 0A

REM ===============================================
REM LANGUAGE SELECTION
REM ===============================================
cls
echo.
echo  -----------------------------------------
echo   AnyDesk Reset ^& Reinstall Utility
echo  -----------------------------------------
echo.
set /p lang="Select language / Выберите язык (1-English 2-Русский): "

if "%lang%"=="2" goto RUSSIAN
if "%lang%"=="1" goto ENGLISH

:ENGLISH
set LANG_WELCOME=Welcome to the AnyDesk Repair ^& Reinstall Tool
set LANG_DESC=This assistant will help you safely reset, reinstall, and restore AnyDesk settings.
set LANG_INIT=Initializing environment...
set LANG_ERROR_EXE=AnyDesk.exe not found in Downloads folder.
set LANG_ERROR_DOWNLOAD=Please download the AnyDesk installer from the official website:
set LANG_ERROR_SAVE=Save the file to your Downloads folder.
set LANG_PROCEED=Proceed without the AnyDesk installer file?
set LANG_BACKUP=Back up user.conf before uninstalling AnyDesk?
set LANG_SAVING=Saving user.conf to
set LANG_NOTFOUND=user.conf not found. This file contains AnyDesk settings and saved connections.
set LANG_STEP1=[1/7] Saving user.conf to Downloads\anydesk_backup
set LANG_STEP2=[2/7] Terminating AnyDesk processes (if running)...
set LANG_STEP3=[3/7] Removing AnyDesk traces...
set LANG_STEP4=[4/7] Launching AnyDesk installer
set LANG_STEP5=[5/7] Closing AnyDesk before restoring user.conf...
set LANG_STEP6=[6/7] Restoring user.conf...
set LANG_STEP7=[7/7] Final launch of AnyDesk...
set LANG_DONE=[Done] All actions completed. AnyDesk is ready to use.
set LANG_STOPPING=Stopping AnyDesk processes and services...
set LANG_REMOVED=[OK] AnyDesk traces removed.
set LANG_PRESS=Press any key to continue once installation is complete...
set LANG_OK=OK

goto START

:RUSSIAN
set LANG_WELCOME=Добро пожаловать в инструмент восстановления AnyDesk
set LANG_DESC=Этот помощник поможет вам безопасно сбросить, переустановить и восстановить настройки AnyDesk.
set LANG_INIT=Инициализация окружения...
set LANG_ERROR_EXE=AnyDesk.exe не найден в папке Downloads.
set LANG_ERROR_DOWNLOAD=Пожалуйста, загрузите установщик AnyDesk с официального сайта:
set LANG_ERROR_SAVE=Сохраните файл в папку Downloads.
set LANG_PROCEED=Продолжить без файла установщика AnyDesk?
set LANG_BACKUP=Создать резервную копию user.conf перед удалением AnyDesk?
set LANG_SAVING=Сохранение user.conf в
set LANG_NOTFOUND=user.conf не найден. Этот файл содержит настройки AnyDesk и сохраненные соединения.
set LANG_STEP1=[1/7] Сохранение user.conf в Downloads\anydesk_backup
set LANG_STEP2=[2/7] Завершение процессов AnyDesk (если они запущены)...
set LANG_STEP3=[3/7] Удаление следов AnyDesk...
set LANG_STEP4=[4/7] Запуск установщика AnyDesk
set LANG_STEP5=[5/7] Закрытие AnyDesk перед восстановлением user.conf...
set LANG_STEP6=[6/7] Восстановление user.conf...
set LANG_STEP7=[7/7] Финальный запуск AnyDesk...
set LANG_DONE=[Done] Все действия завершены. AnyDesk готов к использованию.
set LANG_STOPPING=Остановка процессов и служб AnyDesk...
set LANG_REMOVED=[OK] Следы AnyDesk удалены.
set LANG_PRESS=Нажмите любую клавишу после завершения установки...
set LANG_OK=OK

goto START

:START
cls
echo.
echo  ------------------------------------------
echo  %LANG_WELCOME%
echo  %LANG_DESC%
echo  ------------------------------------------
echo.
echo  %LANG_INIT%
echo.

REM ===============================================
REM CHECK ADMIN RIGHTS
REM ===============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script requires administrator rights!
    echo Please run as Administrator (Right-click ^> Run as administrator)
    pause
    exit /b 1
)

REM ===============================================
REM CHECK FOR ANYDESK INSTALLER
REM ===============================================
set "DOWNLOADS=%USERPROFILE%\Downloads"
set "INSTALLER=%DOWNLOADS%\AnyDesk.exe"

if not exist "%INSTALLER%" (
    echo [Error] %LANG_ERROR_EXE%
    echo.
    echo %LANG_ERROR_DOWNLOAD%
    echo https://anydesk.com/en/downloads
    echo.
    echo %LANG_ERROR_SAVE%
    echo.
    set /p CONFIRM="%LANG_PROCEED% [S,N]?"
    if /i not "!CONFIRM!"=="S" (
        echo Exiting...
        pause
        exit /b 1
    )
    set "SKIP_INSTALL=1"
) else (
    set "SKIP_INSTALL=0"
)

REM ===============================================
REM BACKUP USER.CONF
REM ===============================================
set /p BACKUP="%LANG_BACKUP% [S,N]?"
if /i "!BACKUP!"=="S" (
    echo.
    echo %LANG_STEP1%
    set "BACKUP_DIR=%DOWNLOADS%\anydesk_backup"
    if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!"
    
    set "SOURCE=%APPDATA%\AnyDesk\user.conf"
    if exist "!SOURCE!" (
        copy "!SOURCE!" "!BACKUP_DIR!\user.conf" >nul
        echo [OK] Backup created successfully
    ) else (
        echo [!] %LANG_NOTFOUND%
        set /p CONFIRM="Proceed without saving the configuration file? [S,N]?"
        if /i not "!CONFIRM!"=="S" (
            echo Exiting...
            pause
            exit /b 1
        )
        set "SKIP_RESTORE=1"
    )
)

REM ===============================================
REM STEP 2: STOP ANYDESK
REM ===============================================
echo.
echo %LANG_STEP2%
echo %LANG_STOPPING%

taskkill /F /IM AnyDesk.exe >nul 2>&1
net stop AnyDesk >nul 2>&1

timeout /t 2 /nobreak >nul

REM ===============================================
REM STEP 3: REMOVE ANYDESK FILES
REM ===============================================
echo.
echo %LANG_STEP3%

REM Stop service
sc stop AnyDesk >nul 2>&1

REM Remove configuration files
del /F /Q "%ProgramData%\AnyDesk\service.conf" >nul 2>&1
del /F /Q "%APPDATA%\AnyDesk\service.conf" >nul 2>&1

REM Remove AnyDesk directories
rmdir /S /Q "%ProgramData%\AnyDesk" >nul 2>&1
rmdir /S /Q "%APPDATA%\AnyDesk" >nul 2>&1
rmdir /S /Q "%LOCALAPPDATA%\AnyDesk" >nul 2>&1
rmdir /S /Q "%ProgramFiles(x86)%\AnyDesk" >nul 2>&1
rmdir /S /Q "%ProgramFiles%\AnyDesk" >nul 2>&1

echo %LANG_REMOVED%

REM ===============================================
REM STEP 4: INSTALL ANYDESK
REM ===============================================
if "%SKIP_INSTALL%"=="0" (
    echo.
    echo %LANG_STEP4%
    echo %INSTALLER%
    echo.
    echo %LANG_PRESS%
    start "" "%INSTALLER%"
    pause
) else (
    echo.
    echo [!] Skipping installation (no installer found)
)

REM ===============================================
REM STEP 5: STOP ANYDESK AGAIN
REM ===============================================
echo.
echo %LANG_STEP5%
echo %LANG_STOPPING%

taskkill /F /IM AnyDesk.exe >nul 2>&1
net stop AnyDesk >nul 2>&1

timeout /t 2 /nobreak >nul

REM ===============================================
REM STEP 6: RESTORE USER.CONF
REM ===============================================
echo.
echo %LANG_STEP6%

if /i "!BACKUP!"=="S" (
    set "BACKUP_FILE=!BACKUP_DIR!\user.conf"
    set "RESTORE_PATH=%APPDATA%\AnyDesk\user.conf"
    
    if exist "!BACKUP_FILE!" (
        if not exist "%APPDATA%\AnyDesk" mkdir "%APPDATA%\AnyDesk"
        copy "!BACKUP_FILE!" "!RESTORE_PATH!" >nul 2>&1
        echo [OK] user.conf restored successfully
    ) else (
        echo [!] %LANG_NOTFOUND%
    )
) else (
    echo [!] Restoration skipped
)

REM ===============================================
REM STEP 7: LAUNCH ANYDESK
REM ===============================================
echo.
echo %LANG_STEP7%

net start AnyDesk >nul 2>&1

set "ANYDESK1=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
set "ANYDESK2=%ProgramFiles%\AnyDesk\AnyDesk.exe"

if exist "!ANYDESK1!" (
    start "" "!ANYDESK1!"
) else if exist "!ANYDESK2!" (
    start "" "!ANYDESK2!"
)

timeout /t 3 /nobreak >nul

REM ===============================================
REM COMPLETE
REM ===============================================
echo.
echo %LANG_DONE%
echo.
pause
