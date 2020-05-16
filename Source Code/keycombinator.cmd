@echo off
setlocal enabledelayedexpansion

	cd BF_Files
	title  Key Combinator - Developed By TUX
	mode con:cols=60 lines=30
	::%60 Char %20 Digit %10 Symbol %10 Previous
	
	set how_many_passwords_per_length=
	set until_where=
	set current_char=nothing
	set current_digit=nothing
	set current_symbol=nothing
	set current_add=0
	set add_current_thing=false
	
	set /a char_code=0
	set /a digit_code=0
	set /a symbol_code=0
	set /a choice_code=0
	
	
	set char_list=abcdefghijklmnoprstuvyzxwq 
		
	set digit_list=1234567890

	set symbol_list=-_
	
	goto :main
	
	
	
	:userinput
	call colorchar.exe /0a " cmd"
	call colorchar.exe /0f "@"
	call colorchar.exe /08 "user"
	call colorchar.exe /0f "[]-"
	
	
	goto :eof
	
	
	:select_char
	set current_char=!char_list:~%1,1!
	set current_add=!current_char!
	goto :eof
	
	
	
	:select_digit
	set current_digit=!digit_list:~%1,1!
	set current_add=!current_digit!
	goto :eof
	
	
	
	:select_symbol	
	set current_symbol=!symbol_list:~%1,1!
	set current_add=!current_symbol!
	goto :eof
	
	
	
	:select_choice
	

	set /a choice_code=!random! %% 10 + 1
	
	
	
	if !choice_code!==1 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
		if !choice_code!==2 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
		if !choice_code!==3 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
		if !choice_code!==4 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
		if !choice_code!==5 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
		if !choice_code!==6 (
	set /a char_code=!random! %% 26
	call :select_char !char_code!
	)
	
	if !choice_code!==7 (
	set /a digit_code=!random! %% 10
	call :select_digit !digit_code!
	)
		if !choice_code!==8 (
	set /a digit_code=!random! %% 10
	call :select_digit !digit_code!
	)


	
	
	if !choice_code!==9 (
	set /a symbol_code=!random! %% 2
	call :select_symbol !symbol_code!
	)
	
	if !choice_code!==10 (
	set add_current_thing=true
	)
	goto :eof

	
	
	
	
	
	
	
	:main
	echo.
	echo  [==================================================]
	call colorchar.exe /0b "                Key Combinator 1.0.0"
	echo.
	echo  [==================================================]
	call colorchar.exe /0e "                  Developed By TUX"
	echo.
	echo  [==================================================]
	echo.
	echo  What is the limit length for creating passwords? (8-?)
	call :userinput
	set /p until_where=
	
	if !until_where! lss 8 (
		echo.
		call colorchar.exe /0c " Bad input..."
		timeout /t 3 >nul
		cls
		set until_where=
		goto :main
	)
	
	
	echo.
	echo  How many passwords will generated per length?
	call :userinput
	set /p how_many_passwords_per_length=
	cls
	
	

	
	
	
	
	
	
	echo  Generating Passwords...
	
	
	
	
	:password_generation
	
		for /l %%a in ( 8, 1, !until_where! ) do (
	
			set current_pass_length=%%a
		
				for /l %%a in (1,1,!how_many_passwords_per_length!) do (
		
		
					for /l %%a in ( 1,1, !current_pass_length!) do (
		
				
						if !add_current_thing!==true (
						set master_password=!master_password!!current_add!
						set add_current_thing=false
						)else (
						call :select_choice
						set master_password=!master_password!!current_add!
						)
					
		
						if %%a==!current_pass_length! (
						set /a passwords_generated=!passwords_generated!+1
						echo !master_password!>>passlist_raw.txt
						set master_password=
						)
				

					)
						cls
						echo  Generating Passwords...
						echo  Total Generated !passwords_generated!
				
				)
	
		)

	cls
	echo.
	echo  [==========================]
	call colorchar.exe /0a "  Creating Of List Complete"
	echo.
	echo   Passwords generated: !passwords_generated!
	echo  [==========================]
	echo.
	echo  Press any key to continue...
	pause >nul
	exit
	

	
	
	