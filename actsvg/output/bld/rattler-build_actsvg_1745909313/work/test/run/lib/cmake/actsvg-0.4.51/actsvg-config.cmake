# Set up the helper functions/macros.

####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was actsvg-config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

####################################################################################

# Set up some simple variables for using the package.
set( actsvg_VERSION "0.4.51" )
set_and_check( actsvg_INCLUDE_DIR
   "${PACKAGE_PREFIX_DIR}/include" )
set_and_check( actsvg_CMAKE_DIR "${PACKAGE_PREFIX_DIR}/lib/cmake/actsvg-0.4.51" )

# Print a standard information message about the package being found.
include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( actsvg REQUIRED_VARS
   CMAKE_CURRENT_LIST_FILE
   VERSION_VAR actsvg_VERSION )

# Include the file listing all the imported targets and options.
include( "${actsvg_CMAKE_DIR}/actsvg-config-targets.cmake" )
