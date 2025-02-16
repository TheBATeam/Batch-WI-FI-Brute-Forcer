@Echo off
Setlocal EnableDelayedExpansion
cls
cd /d "%~dp0Files"
call VT100.bat
Set _Temp=0
set _Interface_Count=0
set _Interface_String=
for /f "tokens=*" %%A in ('netsh wlan show interfaces') do (
	if /i "!_Temp!" == "0" (set "_Interface_String=%%A")
	set _Temp=1
	)

echo !_Interface_String!
call :extract_num "!_Interface_String!" _Interface_Count
echo Total interface: !_Interface_Count!

set _Temp=0
set _Count=0
set _Index=-1
for /f "skip=2 tokens=1,* delims=:" %%A in ('netsh wlan show interfaces') do (
	if "%%B" NEQ "" (
		if !_Temp! == 0 (
			set "_Interface_Name=%%~B"
			
			REM  Removing, if the String 'Wifi' present in Name
			REM  Removing, any number present in Name
			REM  Using this method, because, sometimes the description of interface also has word - Wi-Fi
			REM  e.g: Wifi, Wi-fi, Wi-fi 2, Wi-fi 3 etc.
			REM echo !_Interface_Name!
			set "_Interface_Name=!_Interface_Name:-=!"
			REM echo !_Interface_Name!
			set "_Interface_Name=!_Interface_Name:wifi=!"
			REM echo !_Interface_Name!
			for /L %%a in (0,1,9) do (set "_Interface_Name=!_Interface_Name:%%a=!")
			REM echo. !_Interface_Name!.
			set "_Interface_Name=!_Interface_Name: =!"
			REM echo !_Interface_Name!
			
			if "!_Interface_Name!" == "" (
				REM Echo Name: %%B
				Set _Temp=1
				Set /A _Index+=1
			)		
			set _Count=0
		)
		
		Set /A _Count+=1
		if !_Count! GTR 4 (Set _Temp=0)
		
		if !_Temp! == 1 (
			set "_Temp_Value=%%~B"
			set "_Temp_Value=!_Temp_Value: =!"
			
			if !_Count! == 1 (set "_Interface[!_Index!]_Name=!_Temp_Value!")
			if !_Count! == 2 (set "_Interface[!_Index!]_Description=%%~B")
			if !_Count! == 3 (set "_Interface[!_Index!]_GUID=!_Temp_Value!")
			if !_Count! == 4 (set "_Interface[!_Index!]_Mac=!_Temp_Value!")
			echo !_Temp_Value!
		)
	)
)

for /l %%A in (0,1,!_Index!) do (
	echo Name: !_Interface[%%A]_Name!
	echo Desc: !_Interface[%%A]_Description!
	echo GUID: !_Interface[%%A]_GUID!
	echo MAC : !_Interface[%%A]_Mac!
)

:wifi
Set _Temp=0
set _Wifi_Count=0
set _Wifi_String=
set "_file=!temp!\wifi_scan_!random!!random!!random!!random!.txt"
If Exist "!_file!" (del /f /q "!_file!" >nul 2>nul)
timeout /t 1 >nul
for /f "skip=2 tokens=*" %%A in ('netsh wlan show networks mode^=bssid interface^="!_Interface[0]_name!"') do (
	if /i "!_Temp!" == "0" (
		set "_Wifi_String=%%A"
		set _Temp=1
	) Else (
		echo.%%A >>"!_file!"
	)
)

echo !_Wifi_String!
call :extract_num "!_Wifi_String!" _Wifi_Count
echo Available Networks: !_Wifi_Count!

set _Temp=0
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
			set "_SSID=!_SSID:SSID=!"
			REM echo !_SSID!
			for /L %%a in (0,1,9) do (set "_SSID=!_SSID:%%a=!")
			REM echo. !_SSID!.
			set "_SSID=!_SSID: =!"
			REM echo !_SSID!
			
			if "!_SSID!" == "" (
				REM Echo _SSID: %%A
				Set _Temp=1
				Set /A _Wifi_Index+=1
			)
			set _Count=0
		)
		
		Set /A _Count+=1
		if !_Count! GTR 8 (Set _Temp=0)
		
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

for /l %%A in (0,1,!_Wifi_Index!) do (
	Call Getlen "!Wifi[%%A]_SSID!"
	set len=!errorlevel!
	set /a _add_spaces=!wifi_max_length!-!len!
	set "_TempWifiName=!Wifi[%%A]_SSID!"
	if /i "!_TempWifiName!" == "Hidden_Network" (set "_TempWifiName=!_Negative!!_TempWifiName!!_Positive!")
	for /l %%a in (0,1,!_add_spaces!) do (set "_TempWifiName=!_TempWifiName! ")
	
	set /a _Sr=%%A+1
	if !_Sr! lSS 9 (set "_Sr= !_Sr!") Else (set "_Sr=!_Sr!")
	
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
echo 'S' to scan again and 'Q' to quit
choice /c SQ
cls
if %errorlevel% == 1 (goto :Wifi)
exit

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