@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Optimizer v3.1 - Profissional
chcp 65001 >nul 2>&1
color 0B

:: ╔════════════════════════════════════════════════════════════╗
:: ║           WINDOWS OPTIMIZER v3.1  -  VERSAO ESTAVEL        ║
:: ╚════════════════════════════════════════════════════════════╝

set "APPNAME=Windows Optimizer"
set "VERSION=v3.1"
set "BASE=%ProgramData%\WindowsOptimizer"
set "LOGDIR=%BASE%\logs"
set "BACKUPDIR=%BASE%\backups"

if not exist "%BASE%" md "%BASE%" >nul 2>&1
if not exist "%LOGDIR%" md "%LOGDIR%" >nul 2>&1
if not exist "%BACKUPDIR%" md "%BACKUPDIR%" >nul 2>&1

:: ---------- Verifica Administrador ----------
net session >nul 2>&1
if errorlevel 1 (
    cls
    color 0C
    echo.
    echo  ╔════════════════════════════════════════════════════════╗
    echo  ║           PERMISSAO DE ADMINISTRADOR NECESSARIA        ║
    echo  ╚════════════════════════════════════════════════════════╝
    echo.
    echo   Este programa PRECISA ser executado como Administrador.
    echo.
    echo   Clique com o botao direito no arquivo e escolha:
    echo   "Executar como administrador"
    echo.
    echo  ────────────────────────────────────────────────────────
    pause
    exit /b
)

:: ---------- Detecta Windows ----------
set "OS=Windows"
set "BUILD=?"

for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "OS=%%a"
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set "BUILD=%%a"

echo %OS% | findstr /i "Windows 10 Windows 11" >nul
if errorlevel 1 (
    color 0C
    echo.
    echo  [ERRO] Sistema nao suportado: %OS%
    echo  Este otimizador requer Windows 10 ou Windows 11.
    pause
    exit /b
)

:: ---------- Log e Backup ----------
for /f "tokens=1-3 delims=/" %%a in ("%date%") do set "D=%%c-%%b-%%a"
set "T=%time::=-%"
set "T=%T: =0%"
set "LOGFILE=%LOGDIR%\optimizer_%D%_%T%.log"
set "BACKUP=%BACKUPDIR%\backup_%D%_%T%"
md "%BACKUP%" >nul 2>&1

call :LOG "=== %APPNAME% %VERSION% iniciado ==="

:MENU
cls
color 0B
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                    MENU PRINCIPAL                    │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Limpeza de arquivos
echo     [ 2 ]  Reparo do Sistema
echo     [ 3 ]  Instalar programas
echo     [ 4 ]  Ajustes de desempenho
echo     [ 5 ]  Drivers + BIOS
echo     [ 6 ]  Monitor (Resolucao)
echo     [ 7 ]  Rede
echo     [ 8 ]  Informacoes do computador
echo     [ 9 ]  Backups / Logs
echo     [10 ]  Diskpart (Gerenciar discos)
echo.
echo     [ 0 ]  Sair
echo.
echo   ────────────────────────────────────────────────────────
set "OPT="
set /p "OPT=   › Escolha uma opcao: "

if "%OPT%"=="1" goto CLEAN_MENU
if "%OPT%"=="2" goto REPAIR_MENU
if "%OPT%"=="3" goto INSTALL_APPS
if "%OPT%"=="4" goto PERFORMANCE
if "%OPT%"=="5" goto GPU_DRIVERS
if "%OPT%"=="6" goto DISPLAY_SETTINGS
if "%OPT%"=="7" goto NETWORK_MENU
if "%OPT%"=="8" goto INFO
if "%OPT%"=="9" goto RESTORE_MENU
if "%OPT%"=="10" goto DISKPART_MENU
if "%OPT%"=="0" goto EXIT

echo.
echo   [!] Opcao invalida. Tente novamente.
timeout /t 2 >nul
goto MENU

:: ============================================================
:: 1. LIMPEZA
:: ============================================================

:CLEAN_MENU
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                   LIMPEZA DE ARQUIVOS                │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Limpeza rapida (Temporarios)
echo     [ 2 ]  Limpeza avancada
echo     [ 3 ]  Limpeza Windows Update (DISM)
echo.
echo     [ 0 ]  Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "CLOPT="
set /p "CLOPT=   › Escolha: "

if "%CLOPT%"=="1" goto TEMP
if "%CLOPT%"=="2" goto ADVANCED_CLEAN
if "%CLOPT%"=="3" goto UPDATE
if "%CLOPT%"=="0" goto MENU
goto CLEAN_MENU

:TEMP
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │            LIMPEZA DE TEMPORARIOS (COMPLETA)         │
echo   └──────────────────────────────────────────────────────┘
echo.
call :CONFIRM "Deseja continuar com a limpeza?"
if errorlevel 1 goto CLEAN_MENU

echo.
echo   [*] Limpando arquivos temporarios...
echo.
REM ******************** LIXEIRA ********************
del c:\$recycle.bin\* /s /q >nul 2>&1
PowerShell.exe -NoProfile -Command Clear-RecycleBin -Confirm:$false >nul 2>&1

REM ******************** PASTA TEMP DOS USUARIOS ********************
REM Apaga todos arquivos da pasta Temp de todos os usuarios
for /d %%F in (C:\Users\*) do (Powershell.exe Remove-Item -Path "%%F\AppData\Local\Temp\*" -Recurse -Force >nul 2>&1)
REM cria arquivo vazio.txt dentro da pasta Temp de todos usuarios
for /d %%F in (C:\Users\*) do type nul >"%%F\Appdata\Local\Temp\vazio.txt"
REM apaga todas as pastas vazias dentro da pasta Temp de todos usuarios (mas nao apaga a propria pasta Temp)
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Temp\ %%F\AppData\Local\Temp\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
REM Apaga arquivo vazio.txt dentro da pasta Temp de todos usuarios
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Temp\vazio.txt >nul 2>&1

REM ******************** WINDOWS TEMP ********************
REM Apaga todos arquivos da pasta \Windows\Temp, mantendo as pastas
del c:\Windows\Temp\* /s /q >nul 2>&1
REM cria arquivo vazio.txt dentro da pasta \Windows\Temp
type nul > c:\Windows\Temp\vazio.txt
REM apaga todas as pastas vazias dentro da pasta \Windows\Temp (mas nao apaga a propria pasta)
robocopy c:\Windows\Temp c:\Windows\Temp /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
REM Apaga arquivo vazio.txt dentro da pasta \Windows\Temp
del c:\Windows\Temp\vazio.txt >nul 2>&1

REM ******************** ARQUIVOS DE LOG DO WINDOWS ********************
del C:\Windows\Logs\cbs\*.log >nul 2>&1
del C:\Windows\setupact.log >nul 2>&1
attrib -s c:\windows\logs\measuredboot\*.* >nul 2>&1
del c:\windows\logs\measuredboot\*.log >nul 2>&1
attrib -h -s C:\Windows\ServiceProfiles\NetworkService\ >nul 2>&1
attrib -h -s C:\Windows\ServiceProfiles\LocalService\ >nul 2>&1
del C:\Windows\ServiceProfiles\LocalService\AppData\Local\Temp\MpCmdRun.log >nul 2>&1
del C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp\MpCmdRun.log >nul 2>&1
attrib +h +s C:\Windows\ServiceProfiles\NetworkService\ >nul 2>&1
attrib +h +s C:\Windows\ServiceProfiles\LocalService\ >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\*.log /s /q >nul 2>&1
del C:\Windows\Logs\MeasuredBoot\*.log >nul 2>&1
del C:\Windows\Logs\MoSetup\*.log >nul 2>&1
del C:\Windows\Panther\*.log /s /q >nul 2>&1
del C:\Windows\Performance\WinSAT\winsat.log /s /q >nul 2>&1
del C:\Windows\inf\*.log /s /q >nul 2>&1
del C:\Windows\logs\*.log /s /q >nul 2>&1
del C:\Windows\SoftwareDistribution\*.log /s /q >nul 2>&1
del C:\Windows\Microsoft.NET\*.log /s /q >nul 2>&1

REM ******************** ARQUIVOS DE LOG DO ONEDRIVE ********************
taskkill /F /IM "OneDrive.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\setup\logs\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.odl /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.aodl /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.otc /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\OneDrive\*.qmlc /s /q >nul 2>&1

REM ******************** ARQUIVOS DE DUMP DE PROGRAMAS (NAO DO WINDOWS) ********************
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\CrashDumps\*.dmp /s /q >nul 2>&1

REM ******************** ARQUIVOS DE LOG DO WINDOWS E IE ********************
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\Explorer\*.db /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\WebCache\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\SettingSync\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete\*.tmp /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\"Terminal Server Client"\Cache\*.bin /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\IE\* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\Low\*.dat /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\Low\*.js /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\Low\*.htm /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\Low\*.txt /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Windows\INetCache\Low\*.jpg /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Microsoft\Windows\INetCache\IE\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1

REM ******************** EDGE ********************
taskkill /F /IM "msedge.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do attrib -h -s %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\*.* >nul 2>&1
for /d %%F in (C:\Users\*) do attrib -h -s %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\*.* >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\*.* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\*.* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do attrib +h +s %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content >nul 2>&1
for /d %%F in (C:\Users\*) do attrib +h +s %%F\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\Cache\Cache_Data\data*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\Cache\Cache_Data\f*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\Cache_Data\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\Cache\Cache_Data\index. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\Cache\Cache_Data\index. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\GPUCache\d*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\GPUCache\d*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\GPUCache\d*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\GPUCache\i*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\GPUCache\i*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\GPUCache\i*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\IndexedDB\https_ntp.msn.com_0.indexeddb.leveldb\*.* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\IndexedDB\https_ntp.msn.com_0.indexeddb.leveldb\*.* /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\IndexedDB\https_ntp.msn.com_0.indexeddb.leveldb\*.* /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Code Cache"\js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Code Cache"\js\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Code Cache"\js\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Code Cache"\wasm\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Platform Notifications"\*.* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Platform Notifications"\*.* /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Platform Notifications"\*.* /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\EdgePushStorageWithWinRt\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\EdgePushStorageWithWinRt\*.log /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\EdgePushStorageWithWinRt\*.log /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"File System"\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"File System"\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"File System"\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\CacheStorage\ %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\Database\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Service Worker"\Database\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Service Worker"\Database\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\EdgeCoupons\coupons_data.db\*.ldb /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\EdgeCoupons\coupons_data.db\*.ldb /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\EdgeCoupons\coupons_data.db\*.ldb /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\EdgeCoupons\coupons_data.db\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\EdgeCoupons\coupons_data.db\index. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\EdgeCoupons\coupons_data.db\index. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\Default\EdgeCoupons\coupons_data.db\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Guest Profile"\EdgeCoupons\coupons_data.db\*.log /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\"Profile %%i"\EdgeCoupons\coupons_data.db\*.log /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\Edge\"User Data"\BrowserMetrics\*.pma /s /q >nul 2>&1

REM ******************** FIREFOX ********************
taskkill /F /IM "firefox.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\local\Mozilla\Firefox\Profiles\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\local\Mozilla\Firefox\Profiles\script*.bin /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\local\Mozilla\Firefox\Profiles\startup*.* /s /q >nul 2>&1

REM ******************** CHROME ********************
taskkill /F /IM "chrome.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\Cache\Cache_Data\data*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\Cache\Cache_Data\f*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\Cache\Cache_Data\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\Cache\Cache_Data\index. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\Cache\Cache_Data\index. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\GPUCache\d*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\GPUCache\d*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\GPUCache\d*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\GPUCache\i*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\GPUCache\i*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\GPUCache\i*. /s /q >nul 2>&1)
del C:\Program Files\Google\Chrome\Application\SetupMetrics\*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Code Cache"\js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Code Cache"\js\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Code Cache"\js\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Code Cache"\wasm\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\Storage\data_*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\Storage\data_*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\Storage\data_*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\Storage\index*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\Storage\index*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\Storage\index*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\History-journal*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\History-journal*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\History-journal*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Code Cache"\webui_js\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\Database\*.log /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\CacheStorage\ %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\Database\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Service Worker"\Database\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\Database\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Guest Profile"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\"Profile %%i"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\BrowserMetrics*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Google\Chrome\"User Data"\crash*.pma /s /q >nul 2>&1

REM ******************** BRAVE ********************
taskkill /F /IM "brave.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\Cache_Data\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\Cache\Cache_Data\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\GPUCache\d*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\GPUCache\d*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\GPUCache\i*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\GPUCache\i*. /s /q >nul 2>&1
del C:\Program Files\BraveSoftware\Brave-Browser\Application\SetupMetrics\*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Code Cache"\js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Code Cache"\js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Storage\data_*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\Storage\data_*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Storage\index*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\Storage\index*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\History-journal*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\History-journal*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\CacheStorage\ %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\ %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\Database\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Service Worker"\Database\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Guest Profile"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\BrowserMetrics*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\crash*.pma /s /q >nul 2>&1

REM ******************** VIVALDI ********************
taskkill /F /IM "vivaldi.exe" >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\Cache\Cache_Data\data*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\Cache\Cache_Data\data*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\Cache\Cache_Data\f*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\Cache\Cache_Data\f*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\Cache\Cache_Data\index. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\Cache\Cache_Data\index. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\Cache\Cache_Data\index. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\GPUCache\d*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\GPUCache\d*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\GPUCache\d*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\GPUCache\i*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\GPUCache\i*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\GPUCache\i*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Code Cache"\js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Code Cache"\js\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Code Cache"\js\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Code Cache"\wasm\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Code Cache"\wasm\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\Storage\data_*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\Storage\data_*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\Storage\data_*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\JumpListIconsRecentClosed\*.tmp /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\Storage\index*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\Storage\index*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\Storage\index*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\History-journal*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\History-journal*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\History-journal*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Code Cache"\webui_js\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Code Cache"\webui_js\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Service Worker"\Database\*.log /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\Database\*.log /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\CacheStorage\ %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Vivaldi\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do robocopy %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\CacheStorage\ /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\Database\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Service Worker"\Database\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\Database\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Guest Profile"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\"Profile %%i"\"Service Worker"\ScriptCache\*. /s /q >nul 2>&1)
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\BrowserMetrics*.pma /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Vivaldi\"User Data"\crash*.pma /s /q >nul 2>&1

REM ******************** SPOTIFY ********************
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Spotify\Data\*.file /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Spotify\Browser\Cache\"Cache_Data"\f*. /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Spotify\Browser\GPUCache\*. /s /q >nul 2>&1

REM ******************** ADOBE MEDIA CACHE FILES ********************
for /d %%F in (C:\Users\*) do del %%F\AppData\Roaming\Adobe\Common\"Media Cache files"\*.* /s /q >nul 2>&1
for /d %%F in (C:\Users\*) do del %%F\AppData\Roaming\Adobe\*.log /s /q >nul 2>&1

REM ******************** VMWARE ********************
del C:\ProgramData\VMware\logs\*.log /s /q >nul 2>&1

REM ******************** TeamViewer ********************
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\TeamViewer\EdgeBrowserControl\Persistent\data_*.  /s /q >nul 2>&1)
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_0 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_1 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_2 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_3 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_4 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_5 /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "f_*." /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "data.*" /C "cmd /c del @path" >nul 2>&1))
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "index.*" /C "cmd /c del @path" >nul 2>&1))

echo Limpeza concluida.
call :LOG "Limpeza de temporarios concluida."
pause
goto CLEAN_MENU

:ADVANCED_CLEAN
cls
echo ============================================================
echo                 LIMPEZA AVANCADA
echo ============================================================
echo.
echo Sera limpo: Prefetch, Delivery Optimization, Thumbnails, Logs e Store Cache.
echo.
call :CONFIRM "Deseja continuar?"
if errorlevel 1 goto CLEAN_MENU

echo Limpando...
del /f /s /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /f /s /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*" >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
del /f /s /q "%TEMP%\*" >nul 2>&1
wsreset.exe >nul 2>&1

echo Limpeza avancada concluida.
call :LOG "Limpeza avancada concluida."
pause
goto CLEAN_MENU

:UPDATE
cls
echo ============================================================
echo              LIMPEZA WINDOWS UPDATE
echo ============================================================
echo.
echo ATENCAO: A segunda etapa (/ResetBase) impede desinstalar atualizacoes antigas.
echo.
call :CONFIRM "Deseja continuar?"
if errorlevel 1 goto CLEAN_MENU

echo Executando DISM StartComponentCleanup...
DISM.exe /Online /Cleanup-Image /StartComponentCleanup
if errorlevel 1 (
    echo Falha na primeira etapa.
    pause
    goto CLEAN_MENU
)

echo.
echo Executando DISM ResetBase...
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo.
echo Limpeza do Windows Update concluida.
call :LOG "Limpeza Windows Update concluida."
pause
goto CLEAN_MENU

:: ============================================================
:: 2. REPARO
:: ============================================================

:REPAIR_MENU
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                  REPARO DO SISTEMA                   │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Criar Ponto de Restauracao
echo     [ 2 ]  Executar SFC
echo     [ 3 ]  Executar DISM RestoreHealth
echo     [ 4 ]  Executar SFC + DISM
echo.
echo     [ 0 ]  Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "ROPT="
set /p "ROPT=   › Escolha: "

if "%ROPT%"=="1" goto CREATE_RESTORE
if "%ROPT%"=="2" goto RUN_SFC
if "%ROPT%"=="3" goto RUN_DISM
if "%ROPT%"=="4" goto RUN_SFC_DISM
if "%ROPT%"=="0" goto MENU
goto REPAIR_MENU

:CREATE_RESTORE
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │              CRIAR PONTO DE RESTAURACAO              │
echo   └──────────────────────────────────────────────────────┘
echo.
call :CONFIRM "Deseja criar o ponto de restauracao?"
if errorlevel 1 goto REPAIR_MENU

echo.
echo   [*] Criando ponto de restauracao...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Windows Optimizer' -RestorePointType MODIFY_SETTINGS" 2>nul
if errorlevel 1 (
    echo Nao foi possivel criar o ponto (pode estar desativado no sistema).
) else (
    echo Ponto de restauracao criado com sucesso.
)
call :LOG "Ponto de restauracao solicitado."
pause
goto REPAIR_MENU

:RUN_SFC
cls
echo Executando SFC /scannow...
echo Isso pode demorar varios minutos.
echo.
sfc /scannow
echo.
pause
goto REPAIR_MENU

:RUN_DISM
cls
echo Executando DISM RestoreHealth...
echo Isso pode demorar bastante.
echo.
DISM /Online /Cleanup-Image /RestoreHealth
echo.
pause
goto REPAIR_MENU

:RUN_SFC_DISM
cls
echo Executando DISM + SFC...
echo.
echo [1/2] DISM...
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo [2/2] SFC...
sfc /scannow
echo.
echo Concluido.
pause
goto REPAIR_MENU

:: ============================================================
:: 3. INSTALAR PROGRAMAS
:: ============================================================

:INSTALL_APPS
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │              INSTALAR PROGRAMAS (Ninite-like)        │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Navegadores Web
echo     [ 2 ]  Mensagens e Comunicacao
echo     [ 3 ]  Midia (Video / Audio)
echo     [ 4 ]  Documentos e PDF
echo     [ 5 ]  Compressao
echo     [ 6 ]  Utilitarios
echo     [ 7 ]  Seguranca
echo     [ 8 ]  Armazenamento Online
echo     [ 9 ]  Ferramentas de Desenvolvimento
echo     [10 ]  Imagem e Design
echo     [11 ]  .NET e Java (Runtimes)
echo     [12 ]  Outros (Steam, Games, etc.)
echo.
echo     [ 0 ]  Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "CAT="
set /p "CAT=   › Escolha a categoria: "

if "%CAT%"=="1"  goto INST_BROWSERS
if "%CAT%"=="2"  goto INST_MESSAGING
if "%CAT%"=="3"  goto INST_MEDIA
if "%CAT%"=="4"  goto INST_DOCS
if "%CAT%"=="5"  goto INST_COMPRESSION
if "%CAT%"=="6"  goto INST_UTILS
if "%CAT%"=="7"  goto INST_SECURITY
if "%CAT%"=="8"  goto INST_CLOUD
if "%CAT%"=="9"  goto INST_DEV
if "%CAT%"=="10" goto INST_IMAGING
if "%CAT%"=="11" goto INST_RUNTIMES
if "%CAT%"=="12" goto INST_OTHER
if "%CAT%"=="0"  goto MENU
goto INSTALL_APPS

:: ---------- Helper: check winget ----------
:CHECK_WINGET
where winget >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [!] Winget nao encontrado.
    echo       Instale o "App Installer" na Microsoft Store.
    pause
    exit /b 1
)
exit /b 0

:: ---------- Helper: install one package ----------
:WINGET_INSTALL
echo   [*] Instalando %~2 ...
winget install -e --id %~1 --accept-source-agreements --accept-package-agreements --silent
exit /b

:: ============================================================
:: 1. NAVEGADORES
:: ============================================================
:INST_BROWSERS
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                   NAVEGADORES WEB                    │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Google Chrome
echo     [ 2 ] Mozilla Firefox
echo     [ 3 ] Microsoft Edge
echo     [ 4 ] Brave
echo     [ 5 ] Opera
echo     [ 6 ] Vivaldi
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "B="
set /p "B=   › Digite os numeros (ex: 1 4) ou 9: "
if "%B%"=="0" goto INSTALL_APPS
if "%B%"=="" goto INST_BROWSERS
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_BROWSERS

echo %B% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Google.Chrome" "Chrome"
    call :WINGET_INSTALL "Mozilla.Firefox" "Firefox"
    call :WINGET_INSTALL "Microsoft.Edge" "Edge"
    call :WINGET_INSTALL "Brave.Brave" "Brave"
    call :WINGET_INSTALL "Opera.Opera" "Opera"
    call :WINGET_INSTALL "Vivaldi.Vivaldi" "Vivaldi"
    goto INST_DONE
)
echo %B% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Google.Chrome" "Chrome"
echo %B% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Mozilla.Firefox" "Firefox"
echo %B% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Microsoft.Edge" "Edge"
echo %B% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "Brave.Brave" "Brave"
echo %B% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "Opera.Opera" "Opera"
echo %B% | findstr /i "\<6\>" >nul && call :WINGET_INSTALL "Vivaldi.Vivaldi" "Vivaldi"
goto INST_DONE

:: ============================================================
:: 2. MENSAGENS
:: ============================================================
:INST_MESSAGING
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │              MENSAGENS E COMUNICACAO                 │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Discord
echo     [ 2 ] Telegram
echo     [ 3 ] Zoom
echo     [ 4 ] Microsoft Teams
echo     [ 5 ] Thunderbird (Email)
echo     [ 6 ] Slack
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "M="
set /p "M=   › Digite os numeros (ex: 1 2) ou 9: "
if "%M%"=="0" goto INSTALL_APPS
if "%M%"=="" goto INST_MESSAGING
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_MESSAGING

echo %M% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Discord.Discord" "Discord"
    call :WINGET_INSTALL "Telegram.TelegramDesktop" "Telegram"
    call :WINGET_INSTALL "Zoom.Zoom" "Zoom"
    call :WINGET_INSTALL "Microsoft.Teams" "Teams"
    call :WINGET_INSTALL "Mozilla.Thunderbird" "Thunderbird"
    call :WINGET_INSTALL "SlackTechnologies.Slack" "Slack"
    goto INST_DONE
)
echo %M% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Discord.Discord" "Discord"
echo %M% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Telegram.TelegramDesktop" "Telegram"
echo %M% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Zoom.Zoom" "Zoom"
echo %M% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "Microsoft.Teams" "Teams"
echo %M% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "Mozilla.Thunderbird" "Thunderbird"
echo %M% | findstr /i "\<6\>" >nul && call :WINGET_INSTALL "SlackTechnologies.Slack" "Slack"
goto INST_DONE

:: ============================================================
:: 3. MIDIA
:: ============================================================
:INST_MEDIA
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                 MIDIA (VIDEO / AUDIO)                │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] VLC Media Player
echo     [ 2 ] Spotify
echo     [ 3 ] Audacity
echo     [ 4 ] HandBrake
echo     [ 5 ] foobar2000
echo     [ 6 ] AIMP
echo     [ 7 ] K-Lite Codec Pack (Full)
echo     [ 8 ] iTunes
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "MD="
set /p "MD=   › Digite os numeros (ex: 1 3) ou 9: "
if "%MD%"=="0" goto INSTALL_APPS
if "%MD%"=="" goto INST_MEDIA
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_MEDIA

echo %MD% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "VideoLAN.VLC" "VLC"
    call :WINGET_INSTALL "Spotify.Spotify" "Spotify"
    call :WINGET_INSTALL "Audacity.Audacity" "Audacity"
    call :WINGET_INSTALL "HandBrake.HandBrake" "HandBrake"
    call :WINGET_INSTALL "PeterPawlowski.foobar2000" "foobar2000"
    call :WINGET_INSTALL "AIMP.AIMP" "AIMP"
    call :WINGET_INSTALL "CodecGuide.K-LiteCodecPack.Full" "K-Lite Full"
    call :WINGET_INSTALL "Apple.iTunes" "iTunes"
    goto INST_DONE
)
echo %MD% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "VideoLAN.VLC" "VLC"
echo %MD% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Spotify.Spotify" "Spotify"
echo %MD% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Audacity.Audacity" "Audacity"
echo %MD% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "HandBrake.HandBrake" "HandBrake"
echo %MD% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "PeterPawlowski.foobar2000" "foobar2000"
echo %MD% | findstr /i "\<6\>" >nul && call :WINGET_INSTALL "AIMP.AIMP" "AIMP"
echo %MD% | findstr /i "\<7\>" >nul && call :WINGET_INSTALL "CodecGuide.K-LiteCodecPack.Full" "K-Lite Full"
echo %MD% | findstr /i "\<8\>" >nul && call :WINGET_INSTALL "Apple.iTunes" "iTunes"
goto INST_DONE

:: ============================================================
:: 4. DOCUMENTOS
:: ============================================================
:INST_DOCS
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                  DOCUMENTOS E PDF                    │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] LibreOffice
echo     [ 2 ] Adobe Acrobat Reader
echo     [ 3 ] SumatraPDF
echo     [ 4 ] Foxit Reader
echo     [ 5 ] OnlyOffice
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "D="
set /p "D=   › Digite os numeros (ex: 1 3) ou 9: "
if "%D%"=="0" goto INSTALL_APPS
if "%D%"=="" goto INST_DOCS
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_DOCS

echo %D% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "TheDocumentFoundation.LibreOffice" "LibreOffice"
    call :WINGET_INSTALL "Adobe.Acrobat.Reader.64-bit" "Acrobat Reader"
    call :WINGET_INSTALL "SumatraPDF.SumatraPDF" "SumatraPDF"
    call :WINGET_INSTALL "Foxit.FoxitReader" "Foxit Reader"
    call :WINGET_INSTALL "ONLYOFFICE.DesktopEditors" "OnlyOffice"
    goto INST_DONE
)
echo %D% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "TheDocumentFoundation.LibreOffice" "LibreOffice"
echo %D% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Adobe.Acrobat.Reader.64-bit" "Acrobat Reader"
echo %D% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "SumatraPDF.SumatraPDF" "SumatraPDF"
echo %D% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "Foxit.FoxitReader" "Foxit Reader"
echo %D% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "ONLYOFFICE.DesktopEditors" "OnlyOffice"
goto INST_DONE

:: ============================================================
:: 5. COMPRESSAO
:: ============================================================
:INST_COMPRESSION
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                     COMPRESSAO                       │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] 7-Zip
echo     [ 2 ] WinRAR
echo     [ 3 ] PeaZip
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "C="
set /p "C=   › Digite os numeros (ex: 1 2) ou 9: "
if "%C%"=="0" goto INSTALL_APPS
if "%C%"=="" goto INST_COMPRESSION
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_COMPRESSION

echo %C% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "7zip.7zip" "7-Zip"
    call :WINGET_INSTALL "RARLab.WinRAR" "WinRAR"
    call :WINGET_INSTALL "Giorgiotani.Peazip" "PeaZip"
    goto INST_DONE
)
echo %C% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "7zip.7zip" "7-Zip"
echo %C% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "RARLab.WinRAR" "WinRAR"
echo %C% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Giorgiotani.Peazip" "PeaZip"
goto INST_DONE

:: ============================================================
:: 6. UTILITARIOS
:: ============================================================
:INST_UTILS
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                     UTILITARIOS                      │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] PowerToys
echo     [ 2 ] Everything (busca de arquivos)
echo     [ 3 ] ShareX (screenshots)
echo     [ 4 ] WinDirStat
echo     [ 5 ] WizTree
echo     [ 6 ] qBittorrent
echo     [ 7 ] AnyDesk
echo     [ 8 ] TeamViewer
echo     [ 9 ] CCleaner
echo     [10 ] TeraCopy
echo     [11 ] Revo Uninstaller
echo     [12 ] Open-Shell
echo.
echo     [19 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "U="
set /p "U=   › Digite os numeros (ex: 1 4 6) ou 19: "
if "%U%"=="0" goto INSTALL_APPS
if "%U%"=="" goto INST_UTILS
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_UTILS

echo %U% | findstr /i "\<19\>" >nul && (
    call :WINGET_INSTALL "Microsoft.PowerToys" "PowerToys"
    call :WINGET_INSTALL "voidtools.Everything" "Everything"
    call :WINGET_INSTALL "ShareX.ShareX" "ShareX"
    call :WINGET_INSTALL "WinDirStat.WinDirStat" "WinDirStat"
    call :WINGET_INSTALL "AntibodySoftware.WizTree" "WizTree"
    call :WINGET_INSTALL "qBittorrent.qBittorrent" "qBittorrent"
    call :WINGET_INSTALL "AnyDeskSoftwareGmbH.AnyDesk" "AnyDesk"
    call :WINGET_INSTALL "TeamViewer.TeamViewer" "TeamViewer"
    call :WINGET_INSTALL "Piriform.CCleaner" "CCleaner"
    call :WINGET_INSTALL "CodeSector.TeraCopy" "TeraCopy"
    call :WINGET_INSTALL "RevoUninstaller.RevoUninstaller" "Revo Uninstaller"
    call :WINGET_INSTALL "Open-Shell.Open-Shell-Menu" "Open-Shell"
    goto INST_DONE
)
echo %U% | findstr /i "\<1\>"  >nul && call :WINGET_INSTALL "Microsoft.PowerToys" "PowerToys"
echo %U% | findstr /i "\<2\>"  >nul && call :WINGET_INSTALL "voidtools.Everything" "Everything"
echo %U% | findstr /i "\<3\>"  >nul && call :WINGET_INSTALL "ShareX.ShareX" "ShareX"
echo %U% | findstr /i "\<4\>"  >nul && call :WINGET_INSTALL "WinDirStat.WinDirStat" "WinDirStat"
echo %U% | findstr /i "\<5\>"  >nul && call :WINGET_INSTALL "AntibodySoftware.WizTree" "WizTree"
echo %U% | findstr /i "\<6\>"  >nul && call :WINGET_INSTALL "qBittorrent.qBittorrent" "qBittorrent"
echo %U% | findstr /i "\<7\>"  >nul && call :WINGET_INSTALL "AnyDeskSoftwareGmbH.AnyDesk" "AnyDesk"
echo %U% | findstr /i "\<8\>"  >nul && call :WINGET_INSTALL "TeamViewer.TeamViewer" "TeamViewer"
echo %U% | findstr /i "\<9\>"  >nul && call :WINGET_INSTALL "Piriform.CCleaner" "CCleaner"
echo %U% | findstr /i "\<10\>" >nul && call :WINGET_INSTALL "CodeSector.TeraCopy" "TeraCopy"
echo %U% | findstr /i "\<11\>" >nul && call :WINGET_INSTALL "RevoUninstaller.RevoUninstaller" "Revo Uninstaller"
echo %U% | findstr /i "\<12\>" >nul && call :WINGET_INSTALL "Open-Shell.Open-Shell-Menu" "Open-Shell"
goto INST_DONE

:: ============================================================
:: 7. SEGURANCA
:: ============================================================
:INST_SECURITY
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                      SEGURANCA                       │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Malwarebytes
echo     [ 2 ] KeePass 2
echo     [ 3 ] Bitwarden
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "S="
set /p "S=   › Digite os numeros (ex: 1 2) ou 9: "
if "%S%"=="0" goto INSTALL_APPS
if "%S%"=="" goto INST_SECURITY
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_SECURITY

echo %S% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Malwarebytes.Malwarebytes" "Malwarebytes"
    call :WINGET_INSTALL "DominikReichl.KeePass" "KeePass"
    call :WINGET_INSTALL "Bitwarden.Bitwarden" "Bitwarden"
    goto INST_DONE
)
echo %S% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Malwarebytes.Malwarebytes" "Malwarebytes"
echo %S% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "DominikReichl.KeePass" "KeePass"
echo %S% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Bitwarden.Bitwarden" "Bitwarden"
goto INST_DONE

:: ============================================================
:: 8. CLOUD
:: ============================================================
:INST_CLOUD
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                ARMAZENAMENTO ONLINE                  │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Google Drive for Desktop
echo     [ 2 ] Dropbox
echo     [ 3 ] OneDrive (Microsoft)
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "CL="
set /p "CL=   › Digite os numeros (ex: 1 2) ou 9: "
if "%CL%"=="0" goto INSTALL_APPS
if "%CL%"=="" goto INST_CLOUD
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_CLOUD

echo %CL% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Google.GoogleDrive" "Google Drive"
    call :WINGET_INSTALL "Dropbox.Dropbox" "Dropbox"
    call :WINGET_INSTALL "Microsoft.OneDrive" "OneDrive"
    goto INST_DONE
)
echo %CL% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Google.GoogleDrive" "Google Drive"
echo %CL% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Dropbox.Dropbox" "Dropbox"
echo %CL% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Microsoft.OneDrive" "OneDrive"
goto INST_DONE

:: ============================================================
:: 9. DESENVOLVIMENTO
:: ============================================================
:INST_DEV
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │            FERRAMENTAS DE DESENVOLVIMENTO            │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Visual Studio Code
echo     [ 2 ] Notepad++
echo     [ 3 ] Git
echo     [ 4 ] Python 3 (x64)
echo     [ 5 ] Node.js LTS
echo     [ 6 ] FileZilla
echo     [ 7 ] PuTTY
echo     [ 8 ] WinSCP
echo     [ 9 ] WinMerge
echo.
echo     [19 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "DV="
set /p "DV=   › Digite os numeros (ex: 1 3 4) ou 19: "
if "%DV%"=="0" goto INSTALL_APPS
if "%DV%"=="" goto INST_DEV
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_DEV

echo %DV% | findstr /i "\<19\>" >nul && (
    call :WINGET_INSTALL "Microsoft.VisualStudioCode" "VS Code"
    call :WINGET_INSTALL "Notepad++.Notepad++" "Notepad++"
    call :WINGET_INSTALL "Git.Git" "Git"
    call :WINGET_INSTALL "Python.Python.3.12" "Python 3"
    call :WINGET_INSTALL "OpenJS.NodeJS.LTS" "Node.js LTS"
    call :WINGET_INSTALL "TimKosse.FileZilla.Client" "FileZilla"
    call :WINGET_INSTALL "PuTTY.PuTTY" "PuTTY"
    call :WINGET_INSTALL "WinSCP.WinSCP" "WinSCP"
    call :WINGET_INSTALL "WinMerge.WinMerge" "WinMerge"
    goto INST_DONE
)
echo %DV% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Microsoft.VisualStudioCode" "VS Code"
echo %DV% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Notepad++.Notepad++" "Notepad++"
echo %DV% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Git.Git" "Git"
echo %DV% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "Python.Python.3.12" "Python 3"
echo %DV% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "OpenJS.NodeJS.LTS" "Node.js LTS"
echo %DV% | findstr /i "\<6\>" >nul && call :WINGET_INSTALL "TimKosse.FileZilla.Client" "FileZilla"
echo %DV% | findstr /i "\<7\>" >nul && call :WINGET_INSTALL "PuTTY.PuTTY" "PuTTY"
echo %DV% | findstr /i "\<8\>" >nul && call :WINGET_INSTALL "WinSCP.WinSCP" "WinSCP"
echo %DV% | findstr /i "\<9\>" >nul && call :WINGET_INSTALL "WinMerge.WinMerge" "WinMerge"
goto INST_DONE

:: ============================================================
:: 10. IMAGEM / DESIGN
:: ============================================================
:INST_IMAGING
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                  IMAGEM E DESIGN                     │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] GIMP
echo     [ 2 ] Paint.NET
echo     [ 3 ] Inkscape
echo     [ 4 ] Krita
echo     [ 5 ] IrfanView
echo     [ 6 ] ShareX
echo     [ 7 ] Blender
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "IM="
set /p "IM=   › Digite os numeros (ex: 1 5) ou 9: "
if "%IM%"=="0" goto INSTALL_APPS
if "%IM%"=="" goto INST_IMAGING
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_IMAGING

echo %IM% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "GIMP.GIMP" "GIMP"
    call :WINGET_INSTALL "dotPDN.PaintDotNet" "Paint.NET"
    call :WINGET_INSTALL "Inkscape.Inkscape" "Inkscape"
    call :WINGET_INSTALL "KDE.Krita" "Krita"
    call :WINGET_INSTALL "IrfanSkiljan.IrfanView" "IrfanView"
    call :WINGET_INSTALL "ShareX.ShareX" "ShareX"
    call :WINGET_INSTALL "BlenderFoundation.Blender" "Blender"
    goto INST_DONE
)
echo %IM% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "GIMP.GIMP" "GIMP"
echo %IM% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "dotPDN.PaintDotNet" "Paint.NET"
echo %IM% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Inkscape.Inkscape" "Inkscape"
echo %IM% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "KDE.Krita" "Krita"
echo %IM% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "IrfanSkiljan.IrfanView" "IrfanView"
echo %IM% | findstr /i "\<6\>" >nul && call :WINGET_INSTALL "ShareX.ShareX" "ShareX"
echo %IM% | findstr /i "\<7\>" >nul && call :WINGET_INSTALL "BlenderFoundation.Blender" "Blender"
goto INST_DONE

:: ============================================================
:: 11. RUNTIMES (.NET / JAVA)
:: ============================================================
:INST_RUNTIMES
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │               .NET E JAVA (RUNTIMES)                 │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] .NET Desktop Runtime 8 (x64)
echo     [ 2 ] .NET Desktop Runtime 9 (x64)
echo     [ 3 ] ASP.NET Core Runtime 8 (x64)
echo     [ 4 ] Java Runtime (Adoptium Temurin 21 x64)
echo     [ 5 ] JDK (Adoptium Temurin 21 x64)
echo.
echo     [ 9 ] Instalar os principais (.NET 8 + Java 21)
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "RT="
set /p "RT=   › Digite os numeros (ex: 1 4) ou 9: "
if "%RT%"=="0" goto INSTALL_APPS
if "%RT%"=="" goto INST_RUNTIMES
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_RUNTIMES

echo %RT% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Microsoft.DotNet.DesktopRuntime.8" ".NET Desktop 8"
    call :WINGET_INSTALL "EclipseAdoptium.Temurin.21.JRE" "Java 21 JRE"
    goto INST_DONE
)
echo %RT% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Microsoft.DotNet.DesktopRuntime.8" ".NET Desktop 8"
echo %RT% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "Microsoft.DotNet.DesktopRuntime.9" ".NET Desktop 9"
echo %RT% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Microsoft.DotNet.AspNetCore.8" "ASP.NET Core 8"
echo %RT% | findstr /i "\<4\>" >nul && call :WINGET_INSTALL "EclipseAdoptium.Temurin.21.JRE" "Java 21 JRE"
echo %RT% | findstr /i "\<5\>" >nul && call :WINGET_INSTALL "EclipseAdoptium.Temurin.21.JDK" "JDK 21"
goto INST_DONE

:: ============================================================
:: 12. OUTROS
:: ============================================================
:INST_OTHER
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                       OUTROS                         │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ] Steam
echo     [ 2 ] Epic Games Launcher
echo     [ 3 ] Google Earth Pro
echo.
echo     [ 9 ] Instalar TODOS desta categoria
echo     [ 0 ] Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "OT="
set /p "OT=   › Digite os numeros (ex: 1 2) ou 9: "
if "%OT%"=="0" goto INSTALL_APPS
if "%OT%"=="" goto INST_OTHER
call :CHECK_WINGET || goto INSTALL_APPS
call :CONFIRM "Iniciar instalacao?"
if errorlevel 1 goto INST_OTHER

echo %OT% | findstr /i "\<9\>" >nul && (
    call :WINGET_INSTALL "Valve.Steam" "Steam"
    call :WINGET_INSTALL "EpicGames.EpicGamesLauncher" "Epic Games"
    call :WINGET_INSTALL "Google.EarthPro" "Google Earth Pro"
    goto INST_DONE
)
echo %OT% | findstr /i "\<1\>" >nul && call :WINGET_INSTALL "Valve.Steam" "Steam"
echo %OT% | findstr /i "\<2\>" >nul && call :WINGET_INSTALL "EpicGames.EpicGamesLauncher" "Epic Games"
echo %OT% | findstr /i "\<3\>" >nul && call :WINGET_INSTALL "Google.EarthPro" "Google Earth Pro"
goto INST_DONE

:: ---------- Finalizacao comum ----------
:INST_DONE
echo.
echo   ────────────────────────────────────────────────────────
echo   Instalacao finalizada.
echo   ────────────────────────────────────────────────────────
pause
goto INSTALL_APPS

:: ============================================================
:: 4. DESEMPENHO
:: ============================================================

:PERFORMANCE
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                AJUSTES DE DESEMPENHO                 │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Combo de desempenho
echo     [ 2 ]  Otimizacao SSD
echo     [ 3 ]  Gerenciador de Inicializacao
echo     [ 4 ]  Remover Bloatware
echo.
echo     [ 0 ]  Voltar
echo.
echo   ────────────────────────────────────────────────────────
set "PERFOPT="
set /p "PERFOPT=   › Escolha: "

if "%PERFOPT%"=="1" goto PERFORMANCE_COMBO
if "%PERFOPT%"=="2" goto SSD_OPTIMIZE
if "%PERFOPT%"=="3" goto STARTUP_MANAGER
if "%PERFOPT%"=="4" goto BLOATWARE
if "%PERFOPT%"=="0" goto MENU
goto PERFORMANCE

:PERFORMANCE_COMBO
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                  COMBO DE DESEMPENHO                 │
echo   └──────────────────────────────────────────────────────┘
echo.
call :CONFIRM "Executar o combo de desempenho?"
if errorlevel 1 goto PERFORMANCE

call :BACKUP_POWER
call :BACKUP_SYSMAIN
call :BACKUP_VISUAL

echo [1/5] Ajustando manutencao...
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable >nul 2>&1

echo [2/5] Ativando Alto Desempenho...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

echo [3/5] Desativando SysMain...
net stop SysMain /y >nul 2>&1
sc config SysMain start= disabled >nul 2>&1

echo [4/5] Ajustando efeitos visuais...
reg add "HKCU\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v IconsOnly /t REG_DWORD /d 0 /f >nul

echo [5/5] Otimizando disco...
defrag C: /O >nul 2>&1

echo.
echo Combo finalizado!
call :LOG "Combo de desempenho executado."
pause
goto PERFORMANCE

:SSD_OPTIMIZE
cls
echo ============================================================
echo                  OTIMIZACAO SSD
echo ============================================================
echo.
echo  [1] Habilitar TRIM
echo  [2] Desativar desfragmentacao agendada
echo  [3] Aplicar as duas otimizacoes
echo  [0] Voltar
echo.
set "SSDOPT="
set /p "SSDOPT= Escolha: "

if "%SSDOPT%"=="1" (
    fsutil behavior set DisableDeleteNotify 0
    echo TRIM habilitado.
    pause
)
if "%SSDOPT%"=="2" (
    schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
    echo Desfragmentacao agendada desativada.
    pause
)
if "%SSDOPT%"=="3" (
    fsutil behavior set DisableDeleteNotify 0
    schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
    echo Otimizacoes SSD aplicadas.
    pause
)
if "%SSDOPT%"=="0" goto PERFORMANCE
goto SSD_OPTIMIZE

:STARTUP_MANAGER
cls
echo ============================================================
echo           GERENCIADOR DE INICIALIZACAO
echo ============================================================
echo.
echo  [1] Abrir Gerenciador de Tarefas
echo  [2] Abrir Configuracoes de Inicializacao do Windows
echo  [3] Abrir pasta de Inicializacao
echo  [0] Voltar
echo.
set "STARTOPT="
set /p "STARTOPT= Escolha: "

if "%STARTOPT%"=="1" start taskmgr
if "%STARTOPT%"=="2" start ms-settings:startupapps
if "%STARTOPT%"=="3" start shell:startup
if "%STARTOPT%"=="0" goto PERFORMANCE
goto STARTUP_MANAGER

:BLOATWARE
cls
echo ============================================================
echo           REMOCAO DE BLOATWARE
echo ============================================================
echo.
echo  [1] Jogos pre-instalados
echo  [2] Xbox
echo  [3] OneDrive
echo  [4] Cortana / Busca web
echo  [5] Noticias e apps desnecessarios
echo  [6] Remover todos
echo  [0] Voltar
echo.
set "BLOPT="
set /p "BLOPT= Escolha: "

if "%BLOPT%"=="0" goto PERFORMANCE
call :CONFIRM "Confirma a remocao?"
if errorlevel 1 goto BLOATWARE

if "%BLOPT%"=="1" powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *candycrush*,*king.com*,*MicrosoftSolitaire* | Remove-AppxPackage -ErrorAction SilentlyContinue"
if "%BLOPT%"=="2" powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *Xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue"
if "%BLOPT%"=="3" (
    taskkill /f /im OneDrive.exe >nul 2>&1
    if exist "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
)
if "%BLOPT%"=="4" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f >nul
)
if "%BLOPT%"=="5" powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *BingNews*,*BingWeather*,*GetHelp*,*Getstarted*,*Messaging*,*WindowsFeedbackHub*,*YourPhone*,*People* | Remove-AppxPackage -ErrorAction SilentlyContinue"
if "%BLOPT%"=="6" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *candycrush*,*king.com*,*MicrosoftSolitaire*,*Xbox*,*BingNews*,*BingWeather*,*GetHelp*,*Getstarted*,*Messaging*,*WindowsFeedbackHub*,*YourPhone*,*People* | Remove-AppxPackage -ErrorAction SilentlyContinue"
    taskkill /f /im OneDrive.exe >nul 2>&1
    if exist "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul
)

echo.
echo Remocao concluida.
pause
goto BLOATWARE

:: ============================================================
:: 5. DRIVERS + BIOS
:: ============================================================

:GPU_DRIVERS
cls
call :HEADER
echo.
echo  [1] NVIDIA - Site oficial
echo  [2] NVIDIA - Instalar GeForce Experience
echo  [3] AMD - Site oficial
echo  [4] AMD - Instalar Adrenalin
echo  [5] INTEL - Site oficial
echo  [6] INTEL - Instalar Driver Support Assistant
echo  [7] Verificar BIOS
echo  [0] Voltar
echo.
set "GPUOPT="
set /p "GPUOPT= Escolha: "

if "%GPUOPT%"=="1" start https://www.nvidia.com/Download/index.aspx
if "%GPUOPT%"=="2" winget install -e --id Nvidia.GeForceExperience --accept-source-agreements --accept-package-agreements --silent
if "%GPUOPT%"=="3" start https://www.amd.com/en/support
if "%GPUOPT%"=="4" winget install -e --id AMD.AMDSoftwareAdrenalinEdition --accept-source-agreements --accept-package-agreements --silent
if "%GPUOPT%"=="5" start https://www.intel.com/content/www/us/en/download-center/home.html
if "%GPUOPT%"=="6" winget install -e --id Intel.IntelDriverSupportAssistant --accept-source-agreements --accept-package-agreements --silent
if "%GPUOPT%"=="7" goto BIOS_CHECK
if "%GPUOPT%"=="0" goto MENU
goto GPU_DRIVERS

:BIOS_CHECK
cls
echo ============================================================
echo                  INFORMACOES DA BIOS
echo ============================================================
echo.
echo Fabricante da Placa-Mae:
wmic baseboard get manufacturer 2>nul
echo.
echo Modelo da Placa-Mae:
wmic baseboard get product 2>nul
echo.
echo Versao da BIOS:
wmic bios get smbiosbiosversion 2>nul
echo.
echo  [1] Abrir guia de atualizacao de BIOS
echo  [0] Voltar
set "BOPT="
set /p "BOPT= Escolha: "
if "%BOPT%"=="1" (
    echo.
    echo 1. Anote o modelo da placa-mae acima
    echo 2. Acesse o site oficial do fabricante
    echo 3. Baixe a BIOS mais recente
    echo 4. Use pendrive FAT32 e a ferramenta da BIOS (EZ Flash, Q-Flash, etc.)
    echo 5. Nunca desligue o computador durante a atualizacao
    pause
)
goto GPU_DRIVERS

:: ============================================================
:: 6. MONITOR
:: ============================================================

:DISPLAY_SETTINGS
cls
echo ============================================================
echo                  CONFIGURACOES DE TELA
echo ============================================================
echo.
echo  [1] Abrir Configuracoes de Tela do Windows
echo  [0] Voltar
echo.
set "DOPT="
set /p "DOPT= Escolha: "
if "%DOPT%"=="1" start ms-settings:display
if "%DOPT%"=="0" goto MENU
goto DISPLAY_SETTINGS

:: ============================================================
:: 7. REDE
:: ============================================================

:NETWORK_MENU
cls
echo ============================================================
echo                        REDE
echo ============================================================
echo.
echo  [1] Reset completo de rede
echo  [2] Flush DNS
echo  [3] Ver informacoes de rede
echo  [0] Voltar
echo.
set "NETOPT="
set /p "NETOPT= Escolha: "

if "%NETOPT%"=="1" goto NETWORK_RESET
if "%NETOPT%"=="2" (
    ipconfig /flushdns
    echo DNS limpo.
    pause
)
if "%NETOPT%"=="3" (
    ipconfig /all
    pause
)
if "%NETOPT%"=="0" goto MENU
goto NETWORK_MENU

:NETWORK_RESET
echo.
call :CONFIRM "Executar reset completo de rede? (recomendado reiniciar depois)"
if errorlevel 1 goto NETWORK_MENU

ipconfig /flushdns
ipconfig /release
ipconfig /renew
netsh winsock reset
netsh int ip reset
echo.
echo Reset de rede concluido. Reinicie o computador.
pause
goto NETWORK_MENU

:: ============================================================
:: 8. INFORMACOES
:: ============================================================

:INFO
cls
call :HEADER
echo.
echo  [1] Informacoes do Sistema
echo  [2] Abrir MSINFO32
echo  [3] Gerar relatorio
echo  [0] Voltar
echo.
set "I="
set /p "I= Escolha: "

if "%I%"=="1" (
    echo.
    systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"System Manufacturer" /C:"System Model" /C:"Total Physical Memory"
    echo.
    echo Computador: %COMPUTERNAME%
    echo Usuario: %USERNAME%
    pause
)
if "%I%"=="2" start msinfo32
if "%I%"=="3" goto INFO_REPORT
if "%I%"=="0" goto MENU
goto INFO

:INFO_REPORT
set "REPORT=%LOGDIR%\relatorio_%D%_%T%.txt"
echo Gerando relatorio...
systeminfo > "%REPORT%"
echo Relatorio salvo em:
echo %REPORT%
pause
goto INFO

:: ============================================================
:: 9. BACKUPS
:: ============================================================

:RESTORE_MENU
cls
echo ============================================================
echo                    BACKUPS E LOGS
echo ============================================================
echo.
echo  [1] Abrir pasta de Backups
echo  [2] Abrir pasta de Logs
echo  [0] Voltar
echo.
set "RESOPT="
set /p "RESOPT= Escolha: "
if "%RESOPT%"=="1" start "" "%BACKUPDIR%"
if "%RESOPT%"=="2" start "" "%LOGDIR%"
if "%RESOPT%"=="0" goto MENU
goto RESTORE_MENU

:: ============================================================
:: 10. DISKPART
:: ============================================================

:DISKPART_MENU
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │               DISKPART - GERENCIAR DISCOS            │
echo   └──────────────────────────────────────────────────────┘
echo.
echo     [ 1 ]  Abrir Diskpart (interativo)
echo     [ 2 ]  Listar TODOS os comandos e descricoes
echo     [ 3 ]  Comandos mais usados (resumo rapido)
echo.
echo     [ 0 ]  Voltar
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║  ATENCAO: Diskpart pode APAGAR TODOS OS DADOS!       ║
echo   ║  Sempre use "list disk" e confirme o numero antes.   ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
set "DPOPT="
set /p "DPOPT=   › Escolha: "

if "%DPOPT%"=="1" goto DISKPART_LAUNCH
if "%DPOPT%"=="2" goto DISKPART_FULL_HELP
if "%DPOPT%"=="3" goto DISKPART_QUICK
if "%DPOPT%"=="0" goto MENU
goto DISKPART_MENU

:DISKPART_LAUNCH
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │                   ABRINDO DISKPART                   │
echo   └──────────────────────────────────────────────────────┘
echo.
echo   Voce sera redirecionado para o interpretador Diskpart.
echo.
echo   • Digite "help" dentro do Diskpart para ver os comandos.
echo   • Digite "exit" para sair e voltar ao script.
echo.
echo   Lembrete importante:
echo   SEMPRE confirme o disco com "list disk" antes de usar
echo   clean, format, delete ou convert.
echo.
echo   ────────────────────────────────────────────────────────
pause
diskpart
goto DISKPART_MENU

:DISKPART_QUICK
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │            COMANDOS MAIS USADOS DO DISKPART          │
echo   └──────────────────────────────────────────────────────┘
echo.
echo  list disk              - Lista todos os discos fisicos
echo  list volume            - Lista todos os volumes (letras)
echo  list partition         - Lista particoes do disco selecionado
echo  select disk N          - Seleciona o disco numero N
echo  select volume N        - Seleciona o volume numero N
echo  select partition N     - Seleciona a particao numero N
echo  detail disk            - Mostra detalhes do disco selecionado
echo  detail volume          - Mostra detalhes do volume selecionado
echo  clean                  - Remove TODAS as particoes do disco (PERIGOSO)
echo  clean all              - Zera todos os setores (muito lento e irreversivel)
echo  create partition primary [size=MB] - Cria particao primaria
echo  format fs=ntfs quick   - Formata rapidamente em NTFS
echo  assign letter=X        - Atribui letra de unidade X
echo  remove letter=X        - Remove a letra de unidade X
echo  extend                 - Estende o volume para espaco livre
echo  shrink desired=MB      - Reduz o volume em MB
echo  convert gpt            - Converte disco para GPT (deve estar vazio)
echo  convert mbr            - Converte disco para MBR (deve estar vazio)
echo  active                 - Marca particao como ativa (MBR)
echo  rescan                 - Procura novos discos
echo  exit                   - Sai do Diskpart
echo.
echo  Fluxo tipico para formatar um pendrive:
echo    list disk
echo    select disk N
echo    clean
echo    create partition primary
echo    format fs=ntfs quick
echo    assign
echo    exit
echo.
pause
goto DISKPART_MENU

:DISKPART_FULL_HELP
cls
call :HEADER
echo.
echo   ┌──────────────────────────────────────────────────────┐
echo   │     LISTA COMPLETA DE COMANDOS DISKPART (Microsoft)  │
echo   └──────────────────────────────────────────────────────┘
echo.
echo  active
echo    Marca a particao com foco como ativa (MBR).
echo.
echo  add
echo    Espelha o volume simples com foco no disco especificado.
echo.
echo  assign
echo    Atribui uma letra de unidade ou ponto de montagem ao volume com foco.
echo.
echo  attach vdisk
echo    Anexa (monta) um VHD para que apareca como unidade local.
echo.
echo  attributes
echo    Exibe, define ou limpa os atributos de um disco ou volume.
echo.
echo  automount
echo    Habilita ou desabilita o recurso de montagem automatica.
echo.
echo  break
echo    Quebra o volume espelhado com foco em dois volumes simples.
echo.
echo  clean
echo    Remove toda a particao ou formatacao de volume do disco com foco.
echo    (PERIGOSO - apaga a tabela de particoes)
echo.
echo  compact vdisk
echo    Reduz o tamanho fisico de um arquivo VHD de expansao dinamica.
echo.
echo  convert
echo    Converte volumes FAT/FAT32 para NTFS (mantem arquivos)
echo    ou converte o estilo de particao do disco (mbr / gpt).
echo.
echo  create
echo    Cria uma particao em um disco, um volume ou um VHD.
echo.
echo  delete
echo    Exclui uma particao ou um volume.
echo.
echo  detach vdisk
echo    Impede que o VHD selecionado apareca como unidade local.
echo.
echo  detail
echo    Exibe informacoes sobre o disco, particao, volume ou VHD selecionado.
echo.
echo  exit
echo    Sai do interpretador de comando Diskpart.
echo.
echo  expand vdisk
echo    Expande um VHD para o tamanho especificado.
echo.
echo  extend
echo    Estende o volume ou particao com foco para espaco livre (nao alocado).
echo.
echo  filesystems
echo    Exibe o sistema de arquivos atual e os suportados para formatacao.
echo.
echo  format
echo    Formata um disco/volume para aceitar arquivos.
echo.
echo  gpt
echo    Atribui atributos GPT a particao com foco (discos GPT).
echo.
echo  help
echo    Exibe a lista de comandos ou ajuda detalhada de um comando.
echo.
echo  import
echo    Importa um grupo de discos estrangeiros para o grupo local.
echo.
echo  inactive
echo    Marca a particao de sistema/boot com foco como inativa (MBR).
echo.
echo  list
echo    Exibe lista de discos, particoes, volumes ou VHDs.
echo.
echo  merge vdisk
echo    Mescla um VHD diferencial com seu VHD pai correspondente.
echo.
echo  offline
echo    Coloca um disco ou volume online em estado offline.
echo.
echo  online
echo    Coloca um disco ou volume offline em estado online.
echo.
echo  recover
echo    Atualiza o estado de todos os discos em um grupo e tenta recuperar.
echo.
echo  rem
echo    Adiciona comentarios em um script Diskpart.
echo.
echo  remove
echo    Remove uma letra de unidade ou ponto de montagem de um volume.
echo.
echo  repair
echo    Repara o volume RAID-5 com foco substituindo a regiao com falha.
echo.
echo  rescan
echo    Localiza novos discos que podem ter sido adicionados ao computador.
echo.
echo  retain
echo    Prepara um volume simples dinamico existente para uso como boot/sistema.
echo.
echo  san
echo    Exibe ou define a politica de SAN (Storage Area Network).
echo.
echo  select
echo    Desloca o foco para um disco, particao, volume ou VHD.
echo.
echo  set id
echo    Altera o campo de tipo de particao para a particao com foco.
echo.
echo  shrink
echo    Reduz o tamanho do volume selecionado pela quantidade especificada.
echo.
echo  uniqueid
echo    Exibe ou define o identificador GPT ou a assinatura MBR do disco.
echo.
echo   ────────────────────────────────────────────────────────
echo   Dica: Dentro do Diskpart digite "help nome_do_comando"
echo   para ver a sintaxe completa de cada comando.
echo   ────────────────────────────────────────────────────────
echo.
pause
goto DISKPART_MENU

:: ============================================================
:: FUNCOES AUXILIARES
:: ============================================================

:BACKUP_POWER
powercfg /getactivescheme > "%BACKUP%\power_active.txt" 2>&1
exit /b

:BACKUP_SYSMAIN
sc query SysMain > "%BACKUP%\sysmain.txt" 2>&1
exit /b

:BACKUP_VISUAL
reg export "HKCU\Control Panel\Desktop" "%BACKUP%\desktop.reg" /y >nul 2>&1
exit /b

:CONFIRM
echo.
echo   ────────────────────────────────────────────────────────
set "ANS="
set /p "ANS=   › %~1  [S/N]: "
if /i "%ANS%"=="S" exit /b 0
if /i "%ANS%"=="SIM" exit /b 0
exit /b 1

:HEADER
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║             %APPNAME%  %VERSION%                  ║
echo  ╚════════════════════════════════════════════════════════╝
echo   Sistema: %OS%   ^|   Build: %BUILD%
echo  ──────────────────────────────────────────────────────────
exit /b

:SEPARATOR
echo  ──────────────────────────────────────────────────────────
exit /b

:LOG
>>"%LOGFILE%" echo [%date% %time%] %~1
exit /b

:EXIT
call :LOG "=== Encerrado ==="
cls
color 0B
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║              WINDOWS OPTIMIZER ENCERRADO               ║
echo  ╚════════════════════════════════════════════════════════╝
echo.
echo   Obrigado por utilizar o %APPNAME% %VERSION%.
echo.
echo   Logs:     %LOGDIR%
echo   Backups:  %BACKUPDIR%
echo.
echo  ──────────────────────────────────────────────────────────
echo.
endlocal
exit /b 0