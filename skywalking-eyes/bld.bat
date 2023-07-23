set "CGO_ENABLED=0"
set "LDFLAGS=-s -w -X github.com/apache/skywalking-eyes/commands.version=%PKG_VERSION%"
go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="%LDFLAGS%" .\cmd\license-eye || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
