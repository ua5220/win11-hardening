::&cls&::   Сделали: westlife и LeX333666 -- ru-board.com --
:::::::::   http://forum.ru-board.com/topic.cgi?forum=62&topic=30041&start=480#21
:::::::::   Ссылка на закачку новая, старая заблокирована по ошибке Яндекс https://yadi.sk/d/CMqvcp1F3QiaWL

@Echo off
title AutoSettings LTSB
:: Вызов сценария начала
goto :First


::   Отображение языка системы, батник должен работать с любым языком.
:LangVers
for /f tokens^=2-8^ delims^=^={}^" %%A in (' wmic os get MUILanguages /Value 2^>nul ') do (
set "OSLang=%%A" & if "%%B" EQU "," set "OSLang=%%A%%B %%C" & if "%%D" EQU "," set "OSLang=%%A%%B %%C%%D %%E" & if "%%F" EQU "," set "OSLang=%%A%%B %%C%%D %%E%%F %%G")


::   Сценарий главного Меню для выбора действий
:Menu
setlocal
cls
echo.
%ch% {08}  ╔══════════════════════════════════════════════════════════════════════╗                     {\n #}
%ch% {08}  ║     {07}Настройка {08}редакции {0f}Windows 10 Enterprise {0a}LTSB RS1 10.0.14393     {08}║ {\n #}
%ch% {08}  ╚══════════════════════════════════════════════════════════════════════╝                     {\n #}
echo.
%ch%         Ваша Windows:{0a} %xOS% {#}^|{0a} %OSLang% {#}^| %OSVersion% %ProductName%{00}.{\n #}
echo.
if  "%OSVers%"=="10.0.14393" if not "%ProductNameNo%"=="" (
%ch%         {0e}Внимание{#} Ваша редакция не LTSB RS1: %ProductNameNo% {\n #}
%ch%                                             {0e}Отключатся Модерн и другие приложения от Microsoft ^!^!^! {\n #})
echo.        Варианты для выбора:
echo.
%ch% {0b}    [0]{#} = {0e}Quick Settings {08}(Меню применения всех настроек батника){\n #}
echo.
%ch% {0b}    [1]{#} = {0e}Spy {08}(Только отключение слежки, сбора и AppStore){\n #}
%ch% {0b}    [2]{#} = {0e}Settings {08}(Только дополнительные настройки Windows){\n #}
%ch% {0b}    [3]{#} = {0e}Выполнить обе {08}(Spy и Settings){\n #}
echo.
%ch% {0b}    [4]{#} = {0e}SelfMenu {08}(Меню для личных настроек){\n #}
echo.
%ch% {0b}    [5]{#} = {0e}Обновления {08}(Меню управление центром обновления и драйверов){\n #}
%ch% {0b}    [6]{#} = {0e}Групповые политики {08}(Меню применения/сброса политик){\n #}
echo.
%ch% {0b}    [7]{#} = {0e}Обслуживание {08}(Меню управления и выполнения Обслуживания системы){\n #}
echo.
%ch% {0c}    [999]{#} = {0c}Сброс {08}(Меню восстановления всех настроек Spy и Settings){\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {0e}Выйти {\n #}
%ch%                                                    {08} ^| Версия 3.16{\n #}
set /p choice=--- Ваш выбор: 
if not defined choice ( echo. & %ch%         {0a}Перезагрузите компьютер,{\n #}
			%ch%         {0a}если применяли настройки!!!{\n #} & echo.
			echo.        Для выхода нажмите любую клавишу.
			TIMEOUT /T -1 >nul & exit )
if "%choice%"=="0" ( endlocal & goto :QuickSettings )
if "%choice%"=="1" ( cls & goto :Spy )
if "%choice%"=="2" ( cls & goto :Settings )
if "%choice%"=="3" ( cls & goto :Spy)
if "%choice%"=="4" ( endlocal & goto :SelfStat )
if "%choice%"=="5" ( endlocal & goto :UpdateMenu )
if "%choice%"=="6" ( endlocal & goto :MenuGP )
if "%choice%"=="7" ( endlocal & goto :MenuMaintance )
if "%choice%"=="999" ( endlocal & goto :MenuReturn
 ) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :Menu )




::   Сценарий Меню применения всех настроек батника + свой батник с настройками
:QuickSettings
cd /d "%~dp0"
set "QuickPresetsFile=Files\QuickPresets.txt"
set "QuickPresetsFileMy=Files\QuickPresets_My.txt"

if exist "%PresetLGPO%"   Call :BOMRemove "%PresetLGPO%"   "%PresetLGPOTemp%"
if exist "%PresetLGPOMy%" Call :BOMRemove "%PresetLGPOMy%" "%PresetLGPOTemp%"
if exist "%LGPOtemp%" del /f /q "%LGPOtemp%"

if exist "%QuickPresetsFileMy%" (
 set "QuickPresets={0a}Найдены{#}, будут использованы ваши {08}^|{#} {0a}%QuickPresetsFileMy%{#}"
 set "QuickPresetsFile=%QuickPresetsFileMy%"
 ) else if exist "%QuickPresetsFile%" ( set "QuickPresets={0a}Найдены{#}, будет использован {08}^|{#} {0e}%QuickPresetsFile%{#}"
) else ( set "QuickPresets={0e}Не найдены {08}(Будут пропущены){#}" )

setlocal EnableDelayedExpansion
cls
echo.
%ch% {08}    ================================================================================================================ {\n #}
%ch%         {0e}Quick Settings {#}Применение всех настроек батника, заданных в файле {0b}\Files\QuickPresets.txt {\n #}
%ch%         Если будет найден ваш файл {0b}\Files\QuickPresets{0e}_My{0b}.txt{#}, то использован будет он {\n #}
echo.        Тут не настроить/сбросить: Папки Temp, Папки Пользователя, Языковые возможности и Блокировку .exe файлов
%ch%         Все батники: {0b}\Files\MySettings{0e}***{0b}.bat{#} подхватятся, при наличии {08}(Вместо звезд можно любое название) {\n #}
%ch% {08}    ================================================================================================================ {\n #}
echo.
echo.          В данный момент:
%ch%             {0f}Предустановки{#}: %QuickPresets% {\n #}
%ch%            Свои {0f}Настройки{#}: {\n #}
set /a N=0
for /f "tokens=1* delims=" %%I in (' 2^>nul dir /b /a:-d "Files\MySettings*.bat" ^| findstr /i "[.]bat\>" ') do (
 for /f "tokens=1* delims=" %%J in (' type "Files\%%I" ^| findstr /i /r /c:".*" ') do set "ExitBat=%%J"
 if /i "!ExitBat!"=="exit /b 0000" ( set /a "N+=1" & %ch%                  Батник !N!: {0a}%%I {\n #}
  set "ExitBat=Yes")
)
if not "!ExitBat!"=="Yes" %ch%                   Батники: {0e}Не найдены {\n #}
echo.
echo.        Варианты действий:
echo.
%ch% {0b}    [1]{#} = Применить все настройки батника {08}(Предустановки + Свои Настройки){\n #}
%ch% {0b}    [2]{#} = Применить только {0f}Предустановки  {08}(QuickPresets.txt){\n #}
%ch% {0b}    [3]{#} = Применить только {0f}Свои Настройки {08}(Файлы MySettings*.bat){\n #}
echo.
%ch% {0c}    [999]{#} = {0c}Сброс{#} всех настроек батника из всех меню по дефолтным предустановкам {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set "ExitBat="
set "option="
if "%RunQuickSettings%" EQU "1" set "option=1" & goto :QuickApplySettings
set /p option=*    Ваш выбор: 
if not defined option ( echo.&%ch%     {0e} - Возврат в главное меню - {\n #}
			endlocal & TIMEOUT /T 3 >nul & goto :Menu )
if "%option%"=="1"   ( goto :QuickApplySettings )
if "%option%"=="2"   ( goto :QuickApplySettings )
if "%option%"=="3"   ( goto :QuickApplyMyBat )
if "%option%"=="999" ( goto :QuickApplyDefault
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :QuickSettings )

:QuickApplySettings
set "ExitQuick="
echo.
if not exist "%QuickPresetsFile%" (%ch%      Предустановки {0e}Не найдены {\n #})
for /f "tokens=2,3,4,5 delims==" %%I in (' 2^>nul type "%QuickPresetsFile%" ^| find "Quick-Apply-Settings" ') do (
 if "%%~I"=="1" (
  echo.&%ch%      {0e}=== %%~K === {\n #}
  Call %%~J "QuickApply" "%%~L"
  set "ExitQuick=Yes"
 )
)
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
if "!ExitQuick!"=="Yes" if exist "%LGPOtemp%" Call :LGPO_FILE_APPLY
if "%option%"=="1" goto :QuickApplyMyBat
echo.
if "!ExitQuick!"=="Yes" %ch%          {0a}Перезагрузите компьютер^^^!{\n #}
TIMEOUT /T -1 & endlocal & goto :QuickSettings

:QuickApplyMyBat
set "ExitBat="
echo.
set /a N=0
for /f "tokens=1* delims=" %%I in (' 2^>nul dir /b /a:-d "Files\MySettings*.bat" ^| findstr /i "[.]bat\>" ') do (
 for /f "tokens=1* delims=" %%J in (' type "Files\%%I" ^| findstr /i /r /c:".*" ') do set "ExitBat=%%J"
 if /i "!ExitBat!"=="exit /b 0000" (
  echo.& set /a "N+=1" & %ch%      {0e}=== Выполнение батника !N!: "Files\%%I" === {\n #} &echo.
  Call "Files\%%I"
  set "ExitBat=Yes"
 )
)
if "!ExitBat!"=="" %ch%      Батники: {0e}Не найдены {\n #} & echo.
if "!ExitBat!"=="Yes" ( echo.&%ch%          {0a}Перезагрузите компьютер^^^!{\n #}
 ) else if "!ExitQuick!"=="Yes" ( echo.&%ch%          {0a}Перезагрузите компьютер^^^!{\n #}
)
if "%RunQuickSettings%" EQU "1" if "%QuickExit%" EQU ""  echo.&%ch%          {0d}Автозапуск выполнен{#}, для выхода нажмите любую клавишу ...{\n #}& TIMEOUT /T -1 >nul & exit
if "%RunQuickSettings%" EQU "1" if "%QuickExit%" EQU "1" echo.&%ch%          {0d}Автозапуск выполнен{#}, выход через 4 сек.{\n #}& TIMEOUT /T 4 >nul & exit
TIMEOUT /T -1 & endlocal & goto :QuickSettings

:QuickApplyDefault
echo.
if not exist "%QuickPresetsFile%" (%ch%      Предустановки {0e}Не найдены {\n #} & echo.)
set "ExitQuick="
echo.
for /f "tokens=2,3,4,5 delims==" %%I in (' 2^>nul type "%QuickPresetsFile%" ^| find "Quick-Apply-Default" ') do (
 if "%%~I"=="1" (
  set "Ech=%ch%" & set "Cal=Call"
  if /i "%%~J" EQU ":ResetGP" set "Ech=rem" & set "Cal=rem" & set "GPClear=1"
  echo.
  !Ech!      {0e}=== %%~K === {\n #}
  !Cal! %%~J "QuickApply" "%%~L"
  set "ExitQuick=Yes"
 )
)
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
if "!ExitQuick!"=="Yes" if exist "%LGPOtemp%" Call :LGPO_FILE_APPLY
:: Если было указано сбросить ГП в пресете быстрых настроек, выполнение этого в самом конце, после всех операций
if "!GPClear!" EQU "1" TIMEOUT /T 2 >nul & echo. & %ch%      {0e}=== Сброс всех настроек ГП === {\n #}
if "!GPClear!" EQU "1" Call :ResetGP QuickApply
echo.
if "!ExitQuick!"=="Yes" %ch%          {0a}Перезагрузите компьютер^^^!{\n #}
TIMEOUT /T -1 & endlocal & goto :QuickSettings
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




::     ------------------------------------------------------------------
::     ----      Ниже начинается управлением обновлением системы     ----
::     ------------------------------------------------------------------

::   Сценарий Меню управлением обновлением системы
:UpdateMenu
cd /d "%~dp0"
endlocal & setlocal EnableDelayedExpansion
set TQ=SCHTASKS /QUERY /FO CSV /NH /TN
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\WindowsUpdate\Scheduled Start" 2^>nul ') do set "ReplyUpdTask1=%%~I"
if not "!ReplyUpdTask1!"=="" (
 if "!ReplyUpdTask1!"=="Disabled" ( set "UpdTask1={0e}Отключена{#}   " ) else ( set "UpdTask1={0A}Включена{#}    " )
) else ( set "UpdTask1={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\WindowsUpdate\sih" 2^>nul ') do set "ReplyUpdTask2=%%~I"
if not "!ReplyUpdTask2!"=="" (
 if "!ReplyUpdTask2!"=="Disabled" ( set "UpdTask2={0e}Отключена{#}   " ) else ( set "UpdTask2={0A}Включена{#}    " )
) else ( set "UpdTask2={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\WindowsUpdate\sihboot" 2^>nul ') do set "ReplyUpdTask3=%%~I"
if not "!ReplyUpdTask3!"=="" (
 if "!ReplyUpdTask3!"=="Disabled" ( set "UpdTask3={0e}Отключена{#}   " ) else ( set "UpdTask3={0A}Включена{#}    " )
) else ( set "UpdTask3={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\Refresh Settings" 2^>nul ') do set "ReplyUpdTask4=%%~I"
if not "!ReplyUpdTask4!"=="" (
 if "!ReplyUpdTask4!"=="Disabled" ( set "UpdTask4={0e}Отключена{#}   " ) else ( set "UpdTask4={0A}Включена{#}    " )
) else ( set "UpdTask4={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" 2^>nul ') do set "ReplyUpdTask5=%%~I"
if not "!ReplyUpdTask5!"=="" (
 if "!ReplyUpdTask5!"=="Disabled" ( set "UpdTask5={0e}Отключена{#}   " ) else ( set "UpdTask5={0A}Включена{#}    " )
) else ( set "UpdTask5={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\MusUx_UpdateInterval" 2^>nul ') do set "ReplyUpdTask6=%%~I"
if not "!ReplyUpdTask6!"=="" (
 if "!ReplyUpdTask6!"=="Disabled" ( set "UpdTask6={0e}Отключена{#}   " ) else ( set "UpdTask6={0A}Включена{#}    " )
) else ( set "UpdTask6={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" 2^>nul ') do set "ReplyUpdTask7=%%~I"
if not "!ReplyUpdTask7!"=="" (
 if "!ReplyUpdTask7!"=="Disabled" ( set "UpdTask7={0e}Отключена{#}   " ) else ( set "UpdTask7={0A}Включена{#}    " )
) else ( set "UpdTask7={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" 2^>nul ') do set "ReplyUpdTask8=%%~I"
if not "!ReplyUpdTask8!"=="" (
 if "!ReplyUpdTask8!"=="Disabled" ( set "UpdTask8={0e}Отключена{#}   " ) else ( set "UpdTask8={0A}Включена{#}    " )
) else ( set "UpdTask8={9f} Не создана {#}" )
for /f "delims=, tokens=3" %%I in (' %TQ% "Microsoft\Windows\UpdateOrchestrator\Schedule Retry Scan" 2^>nul ') do set "ReplyUpdTask9=%%~I"
if not "!ReplyUpdTask9!"=="" (
 if "!ReplyUpdTask9!"=="Disabled" ( set "UpdTask9={0e}Отключена{#}   " ) else ( set "UpdTask9={0A}Включена{#}    " )
) else ( set "UpdTask9={9f} Не создана {#}" )
set RegUpdServ1="HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start"
reg query %RegUpdServ1% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %RegUpdServ1% 2^>nul ') do set /a "ValueUpdServ1=%%I"
 if "!ValueUpdServ1!"=="4" ( set "UpdServ1={0e}Отключена{#}" ) else ( set "UpdServ1={0A}Включена {#}" )
) else ( set "UpdServ1={4f} Нету {#}" )
set RegUpdServ2="HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v "Start"
reg query %RegUpdServ2% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %RegUpdServ2% 2^>nul ') do set /a "ValueUpdServ2=%%I"
 if "!ValueUpdServ2!"=="4" ( set "UpdServ2={0e}Отключена{#}" ) else ( set "UpdServ2={0A}Включена{#}" )
) else ( set "UpdServ2={4f} Нету {#}" )
set RegUpdServ3="HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start"
reg query %RegUpdServ3% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %RegUpdServ3% 2^>nul ') do set /a "ValueUpdServ3=%%I"
 if "!ValueUpdServ3!"=="4" ( set "UpdServ3={0e}Отключена{#}" ) else ( set "UpdServ3={0A}Включена {#}" )
) else ( set "UpdServ3={4f} Нету {#}" )
set RegDelivery="HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode"
for /f "tokens=3" %%I in (' reg query %RegDelivery% 2^>nul ') do set /a "ValueRegDelivery=%%I"
if "%ValueRegDelivery%"=="100" ( set "ReplyRegDelivery={0e}Отключен{#}" ) else ( set "ReplyRegDelivery={0A}Включен{#}" )
set RegUpd1="HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate"
set RegUpd2="HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions"
for /f "tokens=3" %%I in (' reg query %RegUpd2% 2^>nul ') do set /a "ValueAUOptions=%%I"
for /f "tokens=3" %%I in (' reg query %RegUpd1% 2^>nul ') do set /a "ValueNoAutoUpdate=%%I"
if "!ValueAUOptions!"=="2" ( set "UpdOptions={0A}Уведомление о наличии{#}" )
if "!ValueAUOptions!"=="3" ( set "UpdOptions={0A}Загрузка и Уведомление об установке{#}" )
if "!ValueAUOptions!"=="4" ( set "UpdOptions={0A}Автозагрузка и установка{#}" )
if "!ValueAUOptions!"=="5" ( set "UpdOptions={0A}Управляет администратор{#}" )
if "!ValueNoAutoUpdate!"=="1" ( set "UpdOptions={0e}Отключены{#}" )
if "!ValueAUOptions!"=="" (
 if "!ValueNoAutoUpdate!"=="" ( set "UpdOptions={0A}По умолчанию{#}" )
)
:::::   Проверка параметров задачи "Reboot" (RebootIn) :::::::::::::::::::::::::::
set "taskpathReboot=\Microsoft\Windows\UpdateOrchestrator\Reboot"
set regsearchReboot="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "%taskpathReboot%" /e
for /f "usebackq delims=/ tokens=1" %%i in (' %regsearchReboot% ') do set "regpathReboot=%%i"
for /f "delims={} tokens=2" %%i in (' reg query  %regsearchReboot% ') do set "replyReboot1=%%i"
set dacllistReboot=%SetACL% -on "%regpathReboot:~2,-2%\{%replyReboot1%}" -ot reg -actn list -lst "f:csv;w:d;i:y;s:y;oo:n"
>nul 2>&1 ( %dacllistReboot% | find "S-1-5-18,read"
 if errorlevel 1 ( set "replyReboot2={0c}Не заблокирована^^^^^!{#}" ) else ( set "replyReboot2={0a}Заблокирована{#}" )
)
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN "%taskpathReboot%" ') do set "replyReboot3=%%~i"
if not "!replyReboot3!"=="" (
	if "!replyReboot3!"=="Disabled" ( set "replyReboot4={0a}Отключена{#}" ) else ( set "replyReboot4={0c}Включена^^^^^!{#}" )
) else ( set "replyReboot4={0e}Не существует^^^^^!{#}" )
cls
echo.
%ch% {08}    ========================================================================================== {\n #}
%ch%         Управление {0f}Центром Обновлений {08}(Windows Update) {\n #}
%ch%         Второй пункт меню действует только на {0a}авто{#}обновление системы, так как {\n #}
%ch%         {0e}эти параметры не влияют, при нажатии вами кнопки "Проверка наличия обновлений" ^^^!^^^!^^^!{\n #}
%ch% {08}    ========================================================================================== {\n #}
echo.
echo.          В данный момент:
%ch%                 Служба ЦО: %UpdServ1% {#}      Служба BITS: %UpdServ2%    Обновления: %UpdOptions%{00}.{\n #}
%ch%           Служба доставки: %UpdServ3% {#}   Режим доставки: %ReplyRegDelivery%{00}.{\n #}
echo.                   Задачи:
%ch%           Scheduled Start: %UpdTask1%   sih: %UpdTask2%  sihboot: %UpdTask3%  Refresh Set: %UpdTask4%{00}.{\n #}
%ch%             Schedule Scan: %UpdTask5% MusUx: %UpdTask6%     USO1: %UpdTask7%         USO2: %UpdTask8%{00}.{\n #}
%ch%       Schedule Retry Scan: %UpdTask9% {00}.{\n #}
echo.
echo.        Варианты действий:
echo.
%ch% {0b}    [1]{#} = Полное отключение обновлений{\n #}
%ch% {0b}    [2]{#} = Проверять и сообщать о наличии обновлений{\n #}
%ch% {0e}    [3]{#} = Восстановить все {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}    [4]{#} = Очистка кэша обновлений {08}(при проблемах обновления) {\n #}
echo.
%ch% {0b}    [5]{#} = Меню Управления обновлением {0e}Драйверов {\n #}
%ch% {0b}    [6]{#} = Меню Управления задачей {0e}Reboot{#}: %replyReboot4% и %replyReboot2% {00}.{\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в главное меню - {\n #}
			endlocal & TIMEOUT /T 3 >nul & goto :Menu )
if "%input%"=="1" ( goto :UpdateOFF )
if "%input%"=="2" ( goto :UpdateCheck )
if "%input%"=="3" ( goto :UpdateDefault )
if "%input%"=="4" ( goto :UpdateClear )
if "%input%"=="5" ( goto :DrMenu )
if "%input%"=="6" ( goto :RebootIn
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :UpdateMenu )

:UpdateOFF
echo.
%ch% {0b} --- Отключение и настройка служб Центра обновлений --- {\n #}
net stop bits
net stop wuauserv
sc config bits start= disabled
sc config wuauserv start= disabled
:: отключение счетчика производительности для службы BITS
LODCTR /D:BITS
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows (все параметры не задано)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f
echo.
%ch% {0b} --- Отключение автоматического обновления --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Настройка автоматического обновления" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f
echo.
%ch% {0b} --- Отключение задач для автоматического обновления --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\MusUx_UpdateInterval" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Refresh Settings" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Retry Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Maintenance Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Policy Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Resume On Boot" /Disable
echo.
%ch% {0b} --- Отключение службы оптимизации доставки обновлений "DoSvc" (Торрент клиент) --- {\n #}
net stop DoSvc
sc config DoSvc start= disabled
:: Комп\Адм. Шабл\Компоненты Windows\Оптимизация доставки "Режим скачивания" (включен, обход)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownLoadMode" /t REG_DWORD /d 100 /f
echo.
%ch% {0b} --- Получать обновления только от Microsoft --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownLoadMode" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownLoadMode" /t REG_DWORD /d 0 /f
echo.
%ch% {0b} --- Запретить доступ к центру обновления Microsoft --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Не подключаться к расположениям Центра обновления Windows в Интернете" (включен)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Запретить доступ для использования любых средств Центра обновления Windows" (включен)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
%ch%      - Центр обновлений {2f} Отключен полностью {#} - {00}.{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UpdateCheck
echo.
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows (все параметры не задано)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f
echo.
%ch% {0b} --- Отключение Автоматического обновления Windows (включение уведомлений о загрузке и установке) --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Настройка автоматического обновления" (включение уведомлений о загрузке и установке)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
echo.
%ch% {0b} --- Запретить автоустановку обновлений --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Разрешить немедленную установку автоматических обновлений" (отключен)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /t REG_DWORD /d 0 /f
echo.
%ch% {0b} --- Не выполнять автоперезагрузку после установки обновлений --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Не выполнять автоматическую перезагрузку при автоматической установке обновлений, если в системе работают пользователи" (включен)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f
echo.
%ch% {0b} --- Получать обновления только от Microsoft --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownLoadMode" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownLoadMode" /t REG_DWORD /d 0 /f
echo.
%ch% {0b} --- Разрешить доступ к центру обновления Microsoft --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Не подключаться к расположениям Центра обновления Windows в Интернете" (удаление, не задан)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Запретить доступ для использования любых средств Центра обновления Windows" (удаление, не задан)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /f
echo.
%ch% {0b} --- Отключение службы оптимизации доставки обновлений "DoSvc" (Торрент клиент) --- {\n #}
net stop DoSvc
sc config DoSvc start= disabled
:: Комп\Адм. Шабл\Компоненты Windows\Оптимизация доставки "Режим скачивания" (включен, обход)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownLoadMode" /t REG_DWORD /d 100 /f
echo.
%ch% {0b} --- Настройка задач Центра обновлений --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /Enable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Enable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\MusUx_UpdateInterval" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Refresh Settings" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Retry Scan" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Maintenance Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Policy Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Resume On Boot" /Disable
echo.
%ch% {0b} --- Перезапуск и настройка служб Центра обновлений --- {\n #}
net stop bits
net stop wuauserv
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
sc config bits start= delayed-auto
sc config wuauserv start= demand
net start bits
net start wuauserv
LODCTR /E:BITS
echo.
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
%ch%      - Центр обновлений настроен на {2f} Проверку и сообщение о наличие {#} - {00}.{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UpdateDefault
echo.
%ch% {0b} --- Включение всех параметров по умолчанию --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /Enable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Enable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\MusUx_UpdateInterval" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Refresh Settings" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Retry Scan" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Enable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Maintenance Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Policy Install" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Resume On Boot" /Disable
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows (удалены все параметры)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f
:: Комп\Адм. Шабл\Компоненты Windows\Центр обновления Windows "Не подключаться к расположениям Центра обновления Windows в Интернете" (удаление, не задан)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Запретить доступ для использования любых средств Центра обновления Windows" (удаление, не задан)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /f
echo.
%ch% {0b} --- Включение оптимизации доставки обновлений (Торрент клиент) --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownLoadMode" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Оптимизация доставки (всех параметры удалить, не задано все)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f
sc config DoSvc start= auto
net start DoSvc
echo.
%ch% {0b} --- Включение и настройка служб Центра обновлений --- {\n #}
net stop bits
net stop wuauserv
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
sc config bits start= delayed-auto
sc config wuauserv start= demand
net start bits
net start wuauserv
LODCTR /E:BITS
echo.
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
%ch%      - Параметры Центра обновлений {2f} Восстановлены {#} - {00}.{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UpdateClear
echo.
%ch% {0b} --- Перезапуск служб и очистка Кэша Центра обновлений --- {\n #}
net stop bits
net stop wuauserv
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
net start bits
net start wuauserv
echo.
%ch%      - Кэш Центра обновлений {2f} Очищен {#} - {00}.{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:RebootIn
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::                                                                                                 :::::
:::::   Задача в UpdateOrchestrator "Reboot" используется для вывода компа из сна, или гибернации     :::::
:::::   для включения по таймеру (обычно ночью) и выполнения установки обновлений и                   :::::
:::::   перезагрузки системы. Задачу создали, так как ввели быструю загрузку, при которой             :::::
:::::   выключения не производится, а каждый раз комп погружается в гибернацию. А системе нужны       :::::
:::::   перезагрузки либо полное выключение, для возможности обновления важных компонентов.           :::::
:::::                                                                                                 :::::
:::::   Эта задача обновляется, во время установки обновлений. И независимо от того,                  :::::
:::::   перезагружали вы комп после этого или нет, она будет включать комп по ночам                   :::::
:::::   для установки обновлений и др.                                                                :::::
:::::   Если вы хотите и используете "быструю загрузку", но перезагрузку хотите делать в ручную,      :::::
:::::   и так же не хотите, что бы комп самовольничал, отрубайте и блокируйте ее включение.           :::::
:::::   Если отрубите, то в окне отображения установки обновления больше не будут выводится варианты  :::::
:::::   действий после обновления, только кнопка перезагрузиться.                                     :::::
:::::                                                              ::::::::::::::::::::::::::::::::::::::::
cls
echo.
%ch% {08}     ============================================================ {\n #}
%ch%          Настройка задачи {0e}"Reboot"{#}. Включает комп по таймеру, {\n #}
echo.         для выполнения обновления и др.
%ch% {08}     ============================================================ {\n #}
echo.
%ch%          В данный момент задача: %replyReboot4% и %replyReboot2% {00}.{\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Отключить и заблокировать включение {\n #}
%ch% {0e}     [2]{#} = Разблокировать и включить {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню Центра Обновлений{\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню Центра Обновлений - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :UpdateMenu )
if "%input%"=="1" ( goto :RebootOFF )
if "%input%"=="2" ( goto :RebootON
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :RebootIn )
:RebootOFF
echo.
set "taskpathReboot=\Microsoft\Windows\UpdateOrchestrator\Reboot"
set regsearchReboot="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "%taskpathReboot%" /e
for /f "usebackq delims=/ tokens=1" %%i in (' %regsearchReboot% ') do set "regpathReboot=%%i"
for /f "delims={} tokens=2" %%i in (' reg query  %regsearchReboot% ') do set "replyReboot1=%%i"
schtasks /Change /TN "%taskpathReboot%" /Disable 2>nul
%SetACL% -on "%regpathReboot:~2,-2%\{%replyReboot1%}" -ot reg -actn ace -ace n:SYSTEM;p:read -actn ace -ace n:S-1-5-32-544;p:read -actn setprot -op dacl:p_nc
echo.
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Задача "Reboot": {2f} Отключена и Заблокирована {#} -{00}.{\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
:RebootON
echo.
set "taskpathReboot=\Microsoft\Windows\UpdateOrchestrator\Reboot"
set regsearchReboot="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "%taskpathReboot%" /e
for /f "usebackq delims=/ tokens=1" %%i in (' %regsearchReboot% ') do set "regpathReboot=%%i"
for /f "delims={} tokens=2" %%i in (' reg query  %regsearchReboot% ') do set "replyReboot1=%%i"
%SetACL% -on "%regpathReboot:~2,-2%\{%replyReboot1%}" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np
schtasks /Change /TN "%taskpathReboot%" /Enable 2>nul
echo.
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Задача "Reboot": {0a}Разблокирована и Включена^^^!{#} - {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :UpdateMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::     --------------------------------------------------------
::     ----      Ниже начинается управление драйверами     ----
::     --------------------------------------------------------

::   Сценарий Меню для драйверов
:DrMenu
setlocal
set regkeyProgDr="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork"
for /f "tokens=3" %%I in (' reg query %regkeyProgDr% 2^>nul ') do set /a "valueProgDr=%%I"
if "%valueProgDr%"=="1" ( set "replyProgDr={0a}Отключена загрузка{#}" ) else ( set "replyProgDr={0e}Включена загрузка! (по умолчанию){#}" )
set regkeyDr="HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate"
for /f "tokens=3" %%I in (' reg query %regkeyDr% 2^>nul ') do set /a "valueDr=%%I"
if "%valueDr%"=="1" ( set "replyDr={0a}Отключена загрузка{#}" ) else ( set "replyDr={0e}Включена загрузка! (по умолчанию){#}" )
set regkeyDrRep="HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSendRequestAdditionalSoftwareToWER"
for /f "tokens=3" %%I in (' reg query %regkeyDrRep% 2^>nul ') do set /a "valueDrRep=%%I"
if "%valueDrRep%"=="1" ( set "replyDrRep={0a}Отключена отправка{#}" ) else ( set "replyDrRep={0e}Включена отправка! (по умолчанию){#}" )
set regkeyDrMeta="HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork"
for /f "tokens=3" %%I in (' reg query %regkeyDrMeta% 2^>nul ') do set /a "valueDrMeta=%%I"
if "%valueDrMeta%"=="1" ( set "replyDrMeta={0a}Запрещено{#}" ) else ( set "replyDrMeta={0e}Включено! (по умолчанию){#}" )
set regkeyDrSearch="HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate"
for /f "tokens=3" %%I in (' reg query %regkeyDrSearch% 2^>nul ') do set /a "valueDrSearch=%%I"
if "%valueDrSearch%"=="1" ( set "replyDrSearch={0a}Отключен{#}" ) else ( set "replyDrSearch={0e}Включен! (по умолчанию){#}" )
set regkeyDrSequence="HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig"
for /f "tokens=3" %%I in (' reg query %regkeyDrSequence% 2^>nul ') do set /a "valueDrSequence=%%I"
if "%valueDrSequence%"=="0" ( set "replyDrSequence={0a}Отключен{#}" ) else ( set "replyDrSequence={0e}Не Отключен! (по умолчанию){#}" )
set regkeyDrPriority="HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "AllSigningEqual"
for /f "tokens=3" %%I in (' reg query %regkeyDrPriority% 2^>nul ') do set /a "valueDrPriority=%%I"
if "%valueDrPriority%"=="1" ( set "replyDrPriority={0a}Равный{#}" ) else ( set "replyDrPriority={0e}Подписанных Microsoft! (по умолчанию){#}" )
set RegDriverUpd1="HKLM\SOFTWARE\Microsoft\WindowsUpdate\ExpressionEvaluators\Driver"
for /f "tokens=3" %%I in (' reg query %RegDriverUpd1% /v "DLL" 2^>nul ') do set "valueDriverUpd1=%%I"
if "%valueDriverUpd1%"=="wuuhext.dll" ( set "replyDriverUpd1={0e}Не заблокирована! (по умолчанию){#}" ) else ( set "replyDriverUpd1={0a}Заблокирована принудительно{#}" )
set RegDriverUpd2="HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdateHandlers\Driver"
for /f "tokens=3" %%I in (' reg query %RegDriverUpd2% /v "DLL" 2^>nul ') do set "valueDriverUpd2=%%I"
if "%valueDriverUpd2%"=="wuuhext.dll" ( set "replyDriverUpd2={0e}Не заблокирована! (по умолчанию){#}" ) else ( set "replyDriverUpd2={0a}Заблокирована принудительно{#}" )
cls
echo.
%ch% {08}     ============================================================================================================ {\n #}
%ch%          Управление {0a}авто{#}установкой и {0a}авто{#}обновлением драйверов + блокировка возможности их поиска{\n #}
echo.         После убирания блокировки, для поиска драйверов через ЦО, надо удалить или обновить драйвер вручную.
%ch%          Первый пункт меню действует только на {0a}авто{#}обновление системы, так как{\n #}
%ch%          {0e}эти параметры не влияют, при нажатии вами кнопки "Проверка наличия обновлений" ^^^!^^^!^^^!{\n #}
echo.         Для исключения загрузки и обновления драйвера, перед нажатием кнопки, нужно скрыть его утилитой,
echo.         либо полностью заблокировать драйвера, с помощью второго пункта меню.
%ch% {08}     ============================================================================================================ {\n #}
echo.
echo.           В данный момент:
%ch%                 Приложения: %replyProgDr% {#}    Отчеты: %replyDrRep% {\n #}
%ch%                   Драйвера: %replyDr% {#}    Получение метаданных: %replyDrMeta% {\n #}
%ch%            Поиск драйверов: %replyDrSearch% {#}              Порядок поиска: %replyDrSequence% {\n #}
%ch%        Приоритет установки: %replyDrPriority% {\n #}
echo.
%ch%    Возможность определения: %replyDriverUpd1% {\n #}
%ch%         Возможность поиска: %replyDriverUpd2% {\n #}
echo.
echo.         Варианты действий:
echo.
%ch% {0b}     [1]{#} = Отключить только {0a}авто{#}установку драйверов {\n #}
%ch% {0b}     [2]{#} = Отключить {0a}авто{#}установку + блокировка {\n #}
%ch% {0e}     [3]{#} = Включить все обратно {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}     [4]{#} = Меню Блокировки/разблокировки установки драйверов по {0e}GUID {\n #}
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню Управления обновлениями {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню Управления обновлениями - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :UpdateMenu )
if "%input%"=="1" ( goto :DrOFF )
if "%input%"=="2" ( goto :DrOFF )
if "%input%"=="3" ( goto :DrON )
if "%input%"=="4" ( endlocal & goto :GUIDIn
) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	 TIMEOUT /T 2 >nul & endlocal & goto :DrMenu )

:DrOFF
echo.
::::   Отключение поиска и скачивания приложений и значков для ваших устройств
::::   Эти настройки в: Свойства системы -> Оборудование -> параметры установки устройств
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Компоненты -> Центр обновления -> Не включать драйвера в обновления Windows
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Система -> Установка устройств -> не отправлять отчет об ошибках...
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSendRequestAdditionalSoftwareToWER" /t REG_DWORD /d 1 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Система -> Установка устройств -> Запретить получение метаданных устройств
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Система -> Управление связью... -> Параметры ... -> Отключить поиск драйверов
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d 1 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Система -> Установка устройств -> Задать порядок поиска ... драйверов
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f
::::   Параметр ГП: Компьютер -> адм. шаблоны -> Система -> Установка устройств -> Устанавливать одинаковый приоритет для драйверов с подписью от M$ и сторонних
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "AllSigningEqual" /t REG_DWORD /d 1 /f
::::   Заблокировать возможность получения драйверов службой обновления
set RegDriverUpd1="HKLM\SOFTWARE\Microsoft\WindowsUpdate\ExpressionEvaluators\Driver"
set RegDriverUpd2="HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdateHandlers\Driver"
rem @echo on
if "%~1"=="QuickApply" if "%~2"=="2" set input=2
if "%input%"=="2" (
 %SetACL% -on %RegDriverUpd1% -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
 %SetACL% -on %RegDriverUpd1% -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
 reg add %RegDriverUpd1% /v "DLL" /t REG_SZ /d "1wuuhext1.dll" /f
 reg add %RegDriverUpd1% /v "Prefixes" /t REG_MULTI_SZ /d "1d1." /f
 %SetACL% -on %RegDriverUpd1% -ot reg -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:read" -actn ace -ace n:S-1-5-32-544;p:read -silent
 %SetACL% -on %RegDriverUpd2% -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
 %SetACL% -on %RegDriverUpd2% -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
 reg add %RegDriverUpd2% /v "DLL" /t REG_SZ /d "1wuuhext1.dll" /f
 reg add %RegDriverUpd2% /v "LocalOnly" /t REG_DWORD /d 1 /f
 %SetACL% -on %RegDriverUpd2% -ot reg -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:read" -actn ace -ace n:S-1-5-32-544;p:read -silent
)
::::   Очистка папки загрузки обновлений
net stop bits
net stop wuauserv
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
net start bits
net start wuauserv
echo.
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
if "%input%"=="2" (
 %ch%      - {2f} Заблокирована {#} загрузка и автоустановка - {\n #}
 echo.
 %ch%        {0e} Необходимо перезагрузиться! {\n #}
 echo.
) else (
 %ch%      - {2f} Отключена {#} только автоустановка - {\n #}
 echo.
 %ch%        {0e} Необходимо перезагрузиться! {\n #}
 echo.
)
TIMEOUT /T -1 & endlocal & goto :DrMenu


:DrON
echo.
::::   Включение поиска и загрузки приложений и значков для выших устройств (по умолчанию)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 1 /f
::::   Загружать драйвера при обновлении Windows (по умолчанию)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" /f
::::   Вернуть возможность получения драйверов службой обновления (по умолчанию)
set RegDriverUpd1="HKLM\SOFTWARE\Microsoft\WindowsUpdate\ExpressionEvaluators\Driver"
set RegDriverUpd2="HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdateHandlers\Driver"
%SetACL% -on %RegDriverUpd1% -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on %RegDriverUpd1% -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add %RegDriverUpd1% /v "DLL" /t REG_SZ /d "wuuhext.dll" /f
reg add %RegDriverUpd1% /v "Prefixes" /t REG_MULTI_SZ /d "d." /f
%SetACL% -on %RegDriverUpd1% -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on %RegDriverUpd1% -ot reg -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -actn ace -ace n:S-1-5-32-544;p:read -silent
%SetACL% -on %RegDriverUpd2% -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on %RegDriverUpd2% -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add %RegDriverUpd2% /v "DLL" /t REG_SZ /d "wuuhext.dll" /f
reg add %RegDriverUpd2% /v "LocalOnly" /t REG_DWORD /d 0 /f
%SetACL% -on %RegDriverUpd2% -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on %RegDriverUpd2% -ot reg -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -actn ace -ace n:S-1-5-32-544;p:read -silent
::::   Очистка папки загрузки обновлений
net stop bits
net stop wuauserv
pushd "%SystemRoot%\SoftwareDistribution" && ( rmdir /s /q "%SystemRoot%\SoftwareDistribution" & popd ) 2>nul
net start bits
net start wuauserv
echo.
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
%ch%      - {0a} Включена {#} загрузка и автоустановка (по умолчанию) - {\n #}
echo.
%ch%        {0e} Необходимо перезагрузиться! {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :DrMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::     ----------------------------------------------
::     ----      Конец управления драйверами     ----
::     ----------------------------------------------



::     -------------------------------------------------------------------
::     ----      Ниже начинается управление Групповыми политиками     ----
::     -------------------------------------------------------------------

::   Меню Настройки Групповых Политик
:MenuGP
if "%GPEditorNO%" EQU "1" (
 echo.& %ch%     {0d}Нет Групповых Политик в вашей Редакции Windows{\n #}
 echo.& %ch%     {0e}Возврат в главное меню {\n #}& echo.
 TIMEOUT /T 6 >nul & goto :Menu
)
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set GPMachineFile=%SystemRoot%\System32\GroupPolicy\Machine\Registry.pol
set GPUserFile=%SystemRoot%\System32\GroupPolicy\User\Registry.pol

if exist "%LGPOtemp%" del /f /q "%LGPOtemp%"

if exist "%PresetLGPO%" (
 set "PresetGP={0a}Найден    {08}^| \%PresetLGPO%{#}"
 Call :BOMRemove "%PresetLGPO%" "%PresetLGPOTemp%"
) else ( set "PresetGP={0e}Не найден {08}^| \%PresetLGPO%{#}" )

if exist "%PresetLGPOMy%" (
 set "MyPresetGP={0a}Найден    {08}^| \%PresetLGPOMy%{#}"
 Call :BOMRemove "%PresetLGPOMy%" "%PresetLGPOTemp%"
) else ( set "MyPresetGP={0e}Не найден {08}^| \%PresetLGPOMy%{#}" )

if exist "%GPMachineFile%" (
 for %%I in ("%GPMachineFile%") do set /a "size=%%~ZI"
 if !size! GTR 99 ( set "GPMachine={0a}Есть примененные параметры{#}" & set "MachinePol=1"
 ) else ( set "GPMachine={0e}Не настроена{#}" )
) else ( set "GPMachine={0e}Не настроена{#}" )
if exist "%GPUserFile%" (
 for %%I in ("%GPUserFile%") do set /a "size=%%~ZI"
 if !size! GTR 99 ( set "GPUser={0a}Есть примененные параметры{#}" & set "UserPol=1"
 ) else ( set "GPUser={0e}Не настроена{#}" )
) else ( set "GPUser={0e}Не настроена{#}" )
cls
echo.
%ch% {08}     ====================================================================================  {\n #}
%ch%          Настройка {0e}Групповой Политики{#} утилитой {0e}LGPO.exe{#} v2.2  {\n #}
echo.         Для настройки ГП через LGPO.exe достаточно одного .txt файла его формата
%ch%          {0b}Сброс ГП приведет и к сбросу параметров из других меню, где настраиваются ГП {\n #}
%ch% {08}     ====================================================================================  {\n #}
echo.
echo.         В данный момент:
%ch%             Конфигурация для Компьютера: %GPMachine% {\n #}
%ch%          Конфигурация для Пользователей: %GPUser% {\n #}
echo.
%ch%               Файл настроек ГП: %PresetGP% {\n #}
%ch%          Свой файл настроек ГП: %MyPresetGP% {\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Настроить ГП из файла LGPO {08}(Настройки будут добавлены/заменены в ГП){\n #}
%ch% {0b}     [2]{#} = Настроить ГП {0f}Своим файлом {08}(Настройки будут добавлены/заменены в ГП){\n #}
echo.
%ch% {0d}   [333]{#} = {0d}Создать{#} Свой файл {0d}"\%PresetLGPOMy%"{#} из уже настроенных ГП {08}(Существующий файл заменится){\n #}
%ch% {0e}   [999]{#} = Сброс настроек ГП {0e}"по умолчанию" {08}(Повлияет на все меню, где настраиваются ГП){\n #}
%ch% {0b}   [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set /p СhoiceGP=-   Ваш выбор: 
if not defined СhoiceGP ( echo. & %ch% {0e}       Возврат в главное меню {\n #} & echo.
		 	  TIMEOUT /T 2 >nul & endlocal & goto :Menu )
if "%СhoiceGP%"=="1"   ( goto :ApplyGP )
if "%СhoiceGP%"=="2"   ( goto :ApplyGP )
if "%СhoiceGP%"=="333" ( goto :CreateMyLGPO )
if "%СhoiceGP%"=="999" ( endlocal & goto :ResetGP
 ) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :MenuGP )

:: Сценарий настройки Групповых Политик файлом LGPO
:ApplyGP
echo.
if "%~1"=="QuickApply" if "%~2"=="2" set "СhoiceGP=2"
set "MyLGPO=LGPO"
if "%СhoiceGP%"=="2" set "PresetLGPO=%PresetLGPOMy%" & set "MyLGPO={0e}Своего LGPO{0b}"
if not exist "%PresetLGPO%" (
 %ch%     {0e}LGPO файл "%PresetLGPO%" не найден {\n #}
 echo.
 if "%~1"=="QuickApply" exit /b
 TIMEOUT /T 5 >nul & endlocal & goto :MenuGP
)
%ch%      {0b}Применение параметров из %MyLGPO% файла {08}(настройка ГП) {\n #}
%LGPO% /t "%PresetLGPO%" /q
if "%Errorlevel%" NEQ "0" (
 echo.
 %ch% {0c}    ================================================================================= {\n #}
 %ch% {0c}        Ошибка применения файла LGPO^^^! {\n #}
 %ch% {0e}        Проблемный {0f}"LGPO_File_error_(%TIME:~,2%-%TIME:~3,2%-%TIME:~6,2%).txt"{0e} скопирован в папку с батником {\n #}
 echo.F| xcopy /Y /Q /R "%PresetLGPO%" "LGPO_File_error_(%TIME:~,2%-%TIME:~3,2%-%TIME:~6,2%).txt" >nul & echo.
 echo.
 if "%~1"=="QuickApply" exit /b
 echo.&echo.&echo.Для возврата в Меню нажмите любую клавишу...
 TIMEOUT /T -1 >nul & endlocal & goto :MenuGP
)
if exist "Files\GP\comment_Machine.cmtx" (
 %ch%          Копируем комментарии: {0a}\Files\GP\comment_Machine.cmtx{#} в {0e}...\Machine\comment.cmtx {\n #}
 echo.F| xcopy /Y /Q /V /H /R "Files\GP\comment_Machine.cmtx" "%SystemRoot%\System32\GroupPolicy\Machine\comment.cmtx"  >nul
)
if exist "Files\GP\comment_User.cmtx" (
 %ch%          Копируем комментарии: {0a}\Files\GP\comment_User.cmtx{#} в {0e}...\User\comment.cmtx {\n #}
 echo.F| xcopy /Y /Q /V /H /R "Files\GP\comment_User.cmtx" "%SystemRoot%\System32\GroupPolicy\User\comment.cmtx" >nul
)
echo.
%ch% {0a}     ========================================================================== {\n #}
%ch% {0a}         Групповые Политики настроены файлом {0f}%PresetLGPO% {\n #}
%ch% {0a}     ========================================================================== {\n #}
echo.
if "%~1"=="QuickApply" exit /b
%ch%      {0a}Не забудьте{#} по окончании перезагрузить компьютер^^^! {\n #}
echo.&echo.&echo.Для возврата в Меню нажмите любую клавишу ...
TIMEOUT /T -1 >nul & endlocal & goto :MenuGP


:: Сценарий создания своего файла LGPO из настроенных Групповых Политик
:CreateMyLGPO
echo.
%ch%    {0b}Создание своего файла LGPO: {0d}"\%PresetLGPOMy%" {\n #}
if "%MachinePol%"=="1" (if exist %PresetLGPOMy% del /f /q %PresetLGPOMy%)
if "%UserPol%"=="1" (if exist %PresetLGPOMy% del /f /q %PresetLGPOMy%)
if "%MachinePol%"=="1" (
 %ch%      Добавление параметров из:  {0f}%GPMachineFile% {\n #}
 %LGPO% /parse /q /m %GPMachineFile% > %PresetLGPOMy%
 set "RegistryPol=1"
 if exist "%SystemRoot%\System32\GroupPolicy\Machine\comment.cmtx" (
  if exist "Files\GP\comment_Machine.cmtx" (
   echo.
   %ch%                     Свой файл: {0f}\Files\GP\comment_Machine.cmtx{#} уже существует{\n #}
   %ch%         Переименовываем его в: {0e}comment_Machine_[%TIME:~,2%.%TIME:~3,2%.%TIME:~6,2%; %DATE%].cmtx {\n #}
   ren "Files\GP\comment_Machine.cmtx" "comment_Machine_[%TIME:~,2%.%TIME:~3,2%.%TIME:~6,2%; %DATE%].cmtx"
  )
  %ch%        И копируем комментарии: {0f}...\Machine\comment.cmtx{#} в {0a}\Files\GP\comment_Machine.cmtx{\n #}
  echo.F| xcopy /Y /Q /V /H /R "%SystemRoot%\System32\GroupPolicy\Machine\comment.cmtx" "Files\GP\comment_Machine.cmtx" >nul
 )
)
if "%UserPol%"=="1" (
 echo.
 %ch%      Добавление параметров из:  {0f}%GPUserFile% {\n #}
 %LGPO% /parse /q /u %GPUserFile% >> %PresetLGPOMy%
 set "RegistryPol=1"
 if exist "%SystemRoot%\System32\GroupPolicy\User\comment.cmtx" (
  if exist "Files\GP\comment_User.cmtx" (
   echo.
   %ch%                     Свой файл: {0f}\Files\GP\comment_User.cmtx{#} уже существует{\n #}
   %ch%         Переименовываем его в: {0e}comment_User_[%TIME:~,2%.%TIME:~3,2%.%TIME:~6,2%; %DATE%].cmtx {\n #}
   ren "Files\GP\comment_User.cmtx" "comment_User_[%TIME:~,2%.%TIME:~3,2%.%TIME:~6,2%; %DATE%].cmtx"
  )
  %ch%        И копируем комментарии: {0f}...\User\comment.cmtx{#} в {0a}\Files\GP\comment_User.cmtx{\n #}
  echo.F| xcopy /Y /Q /V /H /R "%SystemRoot%\System32\GroupPolicy\User\comment.cmtx" "Files\GP\comment_User.cmtx" >nul
 )
)
if defined RegistryPol (echo.&%ch%      Файла LGPO {0a}Создан{\n #}
) else (echo.&%ch%      {0c}Не создан{#} Файл LGPO, {0e} Нет настроенных Групповых Политик{\n #})
echo.&echo.&echo.Для продолжения нажмите любую клавишу ...
TIMEOUT /T -1 >nul & endlocal & goto :MenuGP

::     Сценарий сброса Групповых политик
:ResetGP
setlocal EnableDelayedExpansion
if exist "%SystemRoot%\System32\GroupPolicy" (
 echo.
 echo.    --------------------------------------------------------------------------------------
 %ch%        Очистка системной папки {0e} "%WinDir%\System32\GroupPolicy" {\n #}
 pushd "%WinDir%\System32\GroupPolicy" && (rmdir /s /q "%WinDir%\System32\GroupPolicy" & popd) 2>nul
 for /f %%I in (' dir /b /a "%WinDir%\System32\GroupPolicy" ') do set "BlockFiles=%%I"
 if not "!BlockFiles!"=="" (
  echo.
  %ch%       Один из Файлов {0e}Registry.pol {4f} Заблокирован! {#} Удалить не получилось. {\n #}
  echo.
  %ch%       {4f} Отмена {#} всех действий. {\n #}
  echo.
  if "%~1"=="QuickApply" exit /b
  echo.&echo.&echo.Для возврата в Меню нажмите любую клавишу.
  TIMEOUT /T -1 >nul
  endlocal & goto :MenuGP
 )
 %ch%        Папка {2f} Очищена {00}.{\n #}
) else (
 echo.
 %ch%       Cистемная папка {0e}GroupPolicy {4f} Не существует^^^! {00}.{\n #}
 echo.
 if "%~1"=="QuickApply" exit /b
 echo.&echo.&echo.Для возврата в Меню нажмите любую клавишу.
 TIMEOUT /T -1 >nul
 endlocal & goto :MenuGP
)
echo.
echo.    ---------------------------------------------------------------------------------------
%ch% {0e}        Сбрасываются Групповые Политики, подождите ... {\n #}
echo.
gpupdate /force
if "%~1"=="QuickApply" exit /b
%ch% {0A}    ======================================================== {\n #}
%ch% {0A}        Групповые Политики сброшены, если были настроены     {\n #}
%ch% {0A}    ======================================================== {\n #}
echo.
%ch% {0a}        Не забудьте{#} по окончании перезагрузить компьютер^^^! {\n #}
echo.&echo.&echo.Для возврата в Меню нажмите любую клавишу.
TIMEOUT /T -1 >nul
endlocal & goto :MenuGP

::     ---------------------------------------------------------
::     ----      Конец управления Групповыми политиками     ----
::     ---------------------------------------------------------



:: Меню управления обслуживанием системы
:MenuMaintance
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::                                                                                                   :::::
:::::   Настройка обслуживания системы.                                                                 :::::
:::::   Обслуживание - передача собранных данных и отчетов, обновление индексации поиска, оптимизация   :::::
:::::   загрузки, очистка cистемного диска и др. Назначена по умолчанию на ночь.                        :::::
:::::                                                              ::::::::::::::::::::::::::::::::::::::::::
setlocal EnableDelayedExpansion
:::::   Проверка параметров обслуживания :::::::::::::::::::::::::::
set RegMaint="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled"
for /f "tokens=3" %%I in (' reg query %RegMaint% 2^>nul ') do set /a "ValueMaint=%%I"
if "%ValueMaint%"=="1" ( set "ReplyMaint={0a}Запрещено{#}" ) else ( set "ReplyMaint={0e}Разрешено{#}" )
:::::   Проверка параметров пробуждения компьютера для автообслуживания (MaintIn) :::::::::::::::::::::::::::
set regkeyWake="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp"
for /f "tokens=3" %%I in (' reg query %regkeyWake% 2^>nul ') do set /a "valueWake=%%I"
if "%valueWake%"=="0" ( set "replyWake={0a}Запрещено{#}" ) else ( set "replyWake={0c}Разрешено^^^^^!{#}" )
cls
echo.
%ch% {08}    =================================================================================================== {\n #}
%ch% {07}        Меню управления и выполнения {0e}Обслуживания системы{#} {\n #}
echo.        Возможность выполнить 5 важных последовательных действий, при запрещенном обслуживании
echo.        Либо использовать встроенное стандартное обслуживание из Центра безопасности и обслуживания
echo.        Очистку достаточно делать раз в пол года, по желанию.
%ch% {08}    =================================================================================================== {\n #}
echo.
echo.        В данный момент:
%ch%            Обслуживание: %replyMaint%   Пробуждение: %replyWake% {00}.{\n #}
echo.
%ch% {0b}    [1]{#} = {0e}Меню ручного обновления {08}(из папки){\n #}
echo.
%ch% {0b}    [2]{#} = {0d}Выполнить{#} {0f}[3]{#}, {0f}[4]{#}, {0f}[5]{#}, {0f}[6]{#} пункты {08}(Сразу 4 действия) ^| {0e}~60мин {\n #}
%ch% {0b}    [3]{#} = {0d}Выполнить{#} генерацию образов {0e}NET Framework{#} для программ {08}(Ngen) ^| {0e}~7мин{\n #}
%ch% {0b}    [4]{#} = {0d}Выполнить{#} очистку папки {0e}WinSxS {08}(Очистка и сжатие старых обновлений) ^| {0e}~40мин {\n #}
%ch% {0b}    [5]{#} = {0d}Выполнить{#} очистку системного диска {0e}%Systemdrive% {08}(Папки temp, логи, дампы и т.д.) ^| {0e}~20мин {\n #}
%ch% {0b}    [6]{#} = {0d}Выполнить{#} синхронизацию времени {08}(результат может быть с задержкой) ^| {0e}~0мин{\n #}
echo.
%ch% {0b}    [7]{#} = {0e}Меню оптимизации дисков {08}(Дефрагментация, TRIM, создание раздельных задач){\n #}
echo.
%ch% {0b}    [8]{#} = {0e}Меню Настройки обслуживания и пробуждения {08}(Вкл/Выкл){\n #}
%ch% {0b}    [9]{#} = {0d}Начать{#} стандартное обслуживание системы {08}(Снимет запрет и включит важные задачи) ^| {0e}~90мин {\n #}
%ch% {0c}   [10]{#} = {0c}Остановить{#} стандартное обслуживание системы {\n #}
echo.
%ch% {0b}   [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set "choice="
set /p choice=--- Ваш выбор: 
if not defined choice ( echo.&%ch%     {0e} - Возврат в главное меню - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :Menu  )
if "%choice%"=="1"  ( endlocal & goto :MenuHandUpdate )
if "%choice%"=="2"  ( goto :GoNgen )
if "%choice%"=="3"  ( goto :GoNgen )
if "%choice%"=="4"  ( goto :ClearWinSxS )
if "%choice%"=="5"  ( goto :DiskClean )
if "%choice%"=="6"  ( goto :TimeSync )
if "%choice%"=="7"  ( endlocal & goto :MenuDiskOpt )
if "%choice%"=="8"  ( endlocal & goto :MenuMaintIn )
if "%choice%"=="9"  ( goto :StartMaint )
if "%choice%"=="10" ( goto :StopMaint
 ) else ( echo.&%ch%    {0e}Неправильный выбор {\n #} & echo.
	  endlocal & TIMEOUT /T 2 >nul & goto :MenuMaintance )


:: Меню ручной установки обновлений из папки
:MenuHandUpdate
setlocal EnableDelayedExpansion
set "UpdateFolder=Files\Updates"
cls
echo.
%ch% {08}    ==========================================================================================================   {\n #}
%ch%         {0e}Ручная установка пакетов обновлений или драйверов{#} в файлах {0f}.MSU{#}/{0f}.CAB{#} из папки {0f}\%UpdateFolder% {\n #}
%ch%         Обновления устанавливаются утилитой {0f}DISM{#}. В алфавитном порядке. Центр обновлений Windows не нужен^^^! {\n #}
%ch%         Названия {0f}CAB{#} файлов роли не играют. Драйвера добавляются в хранилище утилитой PnP: {0f}pnputil.exe     {\n #}
%ch% {08}    ==========================================================================================================   {\n #}
echo.
echo.        Установленные обновления:
set /a N=0
for /f "tokens=1-4 delims=/ " %%I in (' 2^>nul wmic qfe get HotFixID^, InstalledOn ^| find /i "KB" ') do (
 if %%J LEQ 9 (set "Month=0%%J") else (set "Month=%%J")
 if %%K LEQ 9 (set "Day=0%%K") else (set "Day=%%K")
 set /a N+=1 & %ch%           !N!. {0a}%%I {08}^| !Day!.!Month!.%%L {\n #})
if "!N!"=="0" (%ch%           {0e}Нет установленных обновлений{\n #})
echo.
%ch%         Файлы обновлений {0f}MSU %xOS%{#} в папке {0f}\%UpdateFolder%{#}:{\n #}
set /a N=0
for /f "tokens=3,4 delims=-._" %%I in (' 2^>nul dir /b "%UpdateFolder%\*.msu" ^| findstr /i "[.]msu\>" ^| find /i "windows10.0-kb" ^| find /i "%xOS%" ') do (
 set /a N+=1 & %ch%           !N!. {0e}%%I {08}^| %%J {\n #})
if "!N!"=="0" (%ch%           {0e}Нет файлов MSU %xOS% в папке{\n #} & set "MsuNO=1")
echo.
%ch%         Все Файлы {0f}CAB{#} в папке {0f}\%UpdateFolder%{#}:{\n #}
Call :FileCheckReName
Call :CheckCAB "Check"
if "%Errorlevel%" EQU "5" set "CabNO=1"
echo.
%ch% {0b}     [111]{#} = {0d}Начать{#} установку обновлений {0f}MSU{#} файлов {08}(Проверяется наличие в системе^^^!) {\n #}
%ch% {0b}     [222]{#} = {0d}Начать{#} установку пакетов {0f}CAB{#} файлов {08}(Проверяется совместимость и по возможности наличие в системе^^^!) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню обслуживания {\n #}
echo.
set "choice="
set /p choice=---   Ваш выбор: 
if not defined choice ( echo.&%ch%     {0e} - Возврат в меню обслуживания - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :MenuMaintance  )
if "%choice%"=="111" ( goto :HandUpdateRunMSU )
if "%choice%"=="222" ( goto :HandUpdateRunCAB
 ) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
	  endlocal & TIMEOUT /T 2 >nul & goto :MenuHandUpdate )

:: Сценарий поиска файлов обновлений MSU в папке, распаковки и установки, в порядке увеличения номера обновлений
:HandUpdateRunMSU
echo.
if "%MsuNO%"=="1" (%ch%           {0e}Нет файлов MSU %xOS% в папке{\n #} &echo.
  TIMEOUT /T 4 >nul & endlocal & goto :MenuHandUpdate
)
set "Restart="
for /f "tokens=3,4 delims=-._" %%I in (' 2^>nul dir /b "%UpdateFolder%\*.msu" ^| findstr /i "[.]msu\>" ^| find /i "windows10.0-kb" ^| find /i "%xOS%" ') do (
 wmic qfe get HotFixID | find /i "%%I" >nul
 if errorlevel 1 (
  for /f %%J in (' dir /b "%UpdateFolder%\*.msu" ^| findstr /i "[.]msu\>" ^| find /i "windows10.0-%%I-%xOS%" ') do (
   echo.&echo.
   echo.     ==========================================================
   %ch%          Распаковка и установка обновления: {0a}%%I {08}^| %xOS% {\n #}
   rd /s /q "%UpdateFolder%\%%I" >nul 2>&1 & md "%UpdateFolder%\%%I"
   echo.
   Expand "%UpdateFolder%\%%J" -F:* "%UpdateFolder%\%%I"
   echo.
   Dism /Online /Add-Package /PackagePath:"%UpdateFolder%\%%I\windows10.0-%%I-%xOS%.cab" /NoRestart
   rd /s /q "%UpdateFolder%\%%I" >nul 2>&1 & set "Restart=Yes"
  )
 ) else (
  echo.&echo.
  echo.     ++++++++++++++++++++++++++++++++++++++++++++++++++
  %ch%          Обновление {0e}%%I {08}^| %xOS% уже Установлено {\n #}
  echo.     ++++++++++++++++++++++++++++++++++++++++++++++++++
 )
)
if "!Restart!"=="Yes" (
 echo.&echo.
 %ch% {0e}          ========================================================== {\n #}
 %ch% {0e}              Для завершения обновления необходима перезагрузка^^^! {\n #}
 %ch% {0e}              Перезагрузить компьютер прямо сейчас? {\n #}
 echo.
 %ch% {0b}              [1]{#} = {0d}Да{\n #}
 echo.
 %ch% {0b}              [Без ввода]{#} = Не перезагружать {\n #}
 echo.
 set "Restartchoice="
 set /p Restartchoice=--- Ваш выбор: 
 if "!Restartchoice!"=="1" (
  echo.
  %ch%     {0a}Будет выполнена перезагрука через 10 секунд{\n #}
  echo.
  shutdown /r /t 10 /c "Перезагрузка начнется через 10 секунд"
 )
)
TIMEOUT /T -1 & endlocal & goto :MenuHandUpdate



:: Сценарий проверки и переименования .cab файлов, если в имени присутствуют спецсимволы: {}()^&%!.
:: Все скобки заменяются на такие [], остальные символы просто убираются.
:: Если в результате убирания символов имена файлов будут одинаковые, будет добавлен префикс _2, _3, и так далее.
:FileCheckReName
setlocal EnableDelayedExpansion
set EXT=cab
set "FileTemp=%temp%\FileCabReName.txt"
set /a N=1
:FileCheckReNameRepeat
for /f "delims=" %%I in (' dir /b /a:-d "%UpdateFolder%\*.%EXT%" 2^>nul ^| findstr /i "[.]%EXT%\>" ^| findstr "%% ^^ & ( ) { } ^!" ') do (
 setlocal DisableDelayedExpansion
 <nul set /p =""%UpdateFolder%\%%I"">"%FileTemp%"
 endlocal
 set "FileName=%%I"
 set "FileName=!FileName:~0,-4!"
 set "FileName=!FileName:(=[!"
 set "FileName=!FileName:)=]!"
 set "FileName=!FileName:{=[!"
 set "FileName=!FileName:}=]!"
 set "FileName=!FileName:^=!"
 set "FileName=!FileName:&=!"
 set "FileName=!FileName:%%=!"
 echo. "!FileName!.%EXT%">>"%FileTemp%"
 for /f "delims=" %%J in (' type "%FileTemp%" ') do (
  setlocal DisableDelayedExpansion
  ren %%J 2>nul && (%ch%      {08}Файл: {0b}%%I {08}^| {0e}Переименован {08}^| Спецсимволы в имени{\n #}& endlocal & set /a N=1) || (
   endlocal
   set /a N+=1
   set "Data=%%J"
   set Data=!Data:~0,-5!_!N!.%EXT%^"
   ren !Data! 2>nul && ( set /a N=1 )
  )
  del /f /q "%FileTemp%"
 )
)
dir /b /a:-d "%UpdateFolder%\*.%EXT%" 2>nul | findstr /i "[.]%EXT%\>" | findstr "%% ^^ & ( ) { } ^!" >nul && goto :FileCheckReNameRepeat
endlocal
exit /b


:: Сценарий запуска на установку .CAB файлов
:HandUpdateRunCAB
echo.
if "%CabNO%" EQU "1" (%ch%           {0e}Нет файлов CAB в папке{\n #} &echo.
 TIMEOUT /T 4 >nul & endlocal & goto :MenuHandUpdate
)
Call :CheckCAB "Apply"
echo.&echo.
echo.&%ch%      {2f} Все выполнено {00}.{\n #}
echo.&%ch%      {0a} Не забудьте перезагрузится, если была установка {\n #}
%ch%      {0a} Добавленные драйвера система увидит после перезагрузки {\n #}
TIMEOUT /T -1 & endlocal & goto :MenuHandUpdate


::  Сценарий получения и вывода информации по файлам .cab, проверка их совместимости и текущего наличия в системе, а так же направление на установку
::  Все данные по обновлениям берутся из файла update.mum, после его извлечения из .cab через 7z.exe.
::  Драйвера определяются по наличию файлов .INF в .CAB файле, включая поддиректории.
::  Названия .cab файлов не играют ни какой роли. Не по всем файлам будет отображено наличие в системе.
:CheckCAB
set /a N=0
for /f "tokens=1* delims=" %%A in (' 2^>nul dir /b /a:-d "%UpdateFolder%\*.cab" ^| findstr /i "[.]cab\>" ') do (
 set "PackArhVal=" & set "PackArh=" & set "PackName=" & set "PackLang=" & set "GetInstall=" & set "SizeMUM="
 set "PackVers=" & set "ArhNO=" & set "VerNO="
 set "CabFilesYES=1"
 set "CabName=%%A"
 set "MumName=!CabName:~0,-4!.mum"

 set "CabNameShort=!CabName:~0,30!"
 set "CabNameTest=!CabNameShort:*.cab=!"
 if "!CabNameTest!" NEQ "" set "CabNameShort=!CabNameShort:~0,-4!~.cab"
 set "CabNameShort={0f}!CabNameShort!{#}"

 set /a N+=1
 if !N! LEQ 99 set "N= !N!"
 if !N! LEQ 9  set "N= !N!"

 set "Spaces=" & set "NS=1"
 for /l %%I in (1, 1, 30) do ( set "LineLength=!CabName:~%%I!" & if defined LineLength set /a "NS+=1" )
 for /l %%I in (30, -1, !NS!) do set "Spaces= !Spaces!"

 set "CabFileDefine="
 !Zip! l "%UpdateFolder%\!CabName!" update.mum 2>nul | find /i "update.mum" >nul && ( set "CabFileDefine=UpdateCab" ) || (
  !Zip! l "%UpdateFolder%\!CabName!" *.inf -r0 2>nul | find /i ".inf" >nul && ( set "CabFileDefine=DriverCab" )
 )

 if "!CabFileDefine!" EQU "UpdateCab" (

  !Zip! e "%UpdateFolder%\!CabName!" update.mum -aoa -so > "%UpdateFolder%\!MumName!" 2>nul

  if exist "%UpdateFolder%\!MumName!" ( for %%I in ("%UpdateFolder%\!MumName!") do set /a "SizeMUM=%%~ZI" )

  if !SizeMUM! NEQ 0 (

   for /f "tokens=*" %%I in (' type "%UpdateFolder%\!MumName!" ^| find /i "processorArchitecture=" ') do set "PackArhVal=%%I"
   echo."!PackArhVal!" | find /i "amd64" >nul && set "PackArh=x64"
   echo."!PackArhVal!" | find /i "x86" >nul && set "PackArh=x86"

   for /f tokens^=2^ delims^=^=^" %%I in (' type "%UpdateFolder%\!MumName!" ^| find /i "package identifier=" ') do set "PackName=%%I"

   for /f tokens^=4^ delims^=^=^" %%I in (' type "%UpdateFolder%\!MumName!" ^| findstr /irc:" language=...[-]..." ') do set "PackLang=%%I"

   for /f "tokens=1* delims=" %%B in (' type "%UpdateFolder%\!MumName!" ^| find "%OSVers%" ') do set "PackVers=%OSVers%"

   if "!PackArh!" EQU "%xOS%" (

    echo.!PackName!| findstr /irc:"^kb[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$" >nul && (
     reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" | find /i "!PackName!" >nul && (
      set "GetInstall=1" ) || ( set "GetInstall=0" )
    )

    if /i "!PackName!" EQU "Language Pack" (
     set LangKey="HKLM\SYSTEM\CurrentControlSet\Control\MUI\UILanguages"
     reg query !LangKey! | find "!PackLang!" >nul && ( set "GetInstall=1" ) || ( set "GetInstall=0" )
    )

    echo.!PackName!| find /i "NET Framework 3" | find /i "OnDemand" >nul && (
     set KeyNetFx3="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
     reg query !KeyNetFx3! /s /f "Microsoft-Windows-NetFx3-OnDemand-Package" /k | find "~~" >nul && ( set "GetInstall=1" ) || ( set "GetInstall=0" )
    )

   ) else ( set "ArhNO=1" )

   echo.!PackName!| find /i "NET Framework 3" | find /i "OnDemand" >nul && set "PackName=NET Framework 3.5 OnDemand"

   if /i "!PackVers!" EQU "%OSVers%" ( set "PackVers= {08}| {0f}!PackVers!" ) else ( set "VerNO=1" )

   if "!GetInstall!" EQU "1" set "PackInstall={08}| {0a}Установлен{#}"
   if "!GetInstall!" EQU "0" set "PackInstall={08}| {0e}Не установлен{#}"
   if "!GetInstall!" EQU ""  set "PackInstall={08}| {0b}Подходит{#}" & set "GetInstall=0"

   if "!ArhNO!" EQU "1" (
    set "PackInstall={08}| {0c}Разрядность не подходит{#}" & set "GetInstall=" & set "PackArh={0c}!PackArh!{#}"
   ) else if "!VerNO!" EQU "" (
    if "!GetInstall!" EQU "1" set "PackArh={0a}!PackArh!{#}"
    if "!GetInstall!" EQU "0" set "PackArh={0e}!PackArh!{#}"
    if "!GetInstall!" EQU ""  set "PackArh={0e}!PackArh!{#}"
   ) else ( set "PackArh={0c}!PackArh!{#}" )

   if "!VerNO!" EQU "1" set "PackInstall={08}| {0c}Версия не подходит{#}" & set "GetInstall="
   if "!ArhNO!" EQU "1" if "!VerNO!" EQU "1" set "PackInstall={08}| {0c}Разрядность и версия не подходит{#}" & set "GetInstall="

   if /i "!PackName!" EQU "Language Pack" (
    set "PackName=Языковой пакет"
    if "!PackLang!" NEQ "" (
     if "!GetInstall!" EQU "1" set "PackLang= {08}| {0a}!PackLang!{#}"
     if "!GetInstall!" EQU "0" set "PackLang= {08}| {0e}!PackLang!{#}"
     if "!GetInstall!" EQU ""  set "PackLang= {08}| {0c}!PackLang!{#}"
    )
   ) else ( set "PackLang=" )

   if "!GetInstall!" EQU "" ( set "PackName={0c}!PackName!{#}"
   ) else if "!GetInstall!" EQU "0" ( set "PackName={0e}!PackName!{#}" ) else ( set "PackName={0a}!PackName!{#}" )

   if "%~1" NEQ "Apply" %ch% {08}!N!.{#} !CabNameShort!!Spaces! {08}^|{#} !PackArh! {08}^|{#} !PackName!!PackLang!!PackVers! !PackInstall! {\n #}

  ) & rem :: Конец выполнения, если размер не равен нулю

 ) else if "!CabFileDefine!" EQU "DriverCab" (
   set "PackInstall={08}| {0d}CAB Файл с драйверами {08}(Будут добавлены в хранилище драйверов){#}" & set "GetInstall=0"
   if "%~1" NEQ "Apply" %ch% {08}!N!.{#} !CabNameShort!!Spaces! {08}^| •••{#} !PackInstall! {\n #}
 )

 if "!CabFileDefine!" EQU "" (
  set "PackInstall={08}| {0c}Не определен^!^!^! | Будет пропущен{#}"
  if "%~1" NEQ "Apply" %ch% {08}!N!.{#} !CabNameShort!!Spaces! {08}^|{0c} ---{#} !PackInstall! {\n #}
 )

 if exist "%UpdateFolder%\!MumName!" del /f /q "%UpdateFolder%\!MumName!"

 if "%~1" EQU "Apply" if "!GetInstall!" NEQ "0" %ch%      {0e}Пропуск {#}установки пакета: !CabNameShort!!Spaces! !PackInstall! {\n #}

 if "%~1" EQU "Apply" if "!GetInstall!" EQU "0" Call :InstallCAB "Apply" "!CabName!" "!CabFileDefine!"
)
if "!CabFilesYES!" EQU "" %ch%           {0e}Нет файлов CAB в папке{\n #} & set "OUT=5"
exit /b !OUT!

:: Сценарий установки файлов обновлений .MSU или .CAB, включая пакеты драйверов, прошедших проверку в сценарии :CheckCAB
:InstallCAB
set "CabFile=%~2"
set "CabType=%~3"
if "%CabType%" EQU "UpdateCab" (
 echo.
 %ch% {08}     ============================================================================================================== {\n #}
 %ch%          {0b}Установка пакета {0e}Обновления{#}: {0f}%CabFile% {\n #}
 dism /online /Add-Package /PackagePath:"%UpdateFolder%\%CabFile%" /NoRestart
 echo.
)
if "%CabType%" EQU "DriverCab" (
 echo.
 %ch% {08}     ============================================================================================================== {\n #}
 %ch%          {0b}Добавление Драйверов {0d}В хранилище драйверов из{#}: {0f}%CabFile% {\n #}
 if exist "%UpdateFolder%\%CabFile:~0,-4%" rd /s /q "%UpdateFolder%\%CabFile:~0,-4%"
 md "%UpdateFolder%\%CabFile:~0,-4%"
 Expand "%UpdateFolder%\%CabFile%" -F:* "%UpdateFolder%\%CabFile:~0,-4%" >nul 2>&1
 echo.
 pnputil /add-driver "%UpdateFolder%\%CabFile:~0,-4%\*.inf" /subdirs
 echo.
 if exist "%UpdateFolder%\%CabFile:~0,-4%" rd /s /q "%UpdateFolder%\%CabFile:~0,-4%"
)
exit /b
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Сценарий генерации образов NET Framework для компонентов и программ
:GoNgen
echo.&%ch%      {0b}Начало{#} проверки и/или генерации образов {0e}NET Framework {08}^| x86{\n #} & echo.
for /f %%I in (' dir /B /A:D "%windir%\Microsoft.NET\Framework\v4*" ') do (
 %windir%\Microsoft.NET\Framework\%%I\ngen.exe ExecuteQueuedItems
)
if "%xOS%"=="x64" (
 for /f %%I in (' dir /B /A:D "%windir%\Microsoft.NET\Framework64\v4*" ') do (
  echo.&%ch%      {0b}Начало{#} проверки и/или генерации образов {0e}NET Framework {08}^| x64{\n #} & echo.
  %windir%\Microsoft.NET\Framework64\%%I\ngen.exe ExecuteQueuedItems
 )
)
echo.&%ch%      {2f} Выполнена {#} проверка и/или генерация образов {0e}NET Framework {00}.{\n #}
if "%choice%"=="2" goto :ClearWinSxS
TIMEOUT /T -1 & endlocal & goto :MenuMaintance

:: Сценарий очистки и сжатия папки WinSxS
:ClearWinSxS
echo.
%ch%      Выполняется: {0b}Очистка и сжатие папки WinSxS {\n #}
echo.     Ожидайте окончания, может продлиться до 2 часов
echo.&%ch%      Выполняется: {0b}Dism /Online /Cleanup-Image /StartComponentCleanup{\n #}
Dism /Online /Cleanup-Image /StartComponentCleanup
echo.&%ch%      {0e}При завершении на 20.0%% - очистка WinSxS не требуется{\n #}
echo.&%ch%      {0e}Бывает Ошибка: 2 - это небольшой недочет Dism.exe или makecab.exe{\n #}
echo.     Не находят файл C:\Windows\Logs\CBS\CbsPersist_***.log после его архивации и удаления утилитой makecab.exe
echo.&%ch%      {2f} Завершена {#} очистка и сжатие папки WinSxS {00}.{\n #}
if "%choice%"=="2" goto :DiskClean
TIMEOUT /T -1 & endlocal & goto :MenuMaintance

:: Сценарий очистки системного диска
:DiskClean
echo.
%ch%      Выполняется очистка системного диска: {0b}Сleanmgr.exe /sagerun:7777 {08}(С заданными параметрами){\n #}
%ch%      {0e}Оценка файлов для очистки происходит для всех пунктов, но в любом случае не будет очищено:{\n #}
%ch%      {0f}Корзина, BranchCache, Обновления, Кэш иконок, История файлов пользователя.{\n #}
echo.
set "Key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
for %%I in ( "Active Setup Temp Folders" "Downloaded Program Files" "Internet Cache Files" "Offline Pages Files" "Old ChkDsk Files" ^
 "Previous Installations" "RetailDemo Offline Content" "Setup Log Files" "System error memory dump files" "System error minidump files" ^
 "Temporary Files" "Temporary Setup Files" "Upgrade Discarded Files" "Windows Error Reporting Archive Files" "Windows Error Reporting Queue Files" ^
 "Windows Error Reporting System Archive Files" "Windows Error Reporting System Queue Files" "Windows Error Reporting Temp Files" ^
 "Windows ESD installation files" "Windows Upgrade Log Files"
) do ( reg add "%Key%\%%~I" /v "StateFlags7777" /t REG_DWORD /d 2 /f >nul)
for %%I in ( "BranchCache" "Recycle Bin" "Service Pack Cleanup" "Thumbnail Cache" "Update Cleanup" "User file versions" ) do (
 reg add "%Key%\%%~I" /v "StateFlags7777" /t REG_DWORD /d 0 /f >nul
)
start /wait %windir%\system32\cleanmgr.exe /sagerun:7777
for /f "delims=" %%I in (' reg query "%Key%" /s /f "StateFlags7777" ^| find /i "\VolumeCaches" ') do (
 reg delete "%%~I" /v "StateFlags7777" /f >nul
)
echo.&%ch%      {2f} Завершена {#} очистка системного диска {00}.{\n #}
if "%choice%"=="2" goto :TimeSync
TIMEOUT /T -1 & endlocal & goto :MenuMaintance

:: Сценарий синхронизации времени, с проверкой подключения к сети
:TimeSync
echo.
%ch%         {0e}Проверка сети перед Синхронизацией времени ...{\n #}&echo.
set Online=
set ValueOnline=
set IP=Google.com
for /l %%I in (1,1,3) do (
 if "!Online!"=="" (
  for /f %%J in (' ping -n 1 %IP% ^| findstr /i /n "TTL=" ') do set ValueOnline=%%J
   if !ValueOnline! GEQ 1 ( set "Online=1" &echo.&%ch%                  Сеть ^| {0a}Online {\n #}&echo.
   ) else ( %ch%         Проверка: {0b}%%I{#} ^| {0e}Не удачная {\n #}& TIMEOUT /T 1 >nul )))
if not defined Online echo.&%ch%                Сеть ^| {0c}Не подключена{\n #}&echo. & TIMEOUT /T -1 & endlocal & goto :MenuMaintance
echo.
sc config w32time start= demand >nul
net start w32time
w32tm /resync >nul
w32tm /resync /nowait
echo.&%ch%      {2f} Выполнен {#} запрос на синхронизацию времени {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuMaintance


:: Меню оптимизации дисков
:MenuDiskOpt
setlocal EnableDelayedExpansion
set TaskScheduledDefrag="Microsoft\Windows\Defrag\ScheduledDefrag"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %TaskScheduledDefrag% 2^>nul ') do set "ReplyScheduledDefrag=%%~i"
if not "!ReplyScheduledDefrag!"=="" (
 if "!ReplyScheduledDefrag!"=="Disabled" ( set "ReplyScheduledDefrag={0a}Отключена{#}" ) else ( set "ReplyScheduledDefrag={0e}Включена{#}" )
) else ( set "ReplyScheduledDefrag={0c}Не существует^^^^^!{#}" )
set TaskSSD-Trim="Microsoft\Windows\Defrag\SSD-Trim"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %TaskSSD-Trim% 2^>nul ') do set "ReplyTaskSSD-Trim=%%~i"
if not "!ReplyTaskSSD-Trim!"=="" (
 if "!ReplyTaskSSD-Trim!"=="Disabled" ( set "ReplyTaskSSD-Trim={0e}Отключена{#}" ) else ( set "ReplyTaskSSD-Trim={0a}Включена{#}" )
) else ( set "ReplyTaskSSD-Trim={9f} Не создана {#}" )
set TaskHDD-Defrag="Microsoft\Windows\Defrag\HDD-Defrag"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %TaskHDD-Defrag% 2^>nul ') do set "ReplyTaskHDD-Defrag=%%~i"
if not "!ReplyTaskHDD-Defrag!"=="" (
 if "!ReplyTaskHDD-Defrag!"=="Disabled" ( set "ReplyTaskHDD-Defrag={0e}Отключена{#}" ) else ( set "ReplyTaskHDD-Defrag={0a}Включена{#}" )
) else ( set "ReplyTaskHDD-Defrag={9f} Не создана {#}" )
cls
echo.
%ch% {08}    ============================================================================================== {\n #}
%ch%         Меню раздельной оптимизации {0a}SSD{#} и {0e}HDD{#} дисков. Для предотвращения дефрагментации SSD. {\n #}
%ch%         Раздельные задачи будут использоваться {0a}авто{#}обслуживанием системы, если не запрещаете. {\n #}
echo.        Определение дисков может идти медленно, если они отключаются при простое.
%ch% {08}    ============================================================================================== {\n #}
echo.
echo.        В данный момент Задачи:
%ch%                ScheduledDefrag: %ReplyScheduledDefrag%     SSD-Trim: %ReplyTaskSSD-Trim%   HDD-Defrag: %ReplyTaskHDD-Defrag%  {00}.{\n #}
echo.
echo.        Ваши жесткие диски:
Call :DiskInfo
echo.
%ch% {0b}    [1]{#} = Создать раздельные задачи оптимизации дисков {0a}SSD-Trim{#} и {0e}HDD-Defrag {08}(желательно){\n #}
%ch% {0e}    [2]{#} = Вернуть {0e}по умолчанию {08}(Включить задачу "ScheduledDefrag" и удалить остальные){\n #}
echo.
%ch% {0b}    [3]{#} = Запустить утилиту {0e}dfrgui {08}(ручная оценка и оптимизация дисков){\n #}
%ch% {0b}    [4]{#} = SSD: %TrimDisks%{\n #}
%ch% {0b}    [5]{#} = HDD: %DfrgDisks%{\n #}
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню обслуживания {\n #}
echo.
set "choice="
set /p choice=--- Ваш выбор: 
if not defined choice ( echo.&%ch%     {0e} - Возврат в меню обслуживания - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :MenuMaintance  )
if "%choice%"=="1" ( goto :CreateTasksDisks  )
if "%choice%"=="2" ( goto :TaskDef )
if "%choice%"=="3" ( goto :DfrGUI )
if "%choice%"=="4" ( goto :GoTrimSSD )
if "%choice%"=="5" ( goto :GoDefragHDD
	) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
		 endlocal & TIMEOUT /T 2 >nul & goto :MenuDiskOpt )

:: Сценарий запуска утилиты dfrgui
:DfrGUI
start "" dfrgui
echo.&%ch%      {2f} Запущена {#} утилита {0e}dfrgui {00}.{\n #} & echo.
TIMEOUT /T 5 >nul & endlocal & goto :MenuDiskOpt

:: Сценарий создания раздельных задач обслуживания SSD и HDD
:CreateTasksDisks
echo.
if "%SSDdisk%"=="" (
 %ch%      {4f} Отмена {#} у вас нет {0a}SSD{#} дисков {\n #} & echo.
 if "%~1"=="QuickApply" exit /b
 TIMEOUT /T 4 >nul & endlocal & goto :MenuDiskOpt
)
set /a N=0
set KeyDefrag="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\Defrag"
for /f "tokens=12 delims=\" %%I in (' 2^>nul reg query %KeyDefrag% ^| find /i "\Defrag\" ^| find /i /v "ScheduledDefrag" ') do (
 set /a N+=1
 if "!N!"=="1" (echo.&%ch%     {0b}Удаление{#} всех задач дефрагментации, кроме {0e}ScheduledDefrag {\n #}&echo.)
 schtasks /tn "Microsoft\Windows\Defrag\%%I" /delete /f
)
echo.
schtasks /query /tn "Microsoft\Windows\Defrag\ScheduledDefrag" /xml>"%temp%\TempTask.xml"
schtasks /create /tn "Microsoft\Windows\Defrag\SSD-Trim" /xml "%temp%\TempTask.xml" /f
schtasks /change /tn "Microsoft\Windows\Defrag\SSD-Trim" /tr "%%windir%%\system32\defrag.exe %SSDdisk%-l -h" >nul 2>&1
schtasks /change /tn "Microsoft\Windows\Defrag\SSD-Trim" /Enable >nul 2>&1
schtasks /change /tn "Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
echo.&%ch%      {2f} Создана {#} задача {0a}SSD-Trim{#} с парметрами: {0e}%SSDdisk%-h -l {\n #} & echo.
if not "%HDDdisk%"=="" (
 schtasks /create /tn "Microsoft\Windows\Defrag\HDD-Defrag" /xml "%temp%\TempTask.xml" /f
 schtasks /change /tn "Microsoft\Windows\Defrag\HDD-Defrag" /tr "%%windir%%\system32\defrag.exe %HDDdisk%-h -o" >nul 2>&1
 schtasks /change /tn "Microsoft\Windows\Defrag\HDD-Defrag" /Enable >nul 2>&1
 schtasks /change /tn "Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
 echo.&%ch%      {2f} Создана {#} задача {0a}HDD-Defrag{#} с парметрами: {0e}%HDDdisk%-h -o {\n #} & echo.
)
del "%temp%\TempTask.xml" 2>nul
if "%~1"=="QuickApply" exit /b
TIMEOUT /T -1 & endlocal & goto :MenuDiskOpt

:: Сценарий запуска TRIM, для обнаруженных дисков SSD
:GoTrimSSD
if "%SSDdisk%"=="" (
 echo.&%ch%      {4f} Отмена {#} у вас нет {0a}SSD{#} дисков {\n #}
 TIMEOUT /T 4 >nul & endlocal & goto :MenuDiskOpt
) else (
 echo.
 wmic os get Locale /Value | find "0419" >nul && chcp 1251 >nul
 %windir%\system32\defrag.exe %SSDdisk%/H /L /U
 chcp 65001 >nul
 echo.&%ch%      {2f} Выполнен {#} TRIM ваших {0a}SSD{#} дисков{00}.{\n #}
)
TIMEOUT /T -1 & endlocal & goto :MenuDiskOpt

:: Сценарий запуска дефрагментации, для обнаруженных дисков HDD
:GoDefragHDD
if "%HDDdisk%"=="" (
 echo.&%ch%      {4f} Отмена {#} у вас нет {0e}HDD{#} дисков {\n #}
 TIMEOUT /T 4 >nul & endlocal & goto :MenuDiskOpt
) else (
 echo.
 wmic os get Locale /Value | find "0419" >nul && chcp 1251 >nul
 %windir%\system32\defrag.exe %HDDdisk%/H /O /U
 chcp 65001 >nul
 echo.&%ch%      {2f} Выполнена {#} дефрагментация ваших {0e}HDD{#} дисков{00}.{\n #}
)
TIMEOUT /T -1 & endlocal & goto :MenuDiskOpt

:TaskDef
echo.&%ch%     {0b}Удаление{#} всех задач дефрагментации, кроме {0e}ScheduledDefrag {\n #}&echo.
set KeyDefrag="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\Defrag"
for /f "tokens=12 delims=\" %%I in (' 2^>nul reg query %KeyDefrag% ^| find /i "\Defrag\" ^| find /i /v "ScheduledDefrag" ') do (
 schtasks /tn "Microsoft\Windows\Defrag\%%I" /delete /f
)
echo.
schtasks /change /tn "Microsoft\Windows\Defrag\ScheduledDefrag" /Enable
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%      {2f} Возвращены {#} задачи по умолчанию {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuDiskOpt


:: Сценарий получения информации по жестким дискам в системе, и определения SSD дисков
:DiskInfo
set "DiskLOG=%temp%\Diskpart.log"
set "DiskLOG2=%temp%\Diskpart2.log"
set "WmicLog=%temp%\Wmic.log"
set "HDDLog=%temp%\TempHDD.log"
set "SSDLog=%temp%\TempSSD.log"
del "%WmicLog%" 2>nul & del "%HDDLog%" 2>nul & del "%SSDLog%" 2>nul & del "%DiskLOG2%" 2>nul
echo. list volume | diskpart | findstr /i " Partition Simple " | findstr /i " GB MB " >%DiskLOG%
chcp 866 >nul
for /f "tokens=1*" %%I in (' type "%DiskLOG%" ') do (
 set "LogLine=%%I %%J"
 set "LogLine=!LogLine:* NTFS =!" & set "LogLine=!LogLine:* FAT32 =!" & set "LogLine=!LogLine:* Simple =!" & set "LogLine=!LogLine:* Partition =!"
 for /f "tokens=1,2" %%K in ('echo.!LogLine!^| findstr /i " MB GB "') do (
  set "SizeMB=1"
  if "%%L"=="MB" ( set "SizeMB=%%K" & set "SizeMB=!SizeMB:~3!" )
  set "ExcludeLine=~~~~~~~"
  if "!SizeMB!"=="" set "ExcludeLine=%%K %%L"
  for /f "tokens=3*" %%O in (' echo.%%I %%J ^| find /i /v " !ExcludeLine! " ^| find /i /v " Hidden " ') do (
   echo.%%O %%P>>"%DiskLOG2%"
  )
 )
)
for /f "tokens=1,2*" %%I in (' type "%DiskLOG2%" ') do (
 set "DiskLetter=%%I"
 set "GBDisk=%%J %%K"
 set "GBDisk=!GBDisk:* Simple =!" & set "GBDisk=!GBDisk:* Partition =!"
 set "DiskType=" & set "DiskType2="
 2>nul wmic logicaldisk !DiskLetter!: get FileSystem,Name,VolumeName | find /i "!DiskLetter!:">>%WmicLog%
 type %WmicLog% | find /i "!DiskLetter!:" >nul && ( set "DiskType={0e}HDD{#}"& set "DiskType2=HDD" )
 for %%A in (sat2,sat,auto,ata,scsi,nvme) do (
  set "D=%%A"
  if "%%A"=="sat2" set "D=sat,auto"
  %Smartctl% -d !D! -i !DiskLetter!: |>nul find /i "Solid State Device" && (set "DiskType={0a}SSD{#}"& set "DiskType2=SSD")
 )
 if "!DiskType2!"=="SSD" (<nul set /p Drives=!DiskLetter!: >>%SSDLog%)
 if "!DiskType2!"=="HDD" (<nul set /p Drives=!DiskLetter!: >>%HDDLog%)
 for /f "tokens=1,3*" %%I in (' type "%WmicLog%" ^| find /i "!DiskLetter!:" ') do (
  set "DiskName=%%J %%K"
  set "DiskFS=%%I"
  for /f "tokens=1,2" %%L in ('echo.!GBDisk!') do (
   set "Tab=    "
   if %%L GTR 9 set "Tab=   " & if %%L GTR 99 set "Tab=  " & if %%L GTR 999 set "Tab= "
   set "DiskSize=%%L %%M!Tab!"
   if "!DiskFS!"=="NTFS" set "DiskFS=NTFS "
   %ch%                  !DiskType! {08}Disk ^> {0f}!DiskLetter!: {08}^|{#} !DiskSize! {08}^|{#} !DiskFS! {08}^|{#} !DiskName! {\n #}
  )
 )
)
chcp 65001 >nul
for /f "tokens=*" %%I in (' 2^>nul type %SSDLog% ') do set "SSDdisk=%%I"
for /f "tokens=*" %%I in (' 2^>nul type %HDDLog% ') do set "HDDdisk=%%I"
if "%SSDdisk%"=="" ( set "TrimDisks=У вас нет {0a}SSD{#} дисков"
 ) else ( set "TrimDisks={0d}Выполнить{#} TRIM для {0a}SSD{#} дисков: {0a}%SSDdisk%{#}" )
if "%HDDdisk%"=="" ( set "DfrgDisks=У вас нет {0e}HDD{#} дисков"
 ) else ( set "DfrgDisks={0d}Выполнить{#} дефрагментацию {0e}HDD{#} дисков: {0e}%HDDdisk%{#}" )
del "%DiskLOG%" 2>nul & del "%DiskLOG2%" 2>nul & del "%WmicLog%" 2>nul & del "%HDDLog%" 2>nul & del "%SSDLog%" 2>nul
exit /b


:: Меню запрета и возврата возможности обслуживания
:MenuMaintIn
setlocal EnableDelayedExpansion
:::::   Проверка параметров обслуживания :::::::::::::::::::::::::::
set RegMaint="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled"
for /f "tokens=3" %%I in (' reg query %RegMaint% 2^>nul ') do set /a "ValueMaint=%%I"
if "%ValueMaint%"=="1" ( set "ReplyMaint={0a}Запрещено{#}" ) else ( set "ReplyMaint={0e}Разрешено{#}" )
:::::   Проверка параметров пробуждения компьютера для автообслуживания (MaintIn) :::::::::::::::::::::::::::
set regkeyWake="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp"
for /f "tokens=3" %%I in (' reg query %regkeyWake% 2^>nul ') do set /a "valueWake=%%I"
if "%valueWake%"=="0" ( set "replyWake={0a}Запрещено{#}" ) else ( set "replyWake={0c}Разрешено^^^^^!{#}" )
cls
echo.
%ch% {08}    ======================================== {\n #}
echo.        Настройка Обслуживания системы
%ch% {08}    ======================================== {\n #}
echo.
echo.        В данный момент:
%ch%            Обслуживание: %replyMaint% {00}.{\n #}
%ch%             Пробуждение: %replyWake% {00}.{\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = Запретить обслуживание системы {\n #}
%ch% {0b}    [2]{#} = Запретить пробуждение для обслуживания {\n #}
echo.
%ch% {0e}    [3]{#} = Разрешить обслуживание {0e}(по умолчанию) {\n #}
%ch% {0e}    [4]{#} = Разрешить пробуждение {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню обслуживания {\n #}
echo.
set "input="
set /p input=--- Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню обслуживания - {\n #} & echo.
		       TIMEOUT /T 2 >nul & endlocal & goto :MenuMaintance )
if "%input%"=="1" ( goto :MaintDisable )
if "%input%"=="2" ( goto :WakeOptOFF )
if "%input%"=="3" ( goto :MaintEnable )
if "%input%"=="4" ( goto :WakeOptON
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :MenuMaintIn )

:WakeOptOFF
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /t REG_DWORD /d 0 /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /t REG_DWORD /d 0 /f
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Пробуждение компьютера: {2f} Запрещено {#} - {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuMaintIn

:WakeOptON
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /t REG_DWORD /d 1 /f
%regdelet% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "WakeUp" /f 2>nul
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Пробуждение компьютера: {0a}Разрешено^^^!{#} - {\n #}
TIMEOUT /T -1 & endlocal & goto :MenuMaintIn

:MaintDisable
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Обслуживание Системы: {2f} Запрещено {#} - {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuMaintIn

:MaintEnable
echo.
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /f
%regdelet% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /f 2>nul
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Обслуживание Системы: {0a}Разрешено^^^!{#} - {\n #}
TIMEOUT /T -1 & endlocal & goto :MenuMaintIn


:: Сценарий запуска стандартного обслуживания системы из центра безопасности и обслуживания
:: Со снятием запрета и включением важных зачач, на всякий случай.
:StartMaint
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /f 2>nul
%regdelet% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /f 2>nul
schtasks /Change /TN "Microsoft\Windows\Diagnosis\Scheduled" /Enable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\CleanupTemporaryState" /Enable
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" /Enable
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" /Enable
schtasks /Change /TN "Microsoft\Windows\Chkdsk\ProactiveScan" /Enable
schtasks /Change /TN "Microsoft\Windows\Plug and Play\Plug and Play Cleanup" /Enable
schtasks /Change /TN "Microsoft\Windows\Registry\RegIdleBackup" /Enable
schtasks /Change /TN "Microsoft\Windows\Servicing\StartComponentCleanup" /Enable
schtasks /Change /TN "Microsoft\Windows\Time Synchronization\SynchronizeTime" /Enable
%windir%\system32\MSchedExe.exe Start
echo.&%ch%      {0e}Запущено{#} обслуживание системы {\n #}
echo.     Ожидайте окончания, может продлиться до 2 часов & echo.
TIMEOUT /T 15 >nul & endlocal & goto :MenuMaintance
:StopMaint
%windir%\system32\MSchedExe.exe Stop
echo.&%ch%      {2f} Остановлено {#} обслуживание системы {00}.{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :MenuMaintance





::     ------------------------------------------------
::     ----      Ниже начинается 1 часть: Spy      ----
::     ------------------------------------------------

:Spy
echo.
%ch% {08}    ======================================================================= {\n #}
%ch%         {0b}1 часть: SPY{#} - Отключение слежения, сбора информации и AppStore {\n #}
%ch% {08}    ======================================================================= {\n #}
echo.
if "%~1"=="QuickApply" set "QuickApply=1"


echo.&echo.&echo.
%ch% {0e} ------------------------------------------------------------------ {\n #}
%ch% {0e} --- Остановка и перевод служб по сбору информации для отправки --- {\n #}
%ch% {0e} --- Магазина и приложений AppStore на тип запуска "Отключено": --- {\n #}

echo.&echo.&echo.
%ch% {0b} --- Служба Функциональных возможностей для подключенных пользователей и телеметрия "DiagTrack" --- {\n #}
net stop DiagTrack
sc config DiagTrack start= disabled

echo.&echo.&echo.
%ch% {0b} --- Стандартная служба сборщика центра диагностики Microsoft "diagnosticshub.standardcollector.service" --- {\n #}
net stop diagnosticshub.standardcollector.service
sc config diagnosticshub.standardcollector.service start= disabled

echo.&echo.&echo.
:: Если отключить dmwappushservice, то не включить UWF Unified Write Filter (Объединенный фильтр записи)
:: И поиск обновлений через ЦО будет длиться до 10 минут.
%ch% {0b} --- Служба маршрутизации push-сообщений WAP "dmwappushservice" --- {\n #}
net stop dmwappushservice
sc config dmwappushservice start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба DataCollectionPublishingService "DcpSvc" заливает в облако все данные от приложений --- {\n #}
net stop DcpSvc
sc config DcpSvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба Посредник подключений к сети "NcbService" для Магазина AppStore --- {\n #}
net stop NcbService
sc config NcbService start= disabled

echo.&echo.&echo.
%ch% {0b} --- Службы для Xbox Live --- {\n #}
sc config XblGameSave start= disabled
sc config XblAuthManager start= disabled
sc config XboxNetApiSvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба платформы подключенных устройств CDPSvc --- {\n #}
%ch% {0b} --- Для Xbox SmartGlass --- {\n #}
sc config CDPSvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба Диспетчер скачанных карт "MapsBroker" --- {\n #}
sc config MapsBroker start= disabled

echo.&echo.&echo.
%ch% {0b} --- служба WalletService, "управление вашими финансами" --- {\n #}
sc config WalletService start= disabled


echo.&echo.&echo.
%ch% {0b} --- Отключение "psr.exe" (Problem Steps Recorder - Средство записи действий) --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Совместимость приложений "Отключение средства записи действий" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Не помечать данные для программы по улучшению Windows --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Программа по улучшению качества программного обеспечения Windows "Помечать данные программы по улучшению качества программного обеспечения Windows идентификатором исследования" (отключено)
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "StudyId" /f

echo.&echo.&echo.
%ch% {0b} --- Отключение телеметрии и сбора данных для отправки --- {\n #}
:: Этого параметра нет в ГП, но предлагается для использования самой MS в описании: Configure Windows telemetry in your organization от 04.05.2017
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить программу по улучшению качества программного обеспечения Windows" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Компоненты Windows\Совместимость приложений "Отключение дистанционного отслеживания приложений" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Компоненты Windows\Совместимость приложений "Отключение сборщика перечней" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f
del /f /q %ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
:: Комп\Адм. Шабл\Компоненты Windows\Сборки для сбора данных и предварительные сборки "Не показывать уведомления об отзывах" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Сборки для сбора данных и предварительные сборки "Разрешить телеметрию" (включена, 0 - отсылка только по безопасности)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Сборки для сбора данных и предварительные сборки "Разрешить телеметрию" (включена, 0 - отсылка только по безопасности)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f
:: Запретить телеметрию проверки активации Windows 
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Classes\AppID\slui.exe"" /v ""NoGenTicket"" /t REG_DWORD /d 1 /f"


echo.&echo.&echo.
%ch% {0b} --- Отключение предварительных версий, инсайдерство --- {\n #}
%ch% {0b} --- и скрытие этой вкладки из модерн настроек --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Сборки для сбора данных и предварительные сборки "Переключение пользовательских элементов управления сборками для предварительной оценки" (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Компоненты Windows\Сборки для сбора данных и предварительные сборки "Отключение компонентов и параметров предварительных версий" (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableConfigFlighting" /t REG_DWORD /d 0 /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableExperimentation" /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d 1 /f




echo.&echo.&echo.
%ch% {0b} --- Отключение дополнительного сбора телеметрии, в том числе по "psr.exe" Problem Steps Recorder --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Inventory" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Steps-Recorder" /v "Enabled" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить дополнительный сбор и отправку данных "PerfTrack" и "DiagTrack" --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\PerfTrack" /v "Disabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "Disabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DisableAutomaticTelemetryKeywordReporting" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "TelemetryServiceDisabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks" /v "DisableAsimovUpLoad" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение сбора персональных данных, необходимых для "Кортаны" --- {\n #}
%ch% {0b} --- обучение и персонализацию ввода набираемых текстов: --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Панель управления\Язык и региональные стандарты "Разрешить персонализации ввода"  (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Панель управления\Язык и региональные стандарты\Персонализация рукописного текста "Отключить автоматическое обучение" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Панель управления\Язык и региональные стандарты\Персонализация рукописного текста "Отключить автоматическое обучение" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение сбора и передачи набираемых вами текстов --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить совместный доступ к данным настройки рукописного ввода" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить совместный доступ к данным настройки рукописного ввода" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить отчеты об ошибках распознавания рукописного текста" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить отчеты об ошибках распознавания рукописного текста" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0e} ---------------------------------------------------------------------------------- {\n #}
%ch% {0e} ---------------------------------------------------------------------------------- {\n #}
%ch% {0e} --- Отключение заданий в планировщике по сбору вашей информации для пересылки: --- {\n #}
%ch% {0e} --- А также выключение задач для приложений AppStore и Магазина Windows ---------- {\n #}

@echo.
%ch% {0b} --- Задача, выполняющая сбор данных для SmartScreen --- {\n #}
schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи сбора телеметрических данных программ --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача собирает и загружает данные "SQM" (Software Quality Metrics) --- {\n #}
%ch% {0b} --- для программного обеспечения {\n #}
%ch% {0b} --- Одна из задач для "CEIP" (Customer Experience Improvement Program)  --- {\n #}
%ch% {0b} --- программа улучшения качества программного обеспечения {\n #}
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи для AppStore --- {\n #}
::   задача "CreateObjectTask" нужна для создания локальной учетки на этапе установки ОС
::   Так же для создания учетки в рабочей ОС через модерн аплет настроек.
schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Clip\License Validation" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи "CEIP" Программы улучшения качества программного обеспечения --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи SIUF (System Initiated User Feedback) Обратная связь с пользователями --- {\n #}
%ch% {0b} --- Помогает понять Microsoft, что вы думаете о различных функциях в операционной системе --- {\n #}
%ch% {0b} --- И то, что вы, возможно, захотите увидеть в будущем --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи проверки и обновления Карт AppStore --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Maps\MapsToastTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Maps\MapsUpdateTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача сборщика полных сведений компьютера и сети --- {\n #}
schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача для "CEIP" --- {\n #}
schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи для синхронизации AppSrore приложений --- {\n #}
schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача автоматически обновляет приложения Магазина Windows --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::   Отключение задач с правами SYSTEM, с помощью файла "nircmdc.exe"   :::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Отключение задач с правами "SYSTEM" с помощью файла "nircmdc.exe" {\n #}
%ch% {0b}     Задачи регистрации, доступа и синхронизации с устройствами {\n #} & echo.
Call :SetTaskInSystem "Microsoft\Windows\SettingSync\BackgroundUpLoadTask" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\Device Setup\Metadata Refresh" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\HandleCommand" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceConnectedToNetwork" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic1" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic6" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceScreenOnOff" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" "/Disable"





:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Отключение Задач и логов по телеметрии Office 2013 и 2016 --- {\n #}
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack2016" /Disable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable
schtasks /Change /TN "\Microsoft\Office\Office 15 Subscription Heartbeat" /Disable
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" /v "Start" /t REG_DWORD /d 0 /f )
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" ( reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" /v "Enabled" /t REG_DWORD /d 0 /f )
if exist "%WinDir%\System32\Winevt\Logs\AirSpaceChannel.etl" del /f /q "%WinDir%\System32\Winevt\Logs\AirSpaceChannel.etl"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Отключение задач телеметрии драйверов NVIDIA --- {\n #}
set "NvidiaNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "NvTm" /d ^| find /i "Path" ^| findstr /i "NvTmRepOnLogon_ NvTmRep_ NvTmMon_"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 if not "%%~J"=="Disabled" ( schtasks /Change /TN "%%~I" /Disable & set "NvidiaNo=0" ) else ( echo.       Задача уже отключена: "%%~I" & set "NvidiaNo=0" )))
if "%NvidiaNo%"=="1" %ch%        Задач {0a}Нет{\n #}
echo.
%ch% {0b} --- Отключение службы телеметрии NVIDIA GeForce Experience --- {\n #}
reg query "HKLM\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" >nul 2>&1
if "%errorlevel%"=="0" (
 net stop NvTelemetryContainer
 sc config NvTelemetryContainer start= disabled
) else (%ch%        Службы {0a}Нет{#}{\n #})
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  Установка значений конфиденциальности в Modern аплете настроек.  ::
	::  Они предназначены для всех Modern аплетов и AppStore хлама       ::
	::  Эти установки влияют только на текущего пользователя,            ::
	::  и могут быть в ручную изменены в Modern настройках,              ::
	::  кроме некоторых, которые M$ скрыло от пользователя!!!            ::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&echo.&echo.
%ch% {0b} --- Отключить использование вашего ID для получения рекламы --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /f
if "%xOS%"=="x64" (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
)

echo.&echo.&echo.
%ch% {0b} --- Отключить SmartScreen --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к списку языков --- {\n #}
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Запретить приложеням AppStore на др. устройствах работать на этом устройстве --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "BluetoothPolicy" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к Веб Камере --- {\n #}
@set "Perskey={E5323777-F976-4f5b-9B55-B94699C46E44}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к Микрофону --- {\n #}
@set "Perskey={2EEF81BE-33FA-4800-9670-1CD474972C3F}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к Вашей Учетной записи --- {\n #}
@set "Perskey={C1D23ACC-752B-43E5-8448-8D0E519CD6D6}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всем приложениям AppStore к контактам, этой опции нет в аплете настроек --- {\n #}
@set "Perskey={7D7E8402-7C54-4821-A34E-AEEFD62DED93}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к календарю --- {\n #}
@set "Perskey={D89823BA-7180-4B81-B50C-7E471E6121A3}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к сообщениям, СМС, ММС --- {\n #}
@set "Perskey={992AFA70-6F47-4148-B3E9-3003349C1548}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить интерфейс для доступа приложений AppStore ко всем сообщениям, этой опции нет в аплете настроек --- {\n #}
@set "Perskey={21157C1F-2651-4CC1-90CA-1F28B02263F6}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложений AppStore к Радиомодулям --- {\n #}
@set "Perskey={A8804298-2D5F-42E3-9531-9C8C39EB29CE}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить синхронизацию с устройствами для приложений AppStore --- {\n #}
@set "Perskey=LooselyCoupled"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d LooselyCoupled /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить формирование отзывов --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всем приложениям AppStore к языковым настройкам, этой опции нет в аплете настроек --- {\n #}
@set "Perskey={BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ приложениям AppStore к определению расположения, этой опции нет в аплете настроек --- {\n #}
@set "Perskey={E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всех приложений AppStore к телефонным звонкам "Скрытые" --- {\n #}
@set "Perskey={235B668D-B2AC-4864-B49C-ED1084F6C9D3}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всех приложений AppStore к журналу вызовов --- {\n #}
@set "Perskey={8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всех приложений AppStore к уведомлениям пользователя --- {\n #}
@set "Perskey={52079E78-A92B-413F-B213-E8FE35712E72}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f

echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всех приложений AppStore к E-mail --- {\n #}
@set "Perskey={9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ всех приложений AppStore к Мероприятиям "Скрытые" --- {\n #}
@set "Perskey={9D9E0118-1807-4F2E-96E4-2CE57142E196}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Deny /f




echo.&echo.&echo.
%ch% {0b} --- Запрет доступа к личным данным для всех AppStore пакетов, указанных индивидуально: --- {\n #}
%ch% {0b} --- этих опций нет в аплете настроек --- {\n #}
for /f %%i in (' reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess" /s /k /f * ^| find /i "S-1-15" ^| find "{" ') do (
	reg add %%i /v "Type" /t REG_SZ /d InterfaceClass /f
	reg add %%i /v "Value" /t REG_SZ /d Deny /f )
for /f %%i in (' reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess" /s /k /f * ^| find /i "S-1-15" ^| find "LooselyCoupled" ') do (
	reg add %%i /v "Type" /t REG_SZ /d LooselyCoupled /f
	reg add %%i /v "Value" /t REG_SZ /d Deny /f )



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Запретить фоновую работу Аплета "настроек" Windows  ---  {\n #}
%ch% {0b} --- Переключатель должен находится в: Параметры -^> Конфиденциальность -^> Фоновые приложения...  {\n #}
setlocal
set regpath="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
for /f "delims=\ tokens=7" %%i in (' reg query %regpath% /s /f "immersivecontrolpanel" 2^>nul ') do set "reply=%%i"
if not "%reply%"=="" (
	reg add "%regpath:~1,-1%\%reply%" /v "Disabled" /t REG_DWORD /d 1 /f
	reg add "%regpath:~1,-1%\%reply%" /v "DisabledByUser" /t REG_DWORD /d 1 /f
	reg add "%regpath:~1,-1%\%reply%" /v "IgnoreBatterySaver" /t REG_DWORD /d 0 /f
	) else ( echo.&echo.     Отмена, ключ "immersivecontrolpanel" не существует! & echo. )
endlocal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



cd /d "%~dp0"
if "%QuickApply%"=="1" set "QuickApply=" & exit /b

if "%choice%"=="1" (
 rem Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
 Call :LGPO_FILE_APPLY

 echo. & echo. & echo.
 %ch% {08}    ===================================== {\n #}
 %ch%         Завершена только {0b}1 часть: SPY     {\n #}
 %ch% {08}    ===================================== {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :Menu
) else (
 echo.
 %ch% {08}    ============================== {\n #}
 %ch%         Завершена {0b}1 часть: SPY     {\n #}
 %ch% {08}    ============================== {\n #}
 echo.
 goto :Settings
)


::     -----------------------------------------------
::     ---    Ниже начинается 2 часть: Settings    ---
::     -----------------------------------------------

:Settings
echo.
%ch% {08}    ============================================================ {\n #}
%ch%         {0b}2 часть: Settings{#}  -  Применение настроек Windows 10 {\n #}
%ch% {08}    ============================================================ {\n #}
echo.
if "%~1"=="QuickApply" set "QuickApply=1"


@echo.&@echo.
%ch% {0e} ---------------------------------------------------------------------------------------------------- {\n #}
%ch% {0e} --- Остановка и перевод необязательных служб по обслуживанию системы на тип запуска "Отключено": --- {\n #}

echo.&echo.&echo.
%ch% {0b} --- Служба общих сетевых ресурсов проигрывателя Windows Media "WMPNetworkSvc" --- {\n #}
net stop WMPNetworkSvc
sc config WMPNetworkSvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба Немедленные подключения Windows для Windows Connect Now, --- {\n #}
%ch% {0b} --- настраивает параметры точки доступа или WiFi --- {\n #}
%ch% {0b} --- Используется так же картаной --- {\n #}
net stop wcncsvc
sc config wcncsvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба наблюдения за датчиками "SensrSvc" (кооректировка яркости дисплея, поворота экрана и т.д.) --- {\n #}
net stop SensrSvc
sc config SensrSvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Биометрическая служба Windows "WbioSrvc" --- {\n #}
sc config WbioSrvc start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба "Retail Demo" "скрытый режим для розничной торговли" --- {\n #}
sc config RetailDemo start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба "Служба датчиков" (датчики поворота дисплея, местоположения и т.д.) --- {\n #}
sc config SensorService start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба "Служба данных датчиков" --- {\n #}
sc config SensorDataService start= disabled

echo.&echo.&echo.
%ch% {0b} --- Служба Windows License Manager для Windows AppStore --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LicenseManager" /v "Start" /t REG_DWORD /d 4 /f

echo.&echo.&echo.
%ch% {0b} --- Служба Географического расположения для AppStore --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 4 /f

echo.&echo.&echo.
%ch% {0b} --- Служба push-уведомлений Windows для приложений AppStore --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d 4 /f

echo.&echo.&echo.
%ch% {0b} --- Помощник по входу в учетную запись Майкрософт, необходим для магазина Windows --- {\n #}
:::::   Если отключить, невозможно будет создать даже локальную учетку через Модерн аплет настроек
:::::   Но через управление компьютером или "control userpasswords2" можно будет создать.
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wlidsvc" /v "Start" /t REG_DWORD /d 4 /f



echo.&echo.&echo.
%ch% {0e} --------------------------------------------------------------------------------- {\n #}
%ch% {0e} --------------------------------------------------------------------------------- {\n #}
%ch% {0e} --- Отключение необязательных заданий в планировщике по обслуживанию системы: --- {\n #}

@echo.
%ch% {0b} --- Задача очистки системного диска во время простоя (задолбала постоянно насиловать диск) --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskCleanup\SilentCleanup" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача оценки объема использования диска --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable

@echo.
%ch% {0b} --- Задача для "Storage Sense" перемещение Modern Apps на другой диск по необходимости --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\StorageSense" /Disable

@echo.
%ch% {0b} --- Задачи Проверки томов на отказоустойчивость --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача копирования файлов пользователя в "резервное" расположение (меню предыдущие версии файлов) --- {\n #}
%ch% {0b} --- При использовании службы архивации --- {\n #}
schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача измеряет быстродействие и возможности системы --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи Обслуживания памяти во время простоя и при ошибках --- {\n #}
schtasks /Change /TN "Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /Disable
schtasks /Change /TN "Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача анализирования энергопотребления системы --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи контроля и выполнения семейной безопасности --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача отправки отчетов об ошибках --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable

	:::::::::::::::::::::::::::::::::::::::::::
	::::::::   Дополнительные задачи   ::::::::
	:::::::::::::::::::::::::::::::::::::::::::

echo.&echo.&echo.
%ch% {0b} --- Задача очистки контента Retail Demo --- {\n #}
schtasks /Change /TN "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи уведомлений о вашем расположении: --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Location\Notifications" /Disable
schtasks /Change /TN "Microsoft\Windows\Location\WindowsActionDialog" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача анализа метаданных мобильной сети --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача веб-сайта инфраструктуры диагностики Windows --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WDI\ResolutionHost" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача обновления новых файлов в библиотеке мультимедиа --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи регистрации и проверки ссылок от приложений  --- {\n #}
%ch% {0b} --- В Windows appUriHandler, для получения поддержки от разработчиков  --- {\n #}
schtasks /Change /TN "Microsoft\Windows\ApplicationData\appuriverifierinstall" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\appuriverifierdaily" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача сбора и отправки данных об устройствах --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Device Information\Device" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи Xbox --- {\n #}
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача DUSM (Data Usage Subscription Management) для мобильного интернета --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DUSM\dusmtask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи по детализации ошибок --- {\n #}
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Disable
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача выдачи временных лицензий для Приложений Магазина --- {\n #}
schtasks /Change /TN "Microsoft\Windows\License Manager\TempSignedLicenseExchange" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача по согласованию пакетов во время SYSPREP и загрузки "ProvTool.exe" --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Management\Provisioning\Logon" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи фонового взаимодействия через WiFi --- {\n #}
schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Disable
schtasks /Change /TN "Microsoft\Windows\WCM\WiFiTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задачи обслуживания дисковых пространств (аналог RAID, виртуальные диски) --- {\n #}
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceAgentTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceManagerTask" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача загрузки голосовых моделей --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Disable






	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::::::::   Настройка системных компонентов и программ   ::::::::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&echo.&echo.
%ch% {0b} --- Отключение получения обновлений и телеметрии для средства удаления "вирусов" ---  {\n #}
:: Этих параметров нет в редакторе ГП
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d 1 /f


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&echo.&echo.
%ch% {0b} --- Полное отключение OneDrive --- {\n #}
TASKKILL /F /IM OneDrive.exe /T
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f
reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf090004d /f
reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf090004d /f
if "%xOS%"=="x64" (
 echo.
 %ch% {0b} --- Дополнительно для x64 по OneDrive --- {\n #}
 reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
 reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf090004d /f
 reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
 reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf090004d /f
)
echo.
set "OneDriveTaskNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "OneDrive" /d ^| find /i "Path" ^| find /i "OneDrive"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 if not "%%~J"=="Disabled" ( schtasks /Change /TN "%%~I" /Disable & set "OneDriveTaskNo=0" ) else ( echo.       Задача: "%%~I" уже отключена & set "OneDriveTaskNo=0" )))
if "%OneDriveTaskNo%"=="1" %ch%        Задач OneDrive {0a}Нет{\n #}
echo.

echo.&echo.&echo.
%ch% {0b} --- Запрет использования OneDrive --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\OneDrive "Запретить использование OneDrive для хранения файлов" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\OneDrive "Запретить синхронизацию файлов OneDrive через лимитные подключения" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить уведомления поставщика синхронизации (реклама в проводнике от OneDrive) --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение служб синхронизации, так же необходимых и для OneDrive --- {\n #}
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "CDPUserSvc" ^| find /i "CDPUserSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "OneSyncSvc" ^| find /i "OneSyncSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "PimIndexMaintenanceSvc" ^| find /i "PimIndexMaintenanceSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UnistoreSvc" ^| find /i "UnistoreSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UserDataSvc" ^| find /i "UserDataSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "MessagingService" ^| find /i "MessagingService" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "WpnUserService" ^| find /i "WpnUserService" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 4 /f )
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



echo.&echo.&echo.
%ch% {0b} --- Отключить автопередачу паролей к своим WiFi на сервер Microsoft (WiFiSense)--- {\n #}
%ch% {0b} --- и запретить автоподключение к WiFi без пароля и от моих контактов --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d 0 /f
@echo.
%ch% {0b} --- Запрет автоподключения к левым WiFi всем пользователям, найденных в этой ветке {\n #}
%ch% {0b} --- 828 = Все отключено; 893 = Все включено; {\n #}
%ch% {0b} --- 829 = только автоподключение к WiFi без пароля; 892 = только автоподключение к WiFi от ваших контактов {\n #}
@for /f %%i in (' reg query "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" ^| find "S-1" ') do (
	reg add %%i /v "FeatureStates" /t REG_DWORD /d 828 /f )


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ в интернет службе защиты аудио - Windows Media Digital Rights Management (DRM) --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Управление цифровыми правами Windows Media "Запретить доступ к Интернету для Windows Media DRM" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение определения вашего расположения для AppStore и Других программ (Геозона)--- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Расположение и датчики "Отключить расположение" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Расположение и датчики "Отключить расположение со сценариями" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Расположение и датчики "Отключить датчики" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение возможности использования web камеры на Лок-скрине. --- {\n #}
:: Комп\Адм. Шабл\Панель управления\Персонализация "Запретить включение камеры с экрана блокировки" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить Фрейм Сервер M$, решает проблему с неработающей веб камерой. --- {\n #}
%ch% {0b} --- Фрейм Сервер Позволяет получать доступ к одной камере нескольким приложениям. --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /t REG_DWORD /d 0 /f
if "%xOS%"=="x64" (
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /t REG_DWORD /d 0 /f )
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FrameServer" /V "Start" /t REG_DWORD /d 4 /f

echo.&echo.&echo.
%ch% {0b} --- Скрытие рекламы Windows Update из модерн настроек --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "HideMCTLink" /t REG_DWORD /d 1 /f


	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::   Параметры для Групповой Политики                              :::::
	:::::   Будут добавлены в ГП и Будут отслеживаться файлом проверки    :::::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&echo.&echo.
%ch% {0b} --- Отключить SmartScreen, отключится и его проверка центром "безопасность и обслуживание" --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Проводник "Настроить Windows SmartScreen" (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить отправку отчетов об ошибках: --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Отчеты об ошибках Windows "Отключить отчеты об ошибках Windows" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Отчеты об ошибках Windows "Не отправлять дополнительные данные" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Отчеты об ошибках Windows "Отключить отчеты об ошибках Windows" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Отчеты об ошибках Windows "Не отправлять дополнительные данные" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить отчеты об ошибках Windows" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить анализ и отправку данных "PerfTrack" через SQM  --- {\n #}
:: Комп\Адм. Шабл\Система\Диагностика\Быстродействие Windows PerfTrack "Включить или отключить PerfTrack" (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить средство диагностики "MSDT" для технической поддержки  --- {\n #}
:: Комп\Адм. Шабл\Система\Диагностика\Средство диагностики службы технической поддержки Майкрософт "Средство диагностики службы технической поддержки Майкрософт" (отключена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить синхронизацию: --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Синхронизация параметров "Не синхронизировать" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d 2 /f
:: Комп\Адм. Шабл\Компоненты Windows\Синхронизация параметров "Не синхронизировать" (Разрешить пользователям включать синхронизацию галачка не стоит)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d 1 /f
:: Этого параметра нет в шаблоне ГП, но параметр есть в реестре.
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "EnableBackupForWin8Apps" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- IE --- {\n #}
%ch% {0b} --- Запретить участие в программе улучшения качества для IE --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Internet Explorer "Запретить участие в программе улучшения качества программного обеспечения" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Internet Explorer "Запретить участие в программе улучшения качества программного обеспечения" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d 0 /f
%ch% {0b} --- Отключить рекомендуемые сайты для IE --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Internet Explorer "Включить рекомендуемые сайты" (отключить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Internet Explorer "Включить рекомендуемые сайты" (отключить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d 0 /f
%ch% {0b} --- Отключить предостовление улучшеных вариантов поиска --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Internet Explorer "Разрешить службам Майкрософт предоставлять пользователю ..." (отключить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Internet Explorer "Разрешить службам Майкрософт предоставлять пользователю ..." (отключить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /t REG_DWORD /d 0 /f

%ch% {0b} --- Запретить загружать инструменты в режиме InPrivate --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Internet Explorer\Конфиденциальность "Запретить компьютеру загружать панели инструментов ..." (Включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Internet Explorer\Конфиденциальность "Запретить компьютеру загружать панели инструментов ..." (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /t REG_DWORD /d 1 /f
%ch% {0b} --- Всегда отправлять заголовок "не отслеживать" --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Internet Explorer\Панель управления браузером\Вкладка 'Дополнительно' "Всегда отправлять заголовок 'Не отслеживать'" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Internet Explorer\Панель управления браузером\Вкладка 'Дополнительно' "Всегда отправлять заголовок 'Не отслеживать'" (включено)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Выключить синхронизацию RSS-каналов в фоновом режиме --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\RSS-каналы "Выключить синхронизацию в фоновом режиме для веб-каналов и веб-фрагментов" (включен)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\RSS-каналы "Выключить синхронизацию в фоновом режиме для веб-каналов и веб-фрагментов" (включен)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Запретить использование биометрии --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Биометрия "Разрешение использования биометрии" (отключить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить Windows Hellow для бизнеса и Использование биометрии --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Windows Hello для бизнеса "Использовать Windows Hello для бизнеса" (отключить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить проверку новостей по поддержке Windows Mail --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Windows Mail "Отключить проверку серверов новостей почтой Windows" (включена)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Windows Mail "Отключить проверку серверов новостей почтой Windows" (включена)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключить Программу Windows Mail --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Windows Mail "Выключить приложение почта Windows" (включено)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /t REG_DWORD /d 0 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Windows Mail "Выключить приложение почта Windows" (включено)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Запретить запуск Windows Messenger и программу улучшения --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Windows Messenger "Запретить запуск Windows Messenger" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "PreventRun" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить программу улучшения качества программного обеспечения Windows Messenger" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d 2 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Windows Messenger "Запретить запуск Windows Messenger" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "PreventRun" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить программу улучшения качества программного обеспечения Windows Messenger" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d 2 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить автоскачивание данных карт и незапрошенный трафик --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Карты "Выключить автоматическое скачивание и обновление данных карт" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Компоненты Windows\Карты "Отключить незапрошенный сетевой трафик на странице параметров 'Автономные карты'" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Запретить синхронизацию приложений --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Конфиденциальность приложения "Разрешить синхронизацию приложений для Windows с устройствами" (включить - запретить принудительно)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsSyncWithDevices" /t REG_DWORD /d 2 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить все приложения из магазина и магазин --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Магазин "Отключить все приложения из Магазина Windows" (отключить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Магазин "Отключить приложение Магазин" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d 1 /f
:: Отключение обновления Магазина Windows
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d 2 /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d 2 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение Записи игр GAME Bar, WIN+G --- {\n #}
:: Этого параметра нет в ГП
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Выключить загрузку сведений по игре --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Обозреватель игр "Выключить загрузку сведений об игре" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "DownloadGameInfo" /t REG_DWORD /d 0 /f
%ch% {0b} --- Отключить обновления игр --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Обозреватель игр "Отключить обновления игр" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "GameUpdateOptions" /t REG_DWORD /d 0 /f
%ch% {0b} --- Не отслеживать время последнего сеанса игр --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Обозреватель игр "Не отслеживать время последнего сеанса игр в папке 'Игры'" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "ListRecentlyPlayed" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить возможности облака Microsoft и не показывать советы --- {\n #}
:: Комп\Адм. Шабл\Компоненты Windows\Содержимое облака "Выключить возможности потребителя Майкрософт" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f
:: Комп\Адм. Шабл\Компоненты Windows\Содержимое облака "Не показывать советы по использованию Windows" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить идентификатор объявлений для профилей пльзователей --- {\n #}
:: Комп\Адм. Шабл\Система\Профили пользователей "Отключить идентификатор объявлений" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить Вэб публикацию в списке задач для файлов --- {\n #}
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить веб-публикацию в списке задач для файлов и папок" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить веб-публикацию в списке задач для файлов и папок" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить доступ к магазину --- {\n #}
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить доступ к Магазину" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить доступ к Магазину" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить обновление файлов помощника по поиску --- {\n #}
:: Комп\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить обновление файлов содержимого помощника по поиску" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\SearchCompanion" /v "DisableContentFileUpdates" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Не хранить сведения о зоне происхождения файлов --- {\n #}
:: ГП: Конфиг. Пользователя > адм. шаблоны > компоненты Windows > диспетчер вложений
:: Параметр "LowRiskFileTypes" нужен для отключения запроса при уже сохраненной зоне происхождения файла.
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 1 /f
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ^
".7z;.zip;.rar;.iso;.nfo;.txt;.inf;.ini;.xml;.pdf;.bat;.com;.cmd;.reg;.msi;.exe;.htm;.html;.gif;.png;.bmp;.jpg;.avi;^
.mpg;.mpeg;.mov;.mkv;.flv;.srt;.flac;.mp3;.m3u;.cue;.wav;.chm;.mdb;" /f


echo.&echo.&echo.
%ch% {0b} --- Отключить автоматическое исправление слов с ошибками --- {\n #}
:: Пользователи\Адм. Шабл\Панель управления\Язык и региональные стандарты "Отключить автоматическое исправление слов с ошибками" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffAutocorrectMisspelledWords" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключить выделение слов с ошибками --- {\n #}
:: Пользователи\Адм. Шабл\Панель управления\Язык и региональные стандарты "Отключить выделение слов с ошибками" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffHighlightMisspelledWords" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключить прогнозирование текста при вводе --- {\n #}
:: Пользователи\Адм. Шабл\Панель управления\Язык и региональные стандарты "Отключить прогнозирование текста при вводе" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffOfferTextPredictions" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отключить рейтинг справки --- {\n #}
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключение рейтинга справки" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключить программу улучшения справки --- {\n #}
:: Пользователи\Адм. Шабл\Система\Управление связью через Интернет\Параметры связи через Интернет "Отключить программу улучшения справки" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoImplicitFeedback" /t REG_DWORD /d 1 /f




	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::    Ниже идут Дополнительные параметры для Групповой Политики     :::::
	:::::    Будут добавлены в ГП и будут отслеживаться файлом проверки    :::::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ГП: Компоненты Windows/Internet Explorer/Конфиденциальность
%ch% {0b} --- Отключить сбор данных фильтрации InPrivate --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableLogging" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Internet Explorer/Меню браузера
%ch% {0b} --- Отключить возможность отправки отчетов об ошибках --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "NoReportSiteProblems" /t REG_SZ /d "yes" /f

:: ГП: Компоненты Windows/Встроенная справка
%ch% {0b} --- Отключение активной справки --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoActiveHelp" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Звукозапись
%ch% {0b} --- Запретить выполнение программы "Звукозапись" --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\SoundRecorder" /v "Soundrec" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Календарь Windows
%ch% {0b} --- Выключить календарь Windows --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Windows" /v "TurnOffWinCal" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Платформа защиты программного обеспечения
%ch% {0b} --- Отключение веб-проверки AVS (телеметрия активации) --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Подключить
%ch% {0b} --- Не разрешать проекцию на этот компьютер, с др. устройств, кроме ручной --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Connect" /v "AllowProjectionToPC" /t REG_DWORD /d 0 /f

:: ГП: Компоненты Windows/Цифровой ящик
%ch% {0b} --- Не разрешать работу цифрового ящика Windows Marketplace --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Digital Locker" /v "DoNotRunDigitalLocker" /t REG_DWORD /d 1 /f

:: ГП: Система/Диагностика/Средство диагностики службы технической поддержки Майкрософт
%ch% {0b} --- Запретить сбор и передачу данных поддержке Майкрософт --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "DisableQueryRemoteServer" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить Средства диагностики поддержки Майкрософт --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "DownloadToolsEnabled" /t REG_DWORD /d 0 /f

:: ГП: Компоненты Windows/Проводник
%ch% {0b} --- Отключить кэширование эскизов в скрытых файлах thumbs.db --- {\n #}
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableThumbsDBOnNetworkFolders" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключить кэширование эскизов изображений --- {\n #}
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThumbnailCache" /t REG_DWORD /d 1 /f

:: ГП: Компоненты Windows/Содержимое облака
%ch% {0b} --- Отключить все функции SpotLight на экране блокировки --- {\n #}
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /t REG_DWORD /d 1 /f

:: ГП: Пользователи\Адм. Шабл.\Меню «Пуск» и панель задач/Уведомления
%ch% {0b} --- Отключить уведомления и обновления плиток в меню пуск --- {\n #}
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /t REG_DWORD /d 1 /f



	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  Отключение синхронизации персональных настроек Windows,      ::
	::  таких как пароли, настройки браузера, оформление и прочее,   ::
	::  необходимых для аккаунта M$, кортаны и др. хлама,            ::
	::  этих опций нет в Modern аплете настроек                      ::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Отключение синхронизации персональных настроек программ и Windows --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d 5 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\DesktopTheme" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d 0 /f
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



echo.&echo.&echo.
%ch% {0b} --- Отключение проверки правописания, выделения ошибок и прогнозирования --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /t REG_DWORD /d 0 /f
:: Комп\Адм. Шабл\Компоненты Windows\Планшет\Панель ввода "Отключить прогнозирование текста" (включить)
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /t REG_DWORD /d 1 /f
:: Пользователи\Адм. Шабл\Компоненты Windows\Планшет\Панель ввода "Отключить прогнозирование текста" (включить)
Call :LGPO_FILE reg add "HKCU\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /t REG_DWORD /d 1 /f




	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::   Все, что ниже этого текста сейчас, и что будет добавлено в будущем,      :::::
	:::::   не будет вноситься в файл проверки! В том числе и отдельные меню         :::::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




echo.&echo.&echo.
%ch% {0b} --- Открытие проводника на разделе "Этот компьютер" --- {\n #}
%ch% {0b} --- 1 = Этот компьютер, 2 = Панель быстрого доступа --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отображение значка "Этот компьютер" на рабочем столе --- {\n #}
%ch% {0b} --- 0 = Включить, 1 = Скрыть ---  {\n #}
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение залипания клавиши SHIFT после 5 нажатий --- {\n #}
%ch% {0b} --- 506 = Выкл, 510 = Включить (По умолчанию) ---  {\n #}
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f


echo.&echo.&echo.
%ch% {0b} --- Отображать скрытые файлы и папки в проводнике --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Отображать расширения файлов в проводнике --- {\n #}
%ch% {0b} --- 0 = Отображать --- {\n #}
%ch% {0b} --- 1 = Скрывать --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Отключение отображения вкладки "предыдущие версии" в свойствах файлов по ПКМ меню --- {\n #}
%ch% {0b} --- Нужна при использовании архивации файлов --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "NoPreviousVersionsPage" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Скрыть опции Bitlocker из ПКМ меню и проводника --- {\n #}
%ch% {0b} --- Управлять будет можно только через панель управления --- {\n #}
reg add "HKEY_CLASSES_ROOT\Drive\shell\change-passphrase" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\change-pin" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\manage-bde" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\resume-bde-elev" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\resume-bde" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\encrypt-bde-elev" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\encrypt-bde" /v "LegacyDisable" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\Drive\shell\unlock-bde" /v "LegacyDisable" /t REG_SZ /d "" /f


echo.&echo.&echo.
%ch% {0b} --- Включаем "NumLock" у всех, в том числе для Логин-Скрина (1 строка) ---	 {\n #}
reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
reg add "HKEY_USERS\S-1-5-18\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
reg add "HKEY_USERS\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
reg add "HKEY_USERS\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f


echo.&echo.&echo.
%ch% {0b} --- Использование 100% качества картинки, --- {\n #}
%ch% {0b} --- при установке обоев рабочего стола, по умолчанию 85% {\n #}
reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 100 /f

echo.&echo.&echo.
%ch% {0b} --- Настройка панели управления на просмотр в виде мелких значков: --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "StartupPage" /t REG_DWORD /d 1 /f



echo.&echo.&echo.
%ch% {0b} --- Настройки Windows Media Player 12 (Возврата параметров не предусмотрено) --- {\n #}
set WMPKey="HKCU\Software\Microsoft\MediaPlayer\Preferences"
:: Принять лицензионное соглашение
reg add %WMPKey% /v "AcceptedPrivacyStatement" /t REG_DWORD /d 1 /f
:: Не добавлять файлы видео, найденные в библиотеке изображений
reg add %WMPKey% /v "AddVideosFromPicturesLibrary" /t REG_DWORD /d 0 /f
:: Отключить автоматическое добавление музыки в библиотеку
reg add %WMPKey% /v "AutoAddMusicToLibrary" /t REG_DWORD /d 0 /f
:: Не удалять файлы с компьютера при удалении из библиотеки
reg add %WMPKey% /v "DeleteRemovesFromComputer" /t REG_DWORD /d 0 /f
:: Запретить автоматическую проверку лицензий защищённых файлов
reg add %WMPKey% /v "DisableLicenseRefresh" /t REG_DWORD /d 1 /f
:: Проигрыватель уже запускался
reg add %WMPKey% /v "FirstRun" /t REG_DWORD /d 0 /f
:: Не сохранять оценки в файлах мультимедиа
reg add %WMPKey% /v "FlushRatingsToFiles" /t REG_DWORD /d 0 /f
:: Не обновлять содержимое библиотеки при первом запуске
reg add %WMPKey% /v "LibraryHasBeenRun" /t REG_DWORD /d 1 /f
:: Не показывать сведения о мультимедиа из Интернета и не обновлять файлы
reg add %WMPKey% /v "MetadataRetrieval" /t REG_DWORD /d 0 /f
:: Отключить загрузку лицензий на использование файлов мультимедиа
reg add %WMPKey% /v "SilentAcquisition" /t REG_DWORD /d 0 /f
:: Не устанавливать автоматически часы на устройсвтах
reg add %WMPKey% /v "SilentDRMConfiguration" /t REG_DWORD /d 0 /f
:: Не сохранять историю открытых файлов
reg add %WMPKey% /v "DisableMRU" /t REG_DWORD /d 1 /f
:: Не отправлять данные об использовании проигрывателя в Microsoft
reg add %WMPKey% /v "UsageTracking" /t REG_DWORD /d 0 /f
:: Отключить идентификацию Windows Media Player на интернет-сайтах
reg add %WMPKey% /v "SendUserGUID" /t REG_BINARY /d 00 /f
:: Отключить обновление Windows Media Player
reg add %WMPKey% /v "AskMeAgain" /t REG_SZ /d No /f
:: Не использовать Windows Media Player в on-line справочниках
reg add %WMPKey% /v "StartInMediaGuide" /t REG_DWORD /d 0 /f
:: Отключить "Проигрыватель по размеру видео при запуске"
reg add %WMPKey% /v "SnapToVideoV11" /t REG_DWORD /d 0 /f
:: доп. настройка
reg add %WMPKey% /v "MLSChangeIndexMusic" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
%ch% {0b} --- Настройки Internet Explorer 11  (Возврата параметров не предусмотрено) --- {\n #}
:: Отключить мастер первого запуска
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10RunOncePerInstallCompleted" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10TourNoShow" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10TourShown" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10TourShownTime" /t REG_BINARY /d 00 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10RunOnceCompletionTime" /t REG_BINARY /d 00 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10RecommendedSettingsNo" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "IE10RunOnceLastShown_TIMESTAMP" /t REG_BINARY /d 00 /f
:: Предотвратить повторное использование окна Internet Explorer
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "AllowWindowReuse" /t REG_DWORD /d 0 /f
:: Отключить отладку скриптов
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Disable Script Debugger" /t REG_SZ /d yes /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "DisableScriptDebuggerIE" /t REG_SZ /d yes /f
:: Выключить автозаполнение форм
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Use FormSuggest" /t REG_SZ /d no /f
:: Не предлагать Internet Explorer использовать по умолчанию
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Check_Associations" /t REG_SZ /d no /f
:: Пустая страница по умолчанию в Internet Explorer
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d about:Tabs /f
:: Отключить встроенную проверку подлинности Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "EnableNegotiate" /t REG_DWORD /d 0 /f
:: Отключить предупреждение о начале просмотра веб-страницы через безопасное соединение
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "WarnonZoneCrossing" /t REG_DWORD /d 0 /f
:: Кэш для временных файлов = 250Мб
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content" /v "CacheLimit" /t REG_DWORD /d 256000 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Content" /v "CacheLimit" /t REG_DWORD /d 256000 /f
:: Отключить предупреждение "Информация переданная через Интернет, может стать доступной другим пользователям"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v "1601" /t REG_DWORD /d 0 /f
:: Отключить сообщение о возможности использования автозаполнения
reg add "HKCU\Software\Microsoft\Internet Explorer\IntelliForms" /v "AskUser" /t REG_DWORD /d 0 /f
:: Не проверять цифровую подпись загружаемых программ
reg add "HKCU\Software\Microsoft\Internet Explorer\Download" /v "CheckExeSignatures" /t REG_SZ /d no /f
:: Отключить использование рекомендуемых сайтов
reg add "HKCU\Software\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d 0 /f
:: Отключить Smart Screen
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f
:: Открывать всплывающие окна в новой вкладке
reg add "HKCU\Software\Microsoft\Internet Explorer\TabbedBrowsing" /v "PopupsUseNewWindow" /t REG_DWORD /d 2 /f
:: При открытии новой вкладки открывать Новую страницу вкладки
reg add "HKCU\Software\Microsoft\Internet Explorer\TabbedBrowsing" /v "NewTabPageShow" /t REG_DWORD /d 2 /f
:: Не предупреждать об одновременном закрытии вкладок
reg add "HKCU\Software\Microsoft\Internet Explorer\TabbedBrowsing" /v "WarnOnClose" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\TabbedBrowsing" /v "ShowTabsWelcome" /t REG_DWORD /d 0 /f
:: Всегда переключаться на новую вкладку при ее создании
reg add "HKCU\Software\Microsoft\Internet Explorer\TabbedBrowsing" /v "OpenInForeground" /t REG_DWORD /d 1 /f
:: Показывать строку состояния
reg add "HKCU\Software\Microsoft\Internet Explorer\MINIE" /v "ShowStatusBar" /t REG_DWORD /d 1 /f
:: Отключить Internet Connection Wizard (при первом запуске IE)
reg add "HKCU\Software\Microsoft\Internet Connection Wizard" /v "Completed" /t REG_DWORD /d 1 /f
:: Отключить автопроверку веб каналов по раписанию
reg add "HKCU\Software\Microsoft\Feeds" /v "SyncStatus" /t REG_DWORD /d 0 /f
:: Не помечать автоматически веб канал как просмотреный
reg add "HKCU\Software\Microsoft\Internet Explorer\Feeds" /v "AutoMarkAsReadOPV" /t REG_DWORD /d 0 /f
:: Добавить Поиск через Яндекс
set IEKey="HKCU\Software\Microsoft\Internet Explorer\SearchScopes\{357FF84E-6163-4C91-BA84-3623D6ADCFB7}"
reg add %IEKey% /v "Codepage" /t REG_DWORD /d 65001 /f
reg add %IEKey% /v "DisplayName" /t REG_SZ /d Yandex /f
reg add %IEKey% /v "OSDFileURL" /t REG_SZ /d "https://www.microsoft.com/ru-ru/IEGallery/YandexAddOns" /f
reg add %IEKey% /v "FaviconURL" /t REG_SZ /d "http://yandex.ru/favicon.ico" /f
reg add %IEKey% /v "URL" /t REG_SZ /d "http://yandex.ru/yandsearch?text={searchTerms}&from=os" /f
reg add %IEKey% /v "ShowSearchSuggestions" /t REG_DWORD /d 1 /f
reg add %IEKey% /v "SuggestionsURL_JSON" /t REG_SZ /d "http://suggest.yandex.net/suggest-ff.cgi?part={searchTerms}" /f
:: Добавить Поиск через Google.ru
set IEKey="HKCU\Software\Microsoft\Internet Explorer\SearchScopes\{ACD2BEB0-17F5-4FF1-8A1C-60606069FB98}"
reg add %IEKey% /v "DisplayName" /t REG_SZ /d Google /f
reg add %IEKey% /v "OSDFileURL" /t REG_SZ /d "https://www.microsoft.com/ru-ru/IEGallery/GoogleAddOns" /f
reg add %IEKey% /v "URL" /t REG_SZ /d "http://www.google.ru/search?hl=ru&q={searchTerms}" /f
reg add %IEKey% /v "SuggestionsURL_JSON" /t REG_SZ /d "http://suggestqueries.google.com/complete/search?output=firefox&client=firefox&qu={searchTerms}" /f
reg add %IEKey% /v "FaviconURL" /t REG_SZ /d "http://www.google.ru/favicon.ico" /f
reg add %IEKey% /v "ShowSearchSuggestions" /t REG_DWORD /d 1 /f
:: Назначить Яндекс поисковиком по умолчанию
reg add "HKCU\Software\Microsoft\Internet Explorer\SearchScopes" /v "DefaultScope" /t REG_SZ /d "{357FF84E-6163-4C91-BA84-3623D6ADCFB7}" /f



::   Удаление из контекстного меню проводника пункта "3D-печать с помощью 3D Builder", при наличии
::   Восстановления этих пунктов в батнике нету.
echo.
for /f "tokens=1* delims=" %%I in (' reg query "HKEY_CLASSES_ROOT\SystemFileAssociations" /s /k /f "T3D Print" ^| find /i "T3D Print" ') do (
 echo.& %ch% {0b}     Удаление пункта Меню "T3D Print" из "%%I" {\n #}
 reg delete "%%I" /f )
echo.



echo.&echo.&echo.
%ch% {0b} --- Отключение функций центра специальных возможностей --- {\n #}
:: Отключить автозапуск средств: экранной лупы, диктора или клавиатуры,
:: при использовании центра специальных возможностей для сенсорных панелей и планшетов
reg add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "LaunchAT" /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "ATapp" /t REG_SZ /f
:: Отключить горячие клавиши для включения высокой контрастности из центра специальных возможностей
reg add "HKCU\Control Panel\Accessibility\HighContrast" /v "Flags" /t REG_SZ /d 4218 /f
:: Отключить озвучивание параметров при входе в центр специальных возможностей
reg add "HKCU\SOFTWARE\Microsoft\Ease of Access" /v "selfscan" /t REG_DWORD /d 0 /f


echo.&echo.&echo.
cd /d "%~dp0"
%ch% {0b} --- Добавление параметров DCOM локальной активации и запуска служб --- {\n #}
%ch% {0b} --- Исправление ошибки DistributedCOM 10016 от RuntimeBroker --- {\n #}
%ch% {0b} --- AppID: {{9CA88EE3-ACB7-47c8-AFC4-AB702511C276} разрешения для SYSTEM --- {\n #}
set "RegKeyAppID=HKCR\AppID\{9CA88EE3-ACB7-47c8-AFC4-AB702511C276}"
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add "%RegKeyAppID%" /v "LaunchPermission" /t REG_BINARY /d ^
"010014807800000084000000140000003000000002001c000100000011001400040000000101000000000010001000000200480003000000000018000b000000010200000^
000000f0200000001000000000014000b00000001010000000000050a000000000014000b00000001010000000000051200000001010000000000051200000001010000000^
0000512000000" /f
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:read -silent
echo.
%ch% {0b} --- Исправление ошибки DistributedCOM 10016 от CDP Activity Store --- {\n #}
%ch% {0b} --- AppID: {{F72671A9-012C-4725-9D2F-2A4D32D65169} разрешения для SYSTEM --- {\n #}
set "RegKeyAppID=HKCR\AppID\{F72671A9-012C-4725-9D2F-2A4D32D65169}"
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add "%RegKeyAppID%" /v "LaunchPermission" /t REG_BINARY /d ^
"010014801801000024010000140000003000000002001c000100000011001400040000000101000000000010001000000200e80007000000000018000b000000010200000^
000000f0200000001000000000014000b000000010100000000000504000000000028000b00000001060000000000055000000090541e4ba214ef2f89f2297b702169fe408^
a1c84000028000b000000010600000000000550000000ad3ca7cc73b3031ea048cf5266df4b69a04a8386000028000b000000010600000000000550000000cb5a9214f9662^
2ef279c82b6d32825687e0906db000028000b000000010600000000000550000000a994b8384fb0283f0beb2aa79f5369b380c04130000014000b000000010100000000000^
51200000001010000000000050a00000001020000000000052000000021020000" /f
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:read -silent
echo.
%ch% {0b} --- Исправление ошибки DistributedCOM 10016 от Immersive Shell --- {\n #}
%ch% {0b} --- AppID: {{316CDED5-E4AE-4B15-9113-7055D84DCC97} разрешения для LOCAL SERVICE --- {\n #}
set "RegKeyAppID=HKCR\AppID\{316CDED5-E4AE-4B15-9113-7055D84DCC97}"
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add "%RegKeyAppID%" /v "LaunchPermission" /t REG_BINARY /d ^
"010004807000000080000000000000001400000002005c0004000000000014000b000000010100000000000513000000000014001f0000000101000000000005120000000^
00018001f00000001020000000000052000000020020000000014001f000000010100000000000504000000010200000000000520000000200200000102000000000005200^
0000020020000" /f
reg add "%RegKeyAppID%" /v "AccessPermission" /t REG_BINARY /d ^
"010004807000000080000000000000001400000002005c00040000000000140003000000010100000000000513000000000014000700000001010000000000050a0000000^
000140003000000010100000000000512000000000018000700000001020000000000052000000020020000010200000000000520000000200200000102000000000005200^
0000020020000" /f
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:read -silent
echo.
%ch% {0b} --- Исправление ошибки DistributedCOM 10016 от ShellServiceHost --- {\n #}
%ch% {0b} --- AppID: {{4839DDB7-58C2-48F5-8283-E1D1807D0D7D} разрешения для LOCAL SERVICE --- {\n #}
set "RegKeyAppID=HKCR\AppID\{4839DDB7-58C2-48F5-8283-E1D1807D0D7D}"
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -silent
reg add "%RegKeyAppID%" /v "LaunchPermission" /t REG_BINARY /d ^
"01000480e8000000f800000000000000140000000200d40007000000000014001f000000010100000000000512000000000018001f0000000102000000000005200000002^
0020000000014001f000000010100000000000504000000000028000b000000010600000000000550000000c9e7889f198ff1715dcb779c14dc07f9471d7751000014000b0^
00000010100000000000513000000000028000b000000010600000000000550000000d7d47e18e7980b986f8d6266f7b75c8abb7edfdf000028000b0000000106000000000^
00550000000530ffc35ce15f7c8764b1cf29ce3455d050d243f0102000000000005200000002002000001020000000000052000000020020000" /f
reg add "%RegKeyAppID%" /v "AccessPermission" /t REG_BINARY /d ^
"010004807000000080000000000000001400000002005c00040000000000140003000000010100000000000513000000000014000700000001010000000000050a0000000^
000140003000000010100000000000512000000000018000700000001020000000000052000000020020000010200000000000520000000200200000102000000000005200^
0000020020000" /f
%SetACL% -on "%RegKeyAppID%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -silent
%SetACL% -on "%RegKeyAppID%" -ot reg -actn ace -ace n:S-1-5-32-544;p:read -silent





cd /d "%~dp0"
if "%QuickApply%"=="1" set "QuickApply=" & exit /b

:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY

if "%choice%"=="2" (
 echo.
 %ch% {08}    ========================================== {\n #}
 %ch%         Завершена только {0b}2 часть: Settings     {\n #}
 %ch% {08}    ========================================== {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :Menu
) else (
 echo. & echo. & echo.
 %ch% {08}    ============================================ {\n #}
 %ch%         Завершены обе части: {0b}Spy и Settings      {\n #}
 %ch% {08}    ============================================ {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :Menu
)

::     -------------------------------------
::     ---    Конец 2 части: Settings    ---
::     -------------------------------------



::     ---------------------------------------------------------
::     ---    Ниже начинаются личные настройки из SelfMenu   ---
::     ---------------------------------------------------------

	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::                                                                      :::::
	:::::   Ниже расположены настройки, которые я использую в дополнение       :::::
	:::::   к общим. И они уже влияют на работу основных функций Windows,      :::::
	:::::   поэтому каждый сам должен решить, какие использовать для себя.     :::::
	:::::   Этих параметров нет ни в файле проверки, ни в возврате значений.   :::::
	:::::                                                                      :::::
 	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::   Начало проверки значений параметров для меню "SelfMenu"
:SelfStat
cd /d "%~dp0"
endlocal & setlocal EnableDelayedExpansion

:::::   Проверка основных значений Защитника (DefenderIn)  :::::::::::::::::::::::::::
if not exist "%ProgramFiles%\Windows Defender\MsMpEng.exe" (
 set "NoDefender=1" & set "replyDef={0a}Защитник отсутствует{#}" & goto :SkipCheckDef1)
set regkeyDef="HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware"
for /f "tokens=3" %%I in (' reg query %regkeyDef% 2^>nul ') do set /a "valueDef=%%I"
if "%valueDef%"=="1" ( set "replyDef={0a}Отключен{#}" ) else ( set "replyDef={0e}Включен^^^^^!{#}" )
set RegDefNotice1="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender"
for /f "tokens=1" %%I in (' reg query %RegDefNotice1% 2^>nul ') do set "valueDefNotice1=%%I"
set RegDefNotice2="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "WindowsDefender"
for /f "tokens=3" %%I in (' reg query %RegDefNotice2% 2^>nul ') do set "valueDefNotice2=%%I"
set "valueDefNotice2=%valueDefNotice2:~-8%"
if "%valueDefNotice1%"=="WindowsDefender" (
 if "%valueDefNotice2%"=="00000000" ( set "replyDefNotice1=, уведомления: {0e}Включены^^^^^! (по умолчанию){#}"
					set "replyDefNotice2={0e}Включены^^^^^! (по умолчанию){#}"
	) else ( set "replyDefNotice1=, уведомления: {0a}Отключены{#}"
		set "replyDefNotice2={0a}Отключены{#}" )
) else ( set "replyDefNotice1=, уведомления: {0a}Отключены{#}"
	set "replyDefNotice2={0a}Отключены{#}" )
set RegDefShell="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}"
for /f "tokens=1" %%I in (' reg query %RegDefShell% 2^>nul ') do set "valueDefShell=%%I"
if "%valueDefShell%"=="" ( set "replyDefShell1=, Контекстное меню: {0e}Отображается (по умолчанию){#}"
				set "replyDefShell2={0e}Отображается (по умолчанию){#}"
	) else ( set "replyDefShell1=, Контекстное меню: {0a}Скрыто{#}"
		 set "replyDefShell2={0a}Скрыто{#}")
:SkipCheckDef1

:::::   Проверка значения Superfetch (LoadIn)  :::::::::::::::::::::::::::
for /f "tokens=3*" %%i in (' sc qc SysMain ^| find "START_TYPE" 2^>nul ') do set "starttypeSysMain=%%j"
if "%starttypeSysMain%"=="" ( set "replySysMain={0e}Не существует^^^^^!{#}"
	) else if "%starttypeSysMain%"=="DISABLED" ( set "replySysMain={0a}Отключена{#}"
		) else ( set "replySysMain={0c}Включена^^^^^!{#}" )
set taskpathLoad1="\Microsoft\Windows\Sysmain\ResPriStaticDbSync"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %taskpathLoad1% 2^>nul ') do set "replyLoad1=%%~i"
if not "!replyLoad1!"=="" (
	if "!replyLoad1!"=="Disabled" ( set "replyLoad1={0a}Отключена{#}" ) else ( set "replyLoad1={0c}Включена^^^^^!{#}" )
		) else ( set "replyLoad1={0e}Не существует^^^^^!{#}" )
set taskpathLoad2="\Microsoft\Windows\Sysmain\WsSwapAssessmentTask"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %taskpathLoad2% 2^>nul ') do set "replyLoad2=%%~i"
if not "!replyLoad2!"=="" (
	if "!replyLoad2!"=="Disabled" ( set "replyLoad2={0a}Отключена{#}" ) else ( set "replyLoad2={0c}Включена^^^^^!{#}" )
		) else ( set "replyLoad2={0e}Не существует^^^^^!{#}" )
set regkeyLoad1="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch"
for /f "tokens=3" %%i in (' reg query %regkeyLoad1% 2^>nul ') do set /a "valueLoad1=%%i"
if "%valueLoad1%"=="0" ( set "replyLoad3={0a}Отключен{#}" ) else ( set "replyLoad3={0c}Включен^^^^^!{#}" )
set regkeyLoad2="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher"
for /f "tokens=3" %%i in (' reg query %regkeyLoad2% 2^>nul ') do set /a "valueLoad2=%%i"
if "%valueLoad2%"=="0" ( set "replyLoad4={0a}Отключен{#}" ) else ( set "replyLoad4={0c}Включен^^^^^!{#}" )
set regkeyLoad3="HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\ReadyBoot" /v "Start"
for /f "tokens=3" %%i in (' reg query %regkeyLoad3% 2^>nul ') do set /a "valueLoad3=%%i"
if "%valueLoad3%"=="0" ( set "replyLoad5={0a}Отключен{#}" ) else ( set "replyLoad5={0c}Включен^^^^^!{#}" )

:::::   Проверка параметров индексирования (IndexIn) :::::::::::::::::::::::::::
for /f "tokens=3*" %%i in (' sc qc WSearch ^| find "START_TYPE" 2^>nul ') do set "starttypeWSearch=%%j"
if "%starttypeWSearch%"=="" ( set "replyWSearch={0e}Удалена^^^^^!{#} "
	) else if "%starttypeWSearch%"=="DISABLED" ( set "replyWSearch={0a}Отключена{#}"
		) else ( set "replyWSearch={0e}Включена^^^^^!{#}" )
set taskpathIndex="\Microsoft\Windows\Shell\IndexerAutomaticMaintenance"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %taskpathIndex% 2^>nul ') do set "replyIndex=%%~i"
if not "!replyIndex!"=="" (
	if "!replyIndex!"=="Disabled" ( set "replyIndex={0a}Отключена{#}" ) else ( set "replyIndex={0e}Включена^^^^^!{#}" )
		) else ( set "replyIndex={0a}Удалена{#}  " )

:::::   Проверка параметров Гибернации (HipIn) :::::::::::::::::::::::::::
if exist "%SystemDrive%\hiberfil.sys" (
	TIMEOUT /T 2 /NOBREAK >nul
	if exist "%SystemDrive%\hiberfil.sys" (	set "replyHip={0c}Включена^^^^^!{#}" ) else ( set "replyHip={0a}Отключена{#}" )
) else ( set "replyHip={0a}Отключена{#}" )

:::::   Проверка параметров Быстрой загрузки (FastIn) :::::::::::::::::::::::::::
set regkeyFast="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled"
for /f "tokens=3" %%i in (' reg query %regkeyFast% 2^>nul ') do set /a "valueFast=%%i"
if "%valueFast%"=="0" ( set "replyFast={0a}Отключена{#}" ) else ( set "replyFast={0c}Включена^^^^^!{#}" )

:::::    Просмотр фотографий Windows (MenuWPV) ::::::::::::::::::::::::::
set WPVkey1="HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
for /f "tokens=3" %%I in (' 2^>nul reg query %WPVKey1% /s ^| find ".jpg" ') do set "WPVval1=%%I"
if "%WPVval1%"=="PhotoViewer.FileAssoc.Jpeg" ( set "WPVreply1={0a}Возвращена{#}" ) else ( set "WPVreply1={0e}Не восстановлена{#}" )
set WPVkey2="HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg"
for /f "tokens=1" %%I in (' 2^>nul reg query %WPVKey2% ^| find "PhotoViewer.FileAssoc.Jpeg" ') do set "WPVval2=%%I"
if "%WPVval2%"=="" ( set "WPVreply2={0e}Не настроены{#}" ) else ( set "WPVreply2={0a}Настроены{#}" )

:::::   Проверка журналов событий (MenuEventLogs) :::::::::::::::::::::::::::
set RegEventServ="HKLM\SYSTEM\CurrentControlSet\Services\EventLog" /v "Start"
reg query %RegEventServ% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %RegEventServ% 2^>nul ') do set /a "ValueEventServ=%%I"
 if "!ValueEventServ!"=="4" ( set "EventServ={0e}Отключена{#}" ) else ( set "EventServ={0A}Включена {#}" )
) else ( set "EventServ={4f} Нету {#}" )
set RegEventPS="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PowerShell/Admin" /v "Enabled"
for /f "tokens=3" %%I in (' reg query %RegEventPS% 2^>nul ') do set /a "ValueRegEventPS=%%I"
if "%ValueRegEventPS%"=="0" ( set "ReplyRegEventPS={0a}Остановлено (Вероятно){#}" ) else ( set "ReplyRegEventPS={0e}Выполняется (Вероятно){#}" )

:::::   Контроль учетных записей (MenuUAC) :::::::::::::::::::::::::::
set LUA="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA"
for /f "tokens=3" %%I in (' 2^>nul reg query %LUA% ^| find "EnableLUA" ') do set /a "LuaVal=%%I"
if not "!LuaVal!"=="" (
 if "!LuaVal!"=="0" ( set "LuaVal={0a}Отключен{#}"
  ) else ( if "!LuaVal!"=="1" ( set "LuaVal={0e}Включен{#}"
  ) else ( set "LuaVal={0c}Параметр Неправильный {#}" )
 )
) else ( set "LuaVal={0c}Параметр отсутствует {#}" )
set ConsentAdmin="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin"
for /f "tokens=3" %%I in (' 2^>nul reg query %ConsentAdmin% ^| find "ConsentPromptBehaviorAdmin" ') do set /a "ConsentAdminVal=%%I"
if not "!ConsentAdminVal!"=="" (
 if "!ConsentAdminVal!"=="0" ( set "ConsentAdminVal={0a}Соглашаться Автоматически{#}"
  ) else ( if "!ConsentAdminVal!"=="2" ( set "ConsentAdminVal={0a}Усиленный режим{#}"
  ) else ( if "!ConsentAdminVal!"=="5" ( set "ConsentAdminVal={0e}По умолчанию{#}"
  ) else ( set "ConsentAdminVal={0c}Параметр не описан {#}" )
  )
 )
) else ( set "ConsentAdminVal={0c}Параметр отсутствует {#}" )

:::::   Проверка расположения папки "Temp" текущей учетной записи пользователя (UTempIn) :::::::::::::::::::::::::::
set regkeyUTemp="HKCU\Environment" /v "TEMP"
set "tempregUTemp1=%%USERPROFILE%%\AppData\Local\Temp"
set "tempregUTemp2=%USERPROFILE%\AppData\Local\Temp"
for /f "tokens=3" %%i in (' reg query %regkeyUTemp% 2^>nul ') do set "valueUTemp=%%i"
if not "!valueUTemp!"=="" (
	if /i "!valueUTemp!"=="%tempregUTemp1%" ( set "replyUTemp={17} По умолчанию {#}"
		) else if /i "!valueUTemp!"=="%tempregUTemp2%" ( set "replyUTemp={17} Указана, как по умолчанию {#}"
	) else ( set "replyUTemp={0a}Перенесена{#}" )
) else ( set "replyUTemp={4f} Отсутствует путь, необходимо исправить^^^^^!^^^^^!^^^^^! {#}" )
set "infoUTemp=dir %USERPROFILE%\AppData\Local"
for /f "delims=<>[] tokens=2,3,4" %%i in (' %infoUTemp% ^| find /I "Temp " ') do ( set "SUTemp=%%i" & set "PUTemp=%%k" )
if "%SUTemp%"=="SYMLINKD" ( set "SymUTemp={0a}Сделана{#},  указывает на: {0e}%PUTemp%{#}"
	) else ( set "SymUTemp={17} Не сделана {#}" )

:::::   Проверка расположения Системной папки "Temp" (STempIn) :::::::::::::::::::::::::::
set regkeySTemp="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "TEMP"
set "tempregSTemp1=%%SystemRoot%%\TEMP"
set "tempregSTemp2=%SystemRoot%\TEMP"
for /f "tokens=3" %%i in (' reg query %regkeySTemp% 2^>nul ') do set valueSTemp=%%i
if not "!valueSTemp!"=="" (
	if /i "!valueSTemp!"=="%tempregSTemp1%" ( set "replySTemp={17} По умолчанию {#}"
		) else if /i "!valueSTemp!"=="%tempregSTemp2%" ( set "replySTemp={17} Указана, как по умолчанию {#}"
	) else ( set "replySTemp={0a}Перенесена{#}" )
) else ( set "replySTemp={4f} Отсутствует путь, необходимо исправить^^^^^!^^^^^!^^^^^! {#}" )
set "infoSTemp=dir %SystemRoot%"
for /f "delims=<>[] tokens=2,3,4" %%i in (' %infoSTemp% ^| find /I "Temp " ') do ( set "SSTemp=%%i" & set "PSTemp=%%k" )
if "%SSTemp%"=="SYMLINKD" ( set "SymSTemp={0a}Сделана,{#}  указывает на: {0e}%PSTemp%{#}"
	) else ( set "SymSTemp={17} Не сделана {#}" )

:::::   Проверка временного профиля defaultuser0 (RemUserIn) :::::::::::::::::::::::::::
for /f "tokens=2* delims==" %%I in (' WMIC UserAccount Where "LocalAccount=True" Get Name /value ^| find /I "=defaultuser0" ') do set "BagUser=%%I"
if not "%BagUser%"=="" (set "BagUserName={0c}Не удален{#}") else (set "BagUserName={0a}Отсутствует{#}")
for /f "tokens=7 delims=\" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /s /d /f "defaultuser0" ^| find "S-1-5-21" ') do set "BagUserID=%%I"
if not "%BagUserID%"=="" (set "UserID={0c}Найден{#}") else (set "UserID={0a}Не найден{#}")
set "BagUserFolder=%SystemDrive%\Users\defaultuser0"
if exist "%BagUserFolder%" (set "BagFolder={0c}Не удалена{#}") else (set "BagFolder={0a}Отсутствует{#}")

::   Сценарий отдельного Меню для "SelfMenu" - Своих настроек
::   И отображения текущих состояний параметров
:SelfMenu
cls
echo.
%ch% {08}    ======================================================================= {\n #}
%ch%         {0e}SelfMenu{#} - Личные настройки для опытных^^^!{\n #}
%ch%         Настраиваемые параметры можно задать в файле {0f}\Files\Presets.txt  {\n #}
%ch% {08}    ======================================================================= {\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = Защитник: %replyDef%%replyDefNotice1%%replyDefShell1% {00}.{\n #}
%ch% {0b}    [2]{#} = Оптимизация загрузки (6 пар.): %replySysMain%, %replyLoad1%, %replyLoad2%, %replyLoad3%, %replyLoad4%, %replyLoad5% {00}.{\n #}
%ch% {0b}    [3]{#} = Поиск и Индексирование (2 пар.): %replyWSearch%, %replyIndex% {00}.{\n #}
%ch% {0b}    [4]{#} = Гибернация: %replyHip% {00}.{\n #}
%ch% {0b}    [5]{#} = Быстрая загрузка: %replyFast% {00}.{\n #}
%ch% {0b}    [6]{#} = Сеть {08}(Меню настройки параметров сети){\n #}
%ch% {0b}    [7]{#} = Проводник {08}(Меню настройки отображения элементов){\n #}
%ch% {0b}    [8]{#} = Просмотр фотографий Windows:  Поддержка: %WPVreply1%  Параметры: %WPVreply2%{\n #}
%ch% {0b}    [9]{#} = Переименование компьютера: {0e}%computername% {\n #}
%ch% {0b}   [10]{#} = Журналы событий: Служба: %EventServ%  Ведение Журналов: %ReplyRegEventPS% {\n #}
%ch% {0b}   [11]{#} = Удаление профиля {0e}defaultuser0{#}: %BagUserName%, ID: %UserID%, Папка: %BagFolder%{\n #}
%ch% {0b}   [12]{#} = Контроль учетных записей {08}(UAC){#}: !LuaVal!  Поведение: !ConsentAdminVal! {\n #}
if "%Newbie%" NEQ "1" (
%ch% {0b}   [13]{#} = Папки пользователя {08}^(Меню изменения расположения^){\n #}
%ch% {0b}   [14]{#} = Папка {0e}Temp{#} Пользователя: %replyUTemp% Путь: {0e}%valueUTemp%{#}, Ссылка: %SymUTemp% {00}.{\n #}
%ch% {0b}   [15]{#} = Папка {0e}Temp{#} Системная: %replySTemp% Путь: {0e}%valueSTemp%{#}, Ссылка: %SymSTemp% {00}.{\n #}
%ch% {0b}   [16]{#} = Языковые возможности {08}^(Меню установки/удаления^){\n #}
%ch% {0b}   [17]{#} = Блокировка .exe файлов по названию {08}^(Меню блокировки/разблокировки^){\n #}
)
echo.
%ch% {0b}   [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set "selfoption="
set /p selfoption=-   Ваш выбор: 
if not defined selfoption ( echo. & %ch%     {0e} Возврат в главное меню {\n #} & echo.
			    endlocal & TIMEOUT /T 2 >nul & goto :Menu )
if "%selfoption%"=="1"  ( goto :DefenderIn )
if "%selfoption%"=="2"  ( goto :LoadIn )
if "%selfoption%"=="3"  ( endlocal & goto :IndexIn )
if "%selfoption%"=="4"  ( goto :HipIn )
if "%selfoption%"=="5"  ( goto :FastIn )
if "%selfoption%"=="6"  ( goto :MenuNetWork )
if "%selfoption%"=="7"  ( endlocal & goto :MenuExplorer )
if "%selfoption%"=="8"  ( endlocal & goto :MenuWPV )
if "%selfoption%"=="9"  ( goto :CompReNameIn )
if "%selfoption%"=="10" ( goto :MenuEventLogs )
if "%selfoption%"=="11" ( goto :RemUserIn )
if "%selfoption%"=="12" ( goto :MenuUAC
) else if "%Newbie%" EQU "1" (
 echo. & %ch%     {0e} Неправильный выбор {\n #}& echo.
 TIMEOUT /T 2 >nul & goto :SelfMenu
)
if "%selfoption%"=="13" ( goto :MenuUserFoldersLocation )
if "%selfoption%"=="14" ( goto :UTempIn )
if "%selfoption%"=="15" ( goto :STempIn )
if "%selfoption%"=="16" ( endlocal & goto :CapabilitiesMenu )
if "%selfoption%"=="17" ( endlocal & goto :MenuBlockEXE
) else (
 echo. & %ch%     {0e} Неправильный выбор {\n #}& echo.
 TIMEOUT /T 2 >nul & goto :SelfMenu
)






::     ---------------------------------------------------------
::     ---    Ниже начинаются подразделы личных настройек    ---
::     ---------------------------------------------------------



::   Сценарий меню включения/отключения защитника и его компонентов
:DefenderIn
set "taskpathDef1=\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
set "taskpathDef2=\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
set "taskpathDef3=\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
set "taskpathDef4=\Microsoft\Windows\Windows Defender\Windows Defender Verification"
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%taskpathDef1%" ') do set "replyTaskDef1=%%~I"
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%taskpathDef2%" ') do set "replyTaskDef2=%%~I"
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%taskpathDef3%" ') do set "replyTaskDef3=%%~I"
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%taskpathDef4%" ') do set "replyTaskDef4=%%~I"
if not "!replyTaskDef1!"=="" (
	if "!replyTaskDef1!"=="Disabled" ( set "TaskDefResult1={0a}Отключена{#}" ) else ( set "TaskDefResult1={0e}Включена{#}" )
) else ( set "TaskDefResult1={0a}Не существует{#}" )
if not "!replyTaskDef2!"=="" (
	if "!replyTaskDef2!"=="Disabled" ( set "TaskDefResult2={0a}Отключена{#}" ) else ( set "TaskDefResult2={0e}Включена{#}" )
) else ( set "TaskDefResult2={0a}Не существует{#}" )
if not "!replyTaskDef3!"=="" (
	if "!replyTaskDef3!"=="Disabled" ( set "TaskDefResult3={0a}Отключена{#}" ) else ( set "TaskDefResult3={0e}Включена{#}" )
) else ( set "TaskDefResult3={0a}Не существует{#}" )
if not "!replyTaskDef4!"=="" (
	if "!replyTaskDef4!"=="Disabled" ( set "TaskDefResult4={0a}Отключена{#}" ) else ( set "TaskDefResult4={0e}Включена{#}" )
) else ( set "TaskDefResult4={0a}Не существует{#}" )

set regkeyDefServ1="HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start"
reg query %regkeyDefServ1% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ1% 2^>nul ') do set /a "valueDefServ1=%%I"
 if "!valueDefServ1!"=="4" ( set "replyDefServ1={0a}Отключена{#}" ) else ( set "replyDefServ1={0e}Не отключена{#}" )
) else ( set "replyDefServ1={0a}Не существует{#}" )
set regkeyDefServ2="HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start"
reg query %regkeyDefServ2% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ2% 2^>nul ') do set /a "valueDefServ2=%%I"
 if "!valueDefServ2!"=="4" ( set "replyDefServ2={0a}Отключена{#}" ) else ( set "replyDefServ2={0e}Не отключена{#}" )
) else ( set "replyDefServ2={0a}Не существует{#}" )
set regkeyDefServ3="HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start"
reg query %regkeyDefServ3% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ3% 2^>nul ') do set /a "valueDefServ3=%%I"
 if "!valueDefServ3!"=="4" ( set "replyDefServ3={0a}Отключен{#}" ) else ( set "replyDefServ3={0e}Не отключен{#}" )
) else ( set "replyDefServ3={0a}Не существует{#}" )
set regkeyDefServ4="HKLM\SYSTEM\CurrentControlSet\Services\Sense" /v "Start"
reg query %regkeyDefServ4% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ4% 2^>nul ') do set /a "valueDefServ4=%%I"
 if "!valueDefServ4!"=="4" ( set "replyDefServ4={0a}Отключена{#}" ) else ( set "replyDefServ4={0e}Не отключена{#}" )
) else ( set "replyDefServ4={0a}Не существует{#}" )
set regkeyDefServ5="HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start"
reg query %regkeyDefServ5% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ5% 2^>nul ') do set /a "valueDefServ5=%%I"
 if "!valueDefServ5!"=="4" ( set "replyDefServ5={0a}Отключен{#}" ) else ( set "replyDefServ5={0e}Не отключен{#}" )
) else ( set "replyDefServ5={0a}Не существует{#}" )
set regkeyDefServ6="HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start"
reg query %regkeyDefServ6% >nul 2>&1
if "%errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %regkeyDefServ6% 2^>nul ') do set /a "valueDefServ6=%%I"
 if "!valueDefServ6!"=="4" ( set "replyDefServ6={0a}Отключен{#}" ) else ( set "replyDefServ6={0e}Не отключен{#}" )
) else ( set "replyDefServ6={0a}Не существует{#}" )
cls
echo.
%ch% {08}     =========================================================================== {\n #}
%ch%          Управление {0e}Защитником Windows {08}(Defender) {\n #}
echo.         Будут настроены исключения для папки с батником и файлов активатора
%ch% {08}     =========================================================================== {\n #}
echo.
echo.           В данный момент:
%ch%                   Защитник: %replyDef% {\n #}
%ch%                Уведомления: %replyDefNotice2% {\n #}
%ch%           Контекстное меню: %replyDefShell2% {\n #}
%ch%                     Задачи: 1. %TaskDefResult1%, 2. %TaskDefResult2%, 3. %TaskDefResult3%, 4. %TaskDefResult4% {\n #}
echo.
echo.        Запуск компонентов:
%ch%           Служба WinDefend: %replyDefServ1% {\n #}
%ch%            Служба WdNisSvc: %replyDefServ2% {\n #}
%ch%           Драйвер WdNisDrv: %replyDefServ3% {\n #}
%ch%               Служба Sense: %replyDefServ4% {\n #}
%ch%             Драйвер WdBoot: %replyDefServ5% {\n #}
%ch%           Драйвер WdFilter: %replyDefServ6% {\n #}
echo.
if "%NoDefender%"=="1" (
	goto :NoDefender
)
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Отключить только автозапуск, задачи и скрыть контекстное меню{\n #}
%ch% {0b}     [2]{#} = Отключить все{\n #}
%ch% {0e}     [3]{#} = Включить все обрано {0e}(по умолчанию){\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input (echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat)
if "%input%"=="1" ( goto :DefenderExceptions )
if "%input%"=="2" ( goto :DefenderExceptions )
if "%input%"=="3" ( goto :DefenderExceptions ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
		   				      TIMEOUT /T 2 >nul & goto :DefenderIn )

:NoDefender
%ch%          {0e}Защитник отсутствует, настраивать нечего {\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat

:DefenderExceptions
if "%~1"=="QuickApply" if not exist "%ProgramFiles%\Windows Defender\MsMpEng.exe" ( echo.&%ch%      {0a}Защитник отсутствует, пропуск{\n #} & echo. & exit /b )
if "%~1"=="QuickApply" set "QuickApply=1" & set "input=%~2"
echo.
%ch%     {0b}Добавление файлов в исключения у Защитника Windows{\n #} &echo.
set "BatFolder=%~dp0"
%ch%     {0b}Папка с батником настройки: {0f}"%BatFolder:~0,-1%"{\n #}
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%BatFolder:~0,-1%"" /t REG_DWORD /d 0 /f"
%ch%       {0b}Папка активатора KMSAuto: {0f}"%ProgramData%\KMSAutoS" {\n #}
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%ProgramData%\KMSAutoS"" /t REG_DWORD /d 0 /f"
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%SystemRoot%\KMSAutoS"" /t REG_DWORD /d 0 /f"
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%SystemRoot%\KMSAuto.exe"" /t REG_DWORD /d 0 /f"
%ch%          {0b}Папка активатора AAct: {0f}"%SystemRoot%\AAct_Tools" {\n #}
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%SystemRoot%\AAct_Tools"" /t REG_DWORD /d 0 /f"
%ch%           {0b}Файл активатора AAct: {0f}"%SystemRoot%\System32\SppExtComObjPatcher.exe" {\n #}
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%SystemRoot%\System32\SppExtComObjPatcher.exe"" /t REG_DWORD /d 0 /f"
%ch%           {0b}Файл активатора AAct: {0f}"%SystemRoot%\System32\SppExtComObjHook.dll" {\n #}
Call :TrustedInstaller "reg add ""HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"" /v ""%SystemRoot%\System32\SppExtComObjHook.dll"" /t REG_DWORD /d 0 /f"
echo.
%ch%          {2f} Исключения настроены {00}.{\n #}
echo.
if "%input%"=="1" ( goto :DefOFF1 )
if "%input%"=="2" ( goto :DefOFF2 )
if "%input%"=="3" ( goto :DefON
) else ( goto :DefenderIn )


:DefOFF1
echo.
%ch%     {0b}Отключение только запуска Защитника Windows{\n #}
echo.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
echo.
taskkill /f /im MpCmdRun.exe >nul 2>&1
taskkill /f /im MSASCuiL.exe >nul 2>&1
taskkill /f /im MSASCui.exe >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "WindowsDefender" /t REG_EXPAND_SZ /d "\"%%ProgramFiles%%\Windows Defender\MSASCuiL.exe\"" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "WindowsDefender" /f 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /f
echo.
if "%QuickApply%"=="1" set "QuickApply=" & exit /b
echo.&%ch%      Защитник: {2f} Отключена только автозагрузка, задачи и скрыто контекстное меню {#} {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat


:DefOFF2
echo.
%ch%     {0b}Полное Отключение Защитника Windows{\n #}
echo.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
taskkill /f /im MpCmdRun.exe >nul 2>&1
taskkill /f /im MSASCuiL.exe >nul 2>&1
taskkill /f /im MSASCui.exe >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "WindowsDefender" /t REG_EXPAND_SZ /d "\"%%ProgramFiles%%\Windows Defender\MSASCuiL.exe\"" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /f
tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && set "Defender=YES"

if "!Defender!"=="YES" (
 Call :TrustedInstaller "net stop windefend"
 echo.&echo.     Ожидание остановки службы "Windows Defender" 5-20 сек ...
 TIMEOUT /T 5 /NOBREAK >nul
 tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && TIMEOUT /T 5 /NOBREAK >nul
 tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && TIMEOUT /T 10 /NOBREAK >nul
)

set "Defender="
tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && set "Defender=YES"
if "!Defender!"=="YES" (
 Call :TrustedInstaller "net stop windefend"
 echo.&echo.     Защитник не выключился, еще одна попытка.
 echo.     Ожидание остановки службы "Windows Defender" 5-20 сек ...
 TIMEOUT /T 5 /NOBREAK >nul
 tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && TIMEOUT /T 5 /NOBREAK >nul
 tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && TIMEOUT /T 10 /NOBREAK >nul
)

set "Defender="
tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && set "Defender=YES"

if "!Defender!"=="" (
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d 4 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d 4 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sense" /v "Start" /t REG_DWORD /d 4 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 4 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f"
 schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable >nul 2>&1
 schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable >nul 2>&1
 schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
 schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable >nul 2>&1
) else (
 echo.
 echo.     Завершить работу Защитника не удалось,
 echo.     Повторите после перезагрузки системы
 echo.
)
echo.
if "%QuickApply%"=="1" set "QuickApply=" & exit /b
echo.&%ch%      Защитник: {2f} Отключен полностью {#} {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat


:DefON
if "%~1"=="QuickApply" if not exist "%ProgramFiles%\Windows Defender\MsMpEng.exe" ( echo.&%ch%      {0a}Защитник отсутствует, пропуск{\n #} & echo. & exit /b )
if "%~1"=="QuickApply" set "QuickApply=1"
echo.
%ch%     {0b}Восстановление всех параметров Защитника Windows{\n #}
echo.
tasklist /FO TABLE /NH /FI "ImageName EQ MsMpEng.exe" 2>nul | find /i "MsMpEng.exe" >nul && (set "Defender=YES")
if "!Defender!"=="" (
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d 2 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d 3 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 3 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\Sense" /v "Start" /t REG_DWORD /d 3 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 3 /f"
 Call :TrustedInstaller "reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 3 /f"
 reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f 2>nul
) else (echo.&echo.     Защитник уже запущен &echo. )
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "WindowsDefender" /f 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /t REG_EXPAND_SZ /d "\"%%ProgramFiles%%\Windows Defender\MSASCuiL.exe\"" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "WindowsDefender" /t REG_BINARY /d 020000000000000000000000 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f 2>nul
echo.
if "%QuickApply%"=="1" set "QuickApply=" & exit /b
echo.&%ch%      Параметры Защитника: {0a}Восстановлены^^^!{\n #}
echo.&%ch%      {0a}Перезагрузитесь{\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Настройка Superfetch, Prefetch и ReadyBoot.
:LoadIn
cls
echo.
%ch% {08}     ============================================================== {\n #}
%ch%          Настройка {0e}Superfetch{#}, {0e}Prefetch{#} и {0e}ReadyBoot {\n #}
echo.         Используется для оптимизации загрузки винды и программ
echo.         Обычно отключают если системный диск SSD
%ch% {08}     ============================================================== {\n #}
echo.
echo.            В данный момент:
%ch%          1. Служба Superfetch: %replySysMain% {00}.{\n #}
%ch%          2. Задача ResPriStaticDbSync: %replyLoad1% {00}.{\n #}
%ch%          3. Задача WsSwapAssessmentTask: %replyLoad2% {00}.{\n #}
%ch%          4. Параметр Superfetch: %replyLoad3% {00}.{\n #}
%ch%          5. Параметр Prefetcher: %replyLoad4% {00}.{\n #}
%ch%          6. Анализ ReadyBoot: %replyLoad5% {00}.{\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Отключить все {\n #}
%ch% {0e}     [2]{#} = Включить все {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :LoadOFF )
if "%input%"=="2" ( goto :LoadON
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :LoadIn )
:LoadOFF
net stop SysMain
sc config SysMain start= disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\ReadyBoot" /v "Start" /t REG_DWORD /d 0 /f
schtasks /Change /TN "Microsoft\Windows\Sysmain\ResPriStaticDbSync" /Disable
schtasks /Change /TN "Microsoft\Windows\Sysmain\WsSwapAssessmentTask" /Disable
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Оптимизация загрузки: {2f} Отключена {#} -{00}.{\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
:LoadON
sc config SysMain start= auto
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\ReadyBoot" /v "Start" /t REG_DWORD /d 1 /f
schtasks /Change /TN "Microsoft\Windows\Sysmain\ResPriStaticDbSync" /Enable
schtasks /Change /TN "Microsoft\Windows\Sysmain\WsSwapAssessmentTask" /Enable
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Оптимизация загрузки: {0a}Включена^^^!{#} - {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::   Настройка Поиска и Индексирования
:IndexIn
setlocal EnableDelayedExpansion
set IndexPackage1="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Notifications\OptionalFeatures\SearchEngine-Client-Package" /v "Selection"
for /f "tokens=3" %%I in (' 2^>nul reg query %IndexPackage1% ^| find "Selection" ') do set /a "IndexPackageKey1=%%I"
set IndexPackage2="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending"
for /f "tokens=1 delims=" %%I in (' 2^>nul reg query %IndexPackage2% /s /f "*" /k ^| findstr /i /r /c:"-SearchEngine-Client-Package~.*\Updates" ') do (
 for /f "tokens=3" %%J in (' 2^>nul reg query "%%I" /v "SearchEngine-Client-Package" ^| find "SearchEngine-Client-Package " ') do set /a "IndexPackageKey2=%%J"
)
if "%IndexPackageKey1%"=="0" (
 if "%IndexPackageKey2%"=="1"  ( set "IndexPackage={0e}Установится{#}" & set IndexResult=1
 ) else set "IndexPackage={0a}Отключен{#}   " & set IndexResult=0
) else if "%IndexPackageKey1%"=="1" (
 if "%IndexPackageKey2%"=="0"  ( set "IndexPackage={0e}Отключится{#} " & set IndexResult=1
 ) else set "IndexPackage={0e}Включен{#}    " & set IndexResult=2
) else if "%IndexPackageKey1%"=="" (
 if "%IndexPackageKey2%"=="0"  ( set "IndexPackage={0e}Отключится{#} " & set IndexResult=1
 ) else set "IndexPackage={0e}Включен{#}    " & set IndexResult=2
)
set PackageKey="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
reg query %PackageKey% /f "Microsoft-Windows-" /k | findstr /i "Cortana Search2" >nul || set NoCortana=1

if "%~1"=="QuickApply" set "QuickApply=1" & goto %~2

set CortanaKey="HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana"
for /f "tokens=3" %%I in (' reg query %CortanaKey% 2^>nul ') do set /a "Cortana=%%I"
if "%Cortana%"=="0" ( set "Cortana={0a}Запрещено{#}" ) else ( set "Cortana={0e}Разрешено^^^^^!{#}" )
set WebSearchKey1="HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb"
for /f "tokens=3" %%I in (' reg query %WebSearchKey1% 2^>nul ') do set /a "WebSearch1=%%I"
if "%WebSearch1%"=="0" ( set "WebSearch1={0a}Запрещен{#}" ) else ( set "WebSearch1={0e}Разрешен^^^^^!{#}" )
set WebSearchKey2="HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch"
for /f "tokens=3" %%I in (' reg query %WebSearchKey2% 2^>nul ') do set /a "WebSearch2=%%I"
if "%WebSearch2%"=="1" ( set "WebSearch2={0a}Запрещен{#}" ) else ( set "WebSearch2={0e}Разрешен^^^^^!{#}" )

set BINGkey="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled"
for /f "tokens=3" %%I in (' reg query %BINGkey% 2^>nul ') do set /a "BING1=%%I"
set BINGkey="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled"
for /f "tokens=3" %%I in (' reg query %BINGkey% 2^>nul ') do set /a "BING2=%%I"
set BINGkey="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled"
for /f "tokens=3" %%I in (' reg query %BINGkey% 2^>nul ') do set /a "BING3=%%I"
set BINGkey="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled"
for /f "tokens=3" %%I in (' reg query %BINGkey% 2^>nul ') do set /a "BING4=%%I"
set "BING={0e}Разрешен^^^^^!{#}"
if "%BING1%"=="0" if "%BING2%"=="0" if "%BING3%"=="0" if "%BING4%"=="0" set "BING={0a}Запрещен{#}"

set SearchIconkey="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode"
for /f "tokens=3" %%I in (' reg query %SearchIconkey% 2^>nul ') do set /a "SearchIconVal=%%I"
set "SearchIcon={0e}Отображена{#}"
if "%SearchIconVal%"=="0"  set "SearchIcon={0a}Скрыта{#}"

if "%IndexResult%"=="0" ( set "Cortana={0a}Индекс-ние отключено{#}"
  set "WebSearch1={0a}Индекс-ние отключено{#}"
  set "WebSearch2={0a}Индекс-ние отключено{#}"
)

if "%NoCortana%"=="1" if "%IndexResult%"=="0" ( set "Cortana={0a}Кортана удалена{#}" & set "WebSearch1={0a}Поиск Кортаны удален{#}" & set "WebSearch2={0a}Поиск Кортаны удален{#}" & set "BING={0a}Поиск Кортаны удален{#}")
if "%NoCortana%"=="1" if "%IndexResult%"=="2" ( set "Cortana=%Cortana% {0a}(Кортана удалена){#}" & set "WebSearch1=%WebSearch1%  {0a}(Поиск Кортаны удален){#}" & set "WebSearch2=%WebSearch2%  {0a}(Поиск Кортаны удален){#}" & set "BING=%BING%  {0a}(Поиск Кортаны удален){#}" )

if "%IndexResult%"=="1" ( set "Cortana={0e}Нужна перезагрузка{#}" & set "WebSearch1={0e}Нужна перезагрузка{#}" & set "WebSearch2={0e}Нужна перезагрузка{#}" & set "BING={0e}Нужна перезагрузка{#}" )

for /f "tokens=3*" %%i in (' sc qc WSearch ^| find "START_TYPE" 2^>nul ') do set "starttypeWSearch=%%j"
if "%starttypeWSearch%"=="" ( set "replyWSearch={0e}Удалена^^^^^!{#} "
	) else if "%starttypeWSearch%"=="DISABLED" ( set "replyWSearch={0a}Отключена{#}"
) else ( set "replyWSearch={0e}Включена^^^^^!{#}" )
set taskpathIndex="\Microsoft\Windows\Shell\IndexerAutomaticMaintenance"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %taskpathIndex% 2^>nul ') do set "replyIndex=%%~i"
if not "!replyIndex!"=="" (
	if "!replyIndex!"=="Disabled" ( set "replyIndex={0a}Отключена{#}" ) else ( set "replyIndex={0e}Включена^^^^^!{#}" )
) else ( set "replyIndex={0a}Удалена{#}  " )

:IndexMenu
cls
echo.
%ch% {08}     ========================================================================================= {\n #}
%ch%          Настройка {0e}Поиска и Индексирования{#}. Ускоряет поиск в Windows  {\n #}
echo.         Индексирование собирает и обновляет каталог всех ваших файлов
echo.         При настройке Групповой Политики параметры будут добавлены или убраны из ваших ГП
%ch% {08}     ========================================================================================= {\n #}
echo.
echo.            В данный момент:
%ch%              Служба Windows Search: %replyWSearch%    Использование Кортаны поиском: %Cortana%{\n #}
%ch%           Компонент индексирования: %IndexPackage%                   Поиск в Сети: %WebSearch1%{\n #}
%ch%          Задача обновления индекса: %replyIndex%         Поиск в Сети из таскбара: %WebSearch2%{\n #}
%ch%                                                                   Поиск в Bing: %BING%{\n #}
%ch%                                                      Иконка поиска на таскбаре: %SearchIcon%{\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = {0f}Отключить индексирование и поиск в сети {08}(Параметры поиска в ГП будут сброшены, т.к. ненужны) {\n #}
%ch% {0b}     [2]{#} = Только {0f}Запретить{#} при поиске использование Кортаны и Сети {08}(Индексирование будет оставлено) {\n #}
echo.
%ch% {0e}     [3]{#} = Только {0f}Вернуть{#} использование Кортаны и Сети при поиске {08}(Если Индексирование оставлено) {\n #}
%ch% {0e}     [4]{#} = Вернуть все {0e}(по умолчанию) {\n #}
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :IndexDelete )
if "%input%"=="2" ( goto :SearchWebOFF )
if "%input%"=="3" ( goto :SearchWebON )
if "%input%"=="4" ( goto :IndexDefault
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :IndexMenu )

:IndexDelete
echo.
net stop WSearch
sc config WSearch start= disabled
if not "%IndexResult%"=="0" (dism /online /disable-feature /FeatureName:searchengine-client-package /NoRestart
) else (echo.&%ch%      {0a}Компонент Индексирования уже отключен{\n #})
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f
%ch% {0b} --- Отключение поиска из таскбара через поисковик BING и Кортаной --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
%ch% {0b} --- Скрываем иконку поиска на таскбаре (если удалена картана и ее поиск, то она уже ненужна) --- {\n #}
%ch% {0b} --- Управлять отображением иконки можно по пкм меню на таскбаре --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
if "%QuickApply%"=="1" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
echo. & %ch%      Индексирование: {2f} Отключено {0e}   (Нужна перезагрузка) {\n #}
TIMEOUT /T -1 & endlocal & goto :IndexIn

:SearchWebOFF
echo.
if not "%IndexResult%"=="2" if "%QuickApply%"=="1" ( %ch%      {0e}Отмена настройки ГП по индексированию{#}, Компонент отключен {\n #} & exit /b )
if not "%IndexResult%"=="2" ( %ch%      {0e}Отмена настройки ГП{#}, Компонент индексирования отключен {\n #} & TIMEOUT /T 3 >nul & endlocal & goto :IndexIn )
%ch% {0b} --- Запретить при поиске использовать Cortana  --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить при поиске использовать Cortana с определением местоположения --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить подключения к сети при поиске --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f
%ch% {0b} --- Отключение поиска в сети из таскбара --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f
%ch% {0b} --- Отключение поиска из таскбара через поисковик BING и Кортаной --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
if "%NoCortana%"=="1" (
 %ch% {0b} --- Скрываем иконку поиска на таскбаре ^(если удалена картана и ее поиск, то она уже ненужна^) --- {\n #}
 %ch% {0b} --- Управлять отображением иконки можно по пкм меню на таскбаре --- {\n #}
 reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
)
if "%QuickApply%"=="1" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
echo. & %ch%      Использование при поиске Кортаны и Сети: {2f} Запрещено {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :IndexIn

:SearchWebON
echo.
if not "%IndexResult%"=="2" if "%QuickApply%"=="1" ( %ch%      {0e}Отмена настройки ГП{#}, Компонент индексирования отключен {\n #} & exit /b )
if not "%IndexResult%"=="2" ( %ch%      {0e}Отмена настройки ГП{#}, Компонент индексирования отключен {\n #} & TIMEOUT /T 3 >nul & endlocal & goto :IndexIn )
if not "%NoCortana%"=="1" (
 %ch% {0b} --- Разрешить при поиске использовать Cortana  --- {\n #}
 Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /f
 %ch% {0b} --- Разрешить при поиске использовать Cortana с определением местоположения --- {\n #}
 Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /f
 %ch% {0b} --- Разрешить подключения к сети при поиске --- {\n #}
 Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /f
 %ch% {0b} --- Разрешить поиск в сети из таскбара --- {\n #}
 Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /f
 %ch% {0b} --- Включение поиска из таскбара через поисковик BING и Кортаной ^(по умолчанию^) --- {\n #}
 reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f 2>nul
 reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /f 2>nul
 reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f 2>nul
 reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /f 2>nul
 %ch% {0b} --- Включаем иконку поиска на таскбаре ^(если удалена картана и этот поиск она уже ненужна^) --- {\n #}
 %ch% {0b} --- Управлять ее отображением так же можно по пкм меню на таскбаре --- {\n #}
 reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f
)
if "%QuickApply%"=="1" exit /b
if not "%NoCortana%"=="1" (
 rem  Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
 Call :LGPO_FILE_APPLY
 %ch%      Использование при поиске Кортаны и Сети: {9f} Разрешено {00}.{\n #}
) else (%ch%      Пропуск настройки поиска по Кортане и Сети: {9f} Кортана и ее поиск удалены {00}.{\n #})
TIMEOUT /T -1 & endlocal & goto :IndexIn

:IndexDefault
echo.
if not "%IndexResult%"=="2" (dism /online /enable-feature /FeatureName:searchengine-client-package /NoRestart
) else (echo.&%ch%      {0a}Компонент Индексирования уже установлен{\n #})
sc config WSearch start= delayed-auto
schtasks /Change /TN "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance" /Enable 2>nul
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f
%ch% {0b} --- Включение поиска из таскбара через поисковик BING и Кортаной (по умолчанию) --- {\n #}
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /f 2>nul
%ch% {0b} --- Включаем иконку поиска на таскбаре (если удалена картана и этот поиск она уже ненужна) --- {\n #}
%ch% {0b} --- Управлять ее отображением так же можно по пкм меню на таскбаре --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f
if "%QuickApply%"=="1" exit /b
rem  Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
echo. & %ch%      Индексирование: {9f} Включено^^^! {0e}   (Нужна перезагрузка) {\n #}
TIMEOUT /T -1 & endlocal & goto :IndexIn
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::   Настройка гибернации
:HipIn
cls
echo.
%ch% {08}     ================================================================= {\n #}
%ch%          Настройка {0e}гибернации. {\n #}
echo.         Если отключена, быстрая загрузка так же не будет работать
%ch% {08}     ================================================================= {\n #}
echo.
%ch%          В данный момент Гибернация: %replyHip% {00}.{\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Отключить {\n #}
%ch% {0e}     [2]{#} = Включить {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :HipOFF )
if "%input%"=="2" ( goto :HipON
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :HipIn )
:HipOFF
@Echo on
powercfg -h off
@Echo off
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Гибернация: {2f} Отключена {#} -{00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat
:HipON
@Echo on
powercfg -h on
@Echo off
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Гибернация: {0a}Включена^^^!{#} - {\n #}
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Настройка быстрой загрузки
:FastIn
cls
echo.
%ch% {08}     =============================================== {\n #}
%ch%          Настройка {0e}Быстрой загрузки{\n #}
echo.         Использует гибернацию вместо выключения
%ch% {08}     =============================================== {\n #}
echo.
%ch%          В данный момент Быстрая загрузка: %replyFast% {00}.{\n #}
echo.
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Отключить {08}(Будет полноценное выключение) {\n #}
%ch% {0e}     [2]{#} = Включить {0e}(Значение по умолчанию) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :FastOFF )
if "%input%"=="2" ( goto :FastON
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :FastIn )
:FastOFF
@Echo on
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f
@Echo off
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Быстрая загрузка: {2f} Отключена {#} -{00}.{\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
:FastON
@Echo on
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 1 /f
@Echo off
if "%~1"=="QuickApply" exit /b
echo. & %ch%      - Быстрая загрузка: {0a}Включена^^^!{#} - {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Меню управления отображением папок и значков в панели навигации проводника
:MenuNetWork
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set SMB1Component1="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Notifications\OptionalFeatures\SMB1Protocol" /v "Selection"
for /f "tokens=3" %%I in (' 2^>nul reg query %SMB1Component1% ^| find "Selection" ') do set /a "SMB1ComponentKey1=%%I"
set SMB1Component2="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending"
for /f "tokens=1 delims=" %%I in (' 2^>nul reg query %SMB1Component2% /s /f "*" /k ^| findstr /i /r /c:"-SMB1-Package~.*\Updates" ') do (
 for /f "tokens=3" %%J in (' 2^>nul reg query "%%I" /v "SMB1Protocol" ^| find "SMB1Protocol " ') do set /a "SMB1ComponentKey2=%%J"
)
if "%SMB1ComponentKey1%"=="0" (
 if "%SMB1ComponentKey2%"=="1"  ( set "SMB1Component={0e}Включится {08}(после перезагрузки){#}" & set SMB1Result=1
 ) else set "SMB1Component={0a}Отключен{#}" & set SMB1Result=0
) else if "%SMB1ComponentKey1%"=="1" (
 if "%SMB1ComponentKey2%"=="0"  ( set "SMB1Component={0a}Отключится {08}(после перезагрузки){#}" & set SMB1Result=0
 ) else set "SMB1Component={0e}Включен{#}" & set SMB1Result=1
) else if "%SMB1ComponentKey1%"=="" (
 if "%SMB1ComponentKey2%"=="0"  ( set "SMB1Component={0a}Отключится {08}(после перезагрузки){#}" & set SMB1Result=0
 ) else set "SMB1Component={0e}Включен{#}" & set SMB1Result=1
)

if "%~1"=="QuickApply" set "QuickApply=1" & goto %~2

for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "DependOnService" ') do set "SMB1key1=%%~I"
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" ') do set /a "SMB1key2=%%~I"
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "DependOnService" ') do set "SMB1key3=%%~I"
set "SMB1="
if /i "%SMB1key1%"=="SamSS\0Srv2" if "%SMB1key2%"=="0" if /i "%SMB1key3%"=="Bowser\0MRxSmb20\0NSI" ( set "SMB1={0a}Отключен{#}" )
if "%SMB1%"=="" set "SMB1={0e}Не отключен{#}"
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "Start" ') do set /a "ServerKey=%%~I"
if "%ServerKey%"=="4" ( set "ServerKey={0a}Отключена{#}                 " ) else if "%ServerKey%"=="2" ( set "ServerKey={0e}Включена  {08}(по умолчанию){#}  "
) else ( set "ServerKey={0e}Не отключена{#}" )
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Ole" /v "EnableDCOM" ') do set "DCOMKey=%%~I"
if "%DCOMKey%"=="N" ( set "DCOMKey={0a}Отключен{#}                   " ) else if "%DCOMKey%"=="Y" ( set "DCOMKey={0e}Включен   {08}(по умолчанию){#}   "
) else ( set "DCOMKey={0c}Ошибка{#}" )
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT" /v "Start" ') do set /a "NetBiosKey=%%~I"
if "%NetBiosKey%"=="4" ( set "NetBiosKey={0a}Отключен{#}                   " ) else if "%NetBiosKey%"=="1" ( set "NetBiosKey={0e}Включен   {08}(по умолчанию){#}   "
) else ( set "NetBiosKey={0e}Не отключен{#}   " )
:::::   Проверка параметров протокола "IPv6" :::::::::::::::::::::::::::
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters" /v "DisabledComponents" ') do set "valueIPv6=%%I"
if "!valueIPv6!"=="" ( set "replyIPv6={0e}Включен{#} " & set "valueIPv6=Нет параметра"
 ) else if "!valueIPv6!"=="0x0" ( set "replyIPv6={0e}Включен{#}"
 ) else if "!valueIPv6!"=="0xff" ( set "replyIPv6={0a}Отключен{#}"
) else ( set "replyIPv6={0e}Описание этого значения ключа не предусмотрено{#}" )
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-UnBlock-Site-My" ') do set "Set-UnBlock-Site-My=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-UnBlock-Site-My%') do set "UnBlockSiteMy=%%I"
:::::   Проверка параметров блокировок :::::::::::::::::::::::::::
set UnBlockSite1=https://antizapret.prostovpn.org/proxy.pac
set UnBlockSite2=https://config.anticenz.org/proxy.pac
for /f "tokens=3" %%I in (' 2^>nul reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "AutoConfigURL" ') do set "AutoConfigURL=%%~I"
if not "%AutoConfigURL%"=="" ( if "%AutoConfigURL%"=="%UnBlockSite1%" ( set "AutoConfigURL1={08}^| {0a}Применен{#}" & set "ConfigURL=Вариант 1"))
if not "%AutoConfigURL%"=="" ( if "%AutoConfigURL%"=="%UnBlockSite2%" ( set "AutoConfigURL2={08}^| {0a}Применен{#}" & set "ConfigURL=Вариант 2" ))
if not "%AutoConfigURL%"=="" ( if "%AutoConfigURL%"=="%UnBlockSiteMy%" ( set "AutoConfigURL3={08}^| {0a}Применен{#}" & set "ConfigURL=Вариант 3" ))
if "%UnBlockSiteMy%"=="" ( set "UnBlockSiteMy=Не задан в \Files\Presets.txt" )
if "%AutoConfigURL%"=="" ( set "AutoConfigURL={0e}Нет обхода{#}              " ) else ( set "AutoConfigURL={0a}Применен  {0f}(%ConfigURL%){#}   " )
:::::   Проверка параметров Удаленного доступа :::::::::::::::::::::::::::
set RemoteShare1="HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks"
for /f "tokens=3" %%I in (' reg query %RemoteShare1% 2^>nul ') do set /a "RemoteShareVal1=%%I"
set RemoteShare2="HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareServer"
for /f "tokens=3" %%I in (' reg query %RemoteShare2% 2^>nul ') do set /a "RemoteShareVal2=%%I"
set "RemoteShare={0e}Настроены! {0e}(по своему){#}    "
if "%RemoteShareVal1%"=="0" if "%RemoteShareVal2%"=="0" set "RemoteShare={0a}Отключены{#}                "
if "%RemoteShareVal1%"==""  if "%RemoteShareVal2%"==""  set "RemoteShare={0e}Включены  {08}(по умолчанию){#} "
set RemoteAssist1="HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowToGetHelp"
for /f "tokens=3" %%I in (' reg query %RemoteAssist1% 2^>nul ') do set /a "RemoteAssistVal1=%%I"
set RemoteAssist2="HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowUnsolicited"
for /f "tokens=3" %%I in (' reg query %RemoteAssist2% 2^>nul ') do set /a "RemoteAssistVal2=%%I"
set "RemoteAssist={0e}Настроен!  {0e}(по своему){#}         "
if "%RemoteAssistVal1%"=="0" if "%RemoteAssistVal2%"=="0" set "RemoteAssist={0a}Отключен{#}                      "
if "%RemoteAssistVal1%"==""  if "%RemoteAssistVal2%"==""  set "RemoteAssist={0e}Включен   {08}(по умолчанию){#}      "
set RemoteAssist3="HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp"
for /f "tokens=3" %%I in (' reg query %RemoteAssist3% 2^>nul ') do set /a "RemoteAssistVal3=%%I"
if "%RemoteAssistVal1%"==""  if "%RemoteAssistVal2%"=="" if "%RemoteAssistVal3%"=="0" set "RemoteAssist={0e}Отключен   {08}(не в ГП){#}          "
for /f "delims=, tokens=3" %%I in (' SCHTASKS /QUERY /FO CSV /NH /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" 2^>nul ') do set "RemoteTaskVal=%%~I"
if not "!RemoteTaskVal!"=="" (
 if "!RemoteTaskVal!"=="Disabled" ( set "RemoteTask={0a}Отключена{#}                 " ) else ( set "RemoteTask={0e}Включена  {08}(по умолчанию){#}  " )
) else ( set "RemoteTask={0e}Не создана{#}                " )
set RemoteMDM="HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM" /v "DisableRegistration"
for /f "tokens=3" %%I in (' reg query %RemoteMDM% 2^>nul ') do set /a "RemoteMDMVal=%%I"
if "%RemoteMDMVal%"=="1" ( set "RemoteMDM={0a}Отключена{#}" ) else ( set "RemoteMDM={0e}Включена  {08}(по умолчанию){#}" )
set NetMeeting="HKLM\SOFTWARE\Policies\Microsoft\Conferencing" /v "NoRDS"
for /f "tokens=3" %%I in (' reg query %NetMeeting% 2^>nul ') do set /a "NetMeetingVal=%%I"
if "%NetMeetingVal%"=="1" ( set "NetMeeting={0a}Отключен{#}" ) else ( set "NetMeeting={0e}Включен   {08}(по умолчанию){#}" )
set WinRM="HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" /v "AllowRemoteShellAccess"
for /f "tokens=3" %%I in (' reg query %WinRM% 2^>nul ') do set /a "WinRMVal=%%I"
if "%WinRMVal%"=="0" ( set "WinRM={0a}Отключена{#}" ) else ( set "WinRM={0e}Включена  {08}(по умолчанию){#}" )
set RegRemRegistry="HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry" /v "Start"
reg query %RegRemRegistry% >nul 2>&1
if "%Errorlevel%"=="0" (
 for /f "tokens=3" %%I in (' reg query %RegRemRegistry% 2^>nul ') do set /a "ValueRemRegistry=%%I"
 if "!ValueRemRegistry!"=="4" ( set "RemRegistry={0a}Отключен{#}"
 ) else if "!ValueRemRegistry!"=="3" ( set "RemRegistry={0e}Включен   {08}(по умолчанию){#}"
 ) else ( set "RemRegistry={0e}Включен  {#}" )
) else ( set "RemRegistry={0c}Удален   {#}" )
cls
echo.
%ch% {08}    ======================================================================================================= {\n #}
%ch%         {0e}Настройка параметров Сети{#}  Для безопасности рекомендуется отключить [1] и [2] пункт,{\n #}
echo.        и лишние компоненты в сетевом подключении для интернета. Достаточно оставить IPv4 и если есть
%ch%         компоненты Бридж (от Вирт. Маш.) и Фаервола. Из-за [2] пункта {0b}не будет работать локальная сеть^^^! {\n #}
%ch% {08}    ======================================================================================================= {\n #}
echo.
%ch%          Служба {0f}Сервер{#}: %ServerKey% Компонент {0f}SMB1{#}: %SMB1Component%{\n #}
%ch%          Протокол {0f}DCOM{#}: %DCOMKey% Протокол {0f}SMB1{#}: %SMB1%{\n #}
%ch%        Драйвер {0f}NetBios{#}: %NetBiosKey% Протокол {0f}IPv6{#}: %replyIPv6%  {08}(значение: {0e}%valueIPv6%{08}){\n #}
%ch%     Общие {0f}Адм. Ресурсы{#}: %RemoteShare% Регистрация {0f}MDM{#}: %RemoteMDM%{\n #}
%ch%     Удаленный {0f}Помощник{#}: %RemoteAssist% {0f}NetMeeting{#}: %NetMeeting%{\n #}
%ch%       Задача {0f}Помощника{#}: %RemoteTask% Оболочка {0f}WinRM{#}: %WinRM%{\n #}
%ch%       Обход {0f}блокировок{#}: %AutoConfigURL% Удаленный {0f}Реестр{#}: %RemRegistry%{\n #}
echo.
echo.        Варианты для выбора:
%ch% {0b}    [1]{#} = Отключить {0f}SMB1 {08}(Отключает компонент и протокол SMB1) {\n #}
%ch% {0b}    [2]{#} = Отключить службу {0f}Сервер{#}, протокол {0f}DCOM{#} и драйвер {0f}NetBios через TCP/IP{#} {\n #}
%ch% {0b}    [3]{#} = Отключить {0f}Общие Адм. ресурсы{#} и {0f}Параметры Удаленного доступа {\n #}
%ch% {0b}    [4]{#} = Отключить {0f}IPv6 {\n #}
%ch% {0b}    [5]{#} = Открыть {0f}Сетевые подключения {08}(Для отключения вручную лишних компонентов сети для безопасности){\n #}
echo.
%ch% {0b}    [6]{#} = {0f}Обход блокировок{#} Сайтов 1 {08}^| %UnBlockSite1% %AutoConfigURL1%{\n #}
%ch% {0b}    [7]{#} = {0f}Обход блокировок{#} Сайтов 2 {08}^| %UnBlockSite2% %AutoConfigURL2%{\n #}
%ch% {0b}    [8]{#} = {0f}Обход блокировок{#} Сайтов 3 {08}^| %UnBlockSiteMy% %AutoConfigURL3%{\n #}
%ch% {0e}    [9]{#} = Включить SMB1    {0e}[11]{#} = Включить Сервер, DCOM и NetBios    {0e}[13]{#} = Включить Адм. ресурсы и Удаленный доступ{\n #}
%ch% {0e}   [10]{#} = Включить IPv6    {0e}[12]{#} = Убрать обход блокировок сайтов{\n #}
%ch% {0b}   [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1"   ( goto :SMB1Disable )
if "%input%"=="2"   ( goto :LocalSettingsDisable )
if "%input%"=="3"   ( goto :RemoteOFF )
if "%input%"=="4"   ( goto :IPv6OFF )
if "%input%"=="5"   ( goto :StartNetConnections )
if "%input%"=="6"   ( goto :UnBlockSiteON1 )
if "%input%"=="7"   ( goto :UnBlockSiteON2 )
if "%input%"=="8"   ( goto :UnBlockSiteON3 )
if "%input%"=="9"   ( goto :SMB1Default )
if "%input%"=="10"  ( goto :IPv6ON )
if "%input%"=="11"  ( goto :LocalSettingsDefault )
if "%input%"=="12"  ( goto :UnBlockSiteOFF )
if "%input%"=="13"  ( goto :RemoteON
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
          endlocal & TIMEOUT /T 1 >nul & goto :MenuNetWork )

:SMB1Disable
echo.
:: Отключение компонента SMB1
if "%SMB1Result%"=="1" (
 echo.&%ch%      {0b}Отключение{#} Компонента SMB1{\n #}&echo.
 dism /online /norestart /disable-feature /featurename:SMB1Protocol
) else (
 echo.&%ch%      {0a}Компонент SMB1 уже отключен или отключится после перезагрузки{\n #}&echo.
)
:: Отключение протокола SMB1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "DependOnService" /t REG_MULTI_SZ /d "SamSS"\0"Srv2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "DependOnService" /t REG_MULTI_SZ /d "Bowser"\0"MRxSmb20"\0"NSI" /f
echo.
if "%QuickApply%"=="1" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 4 >nul & endlocal & goto :MenuNetWork

:SMB1Default
echo.
:: Включение компонента SMB1
if "%SMB1Result%"=="0" (
 echo.&%ch%      {0b}Включение{#} Компонента SMB1{\n #}&echo.
 dism /online /norestart /enable-feature /featurename:SMB1Protocol
) else (
 echo.&%ch%      {0a}Компонент SMB1 уже включен или включится после перезагрузки{\n #}&echo.
)
:: Возврат параметров SMB
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "DependOnService" /t REG_MULTI_SZ /d "SamSS"\0"Srv2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "DependOnService" /t REG_MULTI_SZ /d "Bowser"\0"MRxSmb20"\0"NSI" /f
echo.
if "%QuickApply%"=="1" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 4 >nul & endlocal & goto :MenuNetWork

:LocalSettingsDisable
echo.
:: Отключить службу Сервер (445 порт) и счетчики производительности сетевых служб:
sc config LanmanServer start= disabled
LODCTR /D:PerfNet
:: Запретить протокол связи DCOM
reg add "HKLM\SOFTWARE\Microsoft\Ole" /v "EnableDCOM" /t REG_SZ /d "N" /f
:: Отключить драйвер NetBios через TCP/IP
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT" /v "Start" /t REG_DWORD /d 4 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :MenuNetWork

:LocalSettingsDefault
echo.
:: Включить службу Сервер (445 порт) и счетчики производительности сетевых служб (по умолчанию):
sc config LanmanServer start= auto
LODCTR /E:PerfNet
:: Разрешить протокол связи DCOM (по умолчанию)
reg add "HKLM\SOFTWARE\Microsoft\Ole" /v "EnableDCOM" /t REG_SZ /d "Y" /f
:: Включить драйвер NetBios через TCP/IP (по умолчанию)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT" /v "Start" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :MenuNetWork

:IPv6OFF
@Echo on
reg add "HKLM\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0xff /f
@Echo off
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :MenuNetWork

:IPv6ON
@Echo on
reg delete "HKLM\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters" /v "DisabledComponents" /f
@Echo off
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :MenuNetWork

:RemoteOFF
echo.
%ch% {0b} --- Отключение Службы Удаленный реестр "RemoteRegistry" --- {\n #}
net stop RemoteRegistry
sc config RemoteRegistry start= disabled
%ch% {0b} --- Отключение автосоздания общих административных ресурсов. Кроме IPC$ и созданных вами. --- {\n #}
%ch% {0b} --- некоторым средствам резервного копирования необходим к ним доступ. --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareServer" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить подключения удаленного помощника --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить удалённое управление этим компьютером --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить запрос для удаленного помощника --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f
%ch% {0b} --- Запретить получение не запрошенной удаленной помощи --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowUnsolicited" /t REG_DWORD /d 0 /f
%ch% {0b} --- Отключение задачи проверки состояния удаленного помощника --- {\n #}
schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable
%ch% {0b} --- Отключить регистрацию для Mobile Device Management, удаленное управление компьютером --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM" /v "DisableRegistration" /t REG_DWORD /d 1 /f
%ch% {0b} --- Запретить удаленное управление рабочим столом NetMeeting --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Conferencing" /v "NoRDS" /t REG_DWORD /d 1 /f
%ch% {0b} --- Запретить доступ к удаленной оболочке WinRM --- {\n #}
Call :LGPO_FILE reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" /v "AllowRemoteShellAccess" /t REG_DWORD /d 0 /f
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuNetWork

:RemoteON
echo.
%ch% {0b} --- Включение Службы Удаленный реестр "RemoteRegistry" --- {\n #}
sc config RemoteRegistry start= demand
%ch% {0b} --- Включение автосоздания общих административных ресурсов (по умолчанию) --- {\n #}
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /f
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareServer" /f
%ch% {0b} --- Разрешить подключения удаленного помощника (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 1 /f
%ch% {0b} --- Разрешить удалённое управление этим компьютером (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 1 /f
%ch% {0b} --- Разрешить удаленную помощь (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowToGetHelp" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fAllowUnsolicited" /f
%ch% {0b} --- Включение задачи проверки состояния удаленного помощника --- {\n #}
schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Enable
%ch% {0b} --- Включить регистрацию для Mobile Device Management, удаленное управление компьютером (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM" /f
%ch% {0b} --- Включить удаленное управление рабочим столом NetMeeting (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Conferencing" /f
%ch% {0b} --- Включить доступ к удаленной оболочке WinRM (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" /f
if "%~1"=="QuickApply" exit /b
:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T -1 & endlocal & goto :MenuNetWork

:StartNetConnections
ncpa.cpl
TIMEOUT /T 1 >nul & endlocal & goto :MenuNetWork

:UnBlockSiteON1
echo.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "AutoConfigURL" /d "https://antizapret.prostovpn.org/proxy.pac" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d ^
"46000000040000000d00000000000000000000002a00000068747470733a2f2f616e74697a61707265742e70726f73746f76706e2e6f72672f70726f78792e70616300^
00000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d ^
"460000000b0000000d00000000000000000000002a00000068747470733a2f2f616e74697a61707265742e70726f73746f76706e2e6f72672f70726f78792e70^
61630000000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "WarnOnIntranet" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "Flags" /t REG_DWORD /d 211 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "CurrentLevel" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "AutoDetect" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IntranetName" /t REG_DWORD /d 1 /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "ProxyBypass" /f 2>nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "UNCAsIntranet" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {0e}   Нужно перезапустить браузер^^^! {\n #} &echo.
%ch%     {0f}И отключить все расширения "прокси" в браузере^^^! {\n #} &echo.
%ch%     {0f}Только для России^^^! {\n #} &echo.
TIMEOUT /T -1 & endlocal & goto :MenuNetWork

:UnBlockSiteON2
echo.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "AutoConfigURL" /d "https://config.anticenz.org/proxy.pac" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d ^
"46000000050000000d00000000000000000000002500000068747470733a2f2f636f6e6669672e616e746963656e7a2e6f72672f70726f78792e706163000000000000^
0000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d ^
"460000000e0000000d00000000000000000000002500000068747470733a2f2f636f6e6669672e616e746963656e7a2e6f72672f70726f78792e706163000000^
0000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "WarnOnIntranet" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "Flags" /t REG_DWORD /d 211 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "CurrentLevel" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "AutoDetect" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IntranetName" /t REG_DWORD /d 1 /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "ProxyBypass" /f 2>nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "UNCAsIntranet" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {0e}   Нужно перезапустить браузер^^^! {\n #} &echo.
%ch%     {0f}И отключить все расширения "прокси" в браузере^^^! {\n #} &echo.
%ch%     {0f}Только для России^^^! {\n #} &echo.
TIMEOUT /T -1 & endlocal & goto :MenuNetWork

:UnBlockSiteON3
echo.
if "%Set-UnBlock-Site-My%"=="" (
 echo.&%ch%      {4f} Отмена {#}  Свои настройки в {0e}\Files\Presets.txt{#} не заданы {\n #} &echo.
 TIMEOUT /T -1 & endlocal & goto :MenuNetWork
)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "AutoConfigURL" /d "%Set-UnBlock-Site-My%" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "WarnOnIntranet" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "Flags" /t REG_DWORD /d 211 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "CurrentLevel" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "AutoDetect" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IntranetName" /t REG_DWORD /d 1 /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "ProxyBypass" /f 2>nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "UNCAsIntranet" /t REG_DWORD /d 1 /f
echo.&%ch%    {0e} Для продолжения нажмите {0b}"OK"{0e} в открытом окне настроек браузера^^^!{\n #} &echo.&echo.
start /wait rundll32.exe shell32.dll, Control_RunDLL inetcpl.cpl,,4
echo.
echo.&%ch%    {2f} Все выполнено {0e}   Нужно перезапустить браузер^^^! {\n #} &echo.
%ch%     {0f}И отключить все расширения "прокси" в браузере^^^! {\n #} &echo.
TIMEOUT /T -1 & endlocal & goto :MenuNetWork

:UnBlockSiteOFF
echo.
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "AutoConfigURL" /f 2>nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "DefaultConnectionSettings" /t REG_BINARY /d ^
"4600000012000000090000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v "SavedLegacySettings" /t REG_BINARY /d ^
"460000002a000000090000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v "WarnOnIntranet" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "Flags" /t REG_DWORD /d 219 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "CurrentLevel" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "AutoDetect" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IntranetName" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "ProxyBypass" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "UNCAsIntranet" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {0e}   Нужно перезапустить браузер^^^! {\n #} &echo.
TIMEOUT /T 4 >nul & endlocal & goto :MenuNetWork
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Меню управления отображением папок и значков в панели навигации проводника
:MenuExplorer
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set Video="HKCU\SOFTWARE\Classes\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Video% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "VideoVal=%%I"
if "%VideoVal%"=="0" ( set "VideoVal={0a}Скрыта{#}      " ) else ( set "VideoVal={0e}Отображается{#}" )
set Docum="HKCU\SOFTWARE\Classes\CLSID\{d3162b92-9365-467a-956b-92703aca08af}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Docum% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "DocumVal=%%I"
if "%DocumVal%"=="0" ( set "DocumVal={0a}Скрыта{#}      " ) else ( set "DocumVal={0e}Отображается{#}" )
set Downl="HKCU\SOFTWARE\Classes\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Downl% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "DownlVal=%%I"
if "%DownlVal%"=="0" ( set "DownlVal={0a}Скрыта{#}      " ) else ( set "DownlVal={0e}Отображается{#}" )
set Pictu="HKCU\SOFTWARE\Classes\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Pictu% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "PictuVal=%%I"
if "%PictuVal%"=="0" ( set "PictuVal={0a}Скрыта{#}      " ) else ( set "PictuVal={0e}Отображается{#}" )
set Music="HKCU\SOFTWARE\Classes\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Music% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "MusicVal=%%I"
if "%MusicVal%"=="0" ( set "MusicVal={0a}Скрыта{#}      " ) else ( set "MusicVal={0e}Отображается{#}" )
set Deskt="HKCU\SOFTWARE\Classes\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %Deskt% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "DesktVal=%%I"
if "%DesktVal%"=="0" ( set "DesktVal={0a}Скрыта{#}      " ) else ( set "DesktVal={0e}Отображается{#}" )
set KeyDupl86="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
reg query %KeyDupl86% >nul 2>&1
if "%ErrorLevel%"=="0" ( set "DuplVal={0e}Отображаются{#}" ) else ( set "DuplVal={0a}Скрыты{#}" )
set NetIсon86="HKCU\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes"
for /f "tokens=3" %%I in (' 2^>nul reg query %NetIсon86% ^| find "Attributes" ') do set "NetIconVal=%%I"
if "%NetIconVal%"=="0xb0940064" ( set "NetIconVal={0a}Скрыт{#}" ) else ( set "NetIconVal={0e}Отображается{#}" )
set FastAccess86="HKCU\SOFTWARE\Classes\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder" /v "Attributes"
for /f "tokens=3" %%I in (' 2^>nul reg query %FastAccess86% ^| find "Attributes" ') do set "FastAccVal=%%I"
if "%FastAccVal%"=="0xa0600000" ( set "FastAccVal={0a}Скрыт{#}" ) else ( set "FastAccVal={0e}Отображается{#}" )
set GlobalIcon="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
for /f "tokens=1,3" %%I in (' 2^>nul reg query %GlobalIcon% /v "8" ^| find "8" ') do ( set /a "GlobalIconAll=%%I" & set "KeyAll=%%J" )
if "%GlobalIconAll%"=="8" ( set "GlobalIconAll={0a}Настроено {08}^|{0e} !KeyAll!{#}" ) else ( set "GlobalIconAll={0e}Не настроено {08}(по умолчанию){#}" )
set "AllIconDiskLetter="
set RegIconLetter="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"
for /f "tokens=8 delims=\" %%I in (' 2^>nul reg query %RegIconLetter% ') do (
 if "!AllIconDiskLetter!"=="" ( set "AllIconDiskLetter=%%I:" ) else ( set "AllIconDiskLetter=!AllIconDiskLetter! %%I:" )
)
if "!KeyAll!" EQU "" ( set "IconDiskInfo=   {08}(По умолчанию){#}" ) else ( set "IconDiskInfo= {08}(Возможно по причине одного диска в системе){#}" )
if "!AllIconDiskLetter!"=="" ( set "AllIconDiskLetter={0e}Не заданы !IconDiskInfo!{#}" ) else ( set "AllIconDiskLetter={0a}Заданы    {08}^| {0e}!AllIconDiskLetter!{#}" )
cls
echo.
%ch% {08}    ============================================================================================================ {\n #}
%ch%         Настройка проводника: {0e}Папки пользователя, Дубликаты съемных устройств, Значок Сеть, Быстрый доступ  {\n #}
echo.        Для использования этого меню, нужно сначала восстановить все оригинальные значения пунктом [999]
echo.        Все параметры применяются для текущего аккаунта "HKCU", без смены разрешений и с учетом разрядности.
%ch% {08}    ============================================================================================================ {\n #}
echo.
echo.        В данный момент:
%ch%                   Видео: %VideoVal%          Дубликаты: %DuplVal% {\n #}
%ch%               Документы: %DocumVal%        Значок Сеть: %NetIconVal% {\n #}
%ch%                Загрузки: %DownlVal%     Быстрый доступ: %FastAccVal% {\n #}
%ch%             Изображения: %PictuVal% {\n #}
%ch%                  Музыка: %MusicVal%   Иконки глобально: !GlobalIconAll!{\n #}
%ch%            Рабочий стол: %DesktVal%    Иконки у дисков: !AllIconDiskLetter!{\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = {0e}Все папки  {08}(Скрыть/Отобразить)        {0b}[8]{#} = Дубликаты {08}(Скрыть/Отобразить) {\n #}
%ch% {0b}    [2]{#} = Видео  {08}(Скрыть/Отобразить)            {0b}[9]{#} = Значок Сеть {08}(Скрыть/Отобразить) {\n #}
%ch% {0b}    [3]{#} = Документы  {08}(Скрыть/Отобразить)       {0b}[10]{#} = Быстрый доступ {08}(Скрыть/Отобразить) {\n #}
%ch% {0b}    [4]{#} = Загрузки  {08}(Скрыть/Отобразить) {\n #}
%ch% {0b}    [5]{#} = Изображения  {08}(Скрыть/Отобразить)     {0b}[11]{#} = {0e}Иконки дисков {08}(Меню управления){\n #}
%ch% {0b}    [6]{#} = Музыка  {08}(Скрыть/Отобразить) {\n #}
%ch% {0b}    [7]{#} = Рабочий стол  {08}(Скрыть/Отобразить)    {0d}[12]{#} = {0d}Выполнить{#} Перезапуск проводника {08}(Корректно) {\n #}
echo.
%ch% {0e}    [999]{#} = Восстановить все {0e}(по умолчанию) {08}(С корректным перезапуском проводника){\n #}
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1"   ( goto :UserFolderHideALL )
if "%input%"=="2"   ( goto :UserFolderHideSelect )
if "%input%"=="3"   ( goto :UserFolderHideSelect )
if "%input%"=="4"   ( goto :UserFolderHideSelect )
if "%input%"=="5"   ( goto :UserFolderHideSelect )
if "%input%"=="6"   ( goto :UserFolderHideSelect )
if "%input%"=="7"   ( goto :UserFolderHideSelect )
if "%input%"=="8"   ( goto :DuplicateDevices )
if "%input%"=="9"   ( goto :NetIcon )
if "%input%"=="10"  ( goto :FastAccess )
if "%input%"=="11"  ( endlocal & goto :MenuIconDisk )
if "%input%"=="12"  ( Call :ReStartExplorer & endlocal & goto :MenuExplorer )
if "%input%"=="999" ( goto :ExplorerRestore
) else (
 echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
 endlocal & TIMEOUT /T 1 >nul & goto :MenuExplorer
)

:UserFolderHideSelect
echo.
if "%~1"=="QuickApply" set "QuickApply=1" & set "input=%~2"
if "%~1"=="QuickApply" if "%~2" NEQ "" set "QuickApplyDef=2"
if "%input%"=="2"   ( Call :UserFolderHide "Видео" "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" )
if "%input%"=="3"   ( Call :UserFolderHide "Документы" "{d3162b92-9365-467a-956b-92703aca08af}" )
if "%input%"=="4"   ( Call :UserFolderHide "Загрузки" "{088e3905-0323-4b02-9826-5d99428e115f}" )
if "%input%"=="5"   ( Call :UserFolderHide "Изображения" "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" )
if "%input%"=="6"   ( Call :UserFolderHide "Музыка" "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" )
if "%input%"=="7"   ( Call :UserFolderHide "Рабочий стол" "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" )
echo.
if "%QuickApply%"=="1" set "QuickApply=" & set "QuickApplyDef=" & exit /b
goto :MenuExplorer


:UserFolderHideALL
echo.
Call :UserFolderHide "Видео" "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
Call :UserFolderHide "Документы" "{d3162b92-9365-467a-956b-92703aca08af}"
Call :UserFolderHide "Загрузки" "{088e3905-0323-4b02-9826-5d99428e115f}"
Call :UserFolderHide "Изображения" "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
Call :UserFolderHide "Музыка" "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
Call :UserFolderHide "Рабочий стол" "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
echo.
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
TIMEOUT /T 4 >nul & endlocal & goto :MenuExplorer


:UserFolderHide
setlocal
set NameFolder=%~1
set IDFolder=%~2
set KeyFolder="HKCU\SOFTWARE\Classes\CLSID\%IDFolder%" /v "System.IsPinnedToNameSpaceTree"
for /f "tokens=3" %%I in (' 2^>nul reg query %KeyFolder% ^| find "System.IsPinnedToNameSpaceTree" ') do set /a "FolderVal=%%I"
if "%QuickApply%"=="1" if "%QuickApplyDef%"=="" set "FolderVal=0"
if "%QuickApply%"=="1" if "%QuickApplyDef%"=="2" set "FolderVal=1"
if "%FolderVal%"=="0" ( set "FolderVal=1" & set "FolderView={0e}Возврат{#}"  ) else ( set "FolderVal=0" & set "FolderView={0a}Скрытие{#}" )
echo.&%ch%    %FolderView% папки {0b}%NameFolder%{\n #}
reg add "HKCU\SOFTWARE\Classes\CLSID\%IDFolder%" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d %FolderVal% /f
%regad% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\%IDFolder%" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d %FolderVal% /f
if "%FolderVal%"=="0" (
 reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\%IDFolder%" /f 2>nul
 %regdelet% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\%IDFolder%" /f 2>nul
 reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "%IDFolder%" /t REG_DWORD /d 1 /f )
if "%FolderVal%"=="1" (
 reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\%IDFolder%" /f
 %regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\%IDFolder%" /f
 reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "%IDFolder%" /f 2>nul )
if "%QuickApply%"=="1" exit /b
if not "%input%"=="1" ( echo.&%ch%    {2f} Выполнено {00}.{\n #} & TIMEOUT /T 3 >nul )
endlocal
exit /b


:DuplicateDevices
echo.
set KeyDupl86="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
set KeyDupl64="HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
if "%~1"=="QuickApply" ( reg query "HKCU" >nul 2>&1 ) else ( reg query %KeyDupl86% >nul 2>&1 )
if "%ErrorLevel%"=="0" (
 echo.&%ch%          {0a}Скрытие {0b}Дубликатов съемных устройств{\n #}
 reg delete %KeyDupl86% /f & %regdelet% %KeyDupl64% /f
) else (
 echo.&%ch%          {0e}Возврат {0b}Дубликатов съемных устройств{\n #}
 reg add %KeyDupl86% /f & %regad% %KeyDupl64% /f
)
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {0e} Нужен перезапуск проводника {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuExplorer

:NetIcon
echo.
set NetIсon86="HKCU\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes"
for /f "tokens=3" %%I in (' 2^>nul reg query %NetIсon86% ^| find "Attributes" ') do set "NetIconVal=%%I"
if "%~1"=="QuickApply" set "NetIconVal=1"
if "%NetIconVal%"=="0xb0940064" ( set "NetIconVal=0xb0040064" & set "NetIconView={0e}Возврат{#}" ) else ( set "NetIconVal=0xb0940064" & set "NetIconView={0a}Скрытие{#}" )
echo.&%ch%          %NetIconView% {0b}значка Сеть {\n #}
reg add "HKCU\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes" /t REG_DWORD /d %NetIconVal% /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedtoNameSpaceTree" /f 2>nul
%regad% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes" /t REG_DWORD /d %NetIconVal% /f
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedtoNameSpaceTree" /f 2>nul
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {0e} Нужен перезапуск проводника {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuExplorer

:FastAccess
echo.
set FastAccess86="HKCU\SOFTWARE\Classes\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder" /v "Attributes"
for /f "tokens=3" %%I in (' 2^>nul reg query %FastAccess86% ^| find "Attributes" ') do set "FastAccVal=%%I"
if "%~1"=="QuickApply" set "FastAccVal=1"
if "%FastAccVal%"=="0xa0600000" ( set "FastAccVal=0xa0100000" & set "FastAccView={0e}Возврат{#}" ) else ( set "FastAccVal=0xa0600000" & set "FastAccView={0a}Скрытие{#}" )
echo.&%ch%          %FastAccView% {0b}Быстрый доступ {\n #}
reg add "HKCU\SOFTWARE\Classes\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder" /v "Attributes" /t REG_DWORD /d %FastAccVal% /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}" /v "System.IsPinnedtoNameSpaceTree" /f 2>nul
%regad% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder" /v "Attributes" /t REG_DWORD /d %FastAccVal% /f
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}" /v "System.IsPinnedtoNameSpaceTree" /f 2>nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f
echo.
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {0e} Нужен перезапуск проводника {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuExplorer

:ExplorerRestore
echo.
setlocal
echo.&%ch%   Восстановление всех параметров папки {0b}Видео{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f 2>nul
echo.&%ch%   Восстановление всех параметров папки {0b}Документы{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{d3162b92-9365-467a-956b-92703aca08af}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{d3162b92-9365-467a-956b-92703aca08af}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{d3162b92-9365-467a-956b-92703aca08af}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{d3162b92-9365-467a-956b-92703aca08af}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{d3162b92-9365-467a-956b-92703aca08af}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{d3162b92-9365-467a-956b-92703aca08af}" /f 2>nul
echo.&%ch%   Восстановление всех параметров папки {0b}Загрузки{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{088e3905-0323-4b02-9826-5d99428e115f}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{088e3905-0323-4b02-9826-5d99428e115f}" /f 2>nul
echo.&%ch%   Восстановление всех параметров папки {0b}Изображения{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f 2>nul
echo.&%ch%   Восстановление всех параметров папки {0b}Музыка{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Show" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f 2>nul
echo.&%ch%   Восстановление всех параметров папки {0b}Рабочий стол{\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /f 2>nul
%regdelet% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\ShellFolder" /f 2>nul
%regdelet% "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\ShellFolder" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\RemovedFolders" /v "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideMyComputerIcons" /v "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f 2>nul
echo.&%ch%   Восстановление всех параметров {0b}Дубликатов съемных устройств в проводнике{\n #}
set "Dup86=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders"
set "Dup64=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders"
%SetACL% -on "%Dup86%" -ot reg -actn setowner -ownr n:S-1-1-0 -rec yes -silent
%SetACL% -on "%Dup86%" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -actn trustee -trst n1:S-1-1-0;ta:remtrst -rec yes -silent
reg add "%Dup86%\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /v "" /t REG_SZ /d "Removable Drives" /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f 2>nul
if %xOS%==x64 (
%SetACL% -on "%Dup64%" -ot reg -actn setowner -ownr n:S-1-1-0 -rec yes -silent
%SetACL% -on "%Dup64%" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -actn trustee -trst n1:S-1-1-0;ta:remtrst -rec yes -silent
reg add "%Dup64%\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /v "" /t REG_SZ /d "Removable Drives" /f
reg delete "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" /f 2>nul )
echo.&%ch%   Восстановление всех параметров {0b}значка Сети{\n #}
set "NetIсon86=HKEY_CLASSES_ROOT\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
set "NetIсon64=HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
%SetACL% -on "%NetIсon86%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -rec yes -silent
%SetACL% -on "%NetIсon86%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -rec yes -silent
reg delete "%NetIсon86%" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg add "%NetIсon86%\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xb0040064 /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /f 2>nul
%SetACL% -on "%NetIсon86%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -actn setprot -op dacl:p_nc^
 -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -ace n:SYSTEM;p:read -ace n:S-1-5-32-544;p:read -ace n:S-1-5-32-545;p:read^
 -ace n:S-1-15-2-1;p:read -silent
%SetACL% -on "%NetIсon86%\ShellFolder" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -silent
if "%xOS%"=="x64" (
%SetACL% -on "%NetIсon64%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -rec yes -silent
%SetACL% -on "%NetIсon64%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -rec yes -silent
reg delete "%NetIсon64%" /v "System.IsPinnedToNameSpaceTree" /f 2>nul
reg add "%NetIсon64%\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xb0040064 /f
reg delete "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /f 2>nul
%SetACL% -on "%NetIсon64%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -actn setprot -op dacl:p_nc^
 -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -ace n:SYSTEM;p:read -ace n:S-1-5-32-544;p:read -ace n:S-1-5-32-545;p:read^
 -ace n:S-1-15-2-1;p:read -silent
%SetACL% -on "%NetIсon64%\ShellFolder" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -silent )
echo.&%ch%   Восстановление всех параметров {0b}Быстрого доступа{\n #}
set "FastAccess86=HKEY_CLASSES_ROOT\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}"
set "FastAccess64=HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}"
%SetACL% -on "%FastAccess86%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -rec yes -silent
%SetACL% -on "%FastAccess86%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -rec yes -silent
reg add "%FastAccess86%" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
reg add "%FastAccess86%\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xa0100000 /f
reg delete "HKCU\SOFTWARE\Classes\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}" /f 2>nul
%SetACL% -on "%FastAccess86%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -actn setprot -op dacl:p_nc^
 -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -ace n:SYSTEM;p:read -ace n:S-1-5-32-544;p:read -ace n:S-1-5-32-545;p:read^
 -ace n:S-1-15-2-1;p:read -silent
%SetACL% -on "%FastAccess86%\ShellFolder" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -silent
if "%xOS%"=="x64" (
%SetACL% -on "%FastAccess64%" -ot reg -actn setowner -ownr n:S-1-5-32-544 -rec yes -silent
%SetACL% -on "%FastAccess64%" -ot reg -actn ace -ace n:S-1-5-32-544;p:full -rec yes -silent
reg add "%FastAccess64%" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
reg add "%FastAccess64%\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xa0100000 /f
reg delete "HKCU\SOFTWARE\Classes\Wow6432Node\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}" /f 2>nul
%SetACL% -on "%FastAccess64%" -ot reg -actn setowner -ownr "n:NT SERVICE\TrustedInstaller" -actn setprot -op dacl:p_nc^
 -actn ace -ace "n:NT SERVICE\TrustedInstaller;p:full" -ace n:SYSTEM;p:read -ace n:S-1-5-32-544;p:read -ace n:S-1-5-32-545;p:read^
 -ace n:S-1-15-2-1;p:read -silent
%SetACL% -on "%FastAccess64%\ShellFolder" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -actn setowner -ownr n:SYSTEM -silent )
echo.
if "%~1"=="QuickApply" exit /b
Call :ReStartExplorer
echo.&%ch%    {2f} Все выполнено {00}.{\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuExplorer


:: Меню управления иконками дисков
:MenuIconDisk
cd /d "%~dp0"
setlocal EnableDelayedExpansion

for /f "tokens=1,2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find /i "Set-Icon-Disks" ') do (
 set "SetIcon=%%~I" & set "SetIcon=!SetIcon: =!"
 if /i "!SetIcon!"=="Set-Icon-Disks-LOCAL" set "MyIconDisksLOCAL=%%~J"
 if /i "!SetIcon!"=="Set-Icon-Disks-RAM" set "MyIconDisksRAM=%%~J"
 if /i "!SetIcon!"=="Set-Icon-Disks-USB" set "MyIconDisksUSB=%%~J"
)

if "%~1"=="QuickApply" if "!SetIcon!"=="" echo.&%ch%          {0c}Не заданы Иконки в Files\Presets.txt{\n #}& exit /b
if "%~1"=="QuickApply" set "QuickApply=1" & Call :AllDiskInfo
if "%QuickApply%"=="1" goto :ApplyIconDisks

set GlobalIcon="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
for /f "tokens=1,3" %%I in (' 2^>nul reg query %GlobalIcon% /v "7" ^| find "7" ') do (set /a "GlobalIconUSB=%%I" & set "KeyUSB=%%J")
if "%GlobalIconUSB%"=="7" ( set "GlobalIconUSB={0a}Настроено {08}^|{0e} !KeyUSB!{#}" ) else ( set "GlobalIconUSB={0e}Не настроено {08}(по умолчанию){#}" )
for /f "tokens=1,3" %%I in (' 2^>nul reg query %GlobalIcon% /v "8" ^| find "8" ') do (set /a "GlobalIconAll=%%I" & set "KeyAll=%%J")
if "%GlobalIconAll%"=="8" ( set "GlobalIconAll={0a}Настроено {08}^|{0e} !KeyAll!{#}" ) else ( set "GlobalIconAll={0e}Не настроено {08}(по умолчанию){#}" )
set "AllIconDiskLetter="
set RegIconLetter="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons"
for /f "tokens=8 delims=\" %%I in (' 2^>nul reg query %RegIconLetter% ') do (
 if "!AllIconDiskLetter!"=="" ( set "AllIconDiskLetter=%%I:" ) else ( set "AllIconDiskLetter=!AllIconDiskLetter! %%I:" )
)
if "!KeyAll!" EQU "" ( set "IconDiskInfo=   {08}(По умолчанию){#}" ) else ( set "IconDiskInfo= {08}(Возможно по причине одного диска в системе){#}" )
if "!AllIconDiskLetter!"=="" ( set "AllIconDiskLetter={0e}Не заданы !IconDiskInfo!{#}" ) else ( set "AllIconDiskLetter={0a}Заданы    {08}^| {0e}!AllIconDiskLetter!{#}" )
cls
echo.
%ch% {08}    ======================================================================================================== {\n #}
%ch%         Настройка {0e}Иконок дисков {08}(Установка своих иконок для RAM и USB дисков/флешек) {\n #}
echo.        Нельзя заранее знать какие типы дисков будут подключены, но можно пойти хитрым путем.
echo.        Заменить глобально всем дискам на иконку флешки, а локальным и RAM установить иконки на букву.
%ch%         В файле {0f}\Files\Presets.txt{#} - можно задать свои иконки. Иконка системного диска {0a}"%SystemDrive%"{#} не меняется^^^!{\n #}
%ch% {08}    ======================================================================================================== {\n #}
echo.
if "!SetIcon!"=="" (
 echo.&%ch%          {0e}Не заданы иконки в Files\Presets.txt{\n #}
 TIMEOUT /T -1 & endlocal & goto :MenuExplorer
)
echo.             В данный момент параметры:
%ch%       Иконки глобально для {0f}Всех дисков{#}: !GlobalIconAll! {\n #}
%ch%        Иконки глобально для {0f}USB Флешек{#}: !GlobalIconUSB! {\n #}
%ch%         Индивидуальные иконки у дисков: !AllIconDiskLetter! {\n #}
echo.
Call :AllDiskInfo
if "%ErrorLevel%" EQU "1" echo.&%ch%      {0c}Проблема со сценарием PowerShell{#} ^| Возврат в меню настройки проводника{\n #}& TIMEOUT /T -1 & endlocal & goto :MenuExplorer
echo.
echo.        Варианты для выбора:
echo.
if not "!AllLocalDisks!"=="" ( set "ViewLocalDisks={08}^^^|{#} Локальные: {0a}%SystemDrive% !AllLocalDisks!{#} "
) else ( set "ViewLocalDisks={08}^|{#} Локальные: {0a}%SystemDrive%{#} " )
if not "!AllRamDisks!"=="" ( set "ViewRamDisks={08}^^^|{#} RAM: {0d}!AllRamDisks!{#} " )
%ch% {0b}    [1]{#} = Установить иконки, {08}исходя из{#} %ViewLocalDisks%%ViewRamDisks%{08}^|{#} Остальные {0e}USB{\n #}
%ch% {0e}    [2]{#} = Вернуть {0e}по умолчанию {08}(Удалить глобальные и индивидуальные параметры иконок) {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню настройки проводника {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню настройки проводника - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :MenuExplorer )
if "%input%"=="1" ( goto :ApplyIconDisks )
if "%input%"=="2" ( goto :DefaultIconDisks
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
          endlocal & TIMEOUT /T 1 >nul & goto :MenuIconDisk )

:: Сценарий получения информации о дисках в системе, обработка полученных данных, создание переменных и вывод результата
:AllDiskInfo
:: Запуск выполнения скрипта PowerShell для получения списка дисков в системе
powershell.exe -executionpolicy RemoteSigned -file "Files\Tools\ViewMyDisks.ps1"
:: Получение информации о дисках из лог файла сценария PowerShell
set "TypeDisk="
set "AllRamDisks="
set "AllLocalDisks="
set "AllDisks=%Temp%\AllDisks.log"
if not exist "%AllDisks%" exit /b 1
for /f "tokens=1*" %%I in (' type "%AllDisks%" ^| find /i " Ф/с " ') do (%ch%        {80} %%I %%J{00}.{\n #})
for /f "tokens=1-8 delims=|" %%I in (' type "%AllDisks%" ^| find "|" ') do (
 set "TypeDisk=%%M" & set "TypeDisk=!TypeDisk: =!"
 if "!TypeDisk!"=="HDD" (set C=0e) else (if "!TypeDisk!"=="SSD" (set C=0a) else (if "!TypeDisk!"=="RAM" (set C=0d) else (if "!TypeDisk!"=="Virtual" (set C=0e) else (set C=07))))
 %ch%         {!C!}%%I{#} %%J %%K %%L {!C!}%%M{#} %%N %%O {\n #}
 if not "%%I"=="%SystemDrive%" (if "!TypeDisk!"=="HDD" (if "!AllLocalDisks!"=="" (set "AllLocalDisks=%%I") else (set "AllLocalDisks=!AllLocalDisks! %%I")))
 if not "%%I"=="%SystemDrive%" (if "!TypeDisk!"=="SSD" (if "!AllLocalDisks!"=="" (set "AllLocalDisks=%%I") else (set "AllLocalDisks=!AllLocalDisks! %%I")))
 if not "%%I"=="%SystemDrive%" (if "!TypeDisk!"=="Virtual" (if "!AllLocalDisks!"=="" (set "AllLocalDisks=%%I") else (set "AllLocalDisks=!AllLocalDisks! %%I")))
 if not "%%I"=="%SystemDrive%" (if "!TypeDisk!"=="RAM" (if "!AllRamDisks!"==""   (set "AllRamDisks=%%I") else (set "AllRamDisks=!AllRamDisks! %%I")))
)
del /f /q "%AllDisks%" 2>nul
exit /b

:: Сценарий настройки иконок у дисков, на основании полученных данных
:ApplyIconDisks
echo.&%ch%     {0b}Установка{#} глобальных параметров иконок: {0a}Всем дискам {08}^| {0e}"!MyIconDisksUSB!"{\n #}
:: Установка глобально иконки для флешек:
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "7" /t REG_EXPAND_SZ /d "!MyIconDisksUSB!" /f
%regad% "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "7" /t REG_EXPAND_SZ /d "!MyIconDisksUSB!" /f
:: Установка глобально иконки для локальных и USB дисков.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "8" /t REG_EXPAND_SZ /d "!MyIconDisksUSB!" /f
%regad% "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "8" /t REG_EXPAND_SZ /d "!MyIconDisksUSB!" /f
:: Установка индивидуально иконок для локальных дисков (возврат обычных иконок, после установки глобальных)
if not "!AllLocalDisks!"=="" (
 for %%I in (!AllLocalDisks!) do (
  set "LocalDisk=%%I" & set "LocalDisk=!LocalDisk:~0,1!"
  echo.&%ch%     {0b}Установка{#} иконки индивидуально для Локального Диска: {0a}"!LocalDisk!" {08}^| {0e}"!MyIconDisksLOCAL!" {\n #}
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\!LocalDisk!\DefaultIcon" /v "" /t REG_EXPAND_SZ /d "!MyIconDisksLOCAL!" /f
 )
)
:: Установка индивидуально иконок для RAM дисков:
if not "!AllRamDisks!"=="" (
 for %%I in (!AllRamDisks!) do (
  set "RamDisk=%%I" & set "RamDisk=!RamDisk:~0,1!"
  echo.&%ch%     {0b}Установка{#} иконки индивидуально для RAM Диска: {0a}"!RamDisk!" {08}^| {0e}"!MyIconDisksRAM!"{\n #}
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons\!RamDisk!\DefaultIcon" /v "" /t REG_EXPAND_SZ /d "!MyIconDisksRAM!" /f
 )
)
echo.
if "%~1"=="QuickApply" exit /b
Call :ReStartExplorer
echo.&%ch%     {2f} Выполнено {00}.{\n #} &echo.
TIMEOUT /T -1 & endlocal & goto :MenuIconDisk

:DefaultIconDisks
echo.&%ch%     {0b}Удаление{#} иконок: {0a}У всех дисков {08}(Глобальные и индивидуальные параметры){\n #}
:: удаление всех глобальных параметров для иконок:
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /va /f 2>nul
%regdelet% "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /va /f 2>nul
:: Удаление всех индивидуальных иконок для букв дисков
for /f "tokens=1*" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DriveIcons" ') do (
 reg delete "%%I" /f
)
echo.
if "%~1"=="QuickApply" exit /b
Call :ReStartExplorer
echo.&%ch%    {2f} Все восстановлено {00}.{\n #} &echo.
TIMEOUT /T -1 & endlocal & goto :MenuIconDisk
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Меню восстановления стандартного просмотрщика фото
:MenuWPV
setlocal EnableDelayedExpansion
:::::    Проверка поддержки графических файлов:
set WPVkey1="HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
for /f "tokens=3" %%I in (' 2^>nul reg query %WPVKey1% /s ^| find ".jpg" ') do set "WPVval1=%%I"
if "%WPVval1%"=="PhotoViewer.FileAssoc.Jpeg" ( set "WPVreply1={0a}Возвращена{#}" ) else ( set "WPVreply1={0e}Не восстановлена{#}" )
:::::    Проверка параметров для ассоциаций:
set WPVkey2="HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg"
for /f "tokens=1" %%I in (' 2^>nul reg query %WPVKey2% ^| find "PhotoViewer.FileAssoc.Jpeg" ') do set "WPVval2=%%I"
if "%WPVval2%"=="" ( set "WPVreply2={0e}Не настроены{#}" ) else ( set "WPVreply2={0a}Настроены{#}" )
:::::    Проверка назначения ассоциаций на открытие:
set WPVkey3="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\UserChoice" /v "Progid"
for /f "tokens=1" %%I in (' 2^>nul reg query %WPVKey3% ^| find "jpegfile" ') do set "WPVval3=%%I"
if "%WPVval3%"=="" ( set "WPVreply3={0e}Не сделано{#}" ) else ( set "WPVreply3={0a}Сделано{#}" )
cls
echo.
%ch% {08}    ==================================================================================== {\n #}
%ch%         Восстановление {0e}Стандартного просмотрщика Фото {08}(Windows Photo Viewer){\n #}
echo.        Возврат поддержки графических файлов и добавление в меню для их открытия
echo.        Назначение на открытие графических файлов, с восстановлением параметров для:
%ch%         {0e}.jpg .jpe .jpeg .jfif .bmp .dib .wdp .jxr .png .tiff .tif .ico {\n #}
%ch% {08}    ==================================================================================== {\n #}
echo.
echo.        В данный момент:
%ch%               Поддержка: %WPVreply1% {\n #}
%ch%               Параметры: %WPVreply2% {\n #}
%ch%              Назначение: %WPVreply3% {08}(проверка по .jpg){\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = Вернуть только поддержку {08}(Возвращает все параметры Windows Photo Viewer){\n #}
%ch% {0b}    [2]{#} = Вернуть поддержку и назначить/переназначить на открытие {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :WPVreturn )
if "%input%"=="2" ( goto :WPVreturn
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
          endlocal & TIMEOUT /T 1 >nul & goto :MenuWPV )

:WPVreturn
echo.
%ch%    {0a} Возврат {0b}поддержки графических файлов {08}(Windows Photo Viewer){\n #}
set RegAssoc="HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
reg add %RegAssoc% /v ".bmp"  /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f
reg add %RegAssoc% /v ".dib"  /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f
reg add %RegAssoc% /v ".jpg"  /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f
reg add %RegAssoc% /v ".jpe"  /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f
reg add %RegAssoc% /v ".jpeg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f
reg add %RegAssoc% /v ".jfif" /t REG_SZ /d "PhotoViewer.FileAssoc.JFIF" /f
reg add %RegAssoc% /v ".png"  /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f
reg add %RegAssoc% /v ".wdp"  /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f
reg add %RegAssoc% /v ".jxr"  /t REG_SZ /d "PhotoViewer.FileAssoc.Wdp" /f
reg add %RegAssoc% /v ".tif"  /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f
reg add %RegAssoc% /v ".tiff" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f
reg add %RegAssoc% /v ".ico"  /t REG_SZ /d "PhotoViewer.FileAssoc.Ico" /f
rem reg add %RegAssoc% /v ".gif"  /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f

echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}photoviewer.dll {\n #}
reg add "HKLM\SOFTWARE\Classes\Applications\photoviewer.dll\shell\open" /v "MuiVerb" /t REG_SZ /d "@photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\Applications\photoviewer.dll\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.Jpeg {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "EditFlags" /t REG_DWORD /d "0x10000" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\jpegfile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\jpegfile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\jpegfile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.Bitmap {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3056" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-70" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\Paint.Picture\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\Paint.Picture\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\Paint.Picture\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "PBrush_.bmp" /t REG_DWORD  /d 0 /f
echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.Png {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Png" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-71" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Png\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\pngfile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\pngfile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\pngfile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.Wdp {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "EditFlags" /t REG_DWORD /d "0x10000" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\wmphoto.dll,-400" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\wdpfile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\wdpfile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\wdpfile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
echo.
%ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.JFIF {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "EditFlags" /t REG_DWORD /d "0x10000" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3055" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\pjpegfile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\pjpegfile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\pjpegfile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
echo.
%ch%    {0a} Добавление параметров {#}для ассоциаций {0b}.Ico {\n #}
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-70" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Ico\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

reg add "HKLM\SOFTWARE\Classes\icofile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
reg add "HKLM\SOFTWARE\Classes\icofile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
reg add "HKLM\SOFTWARE\Classes\icofile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

rem echo.
rem %ch%    {0a} Возврат параметров {#}для ассоциаций {0b}.Gif {\n #}
rem reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "ImageOptionFlags" /t REG_DWORD /d "0x1" /f
rem reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif" /v "FriendlyTypeName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll,-3057" /f
rem reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\DefaultIcon" /v "" /t REG_SZ /d "%%SystemRoot%%\System32\imageres.dll,-83" /f
rem reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
rem reg add "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

rem reg add "HKLM\SOFTWARE\Classes\giffile\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3043" /f
rem reg add "HKLM\SOFTWARE\Classes\giffile\shell\open\command" /v "" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f
rem reg add "HKLM\SOFTWARE\Classes\giffile\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

echo.
::::::  Установка программы "Windows Photo Viewer" для открытия по умолчанию указанных раcширений
::::::  И восстановление всех оригинальных параметров у расширений:
if "%~1"=="QuickApply" set "QuickApply=1"
if "%~1"=="QuickApply" if "%~2"=="2" set "input=2"
if "%input%"=="2" (
 Call :ApplyWPVdef "jpg"  "jpegfile"          "jpeg"          "Jpeg"
 Call :ApplyWPVdef "jpe"  "jpegfile"          "jpeg"          "Jpeg"
 Call :ApplyWPVdef "jpeg" "jpegfile"          "jpeg"          "Jpeg"
 Call :ApplyWPVdef "jfif" "pjpegfile"         "jpeg"          "JFIF"
 Call :ApplyWPVdef "bmp"  "Paint.Picture"     "bmp"           "Bitmap"
 Call :ApplyWPVdef "dib"  "Paint.Picture"     "bmp"           "Bitmap"
 Call :ApplyWPVdef "wdp"  "wdpfile"           "vnd.ms-photo"  "Wdp"
 Call :ApplyWPVdef "jxr"  "wdpfile"           "vnd.ms-photo"  "Wdp"
 Call :ApplyWPVdef "png"  "pngfile"           "png"           "Png"
 Call :ApplyWPVdef "tiff" "TIFImage.Document" "tiff"          "Tiff"
 Call :ApplyWPVdef "tif"  "TIFImage.Document" "tiff"          "Tiff"
 Call :ApplyWPVdef "ico"  "icofile"           "x-icon"        "Ico"
 rem Call :ApplyWPVdef "gif"  "giffile"           "gif"           "Gif"
 echo.
 %ch%   {0b}Обновление кэша проводника {08}^(для обновления иконок^){\n #}
echo.
%NirCMDc% shellrefresh
TIMEOUT /T 1 >nul
)
if "%QuickApply%"=="1" set "QuickApply=" & set "input=" & exit /b
echo.&%ch%   {2f} Все выполнено {00}.{\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuWPV

:ApplyWPVdef
Setlocal EnableDelayedExpansion
set "SetExt=%~1"
set "SetType=%~2"
set "SetContentType=%~3"
set "SetAssoc=%~4"
echo.
%ch% === {0a}Назначение и восстановление параметров {#}у расширения {0b}.%SetExt%{#} === {\n #}
echo.
reg add "HKCR\.%SetExt%" /v "" /t REG_SZ /d "%SetType%" /f
reg add "HKCR\.%SetExt%" /v "Content Type" /t REG_SZ /d "image/%SetContentType%" /f
reg add "HKCR\.%SetExt%" /v "PerceivedType" /t REG_SZ /d "image" /f
reg delete "HKCR\.%SetExt%\OpenWithProgids" /va /f >nul 2>&1
reg add "HKCR\.%SetExt%\OpenWithProgids" /v "%SetType%" /t REG_SZ  /d "" /f
reg add "HKCR\.%SetExt%\PersistentHandler" /t REG_SZ  /d "{098f2470-bae0-11cd-b579-08002b30bfeb}" /f
echo.
reg add "HKLM\SOFTWARE\Classes\.%SetExt%" /v "" /t REG_SZ /d "%SetType%" /f
reg add "HKLM\SOFTWARE\Classes\.%SetExt%" /v "Content Type" /t REG_SZ /d "image/%SetContentType%" /f
reg add "HKLM\SOFTWARE\Classes\.%SetExt%" /v "PerceivedType" /t REG_SZ /d "image" /f
reg delete "HKLM\SOFTWARE\Classes\.%SetExt%\OpenWithProgids" /va /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\.%SetExt%\OpenWithProgids" /v "%SetType%" /t REG_SZ  /d "" /f
reg add "HKLM\SOFTWARE\Classes\.%SetExt%\PersistentHandler" /t REG_SZ  /d "{098f2470-bae0-11cd-b579-08002b30bfeb}" /f
echo.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "PhotoViewer.FileAssoc.%SetAssoc%_.%SetExt%" /t REG_DWORD  /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts" /v "PBrush_.%SetExt%" /t REG_DWORD  /d 0 /f
echo.
set "KEY=HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%SetExt%"
reg delete "%KEY%" /va /f >nul 2>&1
reg delete "%KEY%\OpenWithProgids" /va /f >nul 2>&1
:: Метод записи параметра "REG_NONE", так как reg.exe не поддерживает назначение этого типа параметра.
set "RegFile=%TEMP%\%SetAssoc%.reg"
( echo Windows Registry Editor Version 5.00
  echo [%KEY%\OpenWithProgids]
  echo "%SetType%"=hex^(0^):
  )>"%RegFile%"
reg import "%RegFile%"
del /f /q "%RegFile%" 2>nul
:: Разблокировка раздела UserChoice, блок ставит GUI настроек
for /f %%I in (' 2^>nul reg query "%KEY%" /s /f "UserChoice" /k ^| find "UserChoice" ') do (
%SetACL% -on "%KEY%\UserChoice" -ot reg -actn clear -clr dacl -actn setprot -op dacl:np -silent )
if "%SetExt%" EQU "ico" set "SetType=Applications\photoviewer.dll"
reg delete "%KEY%\UserChoice" /va /f >nul 2>&1
reg add "%KEY%\UserChoice" /v "Progid" /d "%SetType%" /f
:: Блокировка раздела UserChoice, такая же, какую ставит GUI настроек
%SetACL% -on "%KEY%\UserChoice" -ot reg -actn ace -ace "n:%ComputerName%\%UserName%;p:set_val;m:deny;i:np" -silent
echo.
reg delete "HKCU\SOFTWARE\Microsoft\Windows\Roaming\OpenWith\FileExts\.%SetExt%\UserChoice" /va /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\Roaming\OpenWith\FileExts\.%SetExt%\UserChoice" /v "Progid" /t  REG_SZ /d "%SetType%" /f
echo.
reg delete "%KEY%\OpenWithList" /ve /f >nul 2>&1
:: Добавление в историю назначенных программ для открытия файлов "MRUList", с сохранением порядка
for /f "tokens=1" %%I in (' 2^>nul reg query "%KEY%\OpenWithList" /f "PhotoViewer.dll" /d ^| find "PhotoViewer.dll" ') do (
 for /f "tokens=3" %%I in (' 2^>nul reg query "%KEY%\OpenWithList" /v "MRUList" ') do set MRU=%%I
 set MRU=!MRU:%%I=!
 reg add "%KEY%\OpenWithList" /v "MRUList" /t REG_SZ /d "%%I!MRU!" /f
 exit /b
)
for %%I in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
 set R=reg query
 if "!B!"=="1" set R=rem
 !R! "%KEY%\OpenWithList" /v "%%I" >nul 2>&1 || (
  for /f "tokens=3" %%J in (' 2^>nul reg query "%KEY%\OpenWithList" /v "MRUList" ') do (
   set MRU=%%J
   set MRU=!MRU:%%I=!
   reg add "%KEY%\OpenWithList" /v "%%I" /d "PhotoViewer.dll" /f
   reg add "%KEY%\OpenWithList" /v "MRUList" /d "%%I!MRU!" /f
   set B=1
  )
 )
)
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Переименование компьютера.
:CompReNameIn
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Comp-Name" ') do set "Set-Comp-Name=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-Comp-Name%') do set "MyCompName=%%I"

if "%~1"=="QuickApply" if "%MyCompName%"=="" echo.&%ch%          {0c}Не задано имя Компьютера в Files\Presets.txt{\n #}& exit /b
if "%~1"=="QuickApply" set "QuickApply=1" & goto :CompReName

cls
echo.
%ch% {08}     ========================================================== {\n #}
%ch%          {0e}Переименование компьютера {\n #}
%ch%          Можете указать свое имя в файле {0f}\Files\Presets.txt {\n #}
%ch% {08}     ========================================================== {\n #}
echo.
%ch%          Название сейчас: {0a}%computername% {\n #}
echo.
if "%MyCompName%"=="" (
 %ch%          {0e}Не задано имя в Files\Presets.txt{\n #}
 TIMEOUT /T -1 & endlocal & goto :SelfStat)
echo.         Варианты для выбора:
echo.
%ch% {0b}     [1]{#} = Переименовать в {0e}%MyCompName% {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :CompReName
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :CompReNameIn )

:CompReName
echo.
@Echo on
wmic computersystem where name="%computername%" call rename name="%MyCompName%"
@Echo off
if "%QuickApply%"=="1" exit /b
echo. & %ch%      {0a}- Имя компьюера сменится после перезагрузки^^^!^^^!^^^! - {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Меню управления контролем учетных записей
:MenuUAC
setlocal EnableDelayedExpansion
set LUA="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA"
for /f "tokens=3" %%I in (' 2^>nul reg query %LUA% ^| find "EnableLUA" ') do set /a "LuaVal=%%I"
if not "!LuaVal!"=="" (
 if "!LuaVal!"=="0" ( set "LuaVal={0a}Не отображаются{#}"
  ) else ( if "!LuaVal!"=="1" ( set "LuaVal={0e}Выводятся {08}(по умолчанию){#}"
  ) else ( set "LuaVal={0c}Параметр Неправильный {#}" )
 )
) else ( set "LuaVal={0c}Параметр отсутствует {#}" )
set SecureDesktop="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop"
for /f "tokens=3" %%I in (' 2^>nul reg query %SecureDesktop% ^| find "PromptOnSecureDesktop" ') do set /a "SecureDesktopVal=%%I"
if not "!SecureDesktopVal!"=="" (
 if "!SecureDesktopVal!"=="0" ( set "SecureDesktopVal={0a}Через интерактивный рабочий стол{#}"
  ) else ( if "!SecureDesktopVal!"=="1" ( set "SecureDesktopVal={0e}Через безопасный рабочий стол {08}(по умолчанию){#}"
  ) else ( set "SecureDesktopVal={0c}Параметр Неправильный {#}" )
 )
) else ( set "SecureDesktopVal={0c}Параметр отсутствует {#}" )
set ConsentAdmin="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin"
for /f "tokens=3" %%I in (' 2^>nul reg query %ConsentAdmin% ^| find "ConsentPromptBehaviorAdmin" ') do set /a "ConsentAdminVal=%%I"
if not "!ConsentAdminVal!"=="" (
 if "!ConsentAdminVal!"=="0" ( set "ConsentAdminVal={0a}Соглашаться Автоматически{#}"
  ) else ( if "!ConsentAdminVal!"=="2" ( set "ConsentAdminVal={0e}Спрашивать для всех программ {0a}(Усиленный режим){#}"
  ) else ( if "!ConsentAdminVal!"=="5" ( set "ConsentAdminVal={0e}Спрашивать для несистемных программ {08}(по умолчанию){#}"
  ) else ( set "ConsentAdminVal={0c}Параметр не описан {#}" )
  )
 )
) else ( set "ConsentAdminVal={0c}Параметр отсутствует {#}" )
set VirtKey="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization"
for /f "tokens=3" %%I in (' 2^>nul reg query %VirtKey% ^| find "EnableVirtualization" ') do set /a "VirtKeyVal=%%I"
if not "!VirtKeyVal!"=="" (
 if "!VirtKeyVal!"=="0" ( set "VirtKeyVal={0a}Отключена{#}"
  ) else ( if "!VirtKeyVal!"=="1" ( set "VirtKeyVal={0e}Включена {08}(по умолчанию){#}"
  ) else ( set "VirtKeyVal={0c}Параметр неверный  {#}" )
 )
) else ( set "VirtKeyVal={0c}Параметр отсутствует {#}" )
set VirtDriver="HKLM\SYSTEM\CurrentControlSet\services\luafv" /v "Start"
for /f "tokens=3" %%I in (' 2^>nul reg query %VirtDriver% ^| find "Start" ') do set /a "VirtDriverVal=%%I"
if "!VirtDriverVal!"=="2" ( set "VirtDriverVal={0e}Включен {08}(по умолчанию){#}"
 ) else ( if "!VirtDriverVal!"=="4" ( set "VirtDriverVal={0a}Отключен {#}"
 ) else ( set "VirtDriverVal={0c}Параметр не описан {#}" )
)
cls
echo.
%ch% {08}    ================================================================================== {\n #}
%ch%         Настройка {0e}Контроля учетных записей {08}(UAC) {\n #}
%ch%         Отключение или {0a}авто{#}соглашение UAC ведет к серьезной бреши в безопасности^^^!{\n #}
%ch%         {0b}Категорически не рекомендуется отключать или ослаблять UAC^^^! {\n #}
%ch% {08}    ================================================================================== {\n #}
echo.
echo.            В данный момент:
%ch%             Окна с запросом: !LuaVal!  {\n #}
%ch%          Обработка запросов: !SecureDesktopVal!  {\n #}
%ch%          Поведение запросов: !ConsentAdminVal!  {\n #}
%ch%       Виртуализация доступа: !VirtKeyVal!  {\n #}
%ch%       Драйвер Виртуализации: !VirtDriverVal!  {\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = Автосоглашение на повышение прав {08}(Только для пользователей из группы Администраторы) {\n #}
%ch% {0b}    [2]{#} = Отключить UAC полностью {08}(Для всех пользователей) {\n #}
%ch% {0b}    [3]{#} = Усиленный режим UAC {08}(Запросы для всех программ, при доступе к системным данным. Безопаснее) {\n #}
echo.
%ch% {0e}    [4]{#} = Восстановить настройку UAC {0e}(по умолчанию) {0f}Рекомендуется, если UAC отключен^^^! {\n #}
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :AutoAcceptUAC )
if "%input%"=="2" ( goto :DisableUAC )
if "%input%"=="3" ( goto :ForceUAC )
if "%input%"=="4" ( goto :DefaultUAC
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
          endlocal & TIMEOUT /T 1 >nul & goto :MenuUAC )

:: Сценарий установки автосоглашения на повышение прав, при запросе UAC
:AutoAcceptUAC
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\luafv" /v "Start" /t REG_DWORD /d 2 /f
:: Автоматически соглашаться на повышение прав, при запросе для Учетных записей из групп "Администраторы"
:: Запрос системе поступает, и если учетка админа, то выполняется автосоглашение на повышение прав.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
echo.
%ch% {08}    ============================================= {\n #}
%ch%         {0a}Необходима Перезагрузка компьютера^^^!^^^!^^^! {\n #}
%ch% {08}    ============================================= {\n #}
echo.
TIMEOUT /T 4 >nul & endlocal & goto :MenuUAC

:: Сценарий отключения UAC полностью
:DisableUAC
echo.
:: Отключить режим одобрения администратором
:: Окна с запросом повышения прав не предлагаются вообще для всех пользователей.
:: Если нет автосоглашения повышения прав, то повышения не будет.
:: Сами запросы идут, просто не отображаются пользователю.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f
:: Выполнение запросов на повышение прав обрабатывать через интерактивный рабочий стол (без затемнения экрана)
:: не через "безопасный рабочий стол" (с затемнением экрана)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f
:: Автоматически соглашаться на повышение прав при запросе для Учетных записей из группы "Администраторы"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f
:: Отключить виртуализацию, перехват функций через драйвер luafv.sys - отслеживание чтения или записи в защищенные области системы
:: т.е. все программы получают сразу доступ к важным файлам системы и реестру. Ненужен и тормозит систему, при отключенном UAC.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\luafv" /v "Start" /t REG_DWORD /d 4 /f
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
echo.
%ch% {08}    ============================================= {\n #}
%ch%         {0a}Необходима Перезагрузка компьютера^^^!^^^!^^^! {\n #}
%ch% {08}    ============================================= {\n #}
echo.
TIMEOUT /T 4 >nul & endlocal & goto :MenuUAC

:: Сценарий включения усиленного режима UAC
:ForceUAC
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\luafv" /v "Start" /t REG_DWORD /d 2 /f
:: Усиленный режим UAC. Запрос поступает для всех приложений, при доступе к системным данным, включая доверенные системные, с автовалидацией.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 2 /f
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
echo.
%ch% {08}    ============================================= {\n #}
%ch%         {0a}Необходима Перезагрузка компьютера^^^!^^^!^^^! {\n #}
%ch% {08}    ============================================= {\n #}
echo.
TIMEOUT /T 4 >nul & endlocal & goto :MenuUAC

:: Сценарий восстановления всех параметров UAC по умолчанию.
:DefaultUAC
echo.
:: Включить режим UAC одобрения администратором, отображать окно с запросом
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
:: Запросы на повышение прав обрабатывать через безопасный рабочий стол (с затемнением экрана)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f
:: Выводить запрос на согласие для двоичных данных не из Windows для Учетных записей из группы "Администраторы"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f
:: Включить виртуализацию, перехват функций через драйвер luafv.sys - отслеживание чтения или записи в защищенные области системы
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\luafv" /v "Start" /t REG_DWORD /d 2 /f
if "%~1"=="QuickApply" exit /b
echo.&%ch%    {2f} Все выполнено {00}.{\n #}
echo.
%ch% {08}    ============================================= {\n #}
%ch%         {0a}Необходима Перезагрузка компьютера^^^!^^^!^^^! {\n #}
%ch% {08}    ============================================= {\n #}
echo.
TIMEOUT /T 4 >nul & endlocal & goto :MenuUAC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




:: Меню изменения расположения папок текущего пользователя
:MenuUserFoldersLocation
Setlocal EnableDelayedExpansion
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Dir-User-Folders" ') do set "Set-Dir-User-Folders=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-Dir-User-Folders%') do set "DirFolder=%%I"
set "DirFolderAll=%DirFolder%"
for /f "tokens=*" %%I in ('echo.%DirFolder%\ ^| find "\\"') do set "PathError={0c}◄─ Ошибка{#}"
for /f "tokens=*" %%I in ('echo.%DirFolder%\ ^| find "/" ') do set "PathError={0c}◄─ Ошибка{#}"
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Dir-User-Downloads" ') do set "Set-Dir-User-Downloads=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-Dir-User-Downloads%') do set "DirFolderDownloads=%%I"
for /f "tokens=*" %%I in ('echo.%DirFolderDownloads%\ ^| find "\\"') do set "PathError2={0c}◄─ Ошибка{#}"
for /f "tokens=*" %%I in ('echo.%DirFolderDownloads%\ ^| find "/" ') do set "PathError2={0c}◄─ Ошибка{#}"
set "Spaces=" & set "NS=1"
for /l %%I in (1, 1, 27) do ( set "LineLength=!DirFolder:~%%I!" & if defined LineLength set /a "NS+=1" )
for /l %%I in (27, -1, !NS!) do set "Spaces= !Spaces!"
set "Spaces2=" & set "NS=1"
for /l %%I in (1, 1, 27) do ( set "LineLength2=!DirFolderDownloads:~%%I!" & if defined LineLength2 set /a "NS+=1" )
for /l %%I in (27, -1, !NS!) do set "Spaces2= !Spaces2!"
set "Key=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer"
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "My Video" ^| find "My Video" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirVideo=%%I"
if exist "%FindDirVideo%" ( set "DirVideoFolder=^| {0a}Папка существует{#}" ) else ( set "DirVideoFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirVideo%"=="%UserProfile%\Videos" ( set "FindDirVideo={0e}%FindDirVideo%    {08}(Параметр по умолчанию){#}" ) else ( set "FindDirVideo={0a}%FindDirVideo%{#}   " )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirVideoFolder=" & set "FindDirVideo={0c}Параметр в реестре отсутствует^^^^^!{#}" )
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "Personal" ^| find "Personal" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirDocum=%%I"
if exist "%FindDirDocum%" ( set "DirDocumFolder=^| {0a}Папка существует{#}" ) else ( set "DirDocumFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirDocum%"=="%UserProfile%\Documents" ( set "FindDirDocum={0e}%FindDirDocum% {08}(Параметр по умолчанию){#}" ) else ( set "FindDirDocum={0a}%FindDirDocum%{#}" )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirDocumFolder=" & set "FindDirDocum={0c}Параметр в реестре отсутствует^^^^^!{#}" )
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" ^| find "{374DE290-123F-4565-9164-39C4925E467B}" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirDownl=%%I"
if exist "%FindDirDownl%" ( set "DirDownlFolder=^| {0a}Папка существует{#}" ) else ( set "DirDownlFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirDownl%"=="%UserProfile%\Downloads" ( set "FindDirDownl={0e}%FindDirDownl% {08}(Параметр по умолчанию){#}" ) else ( set "FindDirDownl={0a}%FindDirDownl%{#}" )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirDownlFolder=" & set "FindDirDownl={0c}Параметр в реестре отсутствует^^^^^!{#}" )
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "My Pictures" ^| find "My Pictures" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirPictu=%%I"
if exist "%FindDirPictu%" ( set "DirPictuFolder=^| {0a}Папка существует{#}" ) else ( set "DirPictuFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirPictu%"=="%UserProfile%\Pictures" ( set "FindDirPictu={0e}%FindDirPictu%  {08}(Параметр по умолчанию){#}" ) else ( set "FindDirPictu={0a}%FindDirPictu%{#} " )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirPictuFolder=" & set "FindDirPictu={0c}Параметр в реестре отсутствует^^^^^!{#}" )
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "My Music" ^| find "My Music" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirMusic=%%I"
if exist "%FindDirMusic%" ( set "DirMusicFolder=^| {0a}Папка существует{#}" ) else ( set "DirMusicFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirMusic%"=="%UserProfile%\Music" ( set "FindDirMusic={0e}%FindDirMusic%     {08}(Параметр по умолчанию){#}" ) else ( set "FindDirMusic={0a}%FindDirMusic%{#}    " )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirMusicFolder=" & set "FindDirMusic={0c}Параметр в реестре отсутствует^^^^^!{#}" )
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "Desktop" ^| find "Desktop" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDirDeskt=%%I"
if exist "%FindDirDeskt%" ( set "DirDesktFolder=^| {0a}Папка существует{#}" ) else ( set "DirDesktFolder=^^^| {0c}Папка не существует^^^!{#}" )
if "%FindDirDeskt%"=="%UserProfile%\Desktop" ( set "FindDirDeskt={0e}%FindDirDeskt%   {08}(Параметр по умолчанию){#}" ) else ( set "FindDirDeskt={0a}%FindDirDeskt%{#}  " )
for /f "tokens=*" %%I in ('echo.!FindDir! ^| find "*"') do ( set "DirDesktFolder=" & set "FindDirDeskt={0c}Параметр в реестре отсутствует^^^^^!{#}" )
for %%A in ( "My Video" "Personal" "{374DE290-123F-4565-9164-39C4925E467B}" "My Pictures" "My Music" "Desktop" ) do (
 for /f "tokens=*" %%B in (' 2^>nul reg query "%Key%\User Shell Folders" /v "%%~A" ^| find "%%~A" ') do (
  set "FindDir=%%~B"
  set "FindDir=!FindDir:*_SZ=!"
  for /f "tokens=*" %%C in ('echo.!FindDir!') do (
   set "FindDir=%%~C"
   for /f %%D in (' echo."%~dp0" ^| find "!FindDir!" ') do set "LockFolder=!FindDir!")))
echo."%FindDirVideo%" | find "!LockFolder!" >nul && set "VideoLock= {0c}◄─ Батник тут^!{#}"
echo."%FindDirDocum%" | find "!LockFolder!" >nul && set "DocumLock= {0c}◄─ Батник тут^!{#}"
echo."%FindDirDownl%" | find "!LockFolder!" >nul && set "DownlLock= {0c}◄─ Батник тут^!{#}"
echo."%FindDirPictu%" | find "!LockFolder!" >nul && set "PictuLock= {0c}◄─ Батник тут^!{#}"
echo."%FindDirMusic%" | find "!LockFolder!" >nul && set "MusicLock= {0c}◄─ Батник тут^!{#}"
echo."%FindDirDeskt%" | find "!LockFolder!" >nul && set "DesktLock= {0c}◄─ Батник тут^!{#}"
cls
echo.
%ch% {08}    ============================================================================================================ {\n #}
%ch%         Изменение {0e}Расположения папок текущего пользователя. {0b}Завершите и закройте всё перед выполнением^^^!^^^!^^^!{\n #}
%ch%         В файле {0f}\Files\Presets.txt{#} - задано расположение: {0e}"%DirFolder%\" %PathError%{\n #}
%ch%         И отдельное расположение для папки Загрузки: {0e}"%DirFolderDownloads%\" %PathError2%{\n #}
echo.        Всегда выполняется копирование, а затем удаление всех исходных файлов и Настройка прав безопасности^^^!
%ch% {08}    ============================================================================================================ {\n #}
echo.
echo.        Расположение папок в данный момент:
%ch%                Видео: %FindDirVideo% %DirVideoFolder% !VideoLock!{\n #}
%ch%            Документы: %FindDirDocum% %DirDocumFolder% !DocumLock!{\n #}
%ch%             Загрузки: %FindDirDownl% %DirDownlFolder% !DownlLock!{\n #}
%ch%          Изображения: %FindDirPictu% %DirPictuFolder% !PictuLock!{\n #}
%ch%               Музыка: %FindDirMusic% %DirMusicFolder% !MusicLock!{\n #}
%ch%         Рабочий стол: %FindDirDeskt% %DirDesktFolder% !DesktLock!{\n #}
if "!LockFolder!" NEQ "" (
 echo.
 %ch%  {0c}   ──────────────────────────────────────────────────────────────────────────────────────────────────────────── {\n #}
 %ch%  {0c}       Батник расположен в папке: {0e}%~dp0{\n #}&echo.
 %ch%  {0e}       Папка с батником не должна находиться в папках для изменения расположения: {\n #}
 %ch%  {0f}         Видео, Документы, Загрузки, Изображения, Музыка, Рабочий стол{\n #}&echo.
 %ch%  {0e}       Перенесите папку с батником в другое место^^^! {\n #}
 echo.&echo.&echo.    Для возврата в меню Личных настроек нажмите любую клавишу.
 TIMEOUT /T -1 >nul & endlocal & goto :SelfStat )
if not "%PathError%"=="" (
 echo.
 %ch%  {0c}   ──────────────────────────────────────────────────────────────────────────────────────────────────────────── {\n #}
 %ch%         {0e}Уберите лишний, завершающий или Неправильный слэш {\n #}
 %ch%         из заданного расположения для {0e}всех папок{#} ─► {0c}"%DirFolder%"{\n #}
 echo.&echo.    Для возврата в меню Личных настроек нажмите любую клавишу.
 TIMEOUT /T -1 >nul & endlocal & goto :SelfStat )
if not "%PathError2%"=="" (
 echo.
 %ch%  {0c}   ──────────────────────────────────────────────────────────────────────────────────────────────────────────── {\n #}
 %ch%         {0e}Уберите лишний, завершающий или Неправильный слэш {\n #}
 %ch%         из заданного расположения для {0e}папки Загрузки{#} ─► {0c}"%DirFolderDownloads%"{\n #}
 echo.&echo.&echo.    Для возврата в меню Личных настроек нажмите любую клавишу.
 TIMEOUT /T -1 >nul & endlocal & goto :SelfStat )
if "%DirFolder%"=="" (
 echo.
 %ch%  {0c}   ──────────────────────────────────────────────────────────────────────────────────────────────────────────── {\n #}
 %ch%         {0e}Не задано расположение в {0f}Files\Presets.txt{\n #}
 echo.&echo.&echo.    Для возврата в меню Личных настроек нажмите любую клавишу.
 TIMEOUT /T -1 >nul & endlocal & goto :SelfStat)
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = {0e}Все папки    {08}^| Перенести в {0f}%DirFolder%\*         !Spaces!{0e}[100]{#} = {0e}Все папки    {08}^| Восстановить{\n #}
%ch% {0b}    [2]{#} = Видео        {08}^| Перенести в {0f}%DirFolder%\Videos    !Spaces!{0b}[200]{#} = Видео        {08}^| Восстановить{\n #}
%ch% {0b}    [3]{#} = Документы    {08}^| Перенести в {0f}%DirFolder%\Documents !Spaces!{0b}[300]{#} = Документы    {08}^| Восстановить{\n #}
%ch% {0b}    [4]{#} = Загрузки     {08}^| Перенести в {0f}%DirFolderDownloads%\Downloads !Spaces2!{0b}[400]{#} = Загрузки     {08}^| Восстановить{\n #}
%ch% {0b}    [5]{#} = Изображения  {08}^| Перенести в {0f}%DirFolder%\Pictures  !Spaces!{0b}[500]{#} = Изображения  {08}^| Восстановить{\n #}
%ch% {0b}    [6]{#} = Музыка       {08}^| Перенести в {0f}%DirFolder%\Music     !Spaces!{0b}[600]{#} = Музыка       {08}^| Восстановить{\n #}
%ch% {0b}    [7]{#} = Рабочий стол {08}^| Перенести в {0f}%DirFolder%\Desktop   !Spaces!{0b}[700]{#} = Рабочий стол {08}^| Восстановить{\n #}
echo.
%ch% {0e}    [999]{#} = Очистить панель {0e}Быстрый доступ{#} от закрепленных элементов {08}(при невозможности их удалить){\n #}
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*   Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1"   ( goto :MoveAllUserFolder )
if "%input%"=="2"   ( Call :MoveUserFolder "Videos"    "My Video"    "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}" & goto :MenuUserFoldersLocation )
if "%input%"=="3"   ( Call :MoveUserFolder "Documents" "Personal"    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" & goto :MenuUserFoldersLocation )
if "%input%"=="4"   ( Call :MoveUserFolder "Downloads" "{374DE290-123F-4565-9164-39C4925E467B}" "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" & goto :MenuUserFoldersLocation )
if "%input%"=="5"   ( Call :MoveUserFolder "Pictures"  "My Pictures" "{0DDD015D-B06C-45D5-8C4C-F59713854639}" & goto :MenuUserFoldersLocation )
if "%input%"=="6"   ( Call :MoveUserFolder "Music"     "My Music"    "{A0C69A99-21C8-4671-8703-7934162FCF1D}" & goto :MenuUserFoldersLocation )
if "%input%"=="7"   ( Call :MoveUserFolder "Desktop"   "Desktop"     "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}" & goto :MenuUserFoldersLocation )
if "%input%"=="100" ( goto :MoveAllUserFolder )
if "%input%"=="200" ( Call :MoveUserFolder "Videos"    "My Video"    "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}" & goto :MenuUserFoldersLocation )
if "%input%"=="300" ( Call :MoveUserFolder "Documents" "Personal"    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" & goto :MenuUserFoldersLocation )
if "%input%"=="400" ( Call :MoveUserFolder "Downloads" "{374DE290-123F-4565-9164-39C4925E467B}" "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" & goto :MenuUserFoldersLocation )
if "%input%"=="500" ( Call :MoveUserFolder "Pictures"  "My Pictures" "{0DDD015D-B06C-45D5-8C4C-F59713854639}" & goto :MenuUserFoldersLocation )
if "%input%"=="600" ( Call :MoveUserFolder "Music"     "My Music"    "{A0C69A99-21C8-4671-8703-7934162FCF1D}" & goto :MenuUserFoldersLocation )
if "%input%"=="700" ( Call :MoveUserFolder "Desktop"   "Desktop"     "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}" & goto :MenuUserFoldersLocation )
if "%input%"=="999" ( goto :ClearFastAccess
 ) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
          endlocal & TIMEOUT /T 2 >nul & goto :MenuUserFoldersLocation )

:: Вызов сценариев изменения расположения всех папок пользователя
:MoveAllUserFolder
echo.
set "Apply="
Call :MoveUserFolder "Videos"    "My Video"    "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"
Call :MoveUserFolder "Documents" "Personal"    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}"
Call :MoveUserFolder "Downloads" "{374DE290-123F-4565-9164-39C4925E467B}" "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"
Call :MoveUserFolder "Pictures"  "My Pictures" "{0DDD015D-B06C-45D5-8C4C-F59713854639}"
Call :MoveUserFolder "Music"     "My Music"    "{A0C69A99-21C8-4671-8703-7934162FCF1D}"
Call :MoveUserFolder "Desktop"   "Desktop"     "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}"
echo.
if "%Apply%"=="1" ( Call :ReStartExplorer
 echo.&%ch%    {2f} Все выполнено {00}.{\n #} & echo. )
TIMEOUT /T -1 & endlocal & goto :MenuUserFoldersLocation

:: Сценарий изменения расположения папок пользователя
:MoveUserFolder
set "FolderName=%~1"
set "FolderType=%~2"
set "FolderID=%~3"
set "Key=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer"
set "FindDir="
for /f "tokens=*" %%I in (' 2^>nul reg query "%Key%\User Shell Folders" /v "%FolderType%" ^| find "%FolderType%" ') do set "FindDir=%%I"
set "FindDir=!FindDir:*_SZ=!"
for /f "tokens=*" %%I in ('echo.!FindDir!') do set "FindDir=%%I"
if %input% GTR 7 set "DirFolder=%UserProfile%"
if %input% LEQ 7 set "DirFolder=%DirFolderAll%"
if %input% LEQ 7 if "%FolderName%" EQU "Downloads" set "DirFolder=%DirFolderDownloads%"
set "NoFolder="
if "%FindDir%"=="%DirFolder%\%FolderName%" (
 echo.&%ch%      {0c}Отмена переноса{#}, параметр папки {0e}%FolderName%{#} уже указывает на {0e}%DirFolder%\%FolderName% {\n #}
 if not exist "%DirFolder%\%FolderName%" (
  set NoFolder=1
  %ch%      {0e}Но отсутствует папка{#}, по этому создаем {0b}"%DirFolder%\%FolderName%"{#} и {0b}desktop.ini {\n #}
  md "%DirFolder%\%FolderName%"
  if %input% LEQ 7 (
   %ch%      Настраиваем параметры безопасности у {0b}"%DirFolder%\%FolderName%" {\n #}
   %SetACL% -on "%DirFolder%\%FolderName%" -ot file -actn setowner -ownr "n:%ComputerName%\%UserName%" -actn ace -ace "n:S-1-5-18;p:full"^
   -actn ace -ace "n:S-1-5-32-544;p:full" -actn ace -ace "n:%ComputerName%\%UserName%;p:full" -actn setprot -op dacl:p_nc -silent
  )
  echo.     Восстанавливаем у них свойства
  Call :%FolderName%INI "%DirFolder%\%FolderName%"
  attrib +R "%DirFolder%\%FolderName%"
  attrib +A +S +H "%DirFolder%\%FolderName%\desktop.ini"
 )
 if not "%input%"=="1" (
  if not "%input%"=="100" ( if "!NoFolder!"=="1" ( TIMEOUT /T -1 ) else ( TIMEOUT /T 3 >nul ))
 )
 exit /b
)
echo.
echo.  -----------------------------------------------------------------
%ch%      {0b}Переносим{#} папку: {0e}%FolderName% {\n #}
if %input% LEQ 7 set "DirFolder=%DirFolderAll%"
if %input% LEQ 7 if "%FolderName%" EQU "Downloads" set "DirFolder=%DirFolderDownloads%"
if not exist "%DirFolder%\%FolderName%" (
 %ch%      Создаем папку {0e}"%DirFolder%\%FolderName%" {\n #}
 md "%DirFolder%\%FolderName%"
)
if not exist "%DirFolder%\%FolderName%" (
 echo.&%ch%      {0c}Отмена{#},  невозможно создать папку в {0e}%DirFolder%\%FolderName% {\n #}&echo.
 if not "%input%"=="1" ( if not "%input%"=="100" TIMEOUT /T -1 )
 exit /b
)
if %input% LEQ 7 (
 %ch%      Настраиваем параметры безопасности у {0e}"%DirFolder%\%FolderName%" {\n #}
 %SetACL% -on "%DirFolder%\%FolderName%" -ot file -actn setowner -ownr "n:%ComputerName%\%UserName%" -actn ace -ace "n:S-1-5-18;p:full"^
 -actn ace -ace "n:S-1-5-32-544;p:full" -actn ace -ace "n:%ComputerName%\%UserName%;p:full" -actn setprot -op dacl:p_nc -silent
)
set "Apply=1"
%NirCMDc% win close class "CabinetWClass"
%ch%      Копируем файлы из {0e}"%FindDir%"{#} в {0e}"%DirFolder%\%FolderName%"{#} Ждите ... {\n #}
set "CopyOk=" & set "Error="
robocopy "%FindDir%" "%DirFolder%\%FolderName%" /E /COPY:DATSOU /DCOPY:DAT /XJ /R:2 /W:2 >nul
set "Error=%ErrorLevel%"
if not %Error% GEQ 8 (
  set "CopyOk=Yes" & %ch%      {0a}Все скопировано успешно{\n #}
) else (
 echo.&%ch%      {0c}Errorlevel: {0e}"%Error%" {\n #}
 if "%Error%"=="16" (%ch%      {0e}Исходная папка не существует, копировать нечего{\n #})
)
if exist "%DirFolder%\%FolderName%\desktop.ini" ( del /f /q /a "%DirFolder%\%FolderName%\desktop.ini" )
%ch%      Пересоздаем файл: {0e}"%DirFolder%\%FolderName%\desktop.ini" {\n #}
Call :%FolderName%INI "%DirFolder%\%FolderName%"
%ch%      Восстанавливаем свойства у {0e}"%DirFolder%\%FolderName%"{#} и {0e}"%DirFolder%\%FolderName%\desktop.ini"{\n #}
attrib +R "%DirFolder%\%FolderName%"
attrib +A +S +H "%DirFolder%\%FolderName%\desktop.ini"
%ch%      {0e}Устанавливаем параметры в реестрe: {\n #}
reg add "%Key%\Shell Folders" /v "%FolderType%" /t REG_SZ /d "%DirFolder%\%FolderName%" /f
if %input% GTR 7 ( set "DirFolder=%%USERPROFILE%%" )
reg add "%Key%\User Shell Folders" /v "%FolderType%" /t REG_EXPAND_SZ /d "%DirFolder%\%FolderName%" /f
reg add "%Key%\User Shell Folders" /v "%FolderID%" /t REG_EXPAND_SZ /d "%DirFolder%\%FolderName%" /f
if %input% GTR 7 ( reg delete "%Key%\User Shell Folders" /v "%FolderID%" /f )
if "!CopyOk!"=="Yes" if %Error% LSS 8 (%ch%      Удаляем исходную папку {0e}%FindDir% {\n #}& rmdir /s /q "%FindDir%" )
if "!CopyOk!"=="Yes" if %Error% GEQ 8 (%ch%      Исходная папка {0e}%FindDir% {0c}Не удалялась{#}, так как не все было скопировано {\n #}&echo.)
if exist "%FindDir%" TIMEOUT /T 1 >nul
if exist "%FindDir%" if %Error% LSS 8 (echo.&%ch%      {0f}Исходная папка: {0e}"%FindDir%"{0e} Не удалена полностью, из-за заблокированных файлов{\n #})
if not "%input%"=="1" ( if not "%input%"=="100" (
 Call :ReStartExplorer
 echo.&%ch%    {2f} Выполнено {00}.{\n #} & TIMEOUT /T -1 & endlocal
))
exit /b

:: Сценарии создания файла desktop.ini для переносимых папок
:VideosINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21791
 echo.InfoTip=@%%SystemRoot%%\system32\shell32.dll,-12690
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-189
 echo.IconFile=%%SystemRoot%%\system32\shell32.dll
 echo.IconIndex=-238
) >"%DirPath%\desktop.ini"
exit /b
:DocumentsINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21770
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-112
 echo.IconFile=%%SystemRoot%%\system32\shell32.dll
 echo.IconIndex=-235
) >"%DirPath%\desktop.ini"
exit /b
:DownloadsINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21798
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-184
) >"%DirPath%\desktop.ini"
exit /b
:PicturesINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21779
 echo.InfoTip=@%%SystemRoot%%\system32\shell32.dll,-12688
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-113
 echo.IconFile=%%SystemRoot%%\system32\shell32.dll
 echo.IconIndex=-236
) >"%DirPath%\desktop.ini"
exit /b
:MusicINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21790
 echo.InfoTip=@%%SystemRoot%%\system32\shell32.dll,-12689
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-108
 echo.IconFile=%%SystemRoot%%\system32\shell32.dll
 echo.IconIndex=-237
) >"%DirPath%\desktop.ini"
exit /b
:DesktopINI
set "DirPath=%~1"
(echo.
 echo.[.ShellClassInfo]
 echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21769
 echo.IconResource=%%SystemRoot%%\system32\imageres.dll,-183
) >"%DirPath%\desktop.ini"
exit /b

:: Сценарий очистки Быстрого доступа от закрепленных элементов пользователем, при невозможности их удалить
:ClearFastAccess
%NirCMDc% win close class "CabinetWClass"
pushd "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations" && ( rmdir /s /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations" & popd ) 2>nul
echo.&%ch%    {0a} Быстрый доступ очищен {\n #} & echo.
TIMEOUT /T -1 & endlocal & goto :MenuUserFoldersLocation
exit /b
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




:: Меню переноса папки "temp" текущего пользователя, в любое другое место по вашему желанию.
:UTempIn
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-User-Temp-Folder" ') do set "Set-User-Temp-Folder=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-User-Temp-Folder%') do set "Udest=%%I"
cls
echo.
%ch% {08}     ============================================================================== {\n #}
%ch%          Настройка расположения папки {0e}Temp{#} текущего пользователя. С добавлением{\n #}
echo.         символической ссылки, вместо папки по умолчанию, для совместимости
%ch%          Свое расположение можно задать в файле {0f}\Files\Presets.txt {\n #}
%ch%          {0e}Завершите все программы перед выполнением^^^!^^^!^^^! {\n #}
%ch% {08}     ============================================================================== {\n #}
echo.
echo.         В данный момент:
%ch%          Папка Temp: %replyUTemp%{#},   Расположение: {0e}%valueUTemp%{00}.{\n #}
%ch%          Символ. ссылка: %SymUTemp% {00}.{\n #}
echo.
if "%Udest%"=="" (
 %ch%          {0e}Не задан путь в Files\Presets.txt{\n #}
 TIMEOUT /T -1 & endlocal & goto :SelfStat)
echo.         Варианты действий:
echo.
%ch% {0b}     [1]{#} = Перенести расположение в: {0e}"%Udest%" {\n #}
%ch% {0e}     [2]{#} = Восстановить все {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #}  & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :UTempMY )
if "%input%"=="2" ( set "Udefdest=%USERPROFILE%\AppData\Local\Temp"
		    goto :UTempDEF
) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	 TIMEOUT /T 2 >nul & goto :UTempIn )
:UTempMY
echo.---------------------------------------------------------------
set "Udefdest=%USERPROFILE%\AppData\Local\Temp"
if not exist "%Udest%" ( md "%Udest%" )
reg add "HKCU\Environment" /v "TEMP" /t REG_EXPAND_SZ /d %Udest% /f
reg add "HKCU\Environment" /v  "TMP" /t REG_EXPAND_SZ /d %Udest% /f
if not exist "%Udefdest%" (
	mklink /D "%Udefdest%" "%Udest%"
	goto :UdestGo
)
takeown /f "%Udefdest%" /a /r /d y >nul 2>&1
icacls "%Udefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T >nul 2>&1

rd /s /q %Udefdest% >nul 2>&1
if exist %Udefdest% ( echo. & %ch%      - Папка: {0e}%Udefdest%{#}  {4f} Заблокирована^^^! {00}.{\n #} &echo. )

reg add "HKCU\SOFTWARE\Sysinternals\Handle" /v "EulaAccepted" /t REG_DWORD /d 1 /f >nul
:UTEMPDEL
rd /s /q "%Udefdest%" >nul 2>&1
if exist "%Udefdest%" (
	taskkill /f /im explorer.exe >nul 2>&1
	for /f "skip=4 delims=: tokens=1" %%i in ('%Handle% "%Udefdest%"') do (
		set "F=%%i"
		echo.     Закрываем процесс: !F:~,-3!
		taskkill /F /IM !F:~,-3! >nul 2>&1
	)
)
rd /s /q "%Udefdest%" >nul 2>&1
if exist "%Udefdest%" goto :UTEMPDEL
echo.
mklink /D "%Udefdest%" "%Udest%"
echo.&echo.     Ждите...
TIMEOUT /T 3 /nobreak >nul
for /f %%i in (' tasklist /fi "IMAGENAME eq explorer.exe" /FO TABLE /NH ^| find "explorer.exe" ') do set "EXPL=%%i"
if "%EXPL%"=="" (
	start explorer.exe
	start explorer.exe /e /root,"%~dp0"
)

:UdestGo
takeown /f "%Udest%" /a /r /d y >nul 2>&1
icacls "%Udest%" /reset /T >nul 2>&1
icacls "%Udest%" /grant:r SYSTEM:(CI)(OI)F /T >nul 2>&1
icacls "%Udest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T >nul 2>&1
icacls "%Udest%" /grant:r *S-1-5-32-545:(CI)(OI)F /T /inheritance:r >nul 2>&1
takeown /f "%Udefdest%" /r /d y /SKIPSL >nul 2>&1

echo.
%ch%    {0a}Расположение папки {0e}Temp{#} изменено на {0e}%Udest%{#} {\n #}
echo.
%ch%    {0a}Перезагрузите компьютер^^^!^^^!^^^! {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
:UTempDEF
echo. ---------------------------------------------------------------
if not exist "%Udefdest%" ( goto :UdestND2 )
takeown /f "%Udefdest%" /a /r /d y /SKIPSL >nul 2>&1
icacls "%Udefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T /L >nul 2>&1
rd /s /q "%Udefdest%" >nul 2>&1
:UdestND2
if not exist "%Udefdest%" ( md "%Udefdest%" )
takeown /f "%Udefdest%" /r /d y >nul 2>&1
icacls "%Udefdest%" /reset /T >nul 2>&1
reg add "HKCU\Environment" /v "TEMP" /t REG_EXPAND_SZ /d %%USERPROFILE%%\AppData\Local\Temp /f
reg add "HKCU\Environment" /v  "TMP" /t REG_EXPAND_SZ /d %%USERPROFILE%%\AppData\Local\Temp /f
echo.
%ch%   {0a}--- Все настройки папки {0e}Temp{#} текущего пользователя {\n #}
%ch%   {0a}--- восстановлены по умолчанию^^^!^^^!^^^! {\n #}
echo.
%ch%    {0a}Перезагрузите компьютер^^^!^^^!^^^!{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Меню переноса системной папки "temp", в любое другое место по вашему желанию.
:STempIn
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-System-Temp-Folder" ') do set "Set-System-Temp-Folder=%%~I"
for /f "tokens=*" %%I in ('echo.%Set-System-Temp-Folder%') do set "Sdest=%%I"
cls
echo.
%ch% {08}     ========================================================================== {\n #}
%ch%          Настройка расположения системной папки {0e}Temp{#}, с добавлением {\n #}
echo.         символической ссылки, вместо папки по умолчанию, для совместимости
%ch%          Свое расположение можно задать в файле {0f}\Files\Presets.txt {\n #}
%ch%          {0e}Завершите все программы перед выполнением^^^!^^^!^^^! {\n #}
%ch% {08}     ========================================================================== {\n #}
echo.
echo.         В данный момент:
%ch%          Папка Temp: %replySTemp%{#},   Расположение: {0e}%valueSTemp%{00}.{\n #}
%ch%          Символ. ссылка: %SymSTemp% {00}.{\n #}
echo.
if "%Sdest%"=="" (
 %ch%          {0e}Не задан путь в \Files\Presets.txt{\n #}
 TIMEOUT /T -1 & endlocal & goto :SelfStat)
echo.         Варианты действий:
echo.
%ch% {0b}     [1]{#} = Перенести расположение в: {0e}"%Sdest%" {\n #}
%ch% {0e}     [2]{#} = Восстановить все {0e}(по умолчанию) {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%input%"=="1" ( goto :STempMY )
if "%input%"=="2" ( set "Sdefdest=%SystemRoot%\Temp"
		    goto :STempDEF
) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	 TIMEOUT /T 2 >nul & goto :STempIn )
:STempMY
echo.---------------------------------------------------------------
set "Sdefdest=%SystemRoot%\Temp"
if not exist "%Sdest%" ( md "%Sdest%" )
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "TEMP" /t REG_EXPAND_SZ /d %Sdest% /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v  "TMP" /t REG_EXPAND_SZ /d %Sdest% /f
if not exist "%Sdefdest%" (
	mklink /D "%Sdefdest%" "%Sdest%"
	goto :SdestGo
)
takeown /f "%Sdefdest%" /a /r /d y >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T >nul 2>&1

rd /s /q %Sdefdest% >nul 2>&1
if exist %Sdefdest% ( echo. & %ch%      - Папка: {0e}%Sdefdest%{#}  {4f} Заблокирована^^^! {00}.{\n #} &echo. )

reg add "HKCU\SOFTWARE\Sysinternals\Handle" /v "EulaAccepted" /t REG_DWORD /d 1 /f >nul
:STEMPDEL
rd /s /q "%Sdefdest%" >nul 2>&1
if exist "%Sdefdest%" (
	taskkill /f /im explorer.exe >nul 2>&1
	for /f "skip=4 delims=: tokens=1" %%i in ('%Handle% "%Sdefdest%"') do (
		set "F=%%i"
		echo.     Закрываем процесс: !F:~,-3!
		taskkill /F /IM !F:~,-3! >nul 2>&1
	)
)
rd /s /q "%Sdefdest%" >nul 2>&1
if exist "%Sdefdest%" goto :STEMPDEL
echo.
mklink /D "%Sdefdest%" "%Sdest%"
echo.&echo.     Ждите...
TIMEOUT /T 3 /nobreak >nul
for /f %%i in (' tasklist /fi "IMAGENAME eq explorer.exe" /FO TABLE /NH ^| find "explorer.exe" ') do set "EXPL=%%i"
if "%EXPL%"=="" (
	start explorer.exe
	start explorer.exe /e /root,"%~dp0"
)

:SdestGo
takeown /f "%Sdest%" /a /r /d y >nul 2>&1
icacls "%Sdest%" /reset /T >nul 2>&1
icacls "%Sdest%" /remove *S-1-3-0 /T >nul 2>&1
icacls "%Sdest%" /remove *S-1-5-32-545 /T >nul 2>&1
icacls "%Sdest%" /grant:r SYSTEM:(CI)(OI)F /T >nul 2>&1
icacls "%Sdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T >nul 2>&1
icacls "%Sdest%" /grant:r *S-1-3-0:(OI)(CI)(IO)F /T >nul 2>&1
icacls "%Sdest%" /grant:r *S-1-5-32-545:(CI)(AD,X,WD) /T /inheritance:r >nul 2>&1
icacls "%Sdest%" /setowner SYSTEM >nul 2>&1

icacls "%Sdefdest%" /reset /T /L >nul 2>&1
icacls "%Sdefdest%" /remove *S-1-3-0 /T /L >nul 2>&1
icacls "%Sdefdest%" /remove *S-1-5-32-545 /T /L >nul 2>&1
icacls "%Sdefdest%" /grant:r SYSTEM:(CI)(OI)F /T /L >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T /L >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-3-0:(OI)(CI)(IO)F /T /L >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-545:(CI)(AD,X,WD) /T /L /inheritance:r >nul 2>&1
icacls "%Sdefdest%" /setowner SYSTEM /L >nul 2>&1
echo.
%ch%    {0a}Расположение папки {0e}Temp{#} изменено на {0e}%Sdest% {\n #}
echo.
%ch%    {0a}Перезагрузите компьютер^^^!^^^!^^^!{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
:STempDEF
echo.---------------------------------------------------------------
if not exist "%Sdefdest%" ( goto :SdestND2 )
takeown /f "%Sdefdest%" /a /r /d y /SKIPSL >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T /L >nul 2>&1
rd /s /q "%Sdefdest%" >nul 2>&1
:SdestND2
if not exist "%Sdefdest%" ( md "%Sdefdest%" )
takeown /f "%Sdefdest%" /r /d y >nul 2>&1
icacls "%Sdefdest%" /reset /T /L >nul 2>&1
icacls "%Sdefdest%" /remove *S-1-3-0 /T >nul 2>&1
icacls "%Sdefdest%" /remove *S-1-5-32-545 /T >nul 2>&1
icacls "%Sdefdest%" /grant:r SYSTEM:(CI)(OI)F /T >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-544:(CI)(OI)F /T >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-3-0:(OI)(CI)(IO)F /T >nul 2>&1
icacls "%Sdefdest%" /grant:r *S-1-5-32-545:(CI)(AD,X,WD) /T /inheritance:r >nul 2>&1
icacls "%Sdefdest%" /setowner SYSTEM /L
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "TEMP" /t REG_EXPAND_SZ /d %%SystemRoot%%\TEMP /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v  "TMP" /t REG_EXPAND_SZ /d %%SystemRoot%%\TEMP /f
echo.
%ch%  {0a}--- Все настройки системной папки {0e}Temp {\n #}
%ch%  {0a}--- восстановлены по умолчанию^^^!^^^!^^^! {\n #}
echo.
%ch%    {0a}Перезагрузите компьютер^^^!^^^!^^^!{\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Меню удаления временного профиля defaultuser0
:RemUserIn
cls
echo.
echo.      ===================================================================================
%ch%          Удаление временного профиля {0e}defaultuser0{#} и очистка реестра. {\n #}
%ch% {0e}         Вернуть обратно после удаления будет нельзя^^^!^^^!^^^! {\n #}
echo.         Если ID не определится, после ручного удаления, то очистки реестра не будет.
echo.      ===================================================================================
echo.
echo.         В данный момент:
%ch%                  Профиль: %BagUserName% {\n #}
%ch%               ID профиля: %UserID% {\n #}
%ch%            Папка профиля: %BagFolder% {\n #}
if "%BagUser%"=="" if "%BagUserID%"=="" if not exist "%BagUserFolder%" (
	echo.&%ch%     {0a}  Удалять нечего. {\n #}
	echo.      Для возврата в меню нажмите любую клавишу
	TIMEOUT /T -1 >nul & endlocal & goto :SelfStat )
echo.
echo.         Варианты действий:
echo.
%ch% {0b}     [1]{#} = Удалить все и очистить реестр {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo.&%ch%     {0e} - Возврат в меню - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :SelfStat )
if "%input%"=="1" ( goto :RemUser
) else ( echo.&%ch%     {0e} Неправильный выбор {\n #} & echo.
	 TIMEOUT /T 2 >nul & endlocal & goto :RemUserIn )

:RemUser
if not "%BagUser%"=="" (
echo.&%ch%          Удаление профиля {0e} defaultuser0{#}:{\n #}
net user "defaultuser0" /delete
%ch%          Очистка в реестре параметров от {0e}defaultuser0{#}:{\n #}
if not "!BagUserID!"=="" (
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
if "%xOS%"=="x64" (
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
)
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\IdentityStore\Cache" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\UserManager\Users" /s /d /f "!BagUserID!" ^| find "UserManager\Users" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppReadiness" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	%SetACL% -on "%%I" -ot reg -actn setowner -ownr n:S-1-1-0 -rec yes -silent
	%SetACL% -on "%%I" -ot reg -actn ace -ace n:S-1-1-0;p:full -rec yes -silent
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\Sites" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	%SetACL% -on "%%I" -ot reg -actn setowner -ownr n:S-1-1-0 -rec yes -silent
	%SetACL% -on "%%I" -ot reg -actn ace -ace n:S-1-1-0;p:full -rec yes -silent
	reg delete "%%I" /f )
for /f "tokens=1 delims=" %%I in (' reg query "HKLM\SOFTWARE\Microsoft\Windows Search\UninstalledStoreApps" /s /k /f "!BagUserID!" ^| find "S-1-5-21" ') do (
	%SetACL% -on "%%I" -ot reg -actn setowner -ownr n:S-1-1-0 -rec yes -silent
	%SetACL% -on "%%I" -ot reg -actn ace -ace n:S-1-1-0;p:full -rec yes -silent
	reg delete "%%I" /f )
))
if exist "%BagUserFolder%" (
	icacls "%BagUserFolder%" /grant:r *S-1-1-0:F /T /Q /L >nul 2>&1
	rmdir /s /q "%BagUserFolder%" >nul 2>&1
	if not exist "%BagUserFolder%" (echo.&%ch%           {0a}Удалена папка "%BagUserFolder%" {\n #} & echo.)
)
if exist "%BagUserFolder%" (rmdir /s /q "%BagUserFolder%" >nul 2>&1
	if not exist "%BagUserFolder%" (echo.&%ch%           {0a}Удалена папка "%BagUserFolder%" {\n #} & echo.)
)
TIMEOUT /T -1 & endlocal & goto :SelfStat
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::  Меню управления журналами событий
:MenuEventLogs
cls
echo.
%ch% {08}    ============================================================================= {\n #}
%ch%         Управление {0e}Журналами событий. {\n #}
echo.        Дает возможность уменьшить количество обращений к диску.
echo.        Важные Журналы будут работать: Безопасность, Установка, Система и др.
%ch% {08}    ============================================================================= {\n #}
echo.
echo.            В данный момент:
%ch%                      Служба: %EventServ% {\n #}
%ch%            Ведение Журналов: %ReplyRegEventPS% {\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = Очистка всех журналов событий{\n #}
%ch% {0b}    [2]{#} = Отключение ведения всех журналов событий {08}(кроме основных) {\n #}
%ch% {0b}    [3]{#} = Выполнить всё {08}(Отключить и очистить){\n #}
%ch% {0e}    [4]{#} = Включить ведение 275 журналов {0e}(по умолчанию){\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в меню личных настроек {\n #}
echo.
set "choice="
set /p choice=--- Ваш выбор: 
if not defined choice ( echo. & %ch%         {0e}Возврат в меню личных настроек{\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :SelfStat )
if "%choice%"=="1" ( goto :ClearEventLogs )
if "%choice%"=="2" ( goto :EventLogsOff )
if "%choice%"=="3" ( goto :EventLogsOff )
if "%choice%"=="4" ( goto :EventLogsDefaults
	) else ( echo. & %ch%        {0e}Неправильный выбор {\n #} & echo.
		 TIMEOUT /T 2 >nul & goto :MenuEventLogs  )

::  Отключение ведения всех журналов событий, кроме основных
:EventLogsOff
for /F "tokens=*" %%I in ('wevtutil el') do (
	%ch% {0b}   ^< Отключение журнала: {0e}"%%I"{\n #}
	wevtutil.exe sl "%%I" /e:false 2>nul )
:: Включение обратно ведения журнала событий "Установка"
wevtutil sl "Setup" /e:true
if "%~1"=="QuickApply" exit /b
if "%choice%"=="3" ( goto :ClearEventLogs )
echo.
%ch%      Отключение ведения журналов {2f} Выполнено {#} {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat

::  Очистка всех журналов событий
:ClearEventLogs
@echo.&@echo.
for /F "tokens=*" %%I in ('wevtutil el') do (
	%ch% {0b}   ^> Очистка журнала: {0e}"%%I"{\n #}
	wevtutil cl "%%I" 2>nul )
if "%~1"=="QuickApply" exit /b
if "%choice%"=="3" ( set "OutputLogInfo=Отключение и очистка {2f} Выполнена {#}"
	) else ( set "OutputLogInfo=Очистка {2f} Выполнена {#}" )
echo.
%ch%      %OutputLogInfo%  {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat

::  Вызов сценариев включения ведения журналов событий по умолчанию
:EventLogsDefaults
if "%~1"=="QuickApply" set "QuickApply=1"
@echo.&@echo.
Call :EnableEventLogs "Microsoft-AppV-Client/Admin"
Call :EnableEventLogs "Microsoft-AppV-Client/Operational"
Call :EnableEventLogs "Microsoft-AppV-Client/Virtual Applications"
Call :EnableEventLogs "Microsoft-Client-Licensing-Platform/Admin"
Call :EnableEventLogs "Microsoft-User Experience Virtualization-Agent Driver/Operational"
Call :EnableEventLogs "Microsoft-User Experience Virtualization-App Agent/Operational"
Call :EnableEventLogs "Microsoft-User Experience Virtualization-IPC/Operational"
Call :EnableEventLogs "Microsoft-User Experience Virtualization-SQM Uploader/Operational"
Call :EnableEventLogs "Microsoft-Windows-AAD/Operational"
Call :EnableEventLogs "Microsoft-Windows-All-User-Install-Agent/Admin"
Call :EnableEventLogs "Microsoft-Windows-AllJoyn/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppHost/Admin"
Call :EnableEventLogs "Microsoft-Windows-AppID/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppLocker/EXE and DLL"
Call :EnableEventLogs "Microsoft-Windows-AppLocker/MSI and Script"
Call :EnableEventLogs "Microsoft-Windows-AppLocker/Packaged app-Deployment"
Call :EnableEventLogs "Microsoft-Windows-AppLocker/Packaged app-Execution"
Call :EnableEventLogs "Microsoft-Windows-AppModel-Runtime/Admin"
Call :EnableEventLogs "Microsoft-Windows-AppReadiness/Admin"
Call :EnableEventLogs "Microsoft-Windows-AppReadiness/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppXDeployment/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppXDeploymentServer/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppXDeploymentServer/Restricted"
Call :EnableEventLogs "Microsoft-Windows-ApplicabilityEngine/Operational"
Call :EnableEventLogs "Microsoft-Windows-Application Server-Applications/Admin"
Call :EnableEventLogs "Microsoft-Windows-Application Server-Applications/Operational"
Call :EnableEventLogs "Microsoft-Windows-ApplicationResourceManagementSystem/Operational"
Call :EnableEventLogs "Microsoft-Windows-AppxPackaging/Operational"
Call :EnableEventLogs "Microsoft-Windows-AssignedAccess/Admin"
Call :EnableEventLogs "Microsoft-Windows-AssignedAccessBroker/Admin"
Call :EnableEventLogs "Microsoft-Windows-Audio/CaptureMonitor"
Call :EnableEventLogs "Microsoft-Windows-Audio/Operational"
Call :EnableEventLogs "Microsoft-Windows-Audio/PlaybackManager"
Call :EnableEventLogs "Microsoft-Windows-Authentication User Interface/Operational"
Call :EnableEventLogs "Microsoft-Windows-BackgroundTaskInfrastructure/Operational"
Call :EnableEventLogs "Microsoft-Windows-Backup"
Call :EnableEventLogs "Microsoft-Windows-Biometrics/Operational"
Call :EnableEventLogs "Microsoft-Windows-BitLocker-DrivePreparationTool/Admin"
Call :EnableEventLogs "Microsoft-Windows-BitLocker-DrivePreparationTool/Operational"
Call :EnableEventLogs "Microsoft-Windows-BitLocker/BitLocker Management"
Call :EnableEventLogs "Microsoft-Windows-Bits-Client/Operational"
Call :EnableEventLogs "Microsoft-Windows-Bluetooth-BthLEPrepairing/Operational"
Call :EnableEventLogs "Microsoft-Windows-Bluetooth-MTPEnum/Operational"
Call :EnableEventLogs "Microsoft-Windows-BranchCache/Operational"
Call :EnableEventLogs "Microsoft-Windows-BranchCacheSMB/Operational"
Call :EnableEventLogs "Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational"
Call :EnableEventLogs "Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational"
Call :EnableEventLogs "Microsoft-Windows-CloudStorageWizard/Operational"
Call :EnableEventLogs "Microsoft-Windows-CodeIntegrity/Operational"
Call :EnableEventLogs "Microsoft-Windows-Compat-Appraiser/Operational"
Call :EnableEventLogs "Microsoft-Windows-Containers-Wcifs/Operational"
Call :EnableEventLogs "Microsoft-Windows-Containers-Wcnfs/Operational"
Call :EnableEventLogs "Microsoft-Windows-CoreApplication/Operational"
Call :EnableEventLogs "Microsoft-Windows-CoreSystem-SmsRouter-Events/Operational"
Call :EnableEventLogs "Microsoft-Windows-CorruptedFileRecovery-Client/Operational"
Call :EnableEventLogs "Microsoft-Windows-CorruptedFileRecovery-Server/Operational"
Call :EnableEventLogs "Microsoft-Windows-Crypto-DPAPI/BackUpKeySvc"
Call :EnableEventLogs "Microsoft-Windows-Crypto-DPAPI/Operational"
Call :EnableEventLogs "Microsoft-Windows-DAL-Provider/Operational"
Call :EnableEventLogs "Microsoft-Windows-DSC/Admin"
Call :EnableEventLogs "Microsoft-Windows-DSC/Operational"
Call :EnableEventLogs "Microsoft-Windows-DataIntegrityScan/Admin"
Call :EnableEventLogs "Microsoft-Windows-DataIntegrityScan/CrashRecovery"
Call :EnableEventLogs "Microsoft-Windows-DateTimeControlPanel/Operational"
Call :EnableEventLogs "Microsoft-Windows-Deduplication/Diagnostic"
Call :EnableEventLogs "Microsoft-Windows-Deduplication/Operational"
Call :EnableEventLogs "Microsoft-Windows-Deduplication/Scrubbing"
Call :EnableEventLogs "Microsoft-Windows-DeviceGuard/Operational"
Call :EnableEventLogs "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
Call :EnableEventLogs "Microsoft-Windows-DeviceSetupManager/Admin"
Call :EnableEventLogs "Microsoft-Windows-DeviceSetupManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-DeviceSync/Operational"
Call :EnableEventLogs "Microsoft-Windows-Devices-Background/Operational"
Call :EnableEventLogs "Microsoft-Windows-Dhcp-Client/Admin"
Call :EnableEventLogs "Microsoft-Windows-Dhcpv6-Client/Admin"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-DPS/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-PCW/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-PLA/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-Scheduled/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-Scripted/Admin"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-Scripted/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnosis-ScriptedDiagnosticsProvider/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnostics-Networking/Operational"
Call :EnableEventLogs "Microsoft-Windows-Diagnostics-Performance/Operational"
Call :EnableEventLogs "Microsoft-Windows-DiskDiagnostic/Operational"
Call :EnableEventLogs "Microsoft-Windows-DiskDiagnosticDataCollector/Operational"
Call :EnableEventLogs "Microsoft-Windows-DiskDiagnosticResolver/Operational"
Call :EnableEventLogs "Microsoft-Windows-EDP-Audit-Regular/Admin"
Call :EnableEventLogs "Microsoft-Windows-EDP-Audit-TCB/Admin"
Call :EnableEventLogs "Microsoft-Windows-EapHost/Operational"
Call :EnableEventLogs "Microsoft-Windows-EapMethods-RasChap/Operational"
Call :EnableEventLogs "Microsoft-Windows-EapMethods-RasTls/Operational"
Call :EnableEventLogs "Microsoft-Windows-EapMethods-Sim/Operational"
Call :EnableEventLogs "Microsoft-Windows-EapMethods-Ttls/Operational"
Call :EnableEventLogs "Microsoft-Windows-EmbeddedAppLauncher/Admin"
Call :EnableEventLogs "Microsoft-Windows-EventCollector/Operational"
Call :EnableEventLogs "Microsoft-Windows-FMS/Operational"
Call :EnableEventLogs "Microsoft-Windows-Fault-Tolerant-Heap/Operational"
Call :EnableEventLogs "Microsoft-Windows-FileHistory-Core/WHC"
Call :EnableEventLogs "Microsoft-Windows-FileHistory-Engine/BackupLog"
Call :EnableEventLogs "Microsoft-Windows-Folder Redirection/Operational"
Call :EnableEventLogs "Microsoft-Windows-Forwarding/Operational"
Call :EnableEventLogs "Microsoft-Windows-GenericRoaming/Admin"
Call :EnableEventLogs "Microsoft-Windows-GroupPolicy/Operational"
Call :EnableEventLogs "Microsoft-Windows-Help/Operational"
Call :EnableEventLogs "Microsoft-Windows-HomeGroup Control Panel/Operational"
Call :EnableEventLogs "Microsoft-Windows-HomeGroup Listener Service/Operational"
Call :EnableEventLogs "Microsoft-Windows-HomeGroup Provider Service/Operational"
Call :EnableEventLogs "Microsoft-Windows-HotspotAuth/Operational"
Call :EnableEventLogs "Microsoft-Windows-IKE/Operational"
Call :EnableEventLogs "Microsoft-Windows-IdCtrls/Operational"
Call :EnableEventLogs "Microsoft-Windows-International-RegionalOptionsControlPanel/Operational"
Call :EnableEventLogs "Microsoft-Windows-International/Operational"
Call :EnableEventLogs "Microsoft-Windows-Iphlpsvc/Operational"
Call :EnableEventLogs "Microsoft-Windows-KdsSvc/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-ApphelpCache/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-Boot/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-EventTracing/Admin"
Call :EnableEventLogs "Microsoft-Windows-Kernel-IO/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-PnP/Configuration"
Call :EnableEventLogs "Microsoft-Windows-Kernel-Power/Thermal-Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-ShimEngine/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-StoreMgr/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-WDI/Operational"
Call :EnableEventLogs "Microsoft-Windows-Kernel-WHEA/Errors"
Call :EnableEventLogs "Microsoft-Windows-Kernel-WHEA/Operational"
Call :EnableEventLogs "Microsoft-Windows-Known Folders API Service"
Call :EnableEventLogs "Microsoft-Windows-LanguagePackSetup/Operational"
Call :EnableEventLogs "Microsoft-Windows-LiveId/Operational"
Call :EnableEventLogs "Microsoft-Windows-MUI/Admin"
Call :EnableEventLogs "Microsoft-Windows-MUI/Operational"
Call :EnableEventLogs "Microsoft-Windows-MemoryDiagnostics-Results/Debug"
Call :EnableEventLogs "Microsoft-Windows-Mprddm/Operational"
Call :EnableEventLogs "Microsoft-Windows-NCSI/Operational"
Call :EnableEventLogs "Microsoft-Windows-NTLM/Operational"
Call :EnableEventLogs "Microsoft-Windows-NcdAutoSetup/Operational"
Call :EnableEventLogs "Microsoft-Windows-NdisImPlatform/Operational"
Call :EnableEventLogs "Microsoft-Windows-NetworkLocationWizard/Operational"
Call :EnableEventLogs "Microsoft-Windows-NetworkProfile/Operational"
Call :EnableEventLogs "Microsoft-Windows-NetworkProvider/Operational"
Call :EnableEventLogs "Microsoft-Windows-NetworkProvisioning/Operational"
Call :EnableEventLogs "Microsoft-Windows-NlaSvc/Operational"
Call :EnableEventLogs "Microsoft-Windows-Ntfs/Operational"
Call :EnableEventLogs "Microsoft-Windows-Ntfs/WHC"
Call :EnableEventLogs "Microsoft-Windows-OOBE-Machine-DUI/Operational"
Call :EnableEventLogs "Microsoft-Windows-OfflineFiles/Operational"
Call :EnableEventLogs "Microsoft-Windows-OneBackup/Debug"
Call :EnableEventLogs "Microsoft-Windows-PackageStateRoaming/Operational"
Call :EnableEventLogs "Microsoft-Windows-ParentalControls/Operational"
Call :EnableEventLogs "Microsoft-Windows-Partition/Diagnostic"
Call :EnableEventLogs "Microsoft-Windows-PerceptionRuntime/Operational"
Call :EnableEventLogs "Microsoft-Windows-PerceptionSensorDataService/Operational"
Call :EnableEventLogs "Microsoft-Windows-Policy/Operational"
Call :EnableEventLogs "Microsoft-Windows-PowerShell-DesiredStateConfiguration-FileDownloadManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-PowerShell/Admin"
Call :EnableEventLogs "Microsoft-Windows-PowerShell/Operational"
Call :EnableEventLogs "Microsoft-Windows-PrintBRM/Admin"
Call :EnableEventLogs "Microsoft-Windows-PrintService/Admin"
Call :EnableEventLogs "Microsoft-Windows-Program-Compatibility-Assistant/CompatAfterUpgrade"
Call :EnableEventLogs "Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin"
Call :EnableEventLogs "Microsoft-Windows-PushNotification-Platform/Admin"
Call :EnableEventLogs "Microsoft-Windows-PushNotification-Platform/Operational"
Call :EnableEventLogs "Microsoft-Windows-ReadyBoost/Operational"
Call :EnableEventLogs "Microsoft-Windows-ReadyBoostDriver/Operational"
Call :EnableEventLogs "Microsoft-Windows-Regsvr32/Operational"
Call :EnableEventLogs "Microsoft-Windows-RemoteApp and Desktop Connections/Admin"
Call :EnableEventLogs "Microsoft-Windows-RemoteApp and Desktop Connections/Operational"
Call :EnableEventLogs "Microsoft-Windows-RemoteAssistance/Admin"
Call :EnableEventLogs "Microsoft-Windows-RemoteAssistance/Operational"
Call :EnableEventLogs "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Admin"
Call :EnableEventLogs "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational"
Call :EnableEventLogs "Microsoft-Windows-RemoteDesktopServices-SessionServices/Operational"
Call :EnableEventLogs "Microsoft-Windows-Resource-Exhaustion-Detector/Operational"
Call :EnableEventLogs "Microsoft-Windows-Resource-Exhaustion-Resolver/Operational"
Call :EnableEventLogs "Microsoft-Windows-RestartManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-RetailDemo/Admin"
Call :EnableEventLogs "Microsoft-Windows-RetailDemo/Operational"
if exist "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe" (
 Call :EnableEventLogs "Microsoft-Windows-SENSE/Operational"
)
Call :EnableEventLogs "Microsoft-Windows-SMBClient/Operational"
Call :EnableEventLogs "Microsoft-Windows-SMBServer/Audit"
Call :EnableEventLogs "Microsoft-Windows-SMBServer/Connectivity"
Call :EnableEventLogs "Microsoft-Windows-SMBServer/Operational"
Call :EnableEventLogs "Microsoft-Windows-SMBServer/Security"
Call :EnableEventLogs "Microsoft-Windows-SMBWitnessClient/Admin"
Call :EnableEventLogs "Microsoft-Windows-SMBWitnessClient/Informational"
if "%xOS%"=="x64" (
 Call :EnableEventLogs "Microsoft-Windows-ScmBus/Certification"
 Call :EnableEventLogs "Microsoft-Windows-ScmDisk0101/Operational"
)
Call :EnableEventLogs "Microsoft-Windows-SearchUI/Operational"
Call :EnableEventLogs "Microsoft-Windows-Security-Audit-Configuration-Client/Operational"
Call :EnableEventLogs "Microsoft-Windows-Security-EnterpriseData-FileRevocationManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-Security-Netlogon/Operational"
Call :EnableEventLogs "Microsoft-Windows-Security-SPP-UX-GenuineCenter-Logging/Operational"
Call :EnableEventLogs "Microsoft-Windows-Security-SPP-UX-Notifications/ActionCenter"
Call :EnableEventLogs "Microsoft-Windows-Security-UserConsentVerifier/Audit"
Call :EnableEventLogs "Microsoft-Windows-SettingSync-Azure/Debug"
Call :EnableEventLogs "Microsoft-Windows-SettingSync-Azure/Operational"
Call :EnableEventLogs "Microsoft-Windows-SettingSync/Debug"
Call :EnableEventLogs "Microsoft-Windows-SettingSync/Operational"
Call :EnableEventLogs "Microsoft-Windows-Shell-ConnectedAccountState/ActionCenter"
Call :EnableEventLogs "Microsoft-Windows-Shell-Core/ActionCenter"
Call :EnableEventLogs "Microsoft-Windows-Shell-Core/AppDefaults"
Call :EnableEventLogs "Microsoft-Windows-Shell-Core/LogonTasksChannel"
Call :EnableEventLogs "Microsoft-Windows-Shell-Core/Operational"
Call :EnableEventLogs "Microsoft-Windows-SmartCard-Audit/Authentication"
Call :EnableEventLogs "Microsoft-Windows-SmartCard-DeviceEnum/Operational"
Call :EnableEventLogs "Microsoft-Windows-SmartCard-TPM-VCard-Module/Admin"
Call :EnableEventLogs "Microsoft-Windows-SmartCard-TPM-VCard-Module/Operational"
Call :EnableEventLogs "Microsoft-Windows-SmbClient/Connectivity"
Call :EnableEventLogs "Microsoft-Windows-SmbClient/Security"
Call :EnableEventLogs "Microsoft-Windows-StateRepository/Operational"
Call :EnableEventLogs "Microsoft-Windows-StateRepository/Restricted"
Call :EnableEventLogs "Microsoft-Windows-Storage-ClassPnP/Operational"
Call :EnableEventLogs "Microsoft-Windows-Storage-Storport/Operational"
Call :EnableEventLogs "Microsoft-Windows-Storage-Tiering/Admin"
Call :EnableEventLogs "Microsoft-Windows-StorageManagement/Operational"
Call :EnableEventLogs "Microsoft-Windows-StorageSpaces-Driver/Diagnostic"
Call :EnableEventLogs "Microsoft-Windows-StorageSpaces-Driver/Operational"
Call :EnableEventLogs "Microsoft-Windows-StorageSpaces-ManagementAgent/WHC"
Call :EnableEventLogs "Microsoft-Windows-StorageSpaces-SpaceManager/Diagnostic"
Call :EnableEventLogs "Microsoft-Windows-StorageSpaces-SpaceManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-Store/Operational"
Call :EnableEventLogs "Microsoft-Windows-SystemSettingsThreshold/Operational"
Call :EnableEventLogs "Microsoft-Windows-TCPIP/Operational"
Call :EnableEventLogs "Microsoft-Windows-TWinUI/Operational"
Call :EnableEventLogs "Microsoft-Windows-TZSync/Operational"
Call :EnableEventLogs "Microsoft-Windows-TZUtil/Operational"
Call :EnableEventLogs "Microsoft-Windows-TaskScheduler/Maintenance"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-LocalSessionManager/Admin"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-PnPDevices/Admin"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-PnPDevices/Operational"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-Printers/Admin"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-Printers/Operational"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-RDPClient/Operational"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-ServerUSBDevices/Admin"
Call :EnableEventLogs "Microsoft-Windows-TerminalServices-ServerUSBDevices/Operational"
Call :EnableEventLogs "Microsoft-Windows-UAC-FileVirtualization/Operational"
Call :EnableEventLogs "Microsoft-Windows-UAC/Operational"
Call :EnableEventLogs "Microsoft-Windows-User Control Panel/Operational"
Call :EnableEventLogs "Microsoft-Windows-User Device Registration/Admin"
Call :EnableEventLogs "Microsoft-Windows-User Profile Service/Operational"
Call :EnableEventLogs "Microsoft-Windows-User-Loader/Operational"
Call :EnableEventLogs "Microsoft-Windows-UserPnp/ActionCenter"
Call :EnableEventLogs "Microsoft-Windows-UserPnp/DeviceInstall"
Call :EnableEventLogs "Microsoft-Windows-VDRVROOT/Operational"
Call :EnableEventLogs "Microsoft-Windows-VHDMP-Operational"
Call :EnableEventLogs "Microsoft-Windows-VPN-Client/Operational"
Call :EnableEventLogs "Microsoft-Windows-VPN/Operational"
Call :EnableEventLogs "Microsoft-Windows-VerifyHardwareSecurity/Admin"
Call :EnableEventLogs "Microsoft-Windows-Volume/Diagnostic"
Call :EnableEventLogs "Microsoft-Windows-VolumeSnapshot-Driver/Operational"
Call :EnableEventLogs "Microsoft-Windows-WFP/Operational"
Call :EnableEventLogs "Microsoft-Windows-WLAN-AutoConfig/Operational"
Call :EnableEventLogs "Microsoft-Windows-WMI-Activity/Operational"
Call :EnableEventLogs "Microsoft-Windows-WPD-ClassInstaller/Operational"
Call :EnableEventLogs "Microsoft-Windows-WPD-CompositeClassDriver/Operational"
Call :EnableEventLogs "Microsoft-Windows-WPD-MTPClassDriver/Operational"
Call :EnableEventLogs "Microsoft-Windows-WWAN-SVC-Events/Operational"
Call :EnableEventLogs "Microsoft-Windows-Wcmsvc/Operational"
Call :EnableEventLogs "Microsoft-Windows-Win32k/Operational"
Call :EnableEventLogs "Microsoft-Windows-WinINet-Config/ProxyConfigChanged"
Call :EnableEventLogs "Microsoft-Windows-WinRM/Operational"
Call :EnableEventLogs "Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurity"
Call :EnableEventLogs "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall"
Call :EnableEventLogs "Microsoft-Windows-WindowsBackup/ActionCenter"
Call :EnableEventLogs "Microsoft-Windows-WindowsSystemAssessmentTool/Operational"
Call :EnableEventLogs "Microsoft-Windows-WindowsUpdateClient/Operational"
Call :EnableEventLogs "Microsoft-Windows-Winlogon/Operational"
Call :EnableEventLogs "Microsoft-Windows-Winsock-WS2HELP/Operational"
Call :EnableEventLogs "Microsoft-Windows-Wired-AutoConfig/Operational"
Call :EnableEventLogs "Microsoft-Windows-Workplace Join/Admin"
Call :EnableEventLogs "Microsoft-WindowsPhone-Connectivity-WiFiConnSvc-Channel"
Call :EnableEventLogs "Setup"
echo.
if "%QuickApply%"=="1" set "QuickApply=" & exit /b
%ch%      Включение журналов по умолчанию {2f} Выполнено {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :SelfStat

::  Сценарий включения ведения журналов по умолчанию
:EnableEventLogs
set "NameLog=%~1"
%ch% {0b}   ^> Включение журнала: {0e}"%NameLog%"{\n #}
wevtutil sl "%NameLog%" /e:true
exit /b



::     ----------------------------------------------------------------
::     -----        Конец Меню управления журналами событий       -----
::     ----------------------------------------------------------------

:: Меню настроек языковых возможностей
:CapabilitiesMenu
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set TaskCapability="Microsoft\Windows\LanguageComponentsInstaller\Installation"
for /f "delims=, tokens=3" %%i in (' SCHTASKS /QUERY /FO CSV /NH /TN %TaskCapability% 2^>nul ') do set "replyCapability=%%~i"
if not "!replyCapability!"=="" (
	if "!replyCapability!"=="Disabled" ( set "replyCapability={0a}Отключена{#}"
	) else ( set "replyCapability={0e}Включена^^^^^!{#}" )
) else ( set "replyCapability={0у}Не существует^^^^^!{#}" )
cls
echo.
%ch% {08}     ========================================================================================================== {\n #}
%ch%          Настройка {0e}Языковых возможностей {08}(Features On Demand V2){\n #}
echo.         Если все удалить, экранный диктор, кортана, распознавание голоса не смогут выполнять свои функции^^^!
%ch%          При их {0a}авто{#}установке появляется окно: "Мы добавили в Windows ряд новых функций". {\n #}
echo.         В ручную установить/удалить можно, но не все даст удалить, тут:
echo.           Модерн настройки ^> Система ^> Приложения и возможности ^> управление дополнительными компонентами
%ch%          {0f}Для выполнения установки или удаления необходим Интернет и не отключенный Центр Обновления^^^! {\n #}
%ch% {08}     ========================================================================================================== {\n #}
echo.
echo.         В данный момент:
set "CapabilityPath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
for /f "tokens=13-15 delims=\~- " %%I in (' reg query "%CapabilityPath%" ^| find /I "LanguageFeatures" ^| find /I /V "WOW64" ^| find /I /V "onecoreuap" ^| find /I /V "enduser" ') do (
%ch%            Установлен: {0a}Language.%%I-%%J-%%K{\n #}
set "Capability=%%I"
)
if "%Capability%"=="" (
%ch%            Языковые возможности {0a}Не установлены{\n #}
)
%ch%            Задача Автоустановки языковых возможностей: %replyCapability% {00}.{\n #}
echo.
echo.         Варианты действий:
echo.
%ch% {0b}     [1]{#} = Удалить все и отключить задачу автоустановки {08} ^| Нужен Интернет и Центр Обновления {\n #}
%ch% {0e}     [2]{#} = Установить языковой комплект и Включить задачу {0e}(по умолчанию) {08} ^| Нужен Интернет и Центр Обновления {\n #}
echo.
%ch% {0b}     [Без ввода]{#} = {08}Вернуться в меню личных настроек{\n #}
echo.
set "input="
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%     {0e} - Возврат в меню личных настроек - {\n #} & echo.
			endlocal & TIMEOUT /T 2 >nul & goto :SelfStat )
if "%input%"=="1" ( goto :CapabilityOFF )
if "%input%"=="2" ( goto :CapabilityON
 ) else ( echo. & %ch%     {0e} Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & goto :CapabilitiesMenu )


:CapabilityOFF
echo.
%ch%         {0e}Проверка сети перед Удалением Яз. возможностей ...{\n #}&echo.
set Online=
set ValueOnline=
set IP=Google.com
for /l %%I in (1,1,3) do (
 if "!Online!"=="" (
  for /f %%J in (' ping -n 1 %IP% ^| findstr /i /n "TTL=" ') do set ValueOnline=%%J
   if !ValueOnline! GEQ 1 ( set "Online=1" &echo.&%ch%                  Сеть ^| {0a}Online {\n #}&echo.
   ) else ( %ch%         Проверка: {0b}%%I{#} ^| {0e}Не удачная {\n #}& TIMEOUT /T 1 >nul )))
if not defined Online echo.&%ch%                Сеть ^| {0c}Не подключена{\n #}&echo. & TIMEOUT /T -1 & endlocal & goto :CapabilitiesMenu
echo.
schtasks /Change /TN "%TaskCapability%" /Disable >nul
set "Capability="
for /f "tokens=10 delims=\~ " %%I in (' reg query "%CapabilityPath%" ^| find /I "LanguageFeatures" ') do set "Capability=%%I"
if "%Capability%"=="" (
echo.
%ch%       --- Языковые возможности {0a}Не установлены{\n #}
TIMEOUT /T 3 >nul & endlocal & goto :SelfStat
)
for /f "tokens=13-15 delims=\~- " %%A in (' reg query "%CapabilityPath%" ^| find /I "LanguageFeatures" ^| find /I /V "WOW64" ^| find /I /V "LanguageFeatures-Basic" ') do (
 for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.%%A~~~%%B-%%C" ') do set "CapabilityVers=%%E"
 for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.%%A~~~%%B-%%C~!CapabilityVers! ^| find /I "State : Installed" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Удаление: {0a}Language.%%A~~~%%B-%%C~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Remove-Capability /CapabilityName:Language.%%A~~~%%B-%%C~!CapabilityVers!
	echo.
 )
)
for /f "tokens=13-15 delims=\~- " %%A in (' reg query "%CapabilityPath%" ^| find /I "LanguageFeatures-Basic" ^| find /I /V "WOW64" ') do (
 for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.%%A~~~%%B-%%C" ') do set "CapabilityVers=%%E"
 for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.%%A~~~%%B-%%C~!CapabilityVers! ^| find /I "State : Installed" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Удаление: {0a}Language.%%A~~~%%B-%%C~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Remove-Capability /CapabilityName:Language.%%A~~~%%B-%%C~!CapabilityVers!
	echo.
 )
)
echo.
%ch%    {0a}--- Языковые возможности Удалены {\n #}
echo.
%ch%    {0c}--- Необходимо перезагрузиться для завершения удаления^^^!{\n #}
%ch%    {0c}--- Если все не удалиться после перезагрузки, еще раз запустите удаление^^^! {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :CapabilitiesMenu


:CapabilityON
schtasks /Change /TN "%TaskCapability%" /Enable >nul
schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\Uninstallation" /Enable >nul
echo.
%ch%         {0e}Проверка сети перед Установкой Яз. возможностей ...{\n #}&echo.
set Online=
set ValueOnline=
set IP=Google.com
for /l %%I in (1,1,3) do (
 if "!Online!"=="" (
  for /f %%J in (' ping -n 1 %IP% ^| findstr /i /n "TTL=" ') do set ValueOnline=%%J
   if !ValueOnline! GEQ 1 ( set "Online=1" &echo.&%ch%                  Сеть ^| {0a}Online {\n #}&echo.
   ) else ( %ch%         Проверка: {0b}%%I{#} ^| {0e}Не удачная {\n #}& TIMEOUT /T 1 >nul )))
if not defined Online echo.&%ch%                Сеть ^| {0c}Не подключена{\n #}&echo. & TIMEOUT /T -1 & endlocal & goto :CapabilitiesMenu
echo.
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.Basic~~~en-US" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.Basic~~~en-US~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.Basic~~~en-US~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.Basic~~~en-US~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.Basic~~~%OSLang%" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.Basic~~~%OSLang%~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.Basic~~~%OSLang%~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.Basic~~~%OSLang%~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.Handwriting~~~%OSLang%" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.Handwriting~~~%OSLang%~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.Handwriting~~~%OSLang%~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.Handwriting~~~%OSLang%~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.TextToSpeech~~~%OSLang%" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.TextToSpeech~~~%OSLang%~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.TextToSpeech~~~%OSLang%~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.TextToSpeech~~~%OSLang%~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.Speech~~~%OSLang%" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.Speech~~~%OSLang%~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.Speech~~~%OSLang%~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.Speech~~~%OSLang%~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.OCR~~~en-US" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.OCR~~~en-US~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.OCR~~~en-US~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.OCR~~~en-US~!CapabilityVers!
	echo.
)
for /f "tokens=6 delims=:~- " %%E in (' DISM /English /Online /Get-Capabilities ^| find /I "Language.OCR~~~%OSLang%" ') do set "CapabilityVers=%%E"
for /f "delims=" %%F in (' DISM /English /Online /Get-CapabilityInfo /CapabilityName:Language.OCR~~~%OSLang%~!CapabilityVers! ^| find /I "State : Not Present" ') do (
	echo.
	echo.
	%ch% {08}*********************************************************************************** {\n #}
	%ch%         Установка: {0a}Language.OCR~~~%OSLang%~!CapabilityVers!{\n #}
	DISM /Online /NoRestart /Add-Capability /CapabilityName:Language.OCR~~~%OSLang%~!CapabilityVers!
	echo.
)
echo.
%ch%   --- Проверка возможностей (и установка по необходимости) {0a}Выполнена{#} {\n #}
echo.
TIMEOUT /T -1 & endlocal & goto :CapabilitiesMenu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




::   Сценарий Меню блокировок .exe файлов
:MenuBlockEXE
Setlocal EnableDelayedExpansion
:: Это раздел для записи блокировок
set "BlockPath=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
cls
echo.
%ch% {08}      ========================================================================== {\n #}
%ch%           Блокировка запуска {0f}.EXE{#} файлов по названию, расположение неважно {\n #}
%ch% {0e}          Не добавляйте файлы, которые могут повлиять на загрузку системы^^^!^^^!^^^! {\n #}
%ch% {08}      ========================================================================== {\n #}
echo.
%ch%           Указанные в {0f}\Files\Presets.txt{#} файлы для блокировки:  {\n #}
set /a N=0
for /f "tokens=2,3* delims==" %%A in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Block-File-Name" ') do (
 set /a N+=1 
 set "ExeName=%%~A"
 set "ExeNameShort=!ExeName:~0,26!"
 set "ExeNameTest=!ExeNameShort:*.exe=!"
 if "!ExeNameTest!" NEQ "" set "ExeNameShort=!ExeNameShort:~0,-4!~.exe"
 set "Spaces=" & set "NS=1"
 for /l %%I in (1, 1, 26) do ( set "LineLength=!ExeName:~%%I!" & if defined LineLength set /a "NS+=1" )
 for /l %%I in (26, -1, !NS!) do set "Spaces= !Spaces!"
 %ch%             !N!. {0e}!ExeNameShort!!Spaces! {08}^| %%~B {\n #}
)
echo.
if "!N!"=="0" (
 %ch%           {0e}Не заданы файлы EXE для блокировки в \Files\Presets.txt{\n #}
 TIMEOUT /T -1 & endlocal & goto :SelfStat
)
echo.          В данный момент уже заблокированы:
for /f "tokens=7* delims=\" %%I in (' 2^>nul reg query "%BlockPath%" /s /f "Debugger" ^| find ".exe" ^| find /I /V "Debugger" ') do (
%ch%             Файл:{0a} %%I {\n #}
set "Block=%%I"
)
if "%Block%"=="" %ch% {0e}               Нет блокировок .exe{\n #}
echo.
echo.          Варианты для выбора:
echo.
%ch% {0b}      [1]{#} = Заблокировать запуск указанных файлов {08}(без отображения блокировки, при запуске){\n #}
%ch% {0b}      [2]{#} = Заблокировать запуск указанных файлов {08}(с отображением блокировки, при запуске) {\n #}
echo.
%ch% {0c}      [3]{#} = Разблокировать только указанные {08}(в \Files\Presets.txt){\n #}
echo.
%ch% {0b}      [Без ввода]{#} = {08}Вернуться в меню личных настроек{\n #}
echo.
set /p choice=-  Ваш выбор: 
if not defined choice ( echo. & %ch% {0e}       Возврат в меню личных настроек {\n #} & echo.
		 	TIMEOUT /T 2 >nul & endlocal & goto :SelfStat )
if "%choice%"=="1" ( goto :BlockEXE )
if "%choice%"=="2" ( goto :BlockEXEView )
if "%choice%"=="3" ( goto :UnBlockEXE
 ) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
	  TIMEOUT /T 2 >nul & endlocal & goto :MenuBlockEXE )

:BlockEXE
echo.
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Block-File-Name" ') do (
 reg add "%BlockPath%\%%~I" /v "Debugger" /t REG_SZ /d "WScript //B" /f
)
echo.
%ch% {0a}     Для продолжения нажмите любую клавишу.{\n #}
echo.
TIMEOUT /T -1 >nul
endlocal & goto :MenuBlockEXE

:BlockEXEView
echo.
for /f "tokens=2,3* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Block-File-Name" ') do (
 reg add "%BlockPath%\%%~I" /v "Debugger" /t REG_SZ /d "cmd /c echo.&echo.&echo.         Программа %%~I %%~J заблокирована^^^!&timeout /t 4 >nul&exit" /f
)
echo.
%ch% {0a}     Для продолжения нажмите любую клавишу.{\n #}
echo.
TIMEOUT /T -1 >nul
endlocal & goto :MenuBlockEXE

:UnBlockEXE
echo.
for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Block-File-Name" ') do (
 reg delete "%BlockPath%\%%~I" /f
)
echo.
%ch% {0a}     Для продолжения нажмите любую клавишу.{\n #}
echo.
TIMEOUT /T -1 >nul
endlocal & goto :MenuBlockEXE


::     --------------------------------------------------------
::     ----      Конец управления Блокировкой программ     ----
::     --------------------------------------------------------



::     ---------------------------------------------
::     -----        Конец Своих настроек       -----
::     ---------------------------------------------


::   Меню блокировки/разблокировки драйверов для нужных устройств по GUID класса.
:GUIDIn
cd /d "%~dp0"
endlocal & setlocal EnableDelayedExpansion
set "regpathguid=HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall"
set guidregkey="%regpathguid%\Restrictions\DenyDeviceClasses"
reg add "%regpathguid%\Restrictions" /v "DenyDeviceClasses" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%regpathguid%\Restrictions" /v "DenyDeviceClassesRetroactive" /t REG_DWORD /d 0 /f >nul 2>&1
cls
for /f "tokens=1,3" %%i in (' reg query %guidregkey% 2^>nul ^| find /I "REG_SZ" ') do set "value1=%%i %%j"
if not "%value1%"=="" ( echo.& %ch%  -- Уже {0a}заблокированные{#} устройства по {0e}GUID:{\n #}
		      echo. & reg query %guidregkey% | find /I "REG_SZ" & echo.
	) else ( echo.& echo.  -- Заблокированные устройства по GUID не найдены. & echo. )
echo.
%ch% {08}   ======================================================== {\n #}
echo.       Блокировка или разблокировка обновления драйвера
echo.       для необходимого устройства по GUID класса.
%ch% {08}   ======================================================== {\n #}
echo.
echo.       Варианты для выбора:
echo.
%ch% {0b}       [Скопируйте GUID класса]{#} нужного устройства{\n #}
echo.
%ch% {0b}       [Без ввода]{#} ={08} Вернуться в меню Управления обновлениями{\n #}
echo.
%ch% {0c}       [999]{#} = Удалить все блокировки по {0e}GUID{\n #}
echo.
set /p InputGUID=***  Вставте GUID тут: 
if "!InputGUID!"=="999" ( Goto :GUIDdel )
if not "!InputGUID!"=="" (
	if "!InputGUID:~,-37!"=="{" (
		if "!InputGUID:~37!"=="}" (
			for /f "delims=REG_SZ tokens=1,2" %%i in (' reg query !guidregkey! 2^>nul ^| find "!InputGUID!" ') do (
			set "Nameblock=%%i" & set "GUIDvalue=%%j" )
		) else ( echo. & %ch%         {0e} Неправильный GUID^^^!^^^!^^^!{\n #} & TIMEOUT /T 3 >nul & Goto :GUIDIn )
	) else ( echo. & %ch%         {0e} Неправильный GUID^^^!^^^!^^^!{\n #} & TIMEOUT /T 3 >nul & Goto :GUIDIn )
) else ( echo. & %ch%         {0e} Возврат в меню Управления обновлениями{\n #}
	 TIMEOUT /T 3 >nul & Goto :UpdateMenu )
if not "!GUIDvalue!"=="" ( goto :GUIDFind ) else ( goto :GUIDName )
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GUIDFind
setlocal
cls
echo.
%ch% {08}   =========================== {\n #}
echo.       Найдена блокировка^^^!
%ch% {08}   =========================== {\n #}
echo.
%ch%        Название:{0b} %Nameblock:~4,-4% {\n #}
%ch%            GUID:{0e} {%GUIDvalue:~4% {\n #}
echo.
echo.       Варианты для выбора:
echo.
%ch% {0b}       [1]{#} = Удалить блокировку {\n #}
%ch% {0b}       [Без ввода]{#} = Отмена {\n #}
echo.
set /p input=*    Ваш выбор: 
if not defined input ( echo. & %ch%      --- {4f} Отмена {#} удаления блокировки --- {\n #} & TIMEOUT /T -1 & endlocal & Goto :GUIDIn )
if "!input!"=="1" ( reg delete "%regpathguid%\Restrictions\DenyDeviceClasses" /v "%Nameblock:~4,-4%" /F
		    echo. & %ch%     {0a} --- Блокировка удалена^^^!{\n #} & TIMEOUT /T -1 & endlocal & Goto :GUIDIn
	) else ( echo. & %ch%         {0e} Неправильный выбор {\n #} & echo.
		 TIMEOUT /T 2 >nul & endlocal & goto :GUIDFind )
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GUIDName
setlocal EnableDelayedExpansion
cls
echo.
%ch% {08}   ======================================= {\n #}
%ch% {0e}       Нет{#} блокировки введенного {0e}GUID^^^!{\n #}
%ch% {08}   ======================================= {\n #}
echo.
%ch%        Введенный GUID: {0e}{!InputGUID! {\n #}
echo.
echo.       Варианты для выбора:
echo.
%ch% {0b}       [Без ввода]{#} = Вернуться в главное меню. {\n #}
%ch% {0b}       [Вписать название]{#} = Добавление блокируемого устройства{\n #}
echo.
set /p InputName=*  Впишите название, английскими буквами ENG: 
echo.%InputName%>name.txt
if exist "name.txt" ( for /f "delims=[]{}()/=+-_?!\*;:'., tokens=1*" %%i in (' findstr /v "[\"\"]" name.txt ') do ( set "InputName1=%%i %%j" )
del /f /q name.txt >nul 2>&1 ) else ( echo.& %ch%         {0e} Имя введено не корректно^^^!{\n #} & TIMEOUT /T 2 >nul & endlocal & Goto :GUIDName )
for /f "tokens=1,2,3" %%i in ("%InputName1%") do ( set "Value1=%%i" & set "Value2=%%j" & set "Value3=%%k" )
if "!Value3!"=="" (
	if "!Value2!"=="" ( set "InputName2=!Value1!" ) else ( set "InputName2=!Value1! !Value2!" )
) else ( set "InputName2=!Value1! !Value2! !Value3!" )
if not "%InputName2%"=="" ( goto :GuNameIs ) else ( echo.& %ch%         {0e} Возврат в главное меню^^^!{\n #} & echo.
			    TIMEOUT /T 3 >nul & endlocal & Goto :GUIDIn )
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GuNameIs
for /f "tokens=1,2,3" %%i in (' echo. %InputName2%^| findstr /i "[a-z]"^| findstr /v "[а-я]"^| findstr /v "[0-9]" ') do (
				set "NameValue1=%%i" & set "NameValue2=%%j" & set "NameValue3=%%k" )
if "%NameValue3%"=="" (
	if "!NameValue2!"=="" ( set "NameEN=!NameValue1!" ) else ( set "NameEN=!NameValue1! !NameValue2!" )
) else ( set "NameEN=!NameValue1! !NameValue2! !NameValue3!" )
if "%NameEN%"=="" ( echo.& %ch%         {0e} Имя введено не английскими буквами^^^! {\n #} & TIMEOUT /T 3 >nul & endlocal & Goto :GUIDName
	) else ( Goto :GuNameEn )
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GuNameEn
for /f "tokens=1,2,3" %%i in (' reg query %guidregkey% /v "%NameEN%" 2^>nul ') do ( set "NameNew1=%%i" & set "NameNew2=%%j" & set "NameNew3=%%k" )
if "%NameNew3%"=="REG_SZ" ( set "NameblockNew=!NameNew1! !NameNew2!" )
if "%NameNew2%"=="REG_SZ" ( set "NameblockNew=!NameNew1!" ) else (
	if not "%NameNew3%"=="REG_SZ" (
		if not "%NameNew2%"=="REG_SZ" ( set "NameblockNew=!NameNew1! !NameNew2! !NameNew3!" )))
if "%InputName2%"=="%NameblockNew%" ( echo.& %ch%         {0e} Введеное имя уже существует {\n #}
				      TIMEOUT /T 3 >nul & endlocal & Goto :GUIDName
 	) else ( echo.& reg add "%regpathguid%\Restrictions\DenyDeviceClasses" /v "%InputName2%" /t REG_SZ /d "%InputGUID%" /f
 		 echo.& %ch%         {0a} Блокировка добавлена^^^!{\n #} & TIMEOUT /T -1 & endlocal & Goto :GUIDIn )
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GUIDdel
cls & echo.& %ch%         {0a} --- Все блокировки по GUID были удалены^^^!{\n #} & echo.
reg delete "%regpathguid%\Restrictions" /f >nul 2>&1
goto :GUIDEnd
:::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::
:GUIDEnd
for /f "tokens=1,3" %%i in (' reg query %guidregkey% 2^>nul ^| find /I "REG_SZ" ') do set "value3=%%i %%j"
if "%value3%"=="" (
	echo. & echo.   ===============================================================
	%ch%       {0e} На данный момент заблокированных по GUID устройств нет.{\n #}
	echo.   =============================================================== & echo.
	reg delete "%regpathguid%\Restrictions" /f >nul 2>&1 )
endlocal
TIMEOUT /T -1
goto :DrMenu

::     -----------------------------------------------------------
::     -----        Конец блокировки драйверов по GUID       -----
::     -----------------------------------------------------------



::     --------------------------------------------------
::     ----      Ниже начинается Сброс настроек      ----
::     --------------------------------------------------

::   Сценарий Меню выбора действий для сброса настроек
:MenuReturn
setlocal
cls
echo.
%ch% {06}    ==========================================================    {\n #}
%ch% {0e}        Сброс{#} сделанных настроек в значения {0e}(по умолчанию) {\n #}
%ch% {06}    ==========================================================    {\n #}
echo.
echo.        Варианты для выбора:
echo.
%ch% {0b}    [1]{#} = {0e}Spy{#} (Только {0c}сброс{#} слежения, сбора и AppStore) {\n #}
%ch% {0b}    [2]{#} = {0e}Settings{#} (Только {0c}сброс{#} дополнительных настроек Windows) {\n #}
%ch% {0b}    [3]{#} = {0e}Сделать все{#} ({0c}Сброс{#} всех Spy и Settings) {\n #}
echo.
%ch% {0b}    [Без ввода]{#} = {08}Вернуться в главное меню {\n #}
echo.
Set /p choice=--- Ваш выбор: 
if not defined choice ( echo. & %ch%     {0e} Возврат в главное меню {\n #} & echo.
			TIMEOUT /T 2 >nul & endlocal & goto :Menu )
if "%choice%"=="1" ( cls & goto :SpyRetn )
if "%choice%"=="2" ( cls & goto :SettRetn )
if "%choice%"=="3" ( cls & goto :SpyRetn
	) else ( echo. & %ch%    {0e}Неправильный выбор {\n #} & echo.
		     TIMEOUT /T 2 >nul & endlocal & goto :MenuReturn )




::     --------------------------------------------------------
::     ----      Ниже начинается Сброс 1 части: Spy      ----
::     --------------------------------------------------------

:SpyRetn
echo.
%ch% {06}   ==================================================================        {\n #}
%ch%         {0b}1 часть: SPY{#} - {0e}Сброс{#} слежения, сбора информации и AppStore {\n #}
%ch% {06}   ==================================================================        {\n #}
echo.
if "%~1"=="QuickApply" set "QuickApply=1"


%ch% {0e} ------------------------------------------------------------------ {\n #}
%ch% {0e} --- Перевод служб на тип запуска "По умолчанию": --- {\n #}


echo.&echo.&echo.
%ch% {0b} --- Служба диагностического отслеживания "DiagTrack" --- {\n #}
sc config DiagTrack start= auto

echo.&echo.&echo.
%ch% {0b} --- Стандартная служба сборщика центра диагностики Microsoft "diagnosticshub.standardcollector.service" --- {\n #}
sc config diagnosticshub.standardcollector.service start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба маршрутизации push-сообщений WAP "dmwappushservice" --- {\n #}
sc config dmwappushservice start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба DataCollectionPublishingService "DcpSvc" заливает в облако все "данные" от приложений --- {\n #}
sc config DcpSvc start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба Посредник подключений к сети "NcbService" для Магазина AppStore (хлам) для получения уведомлений --- {\n #}
sc config NcbService start= demand

echo.&echo.&echo.
%ch% {0b} --- Службы для Xbox Live --- {\n #}
sc config XblGameSave start= demand
sc config XblAuthManager start= demand
sc config XboxNetApiSvc start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба платформы подключенных устройств CDPSvc --- {\n #}
%ch% {0b} --- Для Xbox SmartGlass --- {\n #}
sc config CDPSvc start= delayed-auto

echo.&echo.&echo.
%ch% {0b} --- Служба Диспетчер скачанных карт "MapsBroke" --- {\n #}
sc config MapsBroker start= delayed-auto

echo.&echo.&echo.
%ch% {0b} --- служба WalletService, управление вашими "бабосиками" =) --- {\n #}
sc config WalletService start= demand


echo.&echo.&echo.
%ch% {0b} --- Включение телеметрии и сбора данных "По умолчанию" --- {\n #}
%ch% {0b} --- Включение "psr.exe" (Problem Steps Recorder - Средство записи действий) --- {\n #}
%ch% {0b} --- Включить пометку данных для программы по улучшению Windows --- {\n #}
%ch% {0b} --- Разрешить телеметрию проверки активации Windows --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f
Call :TrustedInstaller "reg delete ""HKLM\SOFTWARE\Classes\AppID\slui.exe"" /v ""NoGenTicket"" /f"



echo.&echo.&echo.
%ch% {0b} --- Включение предварительных версий, инсайдерство "по умолчанию" --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableConfigFlighting" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableExperimentation" /f
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /f


echo.&echo.&echo.
%ch% {0b} --- Включение дополнительного сбора телеметрии, в том числе по "psr.exe" Problem Steps Recorder (по умолчанию) --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Inventory" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Steps-Recorder" /v "Enabled" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Включить дополнительный сбор и отправку данных "PerfTrack" и "DiagTrack" (по умолчанию) --- {\n #}
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\PerfTrack" /v "Disabled" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "Disabled" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DisableAutomaticTelemetryKeywordReporting" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "TelemetryServiceDisabled" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks" /f


echo.&echo.&echo.
%ch% {0b} --- Включение сбора персональных данных, необходимых для "Кортаны" "По умолчанию" --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /f
reg delete "HKCU\SOFTWARE\Microsoft\InputPersonalization" /f
echo.&echo.&echo.
%ch% {0b} --- Включить сбор, обучение и персонализацию ввода набираемых текстов "по умолчанию": --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "AllowInputPersonalization" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /f


echo.&echo.&echo.
%ch% {0b} --- Включение сбора и передачи набираемых вами текстов "по умолчанию" --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Input\TIPC" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /f


echo.&echo.&echo.
%ch% {0b} --- Изменение частоты формирования отзывов на "По умолчанию" --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /f
reg delete "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /f

%ch% {0b} --------------------------------------------------------------------------------- {\n #}
%ch% {0b} --------------------------------------------------------------------------------- {\n #}
%ch% {0b} --- Включение заданий в планировщике по сбору вашей информации для пересылки: --- {\n #}
%ch% {0b} --- А также включение задач для приложений AppStore и Магазина Windows ---------- {\n #}

echo.&echo.&echo.
%ch% {0b} --- Задача, выполняющая сбор данных для SmartScreen --- {\n #}
schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи сбора телеметрических данных программ --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Enable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача собирает и загружает данные "SQM" (Software Quality Metrics) --- {\n #}
%ch% {0b} --- для программного обеспечения {\n #}
%ch% {0b} --- Одна из задач для "CEIP" (Customer Experience Improvement Program)  --- {\n #}
%ch% {0b} --- программа улучшения качества программного обеспечения {\n #}
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача для AppStore --- {\n #}
schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи "CEIP" Программы улучшения качества программного обеспечения --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Enable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Enable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача SIUF (System Initiated User Feedback) Обратная связь с пользователями --- {\n #}
%ch% {0b} --- Помогает понять Microsoft, что вы думаете о различных функциях в операционной системе --- {\n #}
%ch% {0b} --- И то, что вы, возможно, захотите увидеть в будущем --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Enable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача проверки и обновления Карт AppStore --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Maps\MapsToastTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача сборщика полных сведений компьютера и сети --- {\n #}
schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача для "CEIP" --- {\n #}
schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи для синхронизации AppSrore приложений --- {\n #}
schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Enable
schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача автоматически обновляет приложения Магазина Windows --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Enable



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::   Настройка задач "по умолчанию" с правами SYSTEM, с помощью файла "nircmdc.exe"    :::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Настройка задач "по умолчанию" с правами "SYSTEM" {\n #}
%ch% {0b}     Задачи регистрации, доступа и синхронизации с устройствами {\n #} & echo.
Call :SetTaskInSystem "Microsoft\Windows\SettingSync\BackgroundUpLoadTask" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\Device Setup\Metadata Refresh" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\HandleCommand" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceConnectedToNetwork" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic1" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic6" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceScreenOnOff" "/Disable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" "/Enable"
Call :SetTaskInSystem "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" "/Enable"



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Включение задач и логов по телеметрии Office 2013 и 2016 --- {\n #}
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack" /Enable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn" /Enable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack2016" /Enable
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Enable
schtasks /Change /TN "\Microsoft\Office\Office 15 Subscription Heartbeat" /Enable
::  Включение сбора данных по телеметрии Office 2016
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\EventLog-AirSpaceChannel" /v "Start" /t REG_DWORD /d 1 /f )
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" >nul 2>&1
if "%errorlevel%"=="0" ( reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\AirSpaceChannel" /v "Enabled" /t REG_DWORD /d 1 /f )
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Включение задач телеметрии драйверов NVIDIA --- {\n #}
set "NvidiaNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "NvTm" /d ^| find /i "Path" ^| findstr /i "NvTmRepOnLogon_ NvTmRep_ NvTmMon_"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 if "%%~J"=="Disabled" ( schtasks /Change /TN "%%~I" /Enable & set "NvidiaNo=0" ) else ( echo.       Задача уже Включена: "%%~I" & set "NvidiaNo=0" )))
if "%NvidiaNo%"=="1" %ch%        Задач {0a}Нет{\n #}
echo.
%ch% {0b} --- Включение службы телеметрии NVIDIA GeForce Experience --- {\n #}
reg query "HKLM\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" >nul 2>&1
if "%errorlevel%"=="0" (
 sc config NvTelemetryContainer start= auto
 net start NvTelemetryContainer
) else (%ch%       Службы {0a}Нет{#}{\n #})
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  Установка значений конфиденциальности в Modern аплете настроек.  ::
	::  Они предназначены для всех Modern аплетов и AppStore хлама       ::
	::  Эти установки влияют только на текущего пользователя,            ::
	::  и могут быть в ручную изменены в Modern настройках,              ::
	::  кроме некоторых, которые M$ скрыло от пользователя!!!            ::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&echo.&echo.
%ch% {0b} --- Включить SmartScreen --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 1 /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к списку языков  --- {\n #}
reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f

echo.&echo.&echo.
%ch% {0b} --- Разрешить приложеням AppStore на др. устройствах работать на этом устройстве --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "BluetoothPolicy" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к Веб Камере --- {\n #}
@set "Perskey={E5323777-F976-4f5b-9B55-B94699C46E44}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к Микрофону --- {\n #}
@set "Perskey={2EEF81BE-33FA-4800-9670-1CD474972C3F}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к Вашей Учетной записи --- {\n #}
@set "Perskey={C1D23ACC-752B-43E5-8448-8D0E519CD6D6}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ всем приложениям "AppStore" к контактам (этой опции нет в аплете настроек!!!) --- {\n #}
@set "Perskey={7D7E8402-7C54-4821-A34E-AEEFD62DED93}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к календарю --- {\n #}
@set "Perskey={D89823BA-7180-4B81-B50C-7E471E6121A3}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к сообщениям, СМС, ММС --- {\n #}
@set "Perskey={992AFA70-6F47-4148-B3E9-3003349C1548}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить интерфейс для доступа приложений "AppStore" ко всем сообщениям (этой опции нет в аплете настроек!!!) --- {\n #}
@set "Perskey={21157C1F-2651-4CC1-90CA-1F28B02263F6}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложений "AppStore" к Радиомодулям --- {\n #}
@set "Perskey={A8804298-2D5F-42E3-9531-9C8C39EB29CE}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить синхронизацию с устройствами для приложений "AppStore" --- {\n #}
@set "Perskey=LooselyCoupled"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d LooselyCoupled /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f

echo.&echo.&echo.
%ch% {0b} --- Включить доступ всем приложениям "AppStore" к языковым настройкам (этой опции нет в аплете настроек!!!) --- {\n #}
@set "Perskey={BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ приложениям "AppStore" к определению расположения (этой опции нет в аплете настроек!!!) --- {\n #}
@set "Perskey={E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ всех приложений AppStore к телефонным звонкам "Скрытые" --- {\n #}
@set "Perskey={235B668D-B2AC-4864-B49C-ED1084F6C9D3}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ всех приложений AppStore к Журналу вызовов --- {\n #}
@set "Perskey={8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ всех приложений AppStore к уведомлениям пользователя --- {\n #}
@set "Perskey={52079E78-A92B-413F-B213-E8FE35712E72}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ всех приложений AppStore к E-mail --- {\n #}
@set "Perskey={9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ всех приложений AppStore к Мероприятиям "Скрытые" --- {\n #}
@set "Perskey={9D9E0118-1807-4F2E-96E4-2CE57142E196}"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "InitialAppValue" /t REG_SZ /d Unspecified /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Type" /t REG_SZ /d InterfaceClass /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\%Perskey%" /v "Value" /t REG_SZ /d Allow /f



echo.&echo.&echo.
%ch% {0b} --- Включение доступа к личным данным для всех AppStore пакетов, указанных индивидуально: --- {\n #}
%ch% {0b} --- этих опций нет в аплете настроек!!! --- {\n #}
for /f %%i in (' reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess" /s /k /f * ^| find /i "S-1-15" ^| find "{" ') do (
	reg add %%i /v "Type" /t REG_SZ /d InterfaceClass /f
	reg add %%i /v "Value" /t REG_SZ /d Allow /f )
for /f %%i in (' reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess" /s /k /f * ^| find /i "S-1-15" ^| find "LooselyCoupled" ') do (
	reg add %%i /v "Type" /t REG_SZ /d LooselyCoupled /f
	reg add %%i /v "Value" /t REG_SZ /d Allow /f )

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Разрешить фоновую работу Аплета "настроек" Windows  {\n #}
%ch% {0b} --- Переключатель должен находится в: Параметры -^> Конфиденциальность -^> Фоновые приложения... {\n #}
setlocal
set regpath="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
for /f "delims=\ tokens=7" %%i in (' reg query %regpath% /s /f "immersivecontrolpanel" ') do set "reply=%%i"
if not "%reply%"=="" (
	reg add "%regpath:~1,-1%\%reply%" /v "Disabled" /t REG_DWORD /d 0 /f
	reg add "%regpath:~1,-1%\%reply%" /v "DisabledByUser" /t REG_DWORD /d 0 /f
	reg add "%regpath:~1,-1%\%reply%" /v "IgnoreBatterySaver" /t REG_DWORD /d 0 /f
	) else ( echo. & echo.     Отмена, ключ "immersivecontrolpanel" не существует! & echo. )
endlocal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



cd /d "%~dp0"
if "%QuickApply%"=="1" set "QuickApply=" & exit /b

if "%choice%"=="1" (
 rem Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
 Call :LGPO_FILE_APPLY

 echo. & echo. & echo.
 %ch% {06}    =========================================     {\n #}
 %ch%         Завершен {0e}сброс{#} только {0b}1 части: SPY {\n #}
 %ch% {06}    =========================================     {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :MenuReturn
) else (
 echo.
 %ch% {06}    ==================================     {\n #}
 %ch%         Завершен {0e}сброс{#} {0b}1 части: SPY {\n #}
 %ch% {06}    ==================================     {\n #}
 echo.
 goto :SettRetn
)


::     --------------------------------------------------------
::     ---    Ниже начинается Сброс 2 части: Settings    ----
::     --------------------------------------------------------

:SettRetn
echo.
%ch% {06}    ======================================================        {\n #}
%ch%         {0b}2 часть: Settings{#}  -  {0e}Сброс{#} настроек Windows 10 {\n #}
%ch% {06}    ======================================================        {\n #}
echo.
if "%~1"=="QuickApply" set "QuickApply=1"


%ch% {0e} --------------------------------------------------------------------------------------------- {\n #}
%ch% {0e} --- Включение необязательных служб по обслуживанию системы на тип запуска "По умолчанию": --- {\n #}

echo.&echo.&echo.
%ch% {0b} --- Служба общих сетевых ресурсов проигрывателя Windows Media "WMPNetworkSvc" --- {\n #}
sc config WMPNetworkSvc start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба Немедленные подключения Windows для Windows Connect Now, --- {\n #}
%ch% {0b} --- настраивает параметры точки доступа или WiFi --- {\n #}
sc config wcncsvc start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба наблюдения за датчиками "SensrSvc" (кооректировка яркости дисплея, поворота экрана и т.д.) --- {\n #}
sc config SensrSvc start= demand

echo.&echo.&echo.
%ch% {0b} --- Биометрическая служба Windows "WbioSrvc" --- {\n #}
sc config WbioSrvc start= auto

echo.&echo.&echo.
%ch% {0b} --- "Служба датчиков" (датчики поворота дисплея, местоположения и т.д.) --- {\n #}
sc config SensorService start= demand

echo.&echo.&echo.
%ch% {0b} --- Служба "Служба данных датчиков" --- {\n #}
sc config SensorDataService start= demand


echo.&echo.&echo.
%ch% {0b} --- Служба Windows License Manager для Windows AppStore (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LicenseManager" /v "Start" /t REG_DWORD /d 3 /f

echo.&echo.&echo.
%ch% {0b} --- Служба Географического расположения для AppStore (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 3 /f

echo.&echo.&echo.
%ch% {0b} --- Служба push-уведомлений Windows для приложений AppStore (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d 3 /f

echo.&echo.&echo.
%ch% {0b} --- Помощник по входу в учетную запись Майкрософт, необходим для магазина Windows (по умолчанию) --- {\n #}
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wlidsvc" /v "Start" /t REG_DWORD /d 3 /f




echo.&echo.&echo.
%ch% {0e} -------------------------------------------------------------------------------- {\n #}
%ch% {0e} -------------------------------------------------------------------------------- {\n #}
%ch% {0e} --- Включение необязательных заданий в планировщике по обслуживанию системы: --- {\n #}


echo.&echo.&echo.
%ch% {0b} --- Задача очистки системного диска во время простоя (задолбала постоянно насиловать диск) --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskCleanup\SilentCleanup" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача оценки объема использования диска --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Enable

@echo.
%ch% {0b} --- Задача для "Storage Sense" перемещение Modern Apps на другой диск по необходимости --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\StorageSense" /Enable

@echo.
%ch% {0b} --- Задачи Проверки томов на отказоустойчивость --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan" /Enable
schtasks /Change /TN "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача копирования файлов пользователя в "резервное" расположение (меню предыдущие версии файлов) --- {\n #}
%ch% {0b} --- При использовании службы архивации --- {\n #}
schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача измеряет быстродействие и возможности системы --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи Обслуживания памяти во время простоя и при ошибках --- {\n #}
schtasks /Change /TN "Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /Enable
schtasks /Change /TN "Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача анализирования энергопотребления системы --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи контроля и выполнения семейной безопасности --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Enable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача отправки отчетов об ошибках --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Enable

	::::::::::::::::::::::::::::::::::::::::::::::::::
	::::::::   сброс дополнительных задач   ::::::::::
	::::::::::::::::::::::::::::::::::::::::::::::::::

echo.&echo.&echo.
%ch% {0b} --- Задача очистки контента Retail Demo --- {\n #}
schtasks /Change /TN "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи уведомлений о вашем расположении: --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Location\Notifications" /Enable
schtasks /Change /TN "Microsoft\Windows\Location\WindowsActionDialog" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача анализа метаданных мобильной сети --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача веб-сайта инфраструктуры диагностики Windows --- {\n #}
schtasks /Change /TN "Microsoft\Windows\WDI\ResolutionHost" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача обновления новых файлов в библиотеке мультимедиа --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи регистрации и проверки ссылок от приложений  --- {\n #}
%ch% {0b} --- В Windows appUriHandler, для получения поддержки от разработчиков  --- {\n #}
schtasks /Change /TN "Microsoft\Windows\ApplicationData\appuriverifierinstall" /Enable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\appuriverifierdaily" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача сбора и отправки данных об устройствах --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Device Information\Device" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи Xbox --- {\n #}
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Enable
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача DUSM (Data Usage Subscription Management) для мобильного интернета --- {\n #}
schtasks /Change /TN "Microsoft\Windows\DUSM\dusmtask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи по детализации ошибок --- {\n #}
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Enable
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Disable

echo.&echo.&echo.
%ch% {0b} --- Задача выдачи временных лицензий для Приложений Магазина --- {\n #}
schtasks /Change /TN "Microsoft\Windows\License Manager\TempSignedLicenseExchange" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача по согласованию пакетов во время SYSPREP и загрузки "ProvTool.exe" --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Management\Provisioning\Logon" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача фонового взаимодействия через WiFi  --- {\n #}
schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Enable
schtasks /Change /TN "Microsoft\Windows\WCM\WiFiTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задачи обслуживания дисковых пространств (аналог RAID, виртуальные диски) --- {\n #}
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceAgentTask" /Enable
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceManagerTask" /Enable

echo.&echo.&echo.
%ch% {0b} --- Задача загрузки голосовых моделей --- {\n #}
schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Enable


	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::::::::   Настройка системных компонентов и программ (по умолчанию)  ::::::::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&echo.&echo.
%ch% {0b} --- Включение получения обновлений и телеметрии для средства удаления "вирусов" ---  {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /f



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if not exist "%USERPROFILE%\AppData\Local\Microsoft\OneDrive\OneDrive.exe" ( goto :SkipOneDriveOn )
echo.&echo.&echo.
%ch% {0b} --- Включение OneDrive --- {\n #}
reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf080004d /f
reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf080004d /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /t REG_SZ /d "\"%USERPROFILE%\AppData\Local\Microsoft\OneDrive\OneDrive.exe\" /background" /f
if "%xOS%"=="x64" (
 echo.
 %ch% {0b} --- Включение дополнительных ключей для х64 для OneDrive "по умолчанию" --- {\n #}
 reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
 reg add "HKLM\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf080004d /f
 reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
 reg add "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v "Attributes" /t REG_DWORD /d 0xf080004d /f
)
echo.
set "OneDriveTaskNo=1"
for /f "tokens=2 delims=\" %%I in ('
 reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks" /s /f "OneDrive" /d ^| find /i "Path" ^| find /i "OneDrive"
') do ( for /f "tokens=3 delims=," %%J in (' SCHTASKS /Query /FO CSV /NH /TN "%%I" ') do (
 if "%%~J"=="Disabled" ( schtasks /Change /TN "%%~I" /Enable & set "OneDriveTaskNo=0" ) else ( echo.       Задача: "%%~I" уже включена & set "OneDriveTaskNo=0" )))
if "%OneDriveTaskNo%"=="1" %ch%        Задач OneDrive {0a}Нет{\n #}
echo.
:SkipOneDriveOn
echo.&echo.&echo.
%ch% {0b} --- Снять запрет использования OneDrive --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableMeteredNetworkFileSync" /f



echo.&echo.&echo.
%ch% {0b} --- Включить уведомления поставщика синхронизации (реклама в проводнике от OneDrive, по умолчанию) --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /f


echo.&echo.&echo.
%ch% {0b} --- Включение служб синхронизации, так же необходимых и для OneDrive (по умолчанию) --- {\n #}
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "CDPUserSvc" ^| find /i "CDPUserSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 2 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "OneSyncSvc" ^| find /i "OneSyncSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 2 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "PimIndexMaintenanceSvc" ^| find /i "PimIndexMaintenanceSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 3 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UnistoreSvc" ^| find /i "UnistoreSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 3 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "UserDataSvc" ^| find /i "UserDataSvc" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 3 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "MessagingService" ^| find /i "MessagingService" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 3 /f )
for /f %%I in (' reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "WpnUserService" ^| find /i "WpnUserService" ') do (
reg add "%%I" /v "Start" /t REG_DWORD /d 3 /f )
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



echo.&echo.&echo.
%ch% {0b} --- Включить автопередачу паролей к своим WiFi на сервер Microsoft (WiFiSense) --- {\n #}
%ch% {0b} --- и автоподключение к WiFi без пароля и от моих контактов (по умолчанию) --- {\n #}
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /f
%ch% {0b} --- Разрешить автоподключение к левым WiFi всем пользователям найденных в этой ветке (по умолчанию)  {\n #}
%ch% {0b} --- 828 = Все отключено; 893 = Все включено; {\n #}
%ch% {0b} --- 829 = только автоподключение к WiFi без пароля; 892 = только автоподключение к WiFi от ваших контактов {\n #}
for /f %%i in (' reg query "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" ^| find "S-1" ') do (
	reg add %%i /v "FeatureStates" /t REG_DWORD /d 893 /f )


echo.&echo.&echo.
%ch% {0b} --- Открытие проводника на разделе "По умолчанию" --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /f


echo.&echo.&echo.
%ch% {0b} --- Скрыть значок "Этот компьютер" с рабочего стола --- {\n #}
%ch% {0b} --- 0 = Включить, 1 = Скрыть ---  {\n #}
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Включение залипания клавиши SHIFT после 5 нажатий --- {\n #}
%ch% {0b} --- 506 = Выкл, 510 = Включить (По умолчанию) ---  {\n #}
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "510" /f


echo.&echo.&echo.
%ch% {0b} --- Скрывать скрытые файлы и папки в проводнике --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 2 /f


echo.&echo.&echo.
%ch% {0b} --- Скрыть расширения файлов в проводнике --- {\n #}
%ch% {0b} --- 0 = Отображать --- {\n #}
%ch% {0b} --- 1 = Скрывать --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 1 /f


echo.&echo.&echo.
%ch% {0b} --- Включение отображения вкладки "предыдущие версии" в свойствах файлов по ПКМ меню --- {\n #}
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "NoPreviousVersionsPage" /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ в интернет службе защиты аудио - Windows Media Digital Rights Management (DRM) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /f


echo.&echo.&echo.
%ch% {0b} --- Вернуть в ПКМ меню и проводник опции Bitlocker --- {\n #}
reg delete "HKEY_CLASSES_ROOT\Drive\shell\change-passphrase" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\change-pin" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\manage-bde" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\resume-bde-elev" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\resume-bde" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\encrypt-bde-elev" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\encrypt-bde" /v "LegacyDisable" /f
reg delete "HKEY_CLASSES_ROOT\Drive\shell\unlock-bde" /v "LegacyDisable" /f


echo.&echo.&echo.
%ch% {0b} --- Включение определения вашего расположения для AppStore и Других программ (Геозона)--- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /f



echo.&echo.&echo.
%ch% {0b} --- Возможность использования web камеры с Лок-скрина. и вся Персанолизация (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f


echo.&echo.&echo.
%ch% {0b} --- Включить Фрейм Сервер M$ (по умолчанию)--- {\n #}
%ch% {0b} --- Фрейм Сервер Позволяет получать доступ к одной камере нескольким приложениям. --- {\n #}
reg delete "HKLM\SOFTWARE\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /f
if "%xOS%"=="x64" (
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation\Platform" /v "EnableFrameServerMode" /f )
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FrameServer" /V "Start" /t REG_DWORD /d 3 /f



echo.&echo.&echo.
%ch% {0b} --- Выключаем "NumLock" у всех, в том числе на Логин-Скрине (по умолчанию) --- {#}
reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2147483648 /f
reg add "HKEY_USERS\S-1-5-18\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2147483648 /f
reg add "HKEY_USERS\S-1-5-19\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2147483648 /f
reg add "HKEY_USERS\S-1-5-20\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2147483648 /f
reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2147483648 /f


echo.&echo.&echo.
%ch% {0b} --- Включение рекламы Windows Update в модерн настройках --- {\n #}
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "HideMCTLink" /f



	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::   Сброс части параметров из Групповой Политики             :::::
	:::::   Кто настраивает ГП, надо сбросить так же настройки ГП    :::::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&echo.&echo.
%ch% {0b} --- Включить SmartScreen (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /f


echo.&echo.&echo.
%ch% {0b} --- Включить отправку отчетов об ошибках (по умолчанию): --- {\n #}
reg add "HKCU\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 0 /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /f


echo.&echo.&echo.
%ch% {0b} --- Включить анализ и отправку данных "PerfTrack" через SQM (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /f


echo.&echo.&echo.
%ch% {0b} --- Включить средство диагностики "MSDT" для технической поддержки (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "ScenarioExecutionEnabled" /f


echo.&echo.&echo.
%ch% {0b} --- Включить синхронизацию (по умолчанию): --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "EnableBackupForWin8Apps" /f


echo.&echo.&echo.
%ch% {0b} --- Сбросить настроенные параметры IE (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer" /v "AllowServicePoweredQSA" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DoNotTrack" /f
reg delete "HKCU\SOFTWARE\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableToolbars" /f


echo.&echo.&echo.
%ch% {0b} --- Включить синхронизацию RSS-каналов в фоновом режиме (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /f

echo.&echo.&echo.
%ch% {0b} --- Разрешить использование биометрии --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /f


echo.&echo.&echo.
%ch% {0b} --- Включить Windows Hellow для бизнеса (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork" /v "Enabled" /f


echo.&echo.&echo.
%ch% {0b} --- Включить проверку новостей по поддержке Windows Mail и саму программу (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "DisableCommunities" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows Mail" /v "ManualLaunchAllowed" /f


echo.&echo.&echo.
%ch% {0b} --- Включить запуск Windows Messenger и программу улучшения (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "PreventRun" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "PreventRun" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Messenger\Client" /v "CEIP" /f


echo.&echo.&echo.
%ch% {0b} --- Включить автоскачивание данных карт и незапрошенный трафик (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /f


echo.&echo.&echo.
%ch% {0b} --- Разрешить синхронизацию приложений (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /f


echo.&echo.&echo.
%ch% {0b} --- Включить все приложения из магазина и магазин (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "DisableStoreApps" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /f
:: Включение обновления Магазина Windows
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d 4 /f
%regad% "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d 4 /f


echo.&echo.&echo.
%ch% {0b} --- Включение Записи игр GAME Bar, WIN+G (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /f


echo.&echo.&echo.
%ch% {0b} --- Вернуть настройки обозревателя игр (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "DownloadGameInfo" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "GameUpdateOptions" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameUX" /v "ListRecentlyPlayed" /f


echo.&echo.&echo.
%ch% {0b} --- Включить возможности облака Microsoft и показывать советы (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /f


echo.&echo.&echo.
%ch% {0b} --- Включить идентификатор объявлений для профилей пльзователей (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /f


echo.&echo.&echo.
%ch% {0b} --- Включить Вэб публикацию в списке задач для файлов (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /f


echo.&echo.&echo.
%ch% {0b} --- Включить доступ к магазину (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /f


echo.&echo.&echo.
%ch% {0b} --- Включить обновление файлов помощника по поиску (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\SearchCompanion" /v "DisableContentFileUpdates" /f


echo.&echo.&echo.
%ch% {0b} --- Хранить сведения о зоне происхождения файлов (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /f

echo.&echo.&echo.
%ch% {0b} --- Включение исправления, выделения и прогнозирования текста (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffAutocorrectMisspelledWords" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffHighlightMisspelledWords" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "TurnOffOfferTextPredictions" /f


echo.&echo.&echo.
%ch% {0b} --- Включить рейтинг и программу улучшения справки (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoImplicitFeedback" /f




	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:::::   Ниже идет сброс Дополнительных параметров из Групповой Политики    ::::::
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ГП: Компоненты Windows/Internet Explorer/Конфиденциальность
%ch% {0b} --- Включить сбор данных фильтрации InPrivate (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableLogging" /f

:: ГП: Компоненты Windows/Internet Explorer/Меню браузера
%ch% {0b} --- Включить возможность отправки отчетов об ошибках (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "NoReportSiteProblems" /f

:: ГП: Компоненты Windows/Встроенная справка
%ch% {0b} --- Включение активной справки (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoActiveHelp" /f

:: ГП: Компоненты Windows/Звукозапись
%ch% {0b} --- Разрешить выполнение программы "Звукозапись" (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\SoundRecorder" /v "Soundrec" /f

:: ГП: Компоненты Windows/Календарь Windows
%ch% {0b} --- Включить календарь Windows (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Windows" /v "TurnOffWinCal" /f

:: ГП: Компоненты Windows/Платформа защиты программного обеспечения
%ch% {0b} --- Вкючение веб-проверки AVS (телеметрия активации) (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /f

:: ГП: Компоненты Windows/Подключить
%ch% {0b} --- Разрешать проекцию на этот компьютер (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Connect" /v "AllowProjectionToPC" /f

:: ГП: Компоненты Windows/Цифровой ящик
%ch% {0b} --- Разрешать работу цифрового ящика Windows Marketplace (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Digital Locker" /v "DoNotRunDigitalLocker" /f

:: ГП: Система/Диагностика/Средство диагностики службы технической поддержки Майкрософт
%ch% {0b} --- Разрешить сбор и передачу данных поддержке MS (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "DisableQueryRemoteServer" /f
%ch% {0b} --- Разрешить Средства диагностики поддержки Майкрософт (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46ac-8BEE-B1715EC634E5}" /v "DownloadToolsEnabled" /f

:: ГП: Компоненты Windows/Проводник
%ch% {0b} --- Включить кэширование эскизов в скрытых файлах thumbs.db (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableThumbsDBOnNetworkFolders" /f
%ch% {0b} --- Включить кэширование эскизов изображений (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f

:: ГП: Компоненты Windows/Содержимое облака
%ch% {0b} --- Включить все функции SpotLight на экране блокировки (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightFeatures" /f

:: ГП: Меню «Пуск» и панель задач/Уведомления
%ch% {0b} --- Включить уведомления и обновления плиток в меню пуск (по умолчанию) --- {\n #}
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /f



	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	::  Включение синхронизации персональных настроек Windows,        ::
	::  таких как пароли, настройки браузера, оформление и прочее,    ::
	::  необходимых для аккаунта M$, кортаны и др. хлама,             ::
	::  этих опций нету в Modern аплете настроек                      ::
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.&echo.&echo.
%ch% {0b} --- Включение синхронизации персональных настроек программ и Windows --- {\n #}
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\DesktopTheme" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\PackageState" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" /v "Enabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d 1 /f
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
cd /d "%~dp0"
echo.&echo.&echo.
%ch% {0b} --- Включение проверки правописания, выделения ошибок и прогнозирования (по умолчанию) --- {\n #}
%ch% {0b} --- Общий параметр меняется с помощью файла "SetAcl.exe"  {\n #}
%SetACL% -on "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" -ot reg -actn setowner -ownr n:S-1-1-0
%SetACL% -on "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" -ot reg -actn ace -ace n:S-1-1-0;p:full
reg delete "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /f
reg delete "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /f
%SetACL% -on "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" -ot reg -actn setowner -ownr n:SYSTEM
%SetACL% -on "HKLM\SOFTWARE\Microsoft\TabletTip\1.7" -ot reg -actn trustee -trst n1:S-1-1-0;ta:remtrst
reg delete "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableAutocorrection" /f
reg delete "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "EnableSpellchecking" /f
Call :LGPO_FILE reg delete "HKLM\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /f
Call :LGPO_FILE reg delete "HKCU\SOFTWARE\Policies\Microsoft\TabletTip\1.7" /v "DisablePrediction" /f
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


echo.&echo.&echo.
%ch% {0b} --- Возврат использование 85% качества картинки, --- {\n #}
%ch% {0b} --- при установке обоев рабочего стола, по умолчанию {\n #}
reg delete "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /f


echo.&echo.&echo.
%ch% {0b} --- Включение функций центра специальных возможностей (по умолчанию) --- {\n #}
:: Включить горячие клавиши для включения высокой контрастности из центра специальных возможностей
reg add "HKCU\Control Panel\Accessibility\HighContrast" /v "Flags" /t REG_SZ /d 4222 /f
:: Включить озвучивание параметров при входе в центр специальных возможностей
reg add "HKCU\SOFTWARE\Microsoft\Ease of Access" /v "selfscan" /t REG_DWORD /d 1 /f
:: Включить автозапуск средств: экранной лупы, диктора или клавиатуры,
:: при использовании центра специальных возможностей для сенсорных панелей и планшетов
reg add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "LaunchAT" /t REG_DWORD /d 1 /f
reg add "HKCU\Control Panel\Accessibility\SlateLaunch" /v "ATapp" /t REG_SZ /d narrator /f


cd /d "%~dp0"
if "%QuickApply%"=="1" set "QuickApply=" & exit /b

:: Настроить Групповые Политики, созданным файлом LGPO через вызов "Call :LGPO_FILE"
Call :LGPO_FILE_APPLY

if "%choice%"=="2" (
 echo.
 %ch% {06}    ==============================================     {\n #}
 %ch%         Завершен {0e}сброс{#} только {0b}2 части: Settings {\n #}
 %ch% {06}    ==============================================     {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :MenuReturn
) else (
 echo. & echo. & echo.
 %ch% {06}    ===================================================    {\n #}
 %ch%         Завершен {0e}сброс{#} обеих частей: {0b}Spy и Settings {\n #}
 %ch% {06}    ===================================================    {\n #}
 echo.
 echo.        Для возврата в меню нажмите любую клавишу.
 echo.
 TIMEOUT /T -1 >nul
 endlocal & goto :MenuReturn
)


::     ----------------------------------------------
::     -----        Конец сброса настроек       -----
::     ----------------------------------------------







::     -------------------------------------------------------
::     -----    Ниже расположены сценарии управления     -----
::     -------------------------------------------------------


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


:: Сценарий поиска метки BOM (Byte Order Mark) в файле UTF-8, если найдена, то пересоздание файла без нее.
:: Как бы удаление метки BOM (переделка из файла "UTF-8 с BOM" в файл "UTF-8 без BOM")
:: В файле могут быть любые символы, ограничений нет! Пустые строки также сохраняются.
:BOMRemove
setlocal DisableDelayedExpansion
chcp 65001 >nul
set InFileUTF=%~1
set OutFileUTF=%~2
set BOM=∩╗┐
chcp 437 >nul
type "%InFileUTF%" | find /n /c "%BOM%" >nul
if not "%Errorlevel%"=="0" ( chcp 65001 >nul & exit /b )
for /f "tokens=2 delims=:" %%I in (' find /c /v "" "%InFileUTF%" ') do set /a N=%%I
@<"%InFileUTF%">"%OutFileUTF%" ( for /l %%I in (1, 1, %N%) do ( set "LINE=" & set /p "LINE="
if defined LINE if "%%I"=="1" ( call set /p "=%%LINE:~3%%" <nul ) else ( call set /p "=%%LINE%%" <nul )
echo.))
chcp 65001 >nul
echo.F| xcopy /Y /Q /R "%OutFileUTF%" "%InFileUTF%" >nul
del /f /q "%OutFileUTF%"
exit /b


:: сценарий настройки задач с правами "System"
:SetTaskInSystem
cd /d "%~dp0"
setlocal EnableDelayedExpansion
set "TaskName=%~1"
set "TaskAction=%~2"
if /i "%TaskAction%"=="/Disable" (set "TaskValue=Disabled" & set "ReplyInfo=Отключена")
if /i "%TaskAction%"=="/Enable" (set "TaskValue=Ready" & set "ReplyInfo=Включена")
if "%TaskAction%"=="" (exit /b)
for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%TaskName%"  ') do set "ReplyTask=%%~I"
if not "!ReplyTask!"=="" (
 if "!ReplyTask!"=="!TaskValue!" ( %ch%      Задача: "%TaskName%" {2f} Уже %ReplyInfo% {00}.{\n #} & echo.
 ) else (
  %NirCMDc% ElevateCMD RunAsSystem cmd /c schtasks /Change /TN "%TaskName%" %TaskAction% & TIMEOUT /T 1 >nul
  for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%TaskName%" ') do if not "%%~I"=="!TaskValue!" TIMEOUT /T 1 >nul
  for /f "delims=, tokens=3" %%I in (' 2^>nul SCHTASKS /QUERY /FO CSV /NH /TN "%TaskName%" ') do set "ReplyTask=%%~I"
  if "!ReplyTask!"=="!TaskValue!" ( %ch%      Задача: "%TaskName%" {2f} %ReplyInfo% {00}.{\n #} & echo. )
 )
) else (echo.     Задача "%TaskName%" не существует! & echo.)
exit /b


:: Сценарий корректного перезапуска проводника, с сохранением параметров
:ReStartExplorer
echo.&%ch%     {0b}Перезапуск проводника {08}^(Корректный, с сохранением параметров^){\n #}
%NirCMDc% win close class "CabinetWClass" & %ExitExplorer%
taskkill /f /im explorer.exe >nul 2>&1
start "" explorer.exe
tasklist /FO TABLE /NH /FI "ImageName EQ explorer.exe" 2>nul | find /i "explorer.exe" >nul || (start "" explorer.exe)
exit /b


:: сценарий выполнения команды с правами "TrustedInstaller"
:TrustedInstaller
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\seclogon" /v "Start" ') do set /a "FindValue=%%I"
if "%FindValue%"=="4" sc config seclogon start= demand& net start seclogon
for /f "tokens=3" %%I in (' 2^>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\trustedinstaller" /v "Start" ') do set /a "FindValue=%%I"
if "%FindValue%"=="4" %NirCMDc% ElevateCMD RunAsSystem cmd "cmd /c sc config trustedinstaller start= demand"
tasklist /FO TABLE /NH /FI "ImageName EQ trustedinstaller.exe" 2>nul | find /i "trustedinstaller.exe" >nul || (net start trustedinstaller)
%NirCMDc% ElevateCMD RunAsSystem %RunFromToken% trustedinstaller.exe 1 "%~1"
TIMEOUT /T 1 /NOBREAK >nul
exit /b


:: Сценарий установки основных переменных и проверки наличия нужных файлов в папке с этим bat файлом.
:First
chcp 65001 >nul
cd /d "%~dp0"
set xOS=x64& (If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86)
set ch="%~dp0Files\Tools\cecho.exe"
set ExitExplorer="%~dp0Files\Tools\ExitExplorer.exe"
set "SetACL=Files\Tools\SetACL%xOS%.exe"
set "NirCMDc=Files\Tools\nircmdc_%xOS%.exe"
set "Handle=Files\Tools\Handle.exe"
set "RunFromToken=Files\Tools\RunFromToken_%xOS%.exe"
set "Smartctl=Files\Tools\smartctl.exe"
set "Zip=Files\Tools\7z.exe"

for /f "tokens=3*" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "UBR" ') do set /a BuildVer=%%I
if "%BuildVer%" NEQ "" set "BuildVer=.{0f}%BuildVer%{#}"
for /f "tokens=4 delims=[] " %%I in ('ver') do (
 if "%%I"=="10.0.14393" (set "OSVersion={0a}%%I%BuildVer%{#}" & set "OSVers=%%I"
 ) else (set "OSVersion={0e}%%I  {4f} Версия не поддерживается {#}" & set "OSVers=%%I"))
for /f "tokens=3*" %%I in (' 2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName" ') do (
 if not "%%I %%J"=="Windows 10 Enterprise 2016 LTSB" (set "ProductNameNo={0c}%%I %%J{#}"
 ) else if "%OSVers%"=="10.0.14393" (set "ProductName=^| {0a}LTSB RS1{#}"))

set LGPO="%~dp0Files\Tools\LGPO.exe"
set "LGPOtemp=%TEMP%\LGPO-temp.txt"
if exist "%LGPOtemp%" del /f /q "%LGPOtemp%"
if not exist "%WinDir%\System32\gpedit.msc" set "GPEditorNO=1"

set "PresetLGPO=Files\GP\LGPO-Machine-User.txt"
set "PresetLGPOMy=Files\GP\LGPO-Machine-User-My.txt"
set "PresetLGPOTemp=%TEMP%\LGPO-Temp-Preset.txt"
if exist "%PresetLGPOTemp%" del /f /q "%PresetLGPOTemp%"

:: Переменные для подстановки к параметрам реестра при условии разрядности.
if "%xOS%"=="x64" ( set "regad=reg add" & set "regdelet=reg delete" ) else ( set "regad=rem" & set "regdelet=rem" )

if not exist %ch% ( echo.&echo.        Нет файла "cecho.exe" в папке "\Files\Tools"
		    echo.&echo.        Отмена, выход & TIMEOUT /T 5 >nul & exit )
if "%xOS%"=="x64" (
 if not exist "%SystemRoot%\System32\Wow64.dll" (
  echo.&%ch%        {0e}"Ошибка, Батник запущен из-под 32-bit оболочки!"{\n #}
  echo.&%ch%        {4f} Отмена {#} выход {\n #} & TIMEOUT /T 8 >nul & exit )
)
if not exist %NirCMDc% ( echo.&%ch%        Нет файла {0e}nircmdc_%xOS%.exe{#} в папке {0e}\Files\Tools{\n #}
			 echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %SetACL% ( echo.&%ch%        Нет файла {0e}SetACL%xOS%.exe{#} в папке {0e}\Files\Tools{\n #}
			echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %Handle% ( echo.&%ch%        Нет файла {0e}Handle.exe{#} в папке {0e}\Files\Tools{\n #}
			echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %RunFromToken% ( echo.&%ch%        Нет файла {0e}RunFromToken_%xOS%.exe{#} в папке {0e}\Files\Tools{\n #}
			      echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %Smartctl% ( echo.&%ch%        Нет файла {0e}Smartctl.exe{#} в папке {0e}\Files\Tools{\n #}
			  echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %ExitExplorer% ( echo.&%ch%        Нет файла {0e}ExitExplorer.exe{#} в папке {0e}\Files\Tools{\n #}
			      echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist Files\Tools\ViewMyDisks.ps1 ( echo.&%ch%        Нет файла скрипта PowerShell {0e}ViewMyDisks.ps1{#} в папке {0e}\Files\Tools{\n #}
					   echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %LGPO% ( echo.&%ch%        Нет файла {0e}LGPO.exe{#} в папке {0e}\Files\Tools{\n #}
		      echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist %Zip% ( echo.&%ch%        Нет файла {0e}7z.exe{#} в папке {0e}\Files\Tools{\n #}
		     echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )
if not exist Files\Tools\7z.dll ( echo.&%ch%        Нет файла {0e}7z.dll{#} в папке {0e}\Files\Tools{\n #}
				  echo.&%ch%        {4f} Отмена, {#} выход {\n #} & TIMEOUT /T 5 >nul & exit )

for /f "tokens=2* delims==" %%I in (' 2^>nul type "Files\Presets.txt" ^| find "Set-Deny-Newbie" ') do set "Set-Deny-Newbie=%%~I"
if "%Set-Deny-Newbie%" EQU "1" set "Newbie=1"

:: Сценарий перезапуска батника от Админа, если батник запущен без повышенных прав. Будет выведен запрос UAC на получение админских прав.
reg query "HKU\S-1-5-19\Environment" >nul 2>&1 & cls
if "%Errorlevel%" NEQ "0" ( cmd /u /c echo. CreateObject^("Shell.Application"^).ShellExecute "%~f0", "%1 %2", "", "runas", 1 > "%Temp%\GetAdmin.vbs"
"%Temp%\GetAdmin.vbs" & del "%Temp%\GetAdmin.vbs" & cls & exit )

if /i "%~1" EQU "/RunQuickSettings" ( if /i "%~2" EQU "/QuickExit" set "QuickExit=1"
 set "RunQuickSettings=1" & goto :QuickSettings
)
goto :LangVers
