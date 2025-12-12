@echo on
@setlocal EnableDelayedExpansion

go build -o=%LIBRARY_PREFIX%\bin\dx-download-agent.exe -ldflags="-s" .\cmd\dx-download-agent || goto :error
go-licenses save .\cmd\dx-download-agent --save_path=license-files || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
