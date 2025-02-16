@echo off
::LINE ADDED HERE
set "_text=%~1"
Setlocal EnableDelayedExpansion

REM This Getlen function is not created by Kvc...but it is modified and enhanced by kvc & Sounak...
REM I don't Know about the original Programmer, but I appriciate his/her work...


REM It makes it fast and efficient for calculating the length of longer strings...
REM  It can calculate upto 8100 aprox. characters...

REM Get More Extensions Like this @ https://batchprogrammers.blogspot.com

REM It is an upgrade to the older getlen.exe function, which was created using cpp's getlen function...
Set ver=3.0

REM Setting up initial length...
set len=0

REM Checking for various inputs to the fucntion...
::REPLACED ALL VARIABLES
IF /i "!_text!" == "" (Goto :End)
IF /i "!_text!" == "/h" (Goto :Help)
IF /i "!_text!" == "/?" (Goto :Help)
IF /i "!_text!" == "-h" (Goto :Help)
IF /i "!_text!" == "Help" (Goto :Help)
IF /i "!_text!" == "ver" (Echo.%ver% && Goto :EOF)

:Main
::REPLACED INPUT VARIABLE
set "s=!_text!#"
for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%P,1!" NEQ "" ( 
        set /a "len+=%%P"
        set "s=!s:~%%P!"
    )
)

:End
REM The Method Used below is called 'Tunneling in batch'...
REM Using the variable of previous block in new block...
Endlocal && Exit /b %len%

:Help
Echo.
Echo. Calculates the Length of The Given String. Including special characters.
Echo.
Echo. Syntax: Call Getlen [String]
Echo. Where
Echo.
Echo. String:	It is the String, Whose length to be calculated.
Echo.
Echo. The length of the string is Returned in to the Main fucntion through the
Echo. Environmental Errorlevel variable.
Echo.
Echo. Try these lines in a Batch file: [E.g.]
Echo.
Echo. Call Getlen "Karan Veer Chouhan"
Echo. Echo. %%Errorlevel%%
Echo.
ECHo. #TheBATeam
Goto :End