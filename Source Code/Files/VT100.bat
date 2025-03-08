@Echo off
::Setlocal EnableDelayedExpansion

REM THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY
REM KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
REM WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
REM AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
REM HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
REM WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
REM DEALINGS IN THE SOFTWARE.

REM This program is distributed under the following license:

REM ================================================================================
REM GNU General Public License (GPL) - https://opensource.org/licenses/gpl-license
REM ================================================================================

REM ================= ABOUT THE PROGRAM =================
REM This program is created by Kvc at '02-11-2023 - 20:05'
REM This program is a library  That simplifies complex VT100 escape sequences into an easy to use system, 
REM enabling users to effortlessly enhance their CMD experience with advanced formatting and control options.
REM Thankyou to the members of Server.bat (on Disocrd), especially Sintrode, rifteyy, Yeshi and Most importantly
REM Icarus (Batch Macros GOD) for suggesting use of escape sequences to enhance my projects. (Directly or indirectly)
REM For More Visit: www.batch-man.com

REM Setting version information...
Set __ver=20250106

REM Checking for various parameters of the function...
If /i "%~1" == "--help" (goto :help)
If /i "%~1" == "-h" (goto :help)
If /i "%~1" == "-help" (goto :help)
If /i "%~1" == "/?" (goto :help)
If /i "%~1" == "-?" (goto :help)
::If /i "%~1" == "" (goto :help)

REM Adding special parameter to get cur pos... 
If /i "%~1" == "_CurGetPos" (Call :get_cursor_pos& exit /b)
Set CurX=
Set CurY=

If /i "%~1" == "ver" (Echo.%_ver%&Goto :End)

REM Starting Main Program...
:Main
REM This library is created from the documentation from the official Microsoft website:
REM https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences

REM Avoiding Redefining the VT100 Core Variables...
REM If DEFINED __VT100__ (Goto :End)
SET "__VT100__=VT100 library Included"

REM -- Cursor Positioning -- 
SET _CurTopLeft=[H
SET _CurUp@n=[nA
SET _CurUp=[1A
SET _CurDown@n=[nB
SET _CurDown=[1B
SET _CurRight@n=[nC
SET _CurRight=[1C
SET _CurLeft@n=[nD
SET _CurLeft=[nD
SET _CurNextLine@n=[nE
SET _CurNextLine=[1E
SET _CurPrevLine@n=[nF
SET _CurPrevLine=[1F
SET _Cur@X=[xG
SET _goto@X=[xG
SET _Cur@Y=[yd
SET _goto@Y=[yd
SET _Cur@X;Y=[x;yH
SET _goto@X;Y=[x;yH
SET _Cur@X;Y2=[x;y2f
SET _CurSavePos=[s
SET _CurRestorePos=[u
REM SET _CurGetPos=^&Call getcurpos

REM -- Cursor Visibility -- 
SET _CurEnableBlink=[?12h
SET _CurDisableBlink=[?12l
SET _CurShow=[?25h
SET _CurHide=[?25l

REM -- Cursor Shape -- 
SET _CurDefaultShape=[0SPq
SET _CurBlink=[1SPq
SET _CurSteady=[2SPq
SET _CurBlinkUnderline=[3SPq
SET _CurSteadyUnderline=[4SPq
SET _CurBlinkBar=[5SPq
SET _CurSteadyBar=[6SPq

REM -- Viewport Positioning -- 
SET _SmoothScroll=[?4h
SET _JumpScroll=[?4l
SET _ScrollUp@n=[nS
SET _ScrollUp=[1S
SET _ScrollDown@n=[nT
SET _ScrollDown=[1T
SET _ScrollArea@n;m=[n;mr


REM -- Text Modification -- 
SET _InsertChar@n=[n@
SET _DeleteChar@n=[np
SET _EraseChar@n=[nX
SET _InsertLine@n=[nL
SET _DeleteLine@n=[nM
SET _EraseDisplay@n=[nJ
SET _EraseLine@n=[nK

REM -- Text Formatting -- 
REM -- Foreground coloring... -- 
SET _Black=[30m
SET _Red=[31m
SET _Green=[32m
SET _Yellow=[33m
SET _Blue=[34m
SET _Magenta=[35m
SET _Cyan=[36m
SET _White=[37m
REM SET _ExtRGB@n;n;n=[38m
SET _FgDefault=[39m

REM -- Bold Foreground coloring... -- 
SET _BoldBlack=[90m
SET _BoldRed=[91m
SET _BoldGreen=[92m
SET _BoldYellow=[93m
SET _BoldBlue=[94m
SET _BoldMagenta=[95m
SET _BoldCyan=[96m
SET _BoldWhite=[97m


REM -- Background coloring... -- 
SET _BgBlack=[40m
SET _BgRed=[41m
SET _BgGreen=[42m
SET _BgYellow=[43m
SET _BgBlue=[44m
SET _BgMagenta=[45m
SET _BgCyan=[46m
SET _BgWhite=[47m
REM SET _BgExtRGB@n;n;n=[48m
SET _BgDefault=[49m

SET _Default=%_BgDefault%%_FgDefault%

REM -- Bold Background coloring... -- 
SET _BgBoldBlack=[100m
SET _BgBoldRed=[101m
SET _BgBoldGreen=[102m
SET _BgBoldYellow=[103m
SET _BgBoldBlue=[104m
SET _BgBoldMagenta=[105m
SET _BgBoldCyan=[106m
SET _BgBoldWhite=[107m

REM -- Screen Data Manipulation --
REM -- Alternate Screen Buffer... -- 
SET _AltScreen=[?1049h
SET _MainScreen=[?1049l
SET _ClsBelow=[J
SET _ClsAbove=[1J
SET _ClsLineRight=[K
SET _ClsLineLeft=[1K
SET _ClsLine=[2K
SET _Cls=[2J

REM -- Text manipulation --
SET _ResetAll=[0m
SET _Reset=[0m
SET _Bold=[1m
SET _NoBold=[22m
SET _Underline=[4m
SET _NoUnderline=[24m
SET _Negative=[7m
SET _Positive=[27m
SET _LowIntensity=[2m
SET _Blink=[5m
SET _Invisible=[8m
SET _BigTextTopHalf=#3
SET _BigTextBottomHalf=#4

REM There is a bug with windows terminal and VT100 escape codes compatibility, when printing the big text on terminal...
REM it breaks down the printing of big text due to the scrolling in terminal and This is a known issue...
REM https://github.com/microsoft/terminal/issues/14622
REM _BigText@t doesn't work due to this near the scroll edges...
@REM SET _BigText@t=%_CurSavePos%%_ClsLine%%_CurRestorePos%%_BigTextTopHalf%t%_CurRestorePos%%_CurDown%%_ClsLine%%_CurRestorePos%%_CurDown%%_BigTextBottomHalf%t
SET _BigText@t=%_CurSavePos%%_CurDown%%_BigTextBottomHalf%t%_CurRestorePos%%_BigTextTopHalf%t%_CurDown%

Goto :End


:End
Goto :EOF

:Help
REM File calling itself... so the VT100 can be used for the help menu...
Call "%~0"
Echo. Loading help page...
@REM Echo.  %_AltScreen% %_Cur@Y:y=0%
Echo. This program is a library that %_black%%_bgYellow%simplifies complex VT100 escape sequences%_Default% into an easy
Echo. to use system, enabling users to effortlessly enhance their CMD experience with advanced 
Echo. formatting and control options.
Echo. Thankyou to the members of %_black%%_BgYellow%Server.bat (on Disocrd)%_Default%, especially Sintrode, rifteyy, Yeshi 
Echo. and Most importantly Icarus for suggesting use of escape sequences to ehance my projects.
Echo. CREDITS: VT100 %_ver% by Kvc
echo.
echo. Syntax: %_Yellow%call VT100%_Default%
echo. Syntax: %_Yellow%call VT100 [help , /? , -h , -help]%_Default%
echo. Syntax: %_Yellow%call VT100 ver%_Default%
echo.
echo.
echo. %_BigText@t:t=Where:-%
echo.
echo. ver		: Displays version of program
echo. help		: Displays help for the program
Echo.
Echo. Example: %_Yellow%Call VT100%_Default%
Echo. Example: %_Yellow%Call VT100 ver%_Default%
Echo. Example: %_Yellow%Call VT100 [/? , -h , -help , help]%_Default%
Echo.
Echo. Simply Call the VT100.bat file (as shown in example above) and use the defined VT100 escape
Echo. codes as related variable names...
Echo. %_BoldCyan%%_Underline%Following variables are defined by this library:%_NoUnderline%
Echo. %_Cyan%%_BgBlack%

REM Reading variable list from the current file.. so, the Help menu will be up to date...
REM And, Avoiding using _ (underscore) for variable names... as we do not want to capture these variables...
Set counter=0
Set Line=
SetLocal EnableDelayedExpansion
for /f "usebackq tokens=1,2* delims==" %%a in ("%~0") do (
	if /i "%%~a" == ":help" (Goto :break_loop)


	echo. %%~a | find /i "REM --" 2>nul >nul && (
		set "_heading=%%~a"
		echo.!line!
		echo.
		echo !_Negative!!_heading:~3!!_Positive!
		set counter=0
		set line=
		)
	
	for /f "tokens=1,2*" %%A in ('echo %%~a ^| find /i "set _"') do (
		Set "Line=!Line!%%~B		"
		Set /A counter+=1
		Set /A mod=!counter! %% 4
		if !mod! == 0 (Echo. !Line! && Set Line=)
		)
	)
	
:break_loop
Endlocal
Echo. %_Default%
Echo. www.batch-man.com
Echo. #batch-man
Echo.
@REM choice /c Q /m "Press 'Q' to go back to exit HELP Menu ..."
@REM Echo. %_MainScreen%
Goto :End

