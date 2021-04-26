@ECHO OFF
REM --- Local Multiplayer Tic-Tac-Toe in Batch ---

SET RESETVARVAR=0
SET ROUNDCOUNTER=0
SET PLAYERPOINTS=0
SET ENEMYPOINTS=0
SET GAMEMODE=0
SET XROUNDS=0
SET DETER=-1


CALL :RESETVAR

CALL :GETNAME

REM Gets the lobby leader
:NEWLOBBY
	
	ECHO Do you want to...
	ECHO 1 - start a lobby?
	ECHO 2 - join a lobby?
	SET /P ID=: 
	ECHO:
	IF /I "%ID%" EQU "1" SET "SYM=X" & SET "CSYM=O" & DEL *.temp & GOTO BEGIN 
	IF /I "%ID%" EQU "2" SET "SYM=O" & SET "CSYM=X" & GOTO JOIN
	ECHO Unrecognised input, try again!
	ECHO:
GOTO NEWLOBBY

REM Get game settings
:BEGIN

	ECHO Choose game mode.
	ECHO 1 - 1 Round
	ECHO 2 - Best of X rounds
	ECHO:
	SET /P GAMEMODE=: 
	ECHO:
	ECHO:
	IF "%GAMEMODE%" EQU "2" ECHO How many rounds? && SET /P XROUNDS=: 
	ECHO:
	
	REM Decide who is starting
	CALL :GETBEGINNER
		
	ECHO %BEGINNER%-START-%YOURNAME% > "sync.temp"
	ECHO %GAMEMODE%-START-%XROUNDS% > "gmode.temp"

	IF "%BEGINNER%" EQU "1" SET "BEGINNER=0" & GOTO SKIP
	IF "%BEGINNER%" EQU "0" SET "BEGINNER=1"

	:SKIP
	
	CALL :SEARCHENEMY

	REM If enemy found -> Start
	SET ENEMYNAME=%SINPUT:~0,-7%

	IF "%BEGINNER%" EQU "1" GOTO LOOPBEG
	IF "%BEGINNER%" EQU "0" GOTO LOOPJOI
		
	
REM Get game settings
:JOIN

	CALL :SEARCHGAME
	
	REM If enemy found -> Start
	SET BEGINNER=%SINPUT:~0,1%
	SET ENEMYNAME=%SINPUT:~8,-1%
	SET GAMEMODE=%GINPUT:~0,1%
	SET XROUNDS=%GINPUT:~8,-1%
	ECHO %YOURNAME%-FOUND > "sync.temp"
	
	IF "%BEGINNER%" EQU "1" GOTO LOOPBEG
	IF "%BEGINNER%" EQU "0" GOTO LOOPJOI		


REM Main loop - Beginner
:LOOPBEG
CLS

	CALL :HEADER
		ECHO:
		ECHO Your turn!
		flash -c 0
	CALL :PLAYINGFIELD
	CALL :INPUT
	
	CALL :WINCHECK
	IF "-1" NEQ "%DETER%" GOTO :RFINISH
	
	CALL :SEARCHINPUT

	CALL :SYNCPOINTS

	CALL :WINCHECK
	IF "-1" NEQ "%DETER%" GOTO :RFINISH

GOTO LOOPBEG


REM Main loop - Joiner
:LOOPJOI
CLS

	CALL :SEARCHINPUT

	CALL :SYNCPOINTS

	CALL :WINCHECK
	IF "-1" NEQ "%DETER%" GOTO :RFINISH

	CALL :HEADER
		ECHO:
		ECHO Your turn!
		flash -c 0
	CALL :PLAYINGFIELD
	CALL :INPUT

	CALL :WINCHECK
	IF "-1" NEQ "%DETER%" GOTO :RFINISH
	
GOTO LOOPJOI


:YOURNAMEWON
	CLS
	SET /A "PLAYERPOINTS=%PLAYERPOINTS%+%INK%"
	CALL :HEADER
	CALL :PLAYINGFIELD
	ECHO You won this round against %ENEMYNAME%!
	ECHO:
	PAUSE
	SET DETER=1
EXIT /B

:ENEMYNAMEWON
	CLS
	SET /A "ENEMYPOINTS=%ENEMYPOINTS%+%INK%"
	CALL :HEADER
	CALL :PLAYINGFIELD
	ECHO You lost this round against %ENEMYNAME%!
	ECHO:
	PAUSE
	SET DETER=1
EXIT /B

:TIE
	CLS
	CALL :HEADER
	CALL :PLAYINGFIELD
	ECHO Tie!
	ECHO:
	PAUSE
	SET DETER=1
EXIT /B


REM Round finished
:RFINISH
CALL :RESETVAR
IF "%GAMEMODE%" EQU "1" GOTO NORMAL
IF "%GAMEMODE%" EQU "2" GOTO BESTOFTHREE

:BESTOFTHREE

SET /A SUMPOINTS=%PLAYERPOINTS%+%ENEMYPOINTS%

SET twuwu=2
SET /A PTR=%XROUNDS%/%twuwu%

SET /A PTR=%PTR%+%INK%

IF "%PLAYERPOINTS%" EQU "%PTR%" GOTO YOURNAMEWONGAME
IF "%ENEMYPOINTS%" EQU "%PTR%" GOTO ENEMYNAMEWONGAME

IF "%ID%" EQU "1" IF "%PLAYERPOINTS%" LSS "%PTR%" IF "%BEGINNER%" EQU "1" GOTO LOOPJOI
IF "%ID%" EQU "2" IF "%ENEMYPOINTS%" LSS "%PTR%" IF "%BEGINNER%" EQU "1" GOTO LOOPJOI
IF "%ID%" EQU "1" IF "%PLAYERPOINTS%" LSS "%PTR%" IF "%BEGINNER%" EQU "0" GOTO LOOPBEG
IF "%ID%" EQU "2" IF "%ENEMYPOINTS%" LSS "%PTR%" IF "%BEGINNER%" EQU "0" GOTO LOOPBEG


:NORMAL

ECHO:
ECHO Another game?
ECHO 1 - Yes.
ECHO 2 - No.
SET /P REMATCH=: 

IF "%REMATCH%" EQU "1" CLS & CALL :RESETVAR & GOTO NEWLOBBY
IF "%REMATCH%" EQU "2" EXIT
CLS
ECHO Unrecognised input, please try again.
GOTO NORMAL

:YOURNAMEWONGAME
CLS
	CALL :HEADER
	CALL :PLAYINGFIELD
ECHO You won the game!
ECHO:
GOTO NORMAL

:ENEMYNAMEWONGAME
CLS
	CALL :HEADER
	CALL :PLAYINGFIELD
ECHO You lost the game!
ECHO:
GOTO NORMAL

pause
DEL sync.temp
EXIT


::--------------------

REM Rolls dice
:GETBEGINNER
	REM Using Powershell because %RANDOM% is not random enough
	FOR /F %%n IN ('powershell -NoLogo -NoProfile -Command Get-Random -Maximum 2') DO (SET "BEGINNER=%%~n")
EXIT /B

::--------------------

REM Gets playername
:GETNAME
	SET /P YOURNAME=Enter your name: 
	ECHO:
EXIT /B

::--------------------

REM Draws header
:HEADER
	ECHO ^[%PLAYERPOINTS%^]  %YOURNAME% ( %SYM% ) vs ( %CSYM% ) %ENEMYNAME%  ^[%ENEMYPOINTS%^]
EXIT /B

::--------------------

REM Draws playingfiled
:PLAYINGFIELD
	ECHO:
	ECHO:
	ECHO 	/---^|---^|---\
	ECHO 	^| %ONE% ^| %TWO% ^| %THREE% ^|
	ECHO 	^|-----------^|
	ECHO 	^| %FOUR% ^| %FIVE% ^| %SIX% ^|
	ECHO 	^|-----------^|
	ECHO 	^| %SEVEN% ^| %EIGHT% ^| %NINE% ^|
	ECHO 	\---^|---^|---/
	ECHO:
	ECHO:
EXIT /B

::--------------------

REM Syncronises points
:SYNCPOINTS
	IF "%SINPUT:~3,1%" EQU "%ONE%" SET ONE=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%TWO%" SET TWO=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%THREE%" SET THREE=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%FOUR%" SET FOUR=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%FIVE%" SET FIVE=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%SIX%" SET SIX=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%SEVEN%" SET SEVEN=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%EIGHT%" SET EIGHT=%CSYM:~0,1%
	IF "%SINPUT:~3,1%" EQU "%NINE%" SET NINE=%CSYM:~0,1%
	SET /A "COUNTER=%COUNTER%+%INK%"
	DEL %ENEMYNAME%.temp
	SET SINPUT=1
	
EXIT /B

::--------------------

REM Checks state of game
:WINCHECK

	IF "%COUNTER%" EQU "9" CALL :TIE

	IF "%ONE%" EQU "%TWO%" IF "%TWO%" EQU "%THREE%" IF "%TWO%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%ONE%" EQU "%TWO%" IF "%TWO%" EQU "%THREE%" IF "%TWO%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%FOUR%" EQU "%FIVE%" IF "%FIVE%" EQU "%SIX%" IF "%FIVE%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%FOUR%" EQU "%FIVE%" IF "%FIVE%" EQU "%SIX%" IF "%FIVE%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%SEVEN%" EQU "%EIGHT%" IF "%EIGHT%" EQU "%NINE%" IF "%EIGHT%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%SEVEN%" EQU "%EIGHT%" IF "%EIGHT%" EQU "%NINE%" IF "%EIGHT%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%ONE%" EQU "%FOUR%" IF "%FOUR%" EQU "%SEVEN%" IF "%FOUR%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%ONE%" EQU "%FOUR%" IF "%FOUR%" EQU "%SEVEN%" IF "%FOUR%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%TWO%" EQU "%FIVE%" IF "%FIVE%" EQU "%EIGHT%" IF "%FIVE%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%TWO%" EQU "%FIVE%" IF "%FIVE%" EQU "%EIGHT%" IF "%FIVE%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%THREE%" EQU "%SIX%" IF "%SIX%" EQU "%NINE%" IF "%SIX%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%THREE%" EQU "%SIX%" IF "%SIX%" EQU "%NINE%" IF "%SIX%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON
 
	IF "%ONE%" EQU "%FIVE%" IF "%FIVE%" EQU "%NINE%" IF "%FIVE%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%ONE%" EQU "%FIVE%" IF "%FIVE%" EQU "%NINE%" IF "%FIVE%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	IF "%THREE%" EQU "%FIVE%" IF "%FIVE%" EQU "%SEVEN%" IF "%FIVE%" EQU "%SYM:~0,1%" CALL :YOURNAMEWON
	IF "%THREE%" EQU "%FIVE%" IF "%FIVE%" EQU "%SEVEN%" IF "%FIVE%" EQU "%CSYM:~0,1%" CALL :ENEMYNAMEWON

	
EXIT /B

::--------------------

REM Resets variables
:RESETVAR
	SET INK=1
	SET ONE=1
	SET TWO=2
	SET THREE=3
	SET FOUR=4
	SET FIVE=5
	SET SIX=6
	SET SEVEN=7
	SET EIGHT=8
	SET NINE=9
	SET COUNTER=0
	SET DETER=-1
EXIT /B

::--------------------

REM Waits for input
:INPUT
	SET /P GINPUT=Choose a number: 

	SET STATE="0"
	IF "%GINPUT%" EQU "X" GOTO NOPE
	IF "%GINPUT%" EQU "O" GOTO NOPE
	IF "%GINPUT%" EQU "%ONE%" SET STATE=1 & SET ONE=%SYM:~0,1%
	IF "%GINPUT%" EQU "%TWO%" SET STATE=1 & SET TWO=%SYM:~0,1%
	IF "%GINPUT%" EQU "%THREE%" SET STATE=1 & SET THREE=%SYM:~0,1%
	IF "%GINPUT%" EQU "%FOUR%" SET STATE=1 & SET FOUR=%SYM:~0,1%
	IF "%GINPUT%" EQU "%FIVE%" SET STATE=1 & SET FIVE=%SYM:~0,1%
	IF "%GINPUT%" EQU "%SIX%" SET STATE=1 & SET SIX=%SYM:~0,1%
	IF "%GINPUT%" EQU "%SEVEN%" SET STATE=1 & SET SEVEN=%SYM:~0,1%
	IF "%GINPUT%" EQU "%EIGHT%" SET STATE=1 & SET EIGHT=%SYM:~0,1%
	IF "%GINPUT%" EQU "%NINE%" SET STATE=1 & SET NINE=%SYM:~0,1%
	IF "%STATE%" EQU "1 " ECHO YES%GINPUT% > "%YOURNAME%.temp"
	IF "%STATE%" EQU "1 " SET /A "COUNTER=%COUNTER%+%INK%" & EXIT /B

	CLS
	CALL :HEADER
	CALL :PLAYINGFIELD
	ECHO Unrecognised input, try again!
GOTO INPUT

::--------------------

REM Search for game
:SEARCHGAME
	SET /P SINPUT=< "sync.temp" > NUL
	SET /P GINPUT=< "gmode.temp" > NUL
	IF "%SINPUT:~2,5%" EQU "START" IF "%GINPUT:~2,5%" EQU "START" CLS & flash -c 0 & EXIT /B
	CLS
	ECHO Waiting for game leader...
	TIMEOUT 1 /nobreak > NUL
GOTO SEARCHGAME

::--------------------

REM Waits for enemy to join
:SEARCHENEMY
	SET /P SINPUT=< "sync.temp" > NUL
	IF "%SINPUT:~-6,-1%" EQU "FOUND" CLS & flash -c 0 & EXIT /B
	CLS
	ECHO Waiting for enemy...
	TIMEOUT 1 /nobreak > NUL
GOTO SEARCHENEMY

::--------------------

REM Searches for enemy input
:SEARCHINPUT
	SET /P SINPUT=<"%ENEMYNAME%.temp" > NUL
	CLS
	IF "%SINPUT:~0,3%" EQU "YES" EXIT /B
	CALL :HEADER
	CALL :PLAYINGFIELD
	ECHO:
	ECHO Waiting for input from %ENEMYNAME%...
	TIMEOUT 2 /nobreak > NUL
	CLS
GOTO SEARCHINPUT