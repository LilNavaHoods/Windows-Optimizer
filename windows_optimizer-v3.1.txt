@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Optimizer v3.1

:: ============================================================
:: WINDOWS OPTIMIZER v3.1 (Versao Estavel - sem PowerShell instavel)
:: ============================================================

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
    echo ============================================================
    echo              PERMISSAO DE ADMINISTRADOR
    echo ============================================================
    echo.
    echo Este programa PRECISA ser executado como Administrador.
    echo.
    echo Clique com o botao direito no arquivo e escolha:
    echo "Executar como administrador"
    echo.
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
    echo Sistema nao suportado: %OS%
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
call :HEADER
echo.
echo  [1] Limpeza de arquivos
echo  [2] Reparo do Sistema
echo  [3] Instalar programas
echo  [4] Ajustes de desempenho
echo  [5] Drivers + BIOS
echo  [6] Monitor (Resolucao)
echo  [7] Rede
echo  [8] Informacoes do computador
echo  [9] Backups / Logs
echo  [0] Sair
echo.
echo ============================================================
set "OPT="
set /p "OPT= Escolha uma opcao: "

if "%OPT%"=="1" goto CLEAN_MENU
if "%OPT%"=="2" goto REPAIR_MENU
if "%OPT%"=="3" goto INSTALL_APPS
if "%OPT%"=="4" goto PERFORMANCE
if "%OPT%"=="5" goto GPU_DRIVERS
if "%OPT%"=="6" goto DISPLAY_SETTINGS
if "%OPT%"=="7" goto NETWORK_MENU
if "%OPT%"=="8" goto INFO
if "%OPT%"=="9" goto RESTORE_MENU
if "%OPT%"=="0" goto EXIT

echo Opcao invalida.
timeout /t 2 >nul
goto MENU

:: ============================================================
:: 1. LIMPEZA
:: ============================================================

:CLEAN_MENU
cls
call :HEADER
echo.
echo  [1] Limpeza rapida (Temporarios)
echo  [2] Limpeza avancada
echo  [3] Limpeza Windows Update (DISM)
echo  [0] Voltar
echo.
set "CLOPT="
set /p "CLOPT= Escolha: "

if "%CLOPT%"=="1" goto TEMP
if "%CLOPT%"=="2" goto ADVANCED_CLEAN
if "%CLOPT%"=="3" goto UPDATE
if "%CLOPT%"=="0" goto MENU
goto CLEAN_MENU

:TEMP
cls
echo ============================================================
echo              LIMPEZA DE TEMPORARIOS
echo ============================================================
echo.
call :CONFIRM "Deseja continuar?"
if errorlevel 1 goto CLEAN_MENU

echo Limpando arquivos temporarios...
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1

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
echo  [1] Criar Ponto de Restauracao
echo  [2] Executar SFC
echo  [3] Executar DISM RestoreHealth
echo  [4] Executar SFC + DISM
echo  [0] Voltar
echo.
set "ROPT="
set /p "ROPT= Escolha: "

if "%ROPT%"=="1" goto CREATE_RESTORE
if "%ROPT%"=="2" goto RUN_SFC
if "%ROPT%"=="3" goto RUN_DISM
if "%ROPT%"=="4" goto RUN_SFC_DISM
if "%ROPT%"=="0" goto MENU
goto REPAIR_MENU

:CREATE_RESTORE
cls
echo ============================================================
echo              CRIAR PONTO DE RESTAURACAO
echo ============================================================
echo.
call :CONFIRM "Deseja criar o ponto de restauracao?"
if errorlevel 1 goto REPAIR_MENU

echo Criando ponto de restauracao...
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
echo  [1] 7-Zip          [2] WinRAR         [3] KeePass
echo  [4] Notepad++      [5] Everything     [6] ShareX
echo  [7] WinDirStat     [8] Chrome         [9] Firefox
echo  [10] Brave         [11] Telegram      [12] Discord
echo  [13] VLC           [14] Spotify       [15] VS Code
echo  [16] PowerToys     [17] qBittorrent   [18] Acrobat
echo.
echo  [19] Instalar TODOS
echo  [0]  Voltar
echo.
set "ESCOLHA="
set /p "ESCOLHA= Digite os numeros (ex: 1 4 8) ou 19: "

if "%ESCOLHA%"=="0" goto MENU
if "%ESCOLHA%"=="" goto INSTALL_APPS

where winget >nul 2>&1
if errorlevel 1 (
    echo Winget nao encontrado. Instale o "App Installer" na Microsoft Store.
    pause
    goto MENU
)

call :CONFIRM "Iniciar instalacao dos programas selecionados?"
if errorlevel 1 goto INSTALL_APPS

echo %ESCOLHA% | findstr /i "\<19\>" >nul && goto INSTALL_ALL

echo %ESCOLHA% | findstr /i "\<1\>"  >nul && winget install -e --id 7zip.7zip --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<2\>"  >nul && winget install -e --id RARLab.WinRAR --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<3\>"  >nul && winget install -e --id DominikReichl.KeePass --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<4\>"  >nul && winget install -e --id Notepad++.Notepad++ --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<5\>"  >nul && winget install -e --id voidtools.Everything --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<6\>"  >nul && winget install -e --id ShareX.ShareX --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<7\>"  >nul && winget install -e --id WinDirStat.WinDirStat --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<8\>"  >nul && winget install -e --id Google.Chrome --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<9\>"  >nul && winget install -e --id Mozilla.Firefox --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<10\>" >nul && winget install -e --id Brave.Brave --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<11\>" >nul && winget install -e --id Telegram.TelegramDesktop --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<12\>" >nul && winget install -e --id Discord.Discord --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<13\>" >nul && winget install -e --id VideoLAN.VLC --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<14\>" >nul && winget install -e --id Spotify.Spotify --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<15\>" >nul && winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<16\>" >nul && winget install -e --id Microsoft.PowerToys --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<17\>" >nul && winget install -e --id qBittorrent.qBittorrent --accept-source-agreements --accept-package-agreements --silent
echo %ESCOLHA% | findstr /i "\<18\>" >nul && winget install -e --id Adobe.Acrobat.Reader.64-bit --accept-source-agreements --accept-package-agreements --silent

echo.
echo Instalacao finalizada.
pause
goto MENU

:INSTALL_ALL
winget install -e --id 7zip.7zip --accept-source-agreements --accept-package-agreements --silent
winget install -e --id RARLab.WinRAR --accept-source-agreements --accept-package-agreements --silent
winget install -e --id DominikReichl.KeePass --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Notepad++.Notepad++ --accept-source-agreements --accept-package-agreements --silent
winget install -e --id voidtools.Everything --accept-source-agreements --accept-package-agreements --silent
winget install -e --id ShareX.ShareX --accept-source-agreements --accept-package-agreements --silent
winget install -e --id WinDirStat.WinDirStat --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Google.Chrome --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Telegram.TelegramDesktop --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Discord.Discord --accept-source-agreements --accept-package-agreements --silent
winget install -e --id VideoLAN.VLC --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
winget install -e --id Microsoft.PowerToys --accept-source-agreements --accept-package-agreements --silent
echo.
echo Todos os programas principais foram instalados.
pause
goto MENU

:: ============================================================
:: 4. DESEMPENHO
:: ============================================================

:PERFORMANCE
cls
call :HEADER
echo.
echo  [1] Combo de desempenho
echo  [2] Otimizacao SSD
echo  [3] Gerenciador de Inicializacao
echo  [4] Remover Bloatware
echo  [0] Voltar
echo.
set "PERFOPT="
set /p "PERFOPT= Escolha: "

if "%PERFOPT%"=="1" goto PERFORMANCE_COMBO
if "%PERFOPT%"=="2" goto SSD_OPTIMIZE
if "%PERFOPT%"=="3" goto STARTUP_MANAGER
if "%PERFOPT%"=="4" goto BLOATWARE
if "%PERFOPT%"=="0" goto MENU
goto PERFORMANCE

:PERFORMANCE_COMBO
cls
echo ============================================================
echo                  COMBO DE DESEMPENHO
echo ============================================================
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
set "ANS="
set /p "ANS=%~1 [S/N]: "
if /i "%ANS%"=="S" exit /b 0
exit /b 1

:HEADER
echo ============================================================
echo              %APPNAME% %VERSION%
echo ============================================================
echo Sistema: %OS%  ^|  Build: %BUILD%
echo ============================================================
exit /b

:LOG
>>"%LOGFILE%" echo [%date% %time%] %~1
exit /b

:EXIT
call :LOG "=== Encerrado ==="
cls
echo.
echo Windows Optimizer encerrado.
echo.
echo Logs:    %LOGDIR%
echo Backups: %BACKUPDIR%
echo.
endlocal
exit /b 0