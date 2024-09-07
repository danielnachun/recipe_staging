:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
cargo install --no-trackj --locked --root "%LIBRARY_PREFIX%" --path crates\jsona-cli || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
