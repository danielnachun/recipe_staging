cmake -S . -B build -G Ninja ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=%PREFIX%/lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF || goto :error

cmake --build build || goto :error
cmake --install build || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
