rem The system Makeconf file takes priority over Makevars.win in the src dir.
rem In conda's system Makeconf file, CXX14 is set to nothing, causing the
rem compilation to break, even when it is set properly in Makevars.win
rem So we append the proper Makevars to the system Makeconf here
set MAKECONF_FILE="%BUILD_PREFIX%\lib\R\etc\x64\Makeconf"
copy "%MAKECONF_FILE%" "%MAKECONF_FILE%.old"
echo CXX14 = $^(BINPREF^)g++ $^(M_ARCH^) >> "%MAKECONF_FILE%"
echo CXX14STD = -std=gnu++14 >> "%MAKECONF_FILE%"
echo CXX14FLAGS = -Wa,-mbig-obj -g0 -O2 >> "%MAKECONF_FILE%"

"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1

rem Set Makeconf back to what it was before
move /Y "%MAKECONF_FILE%.old" "%MAKECONF_FILE%"