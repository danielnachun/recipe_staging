set "CGO_ENABLED=0"
set "LDFLAGS=-s -w"
go build -trimpath -o="%LIBRARY_BIN%\yq.exe" -ldflags="%LDFLAGS%" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
