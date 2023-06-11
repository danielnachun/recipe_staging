set "CGO_ENABLED=0"
set "LDFLAGS=-s -w -X 'github.com/tomwright/dasel/internal.Version=%PKG_VERSION%'"
go build -trimpath -o="%PREFIX%/bin/%PKG_NAME%" -ldflags="%LDFLAGS%" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
