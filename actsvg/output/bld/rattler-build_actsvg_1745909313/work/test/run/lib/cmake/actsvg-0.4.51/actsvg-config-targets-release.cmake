#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "actsvg::core" for configuration "Release"
set_property(TARGET actsvg::core APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(actsvg::core PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libactsvg_core.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libactsvg_core.dylib"
  )

list(APPEND _cmake_import_check_targets actsvg::core )
list(APPEND _cmake_import_check_files_for_actsvg::core "${_IMPORT_PREFIX}/lib/libactsvg_core.dylib" )

# Import target "actsvg::meta" for configuration "Release"
set_property(TARGET actsvg::meta APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(actsvg::meta PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libactsvg_meta.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libactsvg_meta.dylib"
  )

list(APPEND _cmake_import_check_targets actsvg::meta )
list(APPEND _cmake_import_check_files_for_actsvg::meta "${_IMPORT_PREFIX}/lib/libactsvg_meta.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
