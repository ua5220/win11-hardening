::&cls&::   Сделали: westlife и LeX333666 -- ru-board.com --
:::::::::   http://forum.ru-board.com/topic.cgi?forum=62&topic=30041&start=480#21
:::::::::   Ссылка на закачку новая, старая заблокирована по ошибке Яндекс https://yadi.sk/d/CMqvcp1F3QiaWL

@echo off
title Check Settings LTSB
:: Вызов сценария начала
goto :First

::   Получение версии системы
:LangVers
for /f "tokens=3*" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "UBR" ') do set /a BuildVer=%%I
if "%BuildVer%" NEQ "" set "BuildVer=.{0f}%BuildVer%{#}"
for /f "tokens=4 delims=[] " %%I in ('ver') do (
 if "%%I"=="10.0.14393" (set "OSVersion={0a}%%I%BuildVer%{#}" & set "OSVers=%%I"
 ) else (set "OSVersion={0e}%%I  {4f} Версия не поддерживается {#}" & set "OSVers=%%I"))
for /f "tokens=3*" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName" ') do (
 if not "%%I %%J"=="Windows 10 Enterprise 2016 LTSB" (set "ProductNameNo={0c}%%I %%J{#}"
 ) else if "%OSVers%"=="10.0.14393" (set "ProductName=^| {0a}LTSB RS1{#}"))
::   Отображение языка системы, батник должен работать с любым языком.
for /f tokens^=2-8^ delims^=^={}^" %%A in (' wmic os get MUILanguages /Value 2^>nul ') do (
set "OSLang=%%A" & if "%%B" EQU "," set "OSLang=%%A%%B %%C" & if "%%D" EQU "," set "OSLang=%%A%%B %%C%%D %%E" & if "%%F" EQU "," set "OSLang=%%A%%B %%C%%D %%E%%F %%G")


::   Сценарий Меню выбора действий
:Menu
cls
echo.
%ch% {08}  ╔═════════════════════════════════════════════════════════════════════╗                     {\n #}
%ch% {08}  ║     {07}Проверка {08}редакции {0f}Windows 10 Enterprise {0a}LTSB RS1 10.0.14393     {08}║ {\n #}
%ch% {08}  ╚═════════════════════════════════════════════════════════════════════╝                     {\n #}
echo.
%ch%         Ваша Windows:{0a} %xOS% {#}^|{0a} %OSLang% {#}^| %OSVersion% %ProductName%{00}.{\n #}
echo.
if  "%OSVers%"=="10.0.14393" if not "%ProductNameNo%"=="" (
%ch%         {0e}Внимание{#} Ваша редакция не LTSB RS1: %ProductNameNo% {\n #}
%ch%                                             {0e}Отключатся Модерн и другие приложения от Microsoft ^!^!^! {\n #})
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1] = {0e}Spy{#} (Только проверка значений по слежению, сбору и AppStore) {\n #}
%ch% {0b}    [2] = {0e}Settings{#} (Только проверка значений дополнительных настроек Windows) {\n #}
%ch% {0b}    [3] = {0e}Сделать все{#} (Проверить значения слежения, AppStore и настроек) {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {0e}Выйти {\n #}
%ch%                                                     {08} ^| Версия 3.16{\n #}
set "choice="
Set /p choice=--- Ваш выбор: 
if not defined choice (	del /f /q %batfile% & echo. & %ch%    {0e}Выход. {\n #}
			TIMEOUT /T 3 >nul & exit )
if "%choice%"=="1" ( cls & goto :Spy )
if "%choice%"=="2" ( cls & goto :Settings )
if "%choice%"=="3" ( cls & goto :Spy
	) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
		 TIMEOUT /T 2 >nul & goto :Menu  )


::     ------------------------------------------------
::     ----      Ниже начинается 1 часть: Spy      ----
::     ------------------------------------------------


:Spy
echo.
%ch% {0b}    ============================================================================== {\n #}
%ch%         {0b}1 часть: SPY{#}- Проверка значений слежения, сбора информации и AppStore {\n #}
%ch% {0b}    ============================================================================== {\n #}
echo.

:: -------------------------------------------------------------------
:: ---  Ниже идет проверка служб по сбору информации для отправки, ---
:: ---  магазина и приложений AppStore на тип запуска "Отключено": ---

echo.
%ch% {0b}   -----------------    Службы SPY   ------------------- {\n #}
echo.


echo.&   set Info=Служба: Диагностическое отслеживание
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "DiagTrack" "disabled"


echo.&   set Info=Служба: Сборщик центра диагностики
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "diagnosticshub.standardcollector.service" "disabled"


echo.&   set Info=Служба: Маршрутизация push-сообщений WAP
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "dmwappushservice" "disabled"


echo.&   set Info=Служба: DataCollectionPublishingService
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "DcpSvc" "disabled"


echo.&   set Info=Служба: Посредник подключений к сети
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "NcbService" "disabled"


echo.&   set Info=Службы: для Xbox Live
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "XblGameSave" "disabled"
Call :CheckService "XblAuthManager" "disabled"
Call :CheckService "XboxNetApiSvc" "disabled"


echo.&   set Info=Служба: Платформы подключенных устройств CDPSvc
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "CDPSvc" "disabled"


echo.&   set Info=Служба: Диспетчер скачанных карт
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "MapsBroker" "disabled"


echo.&   set Info=Служба: Управление финансами
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "WalletService" "disabled"



:: ---------------------------------------------------------------
:: ---  Ниже идет проверка параметров по сбору информации      ---
:: ---  для отправки, так же магазина и приложений AppStore    ---



echo.
echo.
%ch% {0b}    -----------------    Параметры  SPY  ------------------- {\n #}
echo.


echo.&   set Info=Проверка телеметрии и сбора данных
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f "DEL /f /q %ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl"
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
Call :CheckReg "TI" reg add "HKLM\SOFTWARE\Classes\AppID\slui.exe" /v "NoGenTicket" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка возможности использования предварительных версий
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableConfigFlighting" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableExperimentation" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка psr.exe Problem Steps Recorder - Средство записи действий
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка дополнительной телеметрии и Steps-Recorder
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Inventory" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Steps-Recorder" /v "Enabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка сбора и отправки данных PerfTrack и DiagTrack
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\PerfTrack" /v "Disabled" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "Disabled" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DisableAutomaticTelemetryKeywordReporting" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "TelemetryServiceDisabled" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks" /v "DisableAsimovUpload" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка сбора персональных данных
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка Сбора, обучения и персонализации ввода набираемых текстов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка сбора и передачи текста, набираемых вами
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка частоты формирования отзывов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f



:: ---------------------------------------------------------------------------
:: ---------------------------------------------------------------------------
:: --- Ниже идет проверка заданий в планировщике по сбору вашей информации ---
:: --- для пересылки, а также  приложений AppStore и Магазина Windows      ---


echo.
echo.
%ch% {0b}    -----------------    Задачи  SPY  ------------------- {\n #}
echo.


echo.&   set Info=Задача: Выполняющая сбор данных для SmartScreen
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable


echo.&   set Info=Задачи: Сбора телеметрических данных программ
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
Call :CheckTask "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
Call :CheckTask "Microsoft\Windows\Application Experience\StartupAppTask" /Disable


echo.&   set Info=Задача: Сбора и загрузки данных SQM
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Autochk\Proxy" /Disable


echo.&   set Info=Задачи: Для AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
Call :CheckTask "Microsoft\Windows\Clip\License Validation" /Disable


echo.&   set Info=Задачи: CEIP
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
Call :CheckTask "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
Call :CheckTask "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
Call :CheckTask "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
Call :CheckTask "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable


echo.&   set Info=Задачи: Feedback SIUF
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable
Call :CheckTask "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable


echo.&   set Info=Задачи: Проверки и обновления Карт AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Maps\MapsToastTask" /Disable
Call :CheckTask "Microsoft\Windows\Maps\MapsUpdateTask" /Disable


echo.&   set Info=Задача: Сборщик полных сведений компьютера и сети
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable


echo.&   set Info=Задача: Для CEIP
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\PI\Sqm-Tasks" /Disable


echo.&   set Info=Задачи: Для синхронизации AppSrore приложений
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable
Call :CheckTask "Microsoft\Windows\SettingSync\BackupTask" /Disable


echo.&   set Info=Задача: Автоматическое обновление приложений Магазина Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::   Отключение задач с правами SYSTEM, с помощью файла "nircmdc.exe"   :::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&   set Info=Задачи: Регистрации, доступа и синхронизации с устройствами
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTaskInSys "Microsoft\Windows\SettingSync\BackgroundUpLoadTask" /Disable
Call :CheckTaskInSys "Microsoft\Windows\Device Setup\Metadata Refresh" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\HandleCommand" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceConnectedToNetwork" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic1" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic6" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceScreenOnOff" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" /Disable
Call :CheckTaskInSys "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" /Disable




echo:&   set Info=Задачи: По телеметрии Office 2013 и 2016
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable
Call :CheckTask "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable
Call :CheckTask "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /Disable
Call :CheckTask "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable
Call :CheckTask "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable


echo.&   set Info=Проверка сбора данных по телеметрии Office 2016
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
reg query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" (
 Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" /v "Start" /t REG_DWORD /d "0" /f
) else ( echo.       ---: "WMI EventLog-AirSpaceChannel" )
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" (
 Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" /v "Enabled" /t REG_DWORD /d "0" /f "DEL /f /q %WinDir%\System32\Winevt\Logs\AirSpaceChannel.etl"
) else ( echo.       ---: "WINEVT EventLog-AirSpaceChannel" )


echo.&   set Info=Служба: Телеметрии NVIDIA GeForce Experience
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "NvTelemetryContainer" "disabled"

echo.&   set Info=Задачи: По телеметрии драйверов Nvidia
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
set "NvidiaNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "NvTm" /d ^| find /i "Path" ^| findstr /i "NvTmRepOnLogon_ NvTmRep_ NvTmMon_"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 Call :CheckTask "%%~I" /Disable
 set "NvidiaNo=0" ))
if "%NvidiaNo%"=="1" echo.       ---: "Нет задач телеметрии Nvidia"




	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  Установка значений конфиденциальности в Modern аплете настроек.  ::
	::  Они предназначены для всех Modern аплетов и AppStore хлама       ::
	::  Эти установки влияют только на текущего пользователя,            ::
	::  и могут быть в ручную изменены в Modern настройках,              ::
	::  кроме некоторых, которые M$ скрыло от пользователя!!!            ::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
echo.
%ch% {0b}    -----------------    Значения конфидециальности SPY  ------------------- {\n #}
echo.


echo.&   set Info=Проверка использования вашего ID для получения рекламы
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id"
if "%xOS%"=="x64" (
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f
)


echo.&   set Info=Проверка SmartScreen
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка доступа приложений AppStore к списку языков
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Разрешений приложеням AppStore на др. устройствах работать на этом устройстве
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "BluetoothPolicy" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка доступа приложений AppStore к Веб Камере
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore к Микрофону
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore к Вашей Учетной записи
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к контактам, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{7D7E8402-7C54-4821-A34E-AEEFD62DED93}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{7D7E8402-7C54-4821-A34E-AEEFD62DED93}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{7D7E8402-7C54-4821-A34E-AEEFD62DED93}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore к календарю
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore к сообщениям, СМС, ММС
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore ко всем сообщениям, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{21157C1F-2651-4CC1-90CA-1F28B02263F6}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{21157C1F-2651-4CC1-90CA-1F28B02263F6}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{21157C1F-2651-4CC1-90CA-1F28B02263F6}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа приложений AppStore к Радиомодулям
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка синхронизации с устройствами для приложений AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Type" /t REG_SZ /d "LooselyCoupled" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к языковым настройкам, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к определению расположения, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к телефонным звонкам, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{235B668D-B2AC-4864-B49C-ED1084F6C9D3}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{235B668D-B2AC-4864-B49C-ED1084F6C9D3}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{235B668D-B2AC-4864-B49C-ED1084F6C9D3}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к Журналу вызовов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к уведомлениям пользователя
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к E-mail
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f


echo.&   set Info=Проверка доступа всех приложений AppStore к Мероприятиям, Скрытые
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9D9E0118-1807-4F2E-96E4-2CE57142E196}" /v "Value" /t REG_SZ /d "Deny" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9D9E0118-1807-4F2E-96E4-2CE57142E196}" /v "Type" /t REG_SZ /d "InterfaceClass" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9D9E0118-1807-4F2E-96E4-2CE57142E196}" /v "InitialAppValue" /t REG_SZ /d "Unspecified" /f



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&   set Info=Проверка доступа к личным данным для всех AppStore пакетов, указанных индивидуально:
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
setlocal EnableDelayedExpansion
set Key="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess"
for /f "tokens=1" %%i in (' reg query %Key% /s /f Allow ^| find "S-1-15" ^| find "{" ') do (
 set regfix1=reg add "%%i" /v "Type" /t REG_SZ /d InterfaceClass /f
 set regfix2=reg add "%%i" /v "Value" /t REG_SZ /d Deny /f
 %ch% {0e}   #######: "%Info:~0,58%" Исправить^^^! {\n #}
 (echo.
  echo.echo.&echo.%%ch%%   {0f}"%Info:~0,58%" {0b}Исправить^^^!{\n #}
  echo.!regfix1!
  echo.!regfix2!
 )>>%batfile%
 set "AllowFind1=%%i"
)
for /f "tokens=1" %%i in (' reg query %Key% /s /f Allow ^| find "S-1-15" ^| find "LooselyCoupled" ') do (
 set regfix1=reg add "%%i" /v "Type" /t REG_SZ /d LooselyCoupled /f
 set regfix2=reg add "%%i" /v "Value" /t REG_SZ /d Deny /f
 %ch% {0e}   #######: "%Info:~0,58%" Исправить^^^! {\n #}
 (echo.
  echo.echo.&echo.%%ch%%   {0f}"%Info:~0,58%" {0b}Исправить^^^!{\n #}
  echo.!regfix1!
  echo.!regfix2!
 )>>%batfile%
 set "AllowFind2=%%i"
)
if /i "!AllowFind1!"=="" if /i "!AllowFind2!"=="" echo.       +++: "Все отключено"
endlocal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&   set Info=Проверка фоновой работы Аплета настроек Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
setlocal EnableDelayedExpansion
set regpath="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
for /f "delims=\ tokens=7" %%i in (' reg query %regpath% /s /f "immersivecontrolpanel" ') do set reply=%%i
set regfix1=reg add "%regpath:~1,-1%\%reply%" /v "Disabled" /t REG_DWORD /d 1 /f
set regfix2=reg add "%regpath:~1,-1%\%reply%" /v "DisabledByUser" /t REG_DWORD /d 1 /f
set regfix3=reg add "%regpath:~1,-1%\%reply%" /v "IgnoreBatterySaver" /t REG_DWORD /d 0 /f
if not "%reply%"=="" (
 for /f "tokens=3" %%i in (' 2^>nul reg query "!regpath:~1,-1!\!reply!" /v "Disabled" ') do set /a value=%%i
 if "!value!"=="1" (echo.       +++: "%Info%"
  ) else (
   %ch% {0e}   #######: "%Info%"   Исправить^^^!{\n #}
  (echo.
   echo.echo.&echo.%%ch%%   {0f}"%Info%" {0b}Исправить^^^!{\n #}
   echo.!regfix1!
   echo.!regfix2!
   echo.!regfix3!
  )>>%batfile%
 )
) else ( echo.        --: "immersivecontrolpanel" не существует. )
endlocal
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if "%choice%"=="1" (
 echo.&echo.
 %ch% {0b}    ---------------------------------------------- {\n #}
 %ch% {0b}      - Завершена проверка только 1 части: SPY -   {\n #}
 %ch% {0b}    ---------------------------------------------- {\n #}
 echo.
 goto :AddPause
) else (
 echo.&echo.
 %ch% {0b}    --------------------------------------- {\n #}
 %ch% {0b}      - Завершена проверка 1 части: SPY -   {\n #}
 %ch% {0b}    --------------------------------------- {\n #}
 echo.
 goto :Settings
)


::     -----------------------------------------------------
::     ----      Ниже начинается 2 часть: Settings      ----
::     -----------------------------------------------------


:Settings
echo.
%ch% {0b}   ========================================================== {\n #}
%ch%         {0b}2 часть: Settings{#}  -  Проверка настроек Windows 10 {\n #}
%ch% {0b}   ========================================================== {\n #}
echo.



:: --------------------------------------------------------------------------
:: ---  Ниже идет проверка не обязательных служб по обслуживанию системы  ---

echo.
echo.
%ch% {0b}    -----------------    Службы  Settings  ------------------- {\n #}
echo.


echo.&   set Info=Служба: Общие сетевые ресурсы проигрывателя Windows Media
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "WMPNetworkSvc" "disabled"


echo.&   set Info=Служба: Немедленные подключения Windows для Windows Connect Now
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "wcncsvc" "disabled"


echo.&   set Info=Служба: Наблюдение за датчиками
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "SensrSvc" "disabled"


echo.&   set Info=Служба: Биометрическая служба Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "WbioSrvc" "disabled"


echo.&   set Info=Служба: -Retail Demo-
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "RetailDemo" "disabled"


echo.&   set Info=Служба: Датчиков
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "SensorService" "disabled"


echo.&   set Info=Служба: Данных датчиков
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckService "SensorDataService" "disabled"


echo.&   set Info=Проверка Службы Windows License Manager для Windows AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Services\LicenseManager" /v "Start" /t REG_DWORD /d "4" /f


echo.&   set Info=Проверка Службы Географического расположения для AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d "4" /f


echo.&   set Info=Проверка Службы Push-уведомлений Windows для приложений AppStore
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d "4" /f


echo.&   set Info=Проверка Службы Помощник по входу в учетную запись Майкрософт
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
echo.   Необходим для магазина Windows
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Services\wlidsvc" /v "Start" /t REG_DWORD /d "4" /f


:: ---------------------------------------------------------------------
:: ---------------------------------------------------------------------
:: ---   Ниже идет проверка не обязательных заданий в планировщике   ---
:: ---   по обслуживанию системы.                                    ---

echo.
echo.
%ch% {0b}    -----------------    Задачи  Settings  ------------------- {\n #}
echo.



echo.&   set Info=Задача: Очистка системного диска во время простоя
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\DiskCleanup\SilentCleanup" /Disable


echo.&   set Info=Задача: Оценки объема использования диска
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable


echo.&   set Info=Задача: Storage Sense - перемещение Modern Apps на другой диск по необходимости
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\DiskFootprint\StorageSense" /Disable


echo.&   set Info=Задачи: Проверки томов на отказоустойчивость
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan" /Disable
Call :CheckTask "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery" /Disable



echo.&   set Info=Задача: Копирования файлов пользователя в резервное расположение, для архивации
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable


echo.&   set Info=Задача: Измерение быстродействия и возможностей системы
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Maintenance\WinSAT" /Disable


echo.&   set Info=Задачи: Обслуживания памяти во время простоя и при ошибках
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /Disable
Call :CheckTask "Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /Disable


echo.&   set Info=Задача: Анализирования энергопотребления системы
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable


echo.&   set Info=Задачи: Контроля и выполнения семейной безопасности
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable
Call :CheckTask "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" /Disable
Call :CheckTask "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Disable


echo.&   set Info=Задача: Отправка отчетов об ошибках
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::   Ниже идут дополнительные задачи   ::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&   set Info=Задача: Очистка контента Retail Demo
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /Disable


echo.&   set Info=Задачи: Уведомления о вашем расположении
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Location\Notifications" /Disable
Call :CheckTask "Microsoft\Windows\Location\WindowsActionDialog" /Disable


echo.&   set Info=Задача: Анализ метаданных мобильной сети
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Disable


echo.&   set Info=Задача: Веб-сайта инфраструктуры диагностики Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\WDI\ResolutionHost" /Disable


echo.&   set Info=Задача: Обновление новых файлов в библиотеке мультимедиа
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /Disable


echo.&   set Info=Задачи: Регистрация и проверка ссылок от приложений
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\ApplicationData\appuriverifierinstall" /Disable
Call :CheckTask "Microsoft\Windows\ApplicationData\appuriverifierdaily" /Disable


echo.&   set Info=Задача: Сбор и отправка данных об устройствах
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Device Information\Device" /Disable


echo.&   set Info=Задачи: Xbox
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\XblGameSave\XblGameSaveTask" /Disable
Call :CheckTask "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable


echo.&   set Info=Задача: DUSM для мобильного интернета
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\DUSM\dusmtask" /Disable


echo.&   set Info=Задачи: Детализации ошибок
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Disable
Call :CheckTask "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Disable


echo.&   set Info=Задача: Выдача временных лицензий для Приложений Магазина
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\License Manager\TempSignedLicenseExchange" /Disable


echo.&   set Info=Задача: Согласование пакетов во время SYSPREP и загрузки, ProvTool.exe
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Management\Provisioning\Logon" /Disable


echo.&   set Info=Задачи: Фонового взаимодействия через WiFi
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\NlaSvc\WiFiTask" /Disable
Call :CheckTask "Microsoft\Windows\WCM\WiFiTask" /Disable


echo.&   set Info=Задачи: Обслуживания дисковых пространств, аналог RAID, виртуальные диски
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\SpacePort\SpaceAgentTask" /Disable
Call :CheckTask "Microsoft\Windows\SpacePort\SpaceManagerTask" /Disable


echo.&   set Info=Задача: Загрузка голосовых моделей
echo. ----------------------------------------------------------------------------------------------------------------------
echo.    %Info%
Call :CheckTask "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Disable






:: --------------------------------------------------------
:: ---  Ниже идет проверка параметров настроек Windows  ---
:: --------------------------------------------------------



echo.
echo.
%ch% {0b}    -----------------    Параметры  Settings  ------------------- {\n #}
echo.


echo.&   set Info=Проверка запрета получения обновлений и телеметрии для средства удаления вирусов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::   Полное отключение OneDrive   ::::::::::::::

echo.&   set Info=Проверка OneDrive
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f "TASKKILL /F /IM OneDrive.exe /T"
Call :CheckReg "--" reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d "0xf090004d" /f
Call :CheckReg "--" reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d "0xf090004d" /f
if "%xOS%"=="x64" (
Call :CheckReg "--" reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d "0xf090004d" /f
Call :CheckReg "--" reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d "0xf090004d" /f
)

echo.&   set Info=Задачи: OneDrive
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
set "OneDriveTaskNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "OneDrive" /d ^| find /i "Path" ^| find /i "OneDrive"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 Call :CheckTask "%%~I" /Disable
 set "OneDriveTaskNo=0" ))
if "%OneDriveTaskNo%"=="1" echo.       ---: "Нет задач OneDrive"

echo.&   set Info=Проверка запрета использования OneDrive
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d "0" /f

::::::::::::   Проверка OneDrive закончена   ::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



echo.&   set Info=Проверка рекламы в проводнике от OneDrive
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f



echo.&   set Info=Проверка служб синхронизации, необходимых и для OneDrive
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "CDPUserSvc" ^| find /i "CDPUserSvc" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "OneSyncSvc" ^| find /i "OneSyncSvc" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "PimIndexMaintenanceSvc" ^| find /i "PimIndexMaintenanceSvc" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UnistoreSvc" ^| find /i "UnistoreSvc" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UserDataSvc" ^| find /i "UserDataSvc" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "MessagingService" ^| find /i "MessagingService" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "WpnUserService" ^| find /i "WpnUserService" ') do (
 Call :CheckReg "--" reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f)



echo.&   set Info=Проверка Автопередачи паролей и автоподключений к WiFi -WiFiSense-
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&   set Info=Проверка параметров Автоподключения к WiFi без пароля и от своих контактов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
setlocal EnableDelayedExpansion
set info1=Запрет всем пользователям автоподключение к WiFi
set info2=без пароля и от своих контактов.
set keysearch="HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features"
for /f "delims=" %%I in (' reg query !keysearch! /s /f "FeatureStates" ^| find "S-1" ') do (
 set "reaply=%%I"
 set value=
 for /f "tokens=3" %%J in (' reg query "!reaply!" /f "FeatureStates" ^| find "0x33c" ') do set value=%%J
 if "!value!"=="" set FixWiFi=1
)
if "!reaply!"=="" (
 echo.       +++: Параметров Автоподключений к левым Wifi не найдено
) else if "!FixWiFi!"=="" (
 echo.       +++: Автоподключение к левым Wifi 
) else (
 %ch% {0e}   #######: %info1%{\n #}
 %ch% {0e}   #######: %info2%   Исправить^^^! {\n #}
 (echo.&echo.echo.
  echo.%%ch%%   {0b}%info1%{\n #}
  echo.%%ch%%   {0b}%info2% Исправить^^^!{#}:{\n #}
  echo.for /f "delims=" %%%%w in ^(' reg query !keysearch! /s /f "FeatureStates" ^^^^^| find "S-1" '^) do ^(
  echo. reg add "%%%%w" /v "FeatureStates" /t REG_DWORD /d 828 /f ^)
 )>>"%batfile%"
)
endlocal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




echo.&   set Info=Проверка Доступа в интернет службе защиты аудио - Windows Media DRM
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Определения вашего расположения для AppStore и Др., Геозона
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Возможности использования web камеры на Лок-скрине
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Фрейм Сервера Microsoft
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /t REG_DWORD /d "0" /f
if "%xOS%"=="x64" (
Call :CheckReg "--" reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /t REG_DWORD /d "0" /f
)
Call :CheckReg "--" reg add "HKLM\SYSTEM\CurrentControlSet\Services\FrameServer" /v "Start" /t REG_DWORD /d "4" /f


echo.&   set Info=Проверка рекламы Windows Update в модерн настройках
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "HideMCTLink" /t REG_DWORD /d "1" /f



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::   Параметры из Групповой Политики, для тех, кто ее не настраивает         ::::::::::
:::::   А тем кто настраивает, за одно будет отслеживаться файлом проверки      ::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&   set Info=Проверка SmartScreen
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка Отправки отчетов об ошибках
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Анализа и отправки данных PerfTrack через SQM
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка Средства диагностики MSDT для технической поддержки
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка Синхронизации
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d "2" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "EnableBackupForWin8Apps" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка участие в программе улучшения качества для IE
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка рекомендуемых сайтов IE
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка предостовления улучшеных вариантов поиска в IE
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка загрузки инструментов в режиме InPrivate в IE
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка отправления заголовока -не отслеживать- в IE
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка синхронизации RSS-каналов в фоновом режиме
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка запрета использование биометрии
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка Windows Hellow для бизнеса и Использование биометрии
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка проверки новостей по поддержке и программы Windows Mail
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка запуска Windows Messenger и ее программу улучшения
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "PreventRun" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d "2" /f


echo.&   set Info=Проверка  автоскачивание данных карт и незапршенный трафик
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка синхронизации приложений
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsSyncWithDevices" /t REG_DWORD /d "2" /f


echo.&   set Info=Проверка Отключения всех приложений из магазина и сам магазин
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d "1" /f
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f
if "%xOS%"=="x64" (
Call :CheckReg "--" reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f
)

echo.&   set Info=Проверка загрузки сведений по игре
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "DownloadGameInfo" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка обновления игр
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "GameUpdateOptions" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка отслеживания времени последнего сеанса игр
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "ListRecentlyPlayed" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка пометки данных для программы по улучшению Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "StudyId" /f


echo.&   set Info=Проверка Отключения возможностей облака Microsoft и советов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка идентификатора объявлений для профилей пльзователей
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Вэб публикации в списке задач для файлов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка доступа к магазину
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка обновления файлов помощника по поиску
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\SearchCompanion" /v "DisableContentFileUpdates" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка Записи игр GAME Bar, WIN+G
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f


echo.&   set Info=Проверка хранения сведений о зоне происхождения файлов
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".7z;.zip;.rar;.iso;.nfo;.txt;.inf;.ini;.xml;.pdf;.bat;.com;.cmd;.reg;.msi;.exe;.htm;.html;.gif;.png;.bmp;.jpg;.avi;.mpg;.mpeg;.mov;.mkv;.flv;.srt;.flac;.mp3;.m3u;.cue;.wav;.chm;.mdb;" /f


echo.&   set Info=Проверка автоматического исправления слов с ошибками
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffAutocorrectMisspelledWords" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка выделения слов с ошибками
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffHighlightMisspelledWords" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка прогнозирования текста при вводе
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffOfferTextPredictions" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка рейтинга справки
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d "1" /f


echo.&   set Info=Проверка программы улучшения справки
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoImplicitFeedback" /t REG_DWORD /d "1" /f



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::   Ниже идут Дополнительные параметры из Групповой Политики                       :::::
:::::   Не будут добавлены в настроенные ГП, но будут отслеживаться файлом проверки    :::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&   set Info=Отключить сбор данных фильтрации InPrivate
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableLogging" /t REG_DWORD /d "1" /f


echo.&   set Info=Отключить возможность отправки отчетов об ошибках
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "NoReportSiteProblems" /t REG_SZ /d "yes" /f


echo.&   set Info=Отключение активной справки
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoActiveHelp" /t REG_DWORD /d "1" /f


echo.&   set Info=Запретить выполнение программы -Звукозапись-
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\SoundRecorder" /v "Soundrec" /t REG_DWORD /d "1" /f


echo.&   set Info=Выключить календарь Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Windows" /v "TurnOffWinCal" /t REG_DWORD /d "1" /f


echo.&   set Info=Отключение веб-проверки AVS -телеметрия активации-
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f


echo.&   set Info=Не разрешать проекцию на этот компьютер
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Connect" /v "AllowProjectionToPC" /t REG_DWORD /d "0" /f


echo.&   set Info=Не разрешать работу цифрового ящика Windows Marketplace
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Digital Locker" /v "DoNotRunDigitalLocker" /t REG_DWORD /d "1" /f


echo.&   set Info=Запретить сбор и передачу данных поддержке Майкрософт
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "DisableQueryRemoteServer" /t REG_DWORD /d "0" /f


echo.&   set Info=Запретить Средства диагностики поддержки Майкрософт
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "DownloadToolsEnabled" /t REG_DWORD /d "0" /f


echo.&   set Info=Отключить кэширование эскизов в скрытых файлах thumbs.db
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableThumbsDBOnNetworkFolders" /t REG_DWORD /d "1" /f


echo.&   set Info=Отключить кэширование эскизов изображений
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThumbnailCache" /t REG_DWORD /d "1" /f


echo.&   set Info=Отключить все функции SpotLight на экране блокировки
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /t REG_DWORD /d "1" /f


echo.&   set Info=Отключить уведомления и обновления плиток в меню пуск
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Отключение синхронизации персональных настроек Windows,       ::
::  таких как пароли, настройки браузера, оформление и прочее,    ::
::  необходимых для аккаунта M$, кортаны и др. хлама,             ::
::  этих опций нету в Modern аплете настроек                      ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&   set Info=Проверка Синхронизации персональных настроек программ и Windows
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\DesktopTheme" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" /v "Enabled" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f



echo.&   set Info=Проверка правописания, выделения ошибок и прогнозирования
echo. ----------------------------------------------------------------------------------------------------------------------
echo.   %Info%
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /t REG_DWORD /d "0" /f
Call :CheckReg "--" reg add "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /t REG_DWORD /d "0" /f
Call :CheckReg "GP" reg add "HKLM\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /t REG_DWORD /d "1" /f
Call :CheckReg "GP" reg add "HKCU\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /t REG_DWORD /d "1" /f




if "%choice%"=="2" (
 echo.&echo.
 %ch% {0b}    --------------------------------------------------- {\n #}
 %ch% {0b}      - Завершена проверка только 2 части: Settings -   {\n #}
 %ch% {0b}    --------------------------------------------------- {\n #}
 echo.
 goto :AddPause
) else (
 echo.&echo.
 %ch% {0b}    ------------------------------------------------------- {\n #}
 %ch% {0b}      - Завершена проверка обеих частей: Spy и Settings -   {\n #}
 %ch% {0b}    ------------------------------------------------------- {\n #}
 echo.
 goto :AddPause
)



::     -----------------------------------------------------
::     -----------------------------------------------------
::     -----------------------------------------------------
::     ----      Ниже находятся сценарии управления     ----
::     ----     Не трогайте их, если не понимаете!!!   -----
::     -----------------------------------------------------
::     -----------------------------------------------------
::     -----------------------------------------------------



:: Сценарий проверки значений реестра, понимает и циферные и буквенные. 
:: + доп параметр, который надо выполнить вместе с правкой реестра, Добавлять его в конце вызова Call
:CheckReg
setlocal EnableDelayedExpansion
shift /5 & shift /6 & shift /7 & shift /8
set "RegInfo=%~1" & set "RegAction=%~3" & set "RegKey=%~4" & set "RegName=%~5" & set "RegType=%~6" & set "RegValue=%~7" & set "RegSpecValue=%~8"
if /i "%RegAction%" NEQ "delete" if /i "%RegAction%" NEQ "add" (%ch% {0c}   *******: Ошибка в: {#}"%RegName%" {\n #} & exit /b)
if not "%RegValue%"=="" ( echo.%RegValue%| findstr /r /c:"^[0-9]*$" >nul && set "A=/a" )

if /i "%RegAction%"=="delete" ( set "T=2" & if "%RegInfo%"=="TI" ( set ApplyKey=""%RegKey%"" /v ""%RegName%"" /f) else ( set ApplyKey="%RegKey%" /v "%RegName%" /f)
) else ( set "T=3" & if "%RegInfo%"=="TI" ( set ApplyKey=""%RegKey%"" /v ""%RegName%"" /t %RegType% /d ""%RegValue%"" /f) else ( set ApplyKey="%RegKey%" /v "%RegName%" /t %RegType% /d "%RegValue%" /f))

if /i "%RegAction%"=="delete" if not "%RegType%"=="" ( set "SpecParam=echo.%RegType%" )
if /i "%RegAction%"=="add" if not "%RegSpecValue%"=="" ( set "SpecParam=echo.%RegSpecValue%" )
for /f "tokens=%T%" %%I in (' 2^>nul reg query "%RegKey%" /v "%RegName%" ') do set %A% "FindValue=%%I"
if "%FindValue%"=="%RegValue%" (echo.       +++: "%RegName%"
) else (
 %ch% {0e}   #######: "%RegName%"   Исправить^^^!{\n #}
 
 if "%RegInfo%"=="GP" (
  (echo.&echo.echo.&echo.%%ch%%   {0b}Добавление настройки Групповой Политики в файл LGPO:{\n #}
   echo.%%ch%%    {0f}"%Info%" {0b}Настроить ГП^^^!{\n #}
   echo:Call :LGPO_FILE reg %RegAction% %ApplyKey%
  )>>"%batfile%"

 ) else if "%RegInfo%"=="TI" (
  (echo.&echo.echo.&echo.%%ch%%   {0b}Внесение параметра через TrustedInstaller:{\n #}
   echo.%%ch%%    {0f}"%Info%" {0b}Исправить^^^!{\n #}
   echo.echo.
   echo.for /f "tokens=3" %%%%I in ^(' 2^^^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\seclogon" /v "Start" '^) do set /a "FindValue=%%%%I"
   echo.if "%%FindValue%%"=="4" sc config seclogon start= demand^& net start seclogon
   echo.for /f "tokens=3" %%%%I in ^(' 2^^^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\trustedinstaller" /v "Start" '^) do set /a "FindValue=%%%%I"
   echo.if "%%FindValue%%"=="4" %%NirCMDc%% ElevateCMD RunAsSystem cmd "cmd /c sc config trustedinstaller start= demand"
   echo.tasklist /FO TABLE /NH /FI "ImageName EQ trustedinstaller.exe" 2^>nul ^| find /i "trustedinstaller.exe" ^>nul ^|^| ^(net start trustedinstaller^)
   echo.%%NirCMDc%% ElevateCMD RunAsSystem %%RunFromToken%% trustedinstaller.exe 1 "reg %RegAction% %ApplyKey%"
   echo.TIMEOUT /T 1 /NOBREAK ^>nul
  )>>"%batfile%"
 
 ) else (
  (echo.&echo.echo.&echo.%%ch%%   {0f}"%Info%" {0b}Исправить^^^!{\n #}
   %SpecParam%
   echo:reg %RegAction% %ApplyKey%
  )>>"%batfile%"
 )

)
exit /b


:: Сценарий проверки служб, выполняет только проверку на отключение! Остальные варианты пропустит.
:CheckService
setlocal EnableDelayedExpansion
set "ServiceName=%~1"
set "ServiceAction=%~2"
if /i not "%ServiceAction%"=="disabled" (exit /b)
for /f "tokens=4*" %%I in (' 2^>nul sc qc %ServiceName% ^| find "START_TYPE" ') do set "ServiceReply=%%I"
if "!ServiceReply!"=="" ( echo.        --: "%ServiceName%"	Не найдена. --
 ) else if "!ServiceReply!"=="DISABLED" ( echo.       +++: "%ServiceName%"
) else (%ch% {0e}   #######: "%ServiceName%"	Отключить^^^!{\n #}
 (echo.&echo.echo.&echo.%%ch%%   {0b}"%Info%"{\n #}
  echo.%%ch%%    Отключение: {0f}"%ServiceName%"{#}, команды:{\n #}
  echo.net stop %ServiceName%
  echo.sc config %ServiceName% start= %ServiceAction%
 )>>"%batfile%"
)
exit /b




:: Сценарий проверки задач, Может Выполнить проверку как на отключение , так и на включение.
:CheckTask
setlocal EnableDelayedExpansion
set "TaskName=%~1"
set "TaskAction=%~2"
if /i "%TaskAction%"=="/Disable" (set "TaskValue=Disabled" & set "ReplyInfo=Отключить")
if /i "%TaskAction%"=="/Enable" (set "TaskValue=Ready" & set "ReplyInfo=Включить")
if "%TaskAction%"=="" (exit /b)
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%TaskName%" ') do set "TaskReply=%%~I"
if not "!TaskReply!"=="" (
 if "!TaskReply!"=="!TaskValue!" (
  echo.       +++: "%TaskName%"
 ) else (
  %ch% {0e}   #######: "%TaskName%"   %ReplyInfo% задачу {\n #}
  (echo.&echo.echo.
   echo.%%ch%%   {0b}"%Info%"{\n #}
   echo.%%ch%%    %ReplyInfo%: {0f}"%TaskName%":{\n #}
   echo.schtasks /Change /TN "%TaskName%" %TaskAction%
  )>>"%batfile%"
 )
) else (echo.     -----: "%TaskName%" Не существует^^^!)
exit /b



:: Сценарий проверки задач, Может Выполнить проверку как на отключение , так и на включение.
:: Для задач, которые отключаются только с правами Системы
:CheckTaskInSys
setlocal EnableDelayedExpansion
set "TaskName=%~1"
set "TaskAction=%~2"
if /i "%TaskAction%"=="/Disable" (set "TaskValue=Disabled" & set "ReplyInfo=Отключить")
if /i "%TaskAction%"=="/Enable" (set "TaskValue=Ready" & set "ReplyInfo=Включить")
if "%TaskAction%"=="" (exit /b)
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%TaskName%" ') do set "TaskReply=%%~I"
if not "!TaskReply!"=="" (
 if "!TaskReply!"=="!TaskValue!" (
  echo.       +++: "%TaskName%"
 ) else (
  %ch% {0e}   #######: "%TaskName%"   %ReplyInfo% задачу^^^! {\n #}
  (echo.&echo.echo.
   echo.%%ch%%   {0b}"%Info%"{\n #}
   echo.%%ch%%    %ReplyInfo%: {0f}"%TaskName%":{\n #}
   echo.%%NirCMDc%% elevatecmd runassystem cmd /c schtasks /Change /TN "%TaskName%" %TaskAction%
   echo.TIMEOUT /T 2 ^>nul
  )>>"!batfile!"
 )
) else (echo.     -----: "%TaskName%" Не существует^^^!)
exit /b



::   Сценарий создания файла "_3__Fix.bat", удаляет существующий "_3__Fix.bat",
::   и копирования в него всего текста после команды, например: [_3__Fix.bat*20]
::   с ограничением на количество строк = 20
::   При подсчете, пустые строки не считаются!!!
:extract
setlocal EnableDelayedExpansion
set counter=0
set file=nul
for /f "usebackq tokens=*" %%A IN ("%~nx0") DO (
 set cur_s=%%A
 if !counter! GTR 0 (
  set /a counter=!counter!-1
  echo.%%A>>"!file!"
 ) else (
 if "!cur_s:~0,1!"=="[" (
  if "!cur_s:~-1!"=="]" (
   for /f "usebackq tokens=1,2* delims=*[]" %%B IN ('%%~A') DO (
    if not "%%C"=="" (
     set file=%%~B
     if exist "!file!" (erase "!file!")
     <nul set /p x=>"!file!"
     set counter=%%~C
    )
   )
  )
 )
 )
)
endlocal
goto :AddInfo


::   Сценарий добавления информации в "_3__Fix.bat" после начального текста,
::   который вставлен командой ":Extract".
:AddInfo
echo.
if exist %batfile% (
(echo.::
 echo.::
 echo.::
 echo.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 echo.::::     Ниже будут созданы строки для исправления.     ::::
 echo.::::               Можно удалить ненужные,              ::::
 echo.::::            которые не хотите исправлять            ::::
 echo.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 )>>%batfile%
 goto :LangVers
) else (
 echo.
 echo.        "%batfile%" не существует, произошла не предвиденная ошибка!
 echo.
 echo.   Для выхода нажмите любую клавишу.
 TIMEOUT /T -1 >nul & exit
)


::   Сценарий добавления в файл "_3__Fix.bat" в конце всех строк @pause,
::   И при наличии параметра Групповых Политик, т.е вызова "Call :LGPO_FILE", добавление вызова применения файла LGPO
::   Поиск добавленных строк осуществляется по количеству всех строк: 83 = 75 + добавленные 8 с описанием
::   Если не найдены добавленные строки, удаление файла "_3__Fix.bat"
::   По этому, если будете добавлять свои строки, делайте аналогично уже указанным параметрам!
:AddPause
setlocal EnableDelayedExpansion
echo.
if exist %batfile% (
 for /f "tokens=1,2" %%I in (%batfile%) do if /i "%%I %%J" EQU "Call :LGPO_FILE" set LineLGPO=1
 if defined LineLGPO ((echo.&echo.::Настроить Групповые Политики, созданным файлом LGPO&echo.Call :LGPO_FILE_APPLY)>>%batfile%)
 for /f %%I in (' type "%batfile%" ^| find /c /v "" ') do set AllLine=%%I
 if !AllLine! GTR 83 (
 (echo.
  echo.
  echo.:::::::::::::::::::: конец ::::::::::::::::::::
  echo.echo.
  echo.%%ch%%         {0a}Исправление выполнено {\n #}
  echo.echo.
  echo.%%ch%%         {0a}Перезагрузите компьютер^^^!^^^!^^^! {\n #}
  echo.echo.
  echo.@pause
  echo.exit
  )>>%batfile%
  echo.
  %ch% {0e}    -------------------------------------------------------------       {\n #}
  %ch% {0e}    ---  В {0b}%batfile%{0e} записаны строчки для исправления       --- {\n #}
  %ch% {0e}    ---                   Ознакомтесь с ним!                   ---      {\n #}
  %ch% {0e}    ---  Строки, которые не хотите исправлять, можно удалить  ---       {\n #}
  %ch% {0e}    ---  Затем запустите {0b}%batfile%{0e}, чтобы все исправить     --- {\n #}
  %ch% {0e}    -------------------------------------------------------------       {\n #}
  echo.
  echo.
  echo.        Для выхода нажмите любую клавишу.
  echo.
  TIMEOUT /T -1 >nul
  exit
 ) else (
  %ch% {0a}    ========================================= {\n #}
  %ch% {0a}        Исправлять нечего, все в порядке^^^!  {\n #}
  %ch% {0a}    ========================================= {\n #}
  del /f /q %batfile%
  echo.
  echo.        Для выхода нажмите любую клавишу.
  TIMEOUT /T -1 >nul & exit
 )
) else (
 echo.
 echo.        Произошла непредвиденная ошибка!
 echo.        Файл "%batfile%" не существует!
 echo.
 echo.        Для выхода нажмите любую клавишу.
 TIMEOUT /T -1 >nul & exit
)




::   Место, от куда будет скопирован текст в начало файла "_3__Fix.bat",
::   Так же эта часть для работы этого бат файла.
::   Название [_3__Fix.bat*74] указывает имя файла и количество строк для копирования,
::   При подсчете, пустые строки не считаются!!!
::   В данном случае копируется до строчки "Set "batfile=_3__Fix.bat"",
::   так как эта и следующие команды не должны попасть в файл "_3__Fix.bat".
[_3__Fix.bat*75]

::&cls&:: Строка для скрытия ошибки, если батник в формате UTF-8 с меткой BOM
::
goto :First
::
:: Сценарий наполнения LGPO файла параметрами, которые указаны через вызов "Call :LGPO_FILE"
:: Происходит переделка обычной команды для reg.exe по настройке параметра в реестре в нужный формат для LGPO.exe
:: Использовать параметры надо только из ГП, иначе через стандартный сброс ГП параметр не убрать, только через LGPO или реестр.
:: Параметры из ГП всегда имеют в имени раздела ...\Policies\..., 
:: но могут быть добавлены дополнительными шаблонами ГП или через LGPO в другие разделы, но такие параметры сбросом ГП не убрать!
:LGPO_FILE
echo.
setlocal
if /i "%~2" NEQ "delete" if /i "%~2" NEQ "add" (
 %ch%     {0c}Пропуск добавления параметра в LGPO файл, неправильная команда{#}:{\n #} & %ch%    %1 {0e}%2{#} %3 {\n #} & exit /b)
if /i "%~2" EQU "delete" if "%~7" NEQ "" (
 %ch%     {0c}Пропуск добавления параметра в LGPO файл, ошибка в параметре{#}:{\n #} & echo.   %1 %2 %3 & %ch%        %4 %5 %6 {0e}%7 %8 %9 {\n #}& exit /b)
if "%GPEditorNO%" EQU "1" ( %ch%     {0e}Нет Редактора Групповых Политик {08}^(Параметры применены в реестр, без LGPO^){\n #}& %ch% {0f}%* {\n #}& %* & exit /b)
set "RegType=%~7:"
set "RegType=%RegType:REG=%"
set "RegType=%RegType:_=%"
set "RegType=%RegType:PAND=%"
if "%~3" NEQ "" for /f "tokens=1* delims=\" %%I in ("%~3") do ( set "RegKey=%%J"
 if /i "%%I" EQU "HKEY_LOCAL_MACHINE" (set Config=Computer) else if /i "%%I" EQU "HKLM" (set Config=Computer
 ) else if /i "%%I" EQU "HKEY_CURRENT_USER" (set Config=User) else if /i "%%I" EQU "HKCU" (set Config=User
 ) else (%ch%     {0c}Пропуск добавления параметра в LGPO файл, неверный раздел{#}: {0e}"%%I"{\n #} & %ch%    %1 %2 %3 {\n #} & exit /b))
if "%~9" NEQ "" set "Action=%RegType%%~9"
if /i "%~6" EQU "/d" set "Action=SZ:%~7"
if /i "%~2" EQU "delete" set "Action=DELETE"
if "%~5" EQU "" ( set "Action=DELETEALLVALUES" & set "ValueName=*" ) else ( set "ValueName=%~5" )
if /i "%~2" EQU "add" if /i "%~4" EQU "/f" set "Action=CREATEKEY" & set "ValueName=*" 
(echo.%Config%& echo.%RegKey%& echo.%ValueName%& echo.%Action%& echo.)>>"%LGPOtemp%"
%ch%      {0a}Добавлен параметр в LGPO файл {08}(для настройки ГП){#}:{\n #} & echo.    %1 %2 %3 & echo.        %4 %5 %6 %7 %8 %9 & echo.
exit /b
::
:: Сценарий настройки Групповой Политики, с помощью официальной утилиты LGPO.exe от MS
:: Здесь Используется файл с параметрами, который наполнен через вызов "Call :LGPO_FILE"
:LGPO_FILE_APPLY
echo.
if "%GPEditorNO%" EQU "1" ( %ch%     {0e}Нет Редактора Групповых Политик {08}^(Все Параметры были применены в реестр, без LGPO^){\n #}& exit /b )
if not exist "%LGPOtemp%" %ch%     {0e}LGPO файл не найден {08}(пропуск настройки ГП){\n #}& exit /b
%ch%      {0b}Применение параметров из LGPO файла {08}(настройка ГП) {\n #}
%LGPO% /t "%LGPOtemp%" /q
if "%Errorlevel%" NEQ "0" ( %ch%     {0c}Ошибка применения файла LGPO^^^!{\n #}
 %ch%     {0e}Проблемный {0f}"LGPO_File_error_(%TIME:~,2%-%TIME:~3,2%-%TIME:~6,2%).txt"{0e} скопирован в папку с батником {\n #}
 echo.F| xcopy /Y /Q /R "%LGPOtemp%" "LGPO_File_error_(%TIME:~,2%-%TIME:~3,2%-%TIME:~6,2%).txt" >nul & echo.)
echo.     Удаление временного LGPO файла & echo.
if exist "%LGPOtemp%" del /f /q "%LGPOtemp%"
exit /b
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Сценарий установки основных переменных и проверки наличия нужных файлов в папке с этим bat файлом.
:First
@echo off
chcp 65001 >nul
cd /d "%~dp0"
set xOS=x64& (If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86)
set ch="%~dp0Files\Tools\cecho.exe"
set NirCMDc="%~dp0Files\Tools\nircmdc_%xOS%.exe"
set RunFromToken="%~dp0Files\Tools\RunFromToken_%xOS%.exe"
set LGPO="%~dp0Files\Tools\LGPO.exe"
set "LGPOtemp=%temp%\LGPO-file.txt"
if exist "%LGPOtemp%" del /f /q "%LGPOtemp%"
if not exist "%WinDir%\System32\gpedit.msc" set "GPEditorNO=1"
if not exist %ch% ( echo.&echo.        Нет файла "cecho.exe" в папке "\Files\Tools"
		    echo.&echo.        Отмена, выход & TIMEOUT /T 5 >nul & exit )
if not exist %NirCMDc% ( echo.&echo.        Нет файла "nircmdc_%xOS%.exe" в папке "\Files\Tools"
			 echo.&echo.        Отмена, выход & TIMEOUT /T 5 >nul & exit  )
::
:: Сценарий вывода запроса UAC на получение админских прав.
reg query "HKU\S-1-5-19\Environment" >nul 2>&1 & cls
if "%Errorlevel%" NEQ "0" ( cmd /u /c echo. CreateObject^("Shell.Application"^).ShellExecute "%~f0", "", "", "runas", 1 > "%Temp%\GetAdmin.vbs"
"%Temp%\GetAdmin.vbs" & del "%Temp%\GetAdmin.vbs" & cls & exit )
::
::::
set "batfile=_3__Fix.bat"
if "%xOS%"=="x64" (
 if not exist "%SystemRoot%\System32\Wow64.dll" (
  echo.&%ch%        {0e}"Ошибка, Батник запущен из-под 32-bit оболочки!"{\n #} & echo.
  %ch%        {4f} Отмена {#} выход {\n #} & TIMEOUT /T 8 >nul & exit )
)
goto :Extract
