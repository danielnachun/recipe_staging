set "CGO_ENABLED=0"
set "LDFLAGS=-s -w"
go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\2fa.exe" -ldflags="%LDFLAGS%" -mod=mod || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
