"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit /B 1
