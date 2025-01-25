go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\botsay.exe -ldflags="-s" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
