set "CGO_ENABLED=0"
set "LDFLAGS=-s -w -X main.version=%PKG_VERSION%"
go build -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="%LDFLAGS%" .\cmd\vale || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
