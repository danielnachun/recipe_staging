:: go one level up
cd %SRC_DIR%
cd ..

:: create the gopath directory structure
set "GOPATH=%CD%\gopath"
mkdir "%GOPATH%\src\github.com\jesseduffield" || goto :error
mklink /D "%GOPATH%\src\github.com\jesseduffield\lazygit" "%SRC_DIR%" || goto :error
cd "%GOPATH%\src\github.com\jesseduffield\lazygit"

:: build the project
set "CGO_ENABLED=0"  :: disable CGO, as there are no C libs to load
set "LDFLAGS=-s -w"  :: omit the symbol table / debug information and
                     :: DWARF symbol table.
go build  -ldflags "%LDFLAGS%" || goto :error

:: install the binary
mv "%GOPATH%\..\work\lazygit" "%LIBRARY_BIN%\lazygit" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
